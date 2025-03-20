
ALTER TABLE Users.CustomerAccount
ADD Salt NVARCHAR(128) NOT NULL,
    HashedAnswer NVARCHAR(128) NOT NULL,
    SaltAnswer NVARCHAR(128) NOT NULL;

ALTER TABLE Users.CustomerAccount
DROP COLUMN AuthAnswer;


GO
CREATE FUNCTION fn_HashPassword
(
    @Password NVARCHAR(128),
    @Salt NVARCHAR(128)
)
RETURNS NVARCHAR(64)
AS
BEGIN
    RETURN CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', @Password + @Salt), 2)
END;
GO

ALTER PROCEDURE sp_NewPassword
    @LoginID INT,
    @QuestionID INT,
    @Answer NVARCHAR(128),
    @NewPassword NVARCHAR(128)
AS
BEGIN TRY
    DECLARE @CorrectAnswer NVARCHAR(128);
    DECLARE @CorrectQuestionKey INT;
    DECLARE @Salt NVARCHAR(128);

	DECLARE @HashedAnswerStored NVARCHAR(64);
    DECLARE @SaltAnswerStored NVARCHAR(128);
    
    -- Obtém a chave da pergunta, hash da resposta e o salt correspondente associada à conta
    SELECT @CorrectQuestionKey = QuestionKey, @HashedAnswerStored = HashedAnswer, @SaltAnswerStored = SaltAnswer
    FROM Users.CustomerAccount
    WHERE CustomerAccountKey = @LoginID;   
    
    -- Verifica se a pergunta e resposta fornecida corresponde à resposta correta
    IF @QuestionID = @CorrectQuestionKey AND dbo.fn_HashPassword(@Answer, @SaltAnswerStored) = @HashedAnswerStored
    BEGIN
        -- Gera um novo salt
        SET @Salt = NEWID();
        -- Atualiza a password na tabela CustomerAccount
        UPDATE Users.CustomerAccount
        SET HashedPassword = dbo.fn_HashPassword(@NewPassword, @Salt), Salt = @Salt
        WHERE CustomerAccountKey = @LoginID;
        
        PRINT '[Password Update] Password alterada com sucesso.';
    END
    ELSE
    BEGIN
        -- Resposta e/ou Pergunta incorreta.
        PRINT '[Password Update] Dados invalidos. A password não foi alterada.';
    END
END TRY
BEGIN CATCH
    RAISERROR ('Ocorreu um erro ao alterar a password.', 18, 1);
END CATCH;
GO

ALTER PROCEDURE sp_AddAccount
    @Password NVARCHAR(128),
    @Question INT,
    @Answer NVARCHAR(128),
    @AccessLevel INT,
    @PCustomerKey INT
AS
BEGIN TRY
    DECLARE @CustomerExists INT;
    DECLARE @AccountExists INT;
    DECLARE @Salt NVARCHAR(128);
	DECLARE @SaltAnswer NVARCHAR(128) = NEWID();
    
    SELECT @CustomerExists = COUNT(*) FROM Users.Customer WHERE CustomerKey = @PCustomerKey;
    SELECT @AccountExists = COUNT(*) FROM Users.CustomerAccount WHERE CustomerKey = @PCustomerKey;
    
    IF @CustomerExists > 0 AND @AccountExists = 0
    BEGIN
        -- Gera um novo salt
        SET @Salt = NEWID();
        INSERT INTO Users.CustomerAccount
        (
            HashedPassword, 
            Salt,
            QuestionKey, 
            HashedAnswer,
			SaltAnswer, 
            AccessLevelKey, 
            CustomerKey
        )
        VALUES
        (
            dbo.fn_HashPassword(@Password, @Salt),
            @Salt, 
            @Question, 
            dbo.fn_HashPassword(@Answer, @SaltAnswer), 
			@SaltAnswer,
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
	END CATCH;
GO

