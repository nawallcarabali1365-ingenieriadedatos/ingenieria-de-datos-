-- Laboratorio TrazaCafé · Bloque 1 · 
-- Retos 2
-- (reto 10, punto 4: script idempotente, se borra la base si ya existe para poder correrlo varias veces)
drop database if exists trazacafe;
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


-- Bloque 2: el esquema cambia y llegan los datos
-- RETO 4: Llegó el correo de Berlín

-- País del cliente: obligatorio y con valor por defecto 'Colombia'
alter table Cliente
  add column pais varchar(40) not null default 'Colombia';

-- Huella de carbono de cada tostión: acepta nulos, nunca negativa (un null pasa el check porque la condición queda como desconocida y no falsa)
alter table Tostion
  add column huella_carbono_kg decimal(8,2) null;
alter table Tostion
  add constraint chk_tostion_huella check (huella_carbono_kg >= 0);

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

describe Cliente;
describe Tostion;
describe Lote;
describe LineaPedido;
describe Certificacion;
describe FincaCertificacion;

-- Reflexión Reto 4:
-- (Al borrar y recrear una tabla se pierden sus filas, y en mi modelo además hay llaves foráneas que la apuntan:
-- por ejemplo, no se puede borrar Tostion sin romper LineaPedido, ni Finca sin romper Lote y FincaCertificacion.
-- Con alter table los clientes que ya existían se quedan y toman pais = 'Colombia' por defecto, sin detener el sistema.)


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

-- Fincas: 4 fincas de 4 departamentos (insert de varias filas)
insert into Finca (nombre, caficultor, municipio, departamento, altitud) values
  ('La Esperanza', 'Jorge Cuéllar',   'Pitalito', 'Huila',     1750),
  ('El Mirador',   'Luz Marina Ríos', 'Salento',  'Quindío',   1850),
  ('Los Naranjos', 'Pedro Enríquez',  'Buesaco',  'Nariño',    1950),
  ('Villa Clara',  'Rosa Elena Mejía','Jardín',   'Antioquia', 1700);

-- Catadores
insert into Catador (nombreCatador) values
  ('Andrea Salazar'),
  ('Felipe Rojas'),
  ('Camila Ortiz');

--  Clientes: uno en Alemania; los demás toman el valor por defecto 'Colombia'
insert into Cliente (nombreCliente, pais) values
  ('Café Andino Bogotá', default),
  ('Barista Medellín',   default),
  ('Tostadora de Berlín','Alemania');

-- Lotes: 8 lotes
insert into Lote (codigoUnico, variedad, proceso, fechacosecha, kiloslot, idFinca) values
  ('HUI-2026-001', 'Caturra',  'lavado',  '2026-01-15', 1200.00, 1),
  ('HUI-2026-002', 'Geisha',   'natural', '2026-01-20',  350.00, 1),
  ('QUI-2026-001', 'Castillo', 'lavado',  '2026-02-03',  900.00, 2),
  ('QUI-2026-002', 'Bourbon',  'honey',   '2026-02-10',  400.00, 2),
  ('NAR-2026-001', 'Caturra',  'lavado',  '2026-02-18',  800.00, 3),
  ('NAR-2026-002', 'Geisha',   'honey',   '2026-02-25',  300.00, 3),
  ('ANT-2026-001', 'Castillo', 'natural', '2026-03-01', 1000.00, 4),
  ('ANT-2026-002', 'Bourbon',  'lavado',  '2026-03-05',  600.00, 4);

--  Cataciones: 10 cataciones (algunos lotes catados por dos catadores distintos)
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

