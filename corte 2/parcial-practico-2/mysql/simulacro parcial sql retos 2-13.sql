-- R2 creacion de la base de datos
drop database if exists dronandes;
create database dronandes;
use dronandes;
-- creacion de tablas por prioridad
create table bases (
    idbase          int auto_increment primary key,
    nombre           varchar(60) not null unique,
    municipio        varchar(60) not null,
    departamento     varchar(40) not null,
    capacidaddrones int not null,
    fechaapertura   date not null,
    constraint chk_basescapacidad check (capacidaddrones > 0)
);

create table tiposcarga (
    idtipo       int auto_increment primary key,
    nombre        varchar(40) not null unique,
    tarifakg     decimal(10,2) not null,
    requierefrio boolean not null default false,
    constraint chk_tiposcargatarifa check (tarifakg > 0)
);

create table drones (
    iddron           int auto_increment primary key,
    codigoserie      varchar(12) not null unique,
    modelo            varchar(40) not null,
    cargamax_kg      decimal(5,2) not null,
    autonomia_km      decimal(5,1) not null,
    estado            varchar(15) not null default 'ACTIVO',
    horasvuelo       decimal(7,1) not null default 0,
    fechaadquisicion date not null,
    idbase           int not null,
    constraint chk_dronesautonomia check (autonomia_km > 0),
    constraint chk_dronesestado    check (estado in ('ACTIVO', 'MANTENIMIENTO', 'RETIRADO')),
    constraint chk_droneshoras     check (horasvuelo >= 0),
    constraint fk_dronesbase foreign key (idbase) references bases (idbase)
);

create table pilotos (
    idpiloto     int auto_increment primary key,
    documento     varchar(15) not null unique,
    nombres       varchar(50) not null,
    apellidos     varchar(50) not null,
    email         varchar(80) not null unique,
    licencia      char(1) not null,
    fechaingreso date not null,
    idsupervisor int null,
    idbase       int not null,
    constraint chk_pilotoslicencia check (licencia in ('A', 'B', 'C')),
    constraint fk_pilotosbase foreign key (idbase) references bases (idbase)
);

create table clientes (
    idcliente     int auto_increment primary key,
    tipo           varchar(12) not null,
    nombre         varchar(80) not null,
    nit_o_documento  varchar(15) not null unique,
    email          varchar(80) null unique,
    telefono       varchar(15) null,
    municipio      varchar(60) not null,
    fecharegistro timestamp default current_timestamp,
    constraint chk_clientestipo check (tipo in ('HOSPITAL', 'FARMACIA', 'COMERCIO', 'ONG', 'PERSONA'))
);


create table entregas (
    identrega        int auto_increment primary key,
    codigo            varchar(10) not null unique,
    idcliente        int not null,
    iddron           int not null,
    idpiloto         int not null,
    fechaprogramada  datetime not null,
    fechaentrega     datetime null,
    municipiodestino varchar(60) not null,
    distancia_km      decimal(5,1) not null,
    prioridad         varchar(8) not null default 'NORMAL',
    estado            varchar(12) not null default 'PROGRAMADA',
    calificacion      smallint null,
    constraint chk_entregasdistancia     check (distancia_km > 0),
    constraint chk_entregasprioridad     check (prioridad in ('NORMAL', 'URGENTE', 'VITAL')),
    constraint chk_entregasestado        check (estado in ('PROGRAMADA', 'EN_VUELO', 'ENTREGADA', 'CANCELADA', 'FALLIDA')),
    constraint chk_entregascalificacion  check (calificacion between 1 and 5),
    constraint chk_entregasfechaentrega check (fechaentrega is null or estado = 'ENTREGADA'),
    constraint fk_entregascliente foreign key (idcliente) references clientes (idcliente),
    constraint fk_entregasdron    foreign key (iddron)    references drones (iddron),
    constraint fk_entregaspiloto  foreign key (idpiloto)  references pilotos (idpiloto)
);


create table carga_entrega (
    primary key (identrega, idtipo),
    identrega int not null,
    idtipo    int not null,
    peso_kg    decimal(6,2) not null,
    unidades   int not null default 1,
    constraint chk_cargaentregapeso     check (peso_kg > 0),
    constraint chk_cargaentregaunidades check (unidades > 0),
    constraint fk_cargaentregaentrega foreign key (identrega) references entregas (identrega),
    constraint fk_cargaentregatipo    foreign key (idtipo)    references tiposcarga (idtipo)
);

