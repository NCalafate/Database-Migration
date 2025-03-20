/*
	Este ficheiro é responsável pela criação de Stored Procedures, funções e Triggers.
	É o segundo a ser executado de forma a apoiar na migração de dados.
*/

USE AdventureWorks;
GO

/*
	Cria a procedure que irá popular a tabela ErrorHandling caso existam erros.
*/
DROP PROCEDURE IF EXISTS sp_ErrorHandling
GO
CREATE PROCEDURE sp_ErrorHandling 
AS 
	DECLARE @ErrorNumber   INT
	DECLARE @ErrorMessage  VARCHAR(4000)
	DECLARE @HostName	   VARCHAR(200)
	DECLARE @TimeStamp     DATETIME
	BEGIN TRY
		SELECT 
			@ErrorNumber  = ISNULL(ERROR_NUMBER(), 0),
			@ErrorMessage = ISNULL(ERROR_MESSAGE(), 'O erro lançado não continha mensagem...'),
			@HostName     = HOST_NAME(),
			@TimeStamp    = GETDATE();
		INSERT INTO AdventureWorks.Logs.ErrorHandling 
		(
			HostName,
			ErrorMsg,
			ErrorCode,
			CreatedAt	
		)
		SELECT 
			@HostName, 
			@ErrorMessage, 
			@ErrorNumber, 
			@TimeStamp
	END TRY
	BEGIN CATCH
		RAISERROR ('Ocorreu um erro ao criar a PROCEDURE [ sp_ErrorHandling ].', 18, 1);
	END CATCH
GO

/*
    Criação do procedure que permite a alteração dos níveis de acesso.
*/
DROP PROCEDURE IF EXISTS sp_UpdateAccess
GO
CREATE PROCEDURE sp_UpdateAccess
    @LoginID   INT,
    @NewAccess NVARCHAR(6)
AS
	BEGIN TRY
		IF @NewAccess = 'admin'
		BEGIN
			UPDATE Users.CustomerAccount
			SET AccessLevelKey = 2
			WHERE CustomerAccountKey = @LoginID;
			PRINT '[Access Update] - Nível de acesso modificado com sucesso.';
		END
		ELSE IF @NewAccess = 'user'
		BEGIN
			UPDATE Users.CustomerAccount
			SET AccessLevelKey = 1
			WHERE CustomerAccountKey = @LoginID;
			PRINT '[Access Update] - Nível de acesso modificado com sucesso.';
		END
		ELSE
		BEGIN
			PRINT '[Access Update] - Erro. Nenhum dado foi alterado.';
		END
	END TRY
	BEGIN CATCH
		RAISERROR ('Ocorreu um erro ao criar a PROCEDURE [ sp_UpdateAccess ].', 18, 1);
	END CATCH
GO

/*
	Criação do procedure que permite a alteração da password de um cliente.
*/
DROP PROCEDURE IF EXISTS sp_NewPassword
GO
CREATE PROCEDURE sp_NewPassword
    @LoginID    INT,
	@QuestionID INT,
    @Answer     NVARCHAR(128)
AS
	BEGIN TRY
		DECLARE @CorrectAnswer      NVARCHAR(128);
		DECLARE @CorrectQuestionKey INT;
		-- Obtém a resposta correta e a chave da pergunta associada à conta
		SELECT @CorrectAnswer = AuthAnswer, @CorrectQuestionKey = QuestionKey
		FROM Users.CustomerAccount
		WHERE CustomerAccountKey = @LoginID;
		-- Verifica se a pergunta e resposta fornecida corresponde à resposta correta
		IF @QuestionID = @CorrectQuestionKey AND @Answer = @CorrectAnswer
		BEGIN
			-- Atualiza a senha na tabela CustomerAccount
			UPDATE Users.CustomerAccount
			SET HashedPassword = NewID()
			WHERE CustomerAccountKey = @LoginID;
			PRINT '[Password Update] Senha lterada com sucesso.';
		END
		ELSE
		BEGIN
			-- Resposta e/ou Pergunta incorreta.
			PRINT '[Password Update] Dados invalidos. A senha não foi alterada.';
		END
	END TRY
	BEGIN CATCH
		RAISERROR ('Ocorreu um erro ao criar a PROCEDURE [ sp_NewPassword ].', 18, 1);
	END CATCH
