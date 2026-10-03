CREATE DATABASE IF NOT EXISTS biblioteca_db;
USE biblioteca_db;

CREATE TABLE socios (
  id     INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  email  VARCHAR(100) NOT NULL UNIQUE,
  activo BOOLEAN      NOT NULL DEFAULT TRUE
);

CREATE TABLE libros (
  id                     INT AUTO_INCREMENT PRIMARY KEY,
  titulo                 VARCHAR(150) NOT NULL,
  autor                  VARCHAR(100) NOT NULL,
  ejemplares_totales     INT NOT NULL CHECK (ejemplares_totales >= 0),
  ejemplares_disponibles INT NOT NULL CHECK (ejemplares_disponibles >= 0)
);

CREATE TABLE prestamos (
  id               INT AUTO_INCREMENT PRIMARY KEY,
  socio_id         INT  NOT NULL,
  libro_id         INT  NOT NULL,
  fecha_prestamo   DATE NOT NULL,
  fecha_limite     DATE NOT NULL,
  fecha_devolucion DATE NULL,
  CONSTRAINT fk_prestamos_socio FOREIGN KEY (socio_id) REFERENCES socios(id),
  CONSTRAINT fk_prestamos_libro FOREIGN KEY (libro_id) REFERENCES libros(id)
);

CREATE TABLE historial_prestamos (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  prestamo_id INT          NOT NULL,
  accion      VARCHAR(20)  NOT NULL,
  detalle     VARCHAR(255),
  usuario     VARCHAR(100) NOT NULL,
  fecha       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_historial_prestamo FOREIGN KEY (prestamo_id) REFERENCES prestamos(id)
);

-- Datos de prueba (funcionan igual en ambos motores)
-- Las fechas son relativas al día en que se ejecuta el script, para que siempre haya préstamos vencidos.
INSERT INTO socios (nombre, email, activo) VALUES
  ('Camila Rojas',   'camila@correo.com',    TRUE),
  ('Andrés Díaz',    'andres@correo.com',    TRUE),
  ('Valentina Ríos', 'valentina@correo.com', FALSE),   -- inactiva
  ('Mateo Castro',   'mateo@correo.com',     TRUE);    -- ya tiene 3 préstamos activos

INSERT INTO libros (titulo, autor, ejemplares_totales, ejemplares_disponibles) VALUES
  ('Cien años de soledad',          'Gabriel García Márquez',   3, 2),
  ('Clean Code',                    'Robert C. Martin',         2, 0),   -- agotado
  ('Fundamentos de bases de datos', 'Abraham Silberschatz',     4, 3),
  ('El principito',                 'Antoine de Saint-Exupéry', 2, 2);

INSERT INTO prestamos (socio_id, libro_id, fecha_prestamo, fecha_limite, fecha_devolucion) VALUES
  (1, 1, CURRENT_DATE - INTERVAL '40' DAY, CURRENT_DATE - INTERVAL '26' DAY, CURRENT_DATE - INTERVAL '27' DAY), -- devuelto
  (2, 2, CURRENT_DATE - INTERVAL '20' DAY, CURRENT_DATE - INTERVAL '6' DAY,  NULL),  -- vencido hace 6 días
  (4, 2, CURRENT_DATE - INTERVAL '18' DAY, CURRENT_DATE - INTERVAL '4' DAY,  NULL),  -- vencido hace 4 días
  (4, 1, CURRENT_DATE - INTERVAL '5' DAY,  CURRENT_DATE + INTERVAL '9' DAY,  NULL),  -- al día
  (4, 3, CURRENT_DATE - INTERVAL '2' DAY,  CURRENT_DATE + INTERVAL '12' DAY, NULL);  -- al día

-- vista R1
create view v_prestamos_vencidos as 
select
    p.id  as prestamo_id,
    s.nombre  as socio,
    s.email   as email,
    l.titulo  as libro,
    p.fecha_limite as fecha_limite,
    datediff(current_date, p.fecha_limite)  as dias_retraso
from prestamos p
join socios s on s.id = p.socio_id
join libros l on l.id = p.libro_id
where p.fecha_devolucion is null
  and p.fecha_limite < current_date;

select * from v_prestamos_vencidos;
-- procedimiento almacenado R2

drop procedure if exists sp_prestar_libro;
DELIMITER //

