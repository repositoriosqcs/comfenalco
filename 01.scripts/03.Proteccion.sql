USE DWH_COMFENALCO
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Eliminar restricciones de clave for�nea
DECLARE @sql NVARCHAR(MAX) = '';
SELECT @sql += 'ALTER TABLE ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) 
    + ' DROP CONSTRAINT ' + QUOTENAME(f.name) + '; ' 
FROM sys.foreign_keys f
INNER JOIN sys.tables t ON f.parent_object_id = t.object_id
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = 'Proteccion';
EXEC sp_executesql @sql;
-- Eliminar tablas
SET @sql = '';
SELECT @sql += 'DROP TABLE ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + '; ' 
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = 'Proteccion';
EXEC sp_executesql @sql;
-- Eliminar el esquema
IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'Proteccion')
BEGIN
    DROP SCHEMA Proteccion;
END
GO
-- Crear el esquema Proteccion
CREATE SCHEMA Proteccion;
GO 
-- Crear Proteccion.DIM_POBLACION
CREATE TABLE [Proteccion].[DIM_POBLACION] (
    [ID_POBLACION] [int] IDENTITY(1,1) NOT NULL,
    [TIPO_DOCUMENTO] [nvarchar](20) NOT NULL,
    [DOCUMENTO] [nvarchar](50) NOT NULL,
    [ID_EMPRESA] [int] NULL DEFAULT -1, -- Asignar valor por defecto de -1,
    [ID_AFILIADO] [int] NULL DEFAULT -1, -- Asignar valor por defecto de -1,
    [ID_BENEFICIARIO] [int] NULL DEFAULT -1, -- Asignar valor por defecto de -1,
    [ID_APORTANTE] [int] NULL DEFAULT -1, -- Asignar valor por defecto de -1,
	CONSTRAINT [PK_DIM_POBLACION] PRIMARY KEY CLUSTERED ([ID_POBLACION])
)
GO
-- Crear Proteccion.DIM_ESTABLECIMIENTO_EDUCATIVO
CREATE TABLE [Proteccion].[DIM_ESTABLECIMIENTO_EDUCATIVO] (
    [ID_ESTABLECIMIENTO_EDUCATIVO] [int] IDENTITY(1,1) NOT NULL,
	--[COD_ESTABLECIMIENTO_EDUCATIVO] [int] NOT NULL,
	[NOMBRE_ESTABLECIMIENTO] [nvarchar](255) NOT NULL,
	--[TIPO_DOCUMENTO] [nvarchar](40) NOT NULL,
    --[DOCUMENTO] [nvarchar](20) NOT NULL,
	[REPRESENTANTE_LEGAL] [nvarchar](255) ,--NOT NULL
	--[NO_SEDES] [int] NOT NULL,
	[DIRECCION] [nvarchar](300) ,--NOT NULL
	--[COD_CIUDAD] [nvarchar](5) NULL
	[MUNICIPIO] [nvarchar](255) ,
	CONSTRAINT [PK_DIM_ESTABLECIMIENTO_EDUCATIVO] PRIMARY KEY CLUSTERED ([ID_ESTABLECIMIENTO_EDUCATIVO])
)
-- Crear Proteccion.DIM_PROGRAMA
CREATE TABLE [Proteccion].[DIM_PROGRAMA] (
	[ID_PROGRAMA] [int] IDENTITY(1,1) NOT NULL,
    [PROGRAMA] [nvarchar](40)
	CONSTRAINT [PK_DIM_PROGRAMA] PRIMARY KEY CLUSTERED ([ID_PROGRAMA])
)
GO
-- Crear Proteccion.DIM_CAMPOS_CARACT
CREATE TABLE [Proteccion].[DIM_CAMPOS_CARACT] (
    [ID_PREGUNTA] [int] IDENTITY(1,1) NOT NULL,
    [PREGUNTA] [nvarchar](255) NOT NULL,
    [OBSERVACIONES] [nvarchar](255),
	CONSTRAINT [PK_DIM_CAMPOS_CARACT] PRIMARY KEY CLUSTERED ([ID_PREGUNTA])
)
GO
-- Crear Proteccion.FACT_CARACTERIZACION
CREATE TABLE [Proteccion].[FACT_CARACTERIZACION] (
	[ID_CARACTERIZACION] [int] IDENTITY(1,1) NOT NULL,
    [ID_FECHA] [int] , --NOT NULL
    [FECHA] [datetime] NOT NULL,
    [ID_POBLACION] [int] NOT NULL,
    --[TIPO_DOCUMENTO] [nvarchar](40) NOT NULL,
    --[DOCUMENTO] [nvarchar](20) NOT NULL,
	[ID_PROGRAMA] [int] NOT NULL,
    [ID_PREGUNTA] [int] NOT NULL, 
    [RESPUESTA] [nvarchar](255),
    [OBSERVACIONES] [nvarchar](255),
	CONSTRAINT [PK_FACT_CARACTERIZACION] PRIMARY KEY CLUSTERED ([ID_CARACTERIZACION]),
	CONSTRAINT [FK_FACT_CARACTERIZACION_DIM_POBLACION] FOREIGN KEY ([ID_POBLACION]) REFERENCES [Proteccion].[DIM_POBLACION]([ID_POBLACION]),
	CONSTRAINT [FK_FACT_CARACTERIZACION_DIM_CAMPOS_CARACT] FOREIGN KEY ([ID_PREGUNTA]) REFERENCES [Proteccion].[DIM_CAMPOS_CARACT]([ID_PREGUNTA]),
	CONSTRAINT [FK_FACT_CARACTERIZACION_DIM_PROGRAMA] FOREIGN KEY ([ID_PROGRAMA]) REFERENCES [Proteccion].[DIM_PROGRAMA]([ID_PROGRAMA]),
	CONSTRAINT [FK_FACT_CARACTERIZACION_Dim_TIEMPO] FOREIGN KEY([ID_FECHA]) REFERENCES [Dwh].[DIM_TIEMPO] ([ID_FECHA])
)
GO
-- Crear Proteccion.FACT_PLAN_COBERTURA
CREATE TABLE [Proteccion].[FACT_PLAN_COBERTURA] (
	[ID_PLAN_COBERTURA] [int] IDENTITY(1,1) NOT NULL,
	--[ID_FECHA] [int] NOT NULL,
    [ANIO] [nvarchar](40),
    --[ZONA] [nvarchar](40),
    [MUNICIPIO] [nvarchar](40),
    [ID_ESTABLECIMIENTO_EDUCATIVO] [int] NOT NULL,
    --[NOMBRE_EE] [nvarchar](200),
    [ID_PROGRAMA] [int] NOT NULL,
	--[PROGRAMA] [nvarchar](40),
    [LINEA_INTERVENCION] [nvarchar](255),
    --[SEDE] [nvarchar](40),
    [COBERTURA_PROYECTADA] [nvarchar](255),
	CONSTRAINT [PK_FACT_PLAN_COBERTURA] PRIMARY KEY CLUSTERED ([ID_PLAN_COBERTURA]),
	CONSTRAINT [FK_FACT_PLAN_COBERTURA_DIM_ESTABLECIMIENTO_EDUCATIVO] FOREIGN KEY ([ID_ESTABLECIMIENTO_EDUCATIVO]) REFERENCES [Proteccion].[DIM_ESTABLECIMIENTO_EDUCATIVO]([ID_ESTABLECIMIENTO_EDUCATIVO]),
	CONSTRAINT [FK_FACT_PLAN_COBERTURA_DIM_PROGRAMA] FOREIGN KEY ([ID_PROGRAMA]) REFERENCES [Proteccion].[DIM_PROGRAMA]([ID_PROGRAMA]),
	--CONSTRAINT [FK_FACT_PLAN_COBERTURA_Dim_TIEMPO] FOREIGN KEY([ID_FECHA]) REFERENCES [Dwh].[DIM_TIEMPO] ([ID_FECHA])
)
GO
-- Crear Proteccion.FACT_VENTA
CREATE TABLE [Proteccion].[FACT_VENTA] (
	[ID_VENTA] [int] IDENTITY(1,1) NOT NULL,
    [ID_FECHA] [int] NOT NULL,
    [FECHA] [datetime] NOT NULL,
    [ID_POBLACION] [int] NOT NULL,
    [TIPO_DOCUMENTO] [nvarchar](40) NOT NULL,
    [DOCUMENTO] [nvarchar](20) NOT NULL,
    [NOMBRE_USUARIO] [nvarchar](200),
    [CATEGORIA_VENTA] [nvarchar](40),
	[ID_TARIFA] [int] NULL DEFAULT -1, -- Asignar valor por defecto de -1,
    --[COD_SERVICIO] [nvarchar](40),
    [SERVICIO] [nvarchar](200),
    [COSTO] [decimal](28, 2),
    [SUBSIDIO] [decimal](28, 2),
    [VALOR_PAGADO_SIN_IMP] [decimal](28, 2),
	CONSTRAINT [PK_FACT_VENTA] PRIMARY KEY CLUSTERED ([ID_VENTA]),
	CONSTRAINT [FK_FACT_VENTA_DIM_POBLACION] FOREIGN KEY ([ID_POBLACION]) REFERENCES [Proteccion].[DIM_POBLACION]([ID_POBLACION]),
	CONSTRAINT [FK_FACT_VENTA_DIM_SERVICIOS] FOREIGN KEY ([ID_TARIFA]) REFERENCES [Transversal].[DIM_TARIFAS_SERVICIOS]([ID_TARIFA]),
	CONSTRAINT [FK_FACT_VENTA_Dim_TIEMPO] FOREIGN KEY([ID_FECHA]) REFERENCES [Dwh].[DIM_TIEMPO] ([ID_FECHA])
)
GO
-- Crear Proteccion.DIM_PREGUNTAS_EE_JEC
CREATE TABLE [Proteccion].[DIM_PREGUNTAS_EE_JEC] (
	[ID_PREGUNTA] [int] IDENTITY(1,1) NOT NULL,
    [PREGUNTA] [nvarchar](255),
    [ID_PROGRAMA] [int] NOT NULL,
	CONSTRAINT [PK_DIM_PREGUNTAS_EE_JEC] PRIMARY KEY CLUSTERED ([ID_PREGUNTA]),
	CONSTRAINT [FK_DIM_PREGUNTAS_EE_JEC_DIM_PROGRAMA] FOREIGN KEY ([ID_PROGRAMA]) REFERENCES [Proteccion].[DIM_PROGRAMA]([ID_PROGRAMA])
)
GO
-- Crear Proteccion.DIM_RESPUESTAS_EE_JEC
CREATE TABLE [Proteccion].[DIM_RESPUESTAS_EE_JEC] (
    [ID_RESPUESTA] [int] IDENTITY(1,1) NOT NULL,
    [RESPUESTA] [nvarchar](255),
    [ID_PREGUNTA] [int] NOT NULL,
	CONSTRAINT [PK_DIM_RESPUESTAS_EE_JEC] PRIMARY KEY CLUSTERED ([ID_RESPUESTA]),
	CONSTRAINT [FK_DIM_RESPUESTAS_EE_JEC_DIM_PREGUNTAS_EE_JEC] FOREIGN KEY ([ID_PREGUNTA]) REFERENCES [Proteccion].[DIM_PREGUNTAS_EE_JEC]([ID_PREGUNTA])
)
GO
/*
--INSERT -1 values------------------------------------------------------------------------------
--USE DWH_COMFENALCO
--GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET IDENTITY_INSERT [DWH_COMFENALCO].[Proteccion].[DIM_RESPUESTAS_EE_JEC] ON
GO
-- Eliminar restricciones de clave for�nea
DECLARE @sql NVARCHAR(MAX) = '';
SELECT @sql += 'ALTER TABLE ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) 
    + ' DROP CONSTRAINT ' + QUOTENAME(f.name) + '; ' 
FROM sys.foreign_keys f
INNER JOIN sys.tables t ON f.parent_object_id = t.object_id
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = 'Proteccion';
EXEC sp_executesql @sql;
TRUNCATE TABLE [DWH_COMFENALCO].[Proteccion].[DIM_RESPUESTAS_EE_JEC];
INSERT INTO [Proteccion].[DIM_RESPUESTAS_EE_JEC] (ID_RESPUESTA,RESPUESTA,ID_PREGUNTA)
VALUES (-1,'RESPUESTA_PREGUNTA_ABIERTA',-1);

SET IDENTITY_INSERT [DWH_COMFENALCO].[Proteccion].[DIM_RESPUESTAS_EE_JEC] OFF 
------------------------------------------------------------------------------------------------
GO*/
-- Crear Proteccion.FACT_DIAGNOSTICOS_EE_JEC
CREATE TABLE [Proteccion].[FACT_DIAGNOSTICOS_EE_JEC] (
    [ID_REGISTRO] [int] IDENTITY(1,1) NOT NULL,
    [FECHA_HORA_INICIO] [datetime] NOT NULL,
    [FECHA_HORA_FIN] [datetime] NOT NULL,
    [CORREO_FUNCIONARIO] [nvarchar](200),
    [NOMBRE_FUNCIONARIO] [nvarchar](200),
    [TOTAL_PUNTOS] [nvarchar](40),
    [FECHA_ULT_MODIF] [datetime] ,
    --[ID_ESTABLECIMIENTO_EDUCATIVO] [int] NOT NULL,
    --[NOMBRE_EE] [nvarchar](200),
    [RECTOR] [nvarchar](40),
	[ID_FECHA] [int] , -- NOT NULL
    [FECHA] [datetime] NOT NULL, 
    [ID_PREGUNTA] [int] NOT NULL, -- 
	--[PREGUNTA] [nvarchar](255),-- PRUEBA
	[RESPUESTA] [nvarchar](255),
    [ID_RESPUESTA] [int] ,
    [OBSERVACION] [nvarchar](40),
	CONSTRAINT [PK_FACT_DIAGNOSTICOS_EE_JEC] PRIMARY KEY CLUSTERED ([ID_REGISTRO]),
	CONSTRAINT [FK_FACT_DIAGNOSTICOS_EE_JEC_DIM_PREGUNTAS_EE_JEC] FOREIGN KEY ([ID_PREGUNTA]) REFERENCES [Proteccion].[DIM_PREGUNTAS_EE_JEC]([ID_PREGUNTA]),
	CONSTRAINT [FK_FACT_DIAGNOSTICOS_EE_JEC_DIM_RESPUESTAS_EE_JEC] FOREIGN KEY ([ID_RESPUESTA]) REFERENCES [Proteccion].[DIM_RESPUESTAS_EE_JEC]([ID_RESPUESTA]),
	--CONSTRAINT [FK_FACT_DIAGNOSTICOS_EE_JEC_DIM_ESTABLECIMIENTO_EDUCATIVO] FOREIGN KEY ([ID_ESTABLECIMIENTO_EDUCATIVO]) REFERENCES [Proteccion].[DIM_ESTABLECIMIENTO_EDUCATIVO]([ID_ESTABLECIMIENTO_EDUCATIVO]),
	CONSTRAINT [FK_FACT_DIAGNOSTICOS_EE_JEC_Dim_TIEMPO] FOREIGN KEY([ID_FECHA]) REFERENCES [Dwh].[DIM_TIEMPO] ([ID_FECHA])
)
GO

