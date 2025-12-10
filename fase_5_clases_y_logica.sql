USE IronStrongFitness; 
GO

-- ########## 1. FUNCIÓN DE EDAD PROMEDIO ##########

-- Calcula la edad promedio de los miembros inscritos en una clase específica.

CREATE FUNCTION fn_EdadPromedioClase (@ClaseID INT)

RETURNS DECIMAL(5, 2)

AS

BEGIN

-- Lógica aquí (JOIN Miembros, Asistencias, calcular AVG(DATEDIFF) )

RETURN 0.00;

END

GO


-- ########## 2. PROCEDIMIENTO DE INSCRIPCIÓN ##########

-- Inscribe un miembro a una clase, verificando que no exceda el cupo máximo.

-- ########## 1. PROCEDIMIENTO ALMACENADO ##########
-- Estructura de DROP/CREATE para poder ejecutar varias veces
IF OBJECT_ID('sp_InscribirClase', 'P') IS NOT NULL
    DROP PROCEDURE sp_InscribirClase;
GO
 
-- ########## 1. PROCEDIMIENTO ALMACENADO ##########
CREATE PROCEDURE sp_InscribirClase (
    @MiembroID INT,
    @ClaseID INT
)
AS
BEGIN
    -- Lógica aquí (Verificar cupo, INSERT en Asistencias)
    -- ...
    RETURN 0;
END
GO


-- ########## 3. CTE (CONSULTA AVANZADA) ##########
-- Aquí debe estar la lógica real del CTE.
 
-- ########## 3. CTE (CONSULTA AVANZADA) ##########

-- Reporte de las 3 clases con mayor número de inscripciones en el último mes.

;WITH TopClases AS (

    SELECT

        C.Nombre AS NombreClase,

        T1.TotalInscripciones,

        -- Asigna un rango basado en el total de inscripciones (más alto es rango 1)

        RANK() OVER (ORDER BY T1.TotalInscripciones DESC) AS Ranking

    FROM

        (

            -- Subconsulta: Cuenta las inscripciones en el último mes

            SELECT

                ClaseID,

                COUNT(AsistenciaID) AS TotalInscripciones

            FROM

                Asistencias

            WHERE

                -- Filtra por el último mes (usando una fecha de referencia, ej: Diciembre 2025)

                FechaAsistencia >= DATEADD(month, -1, GETDATE()) 

            GROUP BY

                ClaseID

        ) AS T1

    INNER JOIN Clases C ON T1.ClaseID = C.ClaseID

)

SELECT 

    Ranking, 

    NombreClase, 

    TotalInscripciones

FROM TopClases

WHERE Ranking <= 3;
 