GO

/*
    Criação de um procedure para criar novas contas.
*/
DROP PROCEDURE IF EXISTS sp_AddAccount
GO
CREATE PROCEDURE sp_AddAccount
    @Question int,
    @Answer nvarchar(128),
    @AccessLevel int,
    @PCustomerKey int
AS
	BEGIN TRY
        DECLARE @CustomerExists int;
        DECLARE @AccountExists int;
        SELECT @CustomerExists = COUNT(*) FROM Users.Customer WHERE CustomerKey = @PCustomerKey;
        SELECT @AccountExists = COUNT(*) FROM Users.CustomerAccount WHERE CustomerKey = @PCustomerKey;
        IF @CustomerExists > 0 AND @AccountExists = 0
			BEGIN       
				DECLARE @NewID uniqueidentifier = NEWID();
				INSERT INTO Users.CustomerAccount
				(
					HashedPassword, 
					QuestionKey, 
					AuthAnswer, 
					AccessLevelKey, 
					CustomerKey
				)
				VALUES
				(
					@NewID, 
					@Question, 
					@Answer, 
					@AccessLevel, 
					@PCustomerKey
				);  
				PRINT '[Account Creation] - Conta criada com sucesso.'; 
			END
        ELSE
			BEGIN
				IF @CustomerExists = 0
					PRINT '[Account Creation] - Erro. O cliente não existe.';
				ELSE
					PRINT '[Account Creation] - Erro. A conta já existe.';
			END
	END TRY
	BEGIN CATCH
		RAISERROR ('Ocorreu um erro ao criar a PROCEDURE [ sp_AddAccount ].', 18, 1);
	END CATCH
GO

/*
	Cria uma procedure que calcula o tamanho de uma certa tabela.
	NOTA: Calcula o tamanho total ATUAL.
*/
DROP PROCEDURE IF EXISTS sp_CalculateRecordSize
GO
CREATE PROCEDURE sp_CalculateRecordSize
    @SchemaName NVARCHAR(255),
    @TableName NVARCHAR(255)
AS
	BEGIN TRY
		-- Create a temporary table to store column sizes
		CREATE TABLE #ColumnSizes
		(
			ColumnName NVARCHAR(255),
			DataType NVARCHAR(255),
			MaxLength INT,
			IsNullable BIT
		);

		-- Insert column information into the temporary table
		INSERT INTO #ColumnSizes
		SELECT 
			COLUMN_NAME,
			DATA_TYPE,
			CASE
				WHEN CHARACTER_MAXIMUM_LENGTH IS NOT NULL THEN CHARACTER_MAXIMUM_LENGTH
				ELSE 0
			END AS MaxLength,
			CASE 
				WHEN IS_NULLABLE = 'YES' THEN 1
				ELSE 0
			END AS IsNullable
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = @TableName AND TABLE_SCHEMA = @SchemaName;

		-- Calculate the estimated record size
		DECLARE @RecordSize INT = 0;

		SELECT 
			@RecordSize = @RecordSize + 
				CASE 
					WHEN DataType IN ('int', 'smallint', 'tinyint') THEN 4 -- Example for integer types
					WHEN DataType IN ('nvarchar', 'nchar') THEN (MaxLength * 2) -- Example for Unicode strings
					-- Add more cases for other data types as needed
					ELSE 0
				END
		FROM #ColumnSizes
		WHERE DataType <> 'timestamp'; -- Exclude timestamp columns

		-- Drop the temporary table
		DROP TABLE #ColumnSizes;

		-- Display the estimated record size
		PRINT 'Estimated Size of a Record in ' + @SchemaName + '.' + @TableName + ': ' + CAST(@RecordSize AS NVARCHAR(50)) + ' bytes';
	END TRY
	BEGIN CATCH
		RAISERROR ('Ocorreu um erro ao criar a PROCEDURE [ sp_CalculateRecordSize ].', 18, 1);
	END CATCH;