create procedure sp_prestar_libro(
    in  p_socio_id    int,
    in  p_libro_id    int,
    in  p_dias        int,
    out p_prestamo_id  int
)
begin
    declare v_activo       boolean;
    declare v_activos      int;
    declare v_disponibles  int;
    declare v_fecha_limite date;

    -- Atomicidad (punto 5): si CUALQUIER cosa falla (incluidos nuestros
    -- SIGNAL), se deshace todo y se re-lanza el error original.
    declare exit handler for SQLEXCEPTION
    begin
        rollback;
        resignal;
    end;

    start transaction;

    -- Regla 4: el préstamo dura entre 1 y 30 días
    if p_dias is null or p_dias < 1 or p_dias > 30 then
        SIGNAL SQLSTATE '45000'
            set message_text = 'Días fuera de rango: el préstamo debe durar entre 1 y 30 días';
    end if;

    -- Regla 1: el socio debe existir y estar activo
    select activo into v_activo
      from socios
     where id = p_socio_id;

    if v_activo is null then
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El socio no existe';
    end if;
    if v_activo = false then
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Socio inactivo: no puede recibir préstamos';
    end if;

    -- Regla 2: máximo 3 préstamos activos (sin devolver)
    select count(*) into v_activos
      from prestamos
     where socio_id = p_socio_id
       and fecha_devolucion is null;

    if v_activos >= 3 then
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El socio ya tiene 3 préstamos activos';
    end if;

    -- Regla 3: el libro debe tener ejemplares disponibles.
    -- FOR UPDATE bloquea la fila del libro hasta el COMMIT/ROLLBACK: si otro funcionario intenta prestar el mismo libro al mismo tiempo, espera aquí y luego lee el valor ya actualizado.
    select ejemplares_disponibles into v_disponibles
      from libros
     where id = p_libro_id
       for update;

    if v_disponibles is null then
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El libro no existe';
    end if;
    IF v_disponibles < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay ejemplares disponibles de este libro';
    end if;

    -- Punto 2: crear el préstamo 
    set v_fecha_limite = date_add(current_date, interval p_dias day);

    insert into prestamos (socio_id, libro_id, fecha_prestamo, fecha_limite, fecha_devolucion)
    values (p_socio_id, p_libro_id, current_date, v_fecha_limite, null);

    set p_prestamo_id = last_insert_id();

    -- Punto 3: descontar un ejemplar
    update libros
       set ejemplares_disponibles = ejemplares_disponibles - 1
     where id = p_libro_id;

    -- Punto 4: registrar en el historial
    insert into historial_prestamos (prestamo_id, accion, detalle, usuario)
    values (p_prestamo_id, 'PRESTAMO',
            concat('Préstamo por ', p_dias, ' días. Fecha límite: ', v_fecha_limite),
            current_user());

    commit;
end //

DELIMITER ;

-- creacion de trigger R3
drop trigger if exists trg_prestamos_after_update;
DELIMITER //
create trigger trg_prestamos_after_update
after update on prestamos
for each row
begin
    declare v_dias_retraso int;

    -- Punto 3: si se cambió otra columna (fecha_devolucion sigue NULL) o si el préstamo ya estaba devuelto (OLD ya tenía fecha), no hace nada.
    if old.fecha_devolucion is null and new.fecha_devolucion is not null then
        -- 0 si llegó a tiempo o antes
        set v_dias_retraso = greatest(datediff(new.fecha_devolucion, new.fecha_limite), 0);

        -- Punto 1: devolver el ejemplar al inventario
        update libros
           set ejemplares_disponibles = ejemplares_disponibles + 1
         where id = new.libro_id;

        -- Punto 2: registrar la devolución
        insert into historial_prestamos (prestamo_id, accion, detalle, usuario)
        values (new.id, 'DEVOLUCION',
                concat('Días de retraso: ', v_dias_retraso),
                current_user());
     end if;
end //

DELIMITER ;

-- 2. Camila (1) presta El principito (4) por 14 días → id 6; quedan 1 disponible
call sp_prestar_libro(1, 4, 14, @id);
select @id AS prestamo_creado;
select titulo, ejemplares_disponibles 
from libros where id = 4;
-- 3. Valentina (3), inactiva  Error: socio inactivo
call sp_prestar_libro(3, 1, 7, @id);
-- 4. Camila (1) presta "Clean Code" (2)  Error: no hay ejemplares
call sp_prestar_libro(1, 2, 7, @id);
-- 5. Mateo (4), con 3 activos  Error: ya tiene 3 préstamos activos
call sp_prestar_libro(4, 4, 7, @id);

-- Caso de uso elegido: fecha de última modificación automática.
alter table libros
add column ultima_modificacion datetime not null default current_timestamp;

drop trigger if exists trg_libros_before_update;
DELIMITER //
create trigger  trg_libros_before_update
before update on libros
for each row
begin
    set new.ultima_modificacion = current_timestamp; -- dia y hora de la modificacion
end //
DELIMITER ;
-- prueba
select id, titulo, ejemplares_disponibles, ultima_modificacion 
from libros 
where id = 4;
-- Camila  presta El principito por 14 días
call sp_prestar_libro(1, 4, 14, @id);