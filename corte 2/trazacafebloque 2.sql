
-- Laboratorio TrazaCafé · Bloque 1 · 
-- Retos 2 
create database trazacafe;
use trazacafe;

-- 1) Tablas que no dependen de nadie

create table Finca (
  idFinca       int auto_increment primary key,
  nombre        varchar(30)  not null,
  caficultor    varchar(30)  not null,
  municipio     varchar(30)  not null,
  departamento  varchar(30)  not null,
  altitud       int          not null
);

create table Catador (
  idCatador      int auto_increment primary key,
  nombreCatador  varchar(30) not null
);

create table Cliente (
  idCliente      int auto_increment primary key,
  nombreCliente  varchar(30) not null
);

-- 2) Tablas que dependen de las anteriores

create table Lote (
  idLote        int auto_increment primary key,
  codigoUnico   varchar(12)  not null,
  variedad      varchar(10)  not null,
  proceso       enum('lavado','honey','natural') not null,   
  fechacosecha  date         not null,
  kiloslot      decimal(7,2) not null,
  idFinca       int          not null,
  constraint FKLoteFinca foreign key (idFinca) references Finca(idFinca)
);

create table Pedido (
  idPedido   int auto_increment primary key,
  estado     varchar(10) not null,
  idCliente  int         not null,
  constraint FKPedidoCliente foreign key (idCliente) references Cliente(idCliente)
);

create table Catacion (
  idCatacion  int auto_increment primary key,
  puntaje     decimal(5,2) not null,
  idCatador   int          not null,
  idLote      int          not null,
  constraint FKCatacionCatador foreign key (idCatador) references Catador(idCatador),
  constraint FKCatacionLote    foreign key (idLote)    references Lote(idLote)
);

create table Tostion (
  idTostion     int auto_increment primary key,
  fechaTostion  date         not null,
  kilosEntrada  decimal(7,2) not null,
  kilosSalida   decimal(7,2) not null,
  perfil        enum('claro','medio','oscuro')   not null,   -- lista cerrada (req. 4)
  idLote        int          not null,
  constraint FKTostionLote foreign key (idLote) references Lote(idLote)
);

create table LineaPedido (
  idLineaPedido       int auto_increment primary key,
  preciokilosPedidos  decimal(12,2) not null,
  kilosPedidos        decimal(7,2)  not null,
  idPedido            int           not null,
  idTostion           int           not null,
  constraint FKLineaPedido  foreign key (idPedido)  references Pedido(idPedido),
  constraint FKLineaTostion foreign key (idTostion) references Tostion(idTostion)
);

describe Finca;
describe Catador;
describe Cliente;
describe Lote;
describe Pedido;
describe Catacion;
describe Tostion;
describe LineaPedido;

-- Reflexión Reto 2:
-- (Si se crea primero lote, el motor da error porque su llave foránea idFinca apunta a la tabla finca, que todavía no existe, y no puede validar esa referencia. 
-- Por eso las tablas se crean en orden: primero las que no dependen de nadie y al final las que tienen llaves foráneas hacia ellas.)

-- Reto 3
-- la altitud nunca es menor a 800 ni mayor a 2.500
alter table Finca
  add constraint chk_finca_altitud check (altitud between 800 and 2500);

--  el código del lote es único
alter table Lote
  add constraint uq_lote_codigo unique (codigoUnico);

--  el puntaje SCA va de 0 a 100
alter table Catacion
  add constraint chk_catacion_puntaje check (puntaje between 0 and 100);

-- nunca pueden salir más kilos de los que entraron
alter table Tostion
  add constraint chk_tostion_kilos_salida check (kilosSalida <= kilosEntrada);

-- Diccionario de datos: kilosEntrada mayor que 0
alter table Tostion
  add constraint chk_tostion_kilos_entrada check (kilosEntrada > 0);

--  el pedido empieza en 'pendiente'
alter table Pedido
  alter column estado set default 'pendiente';


-- RESTRICT: no se borra una finca que tenga lotes (protege el historial)
alter table Lote drop foreign key FKLoteFinca;
alter table Lote add constraint FKLoteFinca
  foreign key (idFinca) references Finca(idFinca) on delete restrict;

-- RESTRICT: no se borra un catador que tenga cataciones registradas
alter table Catacion drop foreign key FKCatacionCatador;
alter table Catacion add constraint FKCatacionCatador
  foreign key (idCatador) references Catador(idCatador) on delete restrict;

