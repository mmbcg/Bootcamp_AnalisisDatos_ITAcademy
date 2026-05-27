#Sprint 2
	#Nivel 1 
		#Ejercici 1: cargar datos-check
		#Ejercicio 2:
#Listado de los países que están generando ventas:
SELECT distinct (country) 
FROM company as c
JOIN transaction as t 
ON c.id =t.company_id;

#¿Desde cuántos países se generan las ventas?
SELECT count( distinct country) as num_paises_generando_ventas 
FROM company as c
JOIN transaction as t 
ON c.id =t.company_id;

#compañía con la mayor media de ventas
SELECT company_name, ROUND(AVG(amount),2) as media_ventas 
FROM company as c
JOIN transaction as t
ON c.id = t.company_id
GROUP BY company_name
#company id por si hay dos company con el mismo nombre 
#pero diferente id dos entidades diferentes
ORDER BY media_ventas DESC
LIMIT 1
;

		#Ejercicio 3:
#Muestra todas las transacciones realizadas por empresas de Alemania.

##pensamiento lógico:
	#la main query va a mostrar las transacciones 
	#la subquery filtrará las empresas alemanas

#subconsulta para seleccionar los ids de las empresas alemanas
SELECT c.id as id_company, company_name, country 
FROM company as c
WHERE country = "Germany"
;
#consulta final:
#Muestra todas las transacciones realizadas por empresas de Alemania
SELECT t.id as id_transaccion, company_id 
FROM transaction as t
WHERE t.company_id IN (SELECT c.id as id_company 
						FROM company as c
						WHERE country = "Germany");
                        
#Lista las empresas que han realizado transacciones 
#por un amount superior a la media de todas las transacciones.

	##pensamiento lógico:
#sub-subquery
#la media de todas las transacciones - utilizar el amount de cada transaccion 
SELECT round(AVG(amount),2) as media_total
FROM transaction as t;

#subquery- saber los id de las empresas que tienen esa media 
SELECT t.company_id
FROM transaction as t
WHERE amount > (SELECT round(AVG(amount),2) as media_total
FROM transaction as t)
;

#main query definitiva
SELECT c.company_name
FROM company as c
WHERE c.id IN (SELECT t.company_id
					FROM transaction as t
					WHERE amount > (SELECT round(AVG(amount),2) as media_total
									FROM transaction as t))
;#resultado de 100 rows - correcto 

#operadores logicos ANY, IN , ALL IN
SELECT c.company_name
FROM company as c
WHERE c.id > ANY (SELECT t.company_id
					FROM transaction as t
					WHERE amount > (SELECT round(AVG(amount),2) as media_total
									FROM transaction as t))
; #resultado de 99 rows

#Eliminarán del sistema las empresas que carecen de transacciones registradas,
#entrega el listado de estas empresas.
SELECT c.company_name
FROM company as c 
WHERE c.id NOT IN (SELECT distinct t.company_id
FROM transaction as t)
;

#Nivel 2
	#Ejecicio 1

#Identifica los cinco días que se generó la mayor cantidad de ingresos en la empresa por ventas. 
#Muestra la fecha de cada transacción junto con el total de las ventas.
SELECT date(t.timestamp) as fecha, sum(t.amount) as ingreso_total
FROM transaction as t 
GROUP BY fecha
ORDER BY ingreso_total DESC
LIMIT 5
;

	#Ejercicio 2
#¿Cuál es la media de ventas por país? 
SELECT c.country as pais, round(AVG(amount), 2) as media_ventas
FROM company as c
JOIN transaction as t
ON c.id = t.company_id
GROUP BY pais
ORDER BY media_ventas DESC;

	#Ejercicio 3
    
#lista de todas las transacciones realizadas por empresas del mismo pais que Non Institute
#Muestra el listado aplicando JOIN y subconsultas.

	##pensamiento lógico:
#subquery -- empresas que están ubicadas en el mismo país que “Non Institute”
SELECT c.country
FROM company as c
WHERE c.company_name = "Non Institute"
;
#main query 
SELECT t.id as transaccion, c.company_name as nombre_compañia, c.country as pais
FROM company as c
JOIN transaction as t
ON c.id = t.company_id
WHERE c.country = (SELECT c.country
					FROM company as c
					WHERE c.company_name = "Non Institute") 
;

#Muestra el listado aplicando solo subconsultas.

	##pensamiento lógico:
#sub-sub-query para identificar el pais de origen de la empresa
SELECT c.country
FROM company as c
WHERE c.company_name = "Non Institute"
;
#subquery para ver el id company de las empresas de ese pais
SELECT c.id
FROM company as c 
WHERE c.country = (SELECT c.country
					FROM company as c
					WHERE c.company_name = "Non Institute")
;
#main query 
SELECT t.id as transacciones
FROM transaction as t
WHERE  t.company_id IN (SELECT c.id
						FROM company as c 
						WHERE c.country = (SELECT c.country
											FROM company as c
											WHERE c.company_name = "Non Institute"))
;


	#Nivel 3
		#Ejercicio 1
#Presenta el nombre, teléfono, país, fecha y amount, 
#de aquellas empresas que realizaron transacciones con un valor comprendido entre 350 y 400 euros 
#y en alguna de estas fechas: 29 de abril de 2015, 20 de julio de 2018 y 13 de marzo de 2024. 
#Ordena los resultados de mayor a menor cantidad.
SELECT c.company_name as nombre, c.phone as telefono, c.country as pais, date(t.timestamp) as fecha, t.amount as importe
FROM company as c
JOIN transaction as t 
ON c.id = t.company_id
WHERE (t.amount between 350 and 400) AND
		(date(t.timestamp) in ('2015-04-29', '2018-07-20', '2024-03-13'))
ORDER BY t.amount DESC
;

#listado de las empresas en las que especifiques si tienen más de 400 transacciones o menos.
#1. como funciona el CASE
#2. el num de transacciones de cada empresa seria un group by y count

#num-transacciones por empresa
SELECT count(id) as num_transacciones, company_id
FROM transaction as t
GROUP BY t.company_id
ORDER BY count(id) DESC 
;
#vale pero quiero que tenga el nombre de a empresa y no el id
SELECT c.company_name as nombre_empresa, count(t.id) as num_transacciones
FROM transaction as t
JOIN company as c 
ON t.company_id = c.id
GROUP BY t.company_id
ORDER BY count(id) DESC 
;
#ahora agregamos una nueva columna 
SELECT c.company_name as nombre_empresa, count(t.id) as num_transacciones,
	CASE 
	WHEN count(t.id) > 400 then 'Más de 400'
         else 'Menos de 400'
	END as target
FROM transaction as t
JOIN company as c 
ON t.company_id = c.id
GROUP BY t.company_id
ORDER BY num_transacciones DESC 
;