

create database if not exists universidad;
use universidad;

create table facultad (
    numBloque int not null,
    nombre varchar(100) not null,
    ubicacion varchar(150),
    primary key (numBloque)
);

create table decano (
    cedula varchar(20) not null,
    nombre varchar(50) not null,
    apellido varchar(50) not null,
    celular varchar(20),
    numBloque int not null,
    primary key (cedula),
    unique (numBloque),
    foreign key (numBloque) references facultad (numBloque)
        on update cascade on delete restrict
);

create table docente (
    cedula varchar(20) not null,
    nombre varchar(50) not null,
    apellido varchar(50) not null,
    numBloque int not null,
    primary key (cedula),
    foreign key (numBloque) references facultad (numBloque)
        on update cascade on delete restrict
);


create table docente_titulo (
    cedula varchar(20) not null,
    titulo varchar(150) not null,
    primary key (cedula, titulo),
    foreign key (cedula) references docente (cedula)
        on update cascade on delete cascade
);


create table asignatura (
    codigo varchar(20) not null,
    nombre varchar(100) not null,
    creditos int not null,
    cedulaDocente varchar(20) not null,
    primary key (codigo),
    foreign key (cedulaDocente) references docente (cedula)
        on update cascade on delete restrict
);


create table estudiante (
    identificacion varchar(20) not null,
    nombres varchar(100) not null,
    apellidos varchar(100) not null,
    direccion varchar(150),
    primary key (identificacion)
);

create table inscribe (
    identificacion varchar(20) not null,
    codigo varchar(20) not null,
    primary key (identificacion, codigo),
    foreign key (identificacion) references estudiante (identificacion)
        on update cascade on delete cascade,
    foreign key (codigo) references asignatura (codigo)
        on update cascade on delete cascade
);

insert into facultad (numBloque, nombre, ubicacion) values
(1, 'ingeniería', 'sede norte, bloque a'),
(2, 'ciencias económicas', 'sede centro, bloque b'),
(3, 'ciencias de la salud', 'sede sur, bloque c');

insert into docente (cedula, nombre, apellido, numBloque) values
('1010101010', 'carlos', 'ramírez', 1),
('1020202020', 'laura', 'gómez', 1),
('1030303030', 'andrés', 'martínez', 2),
('1040404040', 'diana', 'lópez', 3),
('1050505050', 'jorge', 'hernández', 1);


-- vista 1: cada docente con el nombre y la ubicación de su facultad
create or replace view vista_docentes_facultad as
select d.cedula,
       d.nombre,
       d.apellido,
       f.nombre as facultad,
       f.ubicacion
from docente d
inner join facultad f on d.numBloque = f.numBloque;
-- vista 2: cantidad de docentes por facultad
create or replace view vista_total_docentes_por_facultad as
select f.numBloque,
       f.nombre as facultad,
       count(d.cedula) as total_docentes
from facultad f
left join docente d on f.numBloque = d.numBloque
group by f.numBloque, f.nombre;


 delimiter //
 
-- procedimiento 1: registrar una nueva facultad
create procedure registrar_facultad(
    in p_numBloque int,
    in p_nombre varchar(100),
    in p_ubicacion varchar(150)
)
begin
    insert into facultad (numBloque, nombre, ubicacion)
    values (p_numBloque, p_nombre, p_ubicacion);
end //
 
-- procedimiento 2: registrar un nuevo docente
create procedure registrar_docente(
    in p_cedula varchar(20),
    in p_nombre varchar(50),
    in p_apellido varchar(50),
    in p_numBloque int
)
begin
    insert into docente (cedula, nombre, apellido, numBloque)
    values (p_cedula, p_nombre, p_apellido, p_numBloque);
end //

-- procedimiento 3: consultar los docentes de una facultad
create procedure docentes_por_facultad(
    in p_numBloque int
)
begin
    select d.cedula, d.nombre, d.apellido, f.nombre as facultad
    from docente d
    inner join facultad f on d.numBloque = f.numBloque
    where d.numBloque = p_numBloque;
end //
 
-- procedimiento 4: actualizar la ubicación de una facultad
create procedure actualizar_ubicacion_facultad(
    in p_numBloque int,
    in p_ubicacion varchar(150)
)
begin
    update facultad
    set ubicacion = p_ubicacion
    where numBloque = p_numBloque;
end //
 
delimiter ;

-- consulta de las vistas
select * from vista_docentes_facultad;
select * from vista_total_docentes_por_facultad;
 
-- llamada de los procedimientos
call registrar_facultad(4, 'derecho', 'sede centro, bloque d');
call registrar_docente('1060606060', 'paula', 'torres', 4);
call docentes_por_facultad(1);
call actualizar_ubicacion_facultad(2, 'sede centro, bloque e');
 
-- verificar los cambios
select * from vista_total_docentes_por_facultad;



 