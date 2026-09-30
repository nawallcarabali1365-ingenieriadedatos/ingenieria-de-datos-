

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

create database if not exists eduplus character set utf8mb4;
use eduplus;

create table instructores (
  id    int auto_increment primary key,
  nombre varchar(100) not null,
  email  varchar(100) not null unique
);

create table cursos (
  id            int auto_increment primary key,
  titulo         varchar(100) not null,
  area          varchar(50)   not null,
  precio        decimal(10,2) not null,
  instructor_id int           not null,
  constraint fk_cursos_instructor foreign key (instructor_id) references instructores(id)
);

create table estudiantes (
  id        int auto_increment primary key,
  nombre   varchar(50)   not null,
  apellido varchar(50)   not null,
  ciudad   varchar(50)   not null
);

create table  inscripciones (
  id                int auto_increment primary key,
  estudiante_id     int           not null,
  curso_id          int           not null,
  fecha_inscripcion date          not null,
  valor_pagado      decimal(10,2) not null,
  nota_final        decimal(3,1)  null,          -- NULL = curso en progreso
  constraint fk_insc_estudiante foreign key (estudiante_id) references estudiantes(id),
  constraint fk_insc_curso      foreign key (curso_id)     references cursos(id)
);


insert into instructores (nombre, email) values
  ('Paula Herrera',   'paula@eduplus.co'),
  ('Andrés Quintero', 'andres@eduplus.co'),
  ('Camilo Vargas',   'camilo@eduplus.co');

insert into cursos (titulo, area, precio, instructor_id) values
  ('SQL desde cero',       'Bases de datos', 200000.00, 1),
  ('Python para análisis', 'Programación',   350000.00, 2),
  ('Git y GitHub',         'Herramientas',   120000.00, 1),
  ('React avanzado',       'Programación',   450000.00, 2),
  ('Docker práctico',      'Herramientas',   300000.00, 1);

insert into estudiantes (nombre, apellido, ciudad) values
  ('Valeria',  'Ortiz',  'Bogotá'),
  ('Samuel',   'Rojas',  'Medellín'),
  ('Isabella', 'Cruz',   'Cali'),
  ('Tomás',    'Pineda', 'Bogotá'),
  ('Juliana',  'Soto',   'Pereira'),
  ('Martín',   'López',  'Cali');

insert into inscripciones (estudiante_id, curso_id, fecha_inscripcion, valor_pagado, nota_final) values
  (1, 1, '2026-06-01', 200000.00, 4.5),
  (1, 2, '2026-06-10', 350000.00, 4.0),
  (2, 1, '2026-06-05', 180000.00, 3.8),
  (2, 4, '2026-07-01', 450000.00,  null),
  (3, 2, '2026-07-15', 315000.00, 4.8),
  (3, 3, '2026-07-20', 120000.00, 4.2),
  (4, 1, '2026-08-01', 200000.00,  null),
  (4, 3, '2026-08-03', 120000.00, 3.5),
  (4, 4, '2026-08-10', 450000.00,  null);
  
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

select c.titulo,
       c.area,
       c.precio,
       i.nombre as instructor
from cursos c
inner join instructores i on i.id = c.instructor_id
order by i.nombre, c.titulo;

/* PUNTO 2 — LEFT JOIN
   Estudiantes registrados que no se han inscrito en ningún curso */
select  e.nombre,
       e.apellido,
       e.ciudad
from estudiantes e
left join inscripciones ins on ins.estudiante_id = e.id
where ins.id is null;

/* PUNTO 3 — Tres o más tablas
   Cada inscripción con estudiante, curso, instructor, fecha y valor pagado */
select concat(e.nombre, ' ', e.apellido) as estudiante,
       c.titulo                          as curso,
       i.nombre                          as instructor,
       ins.fecha_inscripcion,
       ins.valor_pagado
from inscripciones ins
join estudiantes  e on e.id = ins.estudiante_id
join cursos       c on c.id = ins.curso_id
join instructores i on i.id = c.instructor_id
order by ins.fecha_inscripcion;

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

-- punto 4 con funciones calculadas
select 
    c.titulo,
    count(i.id) as numero_inscritos,
    coalesce(sum(i.valor_pagado), 0) as ingresos,
    round(avg(i.nota_final), 1) as nota_promedio
from  cursos c
left join inscripciones i on c.id = i.curso_id
group by c.id, c.titulo
order by ingresos desc;
-- punto 7 con funciones calculadas
select  
    upper(concat(e.nombre, ' ', e.apellido)) as estudiante,
    count(ins.curso_id) as cursos_tomados,
    sum(ins.valor_pagado) as total_pagado
from estudiantes e
join inscripciones ins on e.id = ins.estudiante_id
group by e.id, e.nombre, e.apellido
having sum(ins.valor_pagado) > (
    select avg(gasto_por_estudiante)
    from (
        select sum(valor_pagado) as gasto_por_estudiante
        from inscripciones
        group by estudiante_id
    ) as promedios
);
