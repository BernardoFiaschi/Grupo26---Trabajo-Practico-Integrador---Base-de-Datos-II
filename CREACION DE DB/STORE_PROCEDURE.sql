USE BD2_TPI_G26;
GO

-- SP que registra la nota de una evaluaci�n de clase.
-- Aplica validaciones de negocio y solo permite un intento por alumno y clase.

IF OBJECT_ID('dbo.SP_RegistrarCalificacionEvaluacion', 'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_RegistrarCalificacionEvaluacion;
GO

CREATE PROCEDURE dbo.SP_RegistrarCalificacionEvaluacion
(
    @IdUsuario         int,
    @IdClase           int,
    @PuntajeObtenido   float,
    @TiempoEmpleadoMin int          = NULL,
    @Observaciones     varchar(500) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @IdModulo         int,
        @IdCurso          int,
        @EsEvaluable      bit,
        @PuntajeAprob     float,
        @IdEvaluacion     int,
        @Aprobado         bit,
        @EstadoEvaluacion varchar(20);

    -- Valido que el usuario exista y est� activo
    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Usuario
        WHERE IdUsuario = @IdUsuario
          AND Activo = 1
    )
    BEGIN
        RAISERROR('El usuario no existe o no esta activo.', 16, 1);
        RETURN;
    END;

    -- Valido que la clase exista y sea evaluable
    SELECT 
        @IdModulo    = IdModulo,
        @EsEvaluable = EsEvaluable
    FROM dbo.Clase
    WHERE IdClase = @IdClase;

    IF @IdModulo IS NULL
    BEGIN
        RAISERROR('La clase indicada no existe.', 16, 1);
        RETURN;
    END;

    IF @EsEvaluable = 0
    BEGIN
        RAISERROR('La clase indicada no es evaluable.', 16, 1);
        RETURN;
    END;

    -- Obtengo el curso al que pertenece la clase
    SELECT @IdCurso = IdCurso
    FROM dbo.Modulo
    WHERE IdModulo = @IdModulo;

    -- Valido que el alumno tenga una inscripci�n activa a ese curso
    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Inscripcion i
        WHERE i.IdUsuario = @IdUsuario
          AND i.IdCurso   = @IdCurso
          AND i.Bloqueado = 0
    )
    BEGIN
        RAISERROR('El usuario no posee una inscripcion activa al curso.', 16, 1);
        RETURN;
    END;

    -- Valido el puntaje
    IF @PuntajeObtenido IS NULL OR @PuntajeObtenido < 0
    BEGIN
        RAISERROR('El puntaje obtenido es invalido.', 16, 1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRAN;

        -- Verifico si ya hay una evaluaci�n para ese alumno y esa clase
        SELECT
            @IdEvaluacion = IdEvaluacion,
            @PuntajeAprob = PuntajeAprob
        FROM dbo.Evaluacion
        WHERE IdUsuario = @IdUsuario
          AND IdClase   = @IdClase;

        -- Solo permito un intento
        IF @IdEvaluacion IS NOT NULL
        BEGIN
            RAISERROR(
                'La evaluacion de esta clase para este alumno ya fue rendida. Solo se permite un intento.',
                16, 1
            );
            ROLLBACK TRAN;
            RETURN;
        END;

        IF @PuntajeAprob IS NULL
            SET @PuntajeAprob = 6;  -- valor por defecto si no hay configurado

        -- Calculo si aprueba y el estado de la evaluaci�n
        SET @Aprobado = CASE WHEN @PuntajeObtenido >= @PuntajeAprob THEN 1 ELSE 0 END;
        SET @EstadoEvaluacion = CASE WHEN @Aprobado = 1 THEN 'APROBADA' ELSE 'REPROBADA' END;

        -- Inserto la evaluaci�n
        INSERT INTO dbo.Evaluacion (
            IdUsuario,
            IdClase,
            Tipo,
            TituloEvaluacion,
            Descripcion,
            PuntajeMax,
            PuntajeObtenido,
            PuntajeAprob,
            Aprobado,
            FechaRealizacion,
            TiempoEmpleadoMin,
            Observaciones,
            Intentos,
            EstadoEvaluacion,
            CalificadoPor
        )
        VALUES (
            @IdUsuario,
            @IdClase,
            'ONLINE',
            'Evaluacion automatica de la clase',
            NULL,
            10,
            @PuntajeObtenido,
            @PuntajeAprob,
            @Aprobado,
            GETDATE(),
            @TiempoEmpleadoMin,
            @Observaciones,
            1,
            @EstadoEvaluacion,
            NULL
        );

        SET @IdEvaluacion = SCOPE_IDENTITY();

        COMMIT TRAN;

        -- Devuelvo un resumen de lo que se grab�
        SELECT
            e.IdEvaluacion,
            e.IdUsuario,
            e.IdClase,
            e.PuntajeObtenido,
            e.PuntajeAprob,
            e.Aprobado,
            e.Intentos,
            e.EstadoEvaluacion,
            e.FechaRealizacion
        FROM dbo.Evaluacion e
        WHERE e.IdEvaluacion = @IdEvaluacion;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

        DECLARE 
            @ErrorMessage nvarchar(4000),
            @ErrorSeverity int,
            @ErrorState    int;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState    = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

CREATE PROCEDURE SP_CANCELARINSCRIPCION (
    @IdUsuario INT,
    @Codigo VARCHAR(30),
    @Motivo VARCHAR(500) = null
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

        IF @IdUsuario IS NULL
        BEGIN
            RAISERROR('El IdUsuario ingresado no existe. Por consecuente no se borro nada.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN; 
        END

        IF @Codigo IS NULL
        BEGIN
            RAISERROR('El codigo de la materia ingresado no existe. Por consecuente no se borro nada.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN; 
        END

        DECLARE @IdEstadoInscripcionCancelada INT;
        DECLARE @IdEstadoPagoCancelada INT;
        DECLARE @IdInscripcion INT;
        DECLARE @IdCurso INT;
        
        -- ID ESTADO INSCRIPCION
        SELECT @IdEstadoInscripcionCancelada = IdEstado
        FROM dbo.Estado
        WHERE Tipo = 'INSCRIPCION' and Situacion = 'CANCELADA'

        -- ID ESTADO PAGO
        SELECT @IdEstadoPagoCancelada = IdEstado
        FROM dbo.Estado
        WHERE Tipo = 'PAGO' and Situacion = 'CANCELADO'

        -- Obtengo el Id del CURSO
        SELECT @IdCurso = IdCurso
        FROM dbo.Curso
        WHERE Codigo = @Codigo

        -- Obtengo el Id de la Inscripcion
        SELECT @IdInscripcion = IdInscripcion
        FROM dbo.Inscripcion
        WHERE IdUsuario = @IdUsuario and IdCurso = @IdCurso

        IF @IdInscripcion IS NULL
        BEGIN
            RAISERROR('No se encontró una inscripción para ese usuario y código de curso. No se canceló nada.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN; 
        END

        UPDATE dbo.Inscripcion
        SET IdEstado = @IdEstadoInscripcionCancelada,
        Bloqueado = 1,
        Observaciones = @Motivo,
        FechaFinAcceso = GETDATE()
        WHERE IdInscripcion = @IdInscripcion

        UPDATE dbo.Pago
        SET IdEstado = @IdEstadoPagoCancelada
        WHERE IdInscripcion = @IdInscripcion

        DELETE FROM dbo.Progreso
        WHERE IdUsuario = @IdUsuario and IdCurso = @IdCurso

        DELETE FROM dbo.Evaluacion
        WHERE IdUsuario = @IdUsuario and IdClase in (
            SELECT cl.IdClase 
            FROM dbo.Clase AS cl
            INNER JOIN dbo.Modulo AS mod ON cl.IdModulo = mod.IdModulo
            WHERE mod.IdCurso = @IdCurso)

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        RAISERROR ('Error en SP_CANCELARINSCRIPCION',16,1);
    END CATCH
END
GO