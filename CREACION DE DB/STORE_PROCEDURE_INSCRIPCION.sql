USE BD2_TPI_G26;
GO

-- Procedimiento para inscribir un usuario en un curso
IF OBJECT_ID('dbo.SP_Inscribir_Usuario', 'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Inscribir_Usuario;
GO

CREATE PROCEDURE dbo.SP_Inscribir_Usuario
    @IdUsuario        INT,
    @IdCurso          INT,
    @Origen           VARCHAR(20) = 'WEB'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdEstadoActivo INT;

    -- VAL1: Usuario activo
    IF NOT EXISTS (SELECT 1 FROM dbo.Usuario WHERE IdUsuario = @IdUsuario AND Activo = 1)
    BEGIN
        RAISERROR('Usuario no existe o no está activo.', 16, 1);
        RETURN;
    END;

    -- VAL2: Curso disponible
    IF NOT EXISTS (
        SELECT 1 
        FROM dbo.Curso 
        WHERE IdCurso = @IdCurso 
        AND Publicado = 1 
        AND GETDATE() BETWEEN FechaInicio AND FechaFin
    )
    BEGIN
        RAISERROR('Curso no disponible para inscripción.', 16, 1);
        RETURN;
    END;

    -- VAL3: No duplicado
    IF EXISTS (SELECT 1 FROM dbo.Inscripcion WHERE IdUsuario = @IdUsuario AND IdCurso = @IdCurso)
    BEGIN
        RAISERROR('El usuario ya está inscrito en este curso.', 16, 1);
        RETURN;
    END;

    -- VAL4: Cupo disponible (si aplica)
    DECLARE @CupoActual INT, @CupoMaximo INT;
    
    SELECT @CupoMaximo = CupoMaximo 
    FROM dbo.Curso 
    WHERE IdCurso = @IdCurso;

    IF @CupoMaximo IS NOT NULL
    BEGIN
        SELECT @CupoActual = COUNT(*) 
        FROM dbo.Inscripcion 
        WHERE IdCurso = @IdCurso AND Bloqueado = 0;

        IF @CupoActual >= @CupoMaximo
        BEGIN
            RAISERROR('Curso con cupo completo.', 16, 1);
            RETURN;
        END;
    END;

    -- OBTENER ESTADO ACTIVO
    SELECT TOP 1 @IdEstadoActivo = IdEstado
    FROM dbo.Estado
    WHERE Tipo = 'INSCRIPCION' AND Situacion = 'ACTIVA';

    IF @IdEstadoActivo IS NULL
    BEGIN
        RAISERROR('No se pudo determinar el estado de inscripción.', 16, 1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- INSERTAR INSCRIPCIÓN
        INSERT INTO dbo.Inscripcion (
            IdUsuario, IdCurso, IdEstado, Bloqueado, FechaInscripcion, Origen
        )
        VALUES (
            @IdUsuario, @IdCurso, @IdEstadoActivo, 0, GETDATE(), @Origen
        );

        -- CREAR PROGRESO INICIAL
        INSERT INTO dbo.Progreso (
            IdUsuario, IdCurso, ClasesCompletadas, TotalClases, Porcentaje, Estado
        )
        SELECT 
            @IdUsuario, 
            @IdCurso, 
            0, 
            (SELECT COUNT(*) FROM dbo.Clase c 
             INNER JOIN dbo.Modulo m ON c.IdModulo = m.IdModulo 
             WHERE m.IdCurso = @IdCurso),
            0, 
            'NO INICIADO';

        COMMIT TRANSACTION;

        SELECT 'Inscripción exitosa' AS Resultado;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMsg VARCHAR(1000) = ERROR_MESSAGE();
        RAISERROR('Error en inscripción: %s', 16, 1, @ErrorMsg);
    END CATCH;
END;
GO