create database TechCorp;

use TechCorp;

create table departamento(
idDepartamento int auto_increment primary key not null,
nombreDepartamento varchar(50) not null
);

create  table Empleados(
IdEmpleado int auto_increment primary key not null,
NombreEmpleado varchar(20) not null,
ApellidoEmpleado varchar(20) not null,
EdadEmpleado int not null,
Salario decimal(10,2) NOT NULL,
idDepartamento INT,
fecha_contratacion DATE NOT null,
CONSTRAINT fk_departamento FOREIGN KEY (idDepartamento) REFERENCES departamento(idDepartamento)
);

INSERT INTO departamento (nombreDepartamento) VALUES 
('Ventas'), 
('IT'), 
('Recursos Humanos'), 
('Marketing');

INSERT INTO Empleados (NombreEmpleado, ApellidoEmpleado, EdadEmpleado, Salario, idDepartamento, fecha_contratacion) VALUES 
('Ana','Gómez', 28, 3500.00, 1, '2019-03-15'),      
('Carlos', 'Pérez', 35, 4500.00, 2, '2021-06-20'),     
('Beatriz', 'Castro', 41, 4200.00, 1, '2022-01-10'),   
('David','Ruiz', 32, 2800.00, 3, '2018-11-05'),       
('Andrés','Torres', 38, 5100.00, 1, '2023-05-12'),    
('Elena','Rojas', 26, 3100.00, 4, '2020-09-01'),      
('Camila','Morales', 29, 3900.00, 2, '2024-02-18');


SELECT * FROM Empleados;
SELECT * FROM departamento;


-- lista de empleados 
SELECT NombreEmpleado, ApellidoEmpleado, EdadEmpleado, Salario 
FROM Empleados;

-- Altos ingresos: Empleados que ganan más de $4,000
SELECT NombreEmpleado, ApellidoEmpleado, Salario 
from Empleados 
WHERE Salario > 4000;

-- Fuerza de ventas: Lista de empleados que trabajan en el departamento de Ventas
SELECT e.NombreEmpleado, e.ApellidoEmpleado, d.nombreDepartamento 
from Empleados e, departamento d 
WHERE e.idDepartamento = d.idDepartamento 
  AND d.nombreDepartamento = 'Ventas';

-- rango de edad
SELECT NombreEmpleado, ApellidoEmpleado, EdadEmpleado 
from Empleados 
WHERE EdadEmpleado BETWEEN 30 AND 40;

-- Nuevas contrataciones: ¿Quiénes han sido contratados después del año 2020?
SELECT NombreEmpleado, ApellidoEmpleado, fecha_contratacion
from Empleados
where year(fecha_contratacion)>2020;

-- Distribución de empleados: ¿Cuántos empleados hay en cada departamento?

SELECT d.nombreDepartamento, COUNT(e.IdEmpleado) AS total_empleados 
from departamento d, Empleados e 
where d.idDepartamento = e.idDepartamento 
group by d.nombreDepartamento;
-- Análisis salarial: ¿Cuál es el salario promedio en la empresa?
SELECT avg(Salario) AS salario_promedio 
FROM Empleados;
-- Nombres selectivos: Muestra los empleados cuyos nombres comienzan con "A" o "C".
SELECT NombreEmpleado, ApellidoEmpleado 
from Empleados 
where NombreEmpleado like 'A%' or NombreEmpleado like 'C%';

-- Departamentos específicos: Encuentra a los empleados que no pertenecen al departamento de IT.
SELECT e.NombreEmpleado, e.ApellidoEmpleado, d.nombreDepartamento 
from Empleados e, departamento d 
where e.idDepartamento = d.idDepartamento 
  and not (d.nombreDepartamento = 'IT');

--- El mejor pagado
 SELECT NombreEmpleado, ApellidoEmpleado, Salario
 from Empleados
 order by Salario desc;