-- Crear Proteccion.DIM_PREGUNTAS_EE_AIPI
CREATE TABLE [Proteccion].[DIM_PREGUNTAS_EE_AIPI] (
	[ID_PREGUNTA] [int] IDENTITY(1,1) NOT NULL,
    [PREGUNTA] [nvarchar](255),
    [ID_PROGRAMA] [int] NOT NULL,
	CONSTRAINT [PK_DIM_PREGUNTAS_EE_AIPI] PRIMARY KEY CLUSTERED ([ID_PREGUNTA]),
	CONSTRAINT [FK_DIM_PREGUNTAS_EE_AIPI_DIM_PROGRAMA] FOREIGN KEY ([ID_PROGRAMA]) REFERENCES [Proteccion].[DIM_PROGRAMA]([ID_PROGRAMA])
)
GO
-- Crear Proteccion.DIM_RESPUESTAS_EE_AIPI
CREATE TABLE [Proteccion].[DIM_RESPUESTAS_EE_AIPI] (
    [ID_RESPUESTA] [int] IDENTITY(1,1) NOT NULL,
    [RESPUESTA] [nvarchar](255),
    [ID_PREGUNTA] [int] NOT NULL,
	CONSTRAINT [PK_DIM_RESPUESTAS_EE_AIPI] PRIMARY KEY CLUSTERED ([ID_RESPUESTA]),
	CONSTRAINT [FK_DIM_RESPUESTAS_EE_AIPI_DIM_PREGUNTAS_EE_AIPI] FOREIGN KEY ([ID_PREGUNTA]) REFERENCES [Proteccion].[DIM_PREGUNTAS_EE_AIPI]([ID_PREGUNTA])
)
GO
/*
--INSERT -1 values------------------------------------------------------------------------------
--USE DWH_COMFENALCO
--GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET IDENTITY_INSERT [DWH_COMFENALCO].[Proteccion].[DIM_RESPUESTAS_EE_AIPI] ON
GO
-- Eliminar restricciones de clave for�nea
DECLARE @sql NVARCHAR(MAX) = '';
SELECT @sql += 'ALTER TABLE ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) 
    + ' DROP CONSTRAINT ' + QUOTENAME(f.name) + '; ' 
FROM sys.foreign_keys f
INNER JOIN sys.tables t ON f.parent_object_id = t.object_id
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = 'Proteccion';
EXEC sp_executesql @sql;
TRUNCATE TABLE [DWH_COMFENALCO].[Proteccion].[DIM_RESPUESTAS_EE_AIPI];
INSERT INTO [Proteccion].[DIM_RESPUESTAS_EE_AIPI] (ID_RESPUESTA,RESPUESTA,ID_PREGUNTA)
VALUES (-1,'RESPUESTA_PREGUNTA_ABIERTA',-1);

SET IDENTITY_INSERT [DWH_COMFENALCO].[Proteccion].[DIM_RESPUESTAS_EE_AIPI] OFF 
------------------------------------------------------------------------------------------------
GO*/
-- Crear Proteccion.FACT_DIAGNOSTICOS_EE_AIPI
CREATE TABLE [Proteccion].[FACT_DIAGNOSTICOS_EE_AIPI] (
    [ID_REGISTRO] [int] IDENTITY(1,1) NOT NULL,
	[ID_FECHA] [int] NOT NULL,
    [FECHA] [datetime] NOT NULL,
    [ID_ESTABLECIMIENTO_EDUCATIVO] [int]  NOT NULL,
    --[NOMBRE_EE] [nvarchar](200),
    --[NO_SEDES] [nvarchar](40),
    [NOMBRE_SEDE] [nvarchar](200),
    [MUNICIPIO] [nvarchar](255),
    [ENTIDAD_ADMINISTRADORA] [nvarchar](255),
    [DIRECCION] [nvarchar](300),
    [ID_PREGUNTA] [int] NOT NULL,--NOT NULL
	[PREGUNTA] [nvarchar](255) ,
    [ID_RESPUESTA] [int] , --NOT NULL
	[RESPUESTA] [nvarchar](255) NOT NULL,
	CONSTRAINT [PK_FACT_DIAGNOSTICOS_EE_AIPI] PRIMARY KEY CLUSTERED ([ID_REGISTRO]),
	CONSTRAINT [FK_FACT_DIAGNOSTICOS_EE_AIPI_DIM_PREGUNTAS_EE_AIPI] FOREIGN KEY ([ID_PREGUNTA]) REFERENCES [Proteccion].[DIM_PREGUNTAS_EE_AIPI]([ID_PREGUNTA]),
	CONSTRAINT [FK_FACT_DIAGNOSTICOS_EE_AIPI_DIM_RESPUESTAS_EE_AIPI] FOREIGN KEY ([ID_RESPUESTA]) REFERENCES [Proteccion].[DIM_RESPUESTAS_EE_AIPI]([ID_RESPUESTA]),
	CONSTRAINT [FK_FACT_DIAGNOSTICOS_EE_AIPI_DIM_ESTABLECIMIENTO_EDUCATIVO] FOREIGN KEY ([ID_ESTABLECIMIENTO_EDUCATIVO]) REFERENCES [Proteccion].[DIM_ESTABLECIMIENTO_EDUCATIVO]([ID_ESTABLECIMIENTO_EDUCATIVO]),
	CONSTRAINT [FK_FACT_DIAGNOSTICOS_EE_AIPI_Dim_TIEMPO] FOREIGN KEY([ID_FECHA]) REFERENCES [Dwh].[DIM_TIEMPO] ([ID_FECHA])
)
GO


