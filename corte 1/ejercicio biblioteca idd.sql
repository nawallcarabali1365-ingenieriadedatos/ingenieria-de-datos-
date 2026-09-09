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
/* en prestamo vamos a agregar un CAMPO que se llame descripcion varchar 100 
En la tabla libro vamos a cambiar anioPublicacion de date por varchar 
En la tabla miembro vamos a eliminar el campo documentomiembro
en la tabla miembro vamos a cambiar el nombre de la tabla por socio*/



