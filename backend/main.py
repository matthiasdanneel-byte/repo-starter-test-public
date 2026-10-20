"""Turn a CSV of books you have read into a Markdown reading-list page."""

import csv
import sys
from collections.abc import Iterable


def render(rows: Iterable[dict[str, str]]) -> str:
    """Return a Markdown list, one line per book: title, author, and the year read."""
    lines = ["# Reading list", ""]
    for row in rows:
        line = f"- **{row['title'].strip()}** by {row['author'].strip()}"
        if row.get("year", "").strip():
            line += f" ({row['year'].strip()})"
        lines.append(line)
    return "\n".join(lines) + "\n"


def main() -> None:
    with open(sys.argv[1], newline="", encoding="utf-8") as f:
        sys.stdout.write(render(csv.DictReader(f)))


if __name__ == "__main__":
    main()