GO

/*
	Cria uma procedure que regista as alterações nos Schemas.
*/
DROP PROCEDURE IF EXISTS sp_RecordSchemaChanges
GO
CREATE PROCEDURE sp_RecordSchemaChanges
AS
	BEGIN TRY
		DECLARE @ChangeDescription NVARCHAR(MAX);
		SET @ChangeDescription = '';
		-- Gather information about the tables and their columns
		SELECT 
			@ChangeDescription = @ChangeDescription +
				'Table: ' + t.name + CHAR(13) + CHAR(10) +
				'Columns: ' + STUFF((
					SELECT 
						CHAR(13) + CHAR(10) + ' - ' + c.name + ' (' + 
						CASE 
							WHEN ty.name IN ('nvarchar', 'varchar', 'nchar', 'char') THEN ty.name + '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length AS NVARCHAR(10)) END + ')'
							WHEN ty.name IN ('decimal', 'numeric') THEN ty.name + '(' + CAST(c.precision AS NVARCHAR(5)) + ',' + CAST(c.scale AS NVARCHAR(5)) + ')'
							ELSE ty.name
						END + ')' + 
						CASE 
							WHEN c.is_identity = 1 THEN ' [Identity]'
							ELSE ''
						END + 
						CASE 
							WHEN c.is_nullable = 0 THEN ' NOT NULL'
							ELSE ''
						END + 
						CASE 
							WHEN dc.definition IS NOT NULL THEN ' DEFAULT ' + dc.definition
							ELSE ''
						END + CHAR(13) + CHAR(10)
					FROM sys.columns c
					INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
					LEFT JOIN sys.default_constraints dc ON c.default_object_id = dc.object_id
					WHERE c.object_id = t.object_id
					FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 4, '') + CHAR(13) + CHAR(10) +
				'Constraints: ' + ISNULL((
					SELECT 
						CHAR(13) + CHAR(10) + ' - ' + cc.name + ' (Foreign Key: ' + fk.name + ', Referenced Table: ' + rt.name + ', ' + 
						CASE 
							WHEN fk.delete_referential_action = 0 THEN 'No Action'
							WHEN fk.delete_referential_action = 1 THEN 'Cascade'
							WHEN fk.delete_referential_action = 2 THEN 'Set Null'
							WHEN fk.delete_referential_action = 3 THEN 'Set Default'
						END + ' on Delete, ' + 
						CASE 
							WHEN fk.update_referential_action = 0 THEN 'No Action'
							WHEN fk.update_referential_action = 1 THEN 'Cascade'
							WHEN fk.update_referential_action = 2 THEN 'Set Null'
							WHEN fk.update_referential_action = 3 THEN 'Set Default'
						END + ' on Update)' + CHAR(13) + CHAR(10)
					FROM sys.foreign_key_columns fkc
					INNER JOIN sys.columns cc ON fkc.parent_column_id = cc.column_id AND fkc.parent_object_id = cc.object_id
					INNER JOIN sys.tables rt ON fkc.referenced_object_id = rt.object_id
					INNER JOIN sys.columns rc ON fkc.referenced_column_id = rc.column_id AND fkc.referenced_object_id = rc.object_id
					INNER JOIN sys.foreign_keys fk ON fkc.constraint_object_id = fk.object_id
					WHERE fkc.parent_object_id = t.object_id
					FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), '') + CHAR(13) + CHAR(10) + '------------------------' + CHAR(13) + CHAR(10)
		FROM sys.tables t;

		-- Insert the schema change description into the history table
		INSERT INTO Monitoring.SchemaChanges (ChangeDescription) VALUES (@ChangeDescription);
	END TRY
	BEGIN CATCH
		RAISERROR ('Ocorreu um erro ao criar a PROCEDURE [ sp_RecordSchemaChanges ].', 18, 1);
	END CATCH;
