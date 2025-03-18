BEGIN;

-- 1. Vehicle Type Enum Conversion
CREATE TYPE planning.vehicle_category_enum AS ENUM ('L2', 'L3', 'L4', 'Box Truck', 'Box Truck Large', 'Trailer');
ALTER TABLE planning.vehicle_type ALTER COLUMN category TYPE planning.vehicle_category_enum USING category::planning.vehicle_category_enum;

-- 2. Collection Plan Day Conversion
CREATE TYPE planning.day_of_week_enum AS ENUM ('SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY');
ALTER TABLE planning.collection_plan RENAME COLUMN day TO collect_on;
ALTER TABLE planning.collection_plan ALTER COLUMN collect_on TYPE planning.day_of_week_enum USING collect_on::planning.day_of_week_enum;

-- 3. Stop Table Collection Days
ALTER TABLE planning.stop ALTER COLUMN collection_days TYPE JSONB USING collection_days::JSONB;
ALTER TABLE planning.stop
    ADD CONSTRAINT check_collection_days
        CHECK (
            collection_days ?| ARRAY['SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY']
    );
-- 4. Planned Tour Table
ALTER TABLE planning.tour_plan RENAME TO planned_tour;
ALTER TABLE planning.planned_tour ADD COLUMN name VARCHAR(255) NOT NULL;
ALTER TABLE planning.planned_tour ADD COLUMN created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW();
ALTER TABLE planning.planned_tour ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW();
ALTER TABLE planning.planned_tour ADD COLUMN vehicle_type_id INTEGER NOT NULL;
ALTER TABLE planning.planned_tour ADD CONSTRAINT fk_collection_plan FOREIGN KEY (collection_plan_id) REFERENCES planning.collection_plan(id);
ALTER TABLE planning.planned_tour ADD CONSTRAINT fk_vehicle_type FOREIGN KEY (vehicle_type_id) REFERENCES planning.vehicle_type(id) ON DELETE RESTRICT;

COMMIT;