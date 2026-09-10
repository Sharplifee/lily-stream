-- Lily Stream v1 schema.
-- broadcasts: who is live right now. invites: who is allowed in.

create table if not exists broadcasts (
  room_id     text primary key,
  title       text not null,
  host        text not null,
  is_live     boolean not null default false,
  viewers     integer not null default 0,
  started_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists broadcasts_live_idx on broadcasts (is_live) where is_live;

create table if not exists invites (
  token       text primary key,
  label       text,
  created_at  timestamptz not null default now(),
  redeemed_by text,
  redeemed_at timestamptz
);

alter table broadcasts enable row level security;
alter table invites   enable row level security;

-- v1 is a closed circle distributed by TestFlight, so anon may read and write
-- presence. Tighten to invite-token checks before any wider distribution.
create policy broadcasts_read  on broadcasts for select using (true);
create policy broadcasts_write on broadcasts for insert with check (true);
create policy broadcasts_update on broadcasts for update using (true);
create policy invites_read on invites for select using (true);