create table mantenimientos (
    idmantenimiento int auto_increment primary key,
    iddron          int not null,
    fecha            date not null,
    tipo             varchar(12) not null,
    descripcion      varchar(200) null,
    costo            decimal(10,2) not null,
    constraint chk_mantenimientostipo  check (tipo in ('PREVENTIVO', 'CORRECTIVO')),
    constraint chk_mantenimientoscosto check (costo >= 0),
    constraint fk_mantenimientosdron foreign key (iddron) references drones (iddron)
);

create table historialentregas (
    idhistorial    int auto_increment primary key,
    identrega      int not null,
    estadoanterior varchar(12) not null,
    estadonuevo    varchar(12) not null,
    fechacambio    datetime not null default current_timestamp,
    constraint fk_historialentregasentrega foreign key (identrega) references entregas (identrega)
);

-- DATOS INICIALES — Proyecto Cóndor (DronAndes Express S.A.S.)
-- Corte: 30 de septiembre de 2026, 18:00
-- Script COMÚN para MySQL y PostgreSQL. Ejecutar DESPUÉS del DDL (R2).

insert into  bases (idbase, nombre, municipio, departamento, capacidaddrones,
fechaapertura) values
(1, 'Base Cóndor', 'Rionegro', 'Antioquia', 6, '2024-02-15'),
(2, 'Base Colibrí', 'Guatapé', 'Antioquia', 4, '2024-08-01'),
(3, 'Base Frailejón', 'Tunja', 'Boyacá', 5, '2025-01-20'),
(4, 'Base Guadua', 'Salento', 'Quindío', 3, '2026-07-01');
insert into tiposcarga (idtipo, nombre, tarifakg, requierefrio) values
(1, 'Vacunas', 12000, TRUE),
(2, 'Muestras de laboratorio', 10000, TRUE),
(3, 'Medicamentos', 8000, FALSE),
(4, 'Documentos', 5000, FALSE),
(5, 'Repuestos', 4500, FALSE),
(6, 'Alimentos', 3500, FALSE);
insert into drones (iddron, codigoserie, modelo, cargamax_kg, autonomia_km, estado,
horasvuelo, fechaadquisicion, idbase) values
(1, 'DA-CX4-01', 'Cóndor X4', 8.00, 45.0, 'ACTIVO', 312.5, '2024-02-20', 1),
(2, 'DA-CX4-02', 'Cóndor X4', 8.00, 45.0, 'ACTIVO', 468.0, '2024-03-10', 1),
(3, 'DA-CX6-01', 'Cóndor X6', 15.00, 60.0, 'ACTIVO', 205.0, '2025-01-15', 1),
(4, 'DA-COL-01', 'Colibrí Mini', 2.50, 25.0, 'ACTIVO', 520.5, '2024-08-05', 2),
(5, 'DA-COL-02', 'Colibrí Mini', 2.50, 25.0, 'MANTENIMIENTO', 610.0, '2024-08-05', 2),
(6, 'DA-ALB-01', 'Albatros H8', 25.00, 90.0, 'ACTIVO', 98.0, '2025-02-01', 3),
(7, 'DA-CX6-02', 'Cóndor X6', 15.00, 60.0, 'ACTIVO', 150.5, '2025-03-12', 3),
(8, 'DA-ALB-02', 'Albatros H8', 25.00, 90.0, 'RETIRADO', 890.0, '2024-05-01', 3);
-- Los supervisores (id_supervisor NULL) se insertan primero.
insert into pilotos (idpiloto, documento, nombres, apellidos, email, licencia, fechaingreso,
idsupervisor, idbase) values
(1, '1036600111', 'Laura', 'Restrepo Gil', 'laura.restrepo@dronandes.co', 'C', '2024-02-01', NULL,
1),
(2, '1049600222', 'Camilo', 'Duarte Rojas', 'camilo.duarte@dronandes.co', 'C', '2025-01-10', NULL,
3),
(3, '1036600333', 'Mateo', 'Zapata Vélez', 'mateo.zapata@dronandes.co', 'B', '2024-04-15', 1, 1),
(4, '1036600444', 'Sara', 'Montoya Ruiz', 'sara.montoya@dronandes.co', 'B', '2024-08-10', 1, 2),
(5, '1036600555', 'Julián', 'Patiño Cruz', 'julian.patino@dronandes.co', 'A', '2025-06-01', 1, 2),
(6, '1049600666', 'Daniela', 'Suárez León', 'daniela.suarez@dronandes.co', 'B', '2025-02-01', 2, 3),
(7, '1049600777', 'Tomás', 'Becerra Niño', 'tomas.becerra@dronandes.co', 'A', '2026-06-15', 2, 3);
insert into clientes (idcliente, tipo, nombre, nit_o_documento, email, telefono, municipio,
fecharegistro) values
(1, 'HOSPITAL', 'Hospital San Juan de Dios de Rionegro', '890980000-1', 'compras@hsjdrionegro.org',
'6045310000', 'Rionegro', '2024-03-01'),
(2, 'FARMACIA', 'Droguería La Esperanza', '71234567', 'esperanza.drogueria@gmail.com',
'3104567890', 'Guatapé', '2024-09-12'),
(3, 'HOSPITAL', 'E.S.E. Hospital San Rafael de Tunja', '891800231-6', 'Logistica@HSRTunja.gov.co',
'6087405050', 'Tunja', '2025-01-25'),
(4, 'ONG', 'Fundación Alas para el Campo', '900456789-2', 'contacto@alasparaelcampo.org',
NULL, 'Marinilla', '2024-11-03'),
(5, 'COMERCIO', 'Repuestos Agrícolas El Arriero', '900123456-7', NULL, '31245678',
'El Peñol', '2025-04-18'),
(6, 'PERSONA', 'Mariana Gómez Arango', '1040123456', 'mariana.gomez@hotmail.com',
'3157778899', 'Guarne', '2025-07-07'),
(7, 'FARMACIA', 'Farmacia Botica del Páramo', '900777888-1', 'boticaparamo@gmail.com',
'3209998877', 'Ventaquemada', '2025-02-14'),
(8, 'COMERCIO', 'Café de Altura Las Nubes', '901222333-4', 'ventas@cafelasnubes.co',
'3001112233', 'Salento', '2026-07-20'),
(9, 'PERSONA', 'Jorge Iván Ríos', '79888777', NULL, NULL, 'Rionegro',
'2026-08-30'),
(10, 'ONG', 'Corporación Montaña Viva', '900999111-0', 'info@montanaviva.org',
'310555444', 'Sáchica', '2025-09-01');
insert into entregas (identrega, codigo, idcliente, iddron, idpiloto, fechaprogramada,
fechaentrega, municipiodestino, distancia_km, prioridad, estado, calificacion) values
(1, 'ENT-0001', 1, 1, 3, '2026-08-03 08:00:00', '2026-08-03 08:42:00', 'San Vicente', 18.5, 'VITAL',
'ENTREGADA', 5),
(2, 'ENT-0002', 1, 3, 1, '2026-08-05 09:30:00', '2026-08-05 10:20:00', 'Concepción', 32.0,
'VITAL', 'ENTREGADA', 4),
(3, 'ENT-0003', 2, 4, 4, '2026-08-07 14:00:00', '2026-08-07 14:25:00', 'San Rafael', 12.0,
'NORMAL', 'ENTREGADA', 5),
(4, 'ENT-0004', 4, 2, 3, '2026-08-10 07:45:00', '2026-08-10 08:30:00', 'El Carmen de Viboral', 22.4,
'URGENTE', 'ENTREGADA', 3),
(5, 'ENT-0005', 5, 3, 1, '2026-08-12 11:00:00', NULL, 'El Peñol', 15.0, 'NORMAL',
'CANCELADA', NULL),
(6, 'ENT-0006', 3, 6, 2, '2026-08-14 06:30:00', '2026-08-14 07:40:00', 'Ramiriquí', 48.0, 'VITAL',
'ENTREGADA', 5),
(7, 'ENT-0007', 10, 7, 6, '2026-08-18 10:00:00', '2026-08-18 10:35:00', 'Samacá', 20.5,
'NORMAL', 'ENTREGADA', 4),
(8, 'ENT-0008', 3, 8, 6, '2026-08-20 08:15:00', NULL, 'Chíquiza', 35.0, 'URGENTE',
'FALLIDA', NULL),
(9, 'ENT-0009', 6, 4, 5, '2026-08-22 16:00:00', '2026-08-22 16:20:00', 'Guarne', 9.5, 'NORMAL',
'ENTREGADA', 2),
(10, 'ENT-0010', 1, 1, 1, '2026-08-25 07:00:00', '2026-08-25 07:50:00', 'Sonsón', 41.0, 'VITAL',
'ENTREGADA', 5),
(11, 'ENT-0011', 10, 6, 2, '2026-08-27 09:00:00', '2026-08-27 10:05:00', 'Sáchica', 52.5,
'URGENTE', 'ENTREGADA', NULL),
(12, 'ENT-0012', 2, 5, 4, '2026-08-29 13:00:00', NULL, 'Alejandría', 14.0, 'NORMAL',
'CANCELADA', NULL),
(13, 'ENT-0013', 4, 2, 1, '2026-09-01 08:00:00', '2026-09-01 08:55:00', 'Granada', 38.0,
'URGENTE', 'ENTREGADA', 4),
(14, 'ENT-0014', 1, 3, 1, '2026-09-03 10:30:00', '2026-09-03 11:15:00', 'Abejorral', 44.0, 'VITAL',
'ENTREGADA', 5),
(15, 'ENT-0015', 7, 7, 6, '2026-09-08 15:00:00', '2026-09-08 15:30:00', 'Turmequé', 17.0,
'NORMAL', 'ENTREGADA', 3),
(16, 'ENT-0016', 3, 6, 2, '2026-09-15 06:00:00', '2026-09-15 07:10:00', 'Miraflores', 58.0, 'VITAL',
'ENTREGADA', 4),
(17, 'ENT-0017', 6, 2, 3, '2026-09-21 17:00:00', NULL, 'Guarne', 10.0, 'NORMAL',
'CANCELADA', NULL),
(18, 'ENT-0018', 10, 7, 6, '2026-09-30 17:40:00', NULL, 'Villa de Leyva', 26.0, 'NORMAL',
'EN_VUELO', NULL),
(19, 'ENT-0019', 1, 1, 1, '2026-10-01 07:30:00', NULL, 'Nariño', 47.0, 'VITAL',
'PROGRAMADA', NULL),
(20, 'ENT-0020', 3, 6, 6, '2026-10-02 06:00:00', NULL, 'Pesca', 39.0, 'VITAL',
'PROGRAMADA', NULL);
insert into carga_entrega (identrega, idtipo, peso_kg, unidades) values
(1, 1, 3.00, 60), (1, 3, 2.00, 15),
(2, 2, 1.50, 30), (2, 3, 4.00, 40),
(3, 3, 1.80, 12),
(4, 3, 3.50, 25), (4, 4, 0.50, 3),
(5, 5, 6.00, 4),
(6, 1, 5.00, 100), (6, 2, 2.00, 40),
(7, 3, 6.00, 50),
(8, 1, 8.00, 160), (8, 3, 4.00, 30),
(9, 4, 0.80, 5),
(10, 1, 4.00, 80), (10, 2, 1.00, 20), (10, 3, 2.50, 20),
(11, 3, 7.00, 60), (11, 4, 1.00, 6),
(13, 3, 5.00, 40), (13, 5, 2.00, 2),
(14, 1, 6.00, 120), (14, 2, 3.00, 60),
(15, 3, 3.00, 25), (15, 4, 0.30, 2),
(16, 1, 10.00, 200), (16, 3, 8.00, 70),
(18, 3, 4.00, 35),
(19, 1, 3.50, 70),
(20, 2, 2.50, 50), (20, 1, 6.00, 120);
insert into mantenimientos (idmantenimiento, iddron, fecha, tipo, descripcion, costo) values
(1, 2, '2026-03-15', 'PREVENTIVO', 'Cambio de hélices', 350000),
(2, 4, '2026-04-02', 'PREVENTIVO', 'Calibración de GPS', 180000),
(3, 5, '2026-09-25', 'CORRECTIVO', 'Falla en motor 3', 1250000),
(4, 8, '2026-08-21', 'CORRECTIVO', 'Impacto en aterrizaje, evaluación de daños', 2800000),
(5, 1, '2026-06-10', 'PREVENTIVO', 'Revisión general de 300 horas', 420000),
(6, 6, '2026-07-05', 'PREVENTIVO', NULL, 260000),
(7, 5, '2026-05-14', 'PREVENTIVO', 'Cambio de baterías', 950000),
(8, 2, '2026-09-12', 'CORRECTIVO', 'Sensor de altitud defectuoso', 610000);
-- ---------------------------------------------------------------------------------------
-- R3. Ajustes estructurales solicitados por Calidad
-- a) ampliar clientes.nombre a 120 sin perder el not null
alter table clientes modify nombre varchar(120) not null;
 
