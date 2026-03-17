defmodule RealtimeNotesElixirWeb.Presence do
  @moduledoc """
  Tracks connected editors for the shared note.
  """

  use Phoenix.Presence,
    otp_app: :realtime_notes_elixir,
    pubsub_server: RealtimeNotesElixir.PubSub
end
