#!/usr/bin/env bash
# Family check (CosmoKundli design system, guardrails).
# Pages build screens from the kit (lib/ui) only. A page that animates a
# stat itself, draws its own loading, or blurs on its own breaks the family,
# and this check fails the build. A line that must stay (a diagram, not a
# stat) carries a "family-ok:" comment with the reason.
set -u
cd "$(dirname "$0")/../lib/pages"
fail=0
check() {
  local pattern="$1" why="$2"
  local hits
  hits=$(grep -nE "$pattern" ./*.dart | grep -v "family-ok:" || true)
  if [ -n "$hits" ]; then
    echo "FAMILY CHECK: $why"
    echo "$hits" | sed 's/^/  /'
    fail=1
  fi
}
check '\bAnimationController\b'      'pages must not run their own animation; use a kit piece (lib/ui)'
check '\bTweenAnimationBuilder\b'    'pages must not animate values; every stat goes through StatValue'
check '\bLinearProgressIndicator\b'  'a stat shown as a bar uses Meter (kit), not a progress indicator'
check '\bFutureBuilder\b'            'loading data uses DataBuilder / FastFuture / LoadView (kit)'
check '\bBackdropFilter\b|ImageFilter\.blur' 'blur belongs to Glass (kit) only'
check '\bCustomPaint\b'              'stats are drawn by kit pieces (StatValue, Meter, RingMeter, GrahBarChart, DailyBarChart)'
if [ $fail -ne 0 ]; then
  echo "Family check failed. See the family plan: every stat, list and screen comes from the kit."
  exit 1
fi
echo "Family check passed."