-- b) la aeronautica solo certifica cargas entre 0,5 y 25 kg
alter table drones
add constraint chk_dronescarga check (cargamax_kg between 0.5 and 25);
 
-- c) el supervisor de un piloto debe ser un piloto existente (relacion recursiva)
alter table pilotos
    add constraint fk_pilotossupervisor
    foreign key (idsupervisor) references pilotos (idpiloto);
-- ---------------------------------------
-- R4  Operaciones de datos (DML)
-- a) tres clientes nuevos en un solo insert, sin escribir idcliente
insert into clientes (tipo, nombre, nit_o_documento, email, telefono, municipio, fecharegistro) values
('FARMACIA', 'Droguería Santa Ana', '900314159-2', 'santaana@gmail.com', '3112223344', 'Marinilla', '2026-09-28'),
('PERSONA', 'Esteban Mejía Toro', '1036987654', null, '3015556677', 'Rionegro', '2026-09-29'),
('COMERCIO', 'Tienda Naturista Frailejón', '901555666-3', 'tienda.frailejon@outlook.com', '3209871234', 'Tunja', '2026-09-30');
 
-- b) RN-07: todo dron activo con mas de 500 horas pasa a mantenimiento
set sql_safe_updates = 0; -- permite que el update y el delete se ejecuten.
update drones
set estado = 'MANTENIMIENTO'
where estado = 'ACTIVO' and horasvuelo > 500;