GO

/*
	Cria uma procedure que verifica o espaço ocupado pelos registos.
*/
DROP PROCEDURE IF EXISTS sp_RecordTableSpaceUsage
GO
CREATE PROCEDURE sp_RecordTableSpaceUsage
AS
	BEGIN TRY
		IF OBJECT_ID('tempdb..#SpaceUsed') IS NOT NULL
			DROP TABLE #SpaceUsed;
		IF OBJECT_ID('Monitoring.TableSpaceHistory') IS NULL
		BEGIN
			CREATE TABLE Monitoring.TableSpaceHistory (
				ExecutionTime   DATETIME,
				TableName       SYSNAME,
				NumRows         BIGINT,
				ReservedSpace   VARCHAR(50),
				DataSpace       VARCHAR(50),
				IndexSize       VARCHAR(50),
				UnusedSpace     VARCHAR(50)
			);
		END
		BEGIN TRY
			CREATE TABLE #SpaceUsed (
				TableName       SYSNAME,
				NumRows         BIGINT,
				ReservedSpace   VARCHAR(50),
				DataSpace       VARCHAR(50),
				IndexSize       VARCHAR(50),
				UnusedSpace     VARCHAR(50)
			);
        
			DECLARE @str VARCHAR(500)
			SET @str =  'exec sp_spaceused ''?'''
			INSERT INTO #SpaceUsed 
			EXEC sp_msforeachtable @command1=@str
        
			INSERT INTO Monitoring.TableSpaceHistory (ExecutionTime, TableName, NumRows, ReservedSpace, DataSpace, IndexSize, UnusedSpace)
			SELECT GETDATE(), TableName, NumRows, ReservedSpace, DataSpace, IndexSize, UnusedSpace
			FROM #SpaceUsed;
        
			SELECT TableName, NumRows, 
				CONVERT(numeric(18,0),REPLACE(ReservedSpace,' KB','')) / 1024 AS ReservedSpace_MB,
				CONVERT(numeric(18,0),REPLACE(DataSpace,' KB','')) / 1024 AS DataSpace_MB,
				CONVERT(numeric(18,0),REPLACE(IndexSize,' KB','')) / 1024 AS IndexSpace_MB,
				CONVERT(numeric(18,0),REPLACE(UnusedSpace,' KB','')) / 1024 AS UnusedSpace_MB
			FROM #SpaceUsed
			ORDER BY ReservedSpace_MB DESC;
        
		END TRY
		BEGIN CATCH
			EXEC sp_ErrorHandling;
			THROW;
		END CATCH
	END TRY
	BEGIN CATCH
		RAISERROR ('Ocorreu um erro ao criar a PROCEDURE [ sp_RecordTableSpaceUsage ].', 18, 1);
	END CATCH;
GO

/*
	Cria o trigger para recuperar a password do utilizador.
	Neste caso, um email com a password de recuperação é enviado.
*/
DROP TRIGGER IF EXISTS tr_RecoveryPassword
GO
CREATE TRIGGER tr_RecoveryPassword
ON Users.CustomerAccount
AFTER UPDATE
AS
	BEGIN TRY 
		-- Declaram-se as variáveis para armazenar informações.
		DECLARE @CustomerAccountKey INT;
		DECLARE @NewHashedPassword NVARCHAR(256);

		-- Obter o LoginKey e a nova Password.
		SELECT @CustomerAccountKey = i.CustomerAccountKey, @NewHashedPassword = i.HashedPassword
		FROM inserted i;

		-- Inserir um registo na tabela RecoveryEmail.
		INSERT INTO Logs.RecoveryEmail 
		(
			Content, 
			TimestampSent, 
			CustomerAccountKey
		)
		VALUES (
			'Senha: ' + @NewHashedPassword, 
			GETDATE(),
			@CustomerAccountKey
		);
	END TRY
	BEGIN CATCH
		RAISERROR ('Ocorreu um erro ao criar o TRIGGER [ tr_RecoveryPassword ].', 18, 1);
	END CATCH
GO


