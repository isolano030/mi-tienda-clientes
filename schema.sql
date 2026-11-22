-- Run this entire script in Supabase SQL Editor.
create table public.customers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  email text,
  phone text,
  note text,
  created_at timestamptz not null default now()
);
create table public.customer_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('admin','customer')),
  customer_id uuid references public.customers(id) on delete cascade
);
create table public.orders (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references public.customers(id) on delete cascade,
  order_date date not null default current_date,
  status text not null default 'pending' check (status in ('pending','purchased','shipped','delivered')),
  total_amount numeric(12,2) not null default 0 check (total_amount >= 0),
  note text,
  created_at timestamptz not null default now()
);
create table public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_name text not null,
  quantity integer not null default 1 check (quantity > 0),
  unit_price numeric(12,2) not null check (unit_price >= 0),
  line_total numeric(12,2) not null check (line_total >= 0)
);
create table public.payments (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references public.customers(id) on delete cascade,
  amount numeric(12,2) not null check (amount > 0),
  payment_date date not null default current_date,
  method text,
  note text,
  created_at timestamptz not null default now()
);

-- Security helpers: security-definer avoids recursive RLS checks.
create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public
as $$ select exists(select 1 from public.customer_profiles where user_id=auth.uid() and role='admin') $$;
create or replace function public.my_customer_id()
returns uuid language sql stable security definer set search_path = public
as $$ select customer_id from public.customer_profiles where user_id=auth.uid() and role='customer' limit 1 $$;

alter table public.customers enable row level security;
alter table public.customer_profiles enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.payments enable row level security;

-- Admins manage all data. Customers can read only their own linked records.
create policy "admin manage customers" on public.customers for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "customer read own customer" on public.customers for select to authenticated using (id=public.my_customer_id());
create policy "profiles read self or admin" on public.customer_profiles for select to authenticated using (user_id=auth.uid() or public.is_admin());
create policy "admin manage profiles" on public.customer_profiles for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin manage orders" on public.orders for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "customer read own orders" on public.orders for select to authenticated using (customer_id=public.my_customer_id());
create policy "admin manage order items" on public.order_items for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "customer read own order items" on public.order_items for select to authenticated using (exists(select 1 from public.orders o where o.id=order_id and o.customer_id=public.my_customer_id()));
create policy "admin manage payments" on public.payments for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "customer read own payments" on public.payments for select to authenticated using (customer_id=public.my_customer_id());

-- Optional: create a view for balances if useful later.
