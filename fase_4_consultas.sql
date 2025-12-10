--Consultas y Reportes
-- 1. Listar miembros que tienen una membresía "VIP".
SELECT
    M.Nombre,
    M.Email,
    ME.Nombre AS TipoMembresia
FROM Miembros M
JOIN Contratos C ON M.IdMiembro = C.IdMiembro -- Une Miembros con sus Contratos
JOIN Membresias ME ON C.IdMembresia = ME.IdMembresia -- Une Contratos con el tipo de Membresia
WHERE ME.Nombre = 'VIP'; -- Filtra por el nombre de la membresía




-- 2. Mostrar el calendario de clases ordenado por horario y nombre del entrenador (JOIN).
SELECT
    CL.NombreClase,
    CL.Horario,
    E.Nombre AS Entrenador,
    E.Especialidad
FROM Clases CL
JOIN Entrenadores E ON CL.IdEntrenador = E.IdEntrenador -- Une la clase con su Entrenador
ORDER BY CL.Horario, E.Nombre;




-- 3. Listar miembros que nunca han asistido a una clase (Subconsulta o LEFT JOIN).
-- Opción 1: Usando Subconsulta con NOT IN
SELECT
    M.Nombre,
    M.Email
FROM Miembros M
WHERE M.IdMiembro NOT IN (
    SELECT DISTINCT IdMiembro -- Selecciona los IDs de todos los que SÍ han asistido
    FROM Asistencias
);

-- Opción 2: Usando LEFT JOIN (Mejor rendimiento en general)
SELECT
    M.Nombre,
    M.Email
FROM Miembros M
LEFT JOIN Asistencias A ON M.IdMiembro = A.IdMiembro -- Intenta unir Miembros con Asistencias
WHERE A.IdMiembro IS NULL; -- Si el IdMiembro es NULL en Asistencias, significa que nunca asistió



-- 4. Mostrar los pagos realizados en el último mes (WHERE con fechas).
-- Asumiendo que la fecha actual es '2025-12-09'. Buscar pagos desde '2025-11-09' hasta hoy.
SELECT
    P.FechaPago,
    P.Monto,
    M.Nombre AS NombreMiembro,
    ME.Nombre AS TipoMembresia
FROM Pagos P
JOIN Contratos C ON P.IdContrato = C.IdContrato
JOIN Miembros M ON C.IdMiembro = M.IdMiembro
JOIN Membresias ME ON C.IdMembresia = ME.IdMembresia
WHERE P.FechaPago >= DATEADD(MONTH, -1, GETDATE()); -- (SQL Server) Cambiar por NOW() - INTERVAL 1 MONTH (MySQL)
-- Nota: En MySQL sería: WHERE P.FechaPago >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH);


-- Consultas Básicas: Contratos que vencen en el próximo mes
SELECT
    M.Nombre,
    C.FechaFin
FROM Contratos C
JOIN Miembros M ON C.IdMiembro = M.IdMiembro
WHERE
    C.FechaFin BETWEEN GETDATE() AND DATEADD(MONTH, 1, GETDATE())
ORDER BY C.FechaFin;



-- Agregación (GROUP BY): Contar cuántos contratos activos hay por tipo de membresía
SELECT
    ME.Nombre AS TipoMembresia,
    COUNT(C.IdContrato) AS TotalContratos
FROM Contratos C
JOIN Membresias ME ON C.IdMembresia = ME.IdMembresia
-- Opcional: Usar HAVING para filtrar solo membresías con más de 5 contratos
-- HAVING COUNT(C.IdContrato) > 5
GROUP BY ME.Nombre
ORDER BY TotalContratos DESC;



-- Lógica de Conjuntos (EXCEPT): Miembros sin Contrato (Clientes Inactivos)
SELECT
    IdMiembro,
    Nombre
FROM Miembros
EXCEPT
-- Selecciona los IDs de los miembros que SÍ tienen contrato
SELECT
    M.IdMiembro,
    M.Nombre
FROM Miembros M
JOIN Contratos C ON M.IdMiembro = C.IdMiembro;