-- RESTRICT: no se borra un lote con cataciones (el puntaje es parte de su trazabilidad)
alter table Catacion drop foreign key FKCatacionLote;
alter table Catacion add constraint FKCatacionLote
  foreign key (idLote) references Lote(idLote) on delete restrict;

-- RESTRICT: no se borra un lote que ya fue tostado
alter table Tostion drop foreign key FKTostionLote;
alter table Tostion add constraint FKTostionLote
  foreign key (idLote) references Lote(idLote) on delete restrict;

-- RESTRICT: no se borra un cliente que tenga pedidos
alter table Pedido drop foreign key FKPedidoCliente;
alter table Pedido add constraint FKPedidoCliente
  foreign key (idCliente) references Cliente(idCliente) on delete restrict;

-- CASCADE: una línea no existe sin su pedido; si se elimina un pedido, se eliminan sus líneas
alter table LineaPedido drop foreign key FKLineaPedido;
alter table LineaPedido add constraint FKLineaPedido
  foreign key (idPedido) references Pedido(idPedido) on delete cascade;

-- RESTRICT: no se borra una tostión que ya se vendió
alter table LineaPedido drop foreign key FKLineaTostion;
alter table LineaPedido add constraint FKLineaTostion
  foreign key (idTostion) references Tostion(idTostion) on delete restrict;


-- Datos poder probar
insert into Finca (nombre, caficultor, municipio, departamento, altitud)
values ('Finca 1', 'Caficultor 1', 'Pitalito', 'Huila', 1600);
insert into Catador (nombreCatador) values ('Catador #1');
insert into Cliente (nombreCliente) values ('Cliente #1');
insert into Lote (codigoUnico, variedad, proceso, fechacosecha, kiloslot, idFinca)
values ('PRB-2026-001', 'Caturra', 'lavado', '2026-03-01', 500.00, 1);
insert into Tostion (fechaTostion, kilosEntrada, kilosSalida, perfil, idLote)
values ('2026-03-10', 100.00, 84.00, 'medio', 1);

--  Viola EL chk_finca_altitud (altitud 3000)
insert into Finca (nombre, caficultor, municipio, departamento, altitud)
values ('Finca Alta', 'Caficultor X', 'Salento', 'Quindío', 3000);
/*Error: (0	35	14:19:36	insert into finca (nombre, caficultor, municipio, departamento, altitud)
 values ('Finca Alta', 'Caficultor X', 'Salento', 'Quindío', 3000)	Error Code: 4025. CONSTRAINT `chk_finca_altitud` failed for `trazacafe`.`finca`	0.000 sec)*/

-- Viola EL  uq_lote_codigo (código repetido)
insert into Lote (codigoUnico, variedad, proceso, fechacosecha, kiloslot, idFinca)
values ('PRB-2026-001', 'Geisha', 'natural', '2026-03-05', 200.00, 1);
/*Error: (0	36	14:20:27	insert into lote (codigoUnico, variedad, proceso, fechacosecha, kiloslot, idFinca)
 values ('PRB-2026-001', 'Geisha', 'natural', '2026-03-05', 200.00, 1)	Error Code: 1062. Duplicate entry 'PRB-2026-001' for key 'uq_lote_codigo'	0.000 sec)*/

-- Viola chk_catacion_puntaje (puntaje 105)
insert into Catacion (puntaje, idCatador, idLote) values (105.00, 1, 1);
/*Error: (0	37	14:22:01	insert into catacion (puntaje, idCatador, idLote) values (105.00, 1, 1)	Error Code: 4025. CONSTRAINT `chk_catacion_puntaje` failed for `trazacafe`.`catacion`	0.000 sec)*/

--  Viola chk_tostion_kilos_salida (salen más kilos de los que entraron)
insert into Tostion (fechaTostion, kilosEntrada, kilosSalida, perfil, idLote)
values ('2026-03-11', 100.00, 120.00, 'claro', 1);
/* Error: (0	38	14:22:42	insert into tostion (fechaTostion, kilosEntrada, kilosSalida, perfil, idLote)
 values ('2026-03-11', 100.00, 120.00, 'claro', 1)	Error Code: 4025. CONSTRAINT `chk_tostion_kilos_salida` failed for `trazacafe`.`tostion`	0.000 sec)*/

