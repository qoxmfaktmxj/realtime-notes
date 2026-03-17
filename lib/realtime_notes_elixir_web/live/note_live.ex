defmodule RealtimeNotesElixirWeb.NoteLive do
  use RealtimeNotesElixirWeb, :live_view

  alias RealtimeNotesElixir.Notes
  alias RealtimeNotesElixirWeb.Presence

  @presence_topic "notes:presence"

  @impl true
  def mount(_params, _session, socket) do
    note = Notes.get_note()

    socket =
      socket
      |> assign(
        page_title: "Realtime Notes",
        viewer_id: viewer_id(),
        user_count: presence_count()
      )
      |> assign_note(note)

    if connected?(socket) do
      Notes.subscribe()
      Phoenix.PubSub.subscribe(RealtimeNotesElixir.PubSub, @presence_topic)
      track_presence(socket)

      {:ok, assign(socket, :user_count, presence_count())}
    else
      {:ok, socket}
    end
  end

  @impl true
  def handle_event("update_note", %{"note" => %{"content" => content}}, socket) do
    note = Notes.update_note(content)
    {:noreply, assign_note(socket, note)}
  end

  @impl true
  def handle_info({:note_updated, note}, socket) do
    {:noreply, assign_note(socket, note)}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{topic: @presence_topic, event: "presence_diff"},
        socket
      ) do
    {:noreply, assign(socket, :user_count, presence_count())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="page-shell">
        <div class="pointer-events-none absolute inset-x-0 top-0 flex justify-center">
          <div class="h-72 w-[44rem] rounded-full bg-white/80 blur-3xl sm:h-80" />
        </div>

        <section class="note-stage relative mx-auto flex min-h-screen w-full max-w-6xl flex-col px-4 py-6 sm:px-6 lg:px-8">
          <header class="mx-auto flex w-full max-w-4xl items-center justify-between gap-4 rounded-full border border-white/80 bg-white/85 px-4 py-3 shadow-[0_10px_35px_rgba(15,23,42,0.08)] backdrop-blur transition duration-200 hover:-translate-y-0.5 hover:shadow-[0_16px_45px_rgba(15,23,42,0.11)]">
            <div class="min-w-0">
              <p class="text-[0.7rem] font-semibold uppercase tracking-[0.32em] text-slate-400">
                Phoenix LiveView
              </p>
              <div class="mt-1 flex items-center gap-3">
                <h1 class="font-serif text-xl text-slate-900 sm:text-2xl">Realtime Notes</h1>
                <span class="hidden h-1.5 w-1.5 rounded-full bg-slate-300 sm:block" />
                <p class="hidden text-sm text-slate-500 sm:block">
                  Shared editing without sign-in
                </p>
              </div>
            </div>

            <div class="flex shrink-0 items-center gap-2 rounded-full border border-emerald-100 bg-emerald-50/90 px-3 py-2 text-sm font-medium text-emerald-700 shadow-sm">
              <span class="inline-flex h-2.5 w-2.5 rounded-full bg-emerald-500 shadow-[0_0_0_4px_rgba(16,185,129,0.16)] animate-pulse" />
              {collaborator_label(@user_count)}
            </div>
          </header>

          <div class="mx-auto flex w-full max-w-4xl flex-1 items-center py-8 sm:py-10 lg:py-12">
            <div class="w-full overflow-hidden rounded-[2rem] border border-white/80 bg-white/90 shadow-[0_30px_90px_rgba(148,163,184,0.20)] backdrop-blur">
              <div class="border-b border-slate-200/80 px-5 py-5 sm:px-8">
                <div class="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
                  <div class="space-y-2">
                    <span class="inline-flex items-center rounded-full bg-slate-100 px-3 py-1 text-xs font-semibold uppercase tracking-[0.24em] text-slate-500">
                      Shared Canvas
                    </span>
                    <div>
                      <h2 class="text-2xl font-semibold tracking-tight text-slate-900 sm:text-3xl">
                        Write together in real time.
                      </h2>
                      <p class="mt-2 max-w-2xl text-sm leading-6 text-slate-500 sm:text-base">
                        Every connected browser sees the same note instantly. This demo keeps state in memory and syncs updates through Phoenix PubSub.
                      </p>
                    </div>
                  </div>

                  <div class="grid grid-cols-2 gap-3 text-left sm:min-w-[15rem] sm:text-right">
                    <div class="rounded-2xl border border-slate-200/80 bg-slate-50/90 px-4 py-3">
                      <p class="text-[0.68rem] font-semibold uppercase tracking-[0.24em] text-slate-400">
                        Last Sync
                      </p>
                      <p class="mt-1 text-sm font-semibold text-slate-700">
                        {format_updated_at(@last_updated)}
                      </p>
                    </div>
                    <div class="rounded-2xl border border-slate-200/80 bg-slate-50/90 px-4 py-3">
                      <p class="text-[0.68rem] font-semibold uppercase tracking-[0.24em] text-slate-400">
                        Characters
                      </p>
                      <p class="mt-1 text-sm font-semibold text-slate-700">{@character_count}</p>
                    </div>
                  </div>
                </div>
              </div>

              <div class="px-5 py-5 sm:px-8 sm:py-8">
                <.form for={@form} id="shared-note-form" phx-change="update_note">
                  <div class="relative">
                    <.input
                      field={@form[:content]}
                      type="textarea"
                      rows="18"
                      phx-debounce="120"
                      autocomplete="off"
                      class="editor-textarea min-h-[420px] w-full rounded-[1.5rem] border border-slate-200/80 bg-slate-50/75 px-5 py-5 text-base leading-8 text-slate-700 outline-none transition duration-200 placeholder:text-slate-300 focus:border-slate-300 focus:bg-white focus:shadow-[0_0_0_6px_rgba(226,232,240,0.55)] sm:min-h-[520px] sm:px-6 sm:py-6 sm:text-[1.03rem]"
                    />

                    <div class="pointer-events-none absolute inset-x-4 bottom-4 hidden items-center justify-between text-xs text-slate-400 sm:flex">
                      <span>Open another tab or browser window to watch the note sync live.</span>
                      <span>{@line_count} lines</span>
                    </div>
                  </div>
                </.form>
              </div>

              <div class="flex flex-col gap-3 border-t border-slate-200/80 px-5 py-4 text-sm text-slate-500 sm:flex-row sm:items-center sm:justify-between sm:px-8">
                <p>
                  Built with Phoenix LiveView, Presence, PubSub, and an in-memory GenServer store.
                </p>
                <div class="flex items-center gap-2">
                  <span class="h-1.5 w-1.5 rounded-full bg-slate-300" />
                  <span>Responsive on desktop and mobile</span>
                </div>
              </div>
            </div>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end

  defp assign_note(socket, note) do
    assign(socket,
      content: note.content,
      last_updated: note.updated_at,
      character_count: String.length(note.content),
      line_count: line_count(note.content),
      form: to_form(%{"content" => note.content}, as: :note)
    )
  end

  defp track_presence(socket) do
    case Presence.track(self(), @presence_topic, socket.assigns.viewer_id, %{
           joined_at: System.system_time(:second)
         }) do
      {:ok, _meta} -> :ok
      {:error, {:already_tracked, _, _}} -> :ok
      {:error, _reason} -> :ok
    end
  end

  defp presence_count do
    @presence_topic
    |> Presence.list()
    |> map_size()
  end

  defp viewer_id do
    "viewer-" <> Base.url_encode64(:crypto.strong_rand_bytes(8), padding: false)
  end

  defp line_count(""), do: 1

  defp line_count(content) do
    content
    |> String.split("\n", trim: false)
    |> length()
  end

  defp format_updated_at(updated_at) do
    Calendar.strftime(updated_at, "%H:%M:%S UTC")
  end

  defp collaborator_label(1), do: "1 collaborator online"
  defp collaborator_label(count), do: "#{count} collaborators online"
end
