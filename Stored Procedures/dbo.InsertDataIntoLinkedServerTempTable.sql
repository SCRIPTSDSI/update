SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[InsertDataIntoLinkedServerTempTable]
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @LinkedServerName NVARCHAR(50) = 'FINTRSQL';
    DECLARE @LinkedDatabaseName NVARCHAR(50) = 'BM15';
    DECLARE @TempTableName NVARCHAR(50) = 'TMP_SHITJ2E';
    
    -- Create the temporary table on the linked server
    DECLARE @Sql NVARCHAR(MAX) = 'CREATE TABLE [' + @TempTableName + '] (';
    SELECT @Sql += '[' + COLUMN_NAME + '] ' + DATA_TYPE + ','
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'sm';
    SET @Sql = LEFT(@Sql, LEN(@Sql) - 1) + ')';
    EXEC ('USE [' + @LinkedDatabaseName + '];' + @Sql);
    
    -- Insert data into the temporary table on the linked server
    SET @Sql = 'INSERT INTO [' + @LinkedServerName + '].[' + @LinkedDatabaseName + '].dbo.[' + @TempTableName + '] (';
    SELECT @Sql += '[' + COLUMN_NAME + '],'
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'sm';
    SET @Sql = LEFT(@Sql, LEN(@Sql) - 1) + ') SELECT ';
    SELECT @Sql += '[' + COLUMN_NAME + '],'
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'sm';
    SET @Sql = LEFT(@Sql, LEN(@Sql) - 1) + ' FROM [sm];';
    EXEC (@Sql);
    
    -- Return the data from the temporary table on the linked server
    SET @Sql = 'SELECT * FROM [' + @LinkedServerName + '].[' + @LinkedDatabaseName + '].dbo.[' + @TempTableName + ']';
    EXEC (@Sql);
    
    -- Clean up the temporary table on the linked server
    SET @Sql = 'DROP TABLE [' + @LinkedServerName + '].[' + @LinkedDatabaseName + '].dbo.[' + @TempTableName + ']';
    EXEC (@Sql);
END
DROP TABLE TMP_SHITJE
GO
