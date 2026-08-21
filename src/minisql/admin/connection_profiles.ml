package minisql.admin.connection_profiles

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.admin.fullclient as fullclient
import minisql.config.loader as json
import minisql.platform.file as file_api

const INVALID_ARGUMENT = 9001
const MAX_PROFILE_DOCUMENT_BYTES = 16777216
const CP_UTF8 = 65001
const WC_ERR_INVALID_CHARS = 0x80
const MAX_ENVIRONMENT_UTF16_UNITS = 32768

// Reads a Windows environment variable as UTF-16 so non-ASCII profile paths remain lossless.
extern function GetEnvironmentVariableW(name as wstr, buffer as bytes, size as u32) from "kernel32.dll" symbol "GetEnvironmentVariableW" returns u32
// Converts a UTF-16 environment value into the UTF-8 representation used by MiniLang strings.
extern function WideCharToMultiByte(codePage as u32, flags as u32, wideText as bytes, wideCount as i32, output as bytes, outputCount as i32, defaultChar as ptr, usedDefault as ptr) from "kernel32.dll" symbol "WideCharToMultiByte" returns i32

// Creates a namespaced profile-store error.
function fail(operation, message)
  return error(INVALID_ARGUMENT, "admin.connection_profiles." + operation + ": " + message)
end function

// Returns one Unicode Windows environment variable as UTF-8 or an empty string when unavailable.
function environment(name)
  wide = bytes(MAX_ENVIRONMENT_UTF16_UNITS * 2, 0)
  count = GetEnvironmentVariableW(name, wide, MAX_ENVIRONMENT_UTF16_UNITS)
  if count == 0 or count >= MAX_ENVIRONMENT_UTF16_UNITS then return "" end if
  required = WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, wide, count, void, 0, void, void)
  if required <= 0 then return "" end if
  output = bytes(required, 0)
  actual = WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, wide, count, output, required, void, void)
  if actual != required then return "" end if
  value = decode(output)
  if typeof(value) != "string" then return "" end if
  return value
end function

// Resolves the per-user connection-alias file and creates its parent directory.
function defaultPath()
  override = environment("MINISQL_ADMIN_PROFILE_PATH")
  if len(override) > 0 then return override end if
  appData = environment("APPDATA")
  if len(appData) == 0 then return "minisql-workbench-profiles.json" end if
  directory = file_api.joinPath(appData, "MiniSQL")
  created = try(file_api.createDirectory(directory))
  if typeof(created) == "error" then return created end if
  return file_api.joinPath(directory, "workbench-profiles.json")
end function

// Returns the first-run trusted-local alias used by the connection manager.
function defaultProfile()
  return fullclient.createProfile("Local MiniSQL", "127.0.0.1", 7432, "localhost", "main", "", false, "", true)
end function

// Revalidates a profile through the canonical model constructor.
function validate(profile)
  if typeof(profile) != "struct" then return fail("validate", "profile must be ConnectionProfile") end if
  return fullclient.createProfile(profile.name, profile.address, profile.port, profile.serverName, profile.databaseName, profile.userName, profile.tls, profile.pinSha256, profile.trustedLocal)
end function

// Escapes a UTF-8 profile field while preserving every valid non-ASCII byte unchanged.
function escape(value)
  if typeof(value) != "string" then return fail("escape", "value must be string") end if
  // JSON structural characters become two-byte escape sequences. UTF-8 bytes
  // are copied as a unit and decoded only after the complete sequence exists,
  // avoiding accidental decoding of an individual continuation byte.
  output = bytes(0)
  hexDigits = bytes("0123456789ABCDEF")
  for each item in bytes(value)
    if item == 34 then output = output + bytes("\\\"")
    else if item == 92 then output = output + bytes("\\\\")
    else if item == 8 then output = output + bytes("\\b")
    else if item == 12 then output = output + bytes("\\f")
    else if item == 10 then output = output + bytes("\\n")
    else if item == 13 then output = output + bytes("\\r")
    else if item == 9 then output = output + bytes("\\t")
    else if item < 32 then output = output + bytes("\\u00") + bytes([hexDigits[item >> 4], hexDigits[item & 15]])
    else output = output + bytes([item])
    end if
  end for
  encoded = decode(output)
  if typeof(encoded) != "string" then return fail("escape", "profile field is not valid UTF-8") end if
  return encoded
end function

// Serializes one validated alias without a password or other secret.
function profileJson(profile)
  checked = try(validate(profile))
  if typeof(checked) == "error" then return checked end if
  tls = "false"
  if checked.tls then tls = "true" end if
  trusted = "false"
  if checked.trustedLocal then trusted = "true" end if
  return "{\"name\":\"" + escape(checked.name) + "\",\"address\":\"" + escape(checked.address) + "\",\"port\":" + checked.port + ",\"serverName\":\"" + escape(checked.serverName) + "\",\"database\":\"" + escape(checked.databaseName) + "\",\"user\":\"" + escape(checked.userName) + "\",\"tls\":" + tls + ",\"pinSha256\":\"" + escape(checked.pinSha256) + "\",\"trustedLocal\":" + trusted + "}"
