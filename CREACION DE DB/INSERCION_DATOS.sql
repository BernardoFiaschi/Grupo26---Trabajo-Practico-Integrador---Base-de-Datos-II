
/* ==== INSERCION DE DATOS ==== */

USE BD2_TPI_G26;
GO

DECLARE @IdUsuarioAlumno             int,
        @IdUsuarioDocente            int,
        @IdDocente                   int,
        @IdCategoriaProgramacion     int,
        @IdEstadoInscripcionEnCurso  int,
        @IdEstadoInscripcionAprobado int,
        @IdEstadoPagoPendiente       int,
        @IdEstadoPagoAprobado        int,
        @IdCursoSQL                  int,
        @IdModulo1                   int,
        @IdClaseIntro                int,
        @IdClaseSelect               int,
        @IdClaseWhere                int,
        @IdInscripcionAlumno         int;

/* ==== ROLES ==== */
IF NOT EXISTS (SELECT 1 FROM Rol WHERE IdRol = 1)
    INSERT INTO Rol (IdRol, Nombre, Descripcion, NivelAcceso, AdministrarCursos, GestionarUsuarios, CorregirEvaluaciones, VerReportes)
    VALUES (1, 'Alumno',  'Rol alumno, solo cursa', 1, 0, 0, 0, 0);

IF NOT EXISTS (SELECT 1 FROM Rol WHERE IdRol = 2)
    INSERT INTO Rol (IdRol, Nombre, Descripcion, NivelAcceso, AdministrarCursos, GestionarUsuarios, CorregirEvaluaciones, VerReportes)
    VALUES (2, 'Docente', 'Rol docente',            2, 1, 0, 1, 1);

/* ==== USUARIOS ==== */
SELECT @IdUsuarioAlumno = IdUsuario
FROM Usuario
WHERE Email = 'juan.perez@example.com';

IF @IdUsuarioAlumno IS NULL
BEGIN
    INSERT INTO Usuario (IdRol, Nombre, Apellido, Email, [Contraseña], FotoPerfil, Documento, Telefono, Ciudad, Pais, FechaNacimiento, Activo)
    VALUES (1, 'Juan', 'Perez', 'juan.perez@example.com', '1234', NULL, '12345678', '1111-1111', 'Buenos Aires', 'Argentina', '1990-01-01', 1);

    SET @IdUsuarioAlumno = SCOPE_IDENTITY();
END

SELECT @IdUsuarioDocente = IdUsuario
FROM Usuario
WHERE Email = 'laura.gomez@example.com';

IF @IdUsuarioDocente IS NULL
BEGIN
    INSERT INTO Usuario (IdRol, Nombre, Apellido, Email, [Contraseña], FotoPerfil, Documento, Telefono, Ciudad, Pais, FechaNacimiento, Activo)
    VALUES (2, 'Laura', 'Gomez', 'laura.gomez@example.com', '1234', NULL, '23456789', '2222-2222', 'Buenos Aires', 'Argentina', '1985-05-10', 1);

    SET @IdUsuarioDocente = SCOPE_IDENTITY();
END

/* ==== DOCENTE ==== */
SELECT @IdDocente = d.IdDocente
FROM Docente d
JOIN Usuario u ON u.IdUsuario = d.IdUsuario
WHERE u.Email = 'laura.gomez@example.com';

IF @IdDocente IS NULL
BEGIN
    INSERT INTO Docente (IdUsuario, Biografia, Especialidad, ExperienciaAnos)
    VALUES (@IdUsuarioDocente, 'Docente de base de datos y programacion', 'Base de Datos', 8);

    SET @IdDocente = SCOPE_IDENTITY();
END

/* ==== CATEGORIA ==== */
SELECT @IdCategoriaProgramacion = IdCategoria
FROM Categoria
WHERE Nombre = 'Programacion';

IF @IdCategoriaProgramacion IS NULL
BEGIN
    INSERT INTO Categoria (Nombre, Descripcion, ImagenPortadaUrl, Activo)
    VALUES ('Programacion', 'Cursos de programacion y bases de datos', NULL, 1);

    SET @IdCategoriaProgramacion = SCOPE_IDENTITY();