-- 5 tostiones (kilosSalida <= kilosEntrada; huella puede ser null)
insert into Tostion (fechaTostion, kilosEntrada, kilosSalida, perfil, idLote, huella_carbono_kg) values
  ('2026-03-02', 100.00,  84.50, 'medio',  1, 12.40),
  ('2026-03-04',  50.00,  42.00, 'claro',  2,  6.10),
  ('2026-03-06', 120.00, 100.80, 'oscuro', 3, null),
  ('2026-03-08',  80.00,  67.20, 'medio',  5,  9.75),
  ('2026-03-09',  40.00,  33.60, 'claro',  6, null);

-- Pedidos: 4 pedidos; el estado no se envía y toma el valor por defecto 'pendiente'
insert into Pedido (idCliente) values
  (3),
  (1),
  (3),
  (2);

-- Líneas de pedido: 6 líneas (precioKilo en pesos colombianos)
insert into LineaPedido (precioKilo, kilosPedidos, idPedido, idTostion) values
  ( 95000.00, 30.00, 1, 1),
  (210000.00, 20.00, 1, 2),
  ( 70000.00, 50.00, 2, 3),
  ( 98000.00, 25.00, 3, 4),
  (190000.00, 15.00, 3, 5),
  ( 72000.00, 40.00, 4, 3);

--  Certificaciones del Reto 4
insert into Certificacion (nombreCertificacion) values
  ('Orgánico'),
  ('Fair Trade');

insert into FincaCertificacion (idFinca, idCertificacion) values
  (1, 1),
  (1, 2),
  (3, 2),
  (4, 1);

-- Lotes de especialidad: copia de los lotes con puntaje promedio >= 85
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
-- (No. lotes_especialidad es una copia hecha en el momento del insert ... select: hoy tiene HUI-2026-001, HUI-2026-002,
-- NAR-2026-001 y NAR-2026-002, pero si QUI-2026-002 (promedio 84,75) recibe una nueva catación de 86, no aparece solo.
-- Para que se actualice sola usaría una vista (create view), que calcula el promedio cada vez que se consulta.)


-- RETO 6: La lista de precios que llega dos veces (upsert)

--  Tabla de precios de referencia
create table preciosreferencia (
  variedad        varchar(10)   primary key,
  precio_kg       decimal(12,2) not null,
  actualizado_en  datetime      not null default current_timestamp
);

--  Semana 1
insert into preciosreferencia (variedad, precio_kg) values
  ('Castillo',  32000.00),
  ('Caturra',   35500.00),
  ('Geisha',   120000.00);

select * from precios_referencia;

-- Pausa de 2 segundos para que se note el cambio en actualizado_en
select sleep(2);

--  Semana 2 con upsert: inserta Bourbon y actualiza Caturra y Geisha
insert into precios_referencia (variedad, precio_kg) values
  ('Caturra',  36800.00),
  ('Geisha',  118000.00),
  ('Bourbon',  41000.00) as nuevo
on duplicate key update
  precio_kg = values(precio_kg),
  actualizado_en = now();


--  deben quedar 4 variedades, y actualizado_en debe ser más reciente
--     en Caturra, Geisha y Bourbon que en Castillo
select * from precios_referencia order by variedad;
select count(*) as variedades from precios_referencia;

-- Reflexión Reto 6:
-- (on duplicate key update solo se activa cuando se repite una llave primaria o unique. Si variedad no lo fuera,
-- la semana 2 insertaría Caturra y Geisha otra vez: quedarían 6 filas en lugar de 4, con dos precios para la
-- misma variedad, y no se sabría cuál es el vigente.)


-- Bloque 3: operar el negocio (DML)
-- RETO 7: La balanza descalibrada

-- Workbench trae activo el modo seguro (error 1175): bloquea update y delete que no filtran por una llave,
-- para evitar cambiar toda una tabla por accidente. Aquí se desactiva porque algunos update cruzan tablas
-- o filtran por columnas que no son llave, y antes de cada uno se revisa con un select cuántas filas cambian.
set sql_safe_updates = 0;

