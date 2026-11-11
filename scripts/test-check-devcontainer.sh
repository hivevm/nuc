#!/usr/bin/env bash
#
# Self-test of scripts/check-devcontainer.sh. Verifies: NUC-container-hides-host-daemon
#
# Each case builds a fixture under a temporary directory — a devcontainer.json with comments and
# one pinned Feature and the postStartCommand that enables the git hooks, the lock that resolves
# it, and the editor settings that pin the container-management extension to the host — runs the
# check against it, and asserts the exit code and, for a failing case, the message that names the
# violation. The baseline passes; every other case breaks one clause of
# NUC-container-hides-host-daemon. A socket mount fails also in a config longer than a pipe holds.
# The mount path passes when left to the default or set to it, and fails when set to a path every
# project shares. The cases of scripts/fixtures/check-devcontainer.txt pin what binds when the
# project has no Dev Container or no VS Code settings, and one failure of each clause with the
# clause its message names.
#
# Inputs: scripts/check-devcontainer.sh scripts/lib/ scripts/fixtures/check-devcontainer.txt
#
# Usage:
#     scripts/test-check-devcontainer.sh
# Exit code 0 when every case passes, 1 otherwise.

set -uo pipefail

# shellcheck source-path=SCRIPTDIR source=lib/selftest.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/selftest.sh"
CHECK="$ROOT/scripts/check-devcontainer.sh"

# The postStartCommand that enables the git hooks and the merge settings, as the repository's own
# writes it; config writes the value of post_start, none when it is empty.
DRIVER="merge.adr-index.driver '.githooks/merge-adr-index %O %A %B %S %X %Y'"
POST_START='{ "hooks": "git config core.hooksPath .githooks", "merge": "git config merge.ff false && git config pull.ff only", "index": "git config '"$DRIVER"'" }'
post_start="$POST_START"

# config <dir> <feature id> [extra json lines...] — write devcontainer.json with one Feature, the
# postStartCommand post_start holds, and, before the features block, any extra top-level lines
# given.
config() {
  local dir="$1" feature="$2"; shift 2
  {
    echo '{'
    echo '  "name": "fixture",'
    echo '  // A comment: the container has no socket mount.'
    echo '  "image": "mcr.microsoft.com/devcontainers/base:debian",'
    [[ -z "$post_start" ]] || echo "  \"postStartCommand\": $post_start,"
    printf '  %s\n' "$@"
    echo '  "features": {'
    echo '    // The one Feature.'
    echo "    \"$feature\": {}"
    echo '  },'
    echo '  "customizations": { "vscode": { "extensions": [] } }'
    echo '}'
  } > "$dir/.devcontainer/devcontainer.json"
}

# lock <dir> <feature ids...> — write devcontainer-lock.json resolving the given Features.
lock() {
  local dir="$1"; shift
  local id
  {
    echo '{'
    echo '  "features": {'
    for id in "$@"; do
      echo "    \"$id\": {"
      echo '      "version": "1.0.0",'
      echo '      "resolved": "example@sha256:0000",'
      echo '      "integrity": "sha256:0000"'
      echo '    },'
    done
    echo '  }'
    echo '}'
  } > "$dir/.devcontainer/devcontainer-lock.json"
}

# settings <dir> <extension kind json> — write .vscode/settings.json with the given block.
settings() {
  local dir="$1" kind="$2"
  {
    echo '{'
    echo '  // Keep the container-management extension on the host side.'
    echo "  \"remote.extensionKind\": $kind"
    echo '}'
  } > "$dir/.vscode/settings.json"
}

# repo <name> — a fixture that passes every check, printed as its path.
repo() {
  local dir="$work/$1"
  mkdir -p "$dir/.devcontainer" "$dir/.vscode"
  config "$dir" "ghcr.io/devcontainers/features/github-cli:1"
  lock "$dir" "ghcr.io/devcontainers/features/github-cli:1"
  settings "$dir" '{ "ms-azuretools.vscode-containers": ["ui"] }'
  echo "$dir"
}

