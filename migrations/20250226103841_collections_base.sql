CREATE SCHEMA planning;

CREATE GROUP app_users;

CREATE USER app;
ALTER GROUP app_users ADD USER app;

GRANT USAGE ON SCHEMA planning TO app_users;

CREATE TABLE planning.collection_plan (
  id SERIAL PRIMARY KEY NOT NULL,
  name VARCHAR(255) NOT NULL,
  day VARCHAR(10) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),

  CHECK (day = ANY(ARRAY['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY']))
);

GRANT SELECT, INSERT, UPDATE ON planning.collection_plan TO app_users;
GRANT USAGE, SELECT ON SEQUENCE planning.collection_plan_id_seq TO app_users;

CREATE TABLE planning.vehicle_type (
  id SERIAL PRIMARY KEY NOT NULL,
  category varchar(20) NOT NULL,
  capacity_kg INTEGER NOT NULL,
  speed_percentage DOUBLE PRECISION NOT NULL
  
  CHECK (speed_percentage > 0 AND speed_percentage <= 1)
);
INSERT INTO planning.vehicle_type (category, speed_percentage, capacity_kg) VALUES
  ('L2', 1, 150),
  ('L3', 1, 200),
  ('L4', 1, 250),
  ('Box Truck', 1, 500),
  ('Box Truck Large', 0.8, 800),
  ('Trailer', 0.8, 1500);

GRANT SELECT ON planning.vehicle_type TO app_users;
GRANT USAGE, SELECT ON SEQUENCE planning.vehicle_type_id_seq TO app_users;

CREATE TABLE planning.tour_plan (
  id SERIAL PRIMARY KEY NOT NULL,
  collection_plan_id INTEGER NOT NULL,

  FOREIGN KEY (collection_plan_id) REFERENCES planning.collection_plan(id)
);

GRANT SELECT, INSERT, UPDATE ON planning.tour_plan TO app_users;
GRANT USAGE, SELECT ON SEQUENCE planning.tour_plan_id_seq TO app_users;

CREATE TABLE planning.stop (
  id SERIAL PRIMARY KEY NOT NULL,
  name VARCHAR(255) NOT NULL,
  merchant_id INTEGER,
  start_date DATE,
  end_date DATE,
  country VARCHAR(2) NOT NULL,
  city TEXT NOT NULL,
  postal_code TEXT NOT NULL,
  address TEXT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  collection_days TEXT NOT NULL
);

GRANT SELECT, INSERT, UPDATE ON planning.stop TO app_users;
GRANT USAGE, SELECT ON SEQUENCE planning.stop_id_seq TO app_users;

CREATE TABLE planning.planned_stop (
  id SERIAL PRIMARY KEY NOT NULL,
  stop_id INTEGER NOT NULL,
  arrival_time time,
  departure_time time,
  duration interval,
  
  FOREIGN KEY (stop_id) REFERENCES planning.stop (id)
);

GRANT SELECT, INSERT, UPDATE ON planning.planned_stop TO app_users;
GRANT USAGE, SELECT ON SEQUENCE planning.planned_stop_id_seq TO app_users;
