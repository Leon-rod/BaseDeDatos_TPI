-- TABLAS SATELITE

CREATE TABLE PAISES (
    ID_PAIS INT NOT NULL,
    PAIS VARCHAR(100) NOT NULL,	
    CONSTRAINT PK_PAISES PRIMARY KEY (ID_PAIS)
);

CREATE TABLE PROVINCIAS (
    ID_PROVINCIA INT NOT NULL,
    PROVINCIA VARCHAR(100) NOT NULL,
	ID_PAIS INT NOT NULL,
    CONSTRAINT PK_PROVINCIAS PRIMARY KEY (ID_PROVINCIA),
	CONSTRAINT FK_PROVINCIAS_PAISES FOREIGN KEY (ID_PAIS) 
        REFERENCES PAISES (ID_PAIS)
);

CREATE TABLE CIUDADES (
    ID_CIUDAD INT NOT NULL,
    CIUDAD VARCHAR(100) NOT NULL,
    ID_PROVINCIA INT NOT NULL,
    CONSTRAINT PK_CIUDADES PRIMARY KEY (ID_CIUDAD),
    CONSTRAINT FK_CIUDADES_PROVINCIAS FOREIGN KEY (ID_PROVINCIA) 
        REFERENCES PROVINCIAS(ID_PROVINCIA)
);

CREATE TABLE BARRIOS (
    ID_BARRIO INT NOT NULL,
    BARRIO VARCHAR(100) NOT NULL,
    ID_CIUDAD INT NOT NULL,
    CONSTRAINT PK_BARRIOS PRIMARY KEY (ID_BARRIO),
    CONSTRAINT FK_BARRIOS_CIUDADES FOREIGN KEY (ID_CIUDAD) 
        REFERENCES CIUDADES(ID_CIUDAD)
);

CREATE TABLE ESTABLECIMIENTOS (
    ID_ESTABLECIMIENTO INT NOT NULL,
    NOMBRE VARCHAR(100) NOT NULL,
    CALLE VARCHAR(100) NOT NULL,
    NUMERO VARCHAR(10),
    ID_BARRIO INT NOT NULL,
    CONSTRAINT PK_ESTABLECIMIENTO PRIMARY KEY (ID_ESTABLECIMIENTO),
    CONSTRAINT FK_ESTABLECIMIENTO_BARRIOS FOREIGN KEY (ID_BARRIO) 
        REFERENCES BARRIOS(ID_BARRIO)
);

CREATE TABLE TIPOS_PRODUCTOS (
    ID_TIPO_PRODUCTO INT NOT NULL,
    TIPO_PRODUCTO VARCHAR(100) NOT NULL,
    CONSTRAINT PK_TIPOS_PRODUCTOS PRIMARY KEY (ID_TIPO_PRODUCTO)
);

CREATE TABLE TIPOS_PEDIDOS (
    ID_TIPO_PEDIDO INT NOT NULL,
    TIPO_PEDIDO VARCHAR(100) NOT NULL,
    CONSTRAINT PK_TIPOS_PEDIDOS PRIMARY KEY (ID_TIPO_PEDIDO)
);

CREATE TABLE TIPOS_PROGRAMAS (
    ID_TIPO_PROGRAMA INT NOT NULL,
    TIPO_PROGRAMA VARCHAR(100) NOT NULL,
    CONSTRAINT PK_TIPOS_PROGRAMAS PRIMARY KEY (ID_TIPO_PROGRAMA)
);

CREATE TABLE PRESENTACIONES (
    ID_PRESENTACION INT NOT NULL,
    PRESENTACION VARCHAR(100) NOT NULL,
    CONSTRAINT PK_PRESENTACIONES PRIMARY KEY (ID_PRESENTACION)
);

CREATE TABLE CARGOS (
    ID_CARGO INT NOT NULL,
    CARGO VARCHAR(100) NOT NULL,
    CONSTRAINT PK_CARGOS PRIMARY KEY (ID_CARGO)
);

CREATE TABLE TIPOS_MOVIMIENTOS (
    ID_TIPO_MOV INT NOT NULL,
    MOVIMIENTO VARCHAR(100) NOT NULL,
    CONSTRAINT PK_TIPOS_MOVIMIENTOS PRIMARY KEY (ID_TIPO_MOV)
);

