
-- REGISTRAR NOTA: Registra dos evaluaciones aprobadas usando el SP
  
USE BD2_TPI_G26;

DECLARE 
    @IdUsuarioAlumno2 int,
    @IdCursoSQL2      int,
    @IdClaseSelect    int,
    @IdClaseWhere     int;

SELECT @IdUsuarioAlumno2 = IdUsuario
FROM dbo.Usuario
WHERE Email = 'juan.perez@example.com';

SELECT @IdCursoSQL2 = IdCurso
FROM dbo.Curso
WHERE Codigo = 'SQL-01';

SELECT @IdClaseSelect = c.IdClase
FROM dbo.Clase c
JOIN dbo.Modulo m ON m.IdModulo = c.IdModulo
WHERE m.IdCurso = @IdCursoSQL2
  AND c.Titulo = 'Consultas SELECT basicas';

SELECT @IdClaseWhere = c.IdClase
FROM dbo.Clase c
JOIN dbo.Modulo m ON m.IdModulo = c.IdModulo
WHERE m.IdCurso = @IdCursoSQL2
  AND c.Titulo = 'Filtros con WHERE';

EXEC dbo.SP_RegistrarCalificacionEvaluacion
    @IdUsuario         = @IdUsuarioAlumno2,
    @IdClase           = @IdClaseSelect,
    @PuntajeObtenido   = 8,
    @TiempoEmpleadoMin = 30,
    @Observaciones     = 'Evaluacion 1 - demo';

EXEC dbo.SP_RegistrarCalificacionEvaluacion
    @IdUsuario         = @IdUsuarioAlumno2,
    @IdClase           = @IdClaseWhere,
    @PuntajeObtenido   = 9,
    @TiempoEmpleadoMin = 40,
    @Observaciones     = 'Evaluacion 2 - demo';

SELECT 
    e.IdEvaluacion,
    e.IdUsuario,
    e.IdClase,
    e.PuntajeObtenido,
    e.PuntajeAprob,
    e.Aprobado,
    e.EstadoEvaluacion
FROM dbo.Evaluacion e
WHERE e.IdUsuario = @IdUsuarioAlumno2
  AND e.IdClase IN (@IdClaseSelect, @IdClaseWhere);



-- BLOQUE 3 - EFECTO DEL TRIGGER + VISTA: Ver inscripcion actualizada a APROBADO y reporte en la vista

/*

USE BD2_TPI_G26;

DECLARE 
    @IdUsuarioAlumno3 int,
    @IdCursoSQL3      int;

SELECT @IdUsuarioAlumno3 = IdUsuario
FROM dbo.Usuario
WHERE Email = 'juan.perez@example.com';

SELECT @IdCursoSQL3 = IdCurso
FROM dbo.Curso
WHERE Codigo = 'SQL-01';

SELECT 
    i.IdInscripcion,
    i.IdUsuario,
    i.IdCurso,
    e.Situacion AS EstadoInscripcion
FROM dbo.Inscripcion i
JOIN dbo.Estado e ON e.IdEstado = i.IdEstado
WHERE i.IdUsuario = @IdUsuarioAlumno3
  AND i.IdCurso   = @IdCursoSQL3;


SELECT *
FROM dbo.VW_NotasCursoAlumno
WHERE IdUsuario = @IdUsuarioAlumno3
  AND IdCurso   = @IdCursoSQL3;


/*

USE BD2_TPI_G26;

DECLARE 
    @IdUsuarioAlumno4 int,
    @IdCursoSQL4      int,
    @IdClaseSelect4   int;

SELECT @IdUsuarioAlumno4 = IdUsuario
FROM dbo.Usuario
WHERE Email = 'juan.perez@example.com';

SELECT @IdCursoSQL4 = IdCurso
FROM dbo.Curso
WHERE Codigo = 'SQL-01';

SELECT @IdClaseSelect4 = c.IdClase
FROM dbo.Clase c
JOIN dbo.Modulo m ON m.IdModulo = c.IdModulo
WHERE m.IdCurso = @IdCursoSQL4
  AND c.Titulo  = 'Consultas SELECT basicas';

EXEC dbo.SP_RegistrarCalificacionEvaluacion
    @IdUsuario         = @IdUsuarioAlumno4,
    @IdClase           = @IdClaseSelect4,
    @PuntajeObtenido   = 10,
    @TiempoEmpleadoMin = 20,
    @Observaciones     = 'Intento repetido para demo';


*/