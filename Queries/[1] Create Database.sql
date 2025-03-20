/*
	Este ficheiro é responsável pela criação da nova base de dados tendo em conta o modelo ER proposto.
	É o primeiro ficheiro a ser executado.
*/

DROP DATABASE IF EXISTS AdventureWorks;
GO

CREATE DATABASE AdventureWorks;
GO

USE AdventureWorks;
GO

/*
	Contém informações padrão como ocupações, perguntas de segurança, níveis de educação e territórios de venda.
*/
CREATE SCHEMA Defaults;
GO

/*
	Contém informações sobre a gestão da BD como mudanças no estado de acesso de clientes.
*/
CREATE SCHEMA Logs;
GO

/*
	Armazena informações relacionadas com encomendas de clientes e produtos encomendados.
*/
CREATE SCHEMA Orders;
GO

/*
	Informações sobre clientes, endereços de entrega e emails de recuperação.
*/
CREATE SCHEMA Users;
GO

/*
	Detalhes sobre informações específicas da linha do produto, categorias, pesos, tamanhos.
*/
CREATE SCHEMA Products;
GO

/*
    Uma schema que servirá para conter Views que se relacionem com a "business logistics", por exemplo, lucro.
*/
CREATE SCHEMA Business;
GO

/*
    Monitoring details.
*/
CREATE SCHEMA Monitoring;
GO

/*
	Armazena informações sobre ocupações (profissões e etc.).
*/
CREATE TABLE Defaults.Occupation (
    OccupationKey INT IDENTITY(1,1) PRIMARY KEY,
	
    Occupation NVARCHAR(128) NOT NULL
);

/*
	Contém informações sobre perguntas (de recuperação da palavra-passe).
*/
CREATE TABLE Defaults.Question (
    QuestionKey INT IDENTITY(1,1) PRIMARY KEY,

    Question NVARCHAR(256) NOT NULL
);

/*
	Inserção das questões pre-definidas.
*/
INSERT INTO Defaults.Question
    (Question)
    VALUES
    ('Animal favorito?'),
    ('Nome da mãe?'),
    ('Nome do pai?'),
    ('Nome do primeiro animal de estimação?');

/*
	Armazena informações sobre o nível de educação do cliente.
*/
CREATE TABLE Defaults.Education (
    EducationKey INT IDENTITY(1,1) PRIMARY KEY,

    Education NVARCHAR(128) NOT NULL
);

/*
	 Contém informações sobre territórios de vendas (zona de atuação da AdventureWorks).
*/
CREATE TABLE Defaults.SaleTerritory (
    SaleTerritoryKey INT IDENTITY(1,1) PRIMARY KEY,

    SalesTerritoryRegion   NVARCHAR(128) NOT NULL,
    SalesTerritoryCountry  NVARCHAR(128) NOT NULL,
    SalesTerritoryGroup    NVARCHAR(128) NOT NULL
);

/*
	Armazena informações de endereços de entrega dos clientes.
*/
CREATE TABLE Defaults.Commute (
    CommuteRangeKey INT IDENTITY(1,1) PRIMARY KEY,

	CommuteRange NVARCHAR(64)  NOT NULL,
);

/*
	Armazena informações de endereços de entrega dos clientes.
*/
CREATE TABLE Users.DeliveryAddress (
    DeliveryAddressKey INT PRIMARY KEY,

    AddressLine1      NVARCHAR(128),
    AddressLine2      NVARCHAR(128),
    City              NVARCHAR(64),
    PostalCode		  NVARCHAR(64),
	StateProvinceCode NVARCHAR(8),
    StateProvinceName NVARCHAR(64),
	CountryRegionCode NVARCHAR(8),
    CountryRegionName NVARCHAR(64),

	CommuteRangeKey INT NOT NULL,
    FOREIGN KEY (CommuteRangeKey)  REFERENCES Defaults.Commute (CommuteRangeKey),

    SaleTerritoryKey INT NOT NULL,
    FOREIGN KEY (SaleTerritoryKey) REFERENCES Defaults.SaleTerritory (SaleTerritoryKey)
);

/*
	Contém informações sobre níveis de acesso dos clientes.
*/
CREATE TABLE Defaults.AccessLevel (
	AccessLevelKey INT IDENTITY(1,1) PRIMARY KEY,

	AccessLevel NVARCHAR(6) NOT NULL,
)

/*
	Inserem-se os níveis de acesso pre-definidos.
*/
INSERT INTO Defaults.AccessLevel 
    (AccessLevel) 
    VALUES 
    ('User'), 
    ('Admin');

/*
	Contém informações sobre os administradores (gerem os acessos dos clientes).
*/
CREATE TABLE Logs.Administrator (
	AdministratorKey INT IDENTITY(1,1) PRIMARY KEY,

	AdminName   NVARCHAR(128),
	CreatedAt   DATETIME NOT NULL,	

	AccessLevelKey INT,
	FOREIGN KEY (AccessLevelKey) REFERENCES Defaults.AccessLevel (AccessLevelKey),
)