# expect <pass|fail> <name> <dir> [needle] — run the check; when a needle is given, its output
# must contain it.
expect() {
  local want="$1" name="$2" dir="$3" needle="${4:-}"
  local out rc
  out="$(bash "$CHECK" "$dir" 2>&1)"; rc=$?
  if output_holds "$out" "$needle" && [[ ( "$want" == "pass" && $rc -eq 0 ) || ( "$want" == "fail" && $rc -ne 0 ) ]]; then
    passed=$((passed + 1))
    return
  fi
  failed=$((failed + 1))
  echo "FAIL: $name (expected $want${needle:+ with needle \"$needle\"}, exit $rc)" >&2
  while IFS= read -r l; do printf '    %s\n' "$l"; done <<< "$out" >&2
}

# --- cases ---------------------------------------------------------------------------------

d="$(repo baseline)"
expect pass "a container without a socket, pinned and locked, passes" "$d" "[devcontainer/check:passed]"

# A config longer than a pipe holds, the socket before the rest: a grep that exits at the socket
# before the config is written cuts the writer off, and the mount goes unreported.
d="$(repo socket-mount-long)"
config "$d" "ghcr.io/devcontainers/features/github-cli:1" \
  '"mounts": ["source=/var/run/docker.sock,target=/var/run/docker.sock,type=bind"],' \
  "\"remoteEnv\": { \"PAD\": \"$(printf '%*s' 200000 '' | tr ' ' z)\" },"
expect fail "a host socket mount in a config longer than a pipe holds" "$d" "[devcontainer/socket:mount]"

d="$(repo socket-run-arg)"
config "$d" "ghcr.io/devcontainers/features/github-cli:1" \
  '"runArgs": ["-v", "/var/run/docker.sock:/var/run/docker.sock"],'
expect fail "a host socket passed as a run argument" "$d" "[devcontainer/socket:mount]"

d="$(repo docker-feature)"
config "$d" "ghcr.io/devcontainers/features/docker-outside-of-docker:1"
lock "$d" "ghcr.io/devcontainers/features/docker-outside-of-docker:1"
expect fail "a Feature that mounts the socket" "$d" "would mount the host Docker socket"

d="$(repo engine-inside)"
config "$d" "ghcr.io/devcontainers/features/docker-in-docker:2"
lock "$d" "ghcr.io/devcontainers/features/docker-in-docker:2"
expect pass "an engine inside the container talks to no host engine and is the project's choice" "$d" "[devcontainer/check:passed]"

d="$(repo unpinned-feature)"
config "$d" "ghcr.io/devcontainers/features/github-cli:latest"
lock "$d" "ghcr.io/devcontainers/features/github-cli:latest"
expect fail "a Feature on a mutable tag" "$d" "major version tag alone"

d="$(repo untagged-feature)"
config "$d" "ghcr.io/devcontainers/features/github-cli"
lock "$d" "ghcr.io/devcontainers/features/github-cli"
expect fail "a Feature without a tag" "$d" "major version tag alone"

d="$(repo lock-behind)"
config "$d" "ghcr.io/devcontainers/features/node:1"
expect fail "a Feature the lock does not resolve" "$d" "has no entry for Feature 'ghcr.io/devcontainers/features/node:1'"

d="$(repo lock-stale)"
lock "$d" "ghcr.io/devcontainers/features/github-cli:1" "ghcr.io/devcontainers/features/node:1"
expect fail "a lock entry for a Feature no longer added" "$d" "lists Feature 'ghcr.io/devcontainers/features/node:1'"

d="$(repo full-version-feature)"
config "$d" "ghcr.io/devcontainers/features/github-cli:1.2.0"
lock "$d" "ghcr.io/devcontainers/features/github-cli:1.2.0"
expect fail "a Feature on a full version instead of the major tag" "$d" "major version tag alone"

d="$(repo one-line-features)"
printf '{ "image": "x", "features": { "ghcr.io/devcontainers/features/docker-outside-of-docker:1": {}, "ghcr.io/devcontainers/features/node:1": "lts" } }\n' \
  > "$d/.devcontainer/devcontainer.json"