-- c) eliminar entregas canceladas que no tienen ninguna carga registrada 
delete from entregas
where estado = 'CANCELADA'
  and identrega not in (select identrega from carga_entrega);
 
-- d) totales en una sola salida (evidencia 03)
select (select count(*) from clientes) as total_clientes,
       (select count(*) from entregas) as total_entregas,
       (select count(*) from drones where estado = 'MANTENIMIENTO')  as drones_mantenimiento;
-- --------------------------------------------------------------------------------------------------------
-- R5. Tablero de control operativo
-- a) entregas entregadas de media distancia y prioridad alta
select codigo, municipiodestino as municipio_destino, distancia_km, prioridad
from entregas
where estado = 'ENTREGADA'
  and distancia_km between 20 and 45
  and prioridad in ('VITAL', 'URGENTE')
order by distancia_km desc;
 
 -- punto b
-- 1) entregas cerradas sin entrega efectiva
select codigo, estado, fechaprogramada as fecha_programada
from entregas
where estado not in ('PROGRAMADA', 'EN_VUELO', 'ENTREGADA')
  and fechaentrega is null
order by codigo;
 
-- 2) entregas con fecha de entrega pero sin calificacion
select codigo, fechaentrega as fecha_entrega
from entregas
where fechaentrega is not null
  and calificacion is null;
 
