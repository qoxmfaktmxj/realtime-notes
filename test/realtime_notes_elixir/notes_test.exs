defmodule RealtimeNotesElixir.NotesTest do
  use ExUnit.Case, async: false

  alias RealtimeNotesElixir.Notes

  setup do
    Notes.update_note(Notes.default_content())
    :ok
  end

  test "returns the seeded shared note" do
    note = Notes.get_note()

    assert note.content == Notes.default_content()
    assert %DateTime{} = note.updated_at
  end

  test "updates the note and broadcasts to subscribers" do
    Notes.subscribe()

    updated_note = Notes.update_note("Pairing notes go here")

    assert_receive {:note_updated, ^updated_note}
    assert updated_note.content == "Pairing notes go here"
    assert Notes.get_note() == updated_note
  end
end
