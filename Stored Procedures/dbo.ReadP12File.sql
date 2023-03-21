SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ReadP12File]
    @filename nvarchar(255)
AS
BEGIN
    DECLARE @filedata varbinary(max)
    
    SELECT @filedata = filedata FROM p12_files WHERE filename = @filename
    
    SELECT CONVERT(varchar(max), @filedata, 2) AS filedata_hex
END
GO