-- Crear Proteccion.FACT_ENTREGA_MATERIAL
CREATE TABLE [Proteccion].[FACT_ENTREGA_MATERIAL] (
    [ID_ENTREGA] [int] IDENTITY(1,1) NOT NULL,
	[ID_FECHA] [int] NOT NULL,
    [FECHA_ENTREGA] [datetime] NOT NULL,
    [ID_PROGRAMA] [int] NOT NULL,
    --[PROGRAMA] [nvarchar](40),
    [ID_PERSONAL] [int] NOT NULL,
    [ID_MATERIAL] [int] NOT NULL,
    [NOMBRE_MATERIAL] [nvarchar](200),
    [TIPO_MATERIAL] [nvarchar](255),
    [CANTIDAD_MATERIAL] [int],
    [VALOR_MATERIAL] [decimal](28, 2),
    [ID_POBLACION] [int] NOT NULL,
    --[TIPO_DOCUMENTO] [nvarchar](40) NOT NULL,
    --[DOCUMENTO] [nvarchar](20) NOT NULL,
	CONSTRAINT [PK_FACT_ENTREGA_MATERIAL] PRIMARY KEY CLUSTERED ([ID_ENTREGA]),
	CONSTRAINT [FK_FACT_ENTREGA_MATERIAL_DIM_POBLACION] FOREIGN KEY ([ID_POBLACION]) REFERENCES [Proteccion].[DIM_POBLACION]([ID_POBLACION]),
	CONSTRAINT [FK_FACT_ENTREGA_MATERIAL_DIM_PERSONAL] FOREIGN KEY ([ID_PERSONAL]) REFERENCES [Transversal].[DIM_PERSONAL]([ID_PERSONAL]),
	CONSTRAINT [FK_FACT_ENTREGA_MATERIAL_DIM_PROGRAMA] FOREIGN KEY ([ID_PROGRAMA]) REFERENCES [Proteccion].[DIM_PROGRAMA]([ID_PROGRAMA]),
	CONSTRAINT [FK_FACT_ENTREGA_MATERIAL_Dim_TIEMPO] FOREIGN KEY([ID_FECHA]) REFERENCES [Dwh].[DIM_TIEMPO] ([ID_FECHA])
)
GO

