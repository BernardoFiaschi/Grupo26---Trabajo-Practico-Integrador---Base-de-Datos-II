Table USUARIO {
  IDUSER int [pk, increment, not null]
  TIPOUSER smallint 
  NOMBRE varchar(255)
  APELLIDO varchar(255)
}

Table CATEGORIA {
  IDCATEGORIA int [pk, increment, not null]
  NOMBRECATEGORIA varchar(255)
}

Table CURSO {
  IDCURSO int [pk, increment, not null]
  NOMBRECURSO varchar(255) [not null, unique]
  IDCATEGORIA int [not null] 
}

Table MODULO {
  IDMODULO int [pk, increment, not null]
  TITULO varchar(255)
  IDCURSO int [not null]
}

Table CLASE {
  IDCLASE int [pk, increment, not null]
  TITULO varchar(255)
  IDMODULO int [not null]
}

Table INSCRIPCION {
  NROINSCRIP int [pk, increment, not null]
  IDUSER int [not null]
  IDCURSO int [not null]
  FECHAINSCRIP date
}

Table EVALUACION {
  IDEVAL int [pk, increment, not null]
  IDUSER int [not null]
  IDCLASE int [not null] 
  CALIFICACIÓN float
  FECHA datetime
}

Table PROGRESO {
  ID int [pk, increment, not null]
  IDUSER int [not null]
  IDCLASE int [not null] 
  ESTADO varchar(20)
  PORCENTAJE int
}

Table PAGO {
  ID int [pk, increment, not null]
  IDUSER int [not null]
  IDCURSO int [not null]
  FECHA datetime
  MONTO decimal(10,2)
  ESTADO varchar(20)
}

Ref: CURSO.IDCATEGORIA > CATEGORIA.IDCATEGORIA
Ref: MODULO.IDCURSO     > CURSO.IDCURSO
Ref: CLASE.IDMODULO     > MODULO.IDMODULO

Ref: INSCRIPCION.IDUSER  > USUARIO.IDUSER
Ref: INSCRIPCION.IDCURSO > CURSO.IDCURSO

Ref: EVALUACION.IDUSER > USUARIO.IDUSER
Ref: EVALUACION.IDCLASE > CLASE.IDCLASE

Ref: PROGRESO.IDUSER > USUARIO.IDUSER
Ref: PROGRESO.IDCLASE > CLASE.IDCLASE

Ref: PAGO.IDUSER  > USUARIO.IDUSER
Ref: PAGO.IDCURSO > CURSO.IDCURSO
