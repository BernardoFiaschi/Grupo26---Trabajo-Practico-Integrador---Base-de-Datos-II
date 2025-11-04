CREATE TABLE [Rol] (
  [Id] smallint PRIMARY KEY NOT NULL,
  [Nombre] varchar(50) UNIQUE NOT NULL,
  [Descripcion] varchar(300),
  [NivelAcceso] smallint NOT NULL DEFAULT (1),
  [AdministrarCursos] boolean NOT NULL DEFAULT (false),
  [GestionarUsuarios] boolean NOT NULL DEFAULT (false),
  [CorregirEvaluaciones] boolean NOT NULL DEFAULT (false),
  [VerReportes] boolean NOT NULL DEFAULT (false)
)
GO

CREATE TABLE [Usuario] (
  [Id] int PRIMARY KEY NOT NULL IDENTITY(1, 1),
  [RolId] smallint NOT NULL,
  [Nombre] varchar(120) NOT NULL,
  [Apellido] varchar(120) NOT NULL,
  [Email] varchar(255) UNIQUE NOT NULL,
  [ContrasenaHash] varchar(255),
  [FotoPerfil] varchar(500),
  [Documento] varchar(20),
  [Telefono] varchar(30),
  [Ciudad] varchar(80),
  [Pais] varchar(80),
  [FechaNacimiento] date,
  [Activo] boolean NOT NULL DEFAULT (true)
)
GO

CREATE TABLE [Categoria] (
  [Id] int PRIMARY KEY NOT NULL IDENTITY(1, 1),
  [Nombre] varchar(150) UNIQUE NOT NULL,
  [Descripcion] varchar(500),
  [ImagenPortadaUrl] varchar(500)
)
GO

CREATE TABLE [Curso] (
  [Id] int PRIMARY KEY NOT NULL IDENTITY(1, 1),
  [CategoriaId] int NOT NULL,
  [Codigo] varchar(30) UNIQUE,
  [Titulo] varchar(255) NOT NULL,
  [Descripcion] text,
  [Objetivos] text,
  [Nivel] varchar(20) NOT NULL,
  [Idioma] varchar(30) NOT NULL,
  [RequisitosPrevios] text,
  [DuracionHoras] int,
  [FechaInicio] date NOT NULL,
  [FechaFin] date NOT NULL,
  [Modalidad] varchar(20) NOT NULL,
  [CupoMaximo] int,
  [Precio] decimal(10,2) NOT NULL,
  [Moneda] char(3) NOT NULL,
  [RequierePago] boolean NOT NULL DEFAULT (false),
  [Publicado] boolean NOT NULL DEFAULT (false),
  [ImagenPortadaUrl] varchar(500),
  [CertificadoDisponible] boolean NOT NULL DEFAULT (false)
)
GO

CREATE TABLE [CursoDocente] (
  [Id] int PRIMARY KEY NOT NULL IDENTITY(1, 1),
  [CursoId] int NOT NULL,
  [UsuarioId] int NOT NULL,
  [RolDocente] varchar(30) NOT NULL,
  [AreaEspecialidad] varchar(100),
  [ExperienciaAnios] smallint,
  [BiografiaCorta] varchar(500),
  [EnlacePerfil] varchar(500),
  [Activo] boolean NOT NULL DEFAULT (true),
  [FechaAsignacion] date NOT NULL,
  [FechaFin] date
)
GO

CREATE TABLE [Modulo] (
  [Id] int PRIMARY KEY NOT NULL IDENTITY(1, 1),
  [CursoId] int NOT NULL,
  [Titulo] varchar(255) NOT NULL,
  [Orden] smallint NOT NULL,
  [Resumen] varchar(500),
  [Objetivos] text
)
GO

CREATE TABLE [Clase] (
  [Id] int PRIMARY KEY NOT NULL IDENTITY(1, 1),
  [ModuloId] int NOT NULL,
  [Titulo] varchar(255) NOT NULL,
  [Orden] smallint NOT NULL,
  [TipoContenido] varchar(30) NOT NULL,
  [DuracionMin] int,
  [RecursoUrl] varchar(500),
  [MaterialDescargableUrl] varchar(500),
  [FechaPublicacion] datetime,
  [EsEvaluable] boolean NOT NULL DEFAULT (false),
  [RequiereAprobacionPrevia] boolean NOT NULL DEFAULT (false)
)
GO

CREATE TABLE [Estado] (
  [Id] int PRIMARY KEY NOT NULL IDENTITY(1, 1),
  [Tipo] varchar(30) NOT NULL,
  [Situacion] varchar(30) NOT NULL,
  [Descripcion] varchar(100)
)
GO

CREATE TABLE [Inscripcion] (
  [Id] int PRIMARY KEY NOT NULL IDENTITY(1, 1),
  [UsuarioId] int NOT NULL,
  [CursoId] int NOT NULL,
  [EstadoId] int NOT NULL,
  [Bloqueado] boolean NOT NULL DEFAULT (false),
  [FechaInscripcion] datetime,
  [Origen] varchar(20) NOT NULL,
  [Observaciones] varchar(300),
  [FechaFinAcceso] date,
  [CertificadoUrl] varchar(500)
)
GO

CREATE TABLE [Pago] (
  [Id] int PRIMARY KEY NOT NULL IDENTITY(1, 1),
  [InscripcionId] int NOT NULL,
  [EstadoId] int NOT NULL,
  [Monto] decimal(10,2) NOT NULL,
  [Moneda] char(3) NOT NULL,
  [Medio] varchar(30),
  [ComprobanteUrl] varchar(500),
  [CuotaNumero] int,
  [TotalCuotas] int,
  [FechaPago] datetime,
  [Vencimiento] date
)
GO

