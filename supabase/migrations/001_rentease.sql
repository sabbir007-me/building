create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  email text not null unique,
  phone text not null default '',
  role text not null default 'tenant' check (role in ('tenant', 'landlord', 'admin')),
  status text not null default 'Active' check (status in ('Active', 'Suspended')),
  created_at timestamptz not null default now()
);

create table if not exists public.properties (
  id text primary key,
  slug text not null unique,
  title text not null,
  type text not null check (type in ('Apartment', 'House', 'Studio')),
  address text not null,
  city text not null,
  rent numeric not null check (rent > 0),
  bedrooms integer not null check (bedrooms > 0),
  bathrooms integer not null check (bathrooms > 0),
  area integer not null check (area > 0),
  image text not null,
  landlord_id uuid not null references public.profiles(id),
  availability text not null default 'Available' check (availability in ('Available', 'Occupied', 'Archived')),
  approval text not null default 'Pending' check (approval in ('Approved', 'Pending', 'Rejected')),
  description text not null,
  amenities text[] not null default '{}',
  available_from date not null,
  created_at timestamptz not null default now()
);

create table if not exists public.applications (
  id text primary key,
  tenant_id uuid not null references public.profiles(id),
  property_id text not null references public.properties(id) on delete cascade,
  submitted_at date not null default current_date,
  status text not null default 'Pending' check (status in ('Pending', 'Approved', 'Rejected', 'Cancelled')),
  message text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists public.rentals (
  id text primary key,
  tenant_id uuid not null references public.profiles(id),
  property_id text not null references public.properties(id),
  start_date date not null,
  end_date date not null,
  rent numeric not null check (rent > 0),
  status text not null default 'Active' check (status in ('Active', 'Ending soon', 'Ended')),
  created_at timestamptz not null default now()
);

create table if not exists public.payments (
  id text primary key,
  rental_id text not null references public.rentals(id) on delete cascade,
  kind text not null check (kind in ('Rent', 'Water', 'Electricity', 'Internet')),
  amount numeric not null check (amount >= 0),
  due_date date not null,
  status text not null default 'Due' check (status in ('Paid', 'Due', 'Overdue')),
  paid_at date,
  created_at timestamptz not null default now()
);

create table if not exists public.maintenance (
  id text primary key,
  tenant_id uuid not null references public.profiles(id),
  property_id text not null references public.properties(id),
  category text not null,
  description text not null,
  priority text not null default 'Normal' check (priority in ('Low', 'Normal', 'Urgent')),
  status text not null default 'Open' check (status in ('Open', 'In progress', 'Resolved')),
  submitted_at date not null default current_date,
  created_at timestamptz not null default now()
);

create table if not exists public.notifications (
  id text primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  message text not null,
  href text not null,
  created_at timestamptz not null default now(),
  read_at timestamptz
);

create index if not exists properties_landlord_id_idx on public.properties(landlord_id);
create index if not exists applications_tenant_id_idx on public.applications(tenant_id);
create index if not exists applications_property_id_idx on public.applications(property_id);
create index if not exists rentals_tenant_id_idx on public.rentals(tenant_id);
create index if not exists maintenance_tenant_id_idx on public.maintenance(tenant_id);
create index if not exists notifications_user_id_idx on public.notifications(user_id);

create or replace function public.current_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select role from public.profiles where id = auth.uid();
$$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, name, email, phone, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'name', split_part(new.email, '@', 1)),
    lower(new.email),
    coalesce(new.raw_user_meta_data ->> 'phone', ''),
    case when new.raw_user_meta_data ->> 'role' = 'landlord' then 'landlord' else 'tenant' end
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.properties enable row level security;
alter table public.applications enable row level security;
alter table public.rentals enable row level security;
alter table public.payments enable row level security;
alter table public.maintenance enable row level security;
alter table public.notifications enable row level security;

create policy "Public can view approved available properties"
  on public.properties for select
  using (approval = 'Approved' and availability <> 'Archived');
create policy "Users can view their profile"
  on public.profiles for select using (id = auth.uid() or public.current_role() = 'admin');
create policy "Users can update their profile"
  on public.profiles for update using (id = auth.uid() or public.current_role() = 'admin');
create policy "Landlords can manage their properties"
  on public.properties for all
  using (landlord_id = auth.uid() or public.current_role() = 'admin')
  with check (landlord_id = auth.uid() or public.current_role() = 'admin');
create policy "Tenants and landlords can view related applications"
  on public.applications for select
  using (
    tenant_id = auth.uid()
    or property_id in (select id from public.properties where landlord_id = auth.uid())
    or public.current_role() = 'admin'
  );
create policy "Tenants can create applications"
  on public.applications for insert
  with check (tenant_id = auth.uid() and public.current_role() = 'tenant');
create policy "Landlords and admins can update applications"
  on public.applications for update
  using (
    property_id in (select id from public.properties where landlord_id = auth.uid())
    or public.current_role() = 'admin'
  );
create policy "Related users can view rentals"
  on public.rentals for select
  using (
    tenant_id = auth.uid()
    or property_id in (select id from public.properties where landlord_id = auth.uid())
    or public.current_role() = 'admin'
  );
create policy "Related users can view payments"
  on public.payments for select
  using (
    rental_id in (select id from public.rentals where tenant_id = auth.uid())
    or rental_id in (
      select r.id from public.rentals r
      join public.properties p on p.id = r.property_id
      where p.landlord_id = auth.uid()
    )
    or public.current_role() = 'admin'
  );
create policy "Related users can view maintenance"
  on public.maintenance for select
  using (
    tenant_id = auth.uid()
    or property_id in (select id from public.properties where landlord_id = auth.uid())
    or public.current_role() = 'admin'
  );
create policy "Tenants can create maintenance requests"
  on public.maintenance for insert
  with check (tenant_id = auth.uid() and public.current_role() = 'tenant');
create policy "Landlords and admins can update maintenance"
  on public.maintenance for update
  using (
    property_id in (select id from public.properties where landlord_id = auth.uid())
    or public.current_role() = 'admin'
  );
create policy "Users can view their notifications"
  on public.notifications for select using (user_id = auth.uid() or public.current_role() = 'admin');
create policy "Users can update their notifications"
  on public.notifications for update using (user_id = auth.uid());

alter publication supabase_realtime add table public.properties;
alter publication supabase_realtime add table public.applications;
alter publication supabase_realtime add table public.rentals;
alter publication supabase_realtime add table public.payments;
alter publication supabase_realtime add table public.maintenance;
alter publication supabase_realtime add table public.notifications;
