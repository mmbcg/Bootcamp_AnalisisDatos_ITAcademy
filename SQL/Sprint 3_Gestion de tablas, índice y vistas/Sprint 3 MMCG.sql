#Sprint 3
	#NIvel 1
		#Ejercicio 1

#Crear tabla credit card:
CREATE TABLE credit_card (
	id VARCHAR(255) PRIMARY KEY,
    iban VARCHAR(255),
    pan VARCHAR(255),
    pin VARCHAR(255),
    cvv VARCHAR(255),
    expiring_date VARCHAR(255)
);
#despues se cargan los datos con el otro documento proporcionado

#indicamos cual es la fk
ALTER TABLE transaction
ADD CONSTRAINT FK_t_cc
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id);

#N1
    #Ejercicio 2
#error asociado al numero de cuenta asociado a la tarjeta de credito con id CcU-2938
#iban correcto: TR323456312213576817699999
SELECT * 
FROM credit_card as cc
WHERE id ='CcU-2938'
;
#clausula update para realizar un cambio en algun campo
UPDATE credit_card as cc
SET iban = 'TR323456312213576817699999'
WHERE id ='CcU-2938'
;
#confirmación de que se realizó el cambio correctamente
SELECT * 
FROM credit_card as cc
WHERE id ='CcU-2938'
;
#just in case
-- ALTER TABLE transaction
-- DROP FOREIGN KEY FK_transaction_creditcard;

#N1
	#Ejercicio 3 
#realizar un nuevo ingreso en la tabla transaction
#id -108B1D1D-5B23-A76C-55EF-C568E49A99DD
#credit_card_id	CcU-9999
#company_id	b-9999
#user_id	9999
#lato	829.999
#longitud	-117.999
#amunt	111.11
#declined	0

#INSERT INTO para agregar una nueva fila a la tabla existente
-- INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined)
-- VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', 829.999, -117.999, NULL, 111.11, 0);
#arroja error porque ese company id no existe en la tabbla company 

#Añadir nueva fila a la tabla company con el id 'b-9999'
INSERT INTO company (id, company_name, phone, email, country, website)
VALUES ('b-9999', NULL, NULL, NULL, NULL, NULL)
;

#revisar que se añadió correctamente
    SELECT *
    FROM company
    WHERE id='b-9999';

#Añadir nueva fila a la tabla credit caard con el id CcU-9999
INSERT INTO credit_card (id, iban, pan, pin, cvv, expiring_date)
VALUES ('CcU-9999', NULL, NULL, NULL, NULL, NULL)
;
	#revisar que se añadió correctamente
    SELECT *
    FROM credit_card
    WHERE id='CcU-9999';

#ahora si que puedo añadir la info que me dan en transaction
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', 829.999, -117.999, NULL, 111.11, 0)
;
#revisar que se añadió correctamente
    SELECT* 
    FROM transaction
    WHERE credit_card_id='CcU-9999';

#N1
    #Ejercicio 4

#eliminar la columna "pan" de la tabla credit_card
#tabla original
SELECT *
FROM credit_card
;
#tabla cc despues de eliminar la columna pan
ALTER TABLE credit_card
DROP COLUMN pan
;
#revisamos si se realizaron los cambios correctamente
SELECT *
FROM credit_card
;

#N2
	#Ejercicio 1
#Elimina de la tabla transacción el registro con ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de datos.
#revision del campo
SELECT *
FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD'
;
#eliminamos 
DELETE FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD'
;
#revisamos que se haya realizado el cambio correctamente
SELECT *
FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD'
;

#N2
	#Ejercicio 2
#crear una vista que proporcione detalles clave sobre las compañías y sus transacciones
#Nombre de la compañía. – company table
#Teléfono de contacto. – company table
#País de residencia. – company table
#Media de compra realizada por cada compañía.  – avg amount from transaction table group by company id from company table.
#Conclusión – complex view 