-- c) drones para la campaña de carga pesada : and se evalua antes que or
select codigoserie as codigo_serie, modelo, cargamax_kg as carga_max_kg,
       horasvuelo as horas_vuelo, autonomia_km, estado
from drones
where estado != 'RETIRADO'
  and ((cargamax_kg >= 8 and horasvuelo < 400) or autonomia_km > 80)
order by codigoserie asc;
 
-- d) pilotos con licencia distinta de A que ingresaron hasta el 1 de febrero de 2025
select nombres, apellidos, licencia, fechaingreso as fecha_ingreso
from pilotos
where not licencia = 'A'
  and fechaingreso <= '2025-02-01'
order by fechaingreso asc;
-- -------------------------------------------------------------------------------------
-- R6. Directorio comercial y calidad de datos 
-- a) clientes con telefono invalido deberia tener exactamente 10 digitos
select upper(nombre) as cliente,
       municipio,
       coalesce(telefono, 'SIN TELÉFONO')  as telefono,
       length(telefono) as digitos
from clientes
where telefono is null or length(telefono) <> 10
order by nombre asc;
 
-- b) clientes con correo corporativo (no termina en un dominio gratuito), el lower() evita que un correo con mayusculas se escape del filtro
select nombre,
       lower(email) as correo,
       concat(nombre, ' <', lower(email), '>') as contacto
from clientes
where email is not null
  and lower(email) not like '%@gmail.com'
  and lower(email) not like '%@hotmail.com'
  and lower(email) not like '%@outlook.com'
order by nombre;
 
-- c) drones condor con serie DA-CX?-NN (cada _ es exactamente un caracter)
select codigoserie    as codigo_serie,
       upper(modelo)  as modelo,
       horasvuelo     as horas_vuelo,
       round(horasvuelo / 1000 * 100, 1) as pct_vida_util
