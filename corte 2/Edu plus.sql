

/* EduPlus es una plataforma colombiana de cursos en 
línea para desarrolladores. 
El equipo de producto prepara el tablero de indicadores 
del trimestre y te pide varias consultas 
sobre instructores, cursos, estudiantes e inscripciones. 
Algunos estudiantes reciben descuentos, 
así que el valor pagado puede ser menor que el precio del curso. 
La nota final queda en NULL mientras el curso no termina.
Puntos a resolver
Punto 1 — INNER JOIN (obligatorio en clase). Listar todos los cursos con su área, precio y el nombre de su instructor, ordenados por instructor y título.
Punto 2 — LEFT JOIN (obligatorio en clase). El área de mercadeo quiere escribir a los estudiantes registrados que no se han inscrito en ningún curso. Mostrar nombre, apellido y ciudad.
Punto 3 — Tres o más tablas (obligatorio en clase). Para cada inscripción: nombre completo del estudiante (en una sola columna), título del curso, nombre del instructor, fecha de inscripción y valor pagado, ordenado por fecha.
Punto 4 — Función de agregación (obligatorio en clase). Para cada curso con inscripciones: número de inscritos, ingresos (suma del valor pagado) y nota promedio redondeada a 1 decimal. Ordenar de mayor a menor ingreso. Extra: incluir también los cursos sin inscritos, mostrando 0 en ingresos.
Punto 5 — Subconsulta con IN o EXISTS (tarea). Encontrar los cursos que nadie ha comprado.
Punto 6 — Comparación con un promedio (tarea). Listar las inscripciones cuya nota final supera la nota promedio de la plataforma, con estudiante, curso y nota.
Punto 7 — JOIN + funciones + subconsulta (tarea). Mostrar, con el nombre completo en mayúsculas, a los estudiantes cuyo total pagado supera el promedio de gasto por estudiante (entre quienes se han inscrito), junto con cuántos cursos tomaron y cuánto pagaron.
Preguntas para explicar la solución (responder en comentarios)
1. En el punto 2, ¿qué pasaría si usaran INNER JOIN?
2. En el punto 4, ¿por qué “React avanzado” tiene nota promedio NULL? ¿Es un error?
3. En el punto 6, ¿AVG(nota_final) tiene en cuenta las inscripciones sin nota? ¿Cómo lo comprobarían?
4. En el punto 5, ¿por qué aquí NOT IN sí funciona pero en el ejemplo de los vendedores no?
5. ¿Qué parte de su solución cambiaría si la ejecutan en el otro motor?

*/

CREATE DATABASE IF NOT EXISTS eduplus CHARACTER SET utf8mb4;
USE eduplus;

CREATE TABLE instructores (
  id     INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  email  VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE cursos (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  titulo        VARCHAR(100)  NOT NULL,
  area          VARCHAR(50)   NOT NULL,
  precio        DECIMAL(10,2) NOT NULL,
  instructor_id INT           NOT NULL,
  CONSTRAINT fk_cursos_instructor FOREIGN KEY (instructor_id) REFERENCES instructores(id)
);

CREATE TABLE estudiantes (
  id       INT AUTO_INCREMENT PRIMARY KEY,
  nombre   VARCHAR(50) NOT NULL,
  apellido VARCHAR(50) NOT NULL,
  ciudad   VARCHAR(50) NOT NULL
);

CREATE TABLE inscripciones (
  id                INT AUTO_INCREMENT PRIMARY KEY,
  estudiante_id     INT           NOT NULL,
  curso_id          INT           NOT NULL,
  fecha_inscripcion DATE          NOT NULL,
  valor_pagado      DECIMAL(10,2) NOT NULL,
  nota_final        DECIMAL(3,1)  NULL,          -- NULL = curso en progreso
  CONSTRAINT fk_insc_estudiante FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id),
  CONSTRAINT fk_insc_curso      FOREIGN KEY (curso_id)      REFERENCES cursos(id)
);


INSERT INTO instructores (nombre, email) VALUES
  ('Paula Herrera',   'paula@eduplus.co'),
  ('Andrés Quintero', 'andres@eduplus.co'),
  ('Camilo Vargas',   'camilo@eduplus.co');

INSERT INTO cursos (titulo, area, precio, instructor_id) VALUES
  ('SQL desde cero',       'Bases de datos', 200000.00, 1),
  ('Python para análisis', 'Programación',   350000.00, 2),
  ('Git y GitHub',         'Herramientas',   120000.00, 1),
  ('React avanzado',       'Programación',   450000.00, 2),
  ('Docker práctico',      'Herramientas',   300000.00, 1);

