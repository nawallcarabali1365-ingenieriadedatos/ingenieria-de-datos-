
create database bdcompaniaseguros;
   use bdcompaniaseguros;
   
   
   create table Compania (
       iDCompania int primary key,
       nit varchar(15) not null,
       nombre varchar(50) not null,
       fechaFundacion date,
       representanteLegal varchar(50)
   );
   
   create table Automovil (
       iDAutomovil int primary key,
       marca varchar(10) not null,
       modelo varchar(15),
       placa varchar(10) unique not null,
       tipo varchar(15),
       anioFabricacion date,
       serieChasis int,
       pasajeros int,
       cilindraje varchar(10),
       iDCompañia int,
       fechaInicio date,
       estado varchar(10),
       valorAsegurado int,
       costo decimal (10,2) not null,
       iDCompania int,
       constraint FKautocompania 
           foreign key (iDCompania) 
           references Compania(iDCompania) on delete cascade
   );
   
   create table Accidentes (
       iDAccidente int primary key,
       fechaAccidente date not null,
       lugar varchar(15),
       heridos int default 0,
       fatalidades varchar(15),
       automotores varchar(15)
   );
   
   create table Involucra (
       dInvolucra int primary key,
       iDAutomovil int,
       iDAccidente int,
       constraint FKinvolucraauto 
           foreign key (iDAutomovil) 
           references Automovil(iDAutomovil) on delete cascade,
       constraint FKinvolucraaccidente 
           foreign key (iDAccidente) 
           references Accidentes(iDAccidente) on delete cascade
   );
   
 
describe Automovil;
   
   /* Modificar tipo de dato de nit */
   alter table Compania 
   modify nit varchar(20) not null;
   
   /* Agregar columna observaciones a Accidentes */
   alter table  Accidentes 
   add informePolicial varchar(200);
   
   /* Eliminar la columna */
   alter table Accidentes 
   drop column informePolicial;
   
   /* Renombrar la tabla Accidentes */
   rename table Accidentes to Siniestros;