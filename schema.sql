-- ============================================================
-- NBKRIST Events Hub — Supabase Database Schema
-- ============================================================
-- HOW TO RUN:
-- 1. Go to https://supabase.com/dashboard
-- 2. Open your project → SQL Editor
-- 3. Paste this ENTIRE file and click "Run"
-- 4. You should see "Success. No rows returned" — that means it worked!
-- ============================================================

-- ── PROFILES TABLE (student accounts) ──
create table if not exists public.profiles (
  id                uuid primary key,
  name              text not null,
  roll_number       text not null,
  email             text,
  branch            text not null,
  year              text not null,
  profile_photo_url text,
  id_card_url       text,
  created_at        timestamptz default now()
);

-- ── EVENTS TABLE ──
create table if not exists public.events (
  id                 uuid default gen_random_uuid() primary key,
  title              text not null,
  description        text,
  date               date not null,
  time               text,
  venue              text not null,
  form_url           text,
  category           text default 'tech',
  branches           text[] default array['ALL'],
  poster_url         text,
  status             text default 'ongoing',
  cert_title         text,
  cert_type          text default 'participation',
  cert_template_url  text,
  has_cert           boolean default false,
  created_by         text,
  created_at         timestamptz default now()
);

-- ── ROW LEVEL SECURITY ──
alter table public.profiles enable row level security;
alter table public.events   enable row level security;

-- Profiles: public read, owner insert/update
drop policy if exists "profiles_read"   on public.profiles;
drop policy if exists "profiles_insert" on public.profiles;
drop policy if exists "profiles_update" on public.profiles;
create policy "profiles_read"   on public.profiles for select using (true);
create policy "profiles_insert" on public.profiles for insert with check (true);
create policy "profiles_update" on public.profiles for update using (true);

-- Events: full public CRUD (manager auth is handled on frontend)
drop policy if exists "events_read"   on public.events;
drop policy if exists "events_insert" on public.events;
drop policy if exists "events_update" on public.events;
drop policy if exists "events_delete" on public.events;
create policy "events_read"   on public.events for select using (true);
create policy "events_insert" on public.events for insert with check (true);
create policy "events_update" on public.events for update using (true);
create policy "events_delete" on public.events for delete using (true);

-- ── STORAGE BUCKETS ──
insert into storage.buckets (id, name, public) values ('profiles',     'profiles',     true) on conflict (id) do nothing;
insert into storage.buckets (id, name, public) values ('id-cards',     'id-cards',     true) on conflict (id) do nothing;
insert into storage.buckets (id, name, public) values ('posters',      'posters',      true) on conflict (id) do nothing;
insert into storage.buckets (id, name, public) values ('certificates', 'certificates', true) on conflict (id) do nothing;

-- Storage: public read + anyone can upload
drop policy if exists "profiles_select"     on storage.objects;
drop policy if exists "profiles_insert"     on storage.objects;
drop policy if exists "idcards_select"      on storage.objects;
drop policy if exists "idcards_insert"      on storage.objects;
drop policy if exists "posters_select"      on storage.objects;
drop policy if exists "posters_insert"      on storage.objects;
drop policy if exists "certificates_select" on storage.objects;
drop policy if exists "certificates_insert" on storage.objects;

create policy "profiles_select"     on storage.objects for select using (bucket_id = 'profiles');
create policy "profiles_insert"     on storage.objects for insert with check (bucket_id = 'profiles');
create policy "idcards_select"      on storage.objects for select using (bucket_id = 'id-cards');
create policy "idcards_insert"      on storage.objects for insert with check (bucket_id = 'id-cards');
create policy "posters_select"      on storage.objects for select using (bucket_id = 'posters');
create policy "posters_insert"      on storage.objects for insert with check (bucket_id = 'posters');
create policy "certificates_select" on storage.objects for select using (bucket_id = 'certificates');
create policy "certificates_insert" on storage.objects for insert with check (bucket_id = 'certificates');

-- ============================================================
-- DONE! Now go back to your website and test it.
-- ============================================================
