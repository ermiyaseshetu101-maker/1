-- simplePOS multi-tenant schema

create table if not exists features (
  id text primary key,
  key text not null unique,
  name text not null,
  description text not null default '',
  kind text not null default 'toggle'
);

create table if not exists plans (
  id text primary key,
  name text not null,
  slug text not null unique,
  price_etb integer not null default 0,
  billing_interval text not null default 'month',
  description text not null default '',
  is_public boolean not null default true,
  sort_order integer not null default 0
);

create table if not exists plan_features (
  plan_id text not null references plans(id) on delete cascade,
  feature_id text not null references features(id) on delete cascade,
  enabled boolean not null default true,
  limit_value integer,
  primary key (plan_id, feature_id)
);

create table if not exists profiles (
  user_id text primary key,
  platform_role text not null default 'owner',
  restaurant_id text,
  email_verified boolean not null default false,
  display_name text,
  created_at timestamptz not null default now()
);

create table if not exists restaurants (
  id text primary key,
  owner_user_id text not null,
  name text not null,
  slug text not null unique,
  status text not null default 'pending',
  plan_id text not null default 'plan_trial',
  currency text not null default 'ETB',
  language text not null default 'en',
  receipt_footer text not null default 'Ameseginalehu — thank you',
  logo_url text,
  trial_ends_at timestamptz not null,
  created_at timestamptz not null default now()
);
create index if not exists restaurants_owner_idx on restaurants (owner_user_id);

create table if not exists staff (
  id text primary key,
  restaurant_id text not null,
  name text not null,
  name_am text not null default '',
  pin text not null,
  role text not null,
  active boolean not null default true,
  created_at timestamptz not null default now()
);
create index if not exists staff_restaurant_idx on staff (restaurant_id);

create table if not exists categories (
  id text primary key,
  restaurant_id text not null,
  name text not null,
  name_am text not null default '',
  sort_order integer not null default 0
);
create index if not exists categories_restaurant_idx on categories (restaurant_id);

create table if not exists products (
  id text primary key,
  restaurant_id text not null,
  category_id text not null,
  name text not null,
  name_am text not null default '',
  price integer not null,
  available boolean not null default true
);
create index if not exists products_restaurant_idx on products (restaurant_id);

create table if not exists dining_tables (
  id text primary key,
  restaurant_id text not null,
  label text not null,
  seats integer not null default 4,
  status text not null default 'available',
  order_id text
);
create index if not exists dining_tables_restaurant_idx on dining_tables (restaurant_id);

