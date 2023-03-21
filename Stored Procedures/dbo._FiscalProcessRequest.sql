SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[_FiscalProcessRequest] (@inputString [nvarchar] (max), @certificatePath [nvarchar] (max), @certificatePassword [nvarchar] (max), @certbinary [varbinary] (max), @url [nvarchar] (200), @schema [nvarchar] (200), @returnValue [nvarchar] (200), @useSystemProxy [nvarchar] (10), @signedXml [nvarchar] (max) OUTPUT, @fic [nvarchar] (max) OUTPUT, @errorText [nvarchar] (max) OUTPUT, @error [nvarchar] (max) OUTPUT, @responseXml [xml] OUTPUT)
WITH EXECUTE AS CALLER
AS EXTERNAL NAME [iic].[UserDefinedFunctions].[ProcessRequest]
GO
