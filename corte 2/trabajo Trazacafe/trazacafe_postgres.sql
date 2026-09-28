drop database if exists trazacafe;
create database trazacafe;
\c trazacafe

drop schema if exists operacion cascade;
create schema operacion;
set search_path to operacion;


-- RETO 2: Los cimientos

create table Finca (
  idFinca       int generated always as identity primary key,
  nombre        varchar(30)  not null,
  caficultor    varchar(30)  not null,
  municipio     varchar(30)  not null,
  departamento  varchar(30)  not null,
  altitud       int          not null
);

create table Catador (
  idCatador      int generated always as identity primary key,
  nombreCatador  varchar(30) not null
);

create table Cliente (
  idCliente      int generated always as identity primary key,
  nombreCliente  varchar(30) not null
);

create table Lote (
  idLote        int generated always as identity primary key,
  codigoUnico   varchar(12)  not null,
  variedad      varchar(10)  not null,
  proceso       varchar(10)  not null,
  fechacosecha  date         not null,
  kiloslot      numeric(7,2) not null,
  idFinca       int          not null,
  constraint chk_lote_proceso check (proceso in ('lavado','honey','natural')),
  constraint FKLoteFinca foreign key (idFinca) references Finca(idFinca)
);

create table Pedido (
  idPedido   int generated always as identity primary key,
  estado     varchar(10) not null,
  idCliente  int         not null,
  constraint FKPedidoCliente foreign key (idCliente) references Cliente(idCliente)
);

create table Catacion (
  idCatacion  int generated always as identity primary key,
  puntaje     numeric(5,2) not null,
  idCatador   int          not null,
  idLote      int          not null,
  constraint FKCatacionCatador foreign key (idCatador) references Catador(idCatador),
  constraint FKCatacionLote    foreign key (idLote)    references Lote(idLote)
);

create table Tostion (
  idTostion     int generated always as identity primary key,
  fechaTostion  date         not null,
  kilosEntrada  numeric(7,2) not null,
  kilosSalida   numeric(7,2) not null,
  perfil        varchar(10)  not null,
  idLote        int          not null,
  constraint chk_tostion_perfil check (perfil in ('claro','medio','oscuro')),
  constraint FKTostionLote foreign key (idLote) references Lote(idLote)
);

create table LineaPedido (
  idLineaPedido       int generated always as identity primary key,
  preciokilosPedidos  numeric(12,2) not null,
  kilosPedidos        numeric(7,2)  not null,
  idPedido            int           not null,
  idTostion           int           not null,
  constraint FKLineaPedido  foreign key (idPedido)  references Pedido(idPedido),
  constraint FKLineaTostion foreign key (idTostion) references Tostion(idTostion)
);

\d operacion.finca
\d operacion.catador
\d operacion.cliente
\d operacion.lote
\d operacion.pedido
\d operacion.catacion
\d operacion.tostion
\d operacion.lineapedido

-- Reflexión Reto 2:
-- (Si se crea primero lote, el motor da error porque su llave foránea idFinca apunta a la tabla finca, que todavía no existe
-- (en postgresql: relation "finca" does not exist). Por eso las tablas se crean en orden: primero las que no dependen de nadie
-- y al final las que tienen llaves foráneas hacia ellas.)


-- RETO 3: Los guardianes de la calidad

alter table Finca
  add constraint chk_finca_altitud check (altitud between 800 and 2500);

alter table Lote
  add constraint uq_lote_codigo unique (codigoUnico);

alter table Catacion
  add constraint chk_catacion_puntaje check (puntaje between 0 and 100);

alter table Tostion
  add constraint chk_tostion_kilos_salida check (kilosSalida <= kilosEntrada);

alter table Tostion
  add constraint chk_tostion_kilos_entrada check (kilosEntrada > 0);

alter table Pedido
  alter column estado set default 'pendiente';

-- RESTRICT: no se borra una finca que tenga lotes (protege el historial)
alter table Lote drop constraint FKLoteFinca;
alter table Lote add constraint FKLoteFinca
  foreign key (idFinca) references Finca(idFinca) on delete restrict;

