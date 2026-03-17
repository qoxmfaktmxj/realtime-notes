# realtime_notes_elixir

Minimal real-time collaborative notes built with Phoenix LiveView, Presence, and a clean Notion-inspired interface.

![Elixir](https://img.shields.io/badge/Elixir-1.17-4B275F?logo=elixir&logoColor=white)
![Phoenix](https://img.shields.io/badge/Phoenix-1.8.5-FD4F00?logo=phoenixframework&logoColor=white)
![LiveView](https://img.shields.io/badge/LiveView-1.1-7E22CE?logo=phoenixframework&logoColor=white)
![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-4.1-06B6D4?logo=tailwindcss&logoColor=white)
![Bandit](https://img.shields.io/badge/Bandit-1.10-0F172A?logo=elixir&logoColor=white)

## Demo Description

`realtime_notes_elixir` is a shared note surface where every connected visitor edits the same textarea in real time. The page opens into a centered editor card on a soft gray background, with a lightweight header showing the project title and the live collaborator count.

The expected UI feels calm and minimal:

- A floating header with the project title and an online collaborator badge
- A centered editor card with generous spacing, soft borders, and subtle shadows
- A single shared textarea for collaborative editing
- Lightweight note metadata such as last sync time, line count, and character count
- Responsive behavior that keeps the editor comfortable on both desktop and mobile screens

## Screenshots

Replace these placeholders with real captures after deployment or local screenshots.

![Desktop editor placeholder](./docs/screenshots/desktop-editor.png)
![Mobile editor placeholder](./docs/screenshots/mobile-editor.png)

## Tech Stack

- Phoenix 1.8.5
- Phoenix LiveView 1.1
- Phoenix.PubSub
- Phoenix.Presence
- Elixir GenServer for in-memory state
- Tailwind CSS 4
- Bandit web server

## Architecture Overview

The application keeps a single shared note in memory using `RealtimeNotesElixir.Notes`, a small GenServer supervised by the OTP application tree. Every edit is written to that process, which acts as the source of truth for the current note body and the last updated timestamp.

Phoenix LiveView powers the UI and keeps the browser synchronized without a custom frontend SPA. Each connected client mounts the same `NoteLive`, subscribes to the shared PubSub topic, and receives note updates as soon as any user types.

Presence is used to track active browser sessions on a dedicated topic. That allows the header to show a live collaborator count with no authentication and no database. Together, LiveView, PubSub, and Presence provide a compact real-time architecture with very little client-side complexity.

## Key Features

- Single shared collaborative textarea powered by LiveView
- Real-time note synchronization across connected browsers
- Live connected user count using Phoenix Presence
- In-memory note storage with a simple GenServer
- Clean, centered, responsive UI with subtle hover and focus states
- No authentication, database, or unnecessary infrastructure
- Test coverage for note storage and LiveView synchronization behavior

## Why This Project Is Interesting

This project is a strong engineering portfolio piece because it shows how far Phoenix LiveView can go without falling back to heavy client-side state management. It demonstrates server-driven UI updates, real-time broadcasting, connection awareness, and a collaboration workflow using a small amount of code.

It is also interesting because it makes the tradeoffs explicit: the app intentionally uses in-memory storage, which keeps the implementation lean and fast for demos, while making durability and conflict resolution future concerns. That makes it a good foundation for discussing architecture evolution in interviews or portfolio reviews.

## How To Run

### Prerequisites

- Elixir 1.17+
- Erlang/OTP 27+

### Local development

```bash
mix deps.get
mix phx.server
```

Then open [http://localhost:4000](http://localhost:4000).

### Quality checks

```bash
mix test
mix precommit
```

## Future Improvements

- Persist notes in Postgres or Redis while keeping the LiveView collaboration flow
- Add optimistic conflict resolution or operational transform/CRDT style editing
- Support multiple note rooms instead of a single shared document
- Add presence avatars and lightweight typing indicators
- Add deployment configuration and production observability
- Capture and replace the screenshot placeholders with real UI images
