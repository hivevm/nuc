#!/usr/bin/env bash
#
# Self-test of scripts/sensor-plain-rules.sh. Verifies: ADR-0002
#
# Each case builds a throwaway git repository under a temporary directory: main holds an
# AGENTS.md and one ADR, a branch changes them, and the sensor runs against main. The cases are a
# table of what the change adds and what the sensor must and must not print: a long sentence in
# the Decision and in the Enforcement, one in the Context, one held in a code span, a soft modal
# verb in AGENTS.md, named in italics, after an italic that wraps, in a block quote, in fenced
# code, and on a line the change did not add, a sentence that ends early, a change outside the
# rules, the working tree with an untracked ADR, and a base that does not resolve.
#
# Inputs: scripts/sensor-plain-rules.sh scripts/lib/
#
# Usage:
#     scripts/test-sensor-plain-rules.sh
# Exit code 0 when every case passes, 1 otherwise.

set -uo pipefail

# shellcheck source-path=SCRIPTDIR source=lib/selftest.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/selftest.sh"
SENSOR="$ROOT/scripts/sensor-plain-rules.sh"

LONG="The session that reads this rule before it starts any work must find every single word of it in the glossary and must also know who acts here."
SHORT="The human decides."

# git_in <dir> <args...> — git in the fixture, with an author.
git_in() {
  fixture "$1"
  local dir="$1"; shift
  git -C "${dir:?}" -c user.name=fixture -c user.email=fixture@example.invalid "$@"
}

# repo <name> — main with AGENTS.md and docs/adr/0001-x.md, then the branch 'work' checked out.
repo() {
  local dir="$work/$1"
  mkdir -p "$dir/docs/adr"
  git -C "${dir:?}" init -q -b main
  printf '# Agent Guide\n\n## 1. Rules\n\n- %s\n- Old line that says should.\n' "$SHORT" > "$dir/AGENTS.md"
  printf '# ADR-0001: X\n\n- **Status:** 🟢 accepted\n\n## Context\n\n%s\n\n## Decision\n\n%s\n\n## Enforcement\n\n%s\n' \
    "$SHORT" "$SHORT" "$SHORT" > "$dir/docs/adr/0001-x.md"
  git_in "$dir" add -A
  git_in "$dir" commit -q -m start
  git_in "$dir" switch -q -c work
  echo "$dir"
}

# after <dir> <file> <heading> <text> — insert a paragraph after the heading line, and commit.
after() {
  fixture "$1"
  awk -v h="$3" -v t="$4" '{ print } $0 == h { print ""; print t }' "$1/$2" > "$1/$2.new"
  mv "$1/$2.new" "$1/$2"
  git_in "$1" commit -q -am "change $2"
}

# expect <name> <dir> <needle> <absent> [args...] — run the sensor; exit 0, output with the needle
# and without the absent text (either may be empty).
expect() {
  local name="$1" dir="$2" needle="$3" absent="$4"; shift 4
  local out rc
  out="$(bash "$SENSOR" --root "$dir" "$@" 2>&1)"; rc=$?
  if [[ $rc -eq 0 && "$out" == *"$needle"* && ( -z "$absent" || "$out" != *"$absent"* ) ]]; then
    passed=$((passed + 1))
    return
  fi
  failed=$((failed + 1))
  echo "FAIL: $name (got exit $rc)" >&2
  while IFS= read -r l; do printf '    %s\n' "$l"; done <<< "$out" >&2
}

# --- cases -----------------------------------------------------------------------------------

r="$(repo decision)"
after "$r" docs/adr/0001-x.md "## Decision" "$LONG"
expect "a long sentence in the Decision: listed with file, line, and count" "$r" \
  "docs/adr/0001-x.md:11: a sentence of 28 words" "" main

r="$(repo enforcement)"
after "$r" docs/adr/0001-x.md "## Enforcement" "$LONG"
expect "a long sentence in the Enforcement: listed" "$r" "a sentence of 28 words" "" main

r="$(repo context)"
after "$r" docs/adr/0001-x.md "## Context" "$LONG"
expect "a long sentence in the Context: not listed" "$r" "no long sentence" "" main

r="$(repo code-span)"
after "$r" docs/adr/0001-x.md "## Decision" "Run \`$LONG\` first."
expect "a long sentence in a code span: not listed" "$r" "no long sentence" "" main

r="$(repo two-lines)"
after "$r" docs/adr/0001-x.md "## Decision" "$(printf '%s\n%s' "${LONG%% before it*}" "before it${LONG#* before it}")"
expect "a long sentence wrapped over two lines: counted as one" "$r" "a sentence of 28 words" "" main

r="$(repo early-end)"
after "$r" docs/adr/0001-x.md "## Decision" "${LONG/ any work / any work. Then it }"
expect "a sentence that ends early: two short ones" "$r" "no long sentence" "" main

r="$(repo modal)"
after "$r" AGENTS.md "## 1. Rules" "- The session should read the glossary."
expect "a soft modal verb in AGENTS.md: listed with line and word" "$r" \
  'AGENTS.md:5: the soft modal verb "should"' "" main
expect "a soft modal verb on a line not added: not listed" "$r" "" "AGENTS.md:8" main

r="$(repo italics)"
after "$r" AGENTS.md "## 1. Rules" "- **Plain.** Say *must*; *should* leaves the reader guessing."
expect "a soft modal verb named in italics: not listed" "$r" "no long sentence" "" main

r="$(repo wrapped-italics)"
after "$r" AGENTS.md "## 1. Rules" "$(printf -- '- **Cache.** A session writes the cache with *write\n  mode*, and it should flush before the *next* run.')"
expect "an italic wrapped over two lines: a real verb after it is listed" "$r" \
  'AGENTS.md:6: the soft modal verb "should"' "" main

r="$(repo quote)"
after "$r" AGENTS.md "## 1. Rules" "> A quote that should not count."
expect "a soft modal verb in a block quote: not listed" "$r" "no long sentence" "" main

r="$(repo fence)"
# shellcheck disable=SC2016 # the backticks are a Markdown fence
after "$r" docs/adr/0001-x.md "## Decision" "$(printf '```sh\n# this could run\n```')"
expect "a soft modal verb in fenced code: not listed" "$r" "no long sentence" "" main

r="$(repo outside)"
printf '%s should\n' "$LONG" > "$r/README.md"
git_in "$r" add README.md
git_in "$r" commit -q -m readme
expect "a change outside the rules: nothing to report" "$r" "no long sentence" "" main

r="$(repo untracked)"
printf '# ADR-0002: Y\n\n## Decision\n\nWe might do it.\n' > "$r/docs/adr/0002-y.md"
expect "the working tree: an untracked ADR is read" "$r" \
  'docs/adr/0002-y.md:5: the soft modal verb "might"' ""

r="$(repo bad-base)"
out="$(bash "$SENSOR" --root "$r" no-such-ref 2>&1)"; rc=$?
check "a base that does not resolve: exit 2" test "$rc" -eq 2 -a "${out/does not resolve/}" != "$out"

summary "Plain rules sensor self-test"
