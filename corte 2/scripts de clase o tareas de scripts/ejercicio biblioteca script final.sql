/*
sestencias DDL: DEFINICION DE DATO OESTRUCTURA
*/
/* crear base de datos*/
create database biblioteca;
/* habilitar la base de datos*/
use biblioteca;
/*crear tablas*/
create table libro(
idLibro varchar (20) primary key,
tituloLibro varchar (50) not null,
identificacioAutorFK varchar (50),
anioPublicacion year not null,
estadoLibro bool
);
create table Autor(
identificacionAutor varchar (50) primary key,
nombreAutor varchar (20) not null,
fechaNacimiento date
);
alter table libro
add constraint autorlibro
foreign key (identificacioAutorFK)
references Autor (identificacionAutor);

create table Miembro(
identificacionMiembro int  auto_increment primary key,
documentoMiembro int not null,
nombreMiembro varchar (20) not null,
direccionMiembro varchar(50) null,
fechaInsicripcion date not null,
estadoMiembro bool
);
create table Prestamo (
idPrestamo int auto_increment primary key,
fechaPrestamo date not null,
fechaDevolucion date not null,
estadoPrestamo bool,
identificacionMiembroFK int,
idLibroFK varchar (20),
constraint fkprestamomiembro
	foreign key (identificacionMiembroFK)
    references Miembro(identificacionMiembro)
    on delete cascade,
constraint fkprestamolibro
	foreign key (idLibroFK)
    references  Libro(idLibro)
    on delete cascade
);
/* conocer la estructura de la BD*/
/* DESCRIBIR LA ESTRUCTURA DE LAS TABLAS*/
describe prestamo;
/* en prestamo vamos a agregar un CAMPO que se llame descripcion varchar 100 */
alter table Prestamo
ADD descripcionprestamo VARCHAR(100);
/*aqui borro borro la columana descripcion porque no estaba muy especifica y ya la habia creado*/
alter table Prestamo
DROP COLUMN descripcion;
/*En la tabla libro vamos a cambiar anioPublicacion de date por varchar*/ 
alter table libro
modify anioPublicacion VARCHAR(100);
 /*En la tabla miembro vamos a eliminar el campo documentomiembro*/
 alter table Miembro
DROP COLUMN documentoMiembro;
/*En la tabla miembro vamos a cambiar el nombre de la tabla por socio*/
rename table Miembro to Socio;






