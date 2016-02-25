CREATE COLLATION C (locale='C');
CREATE DOMAIN price AS MONEY CONSTRAINT positive_price CHECK (VALUE >= 0::money);
CREATE DOMAIN tax_rate AS DECIMAL(7,5) CONSTRAINT positive_percentage CHECK (VALUE >= 0);
CREATE TYPE availability_type AS ENUM ('preorder', 'in stock', 'out of stock');
CREATE TYPE condition_type AS ENUM ('new', 'refurbished', 'used');
CREATE TYPE parameter_type AS ENUM ('bool', 'enum', 'numeric', 'textual');
CREATE TYPE url_scheme_type AS ENUM ('ftp', 'http', 'https');


CREATE TABLE manufacturer (
	id SERIAL,
	name VARCHAR(64) NOT NULL,
	PRIMARY KEY (id),
	UNIQUE (name)
);

CREATE TABLE product_line (
	id SERIAL,
	manufacturer_id INTEGER NOT NULL,
	name VARCHAR(64) NOT NULL,
	PRIMARY KEY (id),
	UNIQUE (name),
	FOREIGN KEY (manufacturer_id) REFERENCES manufacturer (id) ON DELETE RESTRICT ON UPDATE CASCADE
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

CREATE TABLE measure (
	id SERIAL,
	name VARCHAR(64) NOT NULL,
	group_measure_id INTEGER,
	PRIMARY KEY (id),
	UNIQUE (name),
	CONSTRAINT check_group CHECK (group_measure_id IS NULL OR ABS(id) > ABS(group_measure_id)),
	FOREIGN KEY (group_measure_id) REFERENCES measure (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

INSERT INTO measure (id, name) VALUES
	(-1, 'length'),
	(-2, 'mass'),
	(-3, 'time'),
	(-4, 'electric current'),
	(-5, 'thermodynamic temperature'),
	(-6, 'amount of substance'),
	(-7, 'luminous intensity'),
	(-8, 'angle'),
	(-9, 'solid angle'),
	(-10, 'frequency'),
	(-11, 'force'),
	(-13, 'pressure'),
	(-15, 'energy'),
	(-18, 'power'),
	(-20, 'electric charge'),
	(-22, 'voltage'),
	(-25, 'electric capacitance'),
	(-26, 'electric resistance'),
	(-29, 'electrical conductance'),
	(-30, 'magnetic flux'),
	(-31, 'magnetic field strength'),
	(-32, 'inductance'),
	(-33, 'temperature'),
	(-34, 'luminous flux'),
	(-35, 'illuminance'),
	(-36, 'radioactivity'),
	(-37, 'absorbed dose'),
	(-38, 'equivalent dose'),
	(-39, 'catalytic activity'),
	(-40, 'area'),
	(-41, 'volume'),
	(-42, 'level'),
	(-43, 'information');
INSERT INTO measure (id, name, group_measure_id) VALUES
	(-12, 'weight', -11),
	(-14, 'stress', -13),
	(-16, 'work', -15),
	(-17, 'heat', -15),
	(-19, 'radiant flux', -18),
	(-21, 'quantity of electricity', -20),
	(-23, 'electrical potential difference', -22),
	(-24, 'electromotive force', -22),
	(-27, 'impedance', -26),
	(-28, 'reactance', -26);

CREATE TABLE unit (
	id SERIAL,
	name VARCHAR(64) NOT NULL,
	symbol VARCHAR(8) NOT NULL,
	measure_id INTEGER,
	ratio DECIMAL NOT NULL DEFAULT 1,
	unit_id INTEGER,
	PRIMARY KEY (id),
	UNIQUE (name),
	CONSTRAINT check_measure_xor_unit CHECK (measure_id IS NULL != unit_id IS NULL),
	FOREIGN KEY (measure_id) REFERENCES measure (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE FUNCTION check_unit_measure_group() RETURNS trigger
	AS $$
		DECLARE
			main_measure_id INTEGER;
		BEGIN
			IF NEW.measure_id IS NOT NULL THEN
				SELECT group_measure_id INTO main_measure_id FROM measure WHERE id = NEW.measure_id;
				IF main_measure_id IS NOT NULL AND NEW.measure_id != main_measure_id THEN
					RAISE EXCEPTION 'Unit measure_id must match measure.group_measure_id.';
				END IF;
			END IF;
			RETURN NEW;
		END;
	$$ LANGUAGE plpgsql
	STABLE;

CREATE TRIGGER check_unit_measure_group_trigger
	BEFORE INSERT OR UPDATE OF measure_id
	ON unit
	FOR EACH ROW
	EXECUTE PROCEDURE check_unit_measure_group();

INSERT INTO unit (id, name, symbol, measure_id) VALUES
	(-1, 'metre', 'm', -1),
	(-2, 'gram', 'g', -2),
	(-3, 'second', 's', -3),
	(-4, 'ampere', 'A', -4),
	(-5, 'kelvin', 'K', -5),
	(-6, 'mole', 'mol', -6),
	(-7, 'candela', 'cd', -7),
	(-8, 'radian', 'rad', -8),
	(-9, 'steradian', 'sr', -9),
	(-10, 'hertz', 'Hz', -10),
	(-11, 'newton', 'N', -11),
	(-12, 'pascal', 'Pa', -13),
	(-13, 'joule', 'J', -15),
	(-14, 'watt', 'W', -18),
	(-15, 'coulomb', 'C', -20),
	(-16, 'volt', 'V', -22),
	(-17, 'farad', 'F', -25),
	(-18, 'ohm', 'Ω', -26),
	(-19, 'siemens', 'S', -29),
	(-20, 'weber', 'Wb', -30),
	(-21, 'tesla', 'T', -31),
	(-22, 'henry', 'H', -32),
	(-23, 'degree Celsius', '°C', -33),
	(-24, 'lumen', 'lm', -34),
	(-25, 'lux', 'lx', -35),
	(-26, 'becquerel', 'Bq', -36),
	(-27, 'gray', 'Gy', -37),
	(-28, 'sievert', 'Sv', -38),
	(-29, 'katal', 'kat', -39),
	(-31, 'square metre', 'm²', -40),
	(-34, 'cubic metre', 'm³', -41),
	(-43, 'bel', 'B', -42),
	(-46, 'bit', 'b', -43);
INSERT INTO unit (id, name, symbol, ratio, unit_id) VALUES
	(-30, 'tonne', 't', 1e6, -2),
	(-32, 'are', 'a', 100, -31),
	(-33, 'hectare', 'ha', 100, -32),
	(-35, 'litre', 'l', 0.001, -34),
	(-36, 'minute', 'min', 60, -3),
	(-37, 'hour', 'h', 60, -36),
	(-38, 'day', 'd', 24, -37),
	(-39, 'second of arc', '″', 0.0000048481368, -8),
	(-40, 'minute of arc', '′', 60, -39),
	(-41, 'degree of arc', '°', 60, -40),
	(-42, 'astronomical unit', 'au', 149597870700, -1),
	(-44, 'bar', 'bar', 100000, -12),
	(-45, 'ångström', 'Å', 0.0000000001, -1),
	(-47, 'byte', 'B', 8, -46);

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
	(-2, 'k', -2),
	(-42, 'd', -43);

CREATE TABLE image (
	id SERIAL,
	path VARCHAR(1024) COLLATE C NOT NULL, -- Base path, there shall be subdirectories with image variants, liek ${path}/300x200
	PRIMARY KEY (id),
	UNIQUE (path)
);

CREATE TABLE image_original (
	image_id INTEGER NOT NULL,
	url_scheme URL_SCHEME_TYPE NOT NULL,
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
			IF TG_OP = 'UPDATE' THEN
				IF NEW.manufacturer_id IS NULL THEN
					NEW.manufacturer_id := OLD.manufacturer_id;
				END IF;
				IF NEW.product_line_id IS NULL THEN
					NEW.product_line_id := OLD.product_line_id;
				END IF;
			END IF;
			IF NEW.product_line_id IS NOT NULL THEN
				SELECT manufacturer_id INTO product_line_manufacturer_id FROM product_line WHERE id = NEW.product_line_id;
				IF NEW.manufacturer_id != product_line_manufacturer_id THEN
					RAISE EXCEPTION 'Manufacturer_id and product_line.manufacturer_id is not same.';
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

CREATE TABLE product_measure_by_unit_amount (
	product_id INTEGER NOT NULL,
	amount DECIMAL NOT NULL,
	unit_prefix VARCHAR(2),
	unit_id INTEGER NOT NULL,
	PRIMARY KEY (product_id),
	FOREIGN KEY (product_id) REFERENCES product (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (unit_prefix) REFERENCES unit_prefix (symbol) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (unit_id) REFERENCES unit (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE product_variant (
	id SERIAL,
	uuid UUID, -- Usable for XML feeds
	product_id INTEGER NOT NULL,
	name_suffix VARCHAR(32),
	quantity DECIMAL,
	minimum_amount DECIMAL NOT NULL DEFAULT 1,
	availability AVAILABILITY_TYPE NOT NULL DEFAULT 'in stock',
	availability_date TIMESTAMP with time zone,
	available_in_days SMALLINT,
	condition CONDITION_TYPE NOT NULL DEFAULT 'new',
	price PRICE NOT NULL,
	active BOOLEAN NOT NULL,
	PRIMARY KEY (id),
	UNIQUE (product_id, name_suffix),
	UNIQUE (uuid),
	CONSTRAINT check_availability CHECK (availability != 'in stock' OR available_in_days IS NOT NULL),
	FOREIGN KEY (product_id) REFERENCES product (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE product_variant_image (
	product_variant_id INTEGER NOT NULL,
	image_id INTEGER NOT NULL,
	PRIMARY KEY (product_variant_id, image_id),
	FOREIGN KEY (product_variant_id) REFERENCES product_variant (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (image_id) REFERENCES image (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE product_variant_main_image (
	is_main BOOLEAN DEFAULT TRUE,
	PRIMARY KEY (product_variant_id),
	CONSTRAINT check_is_main CHECK (is_main)
) INHERITS (product_variant_image);

CREATE TABLE multipack (
	id SERIAL,
	uuid UUID, -- Usable for XML feeds
	product_variant_id INTEGER NOT NULL,
	amount SMALLINT NOT NULL,
	price PRICE NOT NULL,
	PRIMARY KEY (id),
	UNIQUE (uuid),
	CONSTRAINT amount_multiple CHECK (amount > 1),
	FOREIGN KEY (product_variant_id) REFERENCES product_variant (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE multipack_image (
	multipack_id INTEGER NOT NULL,
	image_id INTEGER NOT NULL,
	PRIMARY KEY (multipack_id, image_id),
	FOREIGN KEY (multipack_id) REFERENCES multipack (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (image_id) REFERENCES image (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE multipack_main_image (
	is_main BOOLEAN DEFAULT TRUE,
	PRIMARY KEY (multipack_id),
	CONSTRAINT check_is_main CHECK (is_main)
) INHERITS (multipack_image);

CREATE TABLE bundle (
	id SERIAL,
	uuid UUID, -- Usable for XML feeds
	main_product_variant_id INTEGER NOT NULL,
	amount SMALLINT NOT NULL DEFAULT 1,
	price PRICE NOT NULL,
	PRIMARY KEY (id),
	UNIQUE (uuid),
	CONSTRAINT amount_positive CHECK (amount > 0),
	FOREIGN KEY (main_product_variant_id) REFERENCES product_variant (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE bundle_image (
	bundle_id INTEGER NOT NULL,
	image_id INTEGER NOT NULL,
	PRIMARY KEY (bundle_id, image_id),
	FOREIGN KEY (bundle_id) REFERENCES bundle (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (image_id) REFERENCES image (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE bundle_main_image (
	is_main BOOLEAN DEFAULT TRUE,
	PRIMARY KEY (bundle_id),
	CONSTRAINT check_is_main CHECK (is_main)
) INHERITS (bundle_image);

CREATE TABLE bundle_products (
	bundle_id INTEGER NOT NULL,
	product_variant_id INTEGER NOT NULL,
	amount SMALLINT NOT NULL DEFAULT 1,
	is_gift BOOLEAN NOT NULL DEFAULT FALSE,
	PRIMARY KEY (bundle_id, product_variant_id),
	CONSTRAINT amount_positive CHECK (amount > 0),
	FOREIGN KEY (bundle_id) REFERENCES bundle (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (product_variant_id) REFERENCES product_variant (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE product_sale (
	product_variant_id INTEGER NOT NULL,
	active_from TIMESTAMP with time zone NOT NULL,
	active_until TIMESTAMP with time zone,
	price PRICE NOT NULL,
	PRIMARY KEY (product_variant_id, active_from),
	CONSTRAINT from_lower_than_until CHECK (active_until IS NULL OR active_from < active_until),
	FOREIGN KEY (product_variant_id) REFERENCES product_variant (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE product_accessory (
	product_id INTEGER NOT NULL,
	accessory_product_id INTEGER NOT NULL,
	PRIMARY KEY (product_id, accessory_product_id),
	FOREIGN KEY (product_id) REFERENCES product (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (accessory_product_id) REFERENCES product (id) ON DELETE RESTRICT ON UPDATE CASCADE
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

CREATE TABLE parameter_measure ( -- Numerical parameters shall have measure
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
	product_variant_id INTEGER NOT NULL,
	parameter_id INTEGER NOT NULL,
	value BOOLEAN, -- NULL represents "maybe" (indecisive answer)
	PRIMARY KEY (product_variant_id, parameter_id),
	FOREIGN KEY (product_variant_id) REFERENCES product_variant (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (parameter_id) REFERENCES parameter (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE product_parameter_enum (
	product_variant_id INTEGER NOT NULL,
	parameter_id INTEGER NOT NULL,
	parameter_enum_id INTEGER NOT NULL,
	PRIMARY KEY (product_variant_id, parameter_id),
	FOREIGN KEY (product_variant_id) REFERENCES product_variant (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (parameter_id) REFERENCES parameter (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (parameter_enum_id) REFERENCES parameter_enum (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE product_parameter_numeric (
	product_variant_id INTEGER NOT NULL,
	parameter_id INTEGER NOT NULL,
	value DECIMAL(12, 6) NOT NULL,
	unit_prefix VARCHAR(2),
	unit_id INTEGER,
	unit VARCHAR(16),
	PRIMARY KEY (product_variant_id, parameter_id, value),
	CONSTRAINT check_known_units_used CHECK (unit_id IS NULL != unit IS NULL),
	FOREIGN KEY (product_variant_id) REFERENCES product_variant (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (parameter_id) REFERENCES parameter (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (unit_prefix) REFERENCES unit_prefix (symbol) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (unit_id) REFERENCES unit (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE product_parameter_textual (
	product_variant_id INTEGER NOT NULL,
	parameter_id INTEGER NOT NULL,
	value VARCHAR NOT NULL,
	PRIMARY KEY (product_variant_id, parameter_id, value),
	FOREIGN KEY (product_variant_id) REFERENCES product_variant (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (parameter_id) REFERENCES parameter (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

REASSIGN OWNED BY archbishop TO reader;
