INSERT INTO manufacturer (id, name) VALUES
	(-1, 'Adidas'),
	(-2, 'Apple');

INSERT INTO product_line (id, manufacturer_id, name) VALUES
	(-1, -2, 'iPod | iPod Touch');

INSERT INTO suplier (id, name) VALUES
	(-1, 'Boty.cz'),
	(-2, 'iTec');

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

INSERT INTO image (id, path) VALUES
	(-1, '403078.jpg'),
	(-2, '403080.jpg'),
	(-3, '16gb-space-gray.jpg'),
	(-4, '32gb-pink.jpg'),
	(-5, '64gb-blue.jpg');

INSERT INTO image_original (image_id, url_scheme, url_authority, url_path, url_query, etag) VALUES
	(-1, 'http', 'www.obchod-s-obuvi.cz', '/pictures/403078.jpg', NULL, '1234567890-abcdef'),
	(-2, 'http', 'www.obchod-s-obuvi.cz', '/pictures/403080.jpg', NULL, '1234567890abcdef'),
	(-3, 'http', 'www.obchod-s-obuvi.cz', '/pictures/403080.jpg', NULL, '1234567890ABCDEF'); -- Etag is probably case sensitive, it depends on implementation

INSERT INTO product (id, uuid, name, manufacturer_id, manufacturer_product_no, product_line_id, suplier_id, tax_level_id, unit_prefix, unit_id, short_description, description, price) VALUES
	(-1, '12345678-1234-1234-1234-1234567890ab', 'Adidas Superstar 2 W', -1, 'G43755', NULL, -1, -1, NULL, NULL, 'V rámci kolekce Originals uvádí adidas sportovní obuv The Superstar, která je již od svého vzniku jedničkou mezi obuví.', 'V rámci kolekce Originals uvádí adidas sportovní obuv The Superstar, která je již od svého vzniku jedničkou mezi obuví. Jejím poznávacím znamením je mimo jiné detaily designové zakončení špičky. Díky kvalitnímu materiálu a trendy vzhledu, podtrženého logy Adidas uvnitř boty i na ní, bude hvězdou vašeho botníku.', 1234.56),
	(-2, '87654321-4321-4321-4321-ba0987654321', 'Apple iPod Touch (5. gen.)', -2, 'oerjn641ern', -1, -2, -4, 'da', -2, 'Supr, čupr.', 'Bomba plomba', 321.99);
