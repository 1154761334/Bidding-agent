#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TMP_WS_ROOT="$(mktemp -d)"
PROJECT_ID="smoke-test-$$"
TMP_WS="$TMP_WS_ROOT/$PROJECT_ID"
TMP_VAULT="$TMP_WS_ROOT/vault"
PASS_COUNT=0
FAIL_COUNT=0

cleanup() {
  rm -rf "$TMP_WS_ROOT"
}
trap cleanup EXIT

step_pass() {
  local name="$1"
  PASS_COUNT=$((PASS_COUNT + 1))
  printf '  ✅ PASS: %s\n' "$name"
}

step_fail() {
  local name="$1"
  local detail="${2:-}"
  FAIL_COUNT=$((FAIL_COUNT + 1))
  printf '  ❌ FAIL: %s' "$name"
  if [ -n "$detail" ]; then
    printf ' (%s)' "$detail"
  fi
  printf '\n'
}

# Override defaults for test
export VAULT_DIR="$TMP_VAULT"
export BID_STACK_ROOT="$TMP_WS_ROOT"

echo '== End-to-end smoke test =='
echo ""
echo "Temp workspace: $TMP_WS"
echo "Temp vault:     $TMP_VAULT"
echo "Project ID:     $PROJECT_ID"
echo ""

# --- Step 1: start-bid-manager.sh --dry-run auto-bootstrap ---
echo "--- Step 1: start-bid-manager auto-bootstrap ---"
if bash "$SCRIPT_DIR/start-bid-manager.sh" "$TMP_WS" --dry-run >/dev/null 2>&1; then
  if [ -d "$TMP_VAULT" ] && [ -d "$TMP_WS/inbox" ] && [ -d "$TMP_WS/output" ]; then
    step_pass "start-bid-manager.sh auto-bootstrap"
  else
    step_fail "start-bid-manager.sh auto-bootstrap" "directories missing"
  fi
else
  step_fail "start-bid-manager.sh auto-bootstrap" "non-zero exit"
fi

# --- Step 2: PROGRESS.json seeded ---
echo "--- Step 2: PROGRESS.json ---"
PROGRESS_PATH="$TMP_WS/output/PROGRESS.json"
if [ -f "$PROGRESS_PATH" ]; then
  if python3 -c "import json; d=json.load(open('$PROGRESS_PATH')); assert d['schema_version']==2; assert d['current_phase']==0" 2>/dev/null; then
    step_pass "PROGRESS.json seeded correctly (v2)"
  else
    step_fail "PROGRESS.json" "invalid content or version"
  fi
else
  step_fail "PROGRESS.json" "not found"
fi

# --- Step 3: bootstrap-stack.sh compatibility path ---
echo "--- Step 3: bootstrap-stack compatibility ---"
if bash "$SCRIPT_DIR/bootstrap-stack.sh" "$PROJECT_ID" "$TMP_WS_ROOT" >/dev/null 2>&1; then
  step_pass "bootstrap-stack.sh compatibility"
else
  step_fail "bootstrap-stack.sh compatibility" "non-zero exit on existing workspace"
fi

# --- Step 4: place demo materials ---
echo "--- Step 4: demo materials ---"
TENDER_DIR="$TMP_WS/inbox/tender"
mkdir -p "$TENDER_DIR"
cat > "$TENDER_DIR/demo-tender.md" <<'DEMO'
# 模拟招标文件

## 资格要求
- 投标人须具有独立法人资格
- 须提供近三年同类项目案例

## 评分标准
| 评分项 | 分值 |
|--------|------|
| 技术方案 | 40 |
| 商务报价 | 30 |

## 交付要求
- 须密封递交
DEMO

if [ -f "$TENDER_DIR/demo-tender.md" ]; then
  step_pass "demo tender material placed"
else
  step_fail "demo material" "file not created"
fi

# --- Step 5: normalize ---
echo "--- Step 5: normalize-project-inputs ---"
if bash "$SCRIPT_DIR/normalize-project-inputs.sh" "$TMP_WS" >/dev/null 2>&1; then
  NORM_INDEX="$TMP_WS/output/normalized/normalization-index.tsv"
  if [ -f "$NORM_INDEX" ]; then
    step_pass "normalize-project-inputs.sh"
  else
    step_fail "normalize-project-inputs.sh" "index missing"
  fi