from drones
where codigoserie like 'DA-CX_-__'
order by horasvuelo desc;
-- -------------------------------------------------------------------------------------------------------------------------
-- R7. Indicadores de gestion
 
-- a) kilogramos por tipo de carga, solo entregas entregadas
select t.nombre    as tipo_carga,
       count(*)    as num_entregas,
       sum(ce.peso_kg) as kg_totales,
       round(avg(ce.peso_kg), 2) as kg_promedio,
       min(ce.peso_kg) as kg_minimo,
       max(ce.peso_kg) as kg_maximo
from carga_entrega ce
inner join tiposcarga t on t.idtipo = ce.idtipo
inner join entregas e   on e.identrega = ce.identrega
where e.estado = 'ENTREGADA'
group by t.nombre
order by kg_totales desc;
 
-- b) clientes estrella: 2 o mas entregas entregadas y promedio de 4 o mas el count(*) cuenta todas las entregas y el avg ignora las calificaciones nulas
select c.nombre as cliente,
       count(*) as entregas_realizadas,
       round(avg(e.calificacion), 2) as calificacion_promedio
from clientes c
inner join entregas e on e.idcliente = c.idcliente
where e.estado = 'ENTREGADA'
group by c.idcliente, c.nombre
having count(*) >= 2 and avg(e.calificacion) >= 4
order by calificacion_promedio desc, cliente asc;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------
-- R8. Consultas multitabla
 
-- a) hoja de vuelo de entregas vitales entregadas
select e.codigo,
       c.nombre as cliente,
       concat(p.nombres, ' ', p.apellidos) as piloto,
       d.codigoserie as dron,
       b.nombre as base,
       timestampdiff(minute, e.fechaprogramada, e.fechaentrega)  as minutos_vuelo
from entregas e
inner join clientes c on c.idcliente = e.idcliente
inner join pilotos p on p.idpiloto = e.idpiloto
inner join drones d on d.iddron = e.iddron
inner join bases b on b.idbase = d.idbase
where e.prioridad = 'VITAL' and e.estado = 'ENTREGADA'
order by e.fechaprogramada asc;
 
-- b) productividad de pilotos; los que no tienen entregas aparecen con 0,  el filtro de estado va en el on: en el where eliminaria a los pilotos sin entregas
select concat(p.nombres, ' ', p.apellidos)  as piloto,
       p.licencia,
       count(e.identrega) as entregas_realizadas
from pilotos p
left join entregas e on e.idpiloto = p.idpiloto and e.estado = 'ENTREGADA'
group by p.idpiloto, p.nombres, p.apellidos, p.licencia
order by entregas_realizadas desc, piloto asc;
 
-- c) organigrama: la tabla pilotos se une consigo misma (p = piloto, s = supervisor) cada piloto (nombre completo, alias piloto), su licencia y el nombre completo de su supervisor (alias supervisor). 
select concat(p.nombres, ' ', p.apellidos) as piloto,
       p.licencia,
       coalesce(concat(s.nombres, ' ', s.apellidos), 'DIRECCIÓN DE OPERACIONES')  as supervisor
from pilotos p
left join pilotos s on s.idpiloto = p.idsupervisor
order by supervisor, piloto;
 
-- d) auditoria RN-05: entregas programadas donde la distancia supera la autonomia del dron
select e.codigo,
       c.nombre as cliente,
       d.codigoserie as dron,
       e.distancia_km,
       d.autonomia_km,
       e.distancia_km - d.autonomia_km as exceso_km
from entregas e
inner join clientes c on c.idcliente = e.idcliente
inner join drones d on d.iddron = e.iddron
where e.estado = 'PROGRAMADA'
  and e.distancia_km > d.autonomia_km;

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------
  
-- R9. Subconsultas
 
-- a) entregas entregadas con distancia mayor al promedio de las entregadas
select codigo, municipiodestino as municipio_destino, distancia_km
from entregas
where estado = 'ENTREGADA'
  and distancia_km > (select avg(distancia_km) from entregas where estado = 'ENTREGADA')
order by distancia_km desc;
 
-- b) clientes que nunca han tenido una entrega= el not in es seguro aqui porque entregas.idcliente es not null
select nombre, tipo, municipio, fecharegistro as fecha_registro
from clientes
where idcliente not in (select idcliente from entregas)
order by fecharegistro, nombre;
 
