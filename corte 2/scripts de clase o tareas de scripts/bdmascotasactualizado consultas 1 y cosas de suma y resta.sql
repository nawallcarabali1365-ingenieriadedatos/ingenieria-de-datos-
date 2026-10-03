
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
   alter table Producto
   add fechacreacion date;
   
   /* Cambiar el tipo de dato de precioProducto  */
   alter table Producto 
   modify precioProducto float not null;
   
   /* Eliminar la columna observaciones*/
   alter table Mascota 
   drop column observaciones;
   
   alter table CompraProducto 
   add precioProducto float not null;
   /* Renombrar la tabla Vacuna */
   rename table Vacuna to VacunasDisponibles;
   
   -- indice: es una estructura de datos que agiliza las consultas
   -- simple:una sola columna
   -- compuesto: crea multiples columnas --> de izquierda a derecha
   -- costo: los que acelerandrasticamente las consultas pero generan penaliza de escritura
   -- (inser update delete)
   -- HACER 10 REGISTROS EN CADA TABLA
   -- HACER 3 INDICES
   
  
   create index idxclientenombre on Cliente(apellidosCliente, nombresCliente);
   create index idxmascotatiporaza on Mascota(tipoMascota, razaMascota);
   create index idxcomprafechaon on CompraProducto(fechaCompra);
   create index idxvacunaenfermedad on VacunasDisponibles(codigoVacuna);
   
   select * from CompraProducto;
   select codigoBarrasFK, cedulaClienteFK from CompraProducto;
   
   -- consultas con alias select camposconsultar as 'nombre alias' from nombretabla
   select codigoBarrasFK as 'codigo de barras', cedulaClienteFK as 'comprador' from CompraProducto;
   -- consultas con ordenamientos select campos a consultar from nombretabla by campoordenar asc desc
   select * from Cliente  order by  nombresCliente asc;
   select * from Cliente  order by  nombresCliente desc;
   -- consultas con clausulawhee con condiciones select campo a consultar from nombretabla where condicion <> = <= => < >
   select * from Mascota where generoMascota= 'Macho';
   select * from Mascota where generoMascota= 'Hembra';
   select * from Producto where precioProducto>=4000;
   select * from Producto where precioProducto=45000;
   
   -- comparadores logicos and (y) y or(o) negacion not
   select * from Producto where nombreProducto= 'Juguete Pelota de Goma' and precioProducto>=4000;
   
   -- consulta indice
   show index from Cliente;
   describe  Producto;
   
   
   
   -- select betwen in is null is not null
   select codigoBarras  as codigo, nombreProducto, precioProducto,marcaProducto from Producto
   where precioProducto between 40000 and 100000
   and codigoBarras in (7002,7001)
   and stock is not null;
   
   -- expresiones condicionales case when coalesce
   select nombreProducto, precioProducto,
   coalesce (fechacreacion,'2000-01-01') as fecharegistrada,
   case 
   		when precioProducto < 50000 then 'economico'
   		when precioProducto between 50000 and 85000 then 'gama media'
   		else 'gama alta'
   end as segmento_precio
from Producto;

-- consultas de coincidencia patro like
-- like % cero o n caracteres '_' exactamente 1 caracter xxx% inicia %xxx final %xxx% contenga

select * from Producto where nombreProducto like '%A';
select * from Producto where nombreProducto like 'A%';
select * from Producto where nombreProducto like '%per%';
-- expresiones regulares 
select * from Producto where nombreProducto regexp '(perro|comida)';
select * from Producto where nombreProducto regexp '[3]';

-- limit ofset
select * from Cliente order by nombresCliente asc
limit 3 offset 0;

-- funciones calculadas 
select  cantidad, precioProducto, (precioProducto*cantidad) as total from CompraProducto;
select codigoBarras, nombreProducto, max(precioProducto) from Producto
select codigoBarras, nombreProducto, min(precioProducto) from Producto
select COUNT(nombreProducto) as cantidadProducto from Producto
select codigoBarras, nombreProducto, AVG(precioProducto) as precioPromedio from Producto
select sum(cantidad) as totalStock from CompraProducto

-- funciones de texto

select nombreProducto, upper(nombreProducto) as mayusculas from Producto
select nombreProducto, lower(nombreProducto) as minusculas from Producto
select nombreProducto, length(nombreProducto) as numerocadena from Producto
select nombreProducto, concat(nombreProducto) as concatenado from Producto
 
select nombreProducto, count(*) as totalproductos from Producto
group by nombreProducto

select nombreProducto,
round(avg(precioProducto)),
min(precioProducto) as masbarato,
max(precioProducto) as mascaro
from Producto
group by nombreProducto;

   
   

   
   
   
   
   
   
   
   
   
   
   
   
   
   