-- Viola chk_tostion_kilos_entrada (entran 0 kilos)
insert into Tostion (fechaTostion, kilosEntrada, kilosSalida, perfil, idLote)
values ('2026-03-12', 0.00, 0.00, 'oscuro', 1);
 /*Error: (0	39	14:23:54	insert into tostion (fechaTostion, kilosEntrada, kilosSalida, perfil, idLote)
 values ('2026-03-12', 0.00, 0.00, 'oscuro', 1)	Error Code: 4025. CONSTRAINT `chk_tostion_kilos_entrada` failed for `trazacafe`.`tostion`	0.000 sec)*/

-- Valor por defecto: se inserta un pedido SIN estado y se verifica
insert into Pedido (idCliente) values (1);
select idPedido, estado from pedido;
-- Resultado: estado = 'pendiente'

--  Viola fk_lote_finca (la finca 999 no existe)
insert into lote (codigoUnico, variedad, proceso, fechacosecha, kiloslot, idFinca)
values ('PRB-2026-002', 'Bourbon', 'honey', '2026-03-06', 150.00, 999);
/*Error: (14:27:25	insert into lote (codigoUnico, variedad, proceso, fechacosecha, kiloslot, idFinca) values ('PRB-2026-002', 'Bourbon', 'honey', '2026-03-06', 150.00, 999)	Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails (`trazacafe`.`lote`, CONSTRAINT `FKLoteFinca` FOREIGN KEY (`idFinca`) REFERENCES `finca` (`idFinca`))	0.015 sec
)*/

-- Viola ON DELETE RESTRICT de fk_lote_finca (la finca 1 tiene lotes)
delete from finca where idFinca = 1;
/* Error: (14:28:42	delete from finca where idFinca = 1	Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails (`trazacafe`.`lote`, CONSTRAINT `FKLoteFinca` FOREIGN KEY (`idFinca`) REFERENCES `finca` (`idFinca`))	0.000 sec
)*/

-- Viola el ENUM de proceso (valor fuera de la lista)
insert into lote (codigoUnico, variedad, proceso, fechacosecha, kiloslot, idFinca)
values ('PRB-2026-003', 'Castillo', 'semilavado', '2026-03-07', 150.00, 1);
/*Error: (14:29:23	insert into lote (codigoUnico, variedad, proceso, fechacosecha, kiloslot, idFinca) values ('PRB-2026-003', 'Castillo', 'semilavado', '2026-03-07', 150.00, 1)	1 row(s) affected, 1 warning(s): 1265 Data truncated for column 'proceso' at row 1	0.016 sec
)*/

-- Limpieza de los datos de prueba (de hijas a padres)
delete from pedido;
delete from tostion;
delete from lote;
delete from finca;
delete from catador;
delete from cliente;

-- Reflexión Reto 3:
-- (en Un CHECK solo evalúa las columnas de la misma fila, así que no puede
-- expresar reglas que dependan de otras filas o de otras tablas. Por ejemplo, "solo es café
-- de especialidad desde 80" depende del promedio de varias cataciones del mismo lote, y el
-- req. 6  que es no perder el historial se cumple con las llaves foráneas ON DELETE RESTRICT.)


-- RETO 4: Llegó el correo de Berlín

-- País del cliente: obligatorio y con valor por defecto 'Colombia'
alter table Cliente
  add column pais varchar(40) not null default 'Colombia';

-- Huella de carbono de cada tostión: acepta nulos, nunca negativa (un null pasa el check porque la condición queda como desconocida y no falsa)
alter table Tostion
  add column huellacarbonokg decimal(8,2) null;
alter table Tostion
  add constraint chk_tostion_huella check (huellacarbonokg >= 0);

-- 4.3 Ampliar todas las columnas de kilos de decimal(7,2) a decimal(10,2)
alter table Lote        modify column kiloslot     decimal(10,2) not null;
alter table Tostion     modify column kilosEntrada decimal(10,2) not null;
alter table Tostion     modify column kilosSalida  decimal(10,2) not null;
alter table LineaPedido modify column kilosPedidos decimal(10,2) not null;

--  Certificaciones: una finca tiene varias y una certificación aplica a muchas
create table Certificacion (
  idCertificacion      int auto_increment primary key,
  nombreCertificacion  varchar(30) not null,
  constraint uq_certificacion_nombre unique (nombreCertificacion)
);