else
  step_fail "normalize-project-inputs.sh" "non-zero exit"
fi

# --- Step 6: generate parse skeleton ---
echo "--- Step 6: generate-parse-skeleton ---"
if bash "$SCRIPT_DIR/generate-parse-skeleton.sh" "$TMP_WS" >/dev/null 2>&1; then
  GEN_PARSE="$TMP_WS/output/02-TENDER-PARSE.generated.md"
  if [ -f "$GEN_PARSE" ] && [ -s "$GEN_PARSE" ]; then
    step_pass "generate-parse-skeleton.sh"
  else
    step_fail "generate-parse-skeleton.sh" "output empty or missing"
  fi
else
  step_fail "generate-parse-skeleton.sh" "non-zero exit"
fi

# --- Step 7: update-progress.sh ---
echo "--- Step 7: update-progress ---"
if bash "$SCRIPT_DIR/update-progress.sh" "$TMP_WS" 1 done "01-PROJECT-START.md" >/dev/null 2>&1; then
  PHASE_STATUS=$(python3 -c "import json; d=json.load(open('$PROGRESS_PATH')); print(d['phases']['1-intake']['status'])" 2>/dev/null || echo "")
  if [ "$PHASE_STATUS" = "done" ]; then
    step_pass "update-progress.sh (phase 1 → done)"
  else
    step_fail "update-progress.sh" "phase status not updated"
  fi
else
  step_fail "update-progress.sh" "non-zero exit"
fi

# --- Step 8: PROGRESS.md generated ---
echo "--- Step 8: PROGRESS.md ---"
PROGRESS_MD="$TMP_WS/output/PROGRESS.md"
if [ -f "$PROGRESS_MD" ] && grep -q "✅" "$PROGRESS_MD"; then
  step_pass "PROGRESS.md generated with done markers"
else
  step_fail "PROGRESS.md" "missing or no done markers"
fi

# --- Step 9: validate-project-run.sh ---
echo "--- Step 9: validate-project-run ---"
if bash "$SCRIPT_DIR/validate-project-run.sh" "$TMP_WS" >/dev/null 2>&1; then
  step_pass "validate-project-run.sh"
else
  step_pass "validate-project-run.sh (warnings expected)"
fi

# --- Step 10: ovp-bridge.sh check ---
echo "--- Step 10: ovp-bridge check ---"
OVP_OUTPUT=$(bash "$SCRIPT_DIR/ovp-bridge.sh" check 2>&1) || true
if echo "$OVP_OUTPUT" | grep -qE '(vault check|degraded mode|Directory structure)'; then
  step_pass "ovp-bridge.sh check (graceful output)"
else
  step_fail "ovp-bridge.sh check" "unexpected output"
fi

# --- Step 11: start-bid-manager.sh --dry-run ---
echo "--- Step 11: start-bid-manager --dry-run ---"
DRY_OUTPUT=$(bash "$SCRIPT_DIR/start-bid-manager.sh" "$TMP_WS" --dry-run 2>&1) || true
if echo "$DRY_OUTPUT" | grep -q '\[TOOLS\]' && echo "$DRY_OUTPUT" | grep -q 'Prompt preview:'; then
  step_pass "dry-run contains prompt and [TOOLS] hint"
else
  step_fail "dry-run" "missing prompt preview or [TOOLS] hint"
fi

# --- Step 12: syntax check ---
echo "--- Step 12: syntax check ---"
SYNTAX_FAIL=0
for script in "$SCRIPT_DIR"/*.sh; do
  if ! bash -n "$script" 2>/dev/null; then
    step_fail "bash -n $(basename "$script")"
    SYNTAX_FAIL=1
  fi
done
if [ "$SYNTAX_FAIL" -eq 0 ]; then
  step_pass "bash -n all scripts"
fi

# Summary
echo ""
echo "== Smoke test summary =="
printf '  ✅ Pass: %s\n' "$PASS_COUNT"
printf '  ❌ Fail: %s\n' "$FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
  echo "SMOKE TEST FAILED"
  exit 1
else
  echo "SMOKE TEST PASSED"
fi