-- Restar 1,5 puntos a las cataciones de Andrea Salazar (sin bajar de 0)
-- antes: deben cambiar 4 filas (86.50, 89.75, 85.00 y 79.50)
select c.idCatacion, c.idLote, c.puntaje
from Catacion c
join Catador ca on ca.idCatador = c.idCatador
where ca.nombreCatador = 'Andrea Salazar';

update Catacion c
join Catador ca on ca.idCatador = c.idCatador
set c.puntaje = greatest(c.puntaje - 1.5, 0)
where ca.nombreCatador = 'Andrea Salazar';
-- el motor debe reportar: 4 row(s) affected

-- después: 85.00, 88.25, 83.50 y 78.00
select c.idCatacion, c.idLote, c.puntaje
from Catacion c
join Catador ca on ca.idCatador = c.idCatador
where ca.nombreCatador = 'Andrea Salazar';

--  Descuento del 10 % a las líneas del cliente alemán (update que cruza tablas)
-- antes: deben cambiar 4 filas (pedidos 1 y 3 de la Tostadora de Berlín: 95000, 210000, 98000 y 190000)

select lp.idLineaPedido, lp.idPedido, lp.precioKilo, c.nombreCliente, c.pais
from LineaPedido lp
join Pedido p  on p.idPedido  = lp.idPedido
join Cliente c on c.idCliente = p.idCliente
where c.pais = 'Alemania';

update LineaPedido lp
join Pedido p  on p.idPedido  = lp.idPedido
join Cliente c on c.idCliente = p.idCliente
set lp.precioKilo = lp.precioKilo * 0.90
where c.pais = 'Alemania';
-- el motor debe reportar: 4 row(s) affected

-- después: 85500, 189000, 88200 y 171000
select lp.idLineaPedido, lp.idPedido, lp.precioKilo, c.nombreCliente, c.pais
from LineaPedido lp
join Pedido p  on p.idPedido  = lp.idPedido
join Cliente c on c.idCliente = p.idCliente
where c.pais = 'Alemania';

-- Reflexión Reto 7:
-- (El descuento se habría aplicado dos veces, porque el update calcula sobre el precio que ya tiene la fila:
-- la línea 1 de la Tostadora de Berlín pasaría de 95.000 a 85.500 y luego a 76.950, un 19 % y no un 10 %.
-- Igual con Andrea Salazar: le quitaría 3 puntos. Estos update no son idempotentes, por eso se revisa antes con select.)


-- RETO 8: El caficultor que se fue

-- Intentar borrar una finca con lotes vendidos: La Esperanza (lotes HUI-2026-001 y HUI-2026-002, vendidos en el pedido 1)
select l.codigoUnico, lp.idPedido, lp.kilosPedidos
from Finca f
join Lote l         on l.idFinca    = f.idFinca
join Tostion t      on t.idLote     = l.idLote
join LineaPedido lp on lp.idTostion = t.idTostion
where f.nombre = 'La Esperanza';

delete from Finca where nombre = 'La Esperanza';
/* Error: Error Code: 1451. Cannot delete or update a parent row:
   a foreign key constraint fails (`trazacafe`.`lote`, CONSTRAINT `FKLoteFinca` FOREIGN KEY (`idFinca`) REFERENCES `finca` (`idFinca`))
   (también puede nombrar FKFincaCertFinca, porque La Esperanza tiene certificaciones; las dos son on delete restrict) */

-- 8.2 Baja lógica: la finca sale de la operación pero su historial se conserva
alter table Finca
  add column activa boolean not null default true;

update Finca
set activa = false
where nombre = 'La Esperanza';

select idFinca, nombre, activa from Finca;

--  Borrar las cataciones de un lote de prueba con un delete que cruza dos tablas (filtrando por código)
-- lote de prueba con dos cataciones
insert into Lote (codigoUnico, variedad, proceso, fechacosecha, kiloslot, idFinca)
values ('PRB-2026-100', 'Caturra', 'lavado', '2026-03-20', 50.00, 2);

