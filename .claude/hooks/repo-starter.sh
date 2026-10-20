#!/usr/bin/env bash
# Written by repo-starter. Claude Code hooks for this repository, wired in .claude/settings.json.
# Every hook warns and never blocks: it exits 0 on every path, prints nothing when there is
# nothing to say, and stays silent under GitHub Actions. Runs in Git Bash on Windows and needs
# only git, grep, awk, sed and tr (no Python, no jq).
#   git-freshness      SessionStart: is the default branch, or this branch, behind the remote?
#   superpowers-check  SessionStart: is the superpowers plugin installed on this machine?
#   secret-warning     PreToolUse on git commit / git push: does the change look like it holds a key?

# emit <event> <message>: the same line for the user (systemMessage) and the model (additionalContext).
emit() {
  local m
  m=$(printf '%s' "$2" | tr -d '"\\' | tr '\n' ' ')
  printf '{"systemMessage":"%s","hookSpecificOutput":{"hookEventName":"%s","additionalContext":"%s"}}\n' "$m" "$1" "$m"
}

# The remote's default branch as origin/<name>, or nothing.
default_ref() {
  local d b
  d=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
  if [ -z "$d" ]; then
    for b in main master; do
      if git rev-parse --verify --quiet "refs/remotes/origin/$b" >/dev/null; then d="origin/$b"; break; fi
    done
  fi
  printf '%s' "$d"
}

git_freshness() {
  local def name msg n branch up k
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
  GIT_TERMINAL_PROMPT=0 GCM_INTERACTIVE=never git fetch --quiet 2>/dev/null || return 0
  def=$(default_ref); name=${def#origin/}; msg=""
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  # The local default branch only matters while it is checked out: new work branches from
  # origin/<default>, so a stale local copy elsewhere is harmless and not worth a warning.
  if [ -n "$def" ] && [ "$branch" = "$name" ]; then
    n=$(git rev-list --count "$name..$def" 2>/dev/null || echo 0)
    if [ "${n:-0}" -gt 0 ]; then
      msg="$name is $n commit(s) behind $def. Start new work from $def (git switch -c <type>/<topic> $def), not from the local $name."
    fi
  fi
  if [ -n "$branch" ] && [ "$branch" != "HEAD" ] && [ "$branch" != "$name" ]; then
    if up=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null); then
      k=$(git rev-list --count "HEAD..$up" 2>/dev/null || echo 0)
      if [ "${k:-0}" -gt 0 ]; then msg="${msg:+$msg }Your branch $branch is $k commit(s) behind $up."; fi
    fi
  fi
  [ -n "$msg" ] && emit SessionStart "[git] $msg"
  return 0
}

superpowers_check() {
  grep -qs '"superpowers@' "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/plugins/installed_plugins.json" && return 0
  emit SessionStart "[setup] The superpowers plugin is not installed on this machine, and this repository's way of working uses it. Install it once: Customize > Plugins, search superpowers, Install (or in a terminal: claude plugin install superpowers@claude-plugins-official). It is active from the next session."
}

# Known key shapes, and a quoted value assigned to a name that says it is secret.
PAT='AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|(^|[^A-Za-z0-9_])(sk-ant-[A-Za-z0-9_-]{20,}|sk-(proj-)?[A-Za-z0-9_-]{32,}|gh[pousr]_[A-Za-z0-9]{36,}|github_pat_[A-Za-z0-9_]{40,}|xox[baprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{35})|AccountKey=[A-Za-z0-9+/=]{40,}|[?&]sig=[A-Za-z0-9%]{40,}'
GEN="(password|passwd|secret|api[_-]?key|access[_-]?key|token)[A-Za-z0-9_]*[\"']?[[:space:]]*[:=][[:space:]]*[\"'][^\"' ]{8,}[\"']"

secret_warning() {
  local diffs="" names="" untracked="" base r added hits envs list
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
  case "$input" in *"git commit"*|*"git push"*) ;; *) input="git commit" ;; esac
  case "$input" in *"git commit"*)
    if git rev-parse --verify --quiet HEAD >/dev/null; then r=HEAD; else r=--cached; fi
    diffs=$(git diff "$r" -U0 --no-color --no-ext-diff 2>/dev/null)
    names=$(git diff "$r" --name-only --diff-filter=d 2>/dev/null)
    # New files count only when the same command stages everything (`git add -A && git commit`).
    case "$input" in *"git add -A"*|*"git add --all"*|*"git add ."*)
      untracked=$(git ls-files --others --exclude-standard 2>/dev/null) ;;
    esac ;;
  esac
  case "$input" in *"git push"*)
    base=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null) || base=$(default_ref)
    if [ -n "$base" ]; then
      diffs=$(printf '%s\n%s' "$diffs" "$(git diff "$base...HEAD" -U0 --no-color --no-ext-diff 2>/dev/null)")
      names=$(printf '%s\n%s' "$names" "$(git diff "$base...HEAD" --name-only --diff-filter=d 2>/dev/null)")
    fi ;;
  esac
  # "<file><TAB><added line>" for every added line, then the files whose added lines match.
  added=$(printf '%s\n' "$diffs" | awk '/^\+\+\+ /{f=substr($0,7); next} /^\+/{print f "\t" substr($0,2)}')
  hits=$( { printf '%s\n' "$added" | grep -E -- "$PAT"; printf '%s\n' "$added" | grep -Ei -- "$GEN"; } | cut -f1)
  if [ -n "$untracked" ]; then  # one grep per pattern over all new files, not one per file
    hits=$(printf '%s\n%s\n%s' "$hits" \
      "$(git ls-files -z --others --exclude-standard | xargs -0 grep -lIE -- "$PAT" 2>/dev/null)" \
      "$(git ls-files -z --others --exclude-standard | xargs -0 grep -lIEi -- "$GEN" 2>/dev/null)")
  fi
  envs=$(printf '%s\n%s\n' "$names" "$untracked" | grep -E '(^|/)\.env($|\.)' | grep -vE '\.(example|sample|template)$')
  list=$(printf '%s\n%s\n' "$hits" "$envs" | sed '/^[[:space:]]*$/d' | sort -u | tr '\n' ',' | sed 's/,$//; s/,/, /g')
  [ -z "$list" ] && return 0
  emit PreToolUse "[secrets] Possible secret in: $list. Before this goes into git: move any real key, token or password into .env (git-ignored) and read it from the environment; record only its name, in the example env file and SECURITY.md. If it is a placeholder or test value, carry on. Never print the value."
}

input=$(cat 2>/dev/null)
[ -n "${GITHUB_ACTIONS:-}" ] && exit 0
case "${1:-}" in
  git-freshness) git_freshness ;;
  superpowers-check) superpowers_check ;;
  secret-warning) secret_warning ;;
esac
exit 0
