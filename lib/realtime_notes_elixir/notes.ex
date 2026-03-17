defmodule RealtimeNotesElixir.Notes do
  @moduledoc """
  In-memory note store for the shared collaborative editor.
  """

  use GenServer

  @topic "notes:shared"
  @default_content """
  Realtime Notes

  This shared canvas is powered by Phoenix LiveView.

  - Open a second browser window to watch edits appear instantly.
  - Capture meeting notes, todos, or ideas without refreshing the page.
  - Connected collaborator count updates in real time.

  Start typing below.
  """

  @type note :: %{content: String.t(), updated_at: DateTime.t()}

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, Keyword.put_new(opts, :name, __MODULE__))
  end

  @spec get_note() :: note()
  def get_note do
    GenServer.call(__MODULE__, :get_note)
  end

  @spec update_note(String.t()) :: note()
  def update_note(content) when is_binary(content) do
    GenServer.call(__MODULE__, {:update_note, content})
  end

  @spec subscribe() :: :ok | {:error, term()}
  def subscribe do
    Phoenix.PubSub.subscribe(RealtimeNotesElixir.PubSub, @topic)
  end

  @spec default_content() :: String.t()
  def default_content, do: @default_content

  @impl true
  def init(_state) do
    {:ok, new_note(@default_content)}
  end

  @impl true
  def handle_call(:get_note, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:update_note, content}, _from, state) do
    next_state =
      if content == state.content do
        state
      else
        new_note(content)
      end

    if next_state != state do
      Phoenix.PubSub.broadcast(RealtimeNotesElixir.PubSub, @topic, {:note_updated, next_state})
    end

    {:reply, next_state, next_state}
  end

  defp new_note(content) do
    %{
      content: content,
      updated_at: DateTime.utc_now() |> DateTime.truncate(:second)
    }
  end
end
