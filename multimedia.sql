--CREATE EXTENSION pgcrypto;

CREATE TABLE tbl_user (
	id UUID PRIMARY KEY NOT null, 
	username VARCHAR(25) UNIQUE,
	email VARCHAR(50) UNIQUE,
	hash VARCHAR(150),
	created DATE NOT NULL,
	updated DATE,
	deleted DATE
);

CREATE TABLE tbl_producto (
    id UUID PRIMARY KEY NOT null,
    nombre VARCHAR(225),
    precio INT,
    imagen BYTEA,
    eliminado BOOLEAN
);

CREATE TABLE tbl_categoria (
    id UUID PRIMARY KEY NOT null, 
    nombre VARCHAR(225) UNIQUE
);

CREATE TABLE tbl_caracteristica (
    id UUID PRIMARY KEY NOT null, 
    nombre VARCHAR(225) UNIQUE
);

CREATE TABLE tbl_categoria_producto (
    id_producto UUID,
    id_categoria UUID,
        FOREIGN KEY (id_producto) 
            REFERENCES tbl_producto(id),
        FOREIGN KEY (id_categoria) 
            REFERENCES tbl_categoria(id)
);

CREATE TABLE tbl_caracteristica_producto (
    id_producto UUID,
    id_caracteristica UUID, 
        FOREIGN KEY (id_producto) 
            REFERENCES tbl_producto(id),
        FOREIGN KEY (id_caracteristica) 
            REFERENCES tbl_caracteristica(id)
);

CREATE TABLE tbl_cliente (
    id UUID PRIMARY KEY NOT null,
    nombre VARCHAR(225),
    numero VARCHAR(50),
    eliminado boolean
);

CREATE TABLE tbl_venta (
    id UUID PRIMARY KEY NOT null,
    id_cliente UUID,
    precio_total INT,
        FOREIGN KEY (id_cliente) 
            REFERENCES tbl_cliente(id)
);

CREATE TABLE tbl_venta_producto (
    id_producto UUID,
    id_venta UUID,
    cantidad INT,
        FOREIGN KEY (id_venta) 
            REFERENCES tbl_venta(id),
        FOREIGN KEY (id_producto) 
            REFERENCES tbl_producto(id)
);

CREATE TABLE tbl_cuidado (
    id UUID PRIMARY KEY NOT null,
    descripcion VARCHAR(500)
);

CREATE TABLE tbl_cuidado_producto (
    id_producto UUID,
    id_cuidado UUID,
    cantidad INT,
        FOREIGN KEY (id_cuidado) 
            REFERENCES tbl_cuidado(id),
        FOREIGN KEY (id_producto) 
            REFERENCES tbl_producto(id)
);

CREATE TABLE tbl_inventario (
    id_producto UUID,
    cantidad INT,
        FOREIGN KEY (id_producto) 
            REFERENCES tbl_producto(id)
);


------------------------------------------------------------------------------------------------------------------------------------------------------

--- Todos los SPs tienen un ejemplo de como se deben de correr, para correrlos primero ingresar los datos en la tablas con el otro script adjunto