END

/* ==== ESTADOS ==== */
SELECT @IdEstadoInscripcionEnCurso = IdEstado
FROM Estado
WHERE Tipo = 'INSCRIPCION' AND Situacion = 'EN CURSO';

IF @IdEstadoInscripcionEnCurso IS NULL
BEGIN
    INSERT INTO Estado (Tipo, Situacion, Descripcion)
    VALUES ('INSCRIPCION', 'EN CURSO', 'Inscripcion activa');

    SET @IdEstadoInscripcionEnCurso = SCOPE_IDENTITY();
END

SELECT @IdEstadoInscripcionAprobado = IdEstado
FROM Estado
WHERE Tipo = 'INSCRIPCION' AND Situacion = 'APROBADO';

IF @IdEstadoInscripcionAprobado IS NULL
BEGIN
    INSERT INTO Estado (Tipo, Situacion, Descripcion)
    VALUES ('INSCRIPCION', 'APROBADO', 'Curso aprobado por evaluaciones');

    SET @IdEstadoInscripcionAprobado = SCOPE_IDENTITY();
END

SELECT @IdEstadoPagoPendiente = IdEstado
FROM Estado
WHERE Tipo = 'PAGO' AND Situacion = 'PENDIENTE';

IF @IdEstadoPagoPendiente IS NULL
BEGIN
    INSERT INTO Estado (Tipo, Situacion, Descripcion)
    VALUES ('PAGO', 'PENDIENTE', 'Pago pendiente');

    SET @IdEstadoPagoPendiente = SCOPE_IDENTITY();
END

SELECT @IdEstadoPagoAprobado = IdEstado
FROM Estado
WHERE Tipo = 'PAGO' AND Situacion = 'APROBADO';

IF @IdEstadoPagoAprobado IS NULL
BEGIN
    INSERT INTO Estado (Tipo, Situacion, Descripcion)
    VALUES ('PAGO', 'APROBADO', 'Pago acreditado');

    SET @IdEstadoPagoAprobado = SCOPE_IDENTITY();
END

/* ==== CURSO ==== */
SELECT @IdCursoSQL = IdCurso
FROM Curso
WHERE Codigo = 'SQL-01';

IF @IdCursoSQL IS NULL
BEGIN
    INSERT INTO Curso (
        Codigo, Titulo, Descripcion, Objetivos, Nivel, Idioma, RequisitosPrevios,
        DuracionHoras, FechaInicio, FechaFin, Modalidad, CupoMaximo,
        Precio, Moneda, RequierePago, Publicado, ImagenPortadaUrl, CertificadoDisponible, IdCategoria
    )
    VALUES (
        'SQL-01',
        'SQL desde cero',
        'Curso introductorio de SQL para manejo de bases de datos relacionales.',
        'Comprender SELECT, filtros, joins y evaluaciones basicas.',
        'Inicial',
        'Español',
        'Conocimientos basicos de PC',
        20,
        '2025-01-01',
        '2025-03-31',
        'Online',
        100,
        10000,
        'ARS',
        1,
        1,
        NULL,
        1,
        @IdCategoriaProgramacion
    );

    SET @IdCursoSQL = SCOPE_IDENTITY();
END

/* ==== MODULO ==== */
SELECT @IdModulo1 = IdModulo
FROM Modulo
WHERE IdCurso = @IdCursoSQL AND Titulo = 'Fundamentos de SQL';

IF @IdModulo1 IS NULL
BEGIN
    INSERT INTO Modulo (IdCurso, Titulo, Orden, Resumen, Objetivos)
    VALUES (
        @IdCursoSQL,
        'Fundamentos de SQL',
        1,
        'Conceptos basicos y primeras consultas',
        'Aprender SELECT, WHERE y consultas simples'
    );

    SET @IdModulo1 = SCOPE_IDENTITY();
END

/* ==== CLASES ==== */
SELECT @IdClaseIntro = IdClase
FROM Clase
WHERE IdModulo = @IdModulo1 AND Titulo = 'Introduccion a SQL';