-- RESTRICT: no se borra un catador que tenga cataciones registradas
alter table Catacion drop constraint FKCatacionCatador;
alter table Catacion add constraint FKCatacionCatador
  foreign key (idCatador) references Catador(idCatador) on delete restrict;

-- RESTRICT: no se borra un lote con cataciones (el puntaje es parte de su trazabilidad)
alter table Catacion drop constraint FKCatacionLote;
alter table Catacion add constraint FKCatacionLote
  foreign key (idLote) references Lote(idLote) on delete restrict;

-- RESTRICT: no se borra un lote que ya fue tostado
alter table Tostion drop constraint FKTostionLote;
alter table Tostion add constraint FKTostionLote
  foreign key (idLote) references Lote(idLote) on delete restrict;

-- RESTRICT: no se borra un cliente que tenga pedidos
alter table Pedido drop constraint FKPedidoCliente;
alter table Pedido add constraint FKPedidoCliente
  foreign key (idCliente) references Cliente(idCliente) on delete restrict;

-- CASCADE: una línea no existe sin su pedido; si se elimina un pedido, se eliminan sus líneas
alter table LineaPedido drop constraint FKLineaPedido;
alter table LineaPedido add constraint FKLineaPedido
  foreign key (idPedido) references Pedido(idPedido) on delete cascade;

-- RESTRICT: no se borra una tostión que ya se vendió
alter table LineaPedido drop constraint FKLineaTostion;
alter table LineaPedido add constraint FKLineaTostion
  foreign key (idTostion) references Tostion(idTostion) on delete restrict;

insert into Finca (nombre, caficultor, municipio, departamento, altitud)
values ('Finca 1', 'Caficultor 1', 'Pitalito', 'Huila', 1600);
insert into Catador (nombreCatador) values ('Catador #1');
insert into Cliente (nombreCliente) values ('Cliente #1');
insert into Lote (codigoUnico, variedad, proceso, fechacosecha, kiloslot, idFinca)
values ('PRB-2026-001', 'Caturra', 'lavado', '2026-03-01', 500.00, 1);
insert into Tostion (fechaTostion, kilosEntrada, kilosSalida, perfil, idLote)
values ('2026-03-10', 100.00, 84.00, 'medio', 1);

insert into Finca (nombre, caficultor, municipio, departamento, altitud)
values ('Finca Alta', 'Caficultor X', 'Salento', 'Quindío', 3000);
/* ERROR:  new row for relation "finca" violates check constraint "chk_finca_altitud" */

insert into Lote (codigoUnico, variedad, proceso, fechacosecha, kiloslot, idFinca)
values ('PRB-2026-001', 'Geisha', 'natural', '2026-03-05', 200.00, 1);
/* ERROR:  duplicate key value violates unique constraint "uq_lote_codigo"
   DETAIL:  Key (codigounico)=(PRB-2026-001) already exists. */

insert into Catacion (puntaje, idCatador, idLote) values (105.00, 1, 1);
/* ERROR:  new row for relation "catacion" violates check constraint "chk_catacion_puntaje" */

insert into Tostion (fechaTostion, kilosEntrada, kilosSalida, perfil, idLote)
values ('2026-03-11', 100.00, 120.00, 'claro', 1);
/* ERROR:  new row for relation "tostion" violates check constraint "chk_tostion_kilos_salida" */

insert into Tostion (fechaTostion, kilosEntrada, kilosSalida, perfil, idLote)
values ('2026-03-12', 0.00, 0.00, 'oscuro', 1);
/* ERROR:  new row for relation "tostion" violates check constraint "chk_tostion_kilos_entrada" */

insert into Pedido (idCliente) values (1);
select idPedido, estado from Pedido;

insert into Lote (codigoUnico, variedad, proceso, fechacosecha, kiloslot, idFinca)
values ('PRB-2026-002', 'Bourbon', 'honey', '2026-03-06', 150.00, 999);
/* ERROR:  insert or update on table "lote" violates foreign key constraint "fklotefinca"
   DETAIL:  Key (idfinca)=(999) is not present in table "finca". */

