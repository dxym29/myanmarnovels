# Novel House — Final Starter

A mobile-first personal novel reading website built with React + Vite + Supabase.

## Included
- Home, latest, popular and genre browsing
- Search
- Novel detail pages
- Chapter list
- Mobile reading page with previous/next navigation
- Dark mode
- Supabase database integration
- Supabase email/password admin login
- Admin dashboard for adding/editing/deleting novels
- Admin chapter editor
- 18+ flag field
- View counters prepared through Supabase RPC functions

## First-time setup
1. Copy `.env.example` to `.env`.
2. Put your Supabase Project URL and Publishable/anon key in `.env`.
3. Run `npm install` then `npm run dev`.
4. Run `supabase/schema.sql` once in the NEW Supabase project's SQL Editor.
5. In Supabase Authentication > Users, create your admin email/password.
6. Copy that user's UUID and run the admin insert line at the bottom of `schema.sql`.
7. Open `#/login` or click Admin in the footer.

## Important
Never put a Supabase service-role/secret key in `.env` for this frontend. Use the Publishable/anon key.
