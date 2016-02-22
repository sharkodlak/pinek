CREATE COLLATION C (locale='C');
CREATE DOMAIN price AS MONEY CONSTRAINT positive_price CHECK (VALUE >= 0::money);
CREATE DOMAIN tax_rate AS DECIMAL(7,5) CONSTRAINT positive_percentage CHECK (VALUE >= 0);
CREATE TYPE availability_type AS ENUM ('preorder', 'in stock', 'out of stock');
CREATE TYPE condition_type AS ENUM ('new', 'refurbished', 'used');
CREATE TYPE parameter_type AS ENUM ('bool', 'enum', 'numeric', 'textual');

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
	min_days SMALLINT NOT NULL,
	PRIMARY KEY (id),
	UNIQUE (name),
	UNIQUE (min_days)
);

INSERT INTO availability (id, name, min_days) VALUES
	(-1, 'in stock', 0),
	(-2, 'in stock by supplier', 1),
	(-3, 'usually in stock', 4),
	(-4, 'to order', 8),
	(-5, 'on request', 31);

CREATE TABLE product_line (
	id SERIAL,
	manufacturer_id INTEGER NOT NULL,
	name VARCHAR(64) NOT NULL,
	PRIMARY KEY (id),
	UNIQUE (name),
	FOREIGN KEY (manufacturer_id) REFERENCES manufacturer (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE measure (
	id SERIAL,
	name VARCHAR(64) NOT NULL,
	PRIMARY KEY (id),
	UNIQUE (name)
);

INSERT INTO measure (id, name) VALUES
	(-1, 'length'),
	(-2, 'mass'),
	(-3, 'time'),
	(-4, 'electric current'),
	(-5, 'thermodynamic temperature'),
	(-6, 'amount of substance'),
	(-7, 'luminous intensity');

CREATE TABLE unit (
	id SERIAL,
	name VARCHAR(64) NOT NULL,
	symbol VARCHAR(8) NOT NULL,
	measure_id INTEGER NOT NULL,
	unit_id INTEGER,
	ratio DECIMAL,
	PRIMARY KEY (id),
	UNIQUE (name),
	FOREIGN KEY (measure_id) REFERENCES measure (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (unit_id) REFERENCES unit (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

INSERT INTO unit (id, name, symbol, measure_id) VALUES
	(-1, 'metre', 'm', -1),
	(-2, 'gram', 'g', -2),
	(-3, 'second', 's', -3),
	(-4, 'ampere', 'A', -4),
	(-5, 'kelvin', 'K', -5),
	(-6, 'mole', 'mol', -6),
	(-7, 'candela', 'cd', -7);

CREATE TABLE unit_prefix (
	symbol VARCHAR(2) NOT NULL,
	name VARCHAR(5) NOT NULL,
	base INTEGER NOT NULL DEFAULT 10,
	exponent SMALLINT NOT NULL,
	PRIMARY KEY (symbol),
	UNIQUE (name),
	UNIQUE (exponent)
);

INSERT INTO unit_prefix (symbol, name, exponent) VALUES
	('Y', 'yotta', 24),
	('Z', 'zetta', 21),
	('E', 'exa', 18),
	('P', 'peta', 15),
	('T', 'tera', 12),
	('G', 'giga', 9),
	('M', 'mega', 6),
	('k', 'kilo', 3),
	('h', 'hecto', 2),
	('da', 'deca', 1),
	('d', 'deci', -1),
	('c', 'centi', -2),
	('m', 'milli', -3),
	('μ', 'micro', -6),
	('n', 'nano', -9),
	('p', 'pico', -12),
	('f', 'femto', -15),
	('a', 'atto', -18),
	('z', 'zepto', -21),
	('y', 'yocto', -24);
INSERT INTO unit_prefix (symbol, name, base, exponent) VALUES
	('Ki', 'kibi', 2, 10),
	('Mi', 'mebi', 2, 20),
	('Gi', 'gibi', 2, 30),
	('Ti', 'tebi', 2, 40),
	('Pi', 'pebi', 2, 50),
	('Ei', 'exbi', 2, 60),
	('Zi', 'zebi', 2, 70),
	('Yi', 'yobi', 2, 80);

CREATE TABLE measure_main_unit (
	measure_id INTEGER NOT NULL,
	unit_prefix VARCHAR(2),
	unit_id INTEGER,
	PRIMARY KEY (measure_id),
	UNIQUE (unit_id),
	FOREIGN KEY (measure_id) REFERENCES measure (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (unit_prefix) REFERENCES unit_prefix (symbol) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (unit_id) REFERENCES unit (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

INSERT INTO measure_main_unit (measure_id, unit_id) VALUES
	(-1, -1),
	(-3, -3),
	(-4, -4),
	(-5, -5),
	(-6, -6),
	(-7, -7);
INSERT INTO measure_main_unit (measure_id, unit_prefix, unit_id) VALUES
	(-2, 'k', -2);

CREATE TABLE image (
	id SERIAL,
	path VARCHAR(1024) COLLATE C NOT NULL, -- Base path, there shall be subdirectories with image variants, liek ${path}/300x200
	PRIMARY KEY (id),
	UNIQUE (path)
);

CREATE TABLE image_original (
	image_id INTEGER NOT NULL,
	url_scheme VARCHAR COLLATE C NOT NULL,
	url_authority VARCHAR COLLATE C NOT NULL,
	url_path VARCHAR COLLATE C NOT NULL,
	url_query VARCHAR COLLATE C,
	etag VARCHAR(64) COLLATE C,
	UNIQUE (url_scheme, url_authority, url_path, url_query),
	UNIQUE (etag, url_authority)
);

CREATE TABLE product (
	id SERIAL,
	uuid UUID NOT NULL, -- Usable for XML feeds
	name VARCHAR(150) NOT NULL,
	manufacturer_id INTEGER,
	manufacturer_product_no VARCHAR(64),
	product_line_id INTEGER,
	suplier_id INTEGER,
	tax_level_id INTEGER,
	unit_prefix VARCHAR(2),
	unit_id INTEGER, -- Specify unit if product isn't sold per pieces
	short_description VARCHAR(5000),
	description TEXT NOT NULL,
	price PRICE NOT NULL,
	PRIMARY KEY (id),
	UNIQUE (uuid),
	UNIQUE (name),
	UNIQUE (manufacturer_id, manufacturer_product_no),
	FOREIGN KEY (manufacturer_id) REFERENCES manufacturer (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (product_line_id) REFERENCES product_line (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (suplier_id) REFERENCES suplier (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (tax_level_id) REFERENCES tax_level (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (unit_prefix) REFERENCES unit_prefix (symbol) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (unit_id) REFERENCES unit (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE FUNCTION check_manufacturer_same() RETURNS trigger
	AS $$
		DECLARE
			product_line_manufacturer_id INTEGER;
		BEGIN
			IF NEW.manufacturer_id IS NULL THEN
				NEW.manufacturer_id := OLD.manufacturer_id;
			END IF;
			IF NEW.product_line_id IS NULL THEN
				NEW.product_line_id := OLD.product_line_id;
			END IF;
			IF NEW.product_line_id IS NOT NULL THEN
				SELECT manufacturer_id INTO product_line_manufacturer_id FROM product_line WHERE id = NEW.product_line_id;
				IF NEW.manufacturer_id != product_line_manufacturer_id THEN
					RAISE EXCEPTION 'Manufacturer_id and product_line.manufacturer_id is ambiguous.';
				END IF;
			END IF;
			RETURN NEW;
		END;
	$$ LANGUAGE plpgsql
	STABLE;

CREATE TRIGGER check_manufacturer_same_trigger
	BEFORE INSERT OR UPDATE OF manufacturer_id, product_line_id
	ON product
	FOR EACH ROW
	EXECUTE PROCEDURE check_manufacturer_same();


CREATE TABLE product_variant (
	id SERIAL,
	uuid UUID, -- Usable for XML feeds
	product_id INTEGER NOT NULL,
	name_suffix VARCHAR(32),
	main_image_id INTEGER,
	quantity DECIMAL,
	minimum_amount DECIMAL NOT NULL DEFAULT 1,
	availability AVAILABILITY_TYPE NOT NULL DEFAULT 'in stock',
	availability_date TIMESTAMP with time zone,
	available_in_days SMALLINT NOT NULL,
	condition CONDITION_TYPE NOT NULL DEFAULT 'new',
	active BOOLEAN,
	PRIMARY KEY (id),
	UNIQUE (product_id, name_suffix),
	UNIQUE (uuid),
	FOREIGN KEY (product_id) REFERENCES product (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (main_image_id) REFERENCES image (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE multipack (
	id SERIAL,
	uuid UUID, -- Usable for XML feeds
	product_variant_id INTEGER NOT NULL,
	main_image_id INTEGER,
	amount SMALLINT NOT NULL,
	price PRICE NOT NULL,
	PRIMARY KEY (id),
	UNIQUE (uuid),
	CONSTRAINT amount_multiple CHECK (amount > 1),
	FOREIGN KEY (product_variant_id) REFERENCES product_variant (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (main_image_id) REFERENCES image (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE bundle (
	id SERIAL,
	uuid UUID, -- Usable for XML feeds
	main_product_variant_id INTEGER NOT NULL,
	amount SMALLINT NOT NULL,
	price PRICE NOT NULL,
	PRIMARY KEY (id),
	UNIQUE (uuid),
	CONSTRAINT amount_positive CHECK (amount > 0),
	FOREIGN KEY (main_product_variant_id) REFERENCES product_variant (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE bundle_products (
	bundle_id INTEGER NOT NULL,
	product_variant_id INTEGER NOT NULL,
	amount SMALLINT NOT NULL,
	PRIMARY KEY (bundle_id, product_variant_id),
	CONSTRAINT amount_positive CHECK (amount > 0),
	FOREIGN KEY (bundle_id) REFERENCES bundle (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (product_variant_id) REFERENCES product_variant (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE product_sale (
	product_id INTEGER NOT NULL,
	active_from TIMESTAMP with time zone NOT NULL,
	active_until TIMESTAMP with time zone,
	price PRICE NOT NULL,
	PRIMARY KEY (product_id, active_from),
	CONSTRAINT from_lower_than_until CHECK (active_until IS NULL OR active_from < active_until),
	FOREIGN KEY (product_id) REFERENCES product (id) ON DELETE RESTRICT ON UPDATE CASCADE
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

CREATE TABLE product_base_unit_amount (
	product_id INTEGER NOT NULL,
	amount DECIMAL NOT NULL,
	unit_prefix VARCHAR(2),
	unit_id INTEGER NOT NULL,
	PRIMARY KEY (product_id),
	FOREIGN KEY (product_id) REFERENCES product (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (unit_prefix) REFERENCES unit_prefix (symbol) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (unit_id) REFERENCES unit (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE parameter (
	id SERIAL,
	name VARCHAR(64) NOT NULL,
	type PARAMETER_TYPE, -- Hint for inserting known parameter with correct type
	PRIMARY KEY (id),
	UNIQUE (name)
);

INSERT INTO parameter (id, name, type) VALUES
	(-1, 'width', 'numeric'),
	(-2, 'height', 'numeric'),
	(-3, 'depth', 'numeric'),
	(-4, 'weight', 'numeric'),
	(-5, 'color', 'textual'),
	(-6, 'gender', 'enum'),
	(-7, 'adult', 'bool');

CREATE TABLE parameter_measure (
	parameter_id INTEGER NOT NULL,
	measure_id INTEGER, -- Hint for inserting known parameter with correct unit
	PRIMARY KEY (parameter_id),
	FOREIGN KEY (parameter_id) REFERENCES parameter (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (measure_id) REFERENCES measure (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

INSERT INTO parameter_measure (parameter_id, measure_id) VALUES
	(-1, -1),
	(-2, -1),
	(-3, -1),
	(-4, -2);

CREATE TABLE parameter_enum (
	id SERIAL,
	parameter_id INTEGER NOT NULL,
	value VARCHAR(64) NOT NULL,
	PRIMARY KEY (id),
	UNIQUE (parameter_id, value),
	FOREIGN KEY (parameter_id) REFERENCES parameter (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

INSERT INTO parameter_enum (id, parameter_id, value) VALUES
	(-1, -6, 'male'),
	(-2, -6, 'female'),
	(-3, -6, 'unisex');

CREATE TABLE product_parameter_bool (
	product_id INTEGER NOT NULL,
	parameter_id INTEGER NOT NULL,
	value BOOLEAN, -- NULL represents "maybe" (indecisive answer)
	PRIMARY KEY (product_id, parameter_id),
	FOREIGN KEY (product_id) REFERENCES product (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (parameter_id) REFERENCES parameter (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE product_parameter_enum (
	product_id INTEGER NOT NULL,
	parameter_id INTEGER NOT NULL,
	parameter_enum_id INTEGER NOT NULL,
	PRIMARY KEY (product_id, parameter_id),
	FOREIGN KEY (product_id) REFERENCES product (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (parameter_id) REFERENCES parameter (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (parameter_enum_id) REFERENCES parameter_enum (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE product_parameter_numeric (
	product_id INTEGER NOT NULL,
	parameter_id INTEGER NOT NULL,
	value DECIMAL(12, 6) NOT NULL,
	unit_prefix VARCHAR(2),
	unit_id INTEGER,
	PRIMARY KEY (product_id, parameter_id, value),
	FOREIGN KEY (product_id) REFERENCES product (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (parameter_id) REFERENCES parameter (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (unit_prefix) REFERENCES unit_prefix (symbol) ON DELETE RESTRICT ON UPDATE CASCADE,
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

REASSIGN OWNED BY archbishop TO reader;
