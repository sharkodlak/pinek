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
	tax_level_id integer NOT NULL,
	active_until DATE DEFAULT NULL,
	percentage TAX_RATE NOT NULL,
	UNIQUE (tax_level_id, active_until),
	FOREIGN KEY (tax_level_id) REFERENCES tax_level (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE FUNCTION check_taxes_uniqueness() RETURNS trigger
AS $$
	DECLARE
		duplicates integer;
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

CREATE TABLE product (
	id SERIAL,
	manufacturer_id integer,
	suplier_id integer,
	tax_level_id integer NOT NULL,
	price PRICE NOT NULL,
	active BOOLEAN,
	PRIMARY KEY (id),
	FOREIGN KEY (manufacturer_id) REFERENCES manufacturer (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (suplier_id) REFERENCES suplier (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (tax_level_id) REFERENCES tax_level (id) ON DELETE RESTRICT ON UPDATE CASCADE
);


REASSIGN OWNED BY archbishop TO reader;
