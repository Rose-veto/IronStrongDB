-- Asegurarse de que el script se ejecute en la base de datos correcta
USE IronStrongFitness;
GO
 
-- ######################################################
-- 1. VISTAS DE REPORTES (FASE 5)
-- ######################################################
 
-- A) VISTA vw_Deudores
-- Listar miembros cuyos contratos vencieron o tienen pagos pendientes.
---------------------------------------------------------------------
 
IF OBJECT_ID('vw_Deudores', 'V') IS NOT NULL
    DROP VIEW vw_Deudores;
GO
 
CREATE VIEW vw_Deudores AS
SELECT
    M.MiembroID,
    M.Nombre AS NombreMiembro,
    C.ContratoID,
    C.FechaFin,
    -- Determinar si el contrato está vencido (FechaFin < GETDATE())
    CASE
        WHEN C.FechaFin < GETDATE() THEN 'Vencido'
        ELSE 'Pago Pendiente' -- Asume que cualquier contrato sin pago reciente es pendiente
    END AS EstadoDeuda
FROM
    Miembros M
INNER JOIN
    Contratos C ON M.MiembroID = C.MiembroID
LEFT JOIN
    Pagos P ON C.ContratoID = P.ContratoID
WHERE
    C.FechaFin < GETDATE() -- Contratos vencidos
    -- O (Opcional: puedes añadir lógica para pagos vencidos si tienes una columna FechaVencimiento en Pagos)
GO
 
-- B) VISTA vw_OcupacionGimnasio
-- Mostrar ocupación y porcentaje de cupo utilizado en las clases.
-----------------------------------------------------------------
 
IF OBJECT_ID('vw_OcupacionGimnasio', 'V') IS NOT NULL
    DROP VIEW vw_OcupacionGimnasio;
GO
 
CREATE VIEW vw_OcupacionGimnasio AS
SELECT
    CL.ClaseID,
    CL.Nombre AS NombreClase,
    CL.CupoMaximo,
    COUNT(A.AsistenciaID) AS OcupacionActual,
    -- Calcular el porcentaje de cupo utilizado
    CAST(COUNT(A.AsistenciaID) AS DECIMAL) * 100 / CL.CupoMaximo AS PorcentajeOcupacion
FROM
    Clases CL
LEFT JOIN
    Asistencias A ON CL.ClaseID = A.ClaseID
GROUP BY
    CL.ClaseID, CL.Nombre, CL.CupoMaximo;
GO
 
-- ######################################################
-- 2. TRIGGERS DE SEGURIDAD Y AUTOMATIZACIÓN (FASE 5)
-- ######################################################
 
-- A) Trigger de Auditoría (tr_AuditoriaPagos)
----------------------------------------------
 
-- Primero, crear la tabla de auditoría
IF OBJECT_ID('AuditoriaPagos', 'U') IS NULL
BEGIN
    CREATE TABLE AuditoriaPagos (
        AuditoriaID INT IDENTITY(1,1) PRIMARY KEY,
        ContratoID INT,
        MontoAnterior DECIMAL(10, 2),
        MontoNuevo DECIMAL(10, 2),
        FechaCambio DATETIME DEFAULT GETDATE(),
        UsuarioCambio NVARCHAR(128) DEFAULT SUSER_SNAME(),
        TipoOperacion CHAR(1) -- 'I' (Insert) o 'U' (Update)
    );
END
GO
 
-- Crear el Trigger
IF OBJECT_ID('tr_AuditoriaPagos', 'TR') IS NOT NULL
    DROP TRIGGER tr_AuditoriaPagos;
GO
 
CREATE TRIGGER tr_AuditoriaPagos
ON Pagos
AFTER INSERT, UPDATE
AS
BEGIN
    -- Auditoría para INSERT
    IF EXISTS (SELECT * FROM inserted EXCEPT SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM deleted EXCEPT SELECT * FROM inserted)
    BEGIN
        INSERT INTO AuditoriaPagos (ContratoID, MontoNuevo, TipoOperacion)
        SELECT ContratoID, Monto, 'I'
        FROM inserted;
    END
 
    -- Auditoría para UPDATE
    IF UPDATE(Monto) -- Solo si el monto fue actualizado
    BEGIN
        INSERT INTO AuditoriaPagos (ContratoID, MontoAnterior, MontoNuevo, TipoOperacion)
        SELECT d.ContratoID, d.Monto, i.Monto, 'U'
        FROM deleted d JOIN inserted i ON d.PagoID = i.PagoID;
    END