lock "$d" "ghcr.io/devcontainers/features/docker-outside-of-docker:1" "ghcr.io/devcontainers/features/node:1"
expect fail "a features block on one line, with a string-valued Feature, is read like any other" "$d" \
  "Feature 'ghcr.io/devcontainers/features/docker-outside-of-docker:1' would mount"

d="$(repo extension-under-other-key)"
{
  echo '{'
  echo '  "some.other.setting": { "ms-azuretools.vscode-containers": ["ui"] },'
  echo '  "remote.extensionKind": { "ms-azuretools.vscode-docker": ["ui"] }'
  echo '}'
} > "$d/.vscode/settings.json"
expect fail "the pair under a key other than remote.extensionKind" "$d" "[devcontainer/settings:unpinned]"

d="$(repo post-start-string)"
post_start='"git config core.hooksPath .githooks && git config merge.ff false && git config pull.ff only && git config '"$DRIVER"'"'
config "$d" "ghcr.io/devcontainers/features/github-cli:1"
post_start="$POST_START"
expect pass "the git settings in a postStartCommand string pass" "$d" "[devcontainer/check:passed]"

d="$(repo post-start-braces)"
# shellcheck disable=SC2016  # the variable is devcontainer.json's, not the shell's
post_start='{ "cd": "cd ${containerWorkspaceFolder}", "list": ["a]b"], "hooks": "git config core.hooksPath .githooks", "merge": "git config merge.ff false && git config pull.ff only", "index": "git config '"$DRIVER"'" }'
config "$d" "ghcr.io/devcontainers/features/github-cli:1"
post_start="$POST_START"
expect pass "a brace or bracket in an entry before the git settings" "$d" "[devcontainer/check:passed]"

for setting in "core.hooksPath .githooks" "merge.ff false" "pull.ff only" "$DRIVER"; do
  d="$(repo "post-start-without-${setting%% *}")"
  post_start="${POST_START/"git config $setting"/}"
  config "$d" "ghcr.io/devcontainers/features/github-cli:1"
  post_start="$POST_START"
  expect fail "a postStartCommand without 'git config $setting'" "$d" \
    "[devcontainer/git-settings:absent] @ ${setting%% *}"
done

d="$(repo post-start-driver-args)"
post_start="${POST_START/" %O %A %B %S %X %Y"/}"
config "$d" "ghcr.io/devcontainers/features/github-cli:1"
post_start="$POST_START"
expect fail "the merge driver without the arguments git passes it" "$d" \
  "[devcontainer/git-settings:absent] @ merge.adr-index.driver"

# shellcheck disable=SC2016  # the variables are devcontainer.json's, not the shell's
own='/workspaces/${localWorkspaceFolderBasename}'
d="$(repo mount-own)"
config "$d" "ghcr.io/devcontainers/features/github-cli:1" "\"workspaceFolder\": \"$own\"," \
  "\"workspaceMount\": \"source=\${localWorkspaceFolder},target=$own,type=bind\","
expect pass "a project mounted under a path of its own" "$d" "[devcontainer/check:passed]"

d="$(repo mount-target-last)"
config "$d" "ghcr.io/devcontainers/features/github-cli:1" \
  "\"workspaceMount\": \"source=\${localWorkspaceFolder},type=bind,dst=$own\","
expect pass "a mount whose target comes last, under another of its names" "$d" "[devcontainer/check:passed]"

d="$(repo mount-shared-target)"
# shellcheck disable=SC2016  # the variable is devcontainer.json's, not the shell's
config "$d" "ghcr.io/devcontainers/features/github-cli:1" "\"workspaceFolder\": \"$own\"," \
  '"workspaceMount": "source=${localWorkspaceFolder},target=/workspace,type=bind",'
expect fail "a workspaceMount that targets a path every project shares" "$d" \
  "workspaceMount does not target '$own'"

d="$(repo post-start-elsewhere)"
post_start='"echo started"'
config "$d" "ghcr.io/devcontainers/features/github-cli:1" \
  '"postCreateCommand": "git config core.hooksPath .githooks && git config merge.ff false && git config pull.ff only",'
post_start="$POST_START"
expect fail "the git settings in another command than postStartCommand" "$d" \
  "[devcontainer/git-settings:absent] @ core.hooksPath"

