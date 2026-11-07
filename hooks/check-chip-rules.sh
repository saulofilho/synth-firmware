#!/bin/sh
# check-chip-rules.sh — advisory lint for the FM-1 (JieLi AC791N) chip rules.
# These are prompts, not verdicts: ./build.sh is the authority on image/RAM/pool
# size and ROM-range constants. This only flags the integer-only rule early.
#
# Modes:
#   check-chip-rules.sh <path>   scan a file or dir (default firmware/src), print findings
#   check-chip-rules.sh --hook   PostToolUse: read the tool JSON on stdin, lint the edited
#                                file only, and emit additionalContext if anything looks off.
#
# Never fails the tool: always exits 0.
set -u

# $1 = file, $2 = mode ("full" keeps the code line, "terse" omits it)
# Host/web files (name has "web", or host.c) compile for a real CPU with an FPU,
# so the device chip rules do not apply — skip them.
scan_file() {
  [ -f "$1" ] || return 0
  case "$1" in *web*|*/host.c|host.c) return 0 ;; esac
  awk -v mode="$2" '
    {
      line = $0
      gsub(/\/\*.*\*\//, "", line)                  # whole-line block comments
      sub(/\/\*.*/, "", line)                        # block comment that runs off the line
      sub(/\*\/.*/, "", line)                        # tail of a block comment
      sub(/\/\/.*/, "", line)                        # // comments
      if (line ~ /^[ \t]*\*/) line = ""              # block-comment continuation lines
      hit = ""
      if (line ~ /(^|[^_a-zA-Z0-9])(float|double)([^_a-zA-Z0-9]|$)/)
        hit = "float/double (no FPU; use Q15/Q12 fixed point)"
      else if (line ~ /(int64_t|uint64_t|long long|s64|u64)/ && line ~ /[\/%]/)
        hit = "64-bit / or % (no __udivdi3; shift or divide 32-bit values)"
      else if (line ~ /0[xX]FFC[0-9A-Fa-f][0-9A-Fa-f]/)
        hit = "looks like a chip-ROM address 0xFFCxxxxx (the build rejects these)"
      if (hit != "") {
        if (mode == "full") printf("  %s:%d  %s\n      %s\n", FN, NR, hit, $0)
        else                printf("%s:%d %s; ", FN, NR, hit)
      }
    }
  ' FN="$1" "$1"
}

scan_path() {
  p="$1"
  if [ -f "$p" ]; then scan_file "$p" full
  elif [ -d "$p" ]; then
    find "$p" \( -name '*.c' -o -name '*.h' \) -type f 2>/dev/null | sort | while IFS= read -r f; do
      scan_file "$f" full
    done
  fi
}

if [ "${1:-}" = "--hook" ]; then
  input=$(cat 2>/dev/null | tr '\n' ' ')
  file=$(printf '%s' "$input" | sed -n 's/.*"file_path"[^"]*"\([^"]*\)".*/\1/p' | head -n1)
  case "$file" in
    */firmware/*.c|*/firmware/*.h|firmware/*.c|firmware/*.h|*.c|*.h)
      # only lint real C/H under a firmware tree
      case "$file" in *firmware*) : ;; *) exit 0 ;; esac ;;
    *) exit 0 ;;
  esac
  findings=$(scan_file "$file" terse)
  if [ -n "$findings" ]; then
    msg="FM-1 chip-rule check on $file: $findings(review each — the build is the authority). See the synth-firmware skill, chip-rules.md."
    # emit as additionalContext; keep it on one line, no quotes in msg
    printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"%s"}}\n' "$msg"
  fi
  exit 0
fi

# direct mode
target="${1:-firmware/src}"
out=$(scan_path "$target")
if [ -n "$out" ]; then
  echo "FM-1 chip-rule check — possible issues in $target:"
  echo "$out"
  echo "Review each (false positives: a float in a string, a 32-bit divide). ./build.sh is the authority."
else
  echo "FM-1 chip-rule check — no float/double, 64-bit division, or ROM-range constants found in $target."
fi
exit 0
