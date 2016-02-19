CREATE TYPE parameter_type AS ENUM ('bool', 'numeric', 'textual');
CREATE DOMAIN price AS MONEY CONSTRAINT positive_price CHECK (VALUE >= 0::money);
CREATE DOMAIN tax_rate AS DECIMAL(7,5) CONSTRAINT positive_percentage CHECK (VALUE >= 0);

CREATE TABLE manufacturer (
	id SERIAL,
	name VARCHAR(64) NOT NULL,
	PRIMARY KEY (id),
	UNIQUE (name)
);

CREATE TABLE suplier (
	id SERIAL,
	name VARCHAR(64) NOT NULL,
	PRIMARY KEY (id),
	UNIQUE (name)
);

CREATE TABLE tax_level (
	id SERIAL,
	name VARCHAR(64) NOT NULL,
	PRIMARY KEY (id),
	UNIQUE (name)
);

CREATE TABLE tax (
	tax_level_id INTEGER NOT NULL,
	active_from DATE,
	active_until DATE,
	percentage TAX_RATE NOT NULL,
	UNIQUE (tax_level_id, active_from),
	UNIQUE (tax_level_id, active_until),
	CONSTRAINT from_lower_than_until CHECK (active_from < active_until),
	FOREIGN KEY (tax_level_id) REFERENCES tax_level (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE FUNCTION check_taxes_uniqueness() RETURNS trigger
AS $$
	DECLARE
		duplicates INTEGER;
	BEGIN
		IF NEW.active_until IS NULL THEN
			SELECT COUNT(*) INTO duplicates FROM tax WHERE tax_level_id = NEW.tax_level_id AND active_until IS NULL;
			IF duplicates > 0 THEN
				RAISE EXCEPTION 'Another tax violates uniqueness. Set it''s active_until to NOT NULL value before inserting new row with NULL value.';
			END IF;
		END IF;
		RETURN NEW;
	END;
$$ LANGUAGE plpgsql
STABLE;

CREATE TRIGGER check_taxes_uniqueness_trigger
BEFORE INSERT OR UPDATE OF active_until
ON tax
FOR EACH ROW
EXECUTE PROCEDURE check_taxes_uniqueness();

CREATE TABLE availability (
	id SERIAL,
	name VARCHAR(64) NOT NULL,
	description VARCHAR(1024),
	PRIMARY KEY (id),
	UNIQUE (name)
);

CREATE TABLE product_line (
	id SERIAL,
	name VARCHAR(64) NOT NULL,
	PRIMARY KEY (id),
	UNIQUE (name)
);

CREATE TABLE unit (
	id SERIAL,
	name VARCHAR(64) NOT NULL,
	unit_id INTEGER,
	ratio DECIMAL(12, 6),
	PRIMARY KEY (id),
	UNIQUE (name),
	FOREIGN KEY (unit_id) REFERENCES unit (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE product (
	id SERIAL,
	uuid UUID, -- Usable for XML feeds
	manufacturer_id INTEGER,
	manufacturer_product_no VARCHAR(64),
	product_line_id INTEGER,
	suplier_id INTEGER,
	tax_level_id INTEGER,
	name VARCHAR(255) NOT NULL,
	short_description VARCHAR(1024),
	description TEXT,
	price PRICE NOT NULL,
	quantity INTEGER,
	unit_id INTEGER, -- Specify unit if product isn't sold per pieces
	minimum_amount INTEGER NOT NULL DEFAULT 1,
	availability_id INTEGER NOT NULL,
	active BOOLEAN,
	PRIMARY KEY (id),
	UNIQUE (uuid),
	UNIQUE (manufacturer_id, manufacturer_product_no),
	FOREIGN KEY (manufacturer_id) REFERENCES manufacturer (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (product_line_id) REFERENCES product_line (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (suplier_id) REFERENCES suplier (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (tax_level_id) REFERENCES tax_level (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (unit_id) REFERENCES unit (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (availability_id) REFERENCES availability (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE product_accessory (
	product_id INTEGER NOT NULL,
	accessory_product_id INTEGER NOT NULL,
	PRIMARY KEY (product_id, accessory_product_id),
	FOREIGN KEY (product_id) REFERENCES product (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (accessory_product_id) REFERENCES product (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE product_gift (
	product_id INTEGER NOT NULL,
	gift_product_id INTEGER NOT NULL,
	PRIMARY KEY (product_id, gift_product_id),
	FOREIGN KEY (product_id) REFERENCES product (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (gift_product_id) REFERENCES product (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE parameter (
	id SERIAL,
	name VARCHAR(64) NOT NULL,
	type PARAMETER_TYPE, -- Hint for inserting known parameter with correct type
	PRIMARY KEY (id),
	UNIQUE (name)
);

CREATE TABLE product_parameter_bool (
	product_id INTEGER NOT NULL,
	parameter_id INTEGER NOT NULL,
	value BOOLEAN, -- NULL represents "maybe" (indecisive answer)
	PRIMARY KEY (product_id, parameter_id),
	FOREIGN KEY (product_id) REFERENCES product (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (parameter_id) REFERENCES parameter (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE product_parameter_numeric (
	product_id INTEGER NOT NULL,
	parameter_id INTEGER NOT NULL,
	value DECIMAL(12, 6) NOT NULL,
	unit_id INTEGER,
	PRIMARY KEY (product_id, parameter_id, value),
	FOREIGN KEY (product_id) REFERENCES product (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (parameter_id) REFERENCES parameter (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (unit_id) REFERENCES unit (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE product_parameter_textual (
	product_id INTEGER NOT NULL,
	parameter_id INTEGER NOT NULL,
	value VARCHAR NOT NULL,
	PRIMARY KEY (product_id, parameter_id, value),
	FOREIGN KEY (product_id) REFERENCES product (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (parameter_id) REFERENCES parameter (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE product_variant (
	product_id INTEGER NOT NULL,
	-- Split product informations to basic data and variants data
);

REASSIGN OWNED BY archbishop TO reader;
