-- 1. Crear la Base de Datos
CREATE DATABASE IronStrongFitness;
GO -- Comando para separar lotes en SQL Server


USE IronStrongFitness;
GO



-- 2. Creación de Tablas


-- TABLA 1: Membresias (Catálogo de tipos de membresía)
-- Es un catálogo que define los tipos de servicio (Mensual, Anual, VIP).
CREATE TABLE Membresias (
    IdMembresia INT PRIMARY KEY IDENTITY(1,1), -- PK: Clave Primaria, Auto-incrementable
    Nombre VARCHAR(50) NOT NULL UNIQUE,
    Costo DECIMAL(10, 2) NOT NULL,
    DuracionDias INT NOT NULL -- Duración en días (e.g., 30, 365)
);



-- TABLA 2: Miembros (Información personal de los clientes)
CREATE TABLE Miembros (
    IdMiembro INT PRIMARY KEY IDENTITY(1,1), -- PK
    Nombre VARCHAR(100) NOT NULL,
    FechaNacimiento DATE NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Estado VARCHAR(10) NOT NULL CHECK (Estado IN ('Activo', 'Inactivo')) -- Restringe valores a 'Activo' o 'Inactivo'
);



-- TABLA 3: Contratos (Relación Miembro-Membresia)
-- Maneja la compra de una membresía por un miembro en un tiempo específico.
CREATE TABLE Contratos (
    IdContrato INT PRIMARY KEY IDENTITY(1,1), -- PK
    IdMiembro INT NOT NULL,
    IdMembresia INT NOT NULL,
    FechaInicio DATE NOT NULL,
    FechaFin DATE NOT NULL,
    -- FKs: Claves Foráneas para asegurar que las referencias existan en las tablas padre
    FOREIGN KEY (IdMiembro) REFERENCES Miembros(IdMiembro),
    FOREIGN KEY (IdMembresia) REFERENCES Membresias(IdMembresia)
);



-- TABLA 4: Pagos (Registra las transacciones financieras)
CREATE TABLE Pagos (
    IdPago INT PRIMARY KEY IDENTITY(1,1), -- PK
    IdContrato INT NOT NULL,
    Monto DECIMAL(10, 2) NOT NULL,
    FechaPago DATE NOT NULL,
    -- FK: Relaciona el pago con un contrato específico
    FOREIGN KEY (IdContrato) REFERENCES Contratos(IdContrato)
);




-- TABLA 5: Entrenadores (Información del personal de entrenamiento)
CREATE TABLE Entrenadores (
    IdEntrenador INT PRIMARY KEY IDENTITY(1,1), -- PK
    Nombre VARCHAR(100) NOT NULL,
    Especialidad VARCHAR(100)
);



-- TABLA 6: Clases (Catálogo de clases grupales ofrecidas)
CREATE TABLE Clases (
    IdClase INT PRIMARY KEY IDENTITY(1,1), -- PK
    NombreClase VARCHAR(100) NOT NULL,
    IdEntrenador INT NOT NULL, -- FK: Entrenador a cargo
    Horario TIME NOT NULL, -- Hora de inicio de la clase
    CupoMaximo INT NOT NULL,
    FOREIGN KEY (IdEntrenador) REFERENCES Entrenadores(IdEntrenador)
);



-- TABLA 7: Asistencias (Relación Miembro-Clase)
-- Registra cuándo un miembro asiste a una clase.
CREATE TABLE Asistencias (
    IdAsistencia INT PRIMARY KEY IDENTITY(1,1), -- PK
    IdClase INT NOT NULL,
    IdMiembro INT NOT NULL,
    FechaRegistro DATETIME DEFAULT GETDATE(), -- Registra fecha y hora de la asistencia
    -- Útil para evitar registros duplicados de asistencia en el mismo día
    CONSTRAINT UQ_Asistencia_Miembro_Clase UNIQUE (IdMiembro, IdClase, FechaRegistro),
    -- FKs
    FOREIGN KEY (IdClase) REFERENCES Clases(IdClase),
    FOREIGN KEY (IdMiembro) REFERENCES Miembros(IdMiembro)
);



--Inserción de Datos (DML)

-- 1. 5 Tipos de Membresías
INSERT INTO Membresias (Nombre, Costo, DuracionDias) VALUES
('Mensual', 50.00, 30),
('Trimestral', 135.00, 90),
('Anual', 480.00, 365),
('VIP', 750.00, 365),
('Prueba 7 Dias', 0.00, 7);