CREATE OR REPLACE FUNCTION prc_crear_producto(_nombre TEXT, _precio INT, _imagen TEXT, _cantidad INT)
    RETURNS TABLE (ID UUID, nombre varchar(225), precio INT, imagen TEXT, cantidad INT) AS
    $$
    DECLARE 
    	_id_producto UUID = gen_random_uuid();

        BEGIN
            INSERT INTO tbl_producto
            VALUES (_id_producto, _nombre, _precio, decode(_imagen, 'base64'), false);

            INSERT INTO tbl_inventario
            VALUES (_id_producto, _cantidad);

            RETURN QUERY
                SELECT P.id, P.nombre, P.precio, encode(P.imagen::BYTEA, 'base64'), _cantidad
                FROM tbl_producto as P
                WHERE P.id = _id_producto;
            
            EXCEPTION 
                WHEN OTHERS THEN 
                    RAISE EXCEPTION 'Error, producto no creado';
        END;
    $$
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION prc_actualizar_producto(_id_producto TEXT, _nombre TEXT, _precio INT, _imagen TEXT, _cantidad INT)
    RETURNS TABLE (ID UUID, nombre varchar(225), precio INT, imagen TEXT, cantidad INT) AS
    $$
    DECLARE 

        BEGIN

            UPDATE tbl_producto AS p
            SET nombre = _nombre, precio = _precio, imagen = decode(_imagen, 'base64')
            WHERE p.id = UUID(_id_producto);

            UPDATE tbl_inventario AS i
            SET cantidad = _cantidad
            WHERE i.id_producto = UUID(_id_producto);

            RETURN QUERY
                SELECT P.id, P.nombre, P.precio, encode(P.imagen::BYTEA, 'base64'), _cantidad
                FROM tbl_producto as P
                WHERE P.id = UUID(_id_producto);

            EXCEPTION 
                WHEN OTHERS THEN 
                    RAISE EXCEPTION 'Error, producto no actualizado';
        END;
    $$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION prc_agregar_categoria_producto(_id_productos TEXT, _categorias TEXT)
    RETURNS VOID AS
    $$
    DECLARE 
        id_categorias TEXT[] = string_to_array(_categorias,';');
        id_productos TEXT[] = string_to_array(_id_productos,';');
        producto TEXT;
        categoria TEXT;

        BEGIN
            IF array_length(id_categorias, 1) > 0 THEN
                FOREACH categoria IN ARRAY id_categorias LOOP
                    IF array_length(id_productos, 1) > 0 THEN
                        FOREACH producto IN ARRAY id_productos LOOP
                        	IF NOT EXISTS(SELECT 1 FROM tbl_categoria_producto WHERE id_producto = UUID(producto) AND id_categoria = UUID(categoria)) THEN
                                INSERT INTO tbl_categoria_producto
                                VALUES (UUID(producto), UUID(categoria));
                                raise notice 'categoria: %', categoria;
                            END IF;
                        END LOOP;
                    END IF;
                END LOOP;
            END IF;

            EXCEPTION 
                WHEN OTHERS THEN 
                    RAISE EXCEPTION 'Error, categorias no agregadas';
        END;
    $$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION prc_eliminar_categoria_producto(_id_productos TEXT, _categorias TEXT)
    RETURNS VOID AS
    $$
    DECLARE 
        id_categorias TEXT[] = string_to_array(_categorias,';');
        id_productos TEXT[] = string_to_array(_id_productos,';');
        producto TEXT;
        categoria TEXT;

        BEGIN
            IF array_length(id_categorias, 1) > 0 THEN
                FOREACH categoria IN ARRAY id_categorias LOOP
                    IF array_length(id_productos, 1) > 0 THEN
                        FOREACH producto IN ARRAY id_productos LOOP
                        	IF EXISTS(SELECT 1 FROM tbl_categoria_producto WHERE id_producto = UUID(producto) AND id_categoria = UUID(categoria)) THEN
                                DELETE FROM tbl_categoria_producto
                                WHERE id_producto = UUID(producto) AND id_categoria = UUID(categoria);
                                raise notice 'categoria: %', categoria;
                            END IF;
                        END LOOP;
                    END IF;
                END LOOP;
            END IF;

            EXCEPTION 
                WHEN OTHERS THEN 
                    RAISE EXCEPTION 'Error, categorias no eliminadas';
        END;
    $$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION prc_agregar_caracteristica_producto(_id_productos TEXT, _caracteristicas TEXT)
    RETURNS VOID AS
    $$
    DECLARE 
        id_caracteristicas TEXT[] = string_to_array(_caracteristicas,';');
        id_productos TEXT[] = string_to_array(_id_productos,';');
        producto TEXT;
        caracteristica TEXT;

        BEGIN
            IF array_length(id_caracteristicas, 1) > 0 THEN
                FOREACH caracteristica IN ARRAY id_caracteristicas LOOP
                    IF array_length(id_productos, 1) > 0 THEN
                        FOREACH producto IN ARRAY id_productos LOOP
                        	IF NOT EXISTS(SELECT 1 FROM tbl_caracteristica_producto WHERE id_producto = UUID(producto) AND id_caracteristica = UUID(caracteristica)) THEN
                                INSERT INTO tbl_caracteristica_producto
                                VALUES (UUID(producto), UUID(caracteristica));
                                raise notice 'caracteristica: %', caracteristica;
                            END IF;
                        END LOOP;
                    END IF;
                END LOOP;
            END IF;

            EXCEPTION 
                WHEN OTHERS THEN 
                    RAISE EXCEPTION 'Error, caracteristicas no agregadas';
        END;
    $$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION prc_eliminar_caracteristica_producto(_id_productos TEXT, _caracteristicas TEXT)
    RETURNS VOID AS
    $$
    DECLARE 
        id_caracteristicas TEXT[] = string_to_array(_caracteristicas,';');
        id_productos TEXT[] = string_to_array(_id_productos,';');
        producto TEXT;
        caracteristica TEXT;

        BEGIN
            IF array_length(id_caracteristicas, 1) > 0 THEN
                FOREACH caracteristica IN ARRAY id_caracteristicas LOOP
                    IF array_length(id_productos, 1) > 0 THEN
                        FOREACH producto IN ARRAY id_productos LOOP
                        	IF EXISTS(SELECT 1 FROM tbl_caracteristica_producto WHERE id_producto = UUID(producto) AND id_caracteristica = UUID(caracteristica)) THEN
                                DELETE FROM tbl_caracteristica_producto
                                WHERE id_producto = UUID(producto) AND id_caracteristica = UUID(caracteristica);
                                raise notice 'caracteristica: %', caracteristica;
                            END IF;
                        END LOOP;
                    END IF;
                END LOOP;
            END IF;

            EXCEPTION 
                WHEN OTHERS THEN 
                    RAISE EXCEPTION 'Error, caracteristicas no eliminadas';
        END;
    $$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION prc_agregar_cuidado_producto(_id_productos TEXT, _cuidados TEXT)
    RETURNS VOID AS
    $$
    DECLARE 
        id_cuidados TEXT[] = string_to_array(_cuidados,';');
        id_productos TEXT[] = string_to_array(_id_productos,';');
        producto TEXT;
        cuidado TEXT;

        BEGIN

            IF array_length(id_cuidados, 1) > 0 THEN
                FOREACH cuidado IN ARRAY id_cuidados LOOP
                    IF array_length(id_productos, 1) > 0 THEN
                        FOREACH producto IN ARRAY id_productos LOOP
                        	IF NOT EXISTS(SELECT 1 FROM tbl_cuidado_producto WHERE id_producto = UUID(producto) AND id_cuidado = UUID(cuidado)) THEN
                                INSERT INTO tbl_cuidado_producto
                                VALUES (UUID(producto), UUID(cuidado));
                                raise notice 'cuidado: %', cuidado;
                            END IF;
                        END LOOP;
                    END IF;
                END LOOP;
            END IF;

            EXCEPTION 
                WHEN OTHERS THEN 
                    RAISE EXCEPTION 'Error, cuidados no agregadas';
        END;
    $$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION prc_eliminar_cuidado_producto(_id_productos TEXT, _cuidados TEXT)
    RETURNS VOID AS
    $$
    DECLARE 
        id_cuidados TEXT[] = string_to_array(_cuidados,';');
        id_productos TEXT[] = string_to_array(_id_productos,';');
        producto TEXT;
        cuidado TEXT;

        BEGIN

            IF array_length(id_cuidados, 1) > 0 THEN
                FOREACH cuidado IN ARRAY id_cuidados LOOP
                    IF array_length(id_productos, 1) > 0 THEN
                        FOREACH producto IN ARRAY id_productos LOOP
                        	IF EXISTS(SELECT 1 FROM tbl_cuidado_producto WHERE id_producto = UUID(producto) AND id_cuidado = UUID(cuidado)) THEN
                                DELETE FROM tbl_cuidado_producto
                                WHERE id_producto = UUID(producto) AND id_cuidado = UUID(cuidado);
                                raise notice 'cuidado: %', cuidado;
                            END IF;
                        END LOOP;
                    END IF;
                END LOOP;
            END IF;

            EXCEPTION 
                WHEN OTHERS THEN 
                    RAISE EXCEPTION 'Error, cuidados no eliminados';
        END;
    $$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION prc_obtener_producto(_id_producto TEXT)
    RETURNS TABLE (id UUID, nombre varchar(225), precio INT, imagen TEXT, cantidad INT) AS
    $$
    DECLARE 

        BEGIN
			IF coalesce(_id_producto, '') = '' IS NOT TRUE THEN
                RETURN QUERY
                    SELECT p.id, p.nombre, p.precio, encode(p.imagen::BYTEA, 'base64'), i.cantidad
                    FROM tbl_producto as p
                    JOIN tbl_inventario as i ON i.id_producto = p.id
                    WHERE p.id = UUID(_id_producto) AND p.eliminado = false;
			ELSE
                RETURN QUERY
                    SELECT p.id, p.nombre, p.precio, encode(p.imagen::BYTEA, 'base64'), i.cantidad
                    FROM tbl_producto as p
                    JOIN tbl_inventario as i ON i.id_producto = p.id
                    WHERE p.eliminado = false;
			END IF;

            EXCEPTION 
                WHEN OTHERS THEN 
                    RAISE EXCEPTION 'Error, producto no obtenido';
        END;
    $$
