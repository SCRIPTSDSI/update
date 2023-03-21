SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE  FUNCTION [dbo].[DRHDateKP]
(
 @PUser      VARCHAR(30),
 @PTableName VARCHAR(30)
)
RETURNS Varchar(50)
AS
begin
  

Declare @DateLimited Varchar(12)
Declare @Dite int

Set @DateLimited='01/01/1760'

SELECT @Dite=IsNull(DITEVIEW,0) FROM DRH..USERS WHERE USERN=@Puser


if @Dite<>0 
   Set @DateLimited=Convert(Varchar,(GetDate()-@Dite),103)

Return @DateLimited

end
GO
