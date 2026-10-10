-- NOVEL HOUSE FINAL DATABASE
-- Run this once in the NEW Supabase project.

create extension if not exists pgcrypto;

create table if not exists public.novels (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text unique not null,
  author text,
  translator text,
  genre text,
  status text not null default 'ongoing' check (status in ('ongoing','completed')),
  synopsis text,
  cover_url text,
  is_adult boolean not null default false,
  views bigint not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.chapters (
  id uuid primary key default gen_random_uuid(),
  novel_id uuid not null references public.novels(id) on delete cascade,
  chapter_number integer not null,
  title text,
  content text not null,
  views bigint not null default 0,
  created_at timestamptz not null default now(),
  unique(novel_id,chapter_number)
);

create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create index if not exists chapters_novel_id_idx on public.chapters(novel_id);
create index if not exists novels_created_at_idx on public.novels(created_at desc);
create index if not exists novels_views_idx on public.novels(views desc);

alter table public.novels enable row level security;
alter table public.chapters enable row level security;
alter table public.admins enable row level security;

drop policy if exists "Public can read novels" on public.novels;
create policy "Public can read novels" on public.novels for select to anon,authenticated using (true);

drop policy if exists "Public can read chapters" on public.chapters;
create policy "Public can read chapters" on public.chapters for select to anon,authenticated using (true);

drop policy if exists "Admins can read admin list" on public.admins;
create policy "Admins can read admin list" on public.admins for select to authenticated using (user_id = auth.uid());

drop policy if exists "Admins insert novels" on public.novels;
create policy "Admins insert novels" on public.novels for insert to authenticated with check (exists(select 1 from public.admins a where a.user_id=auth.uid()));
drop policy if exists "Admins update novels" on public.novels;
create policy "Admins update novels" on public.novels for update to authenticated using (exists(select 1 from public.admins a where a.user_id=auth.uid())) with check (exists(select 1 from public.admins a where a.user_id=auth.uid()));
drop policy if exists "Admins delete novels" on public.novels;
create policy "Admins delete novels" on public.novels for delete to authenticated using (exists(select 1 from public.admins a where a.user_id=auth.uid()));

drop policy if exists "Admins insert chapters" on public.chapters;
create policy "Admins insert chapters" on public.chapters for insert to authenticated with check (exists(select 1 from public.admins a where a.user_id=auth.uid()));
drop policy if exists "Admins update chapters" on public.chapters;
create policy "Admins update chapters" on public.chapters for update to authenticated using (exists(select 1 from public.admins a where a.user_id=auth.uid())) with check (exists(select 1 from public.admins a where a.user_id=auth.uid()));
drop policy if exists "Admins delete chapters" on public.chapters;
create policy "Admins delete chapters" on public.chapters for delete to authenticated using (exists(select 1 from public.admins a where a.user_id=auth.uid()));

create or replace function public.increment_novel_views(novel_uuid uuid)
returns void language sql security definer set search_path=public as $$
 update public.novels set views=views+1,updated_at=now() where id=novel_uuid;
$$;
grant execute on function public.increment_novel_views(uuid) to anon,authenticated;

create or replace function public.increment_chapter_views(chapter_uuid uuid)
returns void language sql security definer set search_path=public as $$
 update public.chapters set views=views+1 where id=chapter_uuid;
$$;
grant execute on function public.increment_chapter_views(uuid) to anon,authenticated;

insert into public.novels(title,slug,author,translator,genre,status,synopsis,cover_url)
values
('The Hidden Moon','the-hidden-moon','Demo Author','Demo Translator','Romance','ongoing','Demo novel. Replace this with your own novel information.','https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=700&q=80'),
('Whispers in the Rain','whispers-in-the-rain','Demo Author','Demo Translator','Drama','completed','Demo novel. Replace this with your own novel information.','https://images.unsplash.com/photo-1512820790803-83ca734da794?w=700&q=80')
on conflict(slug) do nothing;

-- ADMIN SETUP:
-- 1) Supabase Dashboard > Authentication > Users > Add user.
-- 2) Create your admin email/password.
-- 3) Copy that user's UUID.
-- 4) Run this line, replacing YOUR-USER-UUID:
-- insert into public.admins(user_id) values ('YOUR-USER-UUID') on conflict do nothing;

-- COVER IMAGE STORAGE
-- This creates a public bucket so Admin can upload book covers from the website.
insert into storage.buckets (id, name, public)
values ('covers', 'covers', true)
on conflict (id) do update set public = true;

drop policy if exists "Public can view covers" on storage.objects;
create policy "Public can view covers" on storage.objects for select to anon, authenticated using (bucket_id = 'covers');

drop policy if exists "Admins can upload covers" on storage.objects;
create policy "Admins can upload covers" on storage.objects for insert to authenticated with check (bucket_id = 'covers' and exists(select 1 from public.admins a where a.user_id=auth.uid()));

drop policy if exists "Admins can update covers" on storage.objects;
create policy "Admins can update covers" on storage.objects for update to authenticated using (bucket_id = 'covers' and exists(select 1 from public.admins a where a.user_id=auth.uid())) with check (bucket_id = 'covers' and exists(select 1 from public.admins a where a.user_id=auth.uid()));

drop policy if exists "Admins can delete covers" on storage.objects;
create policy "Admins can delete covers" on storage.objects for delete to authenticated using (bucket_id = 'covers' and exists(select 1 from public.admins a where a.user_id=auth.uid()));