end function

// Serializes all aliases using a versioned JSON envelope.
function serialize(profiles)
  if typeof(profiles) != "array" then return fail("serialize", "profiles must be array") end if
  output = "{\"schemaVersion\":2,\"profiles\":["
  if len(profiles) > 0 then
    for index = 0 to len(profiles) - 1
      encoded = try(profileJson(profiles[index]))
      if typeof(encoded) == "error" then return encoded end if
      if index > 0 then output = output + "," end if
      output = output + encoded
    end for
  end if
  return output + "]}\n"
end function

// Durably replaces the alias file through a flushed temporary sibling.
function write(path, text)
  temporary = path + ".new"
  // A stale sibling can remain only after an interrupted older save. Removing
  // it first makes every retry deterministic without touching the live file.
  if file_api.fileExists(temporary) then ignoredStale = try(file_api.deletePath(temporary)) end if
  handle = try(file_api.createDurable(temporary))
  if typeof(handle) == "error" then return handle end if
  payload = bytes(text)
  result = try(file_api.writeAt(handle, 0, payload, 0, len(payload)))
  if typeof(result) == "error" then ignoredClose = try(file_api.close(handle)); ignoredDelete = try(file_api.deletePath(temporary)); return result end if
  flushed = try(file_api.flush(handle))
  if typeof(flushed) == "error" then ignoredClose = try(file_api.close(handle)); ignoredDelete = try(file_api.deletePath(temporary)); return flushed end if
  closed = try(file_api.close(handle))
  if typeof(closed) == "error" then ignoredDelete = try(file_api.deletePath(temporary)); return closed end if
  published = try(file_api.movePath(temporary, path, true))
  if typeof(published) == "error" then ignoredDelete = try(file_api.deletePath(temporary)); return published end if
  return published
end function

// Persists aliases atomically and never serializes the connection password.
function save(path, profiles)
  if typeof(path) != "string" or len(path) == 0 then return fail("save", "path must be non-empty") end if
  document = try(serialize(profiles))
  if typeof(document) == "error" then return document end if
  return write(path, document)
end function

// Decodes one schema-version-two profile object.
function profileFromJson(value)
  name = try(json.stringMember(value, "name"))
  if typeof(name) == "error" then return name end if
  address = try(json.stringMember(value, "address"))
  if typeof(address) == "error" then return address end if
  port = try(json.intMember(value, "port"))
  if typeof(port) == "error" then return port end if
  serverName = try(json.stringMember(value, "serverName"))
  if typeof(serverName) == "error" then return serverName end if
  databaseName = try(json.stringMember(value, "database"))
  if typeof(databaseName) == "error" then return databaseName end if
  userName = try(json.stringMember(value, "user"))
  if typeof(userName) == "error" then return userName end if
  tls = try(json.boolMember(value, "tls"))
  if typeof(tls) == "error" then return tls end if
  pinSha256 = try(json.stringMember(value, "pinSha256"))
  if typeof(pinSha256) == "error" then return pinSha256 end if
  trustedLocal = try(json.boolMember(value, "trustedLocal"))
  if typeof(trustedLocal) == "error" then return trustedLocal end if
  return fullclient.createProfile(name, address, port, serverName, databaseName, userName, tls, pinSha256, trustedLocal)
end function

// Loads aliases or returns the first-run default when no file exists.
function load(path)
  if typeof(path) != "string" or len(path) == 0 then return fail("load", "path must be non-empty") end if
  if not file_api.fileExists(path) then return [defaultProfile()] end if
  text = try(file_api.readAllText(path, MAX_PROFILE_DOCUMENT_BYTES))
  if typeof(text) == "error" then return text end if
  document = try(json.parse(text))
  if typeof(document) == "error" then return document end if
  schemaVersion = try(json.intMember(document, "schemaVersion"))
  if typeof(schemaVersion) == "error" or schemaVersion != 2 then return fail("load", "unsupported profile schema") end if
  values = try(json.member(document, "profiles"))
  if typeof(values) == "error" or values.kind != json.JSON_ARRAY then return fail("load", "profiles array is invalid") end if
  profiles = []
  for each value in values.items
    profile = try(profileFromJson(value))
    if typeof(profile) == "error" then return profile end if
    profiles = profiles + [profile]
  end for
  return profiles
end function

// Replaces an alias by name or appends it when it is new.
function replace(profiles, profile)
  checked = try(validate(profile))
  if typeof(checked) == "error" then return checked end if
  output = []
  replaced = false
  for each existing in profiles
    if existing.name == checked.name then output = output + [checked]; replaced = true else output = output + [existing] end if
  end for
  if not replaced then output = output + [checked] end if
  return output
end function

// Removes the alias with the supplied exact name.
function remove(profiles, name)
  output = []
  for each profile in profiles
    if profile.name != name then output = output + [profile] end if
  end for
  return output
end function

// Returns the stable module name used by smoke tests.
function componentName()
  return "admin.connection_profiles"
end function

// Identifies the GUI integration milestone.
function targetMilestone()
  return "M74"
end function

// Reports that persistent aliases are implemented.
function isImplemented()
  return true
end function