/*
	Contém informações sobre os erros da base de dados.
*/
CREATE TABLE Logs.ErrorHandling (
	ErrorHandlingKey INT IDENTITY(1,1) PRIMARY KEY,

	HostName	NVARCHAR(200),
	ErrorMsg    NVARCHAR(4000),
	ErrorCode	INT,
	CreatedAt   DATETIME NOT NULL,	
)

/*
	Contém informações sobre os clientes (para depois as vender).
*/
CREATE TABLE Users.Customer (
    CustomerKey INT PRIMARY KEY,

	Title                NVARCHAR(128),
    FirstName            NVARCHAR(64)  NOT NULL,
    MiddleName           NVARCHAR(64),
    LastName             NVARCHAR(64)  NOT NULL,
	BirthDate            DATETIME,
	MaritalStatus        NVARCHAR(128),
    Gender               NVARCHAR(8),
	EmailAddress         NVARCHAR(128) NOT NULL,
	YearlyIncome         INT,
	TotalChildren        INT,
	NumberChildrenAtHome INT,
	HomeOwnerFlag        INT,
    NumberCarsOwned      INT,
    Phone                NVARCHAR(64)  NOT NULL,
	FirstPurchase        DATE,         

    OccupationKey INT,
	FOREIGN KEY (OccupationKey)      REFERENCES Defaults.Occupation (OccupationKey),

    EducationKey INT,
	FOREIGN KEY (EducationKey)       REFERENCES Defaults.Education (EducationKey),

    DeliveryAddressKey INT NOT NULL,
    FOREIGN KEY (DeliveryAddressKey) REFERENCES Users.DeliveryAddress (DeliveryAddressKey),
);

/*
	Informações sobre edições dos administradores (quando mudam o acesso de um cliente).
*/
CREATE TABLE Logs.AdministratorEdit (
	AdministratorEditKey INT IDENTITY(1,1) PRIMARY KEY,

	OldAccessState INT           NOT NULL,
	NewAccessState INT           NOT NULL,
	Reason         NVARCHAR(128) NOT NULL,
	TimestampEdit  DATETIME      NOT NULL,

	AdministratorKey INT NOT NULL,
    FOREIGN KEY (AdministratorKey) REFERENCES Logs.Administrator (AdministratorKey),

	CustomerKey INT NOT NULL,
    FOREIGN KEY (CustomerKey)      REFERENCES Users.Customer (CustomerKey)	
)

/*
	Armazena informações sobre tipos de moeda.
*/
CREATE TABLE Defaults.Currency (
    CurrencyKey INT IDENTITY(1,1) PRIMARY KEY,

    CurrencyName NVARCHAR(50) NOT NULL,
    CurrencyCode NVARCHAR(3)  NOT NULL
);

/*
	Armazena todas as informações relacionadas com uma encomenda.
*/
CREATE TABLE Orders.Sale (
    SaleKey INT IDENTITY(1,1) PRIMARY KEY,

	OrderNumber           NVARCHAR(64) NOT NULL,
    RevisionNumber        INT          NOT NULL,
    CustomerPONumber      NVARCHAR(64), 
    LineNumber            INT,          
    CarrierTrackingNumber NVARCHAR(64), 
    OrderDate             DATETIME     NOT NULL,
    DueDate               DATETIME     NOT NULL,
    ShipDate              DATETIME     NOT NULL,
  
    CustomerKey INT NOT NULL,  
    FOREIGN KEY (CustomerKey)      REFERENCES Users.Customer (CustomerKey),

	SaleTerritoryKey INT NOT NULL,
    FOREIGN KEY (SaleTerritoryKey) REFERENCES Defaults.SaleTerritory (SaleTerritoryKey)
);

/*
	Contém informações sobre modelos de produtos.
*/
CREATE TABLE Products.ProductModel (
    ModelKey INT IDENTITY(1,1) PRIMARY KEY,

    ModelName   NVARCHAR(64),
    Color       NVARCHAR(64),
    Style       NVARCHAR(64),
    ProductLine NVARCHAR(64),
    Class       NVARCHAR(64),
);
INSERT INTO Products.ProductModel (ModelName, Color, Style, ProductLine, Class)
VALUES ('NA', 'Não especificado', 'Não especificado', 'Não especificado', 'Não especificado');


/*
	Armazena informações sobre categorias de produtos.
*/
CREATE TABLE Products.ProductCategory (
    CategoryKey INT IDENTITY(1,1) PRIMARY KEY,

    ParentCategory INT,
    EnglishName    NVARCHAR(64),
    FrenchName     NVARCHAR(64),
    SpanishName    NVARCHAR(64) 
);
INSERT INTO Products.ProductCategory (ParentCategory, EnglishName, FrenchName, SpanishName)
VALUES (NULL, 'NA', 'Não especificado', 'Não especificado');

