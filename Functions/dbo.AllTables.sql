SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[AllTables]
( 
)
Returns VarChar(4000)
As
Begin
  Declare @VName VarChar(Max)
  Set     @VName=''

  SELECT @VName=@VName+','+NAME FROM Sys.Tables Where Type='U' Order By Name
  if Left(@VName,1)=','
     Set @VName = Substring(@VName,2,Len(@VName))
  Return @VName
End

GO
