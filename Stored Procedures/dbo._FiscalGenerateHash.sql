SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[_FiscalGenerateHash] (@inputString [nvarchar] (max), @certificatePath [nvarchar] (max), @certificatePassword [nvarchar] (max), @certbinary [varbinary] (max), @iic [nvarchar] (max) OUTPUT, @iicSignature [nvarchar] (max) OUTPUT, @errorText [nvarchar] (max) OUTPUT, @error [nvarchar] (max) OUTPUT)
WITH EXECUTE AS CALLER
AS EXTERNAL NAME [iic].[UserDefinedFunctions].[GenerateHash]
GO
