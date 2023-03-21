SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[_Base64Encode] (@inputString [nvarchar] (max), @outputString [nvarchar] (max) OUTPUT)
WITH EXECUTE AS CALLER
AS EXTERNAL NAME [iic].[UserDefinedFunctions].[Base64Encode]
GO