CREATE TABLE TIPOS_CONTACTOS (
    ID_TIPO_CONTACTO INT NOT NULL,
    TIPO_CONTACTO VARCHAR(100) NOT NULL,
    CONSTRAINT PK_TIPOS_CONTACTOS PRIMARY KEY (ID_TIPO_CONTACTO)
);

CREATE TABLE TIPOS_DOC (
    ID_TIPO_DOC INT NOT NULL,
    TIPO_DOC VARCHAR(100) NOT NULL,
    CONSTRAINT PK_TIPOS_DOC PRIMARY KEY (ID_TIPO_DOC)
);

CREATE TABLE LABORATORIOS (
    ID_LABORATORIO INT NOT NULL,
    NOMBRE_LABORATORIO VARCHAR(100) NOT NULL,
    CONSTRAINT PK_LABORATORIOS PRIMARY KEY (ID_LABORATORIO)
);

CREATE TABLE MARCAS (
    ID_MARCAS INT NOT NULL,
    NOMBRE_MARCA VARCHAR(100) NOT NULL,
    CONSTRAINT PK_MARCAS PRIMARY KEY (ID_MARCAS)
);

CREATE TABLE MONODROGAS (
    ID_MONODROGA INT NOT NULL,
    MONODROGA VARCHAR(100) NOT NULL,
    CONSTRAINT PK_MONODROGAS PRIMARY KEY (ID_MONODROGA)
);

CREATE TABLE ESPECIALIDADES (
    ID_TIPO_ESPECIALIDAD INT NOT NULL,
    ESPECIALIDAD VARCHAR(100) NOT NULL,
    CONSTRAINT PK_ESPECIALIDADES PRIMARY KEY (ID_TIPO_ESPECIALIDAD)
);

CREATE TABLE TIPOS_PAGOS (
    ID_TIPO_PAGO INT NOT NULL,
    TIPO_PAGO VARCHAR(100) NOT NULL,
    CONSTRAINT PK_TIPOS_PAGOS PRIMARY KEY (ID_TIPO_PAGO)
);

-- PRODUCTOS

CREATE TABLE PRODUCTOS (
    ID_PRODUCTO INT NOT NULL,
    NOMBRE VARCHAR(100) NOT NULL,
    TIPO_PRODUCTO INT NOT NULL,
    ID_PRESENTACION INT NOT NULL,
    DESCRIPCION VARCHAR(255),
    PRECIO DECIMAL(10, 2) NOT NULL,
    CONSTRAINT PK_PRODUCTOS PRIMARY KEY (ID_PRODUCTO),
    CONSTRAINT FK_PRODUCTOS_TIPOS_PRODUCTOS FOREIGN KEY (TIPO_PRODUCTO) 
        REFERENCES TIPOS_PRODUCTOS(ID_TIPO_PRODUCTO),
    CONSTRAINT FK_PRODUCTOS_PRESENTACIONES FOREIGN KEY (ID_PRESENTACION) 
        REFERENCES PRESENTACIONES(ID_PRESENTACION)
);

CREATE TABLE MEDICAMENTOS (
    ID_MEDICAMENTO INT NOT NULL,
    ID_MONODROGA INT NOT NULL,
    NOMBRE_COMERCIAL VARCHAR(100) NOT NULL,
    ID_LABORATORIO INT NOT NULL,
    ID_MARCA INT NOT NULL,
    VENTA_LIBRE BIT NOT NULL,
    ID_PRESENTACION INT NOT NULL,
    DESCRIPCION VARCHAR(255),
    PRECIO DECIMAL(10, 2) NOT NULL,
    CONSTRAINT PK_MEDICAMENTOS PRIMARY KEY (ID_MEDICAMENTO),
    CONSTRAINT FK_MEDICAMENTOS_MONODROGAS FOREIGN KEY (ID_MONODROGA) 
        REFERENCES MONODROGAS(ID_MONODROGA),
    CONSTRAINT FK_MEDICAMENTOS_LABORATORIOS FOREIGN KEY (ID_LABORATORIO) 
        REFERENCES LABORATORIOS(ID_LABORATORIO),
    CONSTRAINT FK_MEDICAMENTOS_MARCAS FOREIGN KEY (ID_MARCA) 
        REFERENCES MARCAS(ID_MARCAS),
    CONSTRAINT FK_MEDICAMENTOS_PRESENTACIONES FOREIGN KEY (ID_PRESENTACION) 
        REFERENCES PRESENTACIONES(ID_PRESENTACION)
);