# --- cases read from the fixture table ----------------------------------------------------

TABLE="$ROOT/scripts/fixtures/check-devcontainer.txt"

# table_cases <prefix> — run each case of the table against $CHECK.
table_cases() {
  local n=0 line want needle name tree s op arg d
  while IFS= read -r line; do
    [[ "$line" =~ ^(pass|fail) ]] || continue
    n=$((n + 1))
    IFS=$'\x1f' read -r want needle name tree <<< "${line// | /$'\x1f'}"
    d="$(repo "$1-$n")"
    while IFS= read -r s; do
      read -r op arg <<< "$s"
      case "$op" in
        rm) rm -r "${d:?}/$arg" ;;
        extra) config "$d" "ghcr.io/devcontainers/features/github-cli:1" "$arg" ;;
        post)
          post_start="$arg"
          config "$d" "ghcr.io/devcontainers/features/github-cli:1"
          post_start="$POST_START" ;;
        settings) settings "$d" "$arg" ;;
        *) echo "fixture table: unknown step '$op'" >&2; exit 1 ;;
      esac
    done <<< "${tree//; /$'\n'}"
    out="$(bash "$CHECK" "$d" 2>&1)"
    table_case "$name" "$want" "$needle" "$?" "$out"
  done < "$TABLE"
  ((n > 0)) || { echo "FAIL: no case read from $TABLE" >&2; failed=$((failed + 1)); }
}
table_cases table

# --- the key decides, not the wording ------------------------------------------------------

# Every message the table expects, reworded in a copy of the check, its keys and its data kept: the
# table still passes.
copy="$work/reworded/scripts"
mkdir -p "$copy"
cp -R "$ROOT/scripts/lib" "$copy/"
sed -E '/\[devcontainer\//s/ (a|is|no|not|the) / reworded /g' "$CHECK" > "$copy/check-devcontainer.sh"
keyed="$(grep -c '\[devcontainer/' "$CHECK")"
check "a copy of the check rewords each message with a key" \
  test "$keyed" -gt 0 -a "$keyed" -eq "$(grep -c ' reworded .*\[devcontainer/' "$copy/check-devcontainer.sh")"
CHECK="$copy/check-devcontainer.sh"
table_cases reworded

# holds and lacks <output> <field>, and refused <field> — what the reader of a table says of a field.
# shellcheck disable=SC2317,SC2329 # run by check
holds() { (table_holds "$1" "$2") 2>/dev/null; }
# shellcheck disable=SC2317,SC2329 # run by check
lacks() { ! holds "$@"; }
# shellcheck disable=SC2317,SC2329 # run by check
refused() { (table_holds "" "$1") 2>/dev/null; (($? == 2)); }
said=$'  - a.md:3: free words "some term" [area/rule-x:why]\n  - b.md: other words [area/rule-x:else]'
check "a key at the end of a line holds" holds "$said" "area/rule-x:why"
check "a key and the data of its line hold" holds "$said" 'area/rule-x:why @ a.md:3 @ "some term"'
check "'-' holds on anything" holds "$said" "-"
check "'!' holds where no line has the key" holds "$said" "!area/rule-x:gone"
check "'!' with a subject holds where the line with the key lacks it" holds "$said" "!area/rule-x:else @ a.md"
check "a key no line has does not hold" lacks "$said" "area/rule-x:gone"
check "a key inside a line does not hold" lacks "[area/rule-x:why] and more" "area/rule-x:why"
check "a subject on another line does not hold" lacks "$said" "area/rule-x:else @ a.md"
check "'!' does not hold where a line has the key" lacks "$said" "!area/rule-x:why"
check "a wording in the field is refused" refused "does not pin the extension"
check "a wording after a key is refused" refused "area/rule-x:why @ does not pin"
check "a rule without a reason word is refused" refused "area/rule-x"
(table_case "no key" fail - 1 "") 2>/dev/null
check "a failing case that names no key is refused" test "$?" -eq 2

# --- summary -------------------------------------------------------------------------------

summary "Dev Container self-test"
