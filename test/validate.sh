#!/usr/bin/env bash
#
# validate.sh — Static validation for the Loadout repository
# Runs all checks, reports all failures, exits with error count.
#

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
errors=0

info()  { printf '\033[1;34m[INFO]\033[0m  %s\n' "$1"; }
pass()  { printf '\033[1;32m[PASS]\033[0m  %s\n' "$1"; }
fail()  { printf '\033[1;31m[FAIL]\033[0m  %s\n' "$1"; errors=$((errors + 1)); }

# ---------------------------------------------------------------------------
# 1. Shebang check
# ---------------------------------------------------------------------------
info "Checking shebangs..."
while IFS= read -r f; do
    first_line="$(head -1 "$f")"
    case "$f" in
        *.sh)
            if [[ "$first_line" != "#!/usr/bin/env bash" ]]; then
                fail "$f: expected #!/usr/bin/env bash, got: $first_line"
            fi
            ;;
        *.py)
            if [[ "$first_line" != "#!/usr/bin/env python3" ]]; then
                fail "$f: expected #!/usr/bin/env python3, got: $first_line"
            fi
            ;;
    esac
done < <(find "$REPO_ROOT" -type f \( -name '*.sh' -o -name '*.py' \) -not -path '*/.git/*')
pass "Shebangs"

# ---------------------------------------------------------------------------
# 2. Executable bit
# ---------------------------------------------------------------------------
info "Checking executable bits..."
if command -v git >/dev/null 2>&1 && [ -d "$REPO_ROOT/.git" ]; then
    while IFS= read -r line; do
        mode="$(echo "$line" | awk '{print $1}')"
        file="$(echo "$line" | awk '{print $4}')"
        if [[ "$mode" != "100755" ]]; then
            fail "$file: not executable in git (mode $mode)"
        fi
    done < <(cd "$REPO_ROOT" && git ls-files --stage '*.sh' '*.py' 2>/dev/null)
fi
pass "Executable bits"

# ---------------------------------------------------------------------------
# 3. shellcheck
# ---------------------------------------------------------------------------
info "Running shellcheck..."
if command -v shellcheck >/dev/null 2>&1; then
    while IFS= read -r f; do
        if ! shellcheck --severity=warning "$f" >/dev/null 2>&1; then
            fail "shellcheck: $f"
            shellcheck --severity=warning "$f" 2>&1 | head -20
        fi
    done < <(find "$REPO_ROOT" -type f -name '*.sh' -not -path '*/.git/*')
    pass "shellcheck"
else
    info "shellcheck not found, skipping"
fi

# ---------------------------------------------------------------------------
# 4. Python syntax
# ---------------------------------------------------------------------------
info "Checking Python syntax..."
while IFS= read -r f; do
    if ! python3 -m py_compile "$f" 2>/dev/null; then
        fail "Python syntax: $f"
    fi
done < <(find "$REPO_ROOT" -type f -name '*.py' -not -path '*/.git/*')
pass "Python syntax"

# ---------------------------------------------------------------------------
# 5. JSON validation
# ---------------------------------------------------------------------------
info "Validating JSON files..."
while IFS= read -r f; do
    if ! python3 -m json.tool "$f" >/dev/null 2>&1; then
        fail "Invalid JSON: $f"
    fi
done < <(find "$REPO_ROOT" -type f -name '*.json' -not -path '*/.git/*')
pass "JSON"

# ---------------------------------------------------------------------------
# 6. Plist validation
# ---------------------------------------------------------------------------
info "Validating plist files..."
while IFS= read -r f; do
    if ! python3 -c "import plistlib; plistlib.load(open('$f','rb'))" 2>/dev/null; then
        fail "Invalid plist: $f"
    fi
done < <(find "$REPO_ROOT" -type f -name '*.plist' -not -path '*/.git/*')
pass "Plists"

# ---------------------------------------------------------------------------
# 7. Brewfile syntax
# ---------------------------------------------------------------------------
info "Checking Brewfile syntax..."
while IFS= read -r f; do
    line_num=0
    while IFS= read -r line; do
        line_num=$((line_num + 1))
        # Skip blank lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        if ! echo "$line" | grep -qE '^(tap|brew|cask|mas|vscode)\s+'; then
            fail "$f:$line_num: invalid Brewfile line: $line"
        fi
    done < "$f"
done < <(find "$REPO_ROOT" -type f -name 'Brewfile*' -not -path '*/.git/*')
pass "Brewfiles"

# ---------------------------------------------------------------------------
# 8. Secrets scan
# ---------------------------------------------------------------------------
info "Scanning for secrets..."
secret_patterns='(sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36}|AKIA[A-Z0-9]{16}|xoxb-[0-9]|-----BEGIN.*PRIVATE KEY-----)'
while IFS= read -r f; do
    if grep -qE "$secret_patterns" "$f" 2>/dev/null; then
        fail "Possible secret in: $f"
    fi
done < <(find "$REPO_ROOT" -type f \( -name '*.sh' -o -name '*.py' -o -name '*.json' -o -name '*.yml' -o -name '*.yaml' \) -not -path '*/.git/*' -not -name 'validate.sh')
pass "Secrets scan"

# ---------------------------------------------------------------------------
# 9. Hardcoded path scan
# ---------------------------------------------------------------------------
info "Scanning for hardcoded paths..."
while IFS= read -r f; do
    if grep -qE '(/Users/|/home/)' "$f" 2>/dev/null; then
        fail "Hardcoded user path in: $f"
    fi
done < <(find "$REPO_ROOT" -type f \( -name '*.sh' -o -name '*.py' \) -not -path '*/.git/*' -not -name 'validate.sh')
pass "Hardcoded paths"

# ---------------------------------------------------------------------------
# 10. Static idempotency checks
# ---------------------------------------------------------------------------
info "Checking idempotency patterns..."
while IFS= read -r f; do
    # Flag >> appends that aren't guarded
    if grep -nE '>>' "$f" | grep -vE '(>>|/dev/null|\.log)' >/dev/null 2>&1; then
        # Check if the line has a guard (if/test/[[ before it)
        while IFS= read -r match; do
            line_num="$(echo "$match" | cut -d: -f1)"
            # Look for guard in preceding lines
            prev_start=$((line_num > 3 ? line_num - 3 : 1))
            context="$(sed -n "${prev_start},${line_num}p" "$f")"
            if ! echo "$context" | grep -qE '(if |then|\[\[|\[ |grep -q)'; then
                fail "$f:$line_num: unguarded >> append"
            fi
        done < <(grep -nE '>>' "$f" | grep -vE '(/dev/null|\.log)')
    fi
    # Flag mkdir without -p (only actual mkdir commands, not references in strings)
    if grep -nE '^\s*mkdir [^-]' "$f" | grep -vE 'mkdir -p' >/dev/null 2>&1; then
        fail "$f: mkdir without -p flag"
    fi
done < <(find "$REPO_ROOT" -type f -name '*.sh' -not -path '*/.git/*' -not -name 'validate.sh')
pass "Idempotency patterns"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
if [[ "$errors" -eq 0 ]]; then
    printf '\033[1;32mAll checks passed.\033[0m\n'
    exit 0
else
    printf '\033[1;31m%d check(s) failed.\033[0m\n' "$errors"
    exit "$errors"
fi
