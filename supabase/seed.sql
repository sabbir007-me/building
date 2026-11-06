-- RentEase demo seed data.
-- Run this after supabase/migrations/001_rentease.sql in Supabase SQL Editor.
-- These are illustrative demo credentials only.

create extension if not exists pgcrypto;

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, created_at, updated_at, raw_app_meta_data,
  raw_user_meta_data, is_super_admin, confirmation_token,
  email_change, email_change_token_new, recovery_token
)
values
  ('11111111-1111-4111-8111-111111111111', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'tenant@rentease.demo', crypt('Tenant123!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"name":"Nusrat Jahan","phone":"+880 1712-345678","role":"tenant"}', false, '', '', '', ''),
  ('22222222-2222-4222-8222-222222222222', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'tenant2@rentease.demo', crypt('Tenant123!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"name":"Tanvir Hasan","phone":"+880 1612-345678","role":"tenant"}', false, '', '', '', ''),
  ('33333333-3333-4333-8333-333333333333', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'landlord@rentease.demo', crypt('Landlord123!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"name":"Farhan Ahmed","phone":"+880 1812-345678","role":"landlord"}', false, '', '', '', ''),
  ('44444444-4444-4444-8444-444444444444', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'landlord2@rentease.demo', crypt('Landlord123!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"name":"Rashida Karim","phone":"+880 1512-345678","role":"landlord"}', false, '', '', '', ''),
  ('55555555-5555-4555-8555-555555555555', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'admin@rentease.demo', crypt('Admin123!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"name":"Samira Rahman","phone":"+880 1912-345678","role":"admin"}', false, '', '', '', '')
on conflict (id) do nothing;

insert into auth.identities (id, user_id, provider, identity_data, provider_id, created_at, updated_at)
values
  ('11111111-1111-4111-8111-111111111111', '11111111-1111-4111-8111-111111111111', 'email', '{"sub":"11111111-1111-4111-8111-111111111111","email":"tenant@rentease.demo"}', '11111111-1111-4111-8111-111111111111', now(), now()),
  ('22222222-2222-4222-8222-222222222222', '22222222-2222-4222-8222-222222222222', 'email', '{"sub":"22222222-2222-4222-8222-222222222222","email":"tenant2@rentease.demo"}', '22222222-2222-4222-8222-222222222222', now(), now()),
  ('33333333-3333-4333-8333-333333333333', '33333333-3333-4333-8333-333333333333', 'email', '{"sub":"33333333-3333-4333-8333-333333333333","email":"landlord@rentease.demo"}', '33333333-3333-4333-8333-333333333333', now(), now()),
  ('44444444-4444-4444-8444-444444444444', '44444444-4444-4444-8444-444444444444', 'email', '{"sub":"44444444-4444-4444-8444-444444444444","email":"landlord2@rentease.demo"}', '44444444-4444-4444-8444-444444444444', now(), now()),
  ('55555555-5555-4555-8555-555555555555', '55555555-5555-4555-8555-555555555555', 'email', '{"sub":"55555555-5555-4555-8555-555555555555","email":"admin@rentease.demo"}', '55555555-5555-4555-8555-555555555555', now(), now())
on conflict (provider_id, provider) do nothing;

insert into public.profiles (id, name, email, phone, role, status)
values
  ('11111111-1111-4111-8111-111111111111', 'Nusrat Jahan', 'tenant@rentease.demo', '+880 1712-345678', 'tenant', 'Active'),
  ('22222222-2222-4222-8222-222222222222', 'Tanvir Hasan', 'tenant2@rentease.demo', '+880 1612-345678', 'tenant', 'Active'),
  ('33333333-3333-4333-8333-333333333333', 'Farhan Ahmed', 'landlord@rentease.demo', '+880 1812-345678', 'landlord', 'Active'),
  ('44444444-4444-4444-8444-444444444444', 'Rashida Karim', 'landlord2@rentease.demo', '+880 1512-345678', 'landlord', 'Active'),
  ('55555555-5555-4555-8555-555555555555', 'Samira Rahman', 'admin@rentease.demo', '+880 1912-345678', 'admin', 'Active')
on conflict (id) do update set name = excluded.name, phone = excluded.phone, role = excluded.role, status = excluded.status;

insert into public.properties (id, slug, title, type, address, city, rent, bedrooms, bathrooms, area, image, landlord_id, availability, approval, description, amenities, available_from)
values
  ('property-1', 'gulshan-garden-residence', 'Gulshan Garden Residence', 'Apartment', 'House 18, Road 42, Gulshan 2', 'Dhaka', 68000, 3, 3, 1850, '/images/properties/serenity-tower.jpg', '33333333-3333-4333-8333-333333333333', 'Occupied', 'Approved', 'A bright, well-kept family apartment on a quiet Gulshan street, close to parks, schools and everyday conveniences.', array['Lift','Generator','Security','Parking','Balcony'], '2026-12-01'),
  ('property-2', 'banani-lakeview-flat', 'Banani Lakeview Flat', 'Apartment', 'House 7, Road 11, Banani', 'Dhaka', 52000, 3, 2, 1550, '/images/properties/belgrave-penthouse.jpg', '33333333-3333-4333-8333-333333333333', 'Available', 'Approved', 'Comfortable city living with generous rooms and a balcony overlooking a leafy residential lane.', array['Lift','Generator','Security','Balcony'], '2026-11-15'),
  ('property-3', 'dhanmondi-family-home', 'Dhanmondi Family Home', 'Apartment', 'House 32, Road 8/A, Dhanmondi', 'Dhaka', 42000, 3, 2, 1420, '/images/properties/ocean-breeze-retreat.jpg', '44444444-4444-4444-8444-444444444444', 'Occupied', 'Approved', 'A welcoming, sunlit home close to Dhanmondi Lake, local markets and public transport.', array['Lift','Generator','Security','Play area'], '2026-11-01'),
  ('property-4', 'uttara-modern-apartment', 'Uttara Modern Apartment', 'Apartment', 'Sector 4, Road 12, Uttara', 'Dhaka', 32000, 2, 2, 1120, '/images/properties/azura-villa.jpg', '44444444-4444-4444-8444-444444444444', 'Available', 'Approved', 'A practical, airy apartment in a well-connected Uttara neighborhood with thoughtful building amenities.', array['Lift','Security','Parking','Balcony'], '2026-11-10'),
  ('property-5', 'chattogram-hill-residence', 'Chattogram Hill Residence', 'Apartment', 'Road 3, Khulshi, Panchlaish', 'Chattogram', 38000, 3, 2, 1380, '/images/properties/mountain-lodge.jpg', '33333333-3333-4333-8333-333333333333', 'Available', 'Approved', 'A peaceful residence in Khulshi with open views, family-friendly surroundings and easy access to the city.', array['Lift','Generator','Security','Parking'], '2026-11-20'),
  ('property-6', 'sylhet-riverside-home', 'Sylhet Riverside Home', 'House', 'Block C, Shahjalal Upashahar', 'Sylhet', 28000, 3, 2, 1600, '/images/properties/comporta-beach-house.jpg', '44444444-4444-4444-8444-444444444444', 'Available', 'Approved', 'A standalone home with a small garden in a calm neighborhood, suited to families who want more room.', array['Garden','Parking','Balcony','Security'], '2026-12-01'),
  ('property-7', 'mirpur-compact-studio', 'Mirpur Compact Studio', 'Studio', 'Section 10, Mirpur', 'Dhaka', 18000, 1, 1, 620, '/images/properties/tulum-eco-retreat.jpg', '33333333-3333-4333-8333-333333333333', 'Available', 'Approved', 'A tidy, budget-friendly studio near transit, shops and essential services.', array['Lift','Security','Generator'], '2026-11-08')
on conflict (id) do update set title = excluded.title, availability = excluded.availability, approval = excluded.approval;

insert into public.applications (id, tenant_id, property_id, submitted_at, status, message)
values
  ('application-1', '11111111-1111-4111-8111-111111111111', 'property-2', '2026-10-28', 'Pending', 'I am looking for a long-term home close to my workplace.'),
  ('application-2', '22222222-2222-4222-8222-222222222222', 'property-5', '2026-10-21', 'Pending', 'My family is relocating to Chattogram next month.')
on conflict (id) do nothing;

insert into public.rentals (id, tenant_id, property_id, start_date, end_date, rent, status)
values
  ('rental-1', '11111111-1111-4111-8111-111111111111', 'property-1', '2026-01-01', '2026-12-31', 68000, 'Active'),
  ('rental-2', '22222222-2222-4222-8222-222222222222', 'property-3', '2026-04-01', '2027-03-31', 42000, 'Active')
on conflict (id) do nothing;

insert into public.payments (id, rental_id, kind, amount, due_date, status, paid_at)
values
  ('payment-1', 'rental-1', 'Rent', 68000, '2026-11-05', 'Due', null),
  ('payment-2', 'rental-1', 'Electricity', 2850, '2026-10-25', 'Paid', '2026-10-23'),
  ('payment-3', 'rental-1', 'Water', 650, '2026-10-25', 'Paid', '2026-10-23'),
  ('payment-4', 'rental-1', 'Rent', 68000, '2026-10-05', 'Paid', '2026-10-03'),
  ('payment-5', 'rental-2', 'Rent', 42000, '2026-11-05', 'Due', null),
  ('payment-6', 'rental-2', 'Internet', 1200, '2026-11-08', 'Due', null)
on conflict (id) do nothing;

insert into public.maintenance (id, tenant_id, property_id, category, description, priority, status, submitted_at)
values
  ('maintenance-1', '11111111-1111-4111-8111-111111111111', 'property-1', 'Plumbing', 'The kitchen tap is leaking and needs a washer replacement.', 'Normal', 'In progress', '2026-10-30'),
  ('maintenance-2', '22222222-2222-4222-8222-222222222222', 'property-3', 'Electrical', 'The hallway light is not working.', 'Low', 'Open', '2026-11-01')
on conflict (id) do nothing;

insert into public.notifications (id, user_id, message, href, created_at)
values
  ('notification-1', '11111111-1111-4111-8111-111111111111', 'Your November rent is due soon.', '/tenant/payments', '2026-11-01T09:00:00Z'),
  ('notification-2', '33333333-3333-4333-8333-333333333333', 'A new rental application is waiting for review.', '/landlord/applications', '2026-10-28T10:00:00Z')
on conflict (id) do nothing;