CREATE TABLE MEDICAMENTOS_LOTES (
    ID_MEDICAMENTO_LOTE INT NOT NULL,
    ID_MEDICAMENTO INT NOT NULL,
    LOTE VARCHAR(50) NOT NULL,
    FECHA_VENCIMIENTO DATE NOT NULL,
    CONSTRAINT PK_MEDICAMENTOS_LOTES PRIMARY KEY (ID_MEDICAMENTO_LOTE),
    CONSTRAINT FK_MEDICAMENTOS_LOTES_MEDICAMENTOS FOREIGN KEY (ID_MEDICAMENTO) 
        REFERENCES MEDICAMENTOS(ID_MEDICAMENTO)
);

CREATE TABLE OBRA_SOCIAL (
    ID_OBRA_SOCIAL INT NOT NULL,
    NOMBRE VARCHAR(100) NOT NULL,
    DIRECCION VARCHAR(255),
    CONSTRAINT PK_OBRA_SOCIAL PRIMARY KEY (ID_OBRA_SOCIAL)
);

CREATE TABLE TIPOS_COBERTURAS (
    ID_TIPO_COBERTURA INT NOT NULL,
    ID_OBRA_SOCIAL INT NOT NULL,
    DESCRIPCION VARCHAR(255) NOT NULL,
    CONSTRAINT PK_TIPOS_COBERTURAS PRIMARY KEY (ID_TIPO_COBERTURA),
    CONSTRAINT FK_TIPOS_COBERTURAS_OBRA_SOCIAL FOREIGN KEY (ID_OBRA_SOCIAL) 
        REFERENCES OBRA_SOCIAL(ID_OBRA_SOCIAL)
);

CREATE TABLE MEDICAMENTOS_OBRA_SOCIAL (
    ID_MEDICAMENTO_OBRA_SOCIAL INT NOT NULL,
    ID_MEDICAMENTO INT NOT NULL,
    ID_TIPO_COBERTURA INT NOT NULL,
    DESCUENTO DECIMAL(5, 2) NOT NULL,
    FECHA_COBERTURA DATE NOT NULL,
    ID_CIUDAD INT NOT NULL,
    CONSTRAINT PK_MEDICAMENTOS_OBRA_SOCIAL PRIMARY KEY (ID_MEDICAMENTO_OBRA_SOCIAL),
    CONSTRAINT FK_MEDICAMENTOS_OBRA_SOCIAL_MEDICAMENTOS FOREIGN KEY (ID_MEDICAMENTO) 
        REFERENCES MEDICAMENTOS(ID_MEDICAMENTO),
    CONSTRAINT FK_MEDICAMENTOS_OBRA_SOCIAL_TIPOS_COBERTURAS FOREIGN KEY (ID_TIPO_COBERTURA) 
        REFERENCES TIPOS_COBERTURAS(ID_TIPO_COBERTURA),
    CONSTRAINT FK_MEDICAMENTOS_OBRA_SOCIAL_CIUDADES FOREIGN KEY (ID_CIUDAD) 
        REFERENCES CIUDADES(ID_CIUDAD)
);

-- ENTIDADES/PERSONAS

CREATE TABLE CLIENTES (
    ID_CLIENTE INT NOT NULL,
    NOMBRE VARCHAR(50) NOT NULL,
    APELLIDO VARCHAR(50) NOT NULL,
    FECHA_NACIMIENTO DATE NOT NULL,
    CALLE VARCHAR(100) NOT NULL,
    NUMERO VARCHAR(10),
    ID_BARRIO INT NOT NULL,
    TIPO_DOC INT NOT NULL,
    NRO_DOC VARCHAR(20) NOT NULL,
    CONSTRAINT PK_CLIENTES PRIMARY KEY (ID_CLIENTE),
    CONSTRAINT FK_CLIENTES_BARRIOS FOREIGN KEY (ID_BARRIO) 
        REFERENCES BARRIOS(ID_BARRIO),
    CONSTRAINT FK_CLIENTES_TIPO_DOC FOREIGN KEY (TIPO_DOC) 
        REFERENCES TIPOS_DOC(ID_TIPO_DOC)
);

