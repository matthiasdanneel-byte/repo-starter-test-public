<!-- Written by repo-starter. -->
# Contributing

`main` only changes through a pull request with green checks. In a Claude Code session, Claude
runs these steps for you; this page is the same flow written down.

**branch → small commits → pull request → green `checks` → review → squash merge**

## Steps

1. **Branch from the latest `main`:**
   ```bash
   git fetch origin
   git switch -c <type>/<short-topic> origin/main
   ```
   `<type>` is `feat`, `fix`, `chore`, `docs`, `refactor` or `test`, e.g. `feat/export-to-csv`.
   Don't use `git pull` on `main`: after a squash merge it can't fast-forward.
2. **Commit small and often**, in [Conventional Commits](https://www.conventionalcommits.org):
   `feat: add CSV export`, `fix: keep empty rows out of the total`.
3. **Run the checks** before you push: `cd backend && uv run ruff format --check . && uv run ruff check . && uv run pytest`
4. **Push and open the pull request:**
   ```bash
   git push -u origin HEAD
   gh pr create --fill
   ```
   Fill in the template: what and why, how it was checked (real numbers), the review.
5. **Wait for CI.** The `checks` job is required. `staged` and `secret-scan` are not required,
   but read them.
6. **Review.** A pull request needs one approval from someone other than its author. A
   repository admin merging their own work ticks **"Merge without waiting for requirements to
   be met (bypass rules)"**; the checks still have to be green.
7. **Squash merge** in GitHub. The branch is deleted automatically. Start the next change at
   step 1.

## Rules on `main`

- **`main-ci`:** pull request required, `checks` must pass, squash only, no force-push, no
  deletion. Nobody can bypass it, admins included.
- **`main-review`:** one approving review; repository admins may bypass it.

## Also

- Dependency updates arrive as one grouped Dependabot PR per ecosystem per month.
- Report bugs and plan work as GitHub Issues (templates: Work item, Bug).
- Never commit a secret: see `SECURITY.md`.
