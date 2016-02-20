INSERT INTO tax_level (id, name) VALUES
	(-1, 'základní'),
	(-2, 'osvobozeno'),
	(-3, 'snížená'),
	(-4, 'snížená první'),
	(-5, 'snížená druhá');

INSERT INTO tax (tax_level_id, active_from, active_until, percentage) VALUES
	(-1, NULL, '2004-04-30', 22),
	(-1, NULL, '2009-12-31', 19),
	(-1, NULL, '2012-12-31', 20),
	(-1, NULL, NULL, 21),
	(-2, NULL, NULL, 0),
	(-3, NULL, '2007-12-31', 5),
	(-3, NULL, '2009-12-31', 9),
	(-3, NULL, '2011-12-31', 10),
	(-3, NULL, '2012-12-31', 14),
	(-3, NULL, '2014-12-31', 15),
	(-4, '2015-01-01', NULL, 15),
	(-5, '2015-01-01', NULL, 10);

INSERT INTO measure (id, name) VALUES
	(-1, 'length'),
	(-2, 'mass'),
	(-3, 'time'),
	(-4, 'electric current'),
	(-5, 'thermodynamic temperature'),
	(-6, 'amount of substance'),
	(-7, 'luminous intensity');

INSERT INTO unit (id, name, symbol, measure_id) VALUES
	(-1, 'metre', 'm', -1),
	(-2, 'gram', 'g', -2),
	(-3, 'second', 's', -3),
	(-4, 'ampere', 'A', -4),
	(-5, 'kelvin', 'K', -5),
	(-6, 'mole', 'mol', -6),
	(-7, 'candela', 'cd', -7);
INSERT INTO unit (id, name, symbol, measure_id, ratio, unit_id) VALUES
	(-8, 'kilogram', 'kg', -2, 1000, -2);

INSERT INTO measure_main_unit (measure_id, unit_id) VALUES
	(-1, -1),
	(-2, -8),
	(-3, -3),
	(-4, -4),
	(-5, -5),
	(-6, -6),
	(-7, -7);

INSERT INTO parameter (id, name, type) VALUES
	(-1, 'width', 'numeric'),
	(-2, 'height', 'numeric'),
	(-3, 'depth', 'numeric'),
	(-4, 'weight', 'numeric')