LANGUAGE 'plpgsql';



CREATE OR REPLACE FUNCTION prc_eliminar_producto(_id_producto TEXT)
    RETURNS VOID AS
    $$
    DECLARE 

        BEGIN
            IF (coalesce(_id_producto, '') = '') IS NOT TRUE THEN
                UPDATE tbl_producto AS p
                SET eliminado = true
                WHERE  p.id = UUID(_id_producto);

                UPDATE tbl_inventario AS i
                SET cantidad = 0
                WHERE i.id_producto = UUID(_id_producto);
            END IF;

            EXCEPTION 
                WHEN OTHERS THEN 
                    RAISE EXCEPTION 'Error, producto no eliminado';
        END;
    $$
LANGUAGE 'plpgsql';

-- select * from prc_eliminar_producto('38f09921-48c8-44a6-9dbc-be46741af947');
-- select * from prc_eliminar_producto('');


CREATE OR REPLACE FUNCTION prc_obtener_categoria(_id_producto TEXT)
    RETURNS TABLE (J JSON) AS
    $$
    DECLARE 

        BEGIN
			IF coalesce(_id_producto, '') = '' IS NOT TRUE THEN
                RETURN QUERY
                    SELECT json_build_object('id', c.id,'nombre', c.nombre)
                    FROM tbl_categoria as c
                    JOIN tbl_categoria_producto as cp ON cp.id_categoria = c.id
                    JOIN tbl_producto as p ON cp.id_producto = p.id
                    WHERE p.id = UUID(_id_producto) AND p.eliminado = false;

			ELSE
                RETURN QUERY
					    SELECT json_build_object('id', c.id,'nombre', c.nombre)
                        FROM tbl_categoria as c;
			END IF;

            EXCEPTION 
                WHEN OTHERS THEN 
                    RAISE EXCEPTION 'Error, categoria no obtenida';
        END;
    $$
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION prc_obtener_caracteristica(_id_producto TEXT)
    RETURNS TABLE (J JSON) AS
    $$
    DECLARE 

        BEGIN
			IF coalesce(_id_producto, '') = '' IS NOT TRUE THEN
                RETURN QUERY
                    SELECT json_build_object('id', c.id,'nombre', c.nombre)
                    FROM tbl_caracteristica as c
                    JOIN tbl_caracteristica_producto as cp ON cp.id_caracteristica = c.id
                    JOIN tbl_producto as p ON cp.id_producto = p.id
                    WHERE p.id = UUID(_id_producto) AND p.eliminado = false;

			ELSE
                RETURN QUERY
                    SELECT json_build_object('id', c.id,'nombre', c.nombre)
                    FROM tbl_caracteristica as c;
			END IF;

            EXCEPTION 
                WHEN OTHERS THEN 
                    RAISE EXCEPTION 'Error, caracteristica no obtenida';   
        END;
    $$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION prc_obtener_cuidado(_id_producto TEXT)
    RETURNS TABLE (J JSON) AS
    $$
    DECLARE 

        BEGIN
			IF coalesce(_id_producto, '') = '' IS NOT TRUE THEN
                RETURN QUERY
                    SELECT json_build_object('id', c.id,'descripcion', c.descripcion)
                    FROM tbl_cuidado as c
                    JOIN tbl_cuidado_producto as cp ON cp.id_cuidado = c.id
                    JOIN tbl_producto as p ON cp.id_producto = p.id
                    WHERE p.id = UUID(_id_producto) AND p.eliminado = false;

			ELSE
                RETURN QUERY
                    SELECT json_build_object('id', c.id,'descripcion', c.descripcion)
                    FROM tbl_cuidado as c;
			END IF;

            EXCEPTION 
                WHEN OTHERS THEN 
                    RAISE EXCEPTION 'Error, cuidado no obtenido';
        END;
    $$
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION prc_obtener_producto_params(_id_categorias TEXT, _id_caracteristicas TEXT, _id_cuidados TEXT)
    RETURNS TABLE (furniture_info JSON) AS
    $$
    DECLARE 
		id_categorias UUID[] = string_to_array(_id_categorias,';');
		id_caracteristicas UUID[] = string_to_array(_id_caracteristicas,';');
        id_cuidados UUID[] = string_to_array(_id_cuidados,';');
		categorias_len INT = array_length(id_categorias,1);
		caracteristicas_len INT = array_length(id_caracteristicas,1);
        cuidados_len INT = array_length(id_cuidados,1);
        has_returned BOOLEAN = false;
        BEGIN
			IF categorias_len IS NULL AND caracteristicas_len IS NULL AND cuidados_len IS NULL THEN --NO FILTERS
				RAISE NOTICE 'no filters';
				RETURN QUERY
                    SELECT json_build_object('id', p.id,'nombre',p.nombre,'precio',p.precio,'imagen', encode(p.imagen::BYTEA, 'base64'), 'cantidad', i.cantidad)
                    FROM tbl_producto as p
                    JOIN tbl_inventario as i ON p.id = i.id_producto
                    WHERE p.eliminado = false;
                has_returned := true;
			END IF;

			IF categorias_len IS NOT NULL AND caracteristicas_len IS NULL AND cuidados_len IS NULL THEN -- solo categorias
			    RAISE NOTICE 'filter categorias';
                RETURN QUERY
                    SELECT json_build_object('id', p.id,'nombre',p.nombre,'precio',p.precio,'imagen', encode(p.imagen::BYTEA, 'base64'), 'cantidad', i.cantidad)
                    FROM tbl_producto as p
                    INNER JOIN tbl_inventario as i ON p.id = i.id_producto
                    INNER JOIN tbl_categoria_producto as ctp ON ctp.id_producto = p.id
                    WHERE ctp.id_categoria = ANY(id_categorias) AND p.eliminado = false;
                has_returned := true;
			END IF;
            
			IF categorias_len IS NULL AND caracteristicas_len IS NOT NULL AND cuidados_len IS NULL THEN -- solo caracteristicas
			    RAISE NOTICE 'filter caracteristicas';
                RETURN QUERY
                    SELECT json_build_object('id', p.id,'nombre',p.nombre,'precio',p.precio,'imagen', encode(p.imagen::BYTEA, 'base64'), 'cantidad', i.cantidad)
                    FROM tbl_producto as p
                    INNER JOIN tbl_inventario as i ON p.id = i.id_producto
                    INNER JOIN tbl_caracteristica_producto as crp ON crp.id_producto = p.id
                    WHERE crp.id_caracteristica = ANY(id_caracteristicas) AND p.eliminado = false;
                has_returned := true;
			END IF;

            IF categorias_len IS NULL AND caracteristicas_len IS NULL AND cuidados_len IS NOT NULL THEN -- solo cuidados
			    RAISE NOTICE 'filter cuidados';
                RETURN QUERY
                    SELECT json_build_object('id', p.id,'nombre',p.nombre,'precio',p.precio,'imagen', encode(p.imagen::BYTEA, 'base64'), 'cantidad', i.cantidad)
                    FROM tbl_producto as p
                    INNER JOIN tbl_inventario as i ON p.id = i.id_producto
                    INNER JOIN tbl_cuidado_producto as cdp ON cdp.id_producto = p.id
                    WHERE cdp.id_cuidado = ANY(id_cuidados) AND p.eliminado = false;
                has_returned := true;
			END IF;

            EXCEPTION 
                WHEN OTHERS THEN 
                    RAISE EXCEPTION 'Error, producto no obtenido';
        END;
    $$
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION prc_obtener_ventas() 
    RETURNS TABLE (J JSON)
    AS
    $$
        DECLARE 

        BEGIN
            RETURN QUERY
                SELECT json_build_object('id', v.id, 'nombreCliente', c.nombre, 'precioTotal', v.precio_total, 'productos', json_agg(p.nombre))
                FROM tbl_venta as v
                JOIN tbl_cliente as c ON c.id = v.id_cliente
                JOIN tbl_venta_producto as vp ON vp.id_venta = v.id
                JOIN tbl_producto as p ON vp.id_producto = p.id;

            EXCEPTION 
                WHEN OTHERS THEN 
                    RAISE EXCEPTION 'Error, ventas no obtenidas';
        END;
    $$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION prc_facturar(_id_productos TEXT, _cantidades TEXT, _id_cliente TEXT, _precio_total INT) 
    RETURNS VOID
    AS
    $$
        DECLARE 
        id_venta UUID  = gen_random_uuid();
        cantidadActual INT;
        id_productos TEXT[] = string_to_array(_id_productos,';');
        cantidades TEXT[] = string_to_array(_cantidades,';');
        id_producto TEXT;
        cantidad TEXT;
        i INT = 0;

        BEGIN
            INSERT INTO tbl_venta
            VALUES (id_venta, UUID(_id_cliente), _precio_total);
            raise notice 'venta: %', id_venta;

            FOREACH id_producto IN ARRAY id_productos LOOP
                cantidadActual := (SELECT cantidad FROM tbl_inventario as i WHERE i.id_producto = UUID(id_producto));
                cantidad := cantidades[i]::INT;

                IF (cantidadActual >= cantidad) THEN
                    INSERT INTO tbl_venta_producto
                    VALUES (UUID(id_producto), id_venta, cantidad);

                    UPDATE tbl_inventario AS i
                    SET cantidad = (cantidadActual - cantidad)
                    WHERE i.id_producto = UUID(id_producto);

                ELSE  
                    RAISE EXCEPTION 'Cantidades insuficientes'; 
                END IF;

                i := i + 1;
            END LOOP;

            EXCEPTION 
                WHEN OTHERS THEN 
                    RAISE EXCEPTION 'Error, venta fallida';
        END;
    $$
