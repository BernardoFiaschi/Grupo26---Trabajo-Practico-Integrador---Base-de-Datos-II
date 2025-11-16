USE BD2_TPI_G26;
GO

-- Vista de notas y rendimiento por curso/alumno.
-- La uso como reporte principal para ver si el curso queda aprobado por notas.

IF OBJECT_ID('dbo.VW_NotasCursoAlumno', 'V') IS NOT NULL
    DROP VIEW dbo.VW_NotasCursoAlumno;
GO

CREATE VIEW dbo.VW_NotasCursoAlumno
AS
WITH ClasesEvaluables AS (
    SELECT 
        m.IdCurso,
        c.IdClase
    FROM dbo.Modulo m
    JOIN dbo.Clase c ON c.IdModulo = m.IdModulo
    WHERE c.EsEvaluable = 1
),
NotasPorClase AS (
    SELECT
        i.IdUsuario,
        ce.IdCurso,
        ce.IdClase,
        e.IdEvaluacion,
        e.PuntajeObtenido,
        e.PuntajeMax,
        e.Aprobado,
        e.FechaRealizacion
    FROM dbo.Inscripcion i
    JOIN ClasesEvaluables ce
        ON ce.IdCurso = i.IdCurso
    LEFT JOIN dbo.Evaluacion e
        ON e.IdUsuario = i.IdUsuario
       AND e.IdClase   = ce.IdClase
)
SELECT
    u.IdUsuario,
    u.Nombre,
    u.Apellido,
    c.IdCurso,
    c.Titulo AS TituloCurso,
    COUNT(DISTINCT np.IdClase) AS CantEvaluacionesEsperadas,
    COUNT(DISTINCT CASE WHEN np.IdEvaluacion IS NOT NULL THEN np.IdClase END)
        AS CantEvaluacionesRealizadas,
    COUNT(DISTINCT CASE WHEN np.Aprobado = 1 THEN np.IdClase END)
        AS CantEvaluacionesAprobadas,
    CAST(
        CASE 
            WHEN COUNT(DISTINCT np.IdClase) = 0 THEN 0.0
            ELSE 100.0 * COUNT(DISTINCT CASE WHEN np.Aprobado = 1 THEN np.IdClase END)
                       / COUNT(DISTINCT np.IdClase)
        END AS decimal(5,2)
    ) AS PorcentajeEvaluacionesAprobadas,
    AVG(np.PuntajeObtenido) AS NotaPromedio,
    MIN(np.PuntajeObtenido) AS NotaMinima,
    MAX(np.PuntajeObtenido) AS NotaMaxima,
    MAX(np.FechaRealizacion) AS FechaUltimaEvaluacion,
    CASE
        WHEN COUNT(DISTINCT np.IdClase) = 0 THEN 'SIN NOTAS'
        WHEN COUNT(DISTINCT np.IdClase) > 0
             AND COUNT(DISTINCT np.IdClase)
                 = COUNT(DISTINCT CASE WHEN np.Aprobado = 1 THEN np.IdClase END)
             THEN 'CURSO APROBADO (POR NOTAS)'
        WHEN COUNT(DISTINCT CASE WHEN np.IdEvaluacion IS NOT NULL THEN np.IdClase END) = 0
             THEN 'SIN EVALUACIONES RENDIDAS'
        ELSE 'EN PROCESO'
    END AS EstadoNotasCurso
FROM NotasPorClase np
JOIN dbo.Usuario u ON u.IdUsuario = np.IdUsuario
JOIN dbo.Curso  c ON c.IdCurso    = np.IdCurso
GROUP BY
    u.IdUsuario, u.Nombre, u.Apellido,
    c.IdCurso, c.Titulo;
GO
