# Package `minisql.planner.logical_plan`

[Home](README.md) · [Packages](Packages.md)

## Files

- [src/minisql/planner/logical_plan.ml](File-src-minisql-planner-logical-plan-ml-661531493.md)

## Symbols

- [`minisql.planner.logical_plan.build`](File-src-minisql-planner-logical-plan-ml-661531493.md#function-function-minisql-planner-logical-plan-build-function-build-bound-src-minisql-planner-logical-plan-ml-35511694) — function
- [`minisql.planner.logical_plan.componentName`](File-src-minisql-planner-logical-plan-ml-661531493.md#function-function-minisql-planner-logical-plan-componentname-function-componentname-src-minisql-planner-logical-plan-ml-526401252) — function
- [`minisql.planner.logical_plan.fail`](File-src-minisql-planner-logical-plan-ml-661531493.md#function-function-minisql-planner-logical-plan-fail-function-fail-code-operation-message-src-minisql-planner-logical-plan-ml-1793763211) — function
- [`minisql.planner.logical_plan.indent`](File-src-minisql-planner-logical-plan-ml-661531493.md#function-function-minisql-planner-logical-plan-indent-function-indent-depth-src-minisql-planner-logical-plan-ml-1779106037) — function
- [`minisql.planner.logical_plan.INVALID_ARGUMENT`](File-src-minisql-planner-logical-plan-ml-661531493.md#constant-constant-minisql-planner-logical-plan-invalid-argument-const-invalid-argument-9001-src-minisql-planner-logical-plan-ml-2084805321) — constant
- [`minisql.planner.logical_plan.isImplemented`](File-src-minisql-planner-logical-plan-ml-661531493.md#function-function-minisql-planner-logical-plan-isimplemented-function-isimplemented-src-minisql-planner-logical-plan-ml-1150103636) — function
- [`minisql.planner.logical_plan.isLogicalPlan`](File-src-minisql-planner-logical-plan-ml-661531493.md#function-function-minisql-planner-logical-plan-islogicalplan-function-islogicalplan-value-src-minisql-planner-logical-plan-ml-2093059229) — function
- [`minisql.planner.logical_plan.joinName`](File-src-minisql-planner-logical-plan-ml-661531493.md#function-function-minisql-planner-logical-plan-joinname-function-joinname-jointype-src-minisql-planner-logical-plan-ml-1814745364) — function
- [`minisql.planner.logical_plan.LogicalPlan`](Type-minisql-planner-logical-plan-logicalplan-1962141215.md) — struct
- [`minisql.planner.logical_plan.node`](File-src-minisql-planner-logical-plan-ml-661531493.md#function-function-minisql-planner-logical-plan-node-function-node-kind-name-details-estimatedrows-children-src-minisql-planner-logical-plan-ml-1264460925) — function
- [`minisql.planner.logical_plan.NODE_AGGREGATE`](File-src-minisql-planner-logical-plan-ml-661531493.md#constant-constant-minisql-planner-logical-plan-node-aggregate-const-node-aggregate-5-src-minisql-planner-logical-plan-ml-473091748) — constant
- [`minisql.planner.logical_plan.NODE_DISTINCT`](File-src-minisql-planner-logical-plan-ml-661531493.md#constant-constant-minisql-planner-logical-plan-node-distinct-const-node-distinct-7-src-minisql-planner-logical-plan-ml-1100229268) — constant
- [`minisql.planner.logical_plan.NODE_FILTER`](File-src-minisql-planner-logical-plan-ml-661531493.md#constant-constant-minisql-planner-logical-plan-node-filter-const-node-filter-4-src-minisql-planner-logical-plan-ml-1712380653) — constant
- [`minisql.planner.logical_plan.NODE_JOIN`](File-src-minisql-planner-logical-plan-ml-661531493.md#constant-constant-minisql-planner-logical-plan-node-join-const-node-join-3-src-minisql-planner-logical-plan-ml-859523072) — constant
- [`minisql.planner.logical_plan.NODE_LIMIT`](File-src-minisql-planner-logical-plan-ml-661531493.md#constant-constant-minisql-planner-logical-plan-node-limit-const-node-limit-10-src-minisql-planner-logical-plan-ml-953856188) — constant
- [`minisql.planner.logical_plan.NODE_PROJECT`](File-src-minisql-planner-logical-plan-ml-661531493.md#constant-constant-minisql-planner-logical-plan-node-project-const-node-project-6-src-minisql-planner-logical-plan-ml-1618517013) — constant
- [`minisql.planner.logical_plan.NODE_SCAN`](File-src-minisql-planner-logical-plan-ml-661531493.md#constant-constant-minisql-planner-logical-plan-node-scan-const-node-scan-2-src-minisql-planner-logical-plan-ml-722631155) — constant
- [`minisql.planner.logical_plan.NODE_SET`](File-src-minisql-planner-logical-plan-ml-661531493.md#constant-constant-minisql-planner-logical-plan-node-set-const-node-set-8-src-minisql-planner-logical-plan-ml-1047055253) — constant
- [`minisql.planner.logical_plan.NODE_SORT`](File-src-minisql-planner-logical-plan-ml-661531493.md#constant-constant-minisql-planner-logical-plan-node-sort-const-node-sort-9-src-minisql-planner-logical-plan-ml-1761587918) — constant
- [`minisql.planner.logical_plan.NODE_VALUES`](File-src-minisql-planner-logical-plan-ml-661531493.md#constant-constant-minisql-planner-logical-plan-node-values-const-node-values-1-src-minisql-planner-logical-plan-ml-203625514) — constant
- [`minisql.planner.logical_plan.render`](File-src-minisql-planner-logical-plan-ml-661531493.md#function-function-minisql-planner-logical-plan-render-function-render-plan-src-minisql-planner-logical-plan-ml-372474821) — function
- [`minisql.planner.logical_plan.renderInto`](File-src-minisql-planner-logical-plan-ml-661531493.md#function-function-minisql-planner-logical-plan-renderinto-function-renderinto-plan-depth-lines-src-minisql-planner-logical-plan-ml-209402609) — function
- [`minisql.planner.logical_plan.setName`](File-src-minisql-planner-logical-plan-ml-661531493.md#function-function-minisql-planner-logical-plan-setname-function-setname-operator-all-src-minisql-planner-logical-plan-ml-1205155633) — function
- [`minisql.planner.logical_plan.targetMilestone`](File-src-minisql-planner-logical-plan-ml-661531493.md#function-function-minisql-planner-logical-plan-targetmilestone-function-targetmilestone-src-minisql-planner-logical-plan-ml-1997098278) — function
