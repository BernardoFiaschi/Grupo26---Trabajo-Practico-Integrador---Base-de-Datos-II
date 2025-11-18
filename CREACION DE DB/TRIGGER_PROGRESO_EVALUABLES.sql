USE BD2_TPI_G26;
GO

-- Trigger para actualizar progreso cuando se aprueban clases EVALUABLES
CREATE OR ALTER TRIGGER dbo.TR_Evaluacion_ActualizarProgreso
ON dbo.Evaluacion
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Solo procesar evaluaciones aprobadas
    IF NOT EXISTS (SELECT 1 FROM inserted WHERE Aprobado = 1)
        RETURN;

    ;WITH Cambios AS 
    (
        -- Usuarios y cursos afectados por cambios en evaluaciones aprobadas
        SELECT DISTINCT 
            i.IdUsuario,
            m.IdCurso
        FROM inserted i
        INNER JOIN dbo.Clase c ON i.IdClase = c.IdClase
        INNER JOIN dbo.Modulo m ON c.IdModulo = m.IdModulo
        WHERE i.Aprobado = 1  -- Solo evaluaciones aprobadas
    ),
    ProgresoCalculado AS (
        SELECT
            c.IdUsuario,
            c.IdCurso,
            -- Clases evaluables aprobadas
            ISNULL((
                SELECT COUNT(DISTINCT cl.IdClase) 
                FROM dbo.Modulo AS m2
                INNER JOIN dbo.Clase cl ON m2.IdModulo = cl.IdModulo
                INNER JOIN dbo.Evaluacion ev ON cl.IdClase = ev.IdClase
                    AND ev.IdUsuario = c.IdUsuario
                WHERE m2.IdCurso = c.IdCurso
                    AND cl.EsEvaluable = 1
                    AND ev.Aprobado = 1
            ), 0) AS ClasesEvaluablesAprobadas,
            
            -- Clases no evaluables completadas
            ISNULL((
                SELECT COUNT(DISTINCT cl.IdClase)
                FROM dbo.Modulo m2
                INNER JOIN dbo.Clase cl ON m2.IdModulo = cl.IdModulo
                INNER JOIN dbo.ClaseCompletada cc ON cl.IdClase = cc.IdClase
                    AND cc.IdUsuario = c.IdUsuario
                WHERE m2.IdCurso = c.IdCurso
                    AND cl.EsEvaluable = 0
            ), 0) AS ClasesNoEvaluablesCompletadas,
            
            -- Total de clases en el curso
            (
                SELECT COUNT(DISTINCT cl.IdClase)
                FROM dbo.Modulo m2
                INNER JOIN dbo.Clase cl ON m2.IdModulo = cl.IdModulo
                WHERE m2.IdCurso = c.IdCurso
            ) AS TotalClasesCurso
        FROM Cambios c
    )
    MERGE dbo.Progreso AS target
    USING ProgresoCalculado AS sourc
    ON target.IdUsuario = sourc.IdUsuario 
        AND target.IdCurso = sourc.IdCurso
    WHEN MATCHED THEN 
        UPDATE SET
            ClasesCompletadas = sourc.ClasesEvaluablesAprobadas 
                + sourc.ClasesNoEvaluablesCompletadas,
            TotalClases = sourc.TotalClasesCurso,
            Porcentaje = 
                CASE
                    WHEN sourc.TotalClasesCurso > 0
                    THEN CAST(((sourc.ClasesEvaluablesAprobadas + 
                                sourc.ClasesNoEvaluablesCompletadas) 
                                * 100.0 / sourc.TotalClasesCurso) AS INT)
                    ELSE 0
                END,
            Estado = 
                CASE 
                    WHEN (sourc.ClasesEvaluablesAprobadas + 
                          sourc.ClasesNoEvaluablesCompletadas) = 
                        sourc.TotalClasesCurso
                    THEN 'COMPLETADO'
                    ELSE 'EN PROGRESO'
                END,
            FechaUltimaActividad = GETDATE(),
            UltimaClaseVista = (
                SELECT TOP 1 i.IdClase
                FROM inserted i
                WHERE i.IdUsuario = sourc.IdUsuario
                    AND i.Aprobado = 1
                ORDER BY i.FechaRealizacion DESC
            )
    WHEN NOT MATCHED THEN
        INSERT (IdUsuario, IdCurso, ClasesCompletadas,
                TotalClases, Porcentaje, Estado, UltimaClaseVista,
                FechaUltimaActividad)
        VALUES 
        (
            sourc.IdUsuario,
            sourc.IdCurso,
            sourc.ClasesEvaluablesAprobadas + sourc.ClasesNoEvaluablesCompletadas,
            sourc.TotalClasesCurso,
            CASE 
                WHEN sourc.TotalClasesCurso > 0 
                THEN CAST(((sourc.ClasesEvaluablesAprobadas +
                            sourc.ClasesNoEvaluablesCompletadas)
                            * 100.0 / sourc.TotalClasesCurso) AS INT)
                ELSE 0
            END,
            CASE
                WHEN (sourc.ClasesEvaluablesAprobadas + 
                     sourc.ClasesNoEvaluablesCompletadas) = 
                     sourc.TotalClasesCurso 
                THEN 'COMPLETADO'
                ELSE 'EN PROGRESO'
            END,
            (SELECT TOP 1 IdClase FROM inserted 
             WHERE IdUsuario = sourc.IdUsuario 
                AND Aprobado = 1
             ORDER BY FechaRealizacion DESC),
            GETDATE()
        );
END;
GO