END
GO
 
-- B) Trigger de Vigencia (tr_VerificarVigenciaContrato)
-- Verifica que el contrato sea vigente antes de permitir un pago o una actualización.
-----------------------------------------------------------------------------
 
IF OBJECT_ID('tr_VerificarVigenciaContrato', 'TR') IS NOT NULL
    DROP TRIGGER tr_VerificarVigenciaContrato;
GO
 
CREATE TRIGGER tr_VerificarVigenciaContrato
ON Pagos
INSTEAD OF INSERT -- Usamos INSTEAD OF para prevenir la operación si falla
AS
BEGIN
    IF EXISTS (
        SELECT i.ContratoID
        FROM inserted i
        INNER JOIN Contratos C ON i.ContratoID = C.ContratoID
        WHERE C.FechaFin < GETDATE() -- Si la FechaFin del contrato ya pasó
    )
    BEGIN
        -- Si el contrato ha vencido, NO se inserta el pago.
        RAISERROR('El pago no puede ser registrado: el contrato asociado ya ha vencido.', 16, 1);
        RETURN;
    END
    ELSE
    BEGIN
        -- Si el contrato está vigente, se permite la inserción original.
        INSERT INTO Pagos (ContratoID, Monto, FechaPago) -- Ajustar columnas según tu esquema real
        SELECT ContratoID, Monto, FechaPago FROM inserted;
    END
END
GO
 
-- ######################################################
-- 3. TRANSACCIONES CRÍTICAS (FASE 6)
-- ######################################################
 
-- Script de Renovación (sp_RenovarMembresia)
-- Proceso atómico: verifica pago = costo de la membresía y actualiza la FechaFin
-----------------------------------------------------------------------------------
 
IF OBJECT_ID('sp_RenovarMembresia', 'P') IS NOT NULL
    DROP PROCEDURE sp_RenovarMembresia;
GO
 
CREATE PROCEDURE sp_RenovarMembresia (
    @MiembroID INT,
    @IdMembresia INT,
    @MontoPago DECIMAL(10, 2)
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CostoMembresia DECIMAL(10, 2);
    DECLARE @ContratoID INT;
    DECLARE @NuevaFechaFin DATE;
 
    -- 1. Iniciar la Transacción (Garantía Atómica)
    BEGIN TRANSACTION;
 
    -- 2. Obtener el costo de la membresía
    SELECT @CostoMembresia = Costo
    FROM Membresias
    WHERE IdMembresia = @IdMembresia;
 
    -- 3. Obtener el contrato actual del miembro
    SELECT @ContratoID = ContratoID
    FROM Contratos
    WHERE MiembroID = @MiembroID;
 
    -- 4. Verificar si el monto del pago es correcto
    IF @MontoPago <> @CostoMembresia
    BEGIN
        -- Si falla, revertir todo.
        ROLLBACK TRANSACTION;
        RAISERROR('Error: El monto del pago no coincide con el costo de la membresía.', 16, 1);
        RETURN;
    END
 
    -- 5. Calcular la nueva fecha de fin (Ejemplo: Añadir 1 año a partir de hoy o de la FechaFin actual)
    SELECT @NuevaFechaFin = DATEADD(year, 1, ISNULL(FechaFin, GETDATE()))
    FROM Contratos
    WHERE ContratoID = @ContratoID;
    -- 6. Insertar el nuevo pago
    INSERT INTO Pagos (ContratoID, Monto, FechaPago)
    VALUES (@ContratoID, @MontoPago, GETDATE());
 
    -- 7. Actualizar la FechaFin del contrato
    UPDATE Contratos
    SET
        IdMembresia = @IdMembresia, -- Posible cambio de membresía
        FechaInicio = ISNULL(FechaInicio, GETDATE()), -- Asegurar FechaInicio
        FechaFin = @NuevaFechaFin
    WHERE
        ContratoID = @ContratoID;
 
    -- 8. Si todo es exitoso, confirmar la transacción
    IF @@TRANCOUNT > 0
    BEGIN
        COMMIT TRANSACTION;
        PRINT 'Renovación exitosa y transacción confirmada.';
    END
END
GO