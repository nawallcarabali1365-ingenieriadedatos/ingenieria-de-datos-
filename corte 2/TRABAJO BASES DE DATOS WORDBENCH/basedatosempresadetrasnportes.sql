
create database bdempresatransportes;
use bdempresatransportes;

/* Crear tablas de entidades */
create table Camionero (
    identificacion int primary key,
    nombre varchar(40) not null,
    telefono varchar(30),
    direccionCam varchar(250)
);

create table Camion (
    placa int primary key,
    modelo varchar(15),
    potencia varchar(30),
    tipo varchar(50)
);

CREATE TABLE Ciudad (
    codigoCiud int primary key,
    nombreCiud varchar(15) not null
);


create table Conduccion (
    idConduccion int auto_increment primary key,
    identificacion int,
    placa int,
    constraint FKconduccioncamionero 
        foreign key (identificacion) 
        references Camionero(identificacion) on delete cascade,
    constraint FKconduccioncamion 
        foreign key (placa) 
        references Camion(placa) on delete cascade
);

create table Paquete (
    codigo int primary key,
    descripcion varchar(250),
    destinatario varchar(20) not null,
    direccionPaq varchar(50) not null,
    identificacion int,
    codigoCiud int,
    constraint FKpaquetecamionero 
        foreign key (identificacion) 
        references Camionero(identificacion) on delete set null,
    constraint FKpaqueteciudad 
        foreign key (codigoCiud) 
        references Ciudad(codigoCiud) on delete set null
);

describe Paquete;

/* Agregar fecha de envio al paquete */
alter table Paquete 
add fechaEnvio date;

/* Cambiar tamaño del campo nombreCiud en Ciudad */
alter table Ciudad 
modify nombreCiud varchar(50) not null;

/* Borrar la columna fechaEnvio */
alter table Paquete 
drop column fechaEnvio;

/* Renombrar la tabla Conduccion */
rename table Conduccion to AsignacionConduccion;