insert into Catacion (puntaje, idCatador, idLote) values
  (81.00, 2, (select idLote from Lote where codigoUnico = 'PRB-2026-100')),
  (82.50, 3, (select idLote from Lote where codigoUnico = 'PRB-2026-100'));

-- antes: deben borrarse 2 filas
select c.idCatacion, c.puntaje, l.codigoUnico
from Catacion c
join Lote l on l.idLote = c.idLote
where l.codigoUnico = 'PRB-2026-100';

delete c
from Catacion c
join Lote l on l.idLote = c.idLote
where l.codigoUnico = 'PRB-2026-100';
-- el motor debe reportar: 2 row(s) affected

-- Vaciar lotes_especialidad con truncate y después eliminarla con drop
truncate table lotes_especialidad;
select count(*) as filas from lotes_especialidad;   -- 0

drop table lotes_especialidad;
show tables like 'lotes_especialidad';               -- no devuelve nada

-- Reflexión Reto 8:
-- (DELETE es DML: borra solo las filas que cumplen el where, como las 2 cataciones de PRB-2026-100, respeta las llaves
-- foráneas (por eso no dejó borrar La Esperanza) y se puede deshacer dentro de una transacción. TRUNCATE es DDL: vacía
-- toda lotes_especialidad de golpe, sin where, y reinicia el contador. DROP también es DDL: elimina la tabla con su estructura.)


-- RETO 9: El pedido que no puede quedar a medias

-- Kilos disponibles por tostión: lo que salió del tostador menos lo que ya se vendió en las líneas de pedido
alter table Tostion
  add column kilosDisponibles decimal(10,2) not null default 0;

update Tostion t
set t.kilosDisponibles = t.kilosSalida - coalesce((select sum(lp.kilosPedidos)
                                                  from LineaPedido lp
                                                  where lp.idTostion = t.idTostion), 0);

alter table Tostion
  add constraint chk_tostion_kilos_disponibles check (kilosDisponibles >= 0);

-- quedan: tostión 1 = 54.50, 2 = 22.00, 3 = 10.80, 4 = 42.20, 5 = 18.60
select idTostion, kilosSalida, kilosDisponibles from Tostion;

-- Transacción exitosa: pedido de Barista Medellín con 2 líneas y descuento de inventario
start transaction;

insert into Pedido (idCliente) values (2);
set @pedido_ok = last_insert_id();

insert into LineaPedido (precioKilo, kilosPedidos, idPedido, idTostion) values
  (98000.00, 10.00, @pedido_ok, 4),
  (95000.00, 15.00, @pedido_ok, 1);

update Tostion set kilosDisponibles = kilosDisponibles - 10 where idTostion = 4;
update Tostion set kilosDisponibles = kilosDisponibles - 15 where idTostion = 1;

commit;

select * from Pedido      where idPedido = @pedido_ok;
select * from LineaPedido where idPedido = @pedido_ok;
select idTostion, kilosDisponibles from Tostion where idTostion in (1, 4);   -- 39.50 y 32.20

--  se piden 500 kilos de la tostión 2 que solo tiene 22 disponibles
start transaction;

insert into Pedido (idCliente) values (2);
set @pedido_malo = last_insert_id();

insert into LineaPedido (precioKilo, kilosPedidos, idPedido, idTostion) values
  ( 98000.00,   5.00, @pedido_malo, 4),
  (210000.00, 500.00, @pedido_malo, 2);

update Tostion set kilosDisponibles = kilosDisponibles - 5   where idTostion = 4;
update Tostion set kilosDisponibles = kilosDisponibles - 500 where idTostion = 2;
/* Falla a propósito:  Error Code: 4025. CONSTRAINT `chk_tostion_kilos_disponibles` failed for `trazacafe`.`tostion` / Error Code: 3819. Check constraint 'chk_tostion_kilos_disponibles' is violated. */

rollback;

