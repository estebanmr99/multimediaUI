INSERT INTO tbl_categoria
VALUES (UUID('e8842cd3-c6e6-4f3e-ae59-23c35b37b25a'), 'Cama'),
	   (UUID('df451352-973f-4fc4-a552-3e4b53ab2b23'), 'Mesa'),
	   (UUID('793b099c-13c3-47e3-ac4c-9e5e8fd44530'), 'Silla'),
	   (UUID('2e4ea75f-d00b-4f3b-9320-4630fa4ec825'), 'Sillon'),
	   (UUID('54aba1ff-f002-43d5-a4e8-29ec31ad638e'), 'Escritorio'),
	   (UUID('0244dad4-f72b-47f1-8870-f2901ce3b530'), 'Estante');

INSERT INTO tbl_caracteristica
VALUES (UUID('1d6f2571-c3e3-4bf0-81d6-c45fcca3c51a'), 'Madera'),
		(UUID('043981c2-e00b-438f-9ed5-bf58d14df486'), 'Vidrio'),
		(UUID('b47b5c78-97a7-4fc7-aee5-9cc2845c228c'), 'Pequeño'),
		(UUID('f7d78772-559e-4b08-af91-42d85e15aefa'), 'Grande'),
		(UUID('65ccac6e-006c-47d3-8ac6-2035e3fe1fc2'), 'Mediano'),
		(UUID('81b43be8-727c-4036-83bb-8ca56ea45924'), 'Metal'),
		(UUID('d47bba50-6199-49e2-abd7-e5829a1f1b00'), 'Para 2 personas'),
		(UUID('d10a70db-a326-47f1-ab25-880f36d2416f'), 'Para 4 persona'),
		(UUID('acf8ba25-3255-40c6-83bf-b4c12d27fcef'), 'Individual');

INSERT INTO tbl_cuidado
VALUES (UUID('d6cb50ec-c281-486c-95e6-f6297fb030bb'), 'Limpiar con agua'),
		(UUID('d5b106c2-4311-496b-87bc-19bc3e04a1a6'), 'Limpiar con tela de microfibra'),
		(UUID('d17e51aa-9ec8-42fc-8983-7f57314961f3'), 'Mantener alejado del sol'),
		(UUID('daaa9aaa-ec5e-4428-95cb-f6392b0e7fe6'), 'No mojar con agua'),
		(UUID('902dc493-6e48-40a2-a74e-0a3be132356f'), 'No apoyar recipientes calientes'),
		(UUID('eb9a1d6e-49d9-4d6c-98e8-a0ac5a882e73'), 'Usar productos libres de amoniaco'),
		(UUID('ce058495-1e02-448c-81ef-9cbc98663833'), 'Retirar de inmediato cualquier mancha'),
		(UUID('3713052a-643a-4b40-a2c2-e55cd17700b1'), 'Limpiar todo los dias'),
		(UUID('bd215c7c-bb23-4303-a7f5-e4a13cde01f8'), 'Usar productos para limpiar cuero');

select * from prc_crear_producto('Test', 1550, 'dGVzdA==', 10);