LANGUAGE 'plpgsql';

-- SELECT * FROM tbl_inventario as i WHERE i.id_producto = UUID('38f09921-48c8-44a6-9dbc-be46741af947');
-- select * from prc_facturar(UUID('38f09921-48c8-44a6-9dbc-be46741af947'), 5, UUID('bb85cea4-f238-44c0-974c-362da99d5453'), UUID('1d5ea4a4-2be8-4e61-8b6a-2510e73de908'));
-- SELECT * FROM tbl_inventario as i WHERE i.id_producto = UUID('38f09921-48c8-44a6-9dbc-be46741af947');

----------USER-------------------------------------------------------
CREATE OR REPLACE FUNCTION prc_register_user(_username TEXT, _email TEXT, _hash TEXT)
    RETURNS TABLE (ID UUID, username varchar(25)) AS

    $BODY$
        BEGIN
			INSERT INTO tbl_user(id, username, email, hash, created)
			VALUES (gen_random_uuid(), _username, _email, _hash, current_date);
			
            RETURN QUERY								 
				SELECT U.id, U.username
                FROM tbl_user as U
                WHERE U.username = _username;
        END;
    $BODY$
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION prc_find_user_by_username(_username TEXT)
    RETURNS TABLE (ID UUID, username varchar(25), hash varchar(150)) AS

    $BODY$
        BEGIN
            RETURN QUERY
                SELECT U.id, U.username, U.hash
                FROM tbl_user as U
                WHERE U.username = _username;
        END;
    $BODY$
LANGUAGE 'plpgsql';

SELECT * from prc_register_user('usertest', 'test@test.com', '$2b$10$hyfKWZ6zXiWBhlQk1enA7uAeWkXkpop8evE4M/oeI4y5OIIEQsqWy');