-- no quedó ni la cabecera, ni las líneas, y la tostión 4 sigue en 32.20 (el descuento de 5 kilos también se deshizo)
select * from Pedido      where idPedido = @pedido_malo;   -- 0 filas
select * from LineaPedido where idPedido = @pedido_malo;   -- 0 filas
select idTostion, kilosDisponibles from Tostion where idTostion in (2, 4);

--  Savepoint: se confirma la primera línea y se deshace solo la segunda
start transaction;

insert into Pedido (idCliente) values (1);
set @pedido_savepoint = last_insert_id();

insert into LineaPedido (precioKilo, kilosPedidos, idPedido, idTostion)
values (190000.00, 5.00, @pedido_savepoint, 5);
update Tostion set kilosDisponibles = kilosDisponibles - 5 where idTostion = 5;

savepoint antes_segunda_linea;

insert into LineaPedido (precioKilo, kilosPedidos, idPedido, idTostion)
values (72000.00, 50.00, @pedido_savepoint, 3);
update Tostion set kilosDisponibles = kilosDisponibles - 50 where idTostion = 3;
-- falla por el check: la tostión 3 solo tiene 10.80 kilos

rollback to savepoint antes_segunda_linea;

commit;

-- la cabecera y la primera línea existen; la segunda no. Tostión 5 = 13.60 y tostión 3 sigue en 10.80
select * from Pedido      where idPedido = @pedido_savepoint;
select * from LineaPedido where idPedido = @pedido_savepoint;
select idTostion, kilosDisponibles from Tostion where idTostion in (3, 5);

-- 9.5 Experimento: DDL dentro de una transacción
start transaction;
create table prueba (id int primary key);
rollback;

show tables like 'prueba';
-- en MySQL/MariaDB la tabla SÍ existe: create table hace un commit implícito y el rollback ya no tiene qué deshacer.
-- en PostgreSQL NO existiría, porque allá el DDL también es transaccional.

drop table if exists prueba;

-- Reflexión Reto 9:
-- (En MySQL el create table hizo commit implícito, así que el rollback no borró la tabla prueba. El riesgo en una migración:
-- si un script como el del reto 4 falla a la mitad, los alter table que ya corrieron se quedan (por ejemplo, pais ya agregada
-- pero huella_carbono_kg no) y la base queda a medias; hay que escribir pasos idempotentes y tener copia de respaldo.)


-- RETO 10: El QR que cuenta la historia
-- El promedio SCA se calcula por lote en una subconsulta, así cada línea trae el promedio de todas las cataciones de su lote.
-- La finca aparece aunque esté inactiva (La Esperanza), porque el historial de ventas no se pierde.
create or replace view v_trazabilidad as
select
  lp.idLineaPedido,
  p.idPedido,
  c.nombreCliente     as cliente,
  c.pais,
  f.nombre            as finca,
  f.caficultor,
  f.municipio,
  f.altitud,
  l.codigoUnico       as codigoLote,
  l.variedad,
  l.proceso,
  pc.puntajePromedio,
  t.fechaTostion,
  t.perfil,
  concat(
    l.variedad, ' ', l.proceso,
    ' de Finca ', f.nombre, ', ', f.municipio,
    ' (', format(f.altitud, 0, 'de_DE'), ' m). ',
    'Puntaje ', coalesce(format(pc.puntajePromedio, 2, 'de_DE'), 'sin catar'), '. ',
    'Tostado ', t.perfil, ' el ', date_format(t.fechaTostion, '%Y-%m-%d'), '.'
  ) as texto_qr
from LineaPedido lp
join Pedido p   on p.idPedido  = lp.idPedido
join Cliente c  on c.idCliente = p.idCliente
join Tostion t  on t.idTostion = lp.idTostion
join Lote l     on l.idLote    = t.idLote
join Finca f    on f.idFinca   = l.idFinca
left join (
  select idLote, round(avg(puntaje), 2) as puntajePromedio
  from Catacion
  group by idLote
) pc on pc.idLote = l.idLote;

