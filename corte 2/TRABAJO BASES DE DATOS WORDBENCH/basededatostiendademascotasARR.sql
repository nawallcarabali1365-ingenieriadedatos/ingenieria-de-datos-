
   create database bdtiendamascotas;
   use bdtiendamascotas;
   
   /* Crear tablas*/
   create table Cliente (
       cedulaCliente int primary key,
       nombresCliente varchar(50) not null,
       apellidosCliente varchar(50) not null,
       direccionCliente varchar(100),
       telefonoCliente varchar(20)
   );
   
   create table Mascota (
       codigoMascota int primary key,
       nombreMascota varchar(20) not null,
       tipoMascota varchar(30) not null,
       razaMascota varchar(20),
       generoMascota varchar(10),
       cedulaClienteFK int,
       constraint FKmascotacliente
           foreign key (cedulaClienteFK) 
           references Cliente(cedulaCliente) on delete cascade
   );
   
   create table Vacuna (
       codigoVacuna int primary key,
       nombreVacuna varchar(50) not null,
       dosisVacuna varchar(20) not null,
       enfermedadTrata varchar(100)
   );
   
   create table Producto (
       codigoBarras int primary key,
       nombreProducto varchar(50) not null,
       marcaProducto varchar(20),
       precioProducto decimal (10,2) not null
   );
   
 
   create table MascotaVacuna (
       idAplicacion int auto_increment primary key,
       codigoMascotaFK int,
       codigoVacunaFK int,
       fechaAplicacion date,
       constraint FKmvmascota 
           foreign key(codigoMascotaFK) 
           references Mascota(codigoMascota) on delete cascade,
       constraint FKmvvacuna 
           foreign key (codigoVacunaFK) 
           references Vacuna(codigoVacuna) on delete cascade
   );
   
   create table CompraProducto (
       idCompra int auto_increment primary key,
       cedulaClienteFK int,
       codigoBarrasFK  int,
       fechaCompra date not null,
       cantidad int default 1,
       constraint fk_cp_cliente 
           foreign key (cedulaClienteFK) 
           references Cliente(cedulaCliente) on delete cascade,
       constraint fk_cp_producto 
           foreign key  (codigoBarrasFK) 
           references Producto(codigoBarras) on delete cascade
   );
   

   describe Mascota;
   
   /* Agregar un campo de observaciones a la tabla Mascota */
   alter table Mascota 
   add observaciones varchar (200);
   
   /* Cambiar el tipo de dato de precioProducto  */
   alter table Producto 
   modify precioProducto float not null;
   
   /* Eliminar la columna observaciones*/
   alter table Mascota 
   drop column observaciones;
   
   /* Renombrar la tabla Vacuna */
   rename table Vacuna to VacunasDisponibles;