-- Crear Proteccion.FACT_VISITAS
CREATE TABLE [Proteccion].[FACT_VISITAS] (
	[ID_VISITA] [int] IDENTITY(1,1) NOT NULL,
    [MUNICIPIO] [nvarchar](40),
    [ID_FECHA] [int] NOT NULL,
    [FECHA_PLANEADA] [datetime] NOT NULL,
	[ID_PROGRAMA] [int] NOT NULL,
    [ID_PERSONAL] [int] NULL DEFAULT -1, -- Asignar valor por defecto de -1
    [PERSONAL] [nvarchar](255),
    [ACTIVIDAD] [nvarchar](255),
    [LUGAR] [nvarchar](255),
    [FECHA_EJECUTADA] [datetime] NOT NULL,
	CONSTRAINT [PK_FACT_VISITAS] PRIMARY KEY CLUSTERED ([ID_VISITA]),
	CONSTRAINT [FK_FACT_VISITAS_DIM_PERSONAL] FOREIGN KEY ([ID_PERSONAL]) REFERENCES [Transversal].[DIM_PERSONAL]([ID_PERSONAL]),
	CONSTRAINT [FK_FACT_VISITAS_DIM_PROGRAMA] FOREIGN KEY ([ID_PROGRAMA]) REFERENCES [Proteccion].[DIM_PROGRAMA]([ID_PROGRAMA]),
	CONSTRAINT [FK_FACT_VISITAS_Dim_TIEMPO] FOREIGN KEY([ID_FECHA]) REFERENCES [Dwh].[DIM_TIEMPO] ([ID_FECHA])
)
GO

