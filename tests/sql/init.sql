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

INSERT INTO manufacturer (id, name) VALUES
	(-1, 'Adidas'),
	(-2, 'Apple');

INSERT INTO availability (id, name, min_days) VALUES
	(-1, 'in stock', 0),
	(-2, 'in stock by supplier', 1),
	(-3, 'usually in stock', 4),
	(-4, 'to order', 8),
	(-5, 'on request', 31);