-- Consulta como la haría la app: un solo pedido (pedido 1, Tostadora de Berlín)
select cliente, pais, codigoLote, texto_qr
from v_trazabilidad
where idPedido = 1;

select * from v_trazabilidad;

-- Script idempotente: al inicio del archivo está drop database if exists trazacafe, la vista usa
-- create or replace view y la tabla prueba del reto 9 se borra con drop table if exists.

-- Al consumidor de café de especialidad le importa saber que el caficultor recibió un pago justo;
-- ponerlo en el QR hace la historia verificable también en lo económico, no solo en el origen.
alter table Lote
  add column precioCaficultorKg decimal(12,2) null;

alter table Lote
  add constraint chk_lote_precio_caficultor check (precioCaficultorKg > 0);

update Lote
set precioCaficultorKg = case codigoUnico
    when 'HUI-2026-001' then 18500.00
    when 'HUI-2026-002' then 45000.00
    when 'QUI-2026-001' then 16800.00
    when 'QUI-2026-002' then 22000.00
    when 'NAR-2026-001' then 19000.00
    when 'NAR-2026-002' then 42000.00
    when 'ANT-2026-001' then 16500.00
    when 'ANT-2026-002' then 21500.00
  end
where codigoUnico in ('HUI-2026-001','HUI-2026-002','QUI-2026-001','QUI-2026-002',
                      'NAR-2026-001','NAR-2026-002','ANT-2026-001','ANT-2026-002');

-- se actualiza la vista con el nuevo dato (create or replace permite cambiarla sin borrarla)
create or replace view v_trazabilidad as
select
  lp.idLineaPedido,
  p.idPedido,
  c.nombreCliente     as cliente,
  c.pais,
  f.nombre            as finca,
  f.caficultor,
  f.municipio,
  f.altitud,
  l.codigoUnico       as codigoLote,
  l.variedad,
  l.proceso,
  pc.puntajePromedio,
  t.fechaTostion,
  t.perfil,
  l.precioCaficultorKg,
  concat(
    l.variedad, ' ', l.proceso,
    ' de Finca ', f.nombre, ', ', f.municipio,
    ' (', format(f.altitud, 0, 'de_DE'), ' m). ',
    'Puntaje ', coalesce(format(pc.puntajePromedio, 2, 'de_DE'), 'sin catar'), '. ',
    'Tostado ', t.perfil, ' el ', date_format(t.fechaTostion, '%Y-%m-%d'), '.',
    coalesce(concat(' Al caficultor se le pagaron $', format(l.precioCaficultorKg, 0, 'de_DE'), ' por kilo.'), '')
  ) as texto_qr
from LineaPedido lp
join Pedido p   on p.idPedido  = lp.idPedido
join Cliente c  on c.idCliente = p.idCliente
join Tostion t  on t.idTostion = lp.idTostion
join Lote l     on l.idLote    = t.idLote
join Finca f    on f.idFinca   = l.idFinca
left join (
  select idLote, round(avg(puntaje), 2) as puntajePromedio
  from Catacion
  group by idLote
) pc on pc.idLote = l.idLote;

select cliente, codigoLote, precioCaficultorKg, texto_qr
from v_trazabilidad
where idPedido = 1;

-- se vuelve a activar el modo seguro que se apagó en el reto 7
set sql_safe_updates = 1;

-- Reflexión Reto 10:
-- (No, una vista no guarda datos: guarda la consulta y la ejecuta cada vez. Por eso v_trazabilidad ya muestra el puntaje
-- corregido del reto 7 (HUI-2026-001 con 85,50), mientras que lotes_especialidad había copiado 86,25 en el reto 5 y se
-- quedó desactualizada. La vista no duplica datos ni hay que sincronizarla.)