create table FincaCertificacion (
  idFinca          int not null,
  idCertificacion  int not null,
  constraint PKFincaCertificacion primary key (idFinca, idCertificacion),
  constraint FKFincaCertFinca foreign key (idFinca)
    references Finca(idFinca) on delete restrict,
  constraint FKFincaCertCertificacion foreign key (idCertificacion)
    references Certificacion(idCertificacion) on delete restrict
);

-- Renombrar una columna mal nombrada: preciokilosPedidos -> precioKilo. El nombre anterior sugiere el precio total de los kilos pedidos, pero el dato es el precio de UN kilo (req. 5: "a qué precio").
--     Además, precioKilo sigue el mismo estilo camelCase del resto del modelo.
alter table LineaPedido change column preciokilosPedidos precioKilo decimal(12,2) not null;


-- Verificación
describe Cliente;
describe Tostion;
describe Lote;
describe LineaPedido;
describe Certificacion;
describe FincaCertificacion;

-- Reflexión Reto 4:
-- (escribe aquí tu respuesta en 2 o 3 líneas)


-- RETO 5: La primera cosecha

-- 5.0 Las tablas quedaron vacías tras la limpieza del Reto 3, pero el contador
--     auto_increment siguió avanzando. Se reinicia para que los ids empiecen en 1
--     y las llaves foráneas de abajo apunten a los registros correctos.
alter table Finca        auto_increment = 1;
alter table Catador      auto_increment = 1;
alter table Cliente      auto_increment = 1;
alter table Lote         auto_increment = 1;
alter table Pedido       auto_increment = 1;
alter table Catacion     auto_increment = 1;
alter table Tostion      auto_increment = 1;
alter table LineaPedido  auto_increment = 1;

-- 5.1 Fincas: 4 fincas de 4 departamentos (insert de varias filas)
insert into Finca (nombre, caficultor, municipio, departamento, altitud) values
  ('La Esperanza', 'Jorge Cuéllar',   'Pitalito', 'Huila',     1750),
  ('El Mirador',   'Luz Marina Ríos', 'Salento',  'Quindío',   1850),
  ('Los Naranjos', 'Pedro Enríquez',  'Buesaco',  'Nariño',    1950),
  ('Villa Clara',  'Rosa Elena Mejía','Jardín',   'Antioquia', 1700);

-- 5.2 Catadores
insert into Catador (nombreCatador) values
  ('Andrea Salazar'),
  ('Felipe Rojas'),
  ('Camila Ortiz');

-- 5.3 Clientes: uno en Alemania; los demás toman el valor por defecto 'Colombia'
insert into Cliente (nombreCliente, pais) values
  ('Café Andino Bogotá', default),
  ('Barista Medellín',   default),
  ('Tostadora de Berlín','Alemania');

-- 5.4 Lotes: 8 lotes
insert into Lote (codigoUnico, variedad, proceso, fechacosecha, kiloslot, idFinca) values
  ('HUI-2026-001', 'Caturra',  'lavado',  '2026-01-15', 1200.00, 1),
  ('HUI-2026-002', 'Geisha',   'natural', '2026-01-20',  350.00, 1),
  ('QUI-2026-001', 'Castillo', 'lavado',  '2026-02-03',  900.00, 2),
  ('QUI-2026-002', 'Bourbon',  'honey',   '2026-02-10',  400.00, 2),
  ('NAR-2026-001', 'Caturra',  'lavado',  '2026-02-18',  800.00, 3),
  ('NAR-2026-002', 'Geisha',   'honey',   '2026-02-25',  300.00, 3),
  ('ANT-2026-001', 'Castillo', 'natural', '2026-03-01', 1000.00, 4),
  ('ANT-2026-002', 'Bourbon',  'lavado',  '2026-03-05',  600.00, 4);

-- 5.5 Cataciones: 10 cataciones (algunos lotes catados por dos catadores distintos)
insert into Catacion (puntaje, idCatador, idLote) values
  (86.50, 1, 1),
  (86.00, 2, 1),
  (89.75, 1, 2),
  (90.25, 3, 2),
  (82.00, 2, 3),
  (84.50, 3, 4),
  (85.00, 1, 4),
  (85.50, 2, 5),
  (88.00, 3, 6),
  (79.50, 1, 7);