-- 2. 10 Entrenadores
INSERT INTO Entrenadores (Nombre, Especialidad) VALUES
('Ricardo Montalvo', 'Cardio y Resistencia'),
('Ana Belén Cruz', 'Yoga y Pilates'),
('Carlos Ruiz', 'Levantamiento Olímpico'),
('Sofía Jiménez', 'Zumba y Baile'),
('Marco Antonio Salas', 'Nutrición y Peso'),
('Laura Pérez', 'Entrenamiento Funcional'),
('Javier Torres', 'Boxeo y HIIT'),
('Elena Castro', 'Spinning'),
('Felipe Durán', 'Natación'),
('Gabriela Soto', 'Fuerza y Tonificación');



-- 3. 20 Miembros
INSERT INTO Miembros (Nombre, FechaNacimiento, Email, Estado) VALUES
('Juan Pérez', '1990-05-15', 'juan.perez@example.com', 'Activo'),
('Maria López', '1985-10-20', 'maria.lopez@example.com', 'Activo'),
('Pedro Sánchez', '1998-03-01', 'pedro.sanchez@example.com', 'Inactivo'),
('Laura Gómez', '2001-07-25', 'laura.gomez@example.com', 'Activo'),
('Andrés Castro', '1975-01-10', 'andres.castro@example.com', 'Activo'),
('Verónica Díaz', '1993-11-30', 'veronica.diaz@example.com', 'Activo'),
('Miguel Herrera', '1980-04-12', 'miguel.herrera@example.com', 'Activo'),
('Sofía Ramos', '1995-09-05', 'sofia.ramos@example.com', 'Inactivo'),
('Roberto Valdés', '1988-02-18', 'roberto.valdes@example.com', 'Activo'),
('Camila Flores', '1991-06-22', 'camila.flores@example.com', 'Activo'),
('Daniel Ortiz', '1970-12-03', 'daniel.ortiz@example.com', 'Activo'),
('Fernanda Salas', '2000-08-08', 'fernanda.salas@example.com', 'Activo'),
('Héctor Pino', '1983-01-28', 'hector.pino@example.com', 'Activo'),
('Isabel Luna', '1997-05-09', 'isabel.luna@example.com', 'Activo'),
('Jorge Núñez', '1992-03-14', 'jorge.nunez@example.com', 'Activo'),
('Karla Soto', '1989-10-02', 'karla.soto@example.com', 'Activo'),
('Luis Mora', '1986-07-17', 'luis.mora@example.com', 'Activo'),
('Mónica Vega', '1994-11-21', 'monica.vega@example.com', 'Activo'),
('Nicolás Ríos', '1978-04-04', 'nicolas.rios@example.com', 'Activo'),
('Olivia Torres', '1996-09-19', 'olivia.torres@example.com', 'Activo');



-- 4. 15 Clases programadas
INSERT INTO Clases (NombreClase, IdEntrenador, Horario, CupoMaximo) VALUES
('HIIT Extremo', 1, '07:00:00', 15),       -- Ricardo (1)
('Yoga Matinal', 2, '08:00:00', 20),      -- Ana (2)
('Levantamiento Básico', 3, '09:00:00', 10), -- Carlos (3)
('Zumba Fiesta', 4, '10:00:00', 30),      -- Sofía (4)
('Entrenamiento Personalizado', 5, '11:00:00', 5), -- Marco (5)
('Funcional Express', 6, '12:00:00', 18),   -- Laura (6)
('Box Fit', 7, '17:00:00', 12),           -- Javier (7)
('Spinning Tarde', 8, '18:00:00', 25),     -- Elena (8)
('Natación Avanzada', 9, '19:00:00', 8),    -- Felipe (9)
('Fuerza y Peso', 10, '20:00:00', 15),    -- Gabriela (10)
('Yoga para la Espalda', 2, '16:00:00', 15), -- Ana (2)
('Cross Training', 1, '19:00:00', 10),    -- Ricardo (1)
('Clase Muestra', 3, '13:00:00', 20),     -- Carlos (3)
('Zumba Nocturna', 4, '21:00:00', 25),    -- Sofía (4)
('Entrenamiento Personalizado II', 5, '14:00:00', 5); -- Marco (5)



