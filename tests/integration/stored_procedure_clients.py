# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
# Licensed under the Apache License, Version 2.0; see LICENSE for details.
"""Disposable localhost regression for procedure results and connector output parameters.

Run with --server /path/to/compiled/minisqld. Optionally supply --jdbc-classpath
and --java to run RoutineLiveTest against the same fixture database.
"""
from pathlib import Path
import argparse
import json
import socket
import subprocess
import sys
import tempfile
import time

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--server", required=True, type=Path)
parser.add_argument("--jdbc-classpath")
parser.add_argument("--java", default="java")
args = parser.parse_args()

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'clients/python'))
import minisql

binary = args.server.resolve()
workspace = tempfile.TemporaryDirectory(prefix="minisql-routine-clients-")
data = Path(workspace.name)

created=subprocess.run([str(binary),'--init',str(data),'routine_clients_'+str(time.time_ns()), '4096'],text=True,capture_output=True)
print(created.stdout,flush=True)
if created.returncode: raise RuntimeError(created.stderr)
path=next(x.removeprefix('MiniSQL database created: ').strip() for x in created.stdout.splitlines() if x.startswith('MiniSQL database created: '))
with socket.socket() as probe:
    probe.bind(('127.0.0.1',0));port=probe.getsockname()[1]
log_path = data/'server.log'
log = log_path.open('w')
proc=subprocess.Popen([str(binary),'--serve',path,str(port),'4'],stdout=log,stderr=subprocess.STDOUT)
results=[]

def check(condition,label):
    """Records one end-to-end observable procedure or connector contract."""
    if not condition: raise AssertionError(label)
    results.append(label)
    print('PASS',label,flush=True)

def consume(cursor):
    """Reads every row result without treating same-column SELECTs as batches."""
    groups=[]
    while True:
        if cursor.description is not None:
            groups.append(cursor.fetchall())
        if cursor.nextset() is None: return groups