delete from Finca where idFinca = 1;
/* ERROR:  update or delete on table "finca" violates foreign key constraint "fklotefinca" on table "lote"
   DETAIL:  Key (idfinca)=(1) is still referenced from table "lote". */

insert into Lote (codigoUnico, variedad, proceso, fechacosecha, kiloslot, idFinca)
values ('PRB-2026-003', 'Castillo', 'semilavado', '2026-03-07', 150.00, 1);
/* ERROR:  new row for relation "lote" violates check constraint "chk_lote_proceso" */

delete from Pedido;
delete from Tostion;
delete from Lote;
delete from Finca;
delete from Catador;
delete from Cliente;

-- Reflexión Reto 3:
-- (Un CHECK solo evalúa las columnas de la misma fila, así que no puede
-- expresar reglas que dependan de otras filas o de otras tablas. Por ejemplo, "solo es café
-- de especialidad desde 80" depende del promedio de varias cataciones del mismo lote, y el
-- req. 6  que es no perder el historial se cumple con las llaves foráneas ON DELETE RESTRICT.)


-- RETO 4: Llegó el correo de Berlín

alter table Cliente
  add column pais varchar(40) not null default 'Colombia';

alter table Tostion
  add column huella_carbono_kg numeric(8,2) null;
alter table Tostion
  add constraint chk_tostion_huella check (huella_carbono_kg >= 0);

alter table Lote        alter column kiloslot     type numeric(10,2);
alter table Tostion     alter column kilosEntrada type numeric(10,2);
alter table Tostion     alter column kilosSalida  type numeric(10,2);
alter table LineaPedido alter column kilosPedidos type numeric(10,2);