-- 5.6 Tostiones: 5 tostiones (kilosSalida <= kilosEntrada; huella puede ser null)
insert into Tostion (fechaTostion, kilosEntrada, kilosSalida, perfil, idLote, huella_carbono_kg) values
  ('2026-03-02', 100.00,  84.50, 'medio',  1, 12.40),
  ('2026-03-04',  50.00,  42.00, 'claro',  2,  6.10),
  ('2026-03-06', 120.00, 100.80, 'oscuro', 3, null),
  ('2026-03-08',  80.00,  67.20, 'medio',  5,  9.75),
  ('2026-03-09',  40.00,  33.60, 'claro',  6, null);

-- 5.7 Pedidos: 4 pedidos; el estado no se envía y toma el valor por defecto 'pendiente'
insert into Pedido (idCliente) values
  (3),
  (1),
  (3),
  (2);

-- 5.8 Líneas de pedido: 6 líneas (precioKilo en pesos colombianos)
insert into LineaPedido (precioKilo, kilosPedidos, idPedido, idTostion) values
  ( 95000.00, 30.00, 1, 1),
  (210000.00, 20.00, 1, 2),
  ( 70000.00, 50.00, 2, 3),
  ( 98000.00, 25.00, 3, 4),
  (190000.00, 15.00, 3, 5),
  ( 72000.00, 40.00, 4, 3);

-- 5.9 Certificaciones del Reto 4
insert into Certificacion (nombreCertificacion) values
  ('Orgánico'),
  ('Fair Trade');

insert into FincaCertificacion (idFinca, idCertificacion) values
  (1, 1),
  (1, 2),
  (3, 2),
  (4, 1);

-- 5.10 Lotes de especialidad: copia de los lotes con puntaje promedio >= 85
create table lotes_especialidad (
  codigoLote       varchar(12)  primary key,
  puntajePromedio  decimal(5,2) not null
);

insert into lotes_especialidad (codigoLote, puntajePromedio)
select l.codigoUnico, round(avg(c.puntaje), 2)
from Lote l
join Catacion c on c.idLote = l.idLote
group by l.codigoUnico
having avg(c.puntaje) >= 85;

select * from lotes_especialidad;

-- Verificación de cantidades
select 'fincas' as tabla, count(*) as filas from Finca
union all select 'lotes', count(*) from Lote
union all select 'cataciones', count(*) from Catacion
union all select 'tostiones', count(*) from Tostion
union all select 'clientes', count(*) from Cliente
union all select 'pedidos', count(*) from Pedido
union all select 'lineas', count(*) from LineaPedido
union all select 'certificaciones', count(*) from FincaCertificacion;

-- Reflexión Reto 5:
-- (escribe aquí tu respuesta en 2 o 3 líneas)


-- =====================================================================
-- RETO 6: La lista de precios que llega dos veces (upsert)
-- =====================================================================

-- 6.1 Tabla de precios de referencia
create table precios_referencia (
  variedad        varchar(10)   primary key,
  precio_kg       decimal(12,2) not null,
  actualizado_en  datetime      not null default current_timestamp
);

-- 6.2 Semana 1
insert into precios_referencia (variedad, precio_kg) values
  ('Castillo',  32000.00),
  ('Caturra',   35500.00),
  ('Geisha',   120000.00);

select * from precios_referencia;

-- Pausa de 2 segundos para que se note el cambio en actualizado_en
select sleep(2);

-- 6.3 Semana 2 con upsert: inserta Bourbon y actualiza Caturra y Geisha
-- MySQL 8.0.19 o superior:
insert into precios_referencia (variedad, precio_kg) values
  ('Caturra',  36800.00),
  ('Geisha',  118000.00),
  ('Bourbon',  41000.00) as nuevo
on duplicate key update
  precio_kg = nuevo.precio_kg,
  actualizado_en = now();

-- MariaDB (no admite el alias "as nuevo"). Si la sentencia anterior da error de
-- sintaxis, usa esta en su lugar (values() está obsoleto en MySQL, pero es lo que
-- MariaDB soporta):
-- insert into precios_referencia (variedad, precio_kg) values
--   ('Caturra',  36800.00),
--   ('Geisha',  118000.00),
--   ('Bourbon',  41000.00)
-- on duplicate key update
--   precio_kg = values(precio_kg),
--   actualizado_en = now();

-- 6.4 Verificación: deben quedar 4 variedades, y actualizado_en debe ser más reciente
--     en Caturra, Geisha y Bourbon que en Castillo
select * from precios_referencia order by variedad;
select count(*) as variedades from precios_referencia;

-- Reflexión Reto 6:
-- (escribe aquí tu respuesta en 2 o 3 líneas)