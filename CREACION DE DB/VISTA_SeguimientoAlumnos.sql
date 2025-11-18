
USE BD2_TPI_G26;
go
--Vista de Seguimiento de Alumnos por curso.
--Muestra informacion basica de alumnos inscritos y su progreso

IF OBJECT_ID('dbo.VW_SeguimientoAlumnos', 'V') IS NOT NULL
	DROP VIEW dbo.VW_SeguimientoAlumnos;

GO

CREATE VIEW	dbo.VW_SeguimientoAlumnos
AS
WITH ProgresoAlumnos AS (
	SELECT
		i.IdUsuario,
		i.IdCurso,
		i.IdEstado,
		e.Situacion as EstadoInscripcion,
		i.FechaInscripcion,
		i.FechaFinAcceso,
		i.Bloqueado,
		p.ClasesCompletadas,
		p.TotalClases,
		p.Porcentaje AS ProgresoPorcentaje,
		p.Estado AS EstadoProgreso,
		p.FechaUltimaActividad,
		p.FechaFinalizacion

	FROM dbo.Inscripcion as i
	LEFT JOIN dbo.Estado as e ON i.IdEstado = e.IdEstado
	LEFT JOIN dbo.Progreso as p ON i.IdUsuario = p.IdUsuario AND i.IdCurso = p.IdCurso
)
SELECT 
	u.IdUsuario,
    u.Nombre,
    u.Apellido,
    u.Email,
    u.Telefono,
    c.IdCurso,
    c.Titulo AS NombreCurso,
    c.Codigo AS CodigoCurso,
	pa.EstadoInscripcion,
	pa.FechaInscripcion,
	pa.FechaFinAcceso,
	pa.Bloqueado,
	pa.ClasesCompletadas,
	pa.TotalClases,
	pa.ProgresoPorcentaje,
	pa.EstadoProgreso,
	pa.FechaUltimaActividad,
	pa.FechaFinalizacion,
	CASE--case que se representara como una columna
		WHEN pa.Bloqueado = 1 THEN 'BLOQUEADO'
		WHEN pa.FechaFinAcceso < GETDATE() THEN 'ACCESO EXPIRADO'
		WHEN pa.ProgresoPorcentaje = 100 THEN 'CURSO COMPLETADO'
		WHEN pa.ProgresoPorcentaje > 0 THEN 'EN PROGRESO'
		ELSE 'NO INICIADO'
	END AS EstadoAlumno,--La columna contendra el estado del alumno en los cursos
	CASE 
		WHEN pa.FechaUltimaActividad IS NOT NULL
		THEN DATEDIFF(DAY, pa.FechaUltimaActividad, GETDATE())
		ELSE DATEDIFF(DAY, pa.FechaInscripcion,GETDATE())
	END AS DiasInactivos
FROM ProgresoAlumnos AS pa
INNER JOIN dbo.Usuario AS u ON u.IdUsuario = pa.IdUsuario--Mostrar registros donde coincida IdUsuario (tabla de usuarios)
INNER JOIN dbo.Curso AS c ON c.IdCurso = pa.IdCurso --Y coincida IdCurso (tabla de progreso) con el IdCurso (tabla de curso)
WHERE u.Activo = 1; --Solo cuando este el usuario este activo (en alta).
Go