-- c) drones con mas horas que el promedio de su misma base 
select d.codigoserie as codigo_serie, b.nombre as base, d.horasvuelo as horas_vuelo
from drones d
inner join bases b on b.idbase = d.idbase
where d.horasvuelo > (select avg(d2.horasvuelo)
                      from drones d2
                      where d2.idbase = d.idbase)
order by base;
 
-- d) drones no retirados que nunca han tenido mantenimiento
select d.codigoserie as codigo_serie, d.modelo, d.estado
from drones d
where d.estado <> 'RETIRADO'
  and not exists (select 1 from mantenimientos m where m.iddron = d.iddron)
order by d.codigoserie;
-- --------------------------------------------------------------------------------------------------------------------------  
-- R10. Vista e indices 
-- a) una fila por entrega; left join para incluir las entregas sin carga
create view vw_tablero_entregas as
select e.codigo,
       e.fechaprogramada as fecha_programada,
       c.nombre as cliente,
       c.tipo as tipo_cliente,
       e.municipiodestino as municipio_destino,
       d.codigoserie as dron,
       concat(p.nombres, ' ', p.apellidos) as piloto,
       e.prioridad,
       e.estado,
       count(ce.idtipo) as tipos_carga,
       coalesce(sum(ce.peso_kg), 0) as peso_total_kg
from entregas e
inner join clientes c on c.idcliente = e.idcliente
inner join drones d on d.iddron = e.iddron
inner join pilotos p on p.idpiloto = e.idpiloto
left join carga_entrega ce on ce.identrega = e.identrega
group by e.identrega, e.codigo, e.fechaprogramada, c.nombre, c.tipo, e.municipiodestino,
         d.codigoserie, p.nombres, p.apellidos, e.prioridad, e.estado;
 
select * from vw_tablero_entregas
where estado in ('PROGRAMADA', 'EN_VUELO')
order by fecha_programada;
 
-- b) indices
-- busqueda 1: entregas por estado dentro de un rango de fechas programadas aqui el estado va primero porque se filtra por igualdad y fechaprogramada va despues  porque se filtra por rango y queda ordenada dentro de cada estado.
create index idx_entregas_estado_fecha on entregas (estado, fechaprogramada);
 
-- busqueda 2: clientes por tipo y municipio aqui las dos columnas se filtran por igualdad ya que un indice compuesto resuelve el filtro completo sin recorrer toda la tabla.
create index idx_clientes_tipo_municipio on clientes (tipo, municipio);
 
show index from entregas;
show index from clientes;
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
-- R11. Funcion almacenada
 drop function if exists fn_valorentrega;
delimiter //
create function fn_valorentrega(p_id_entrega int)
returns decimal(12,2)
reads sql data
begin
    declare v_distancia decimal(5,1);
    declare v_prioridad varchar(8);
    declare v_carga     decimal(14,2);
    declare v_total     decimal(14,2);
 
    -- si la entrega no existe devuelve null
    if not exists (select 1 from entregas where identrega = p_id_entrega) then
        return null;
    end if;
 
    select distancia_km, prioridad
    into v_distancia, v_prioridad
    from entregas
    where identrega = p_id_entrega;
 
    -- suma de peso x tarifa; coalesce deja 0 cuando la entrega no tiene carga
    select coalesce(sum(ce.peso_kg * t.tarifakg), 0)
    into v_carga
    from carga_entrega ce
    inner join tiposcarga t on t.idtipo = ce.idtipo
    where ce.identrega = p_id_entrega;
 
    -- RN-10: carga + distancia x $1.200
    set v_total = v_carga + v_distancia * 1200;
 
    -- recargo del 20 % solo para urgente
    if v_prioridad = 'URGENTE' then
        set v_total = v_total * 1.20;
    end if;
 
    return round(v_total, 2);
end //
 
delimiter ;
 
-- prueba 1: entregas entregadas con prioridad urgente
select codigo, prioridad, fn_valorentrega(identrega) as valor_cop
from entregas
where estado = 'ENTREGADA' and prioridad = 'URGENTE'
order by valor_cop desc;
 
-- prueba 2: entrega inexistente, devuelve null
select fn_valorentrega(999) as valor_cop;
-- ------------------------------------------------------------------------------------------------------------------------------------------- 
-- R12. Trigger de auditoria
drop trigger if exists trg_entregasestado;
delimiter //