INSERT INTO estudiantes (nombre, apellido, ciudad) VALUES
  ('Valeria',  'Ortiz',  'Bogotá'),
  ('Samuel',   'Rojas',  'Medellín'),
  ('Isabella', 'Cruz',   'Cali'),
  ('Tomás',    'Pineda', 'Bogotá'),
  ('Juliana',  'Soto',   'Pereira'),
  ('Martín',   'López',  'Cali');

INSERT INTO inscripciones (estudiante_id, curso_id, fecha_inscripcion, valor_pagado, nota_final) VALUES
  (1, 1, '2026-06-01', 200000.00, 4.5),
  (1, 2, '2026-06-10', 350000.00, 4.0),
  (2, 1, '2026-06-05', 180000.00, 3.8),
  (2, 4, '2026-07-01', 450000.00, NULL),
  (3, 2, '2026-07-15', 315000.00, 4.8),
  (3, 3, '2026-07-20', 120000.00, 4.2),
  (4, 1, '2026-08-01', 200000.00, NULL),
  (4, 3, '2026-08-03', 120000.00, 3.5),
  (4, 4, '2026-08-10', 450000.00, NULL);
  
  /* PUNTO 1 — INNER JOIN
   Cursos con su área, precio e instructor, ordenados por instructor y título 
   sub consultas 
   un select detro de otra consulta otro select  
   dentro de perentesis 
   la consulta interna responde una pregunta y la respuesta le sirve a la consulta externa
   precio>promedio
   
   *where >< = 
   *where con in
   *where con exists
   *from
   *select
   */

SELECT c.titulo,
       c.area,
       c.precio,
       i.nombre AS instructor
FROM cursos c
INNER JOIN instructores i ON i.id = c.instructor_id
ORDER BY i.nombre, c.titulo;

/* PUNTO 2 — LEFT JOIN
   Estudiantes registrados que no se han inscrito en ningún curso */
SELECT e.nombre,
       e.apellido,
       e.ciudad
FROM estudiantes e
LEFT JOIN inscripciones ins ON ins.estudiante_id = e.id
WHERE ins.id IS NULL;

/* PUNTO 3 — Tres o más tablas
   Cada inscripción con estudiante, curso, instructor, fecha y valor pagado */
SELECT CONCAT(e.nombre, ' ', e.apellido) AS estudiante,
       c.titulo                          AS curso,
       i.nombre                          AS instructor,
       ins.fecha_inscripcion,
       ins.valor_pagado
FROM inscripciones ins
JOIN estudiantes  e ON e.id = ins.estudiante_id
JOIN cursos       c ON c.id = ins.curso_id
JOIN instructores i ON i.id = c.instructor_id
ORDER BY ins.fecha_inscripcion;

-- punto4
select titulo,precio
from cursos
where precio > (select avg(precio) as promedio from cursos)
order by precio desc;

select titulo,precio
from cursos
where precio = (select max(precio) from cursos);

select curso_id,
       count(*) as est_inscritos,
       sum(valor_pagado) AS ingresos,
       round(avg(nota_final), 1) AS nota_promedio
from inscripciones
group by curso_id;

/*subquery returns more that row *
 * IN devuelve una lista de valores 
 * clientes que tienen al menos 1 pedido*/

-- punto 5
select titulo, area, precio
from cursos
where id not in (select curso_id from inscripciones);

select c.titulo, c.area, c.precio
from cursos c
where not exists (
 select 1
  from  inscripciones i
  where i.curso_id = c.id
);

select nombre,apellido
from estudiantes
where id in (select estudiante_id from inscripciones);

select nombre,apellido
from estudiantes
where id not in (select estudiante_id from inscripciones);

select v.nombre
from estudiantes v
where not exists
(select 1 
from inscripciones p
where p.estudiante_id = v.id);

select v.nombre
from estudiantes v
where exists
(select 1 
from inscripciones p
where p.estudiante_id = v.id);

-- punto 6
select concat(e.nombre, ' ', e.apellido) as estudiante,
       c.titulo as curso,
       ins.nota_final as nota
from inscripciones ins
join estudiantes e on e.id = ins.estudiante_id
join cursos c on c.id = ins.curso_id
where ins.nota_final > (select avg(nota_final) from inscripciones);