#!/usr/bin/env bash
# Verify Phosphor CRT theme migration. Exits non-zero on any failure.
set -euo pipefail

CSS="css/style.css"
PASS=0; FAIL=0
ok()   { echo "  [PASS] $1"; PASS=$((PASS+1)); }
bad()  { echo "  [FAIL] $1"; FAIL=$((FAIL+1)); }

echo "== 1. HTML files unchanged (no diff vs HEAD) =="
HTML_CHANGED=$(git diff --name-only HEAD -- '*.html' | wc -l | tr -d ' ')
if [ "$HTML_CHANGED" -eq 0 ]; then ok "no HTML files modified"; else bad "$HTML_CHANGED HTML files modified"; fi

echo "== 2. CSS braces balanced =="
OPEN=$(grep -o '{' "$CSS" | wc -l | tr -d ' ')
CLOSE=$(grep -o '}' "$CSS" | wc -l | tr -d ' ')
if [ "$OPEN" -eq "$CLOSE" ]; then ok "braces balanced ($OPEN/$CLOSE)"; else bad "braces unbalanced ($OPEN open / $CLOSE close)"; fi

echo "== 3. Core tokens defined with planned values =="
grep -q -- "--crt-bg: #001100;"        "$CSS" && ok "--crt-bg"        || bad "--crt-bg missing/wrong"
grep -q -- "--phosphor-bright: #33FF33;" "$CSS" && ok "--phosphor-bright" || bad "--phosphor-bright missing/wrong"
grep -q -- "--phosphor-body: #66AA66;"   "$CSS" && ok "--phosphor-body"   || bad "--phosphor-body missing/wrong"
grep -q -- "--phosphor-muted: #88C488;"  "$CSS" && ok "--phosphor-muted"  || bad "--phosphor-muted missing/wrong"
grep -q -- "--amber: #FFB000;"           "$CSS" && ok "--amber"           || bad "--amber missing/wrong"

echo "== 4. prefers-reduced-motion gate present =="
grep -q "prefers-reduced-motion" "$CSS" && ok "reduced-motion gate exists" || bad "no reduced-motion gate"

echo "== 5. CRT effect elements present =="
grep -q "repeating-linear-gradient" "$CSS" && ok "scanline gradient" || bad "no scanline gradient"
grep -q "radial-gradient" "$CSS"          && ok "vignette gradient" || bad "no vignette gradient"

echo "== 6. Neubrutalism residue removed =="
# These candy hexes are the neubrutalism signature and must be gone.
RESIDUE=0
for hex in "#fff9ef" "#ffd64d" "#ffc7d8" "#7cb8ff" "#9ff3df" "#ff9e7a" "#fff3c4"; do
  if grep -qi -- "$hex" "$CSS"; then bad "neubrutalism hex remains: $hex"; RESIDUE=$((RESIDUE+1)); fi
done
[ "$RESIDUE" -eq 0 ] && ok "no neubrutalism candy hexes" || true

echo "== 7. Monospace font stack includes JetBrains Mono =="
grep -q "JetBrains Mono" "$CSS" && ok "JetBrains Mono in stack" || bad "JetBrains Mono missing"

echo ""
echo "Result: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
