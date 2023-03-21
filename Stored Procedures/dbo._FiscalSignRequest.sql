SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[_FiscalSignRequest] (@inputString [nvarchar] (max), @certificatePath [nvarchar] (max), @certificatePassword [nvarchar] (max), @certbinary [varbinary] (max), @signedString [nvarchar] (max) OUTPUT)
WITH EXECUTE AS CALLER
AS EXTERNAL NAME [iic].[UserDefinedFunctions].[GenerateSign]
GO