create table Certificacion (
  idCertificacion      int generated always as identity primary key,
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
alter table LineaPedido rename column preciokilosPedidos to precioKilo;

\d operacion.cliente
\d operacion.tostion
\d operacion.lote
\d operacion.lineapedido
\d operacion.certificacion
\d operacion.fincacertificacion

-- Reflexión Reto 4:
-- (Al borrar y recrear una tabla se pierden sus filas, y en mi modelo además hay llaves foráneas que la apuntan:
-- por ejemplo, no se puede borrar Tostion sin romper LineaPedido, ni Finca sin romper Lote y FincaCertificacion.
-- Con alter table los clientes que ya existían se quedan y toman pais = 'Colombia' por defecto, sin detener el sistema.)


-- RETO 5: La primera cosecha

alter table Finca        alter column idFinca       restart with 1;
alter table Catador      alter column idCatador     restart with 1;
alter table Cliente      alter column idCliente     restart with 1;
alter table Lote         alter column idLote        restart with 1;
alter table Pedido       alter column idPedido      restart with 1;
alter table Catacion     alter column idCatacion    restart with 1;
alter table Tostion      alter column idTostion     restart with 1;
alter table LineaPedido  alter column idLineaPedido restart with 1;

insert into Finca (nombre, caficultor, municipio, departamento, altitud) values
  ('La Esperanza', 'Jorge Cuéllar',   'Pitalito', 'Huila',     1750),
  ('El Mirador',   'Luz Marina Ríos', 'Salento',  'Quindío',   1850),
  ('Los Naranjos', 'Pedro Enríquez',  'Buesaco',  'Nariño',    1950),
  ('Villa Clara',  'Rosa Elena Mejía','Jardín',   'Antioquia', 1700);

insert into Catador (nombreCatador) values
  ('Andrea Salazar'),
  ('Felipe Rojas'),
  ('Camila Ortiz');

insert into Cliente (nombreCliente, pais) values
  ('Café Andino Bogotá', default),
  ('Barista Medellín',   default),
  ('Tostadora de Berlín','Alemania');

insert into Lote (codigoUnico, variedad, proceso, fechacosecha, kiloslot, idFinca) values
  ('HUI-2026-001', 'Caturra',  'lavado',  '2026-01-15', 1200.00, 1),
  ('HUI-2026-002', 'Geisha',   'natural', '2026-01-20',  350.00, 1),
  ('QUI-2026-001', 'Castillo', 'lavado',  '2026-02-03',  900.00, 2),
  ('QUI-2026-002', 'Bourbon',  'honey',   '2026-02-10',  400.00, 2),
  ('NAR-2026-001', 'Caturra',  'lavado',  '2026-02-18',  800.00, 3),
  ('NAR-2026-002', 'Geisha',   'honey',   '2026-02-25',  300.00, 3),
  ('ANT-2026-001', 'Castillo', 'natural', '2026-03-01', 1000.00, 4),
  ('ANT-2026-002', 'Bourbon',  'lavado',  '2026-03-05',  600.00, 4);

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

insert into Tostion (fechaTostion, kilosEntrada, kilosSalida, perfil, idLote, huella_carbono_kg) values
  ('2026-03-02', 100.00,  84.50, 'medio',  1, 12.40),
  ('2026-03-04',  50.00,  42.00, 'claro',  2,  6.10),
  ('2026-03-06', 120.00, 100.80, 'oscuro', 3, null),
  ('2026-03-08',  80.00,  67.20, 'medio',  5,  9.75),
  ('2026-03-09',  40.00,  33.60, 'claro',  6, null);

insert into Pedido (idCliente) values
  (3),
  (1),
  (3),
  (2);

insert into LineaPedido (precioKilo, kilosPedidos, idPedido, idTostion) values
  ( 95000.00, 30.00, 1, 1),
  (210000.00, 20.00, 1, 2),
  ( 70000.00, 50.00, 2, 3),
  ( 98000.00, 25.00, 3, 4),
  (190000.00, 15.00, 3, 5),
  ( 72000.00, 40.00, 4, 3);

insert into Certificacion (nombreCertificacion) values
  ('Orgánico'),
  ('Fair Trade');

insert into FincaCertificacion (idFinca, idCertificacion) values
  (1, 1),
  (1, 2),
  (3, 2),
  (4, 1);

create table lotes_especialidad (
  codigoLote       varchar(12)  primary key,
  puntajePromedio  numeric(5,2) not null
);

insert into lotes_especialidad (codigoLote, puntajePromedio)
select l.codigoUnico, round(avg(c.puntaje), 2)
from Lote l
join Catacion c on c.idLote = l.idLote
group by l.codigoUnico
having avg(c.puntaje) >= 85;

select * from lotes_especialidad;

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

create table precios_referencia (
  variedad        varchar(10)   primary key,
  precio_kg       numeric(12,2) not null,
  actualizado_en  timestamp     not null default current_timestamp
);

insert into precios_referencia (variedad, precio_kg) values
  ('Castillo',  32000.00),
  ('Caturra',   35500.00),
  ('Geisha',   120000.00);

select * from precios_referencia;

select pg_sleep(2);

insert into precios_referencia (variedad, precio_kg) values
  ('Caturra',  36800.00),
  ('Geisha',  118000.00),
  ('Bourbon',  41000.00)
on conflict (variedad)
do update set
  precio_kg = excluded.precio_kg,
  actualizado_en = now();

select * from precios_referencia order by variedad;
select count(*) as variedades from precios_referencia;

-- Reflexión Reto 6:
-- (El upsert solo sabe que una variedad ya existe si hay una llave primaria o unique sobre ella. En postgresql, sin esa
-- restricción, on conflict (variedad) ni siquiera corre: da error porque no hay una restricción que coincida. Y sin el
-- on conflict, la semana 2 insertaría Caturra y Geisha otra vez: 6 filas en vez de 4, con dos precios para la misma variedad.)


-- RETO 7: La balanza descalibrada

-- antes: deben cambiar 4 filas (86.50, 89.75, 85.00 y 79.50)
select c.idCatacion, c.idLote, c.puntaje
from Catacion c
join Catador ca on ca.idCatador = c.idCatador
where ca.nombreCatador = 'Andrea Salazar';

update Catacion c
set puntaje = greatest(c.puntaje - 1.5, 0)
from Catador ca
where ca.idCatador = c.idCatador
  and ca.nombreCatador = 'Andrea Salazar';
-- el motor debe reportar: UPDATE 4

select c.idCatacion, c.idLote, c.puntaje
from Catacion c
join Catador ca on ca.idCatador = c.idCatador
where ca.nombreCatador = 'Andrea Salazar';

-- antes: deben cambiar 4 filas (pedidos 1 y 3 de la Tostadora de Berlín: 95000, 210000, 98000 y 190000)
select lp.idLineaPedido, lp.idPedido, lp.precioKilo, c.nombreCliente, c.pais
from LineaPedido lp
join Pedido p  on p.idPedido  = lp.idPedido
join Cliente c on c.idCliente = p.idCliente
where c.pais = 'Alemania';

update LineaPedido lp
set precioKilo = lp.precioKilo * 0.90
from Pedido p
join Cliente c on c.idCliente = p.idCliente
where p.idPedido = lp.idPedido
  and c.pais = 'Alemania';
-- el motor debe reportar: UPDATE 4

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

select l.codigoUnico, lp.idPedido, lp.kilosPedidos
from Finca f
join Lote l         on l.idFinca    = f.idFinca
join Tostion t      on t.idLote     = l.idLote
join LineaPedido lp on lp.idTostion = t.idTostion
where f.nombre = 'La Esperanza';

delete from Finca where nombre = 'La Esperanza';
/* ERROR:  update or delete on table "finca" violates foreign key constraint "fklotefinca" on table "lote"
   DETAIL:  Key (idfinca)=(1) is still referenced from table "lote". */

alter table Finca
  add column activa boolean not null default true;

update Finca
set activa = false
where nombre = 'La Esperanza';

select idFinca, nombre, activa from Finca;

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

delete from Catacion c
using Lote l
where l.idLote = c.idLote
  and l.codigoUnico = 'PRB-2026-100';
-- el motor debe reportar: DELETE 2

truncate table lotes_especialidad restart identity;
select count(*) as filas from lotes_especialidad;

drop table lotes_especialidad;
select to_regclass('operacion.lotes_especialidad') as existe;

-- Reflexión Reto 8:
-- (DELETE es DML: borra solo las filas que cumplen el where, como las 2 cataciones de PRB-2026-100, respeta las llaves
-- foráneas (por eso no dejó borrar La Esperanza) y se puede deshacer dentro de una transacción. TRUNCATE es DDL: vacía
-- toda lotes_especialidad de golpe, sin where, y reinicia el contador. DROP también es DDL: elimina la tabla con su estructura.)


-- RETO 9: El pedido que no puede quedar a medias

alter table Tostion
  add column kilosDisponibles numeric(10,2) not null default 0;

update Tostion t
set kilosDisponibles = t.kilosSalida - coalesce((select sum(lp.kilosPedidos)
                                                 from LineaPedido lp
                                                 where lp.idTostion = t.idTostion), 0);

alter table Tostion
  add constraint chk_tostion_kilos_disponibles check (kilosDisponibles >= 0);

select idTostion, kilosSalida, kilosDisponibles from Tostion order by idTostion;

begin;

insert into Pedido (idCliente) values (2);

insert into LineaPedido (precioKilo, kilosPedidos, idPedido, idTostion) values
  (98000.00, 10.00, currval(pg_get_serial_sequence('pedido', 'idpedido')), 4),
  (95000.00, 15.00, currval(pg_get_serial_sequence('pedido', 'idpedido')), 1);

update Tostion set kilosDisponibles = kilosDisponibles - 10 where idTostion = 4;
update Tostion set kilosDisponibles = kilosDisponibles - 15 where idTostion = 1;

commit;

select * from Pedido      where idPedido = currval(pg_get_serial_sequence('pedido', 'idpedido'));
select * from LineaPedido where idPedido = currval(pg_get_serial_sequence('pedido', 'idpedido'));
select idTostion, kilosDisponibles from Tostion where idTostion in (1, 4);

begin;

insert into Pedido (idCliente) values (2);

insert into LineaPedido (precioKilo, kilosPedidos, idPedido, idTostion) values
  ( 98000.00,   5.00, currval(pg_get_serial_sequence('pedido', 'idpedido')), 4),
  (210000.00, 500.00, currval(pg_get_serial_sequence('pedido', 'idpedido')), 2);

update Tostion set kilosDisponibles = kilosDisponibles - 5   where idTostion = 4;
update Tostion set kilosDisponibles = kilosDisponibles - 500 where idTostion = 2;
/* ERROR:  new row for relation "tostion" violates check constraint "chk_tostion_kilos_disponibles" */

rollback;

select * from Pedido      where idPedido = currval(pg_get_serial_sequence('pedido', 'idpedido'));
select * from LineaPedido where idPedido = currval(pg_get_serial_sequence('pedido', 'idpedido'));
select idTostion, kilosDisponibles from Tostion where idTostion in (2, 4);

begin;

insert into Pedido (idCliente) values (1);

insert into LineaPedido (precioKilo, kilosPedidos, idPedido, idTostion)
values (190000.00, 5.00, currval(pg_get_serial_sequence('pedido', 'idpedido')), 5);
update Tostion set kilosDisponibles = kilosDisponibles - 5 where idTostion = 5;

savepoint antes_segunda_linea;

insert into LineaPedido (precioKilo, kilosPedidos, idPedido, idTostion)
values (72000.00, 50.00, currval(pg_get_serial_sequence('pedido', 'idpedido')), 3);
update Tostion set kilosDisponibles = kilosDisponibles - 50 where idTostion = 3;

rollback to savepoint antes_segunda_linea;

commit;

select * from Pedido      where idPedido = currval(pg_get_serial_sequence('pedido', 'idpedido'));
select * from LineaPedido where idPedido = currval(pg_get_serial_sequence('pedido', 'idpedido'));
select idTostion, kilosDisponibles from Tostion where idTostion in (3, 5);

begin;
create table prueba (id int primary key);
rollback;

select to_regclass('operacion.prueba') as existe;

drop table if exists prueba;

-- Reflexión Reto 9:
-- (En MySQL el create table hizo commit implícito y la tabla prueba siguió existiendo después del rollback; en postgresql
-- el rollback sí la deshizo. El riesgo en MySQL: si una migración como la del reto 4 falla a la mitad, los alter table que
-- ya corrieron se quedan (pais agregada pero huella_carbono_kg no) y la base queda a medias; en postgresql se puede meter
-- toda la migración en un begin ... commit y si algo falla no queda nada aplicado.)


-- RETO 10: El QR que cuenta la historia
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
    ' (', replace(to_char(f.altitud, 'FM9,999'), ',', '.'), ' m). ',
    'Puntaje ', coalesce(replace(to_char(pc.puntajePromedio, 'FM990.00'), '.', ','), 'sin catar'), '. ',
    'Tostado ', t.perfil, ' el ', to_char(t.fechaTostion, 'YYYY-MM-DD'), '.'
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

select cliente, pais, codigoLote, texto_qr
from v_trazabilidad
where idPedido = 1;

select * from v_trazabilidad;

-- Reto creativo: precio pagado al caficultor por kilo. Al consumidor de café de especialidad le importa saber que el caficultor recibió un pago justo;
-- ponerlo en el QR hace la historia verificable también en lo económico, no solo en el origen.
alter table Lote
  add column precioCaficultorKg numeric(12,2) null;

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
    ' (', replace(to_char(f.altitud, 'FM9,999'), ',', '.'), ' m). ',
    'Puntaje ', coalesce(replace(to_char(pc.puntajePromedio, 'FM990.00'), '.', ','), 'sin catar'), '. ',
    'Tostado ', t.perfil, ' el ', to_char(t.fechaTostion, 'YYYY-MM-DD'), '.',
    case when l.precioCaficultorKg is not null
         then concat(' Al caficultor se le pagaron $', replace(to_char(l.precioCaficultorKg, 'FM999,999,990'), ',', '.'), ' por kilo.')
         else ''
    end
  ) as texto_qr,
  l.precioCaficultorKg
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

-- Reflexión Reto 10:
-- (No, una vista no guarda datos: guarda la consulta y la ejecuta cada vez. Por eso v_trazabilidad ya muestra el puntaje
-- corregido del reto 7 (HUI-2026-001 con 85,50), mientras que lotes_especialidad había copiado 86,25 en el reto 5 y se
-- quedó desactualizada. La vista no duplica datos ni hay que sincronizarla.)
