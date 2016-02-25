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

INSERT INTO product (id, uuid, name, manufacturer_id, manufacturer_product_no, product_line_id, suplier_id, tax_level_id, unit_prefix, unit_id, short_description, description) VALUES
	(-1, '12345678-1234-1234-1234-1234567890ab', 'Adidas Superstar 2 W', -1, 'G43755', NULL, -1, -1, NULL, NULL, 'V rámci kolekce Originals uvádí adidas sportovní obuv The Superstar, která je již od svého vzniku jedničkou mezi obuví.', 'V rámci kolekce Originals uvádí adidas sportovní obuv The Superstar, která je již od svého vzniku jedničkou mezi obuví. Jejím poznávacím znamením je mimo jiné detaily designové zakončení špičky. Díky kvalitnímu materiálu a trendy vzhledu, podtrženého logy Adidas uvnitř boty i na ní, bude hvězdou vašeho botníku.'),
	(-2, '87654321-4321-4321-4321-ba0987654321', 'Apple iPod Touch (5. gen.)', -2, 'oerjn641ern', -1, -2, -4, 'da', -2, 'Supr, čupr.', 'Bomba plomba'),
	(-3, '88888888-7777-6666-5555-000000000000', 'Apple i-nabíječka', -2, NULL, NULL, NULL, -2, 'm', -1, 'Nabíječka USB 230V', 'Nabíječka do zásuvky 230V -> microUSB.');

INSERT INTO product_measure_by_unit_amount (product_id, amount, unit_prefix, unit_id) VALUES
	(-1, 10, 'da', -2);

INSERT INTO product_variant (id, uuid, product_id, name_suffix, quantity, minimum_amount, availability, availability_date, available_in_days, condition, price, active) VALUES
	(-1, '12345678-1234-1234-1234-000000000001', -1, 'EUR 36', 3, 1, 'in stock', NULL, 2, 'new', 1234.56, TRUE),
	(-2, '12345678-1234-1234-1234-000000000002', -1, 'EUR 37', 0, 2, 'preorder', NULL, 2, 'refurbished', 1234.56, FALSE),
	(-3, '87654321-4321-4321-4321-000000000001', -2, '16GB - Space Gray', 0, 1, 'out of stock', NULL, NULL, 'used', 299.99, TRUE),
	(-4, '87654321-4321-4321-4321-000000000002', -2, '32GB Pink', 56, 1, 'in stock', NULL, 5, 'new', 349, TRUE),
	(-5, '87654321-4321-4321-4321-000000000003', -2, '64GB Blue', 4, 1, 'preorder', '2016-05-11', NULL, 'new', 399, TRUE),
	(-6, '88888888-7777-6666-5555-000000000001', -3, NULL, 1234, 1, DEFAULT, NULL, 9, DEFAULT, 17, TRUE);

INSERT INTO product_variant_main_image (product_variant_id, image_id) VALUES
	(-1, -1),
	(-2, -1),
	(-3, -3),
	(-4, -4),
	(-5, -5);

INSERT INTO product_variant_image (product_variant_id, image_id) VALUES
	(-1, -2),
	(-2, -2);

INSERT INTO multipack (id, uuid, product_variant_id, amount, price) VALUES
	(-1, '11111111-2222-3333-4444-000000000000', -4, 3, 999);

INSERT INTO multipack_main_image (multipack_id, image_id) VALUES
	(-1, -4);

INSERT INTO bundle (id, uuid, main_product_variant_id, amount, price) VALUES
	(-1, '11111111-2222-3333-4444-000000000001', -4, 1, 649);

INSERT INTO bundle_main_image (bundle_id, image_id) VALUES
	(-1, -4);

INSERT INTO bundle_products (bundle_id, product_variant_id) VALUES
	(-1, -6);

INSERT INTO product_sale (product_variant_id, active_from, active_until, price) VALUES
	(-1, '2016-04-22', '2016-07-22', 987.65);

INSERT INTO product_accessory (product_id, accessory_product_id) VALUES
	(-2, -3);

INSERT INTO product_parameter_bool (product_variant_id, parameter_id, value) VALUES
	(-1, -7, TRUE),
	(-2, -7, NULL);

INSERT INTO product_parameter_enum (product_variant_id, parameter_id, parameter_enum_id) VALUES
	(-1, -6, -1),
	(-3, -6, -3);

INSERT INTO parameter (id, name, type) VALUES
	(-8, 'storage capacity', 'numeric');

INSERT INTO product_parameter_numeric (product_variant_id, parameter_id, value, unit_prefix, unit_id, unit) VALUES
	(-3, -1, 10, 'c', -1, NULL),
	(-3, -2, 20, 'c', -1, NULL),
	(-3, -3, 1, 'c', -1, NULL),
	(-3, -4, 1.234, 'k', -2, NULL),
	(-3, -8, 16, NULL, NULL, 'GB');

INSERT INTO product_parameter_textual (product_variant_id, parameter_id, value) VALUES
	(-3, -5, 'Space Grey');
