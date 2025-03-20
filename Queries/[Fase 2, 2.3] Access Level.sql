-- Cria��o  a role de Administrador
CREATE ROLE AdminRole;

-- Cria��o  a role de SalesPerson
CREATE ROLE SalesPersonRole;

-- Cria��o  a role de SalesTerritory
CREATE ROLE SalesTerritoryRole;


-- Adicionar permiss�es ao admin
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Defaults TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Logs TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Orders TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Users TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Products TO AdminRole;

-- Adicionar permiss�es ao SalesPerson
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Orders TO SalesPersonRole;
GRANT SELECT ON SCHEMA::Defaults TO SalesPersonRole;
GRANT SELECT ON SCHEMA::Logs TO SalesPersonRole;
GRANT SELECT ON SCHEMA::Users TO SalesPersonRole;
GRANT SELECT ON SCHEMA::Products TO SalesPersonRole;

-- Adicionar permiss�es ao SalesTerritory
GRANT SELECT ON Business.SoutheastSales TO SalesTerritoryRole;


-- Cria��o de utilizadores e atribuir das respetivas roles
CREATE USER AdminUser WITHOUT LOGIN;
ALTER ROLE AdminRole ADD MEMBER AdminUser;

CREATE USER SalesPersonUser WITHOUT LOGIN;
ALTER ROLE SalesPersonRole ADD MEMBER SalesPersonUser;

CREATE USER SalesTerritoryUser WITHOUT LOGIN;
ALTER ROLE SalesTerritoryRole ADD MEMBER SalesTerritoryUser;
