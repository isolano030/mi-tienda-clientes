# Mi Tienda — Sales & Customer Portal Starter

A Spanish-language responsive web starter for a small US-to-Costa Rica personal shopping/resale business. Includes an admin panel and read-only customer portal. Frontend is static HTML and uses Supabase Auth + Postgres with Row Level Security (RLS).

## What is included
- Admin dashboard: totals, customer directory, order entry (single product line per order), payment entry, client account detail.
- Customer portal: read-only list of their products/orders, payments, and balance.
- Status labels: Pendiente, Comprado, En tránsito, Entregado.
- USD display, mobile responsive layout.

## Important security notes
- Never put a Supabase `service_role` key in this frontend. Use only the project's anon/public key.
- The supplied SQL enables RLS and makes customer data read-only for clients. Run it as-is before connecting.
- Admin/customer user setup must be done in Supabase Dashboard (or a secure server function), not through this public frontend.
- This is a starter prototype. Before real customer financial records, test all permissions using separate admin and customer accounts. Avoid adding highly sensitive personal information.

## Setup
1. Create a Supabase project at https://supabase.com.
2. In the project, open **SQL Editor**, paste `schema.sql`, and run it.
3. In **Authentication → Users**, create an admin user with email/password.
4. Copy that user's UUID. In SQL Editor, assign the admin profile:
   ```sql
   insert into public.customer_profiles(user_id, role, customer_id)
   values ('ADMIN-USER-UUID-HERE', 'admin', null);
   ```
5. Create a customer in the admin app. To provision their login, create a user in **Authentication → Users** with their email and temporary password, copy the UUID, then link it to the customer:
   ```sql
   insert into public.customer_profiles(user_id, role, customer_id)
   values ('CUSTOMER-AUTH-UUID-HERE', 'customer', 'CUSTOMER-ROW-UUID-HERE');
   ```
   For the customer's `customer_id`, use the row ID from `customers` for that person (copy it from Table Editor).
6. In **Project Settings → API**, copy the Project URL and anon/public key. Edit `index.html` and replace:
   - `YOUR_SUPABASE_URL`
   - `YOUR_SUPABASE_ANON_KEY`
7. Test locally by opening `index.html`. If your browser blocks local auth redirects, use a local static server, or publish to GitHub Pages first. Add your deployment URL to Supabase **Authentication → URL Configuration → Site URL / Redirect URLs**.
8. Publish using GitHub Pages: create a repository, upload `index.html`, and enable Pages in **Settings → Pages → Deploy from a branch → main / root**.

## Admin account
Admin profile is role `admin` and has no customer ID. Customer profile is role `customer` and must reference their customer row. Users without a profile cannot use the app.

## Currency
The UI is set to USD. If you later need Costa Rican colones or exchange-rate calculations, this can be added.