try:
    deadline=time.monotonic()+20
    while True:
        try:
            with socket.create_connection(('127.0.0.1',port),timeout=.2): break
        except OSError:
            if proc.poll() is not None or time.monotonic()>deadline: raise RuntimeError('server did not start')
            time.sleep(.05)
    connection=minisql.connect(f'minisql://127.0.0.1:{port}/main',autocommit=True,socket_timeout=15)
    cursor=connection.cursor()
    cursor.execute('CREATE TABLE routine_wire (id INT PRIMARY KEY)')
    cursor.execute('INSERT INTO routine_wire VALUES '+','.join('('+str(i)+')' for i in range(600)))
    cursor.execute('''CREATE PROCEDURE wire(IN p INT, OUT total INT, INOUT accumulator INT)
      BEGIN
        SELECT COUNT(*) INTO total FROM routine_wire;
        SET accumulator = accumulator + p;
        SELECT id AS value FROM routine_wire ORDER BY id;
        SELECT p AS value;
        SELECT id AS empty_result FROM routine_wire WHERE id < 0;
      END''')
    check(True,'create compound procedure over network')
    cursor.execute('SET @total = 0, @acc = 10')
    cursor.execute('CALL wire(5, @total, @acc)')
    groups=consume(cursor)
    check([len(x) for x in groups]==[600,1,0],'600-row continuation, equal-schema second result, empty result')
    check(groups[0][599]==('599',) and groups[1]==[('5',)],'all result values in order')
    cursor.execute('SELECT @total, @acc')
    check(cursor.fetchone()==('600','15'),'OUT and INOUT copied to session variables')
    cursor.close();cursor=connection.cursor()
    updated=cursor.callproc('wire',(5,None,10))
    check(updated==(5,'600','15'),'Python callproc preserves IN and returns OUT/INOUT')
    groups=consume(cursor)
    check([len(x) for x in groups]==[600,1,0],'callproc retains all results after output lookup')
    cursor.execute('''CREATE PROCEDURE handled(OUT code INT)
      BEGIN
        DECLARE CONTINUE HANDLER FOR SQLSTATE '45000' SET code = 42;
        SET code = 0;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'handled application error';
        SELECT code AS code;
      END''')
    out=cursor.callproc('handled',(None,))
    check(out==('42',),'condition handler OUT value exposed through callproc')
    check(consume(cursor)==[[('42',)]],'handled error still returns procedure result')
    cursor.execute("CREATE PROCEDURE broken() SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'deliberate live error'")
    try:
        cursor.execute('CALL broken()')
    except minisql.DatabaseError as error:
        check('deliberate live error' in str(error),'unhandled SIGNAL becomes connector exception')
    else: raise AssertionError('SIGNAL not raised')
    cursor.execute('SELECT 99')
    check(cursor.fetchone()==('99',),'connection remains aligned after procedure error')
    cursor.execute("CREATE PROCEDURE partial_error() BEGIN SELECT 7 AS value; SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'error after completed result'; END")
    cursor.execute('CALL partial_error()')
    check(cursor.fetchall() == [('7',)], 'completed SELECT remains readable before later SIGNAL')
    try:
        cursor.nextset()
    except minisql.DatabaseError as error:
        check('error after completed result' in str(error), 'later SIGNAL is raised by nextset')
    else:
        raise AssertionError('partial-result SIGNAL not raised by nextset')
    cursor.execute('SELECT 100')
    check(cursor.fetchone() == ('100',), 'connection remains aligned after partial-result error')
    cursor.execute('CREATE TABLE routine_signal_count(value INT)')
    cursor.execute("CREATE PROCEDURE signal_collision() BEGIN INSERT INTO routine_signal_count VALUES(1); SIGNAL SQLSTATE '45011' SET MYSQL_ERRNO = 9007, MESSAGE_TEXT = 'application code matches lock code'; END")
    try:
        cursor.execute('CALL signal_collision()')
    except minisql.DatabaseError as error:
        check(error.code == 9007, 'application errno9007 returns directly without lock retry')
    else:
        raise AssertionError('SIGNAL9007 did not raise an application condition')
    cursor.execute('SELECT COUNT(*) FROM routine_signal_count')
    check(cursor.fetchone() == ('1',), 'application errno9007 does not repeat committed side effects')
    cursor.execute("CREATE PROCEDURE deadlock_collision() SIGNAL SQLSTATE '45012' SET MYSQL_ERRNO = 9031, MESSAGE_TEXT = 'application code matches deadlock code'")
    cursor.execute('START TRANSACTION')
    cursor.execute('INSERT INTO routine_signal_count VALUES(2)')
    try:
        cursor.execute('CALL deadlock_collision()')
    except minisql.DatabaseError as error:
        check(error.code == 9031, 'application errno9031 remains an application condition')
    else:
        raise AssertionError('SIGNAL9031 did not raise an application condition')
    # The executor may require rollback after an unhandled condition, but the
    # listener must not independently roll the caller transaction back.
    cursor.execute('ROLLBACK')
    cursor.close();connection.close()
    if args.jdbc_classpath:
        jdbc = subprocess.run([args.java, '-cp', args.jdbc_classpath,
            'org.minilang.minisql.jdbc.RoutineLiveTest', f'jdbc:minisql://127.0.0.1:{port}/main'],
            text=True, capture_output=True, timeout=40)
        print(jdbc.stdout, flush=True)
        if jdbc.returncode:
            raise RuntimeError(jdbc.stderr)
        check(True, 'JDBC real server procedure suite')
    print(f"MiniSQL live procedure connector tests: SUCCESS ({len(results)} checks)", flush=True)
except BaseException:
    log.flush()
    print(log_path.read_text(), file=sys.stderr)
    raise
finally:
    proc.terminate()
    try: proc.wait(timeout=10)
    except subprocess.TimeoutExpired: proc.kill();proc.wait()
    log.close()
    workspace.cleanup()
