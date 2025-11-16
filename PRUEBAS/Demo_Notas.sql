/*
USE Creacion;
GO

/* =========================================================
   BLOQUE 1 - RESET DEL ESCENARIO DE NOTAS
   Idea: dejar al alumno Juan inscripto en SQL-01 en estado EN CURSO
   y sin ninguna evaluacion cargada, para poder repetir la demo.
   ========================================================= */

DECLARE @IdAlumno        int,
        @IdCurso         int,
        @IdEstadoEnCurso int;

-- Me guardo el Id del alumno de pruebas
SELECT @IdAlumno = IdUsuario
FROM Usuario
WHERE Email = 'juan.perez@example.com';

-- Me guardo el Id del curso de pruebas
SELECT @IdCurso = IdCurso
FROM Curso
WHERE Codigo = 'SQL-01';

-- Busco el estado "EN CURSO" para las inscripciones
SELECT @IdEstadoEnCurso = IdEstado
FROM Estado
WHERE Tipo = 'INSCRIPCION'
  AND Situacion = 'EN CURSO';

-- Borro todas las evaluaciones de este alumno en este curso
DELETE FROM Evaluacion
WHERE IdUsuario = @IdAlumno
  AND IdClase IN (
        SELECT c.IdClase
        FROM Clase c
        JOIN Modulo m ON c.IdModulo = m.IdModulo
        WHERE m.IdCurso = @IdCurso
  );

-- Vuelvo la inscripcion al estado EN CURSO
UPDATE Inscripcion
SET IdEstado = @IdEstadoEnCurso
WHERE IdUsuario = @IdAlumno
  AND IdCurso   = @IdCurso;

-- Chequeo rapido como quedo la inscripcion
SELECT * 
FROM Inscripcion
WHERE IdUsuario = @IdAlumno
  AND IdCurso   = @IdCurso;
GO

*/


USE Creacion;
GO


/* =========================================================
   BLOQUE 2 - CARGA DE EVALUACIONES USANDO EL SP
   Aca llamo al SP_RegistrarCalificacionEvaluacion para dos clases.
   La idea es mostrar que toda la logica pasa por el SP y no se inserta
   directo en la tabla Evaluacion.
   ========================================================= */

DECLARE @IdAlumno2      int,
        @IdClaseSelect  int,
        @IdClaseWhere   int;

-- Id del mismo alumno de pruebas
SELECT @IdAlumno2 = IdUsuario
FROM Usuario
WHERE Email = 'juan.perez@example.com';

-- Id de la clase "Consultas SELECT basicas"
SELECT @IdClaseSelect = IdClase
FROM Clase
WHERE Titulo = 'Consultas SELECT basicas';

-- Id de la clase "Filtros con WHERE"
SELECT @IdClaseWhere = IdClase
FROM Clase
WHERE Titulo = 'Filtros con WHERE';

-- Primera evaluacion (SELECT basicas)
EXEC dbo.SP_RegistrarCalificacionEvaluacion
    @IdUsuario         = @IdAlumno2,
    @IdClase           = @IdClaseSelect,
    @PuntajeObtenido   = 8,
    @TiempoEmpleadoMin = 25,
    @Observaciones     = 'Primera evaluacion';

-- Segunda evaluacion (WHERE)
EXEC dbo.SP_RegistrarCalificacionEvaluacion
    @IdUsuario         = @IdAlumno2,
    @IdClase           = @IdClaseWhere,
    @PuntajeObtenido   = 9,
    @TiempoEmpleadoMin = 30,
    @Observaciones     = 'Segunda evaluacion';
GO


USE Creacion;
GO

/* =========================================================
   BLOQUE 3 - VER RESULTADOS
   Aca muestro:
   - como quedaron las filas en Evaluacion,
   - como el trigger actualizo el estado de la Inscripcion,
   - y el reporte final de VW_NotasCursoAlumno con el curso aprobado.
   Este bloque es el que voy a usar en el video para explicar la logica.
   ========================================================= */

SELECT * FROM Evaluacion;
SELECT * FROM Inscripcion;
SELECT * FROM VW_NotasCursoAlumno;
GO
