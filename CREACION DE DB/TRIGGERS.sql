USE BD2_TPI_G26;
GO

-- Trigger que marca la inscripcion como APROBADA
-- cuando el alumno aprueba todas las clases evaluables del curso.

CREATE OR ALTER TRIGGER dbo.TR_Evaluacion_ActualizarEstadoCursoAprobado
ON dbo.Evaluacion
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdEstadoCursoAprobado int;

    -- Busco el estado de inscripcion que voy a usar como "curso aprobado"
    SELECT TOP (1) @IdEstadoCursoAprobado = IdEstado
    FROM dbo.Estado
    WHERE Tipo     = 'INSCRIPCION'
      AND Situacion IN ('APROBADO', 'CURSO APROBADO')
    ORDER BY IdEstado;

    -- Si no hay estado configurado, no hago nada
    IF @IdEstadoCursoAprobado IS NULL
        RETURN;

    ;WITH Afectados AS (
        SELECT DISTINCT
            e.IdUsuario,
            m.IdCurso
        FROM inserted i
        JOIN dbo.Evaluacion e ON e.IdEvaluacion = i.IdEvaluacion
        JOIN dbo.Clase      c ON c.IdClase      = e.IdClase
        JOIN dbo.Modulo     m ON m.IdModulo     = c.IdModulo
    ),
    Estadisticas AS (
        SELECT
            a.IdUsuario,
            a.IdCurso,
            COUNT(DISTINCT CASE WHEN c.EsEvaluable = 1 THEN c.IdClase END)
                AS TotalClasesEvaluables,
            COUNT(DISTINCT CASE WHEN c.EsEvaluable = 1 AND ev.Aprobado = 1 THEN c.IdClase END)
                AS ClasesAprobadas
        FROM Afectados a
        JOIN dbo.Modulo m ON m.IdCurso  = a.IdCurso
        JOIN dbo.Clase  c ON c.IdModulo = m.IdModulo
        LEFT JOIN dbo.Evaluacion ev
            ON ev.IdUsuario = a.IdUsuario
           AND ev.IdClase   = c.IdClase
        GROUP BY
            a.IdUsuario,
            a.IdCurso
    )
    UPDATE i
    SET i.IdEstado = @IdEstadoCursoAprobado
    FROM dbo.Inscripcion i
    JOIN Estadisticas e
      ON e.IdUsuario = i.IdUsuario
     AND e.IdCurso   = i.IdCurso
    WHERE e.TotalClasesEvaluables > 0
      AND e.ClasesAprobadas = e.TotalClasesEvaluables
      AND i.IdEstado <> @IdEstadoCursoAprobado;
END;
GO