-- Crear Proteccion.FACT_DESERCION
CREATE TABLE [Proteccion].[FACT_DESERCION] (
    [ID_REGISTRO] [int] IDENTITY(1,1) NOT NULL,
    [ID_ESTABLECIMIENTO_EDUCATIVO] [int]  NOT NULL,
    --[NOMBRE_EE] [nvarchar](200),
    [ID_POBLACION] [int] NOT NULL,
    --[TIPO_DOCUMENTO] [nvarchar](40) NOT NULL,
    --[DOCUMENTO] [nvarchar](20) NOT NULL,
    [ANIO_ACADEMICO] [nvarchar](40),
	[ID_FECHA] [int] NOT NULL,
    [FECHA_REGISTRO] [datetime] NOT NULL,
    [ID_PROGRAMA] [int] NOT NULL,
    [CAUSA] [nvarchar](40),
	CONSTRAINT [PK_FACT_DESERCION] PRIMARY KEY CLUSTERED ([ID_REGISTRO]),
	CONSTRAINT [FK_FACT_DESERCION_DIM_POBLACION] FOREIGN KEY ([ID_POBLACION]) REFERENCES [Proteccion].[DIM_POBLACION]([ID_POBLACION]),
	CONSTRAINT [FK_FACT_DESERCION_DIM_ESTABLECIMIENTO_EDUCATIVO] FOREIGN KEY ([ID_ESTABLECIMIENTO_EDUCATIVO]) REFERENCES [Proteccion].[DIM_ESTABLECIMIENTO_EDUCATIVO]([ID_ESTABLECIMIENTO_EDUCATIVO]),
	CONSTRAINT [FK_FACT_DESERCION_DIM_PROGRAMA] FOREIGN KEY ([ID_PROGRAMA]) REFERENCES [Proteccion].[DIM_PROGRAMA]([ID_PROGRAMA]),
	CONSTRAINT [FK_FACT_DESERCION_Dim_TIEMPO] FOREIGN KEY([ID_FECHA]) REFERENCES [Dwh].[DIM_TIEMPO] ([ID_FECHA])
)
GO
-- Crear Proteccion.FACT_PLAN_COBERTURA_ADULTO_DISCAPACIDAD
CREATE TABLE [Proteccion].[FACT_PLAN_COBERTURA_ADULTO_DISCAPACIDAD](
	[ID_REGISTRO] [int] IDENTITY(1,1) NOT NULL,
	[ANIO] [int] NULL,
	[COD_INFRAESTRUCTURA_CCF] [nvarchar](255) NULL,
	[SERVICIO] [float] NULL,
	[CATEGORIA_CCF] [float] NULL,
	[NUM_PERSONAS_COBERTURA_SERVICIOS] [float] NULL,
	[MES_PROYECTADO] [int] NULL,
	[ID_UNIDAD] [int] NULL,
	[ID_PROGRAMA] [int] NULL,
	[ID_FECHA] [int] NULL
) ON [PRIMARY]
GO