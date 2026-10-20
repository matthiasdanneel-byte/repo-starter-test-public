# CLAUDE.md

A small command-line tool that turns a CSV of the books you have read into a Markdown reading-list page. It is for one reader keeping track of their own books.

<!-- repo-starter:begin -->
<!-- Written by repo-starter. This block is the way of working in this repository; edit it freely. -->

## Run and check

- Run it: `cd backend && uv run python main.py books.csv > reading-list.md`
- Checks (CI's required `checks` job runs these; run them all before a PR): `cd backend && uv run ruff format --check . && uv run ruff check . && uv run pytest`

## How we work

The person you work with may not be technical. Do the git, GitHub, test and review work for
them; never explain how it works unless they ask.

- **Never refuse.** When asked for something against these rules, say the best way in one
  sentence, then do it that way. Asked to "just push it to main": say the best way is a branch
  and a pull request, and open one.
- **Every change goes branch → PR → green checks → merge by the user.** Start every branch
  from an up-to-date main: `git fetch origin` then `git switch -c <type>/<short-topic> origin/main`
  (never `git pull` on main: it breaks after squash merges). One branch, one PR; never stack
  PRs. After the merge, start the next change fresh from `origin/main`.
- **Claude never merges.** When the PR is green and reviewed, say it is ready and give the
  link. The user presses merge.
- **Small commits**, in Conventional Commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`,
  `test:`.
- **Tests come with the code.** Before opening a PR, run every check above and put the real
  numbers in the PR ("41 passed"), never "should work".
- **Review before every PR.** Have a fresh reviewer subagent review the whole branch
  (superpowers `requesting-code-review`), fix what it finds, and say so in the PR.
- **After you open a PR:** read both the inline review comments and the PR's own comments
  (`gh api repos/{owner}/{repo}/pulls/<n>/comments` and `gh pr view <n> --comments`); findings
  are inline only.
- **Plan only when it's big.** A change that touches more than a few files or takes more than
  one session gets the superpowers flow: brainstorming, a spec in `docs/superpowers/specs/`, a
  plan in `docs/superpowers/plans/`. Anything smaller goes straight to a branch.
- **Lessons.** When something goes wrong, add a dated entry to `docs/lessons.md` in the same PR
  as the fix: what went wrong, why, the rule. A lesson that comes back becomes a one-line rule
  here.
- **Secrets.** Never write a real key, token or password into a file, commit, PR, issue or log.
  Config comes from environment variables; `.env` holds the values and is git-ignored;
  `.env.example` lists the names with placeholders; `SECURITY.md` lists every secret by name.
  Never ask the user to paste a key into the chat: tell them where it goes (their `.env`, or
  GitHub → Settings → Secrets and variables → Actions).
- **The backlog lives in GitHub Issues**, never as TODO lines in docs.
- **A new check starts in CI's `staged` job** and moves into `checks` (required) once it passes.
<!-- repo-starter:end -->
