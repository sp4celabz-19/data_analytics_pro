ALTER TABLE device
    ADD CONSTRAINT pk_device PRIMARY KEY (device_id),
    ALTER COLUMN device_name SET NOT NULL,
    ADD CONSTRAINT uq_device_name UNIQUE (device_name);

ALTER TABLE country
    ADD CONSTRAINT pk_country PRIMARY KEY (country_id),
    ALTER COLUMN country_code SET NOT NULL,
    ADD CONSTRAINT uq_country_name UNIQUE (country_code);

ALTER TABLE "group"
    ADD CONSTRAINT pk_group PRIMARY KEY (group_id),
    ALTER COLUMN group_label SET NOT NULL,
    ADD CONSTRAINT uq_group_name UNIQUE (group_label);

ALTER TABLE "user"
    ADD CONSTRAINT pk_user PRIMARY KEY (user_id),
    ADD CONSTRAINT fk_user_device FOREIGN KEY (device_id) REFERENCES device(device_id),
    ADD CONSTRAINT fk_user_country FOREIGN KEY (country_id) REFERENCES country(country_id),
    ADD CONSTRAINT fk_user_group FOREIGN KEY (group_id) REFERENCES "group"(group_id),
    ALTER COLUMN device_id SET NOT NULL,
    ALTER COLUMN country_id SET NOT NULL,
    ALTER COLUMN group_id SET NOT NULL;

ALTER TABLE daily
    ADD CONSTRAINT fk_daily_user FOREIGN KEY (user_id) REFERENCES "user"(user_id),
    ALTER COLUMN user_id SET NOT NULL,
    ALTER COLUMN date SET NOT NULL;