IF @IdClaseIntro IS NULL
BEGIN
    INSERT INTO Clase (
        IdModulo, Titulo, Orden, TipoContenido, DuracionMin,
        RecursoUrl, MaterialDescargableUrl, FechaPublicacion,
        EsEvaluable, RequiereAprobacionPrevia
    )
    VALUES (
        @IdModulo1,
        'Introduccion a SQL',
        1,
        'VIDEO',
        30,
        NULL,
        NULL,
        GETDATE(),
        0,
        0
    );

    SET @IdClaseIntro = SCOPE_IDENTITY();
END

SELECT @IdClaseSelect = IdClase
FROM Clase
WHERE IdModulo = @IdModulo1 AND Titulo = 'Consultas SELECT basicas';

IF @IdClaseSelect IS NULL
BEGIN
    INSERT INTO Clase (
        IdModulo, Titulo, Orden, TipoContenido, DuracionMin,
        RecursoUrl, MaterialDescargableUrl, FechaPublicacion,
        EsEvaluable, RequiereAprobacionPrevia
    )
    VALUES (
        @IdModulo1,
        'Consultas SELECT basicas',
        2,
        'VIDEO',
        40,
        NULL,
        NULL,
        GETDATE(),
        1,
        0
    );

    SET @IdClaseSelect = SCOPE_IDENTITY();
END

SELECT @IdClaseWhere = IdClase
FROM Clase
WHERE IdModulo = @IdModulo1 AND Titulo = 'Filtros con WHERE';

IF @IdClaseWhere IS NULL
BEGIN
    INSERT INTO Clase (
        IdModulo, Titulo, Orden, TipoContenido, DuracionMin,
        RecursoUrl, MaterialDescargableUrl, FechaPublicacion,
        EsEvaluable, RequiereAprobacionPrevia
    )
    VALUES (
        @IdModulo1,
        'Filtros con WHERE',
        3,
        'VIDEO',
        45,
        NULL,
        NULL,
        GETDATE(),
        1,
        0
    );

    SET @IdClaseWhere = SCOPE_IDENTITY();
END

/* ==== CURSO POR DOCENTE ==== */
IF NOT EXISTS (
    SELECT 1 FROM CursoPorDocente
    WHERE IdCurso = @IdCursoSQL AND IdDocente = @IdDocente
)
BEGIN
    INSERT INTO CursoPorDocente (IdCurso, IdDocente)
    VALUES (@IdCursoSQL, @IdDocente);
END

/* ==== INSCRIPCION DEL ALUMNO ==== */
SELECT @IdInscripcionAlumno = IdInscripcion
FROM Inscripcion
WHERE IdUsuario = @IdUsuarioAlumno AND IdCurso = @IdCursoSQL;

IF @IdInscripcionAlumno IS NULL
BEGIN
    INSERT INTO Inscripcion (
        IdUsuario, IdCurso, IdEstado, Bloqueado,
        FechaInscripcion, Origen, Observaciones, FechaFinAcceso, CertificadoUrl
    )
    VALUES (
        @IdUsuarioAlumno,
        @IdCursoSQL,
        @IdEstadoInscripcionEnCurso,
        0,
        GETDATE(),
        'WEB',
        NULL,
        NULL,
        NULL
    );

    SET @IdInscripcionAlumno = SCOPE_IDENTITY();
END

/* ==== PAGO ==== */
IF NOT EXISTS (
    SELECT 1 FROM Pago
    WHERE IdInscripcion = @IdInscripcionAlumno
      AND CodigoTransaccion = 'PAGO-TEST-001'
)
BEGIN
    INSERT INTO Pago (
        IdInscripcion, IdEstado, FechaPago, Monto, Moneda, MedioPago, CodigoTransaccion, Aprobado
    )
    VALUES (
        @IdInscripcionAlumno,
        @IdEstadoPagoAprobado,
        GETDATE(),
        10000,
        'ARS',
        'Tarjeta',
        'PAGO-TEST-001',
        1
    );
END

/* ==== CHEQUEOS ==== */
SELECT * FROM Usuario;
SELECT * FROM Curso;
SELECT * FROM Modulo;
SELECT * FROM Clase;
SELECT * FROM Inscripcion;
SELECT * FROM Estado;