-- 5. Contratos y Pagos (Asumiendo que hoy es 2025-12-08)
-- Miembros con Membresía VIP (IdMembresia = 4)
INSERT INTO Contratos (IdMiembro, IdMembresia, FechaInicio, FechaFin) VALUES
(1, 4, '2025-11-01', '2026-11-01'), -- Juan: VIP (Activo)
(2, 1, '2025-12-01', '2025-12-31'), -- Maria: Mensual (Vigente)
(4, 4, '2025-06-15', '2026-06-15'), -- Laura: VIP (Activo)
(5, 3, '2025-01-01', '2026-01-01'), -- Andrés: Anual (Vigente)
(6, 1, '2025-10-01', '2025-10-31'), -- Verónica: Mensual (Vencida)
(7, 2, '2025-09-08', '2025-12-07'), -- Miguel: Trimestral (Vencida - es deudora)
(8, 4, '2025-12-08', '2026-12-08'), -- Sofía: VIP (Nuevo)
(9, 3, '2025-07-20', '2026-07-20'), -- Roberto: Anual
(10, 1, '2025-11-05', '2025-12-05'),-- Camila: Mensual (Vencida - es deudora)
(11, 2, '2025-03-01', '2025-05-30'); -- Daniel: Trimestral (Vencida)



-- Pagos (Relacionados con los contratos anteriores)
INSERT INTO Pagos (IdContrato, Monto, FechaPago) VALUES
(1, 750.00, '2025-11-01'), -- Pago Contrato Juan (VIP)
(2, 50.00, '2025-12-01'),  -- Pago Contrato Maria (Mensual)
(4, 480.00, '2025-06-15'), -- Pago Contrato Laura (VIP) - Simulación de pago menor para test de transacción después
(5, 480.00, '2025-01-01'), -- Pago Contrato Andrés (Anual)
(6, 50.00, '2025-10-01'),  -- Pago Contrato Verónica (Mensual - vencido, pero se pagó)
(8, 750.00, '2025-12-08'), -- Pago Contrato Sofía (VIP)
(9, 480.00, '2025-07-20'); -- Pago Contrato Roberto (Anual)



-- 6. 30 Registros de Asistencia
INSERT INTO Asistencias (IdClase, IdMiembro, FechaRegistro) VALUES
(1, 1, '2025-12-01 07:00:00'), -- Juan a HIIT
(1, 2, '2025-12-01 07:00:00'), -- Maria a HIIT
(2, 4, '2025-12-01 08:00:00'), -- Laura a Yoga
(3, 5, '2025-12-01 09:00:00'), -- Andrés a Levantamiento
(4, 6, '2025-12-01 10:00:00'), -- Verónica a Zumba
(5, 7, '2025-12-01 11:00:00'), -- Miguel a Personalizado
(6, 8, '2025-12-01 12:00:00'), -- Sofía a Funcional
(7, 9, '2025-12-01 17:00:00'), -- Roberto a Box Fit
(8, 10, '2025-12-01 18:00:00'),-- Camila a Spinning
(9, 1, '2025-12-02 19:00:00'), -- Juan a Natación
(10, 2, '2025-12-02 20:00:00'),-- Maria a Fuerza
(11, 4, '2025-12-02 16:00:00'),-- Laura a Yoga
(12, 5, '2025-12-02 19:00:00'),-- Andrés a Cross Training
(13, 6, '2025-12-02 13:00:00'),-- Verónica a Clase Muestra
(14, 7, '2025-12-02 21:00:00'),-- Miguel a Zumba
(15, 8, '2025-12-02 14:00:00'),-- Sofía a Personalizado
(1, 1, '2025-12-03 07:00:00'), -- Juan a HIIT
(2, 4, '2025-12-03 08:00:00'), -- Laura a Yoga
(3, 5, '2025-12-03 09:00:00'), -- Andrés a Levantamiento
(4, 6, '2025-12-03 10:00:00'), -- Verónica a Zumba
(5, 7, '2025-12-03 11:00:00'), -- Miguel a Personalizado
(6, 8, '2025-12-03 12:00:00'), -- Sofía a Funcional
(7, 9, '2025-12-03 17:00:00'), -- Roberto a Box Fit
(8, 10, '2025-12-03 18:00:00'),-- Camila a Spinning
(9, 1, '2025-12-04 19:00:00'), -- Juan a Natación
(10, 2, '2025-12-04 20:00:00'),-- Maria a Fuerza
(11, 4, '2025-12-04 16:00:00'),-- Laura a Yoga
(12, 5, '2025-12-04 19:00:00'),-- Andrés a Cross Training
(13, 6, '2025-12-04 13:00:00'),-- Verónica a Clase Muestra
(14, 7, '2025-12-04 21:00:00');-- Miguel a Zumba

-- Nota: Los miembros 3 (Pedro), 12 (Fernanda), 13 (Héctor), 14 (Isabel), 15 (Jorge), 16 (Karla), 17 (Luis), 18 (Mónica), 19 (Nicolás), 20 (Olivia) no tienen asistencia para futuros reportes.