create trigger trg_entregasestado
before update on entregas
for each row
begin
    -- solo actua si el estado cambia
    if new.estado <> old.estado then
        -- (1) al pasar a entregada sin fecha, se asigna la fecha y hora actual
        if new.estado = 'ENTREGADA' and new.fechaentrega is null then
            set new.fechaentrega = now();
        end if;
 
        -- (2) se registra el cambio en el historial
        insert into historialentregas (identrega, estadoanterior, estadonuevo)
        values (old.identrega, old.estado, new.estado);
    end if;
end//
 
delimiter ;
 
update entregas set estado = 'ENTREGADA', calificacion = 5 where codigo = 'ENT-0018';
update entregas set estado = 'CANCELADA' where codigo = 'ENT-0019';
update entregas set calificacion = 4 where codigo = 'ENT-0011';
 
-- historial: deben quedar 2 registros 
select h.idhistorial, e.codigo, h.estadoanterior, h.estadonuevo, h.fechacambio
from historialentregas h
inner join entregas e on e.identrega = h.identrega
order by h.idhistorial;
 
select codigo, estado, fechaentrega, calificacion
from entregas
where codigo in ('ENT-0018', 'ENT-0019', 'ENT-0011')
order by codigo;
 
-- -------------------------------------------------------------------------------------------------------
-- R13. Procedimiento almacenado
drop procedure if exists sp_programar_entrega;
delimiter //
 
create procedure sp_programar_entrega(
    in p_codigo     varchar(10),
    in p_id_cliente int,
    in p_id_dron    int,
    in p_id_piloto  int,
    in p_fecha      datetime,
    in p_municipio  varchar(60),
    in p_distancia  decimal(5,1),
    in p_prioridad  varchar(8)
)
begin
    declare v_existe    int;
    declare v_estado    varchar(15);
    declare v_autonomia decimal(5,1);
    declare v_licencia  char(1);
 
    -- 1. que el dron y el piloto existan
    select count(*) into v_existe from drones where iddron = p_id_dron;
    if v_existe = 0 then
        signal sqlstate '45000' set message_text = 'El dron indicado no existe';
    end if;
 
    select count(*) into v_existe from pilotos where idpiloto = p_id_piloto;
    if v_existe = 0 then
        signal sqlstate '45000' set message_text = 'El piloto indicado no existe';
    end if;
 
    select estado, autonomia_km into v_estado, v_autonomia
    from drones where iddron = p_id_dron;
 
    select licencia into v_licencia
    from pilotos where idpiloto = p_id_piloto;
 
    -- 2. que el dron este activo (RN-06)
    if v_estado <> 'ACTIVO' then
        signal sqlstate '45000' set message_text = 'El dron no esta ACTIVO (RN-06)';
    end if;
 
    -- 3. que la distancia no supere la autonomia del dron (RN-05)
    if p_distancia > v_autonomia then
        signal sqlstate '45000' set message_text = 'La distancia supera la autonomia del dron (RN-05)';
    end if;
 
    -- 4. que la licencia permita la distancia (RN-03): A hasta 20 km, B hasta 40 km, C sin limite
    if (v_licencia = 'A' and p_distancia > 20) or (v_licencia = 'B' and p_distancia > 40) then
        signal sqlstate '45000' set message_text = 'La licencia del piloto no permite esa distancia (RN-03)';
    end if;
 
    -- el estado no se escribe: queda PROGRAMADA por el valor por defecto
    insert into entregas (codigo, idcliente, iddron, idpiloto, fechaprogramada,
                          municipiodestino, distancia_km, prioridad)
    values (p_codigo, p_id_cliente, p_id_dron, p_id_piloto, p_fecha,
            p_municipio, p_distancia, p_prioridad);
 
    select concat('Entrega programada con identificador ', last_insert_id()) as mensaje;
end//
 
delimiter ;
 
-- llamada 1: valida
call sp_programar_entrega('ENT-0021', 11, 3, 3, '2026-10-03 10:00:00', 'Marinilla', 16.0, 'URGENTE');
 
-- llamada 2: debe fallar; el dron 4 quedo en MANTENIMIENTO en R4.b (RN-06)
call sp_programar_entrega('ENT-0022', 6, 4, 4, '2026-10-03 11:00:00', 'Guarne', 9.0, 'NORMAL');
 
-- llamada 3: debe fallar; el piloto 7 tiene licencia A y la distancia es 28 km (RN-03)
call sp_programar_entrega('ENT-0023', 2, 7, 7, '2026-10-04 08:00:00', 'Arcabuco', 28.0, 'NORMAL');
 
select * from vw_tablero_entregas where codigo = 'ENT-0021';
 
 