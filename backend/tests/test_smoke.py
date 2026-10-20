from main import render


def test_render_lists_each_book_with_its_year():
    rows = [
        {"title": "Dune", "author": "Frank Herbert", "year": "2024"},
        {"title": "Emma", "author": "Jane Austen", "year": ""},
    ]
    assert render(rows) == (
        "# Reading list\n\n- **Dune** by Frank Herbert (2024)\n- **Emma** by Jane Austen\n"
    )