#creat view
CREATE VIEW VistaMarketing AS
SELECT company_name, phone, country, ROUND(AVG(amount),2) AS media_ventas 
FROM company AS c
JOIN transaction AS t
ON c.id = t.company_id
GROUP BY company_name, phone, country
ORDER BY media_ventas DESC;
#revisamos la view creada
SELECT *
FROM VistaMarketing;

#just in case
-- drop view VistaMarketing;

#N2
	#Ejercicio 3
    
#Filtra VistaMarketing sólo las compañías en "Germany"
ALTER VIEW VistaMarketing AS
SELECT company_name, phone, country, ROUND(AVG(amount),2) AS media_ventas 
FROM company AS c
JOIN transaction AS t
ON c.id = t.company_id
WHERE country = 'Germany'
GROUP BY company_name, phone, country
ORDER BY media_ventas DESC;
#revision del filtro de la vista
SELECT * FROM VistaMarketing;

#CORRECCION SERIA EL WHERE EN LA VISTA Y NO EN EL JOIN

SELECT *
FROM VistaMarketing
WHERE country = 'Germany';

#N3
	#Ejercicio 1
#se creó la tabla users y se cargaron sus datos

#cambios en las tablas

#eliminacion de la columna website en la tabla company 
ALTER TABLE company
DROP COLUMN website;

#cambio de data type tabla transaction
# credit_card_id de VARCHAR 255 a 20
ALTER TABLE transaction
MODIFY credit_card_id VARCHAR (20); 

#Vale en el camino me encontré con varias liadas, entonces para 
#evitar estos lios, se eliminan las forein keys, se realizan todos los cambios necesarios
#y se vuelve a restablecer las relaciones para completar el modelo

#elmininacion de fk
ALTER TABLE transaction
DROP CONSTRAINT FK_t_cc
; 
ALTER TABLE transaction
DROP CONSTRAINT transaction_ibfk_1
; 

#cambios de data type tabla company
ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE,
MODIFY id VARCHAR (20),
MODIFY iban VARCHAR (50),
MODIFY pin VARCHAR (4),
MODIFY cvv INT
;

#modificaciones de la tabla user 
ALTER TABLE data_user
RENAME TO data_user,
MODIFY id INT,
RENAME COLUMN email TO personal_email
;


#union de la tabla user al modelo ALTER TABLE transaction
ALTER TABLE transaction
ADD CONSTRAINT FK_t_u
FOREIGN KEY (user_id)
REFERENCES data_user(id);

#me arroja un error diciendo que hay un registro en transaction que no existe en data_user 
#como corroborrarlo?
#left join?
select*from transaction
left join data_user on 
data_user.id=transaction.user_id
where data_user.id is NULL
;

#claro fue la info que se añadió en niveles anteriores, por ende
#se añade esta fila en la tabla data_user

INSERT INTO data_user (id, name, surname, phone, personal_email, birth_date, country, city, postal_code, address)
VALUES ('9999', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
;
#comprobamos:
SELECT *
FROM data_user
WHERE id='9999';

#y ahora si se deberia de poder unir la tabla user al modelo
ALTER TABLE transaction
ADD CONSTRAINT FK_t_u
FOREIGN KEY (user_id)
REFERENCES data_user(id);

#por ultimo volvemos a crear las fk que habiamos quitado con anterioridad para la union completa del modelo
#trasaction-company
ALTER TABLE transaction
ADD CONSTRAINT FK_t_c
FOREIGN KEY (company_id)
REFERENCES company(id);

#transaction-credit_card
ALTER TABLE transaction
ADD CONSTRAINT FK_t_cc
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id);

#N3
	#Ejercicio 2:
#crear  vista  "InformeTecnico" 
CREATE VIEW InformeTecnico AS 
SELECT t.id, name, surname, iban, company_name
FROM transaction AS t
JOIN data_user AS u
ON t.user_id = u.id
JOIN credit_card AS cc
ON t.credit_card_id=cc.id
JOIN company AS c
ON t.company_id=c.id
WHERE declined =0
ORDER BY t.id;