CREATE TABLE [Progreso] (
  [Id] int PRIMARY KEY NOT NULL IDENTITY(1, 1),
  [UsuarioId] int NOT NULL,
  [CursoId] int NOT NULL,
  [ClasesCompletadas] int NOT NULL DEFAULT (0),
  [TotalClases] int NOT NULL DEFAULT (0),
  [Porcentaje] int NOT NULL DEFAULT (0),
  [Estado] varchar(20) NOT NULL,
  [UltimaClaseVista] int,
  [FechaUltimaActividad] datetime,
  [FechaFinalizacion] datetime,
  [TiempoTotalMin] int
)
GO

CREATE TABLE [Evaluacion] (
  [Id] int PRIMARY KEY NOT NULL IDENTITY(1, 1),
  [UsuarioId] int NOT NULL,
  [ClaseId] int NOT NULL,
  [Tipo] varchar(30) NOT NULL,
  [TituloEvaluacion] varchar(255) NOT NULL,
  [Descripcion] text,
  [PuntajeMax] float NOT NULL DEFAULT (10),
  [PuntajeObtenido] float,
  [PuntajeAprob] float NOT NULL DEFAULT (6),
  [Aprobado] boolean,
  [FechaRealizacion] datetime,
  [TiempoEmpleadoMin] int,
  [Observaciones] text,
  [Intentos] smallint DEFAULT (1),
  [EstadoEvaluacion] varchar(20) NOT NULL,
  [CalificadoPor] int
)
GO

CREATE UNIQUE INDEX [CursoDocente_index_0] ON [CursoDocente] ("CursoId", "UsuarioId")
GO

CREATE UNIQUE INDEX [Modulo_index_1] ON [Modulo] ("CursoId", "Orden")
GO

CREATE UNIQUE INDEX [Clase_index_2] ON [Clase] ("ModuloId", "Orden")
GO

CREATE UNIQUE INDEX [Estado_index_3] ON [Estado] ("Tipo", "Situacion")
GO

CREATE UNIQUE INDEX [Inscripcion_index_4] ON [Inscripcion] ("UsuarioId", "CursoId")
GO

CREATE UNIQUE INDEX [Progreso_index_5] ON [Progreso] ("UsuarioId", "CursoId")
GO

CREATE UNIQUE INDEX [Evaluacion_index_6] ON [Evaluacion] ("UsuarioId", "ClaseId")
GO

ALTER TABLE [Usuario] ADD FOREIGN KEY ([RolId]) REFERENCES [Rol] ([Id]) ON DELETE RESTRICT ON UPDATE CASCADE
GO

ALTER TABLE [Curso] ADD FOREIGN KEY ([CategoriaId]) REFERENCES [Categoria] ([Id]) ON DELETE RESTRICT ON UPDATE CASCADE
GO

ALTER TABLE [Modulo] ADD FOREIGN KEY ([CursoId]) REFERENCES [Curso] ([Id]) ON DELETE CASCADE ON UPDATE CASCADE
GO

ALTER TABLE [Clase] ADD FOREIGN KEY ([ModuloId]) REFERENCES [Modulo] ([Id]) ON DELETE CASCADE ON UPDATE CASCADE
GO

ALTER TABLE [CursoDocente] ADD FOREIGN KEY ([CursoId]) REFERENCES [Curso] ([Id]) ON DELETE CASCADE ON UPDATE CASCADE
GO

ALTER TABLE [CursoDocente] ADD FOREIGN KEY ([UsuarioId]) REFERENCES [Usuario] ([Id]) ON DELETE RESTRICT ON UPDATE CASCADE
GO

ALTER TABLE [Inscripcion] ADD FOREIGN KEY ([UsuarioId]) REFERENCES [Usuario] ([Id]) ON DELETE RESTRICT ON UPDATE CASCADE
GO

ALTER TABLE [Inscripcion] ADD FOREIGN KEY ([CursoId]) REFERENCES [Curso] ([Id]) ON DELETE RESTRICT ON UPDATE CASCADE
GO

ALTER TABLE [Pago] ADD FOREIGN KEY ([InscripcionId]) REFERENCES [Inscripcion] ([Id]) ON DELETE RESTRICT ON UPDATE CASCADE
GO

ALTER TABLE [Progreso] ADD FOREIGN KEY ([UsuarioId]) REFERENCES [Usuario] ([Id]) ON DELETE CASCADE ON UPDATE CASCADE
GO

ALTER TABLE [Progreso] ADD FOREIGN KEY ([CursoId]) REFERENCES [Curso] ([Id]) ON DELETE CASCADE ON UPDATE CASCADE
GO

ALTER TABLE [Progreso] ADD FOREIGN KEY ([UltimaClaseVista]) REFERENCES [Clase] ([Id]) ON DELETE SET NULL ON UPDATE CASCADE
GO

ALTER TABLE [Evaluacion] ADD FOREIGN KEY ([UsuarioId]) REFERENCES [Usuario] ([Id]) ON DELETE RESTRICT ON UPDATE CASCADE
GO

ALTER TABLE [Evaluacion] ADD FOREIGN KEY ([ClaseId]) REFERENCES [Clase] ([Id]) ON DELETE CASCADE ON UPDATE CASCADE
GO

ALTER TABLE [Evaluacion] ADD FOREIGN KEY ([CalificadoPor]) REFERENCES [Usuario] ([Id]) ON DELETE SET NULL ON UPDATE CASCADE
GO

ALTER TABLE [Inscripcion] ADD FOREIGN KEY ([EstadoId]) REFERENCES [Estado] ([Id]) ON DELETE RESTRICT
GO

ALTER TABLE [Pago] ADD FOREIGN KEY ([EstadoId]) REFERENCES [Estado] ([Id]) ON DELETE RESTRICT
GO
