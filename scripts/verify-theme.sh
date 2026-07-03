#!/usr/bin/env bash
# Verify Chalkboard Engineering Blueprint theme migration. Exits non-zero on any failure.
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

echo "== 3. Core chalkboard tokens defined with planned values =="
grep -q -- "--bg: #0D3B2F;"              "$CSS" && ok "--bg"                     || bad "--bg missing/wrong"
grep -q -- "--phosphor-bright: #F2EBD8;" "$CSS" && ok "--phosphor-bright (cream)" || bad "--phosphor-bright missing/wrong"
grep -q -- "--phosphor-body: #D8D2BD;"   "$CSS" && ok "--phosphor-body"          || bad "--phosphor-body missing/wrong"
grep -q -- "--phosphor-muted: #ADB8A3;"  "$CSS" && ok "--phosphor-muted"         || bad "--phosphor-muted missing/wrong"
grep -q -- "--glow-bright: none;"        "$CSS" && ok "--glow-bright neutralized" || bad "--glow-bright not none"
grep -q -- "--glow-amber: none;"         "$CSS" && ok "--glow-amber neutralized"  || bad "--glow-amber not none"

echo "== 4. CRT residue removed =="
RESIDUE=0
for pat in "#33FF33" "#FFB000" "#001100" "#66AA66" "#88C488" "#33CC33" "#003300" "#001a00" "rgba(51,255,51" "rgba(51, 255, 51" "rgba(255,176,0" "crt-flicker" "radial-gradient"; do
  if grep -qiF -- "$pat" "$CSS"; then bad "CRT residue remains: $pat"; RESIDUE=$((RESIDUE+1)); fi
done
[ "$RESIDUE" -eq 0 ] && ok "no CRT residue" || true

echo "== 5. Chalkboard grid background present =="
grep -q "background-size: 32px 32px;" "$CSS"                && ok "grid cell size"       || bad "grid background-size missing"
grep -qF "linear-gradient(90deg, rgba(242, 235, 216" "$CSS" && ok "vertical grid lines"  || bad "vertical grid lines missing"

echo "== 6. Font strategy =="
grep -q "Playfair+Display" "$CSS" && ok "Playfair Display imported" || bad "Playfair Display import missing"
grep -q "Noto+Serif+KR"    "$CSS" && ok "Noto Serif KR imported"    || bad "Noto Serif KR import missing"
grep -q -- "--font-display: 'Playfair Display'" "$CSS" && ok "--font-display token" || bad "--font-display missing"
grep -q "'JetBrains Mono'" "$CSS" && ok "JetBrains Mono kept for code" || bad "JetBrains Mono missing"
DISPLAY_USES=$(grep -c "var(--font-display)" "$CSS" | tr -d ' ')
if [ "$DISPLAY_USES" -ge 4 ]; then ok "--font-display applied to headings ($DISPLAY_USES uses)"; else bad "--font-display used only $DISPLAY_USES times (<4)"; fi

echo "== 7. prefers-reduced-motion gate present =="
grep -q "prefers-reduced-motion" "$CSS" && ok "reduced-motion gate exists" || bad "no reduced-motion gate"

echo ""
echo "Result: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