/*
	 Armazena informações sobre os tamanhos dos produtos.
*/
CREATE TABLE Products.ProductSize (
    SizeKey INT IDENTITY(1,1) PRIMARY KEY,

    SizeCode    NVARCHAR(64),
	ActualSize  NVARCHAR(64),
    SizeRange   NVARCHAR(64)
);
INSERT INTO Products.ProductSize (SizeCode, ActualSize, SizeRange)
VALUES ('NA', 'Não especificado', 'Não especificado');


/*
	 Contém informações detalhadas sobre os produtos.
*/
CREATE TABLE Products.Product (
    ProductKey INT PRIMARY KEY,

	CurrStatus         NVARCHAR(64),
    EnglishName        NVARCHAR(64),
    EnglishDescription NVARCHAR(2000),
    FrenchName         NVARCHAR(64),
    FrenchDescription  NVARCHAR(2000),
    SpanishName        NVARCHAR(64),
    SpanishDescription NVARCHAR(2000),
    ListPrice          MONEY,
    Cost               MONEY,
    FinishedFlag       BIT NOT NULL,
    SafetyStockLevel   INT NOT NULL,
    ManufacturingTime  INT NOT NULL,
	WeightCode         NVARCHAR(64),
	ActualWeight       INT,
    DealerPrice        MONEY,

	ModelKey INT NOT NULL,
    FOREIGN KEY (ModelKey)    REFERENCES Products.ProductModel (ModelKey),

	CategoryKey INT NOT NULL,
    FOREIGN KEY (CategoryKey) REFERENCES Products.ProductCategory (CategoryKey),

	SizeKey INT NOT NULL,
    FOREIGN KEY (SizeKey)     REFERENCES Products.ProductSize (SizeKey),
);

/*
	Armazena informações sobre produtos encomendados (ligam-se a uma encomenda).
*/
CREATE TABLE Orders.OrderedProducts (
    OrderedProductsKey INT IDENTITY(1,1) PRIMARY KEY,

	OrderNumber         NVARCHAR(64) NOT NULL,
    ProductStandardCost FLOAT,		
    OrderQuantity       TINYINT,			
	SalesAmount         FLOAT,      
    ExtendedAmount      FLOAT,		 
    UnitPrice           FLOAT,		
    UnitPriceDiscount   TINYINT,		 
	Freight				FLOAT,        
	Tax                 FLOAT,     

    SaleKey INT NOT NULL,	
	FOREIGN KEY (SaleKey)     REFERENCES Orders.Sale (SaleKey),

    ProductKey INT NOT NULL,
	FOREIGN KEY (ProductKey)  REFERENCES Products.Product (ProductKey),

    CurrencyKey INT NOT NULL,
	FOREIGN KEY (CurrencyKey) REFERENCES Defaults.Currency (CurrencyKey),
);

/*
	Armazena informações das contas dos clientes.
*/
CREATE TABLE Users.CustomerAccount (
	CustomerAccountKey INT IDENTITY(1,1) PRIMARY KEY,
    
    HashedPassword NVARCHAR(256) NOT NULL,
    AuthAnswer     NVARCHAR(128) NOT NULL,

    QuestionKey INT NOT NULL,
    FOREIGN KEY (QuestionKey)    REFERENCES Defaults.Question (QuestionKey),

	AccessLevelKey INT NOT NULL,
	FOREIGN KEY (AccessLevelKey) REFERENCES Defaults.AccessLevel (AccessLevelKey),

	CustomerKey INT NOT NULL,
	FOREIGN KEY (CustomerKey)    REFERENCES Users.Customer (CustomerKey),
)

/*
	Armazena informações sobre emails de recuperação de palavra-passe enviados.
*/
CREATE TABLE Logs.RecoveryEmail (
    RecoveryEmailKey INT IDENTITY(1,1) PRIMARY KEY,

    Content       NVARCHAR(256)  NOT NULL,
    TimestampSent DATETIME      NOT NULL,
			
    CustomerAccountKey INT NOT NULL,
    FOREIGN KEY (CustomerAccountKey) REFERENCES Users.CustomerAccount (CustomerAccountKey)
);

/*
    Table for all fields of all tables, with their data types, respective size and associated constraints.
*/
CREATE TABLE Monitoring.SchemaChanges (
    ChangeID			INT IDENTITY(1,1) PRIMARY KEY,
    ExecutionTime		DATETIME DEFAULT GETDATE(),
    ChangeDescription	NVARCHAR(MAX)
);

/*
    Dedicated table, for each database table its number of records and the most reliable estimate of the space occupied. 
*/
CREATE TABLE Monitoring.RecordSizeHistory (
    RecordSizeHistoryID INT PRIMARY KEY IDENTITY(1,1),
    TableName			NVARCHAR(255),
    RecordCount			BIGINT,
    EstimatedSize		INT,
    ExecutionTime		DATETIME DEFAULT GETDATE()
);