-- Tabla: Cliente
insert into Cliente (cedulaCliente, nombresCliente, apellidosCliente, direccionCliente, telefonoCliente) values
(101, 'Carlos', 'Pérez', 'Calle 10 # 5-12', '3001234567'),
(102, 'Ana', 'Gómez', 'Carrera 15 # 20-30', '3109876543'),
(103, 'Luis', 'Rodríguez', 'Av. Siempre Viva 123', '3204567890'),
(104, 'María', 'López', 'Calle 45 # 12-08', '3151112233'),
(105, 'Jorge', 'Martínez', 'Carrera 7 # 80-10', '3019998877'),
(106, 'Laura', 'García', 'Calle 80 # 45-67', '3123334455'),
(107, 'Pedro', 'Sánchez', 'Diagonal 15 # 2-40', '3187776655'),
(108, 'Sofia', 'Torres', 'Transversal 9 # 100-1', '3054443322'),
(109, 'Diego', 'Ramírez', 'Calle 100 # 15-20', '3168889900'),
(110, 'Elena', 'Díaz', 'Carrera 50 # 30-15', '3045556677');

-- Tabla: Mascota
insert into  Mascota (codigoMascota, nombreMascota, tipoMascota, razaMascota, generoMascota, cedulaClienteFK) values
(1, 'Firulais', 'Perro', 'Labrador', 'Macho', 101),
(2, 'Michi', 'Gato', 'Siamés', 'Hembra', 102),
(3, 'Rocky', 'Perro', 'Bulldog', 'Macho', 103),
(4, 'Luna', 'Gato', 'Persa', 'Hembra', 104),
(5, 'Max', 'Perro', 'Poodle', 'Macho', 105),
(6, 'Nala', 'Perro', 'Golden Retriever', 'Hembra', 106),
(7, 'Pelusa', 'Conejo', 'Belier', 'Hembra', 107),
(8, 'Thor', 'Perro', 'Husky', 'Macho', 108),
(9, 'Simba', 'Gato', 'Angora', 'Macho', 109),
(10, 'Bella', 'Perro', 'Beagle', 'Hembra', 110);

-- Tabla: VacunasDisponibles (Renombrada previamente)
insert into VacunasDisponibles (codigoVacuna, nombreVacuna, dosisVacuna, enfermedadTrata) values
(501, 'Rabia', '1 ml', 'Rabia canina y felina'),
(502, 'Triple Felina', '0.5 ml', 'Rinotraqueitis, Calicivirus, Panleucopenia'),
(503, 'Parvovirus', '1 ml', 'Parvovirosis canina'),
(504, 'Polivalente Sextuple', '1 ml', 'Moquillo, Hepatitis, Parvovirus, Leptospira'),
(505, 'Bordetella', '0.5 ml', 'Tos de las perreras'),
(506, 'Leucemia Felina', '1 ml', 'Leucemia viral felina'),
(507, 'Moquillo', '1 ml', 'Distemper canino'),
(508, 'Giardia', '1 ml', 'Giardiasis'),
(509, 'Coronavirus Canino', '1 ml', 'Gastroenteritis por coronavirus'),
(510, 'Desparasitante Interno', '1 pastilla', 'Parásitos intestinales');

-- Tabla: Producto
insert into Producto (codigoBarras, nombreProducto, marcaProducto, precioProducto) values
(7021, 'Alimento Perro Adulto 15kg', 'DogChow', 120000.50),
(7022, 'Alimento Gato Adulto 3kg', 'CatChow', 45000.00),
(7023, 'Juguete Pelota de Goma', 'PetToys', 16000.00),
(7024, 'Shampoo Antipulgas 500ml', 'CleanPet', 28000.00),
(7025, 'Arena para Gato 10kg', 'Scoopable', 34000.00),
(7026, 'Collar Ajustable', 'SafePet', 18000.00),
(7027, 'Rascador para Gato', 'CatHome', 85000.00),
(7028, 'Snack Galletas Caninas', 'Barkies', 12000.00),
(7029, 'Comedero de Acero', 'SteelPet', 29000.00),
(7030, 'Cama Mediana para Perro', 'SoftSleep', 98000.00);


-- Tabla: MascotaVacuna (Historial de vacunación)
insert into MascotaVacuna (codigoMascotaFK, codigoVacunaFK, fechaAplicacion) values
(1, 501, '2025-01-10'),
(1, 504, '2025-02-15'),
(2, 502, '2025-01-20'),
(3, 503, '2025-03-01'),
(4, 506, '2025-02-10'),
(5, 505, '2025-01-12'),
(6, 501, '2025-03-05'),
(7, 510, '2025-02-28'),
(8, 507, '2025-01-25'),
(9, 502, '2025-02-18');

-- Tabla: CompraProducto (Historial de compras)
insert into CompraProducto (cedulaClienteFK, codigoBarrasFK, fechaCompra, cantidad, precioProducto) values
(101, 7001, '2025-03-01', 1, 120000.50),
(102, 7002, '2025-03-02', 2, 45000.00),
(103, 7003, '2025-03-02', 3, 15000.00),
(104, 7005, '2025-03-03', 1, 38000.00),
(105, 7004, '2025-03-04', 2, 28500.00),
(106, 7006, '2025-03-05', 1, 18000.00),
(107, 7008, '2025-03-06', 4, 12500.00),
(108, 7010, '2025-03-07', 1, 95000.00),
(109, 7007, '2025-03-08', 1, 85000.00),
(110, 7009, '2025-03-09', 10, 22000.00);

describe CompraProducto;
 