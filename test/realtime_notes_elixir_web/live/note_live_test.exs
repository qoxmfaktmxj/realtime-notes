defmodule RealtimeNotesElixirWeb.NoteLiveTest do
  use RealtimeNotesElixirWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  alias RealtimeNotesElixir.Notes

  setup do
    Notes.update_note(Notes.default_content())
    :ok
  end

  test "renders the collaborative editor", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#shared-note-form")
    assert has_element?(view, "#note_content")
    assert element(view, "#note_content") |> render() =~ "Realtime Notes"
  end

  test "syncs changes across connected clients", %{conn: conn} do
    {:ok, author_view, _html} = live(conn, ~p"/")
    {:ok, reader_view, _html} = live(conn, ~p"/")

    author_view
    |> form("#shared-note-form", note: %{content: "Synced from LiveView"})
    |> render_change()

    assert has_element?(reader_view, "#note_content")
    assert element(reader_view, "#note_content") |> render() =~ "Synced from LiveView"
    assert Notes.get_note().content == "Synced from LiveView"
  end
end