create table if not exists orders (
  id text primary key,
  restaurant_id text not null,
  number integer not null,
  table_id text,
  table_label text,
  staff_id text,
  staff_name text not null default '',
  status text not null default 'new',
  paid boolean not null default false,
  payment_method text,
  tendered integer,
  discount integer not null default 0,
  order_type text not null default 'takeaway',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists orders_restaurant_idx on orders (restaurant_id);

create table if not exists order_items (
  id text primary key,
  order_id text not null,
  restaurant_id text not null,
  product_id text,
  name text not null,
  name_am text not null default '',
  price integer not null,
  qty integer not null
);
create index if not exists order_items_order_idx on order_items (order_id);

create table if not exists subscriptions (
  id text primary key,
  restaurant_id text not null,
  plan_id text not null,
  status text not null default 'trialing',
  current_period_end timestamptz,
  created_at timestamptz not null default now()
);
create index if not exists subscriptions_restaurant_idx on subscriptions (restaurant_id);

create table if not exists payments (
  id text primary key,
  restaurant_id text not null,
  subscription_id text,
  plan_id text not null,
  amount_etb integer not null,
  provider text not null,
  status text not null default 'pending',
  created_at timestamptz not null default now()
);
create index if not exists payments_restaurant_idx on payments (restaurant_id);

insert into features (id, key, name, description, kind) values
  ('feat_max_staff', 'max_staff', 'Staff seats', 'Maximum staff accounts', 'limit'),
  ('feat_max_products', 'max_products', 'Product catalog', 'Maximum products', 'limit'),
  ('feat_max_tables', 'max_tables', 'Dining tables', 'Maximum floor tables', 'limit'),
  ('feat_kds', 'kds', 'Kitchen display', 'Live kitchen tickets', 'toggle'),
  ('feat_reports', 'reports', 'Advanced reports', 'Sales analytics', 'toggle'),
  ('feat_inventory', 'inventory', 'Inventory', 'Stock tracking', 'toggle'),
  ('feat_multi_device', 'multi_device', 'Multiple devices', 'Concurrent terminals', 'toggle'),
  ('feat_printer', 'printer', 'Thermal printer', 'Receipt printing', 'toggle'),
  ('feat_customers', 'customers', 'Customers', 'Guest profiles', 'toggle'),
  ('feat_discounts', 'discounts', 'Discounts', 'Ticket promotions', 'toggle'),
  ('feat_i18n', 'i18n', 'Multi-language', 'English and Amharic', 'toggle'),
  ('feat_receipt_branding', 'receipt_branding', 'Receipt branding', 'Custom footer and logo', 'toggle')
on conflict (id) do nothing;

insert into plans (id, name, slug, price_etb, billing_interval, description, is_public, sort_order) values
  ('plan_trial', 'Trial', 'trial', 0, 'once', '45-day trial with core POS', true, 0),
  ('plan_starter', 'Starter', 'starter', 1500, 'month', 'Front of house for a single room', true, 1),
  ('plan_pro', 'Professional', 'professional', 3500, 'month', 'Kitchen display, reports, and branding', true, 2),
  ('plan_business', 'Business', 'business', 7500, 'month', 'Unlimited operations for growing groups', true, 3)
on conflict (id) do nothing;

insert into plan_features (plan_id, feature_id, enabled, limit_value) values
  ('plan_trial', 'feat_max_staff', true, 4),
  ('plan_trial', 'feat_max_products', true, 40),
  ('plan_trial', 'feat_max_tables', true, 12),
  ('plan_trial', 'feat_kds', true, null),
  ('plan_trial', 'feat_reports', false, null),
  ('plan_trial', 'feat_inventory', false, null),
  ('plan_trial', 'feat_multi_device', false, null),
  ('plan_trial', 'feat_printer', false, null),
  ('plan_trial', 'feat_customers', false, null),
  ('plan_trial', 'feat_discounts', false, null),
  ('plan_trial', 'feat_i18n', true, null),
  ('plan_trial', 'feat_receipt_branding', false, null),

  ('plan_starter', 'feat_max_staff', true, 10),
  ('plan_starter', 'feat_max_products', true, 100),
  ('plan_starter', 'feat_max_tables', true, 30),
  ('plan_starter', 'feat_kds', true, null),
  ('plan_starter', 'feat_reports', false, null),
  ('plan_starter', 'feat_inventory', false, null),
  ('plan_starter', 'feat_multi_device', false, null),
  ('plan_starter', 'feat_printer', true, null),
  ('plan_starter', 'feat_customers', false, null),
  ('plan_starter', 'feat_discounts', true, null),
  ('plan_starter', 'feat_i18n', true, null),
  ('plan_starter', 'feat_receipt_branding', false, null),

  ('plan_pro', 'feat_max_staff', true, 25),
  ('plan_pro', 'feat_max_products', true, 500),
  ('plan_pro', 'feat_max_tables', true, 80),
  ('plan_pro', 'feat_kds', true, null),
  ('plan_pro', 'feat_reports', true, null),
  ('plan_pro', 'feat_inventory', false, null),
  ('plan_pro', 'feat_multi_device', true, null),
  ('plan_pro', 'feat_printer', true, null),
  ('plan_pro', 'feat_customers', true, null),
  ('plan_pro', 'feat_discounts', true, null),
  ('plan_pro', 'feat_i18n', true, null),
  ('plan_pro', 'feat_receipt_branding', true, null),

  ('plan_business', 'feat_max_staff', true, -1),
  ('plan_business', 'feat_max_products', true, -1),
  ('plan_business', 'feat_max_tables', true, -1),
  ('plan_business', 'feat_kds', true, null),
  ('plan_business', 'feat_reports', true, null),
  ('plan_business', 'feat_inventory', true, null),
  ('plan_business', 'feat_multi_device', true, null),
  ('plan_business', 'feat_printer', true, null),
  ('plan_business', 'feat_customers', true, null),
  ('plan_business', 'feat_discounts', true, null),
  ('plan_business', 'feat_i18n', true, null),
  ('plan_business', 'feat_receipt_branding', true, null)
on conflict (plan_id, feature_id) do nothing;