CREATE TABLE PROVEEDORES (
    ID_PROVEEDOR INT NOT NULL,
    RAZON_SOCIAL VARCHAR(100) NOT NULL,
    CUIT VARCHAR(20) NOT NULL,
    CALLE VARCHAR(100) NOT NULL,
    NUMERO VARCHAR(10),
    ID_BARRIO INT NOT NULL,
    ACTIVO BIT NOT NULL,
    CONSTRAINT PK_PROVEEDORES PRIMARY KEY (ID_PROVEEDOR),
    CONSTRAINT FK_PROVEEDORES_BARRIOS FOREIGN KEY (ID_BARRIO) 
        REFERENCES BARRIOS(ID_BARRIO)
);

CREATE TABLE EMPRESA_LOGISTICA (
    CUIT VARCHAR(20) NOT NULL,
    NOMBRE_EMPRESA VARCHAR(100) NOT NULL,
    CALLE VARCHAR(100) NOT NULL,
    NUMERO VARCHAR(10),
    ID_BARRIO INT NOT NULL,
    CONSTRAINT PK_EMPRESA_LOGISTICA PRIMARY KEY (CUIT),
    CONSTRAINT FK_EMPRESA_LOGISTICA_BARRIOS FOREIGN KEY (ID_BARRIO) 
        REFERENCES BARRIOS(ID_BARRIO)
);

CREATE TABLE COBERTURAS_CLIENTES (
    ID_BENEFICIARIO INT NOT NULL,
    ID_TIPO_COBERTURA INT NOT NULL,
    ID_CLIENTE INT NOT NULL,
    CONSTRAINT PK_COBERTURAS_CLIENTES PRIMARY KEY (ID_BENEFICIARIO),
    CONSTRAINT FK_COBERTURAS_CLIENTES_TIPOS_COBERTURAS FOREIGN KEY (ID_TIPO_COBERTURA) 
        REFERENCES TIPOS_COBERTURAS(ID_TIPO_COBERTURA),
    CONSTRAINT FK_COBERTURAS_CLIENTES_CLIENTES FOREIGN KEY (ID_CLIENTE) 
        REFERENCES CLIENTES(ID_CLIENTE)
);

CREATE TABLE PERSONAL (
    ID_PERSONAL INT NOT NULL,
    NOMBRE VARCHAR(50) NOT NULL,
    APELLIDO VARCHAR(50) NOT NULL,
    FECHA_NAC DATE NOT NULL,
    DIRECCION VARCHAR(150) NOT NULL,
    TIPO_DOC INT NOT NULL,
    NRO_DOC VARCHAR(20) NOT NULL,
    CONSTRAINT PK_PERSONAL PRIMARY KEY (ID_PERSONAL),
    CONSTRAINT FK_PERSONAL_TIPO_DOC FOREIGN KEY (TIPO_DOC)
        REFERENCES TIPOS_DOC(ID_TIPO_DOC)
);

CREATE TABLE MEDICOS (
    MATRICULA VARCHAR(20) NOT NULL,
    NOMBRE VARCHAR(50) NOT NULL,
    APELLIDO VARCHAR(50) NOT NULL,
    ID_TIPO_ESPECIALIDAD INT NOT NULL,
    CONSTRAINT PK_MEDICOS PRIMARY KEY (MATRICULA),
    CONSTRAINT FK_MEDICOS_ESPECIALIDADES FOREIGN KEY (ID_TIPO_ESPECIALIDAD) 
        REFERENCES ESPECIALIDADES(ID_TIPO_ESPECIALIDAD)
);

CREATE TABLE PERSONAL_CARGOS_ESTABLECIMIENTOS (
    ID_PERSONAL_CARGOS_ESTABLECIMIENTOS INT NOT NULL,
    ID_PERSONAL INT NOT NULL,
    ID_CARGO INT NOT NULL,
    CONSTRAINT PK_PERSONAL_CARGOS_ESTABLECIMIENTOS PRIMARY KEY (ID_PERSONAL_CARGOS_ESTABLECIMIENTOS),
    CONSTRAINT FK_PERSONAL_CARGOS_ESTABLECIMIENTOS_PERSONAL FOREIGN KEY (ID_PERSONAL) 
        REFERENCES PERSONAL(ID_PERSONAL),
    CONSTRAINT FK_PERSONAL_CARGOS_ESTABLECIMIENTOS_CARGOS FOREIGN KEY (ID_CARGO) 
        REFERENCES CARGOS(ID_CARGO)
);