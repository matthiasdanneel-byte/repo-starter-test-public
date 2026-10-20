<!-- Written by repo-starter. -->
# Security

**The rule:** no secret value ever appears in this repository: not in a file, a commit, an
issue, a pull request, a workflow log or a chat with Claude. Real values live in the
git-ignored `.env` on your machine, or in GitHub → Settings → Secrets and variables → Actions
for workflows. `.env.example` lists the names with placeholders only.

If a secret was committed or pasted somewhere it shouldn't be, **rotate it** (make a new one and
revoke the old one) at its provider first; removing it from the file doesn't make it safe again.

## Secrets this project uses

Names only. Add a row when the project starts using a new one.

| Name | What it is, and why the project needs it | Where it lives |
|---|---|---|
| | | |

## Reporting a concern

Tell the repository owner directly rather than in an issue or a pull request.
