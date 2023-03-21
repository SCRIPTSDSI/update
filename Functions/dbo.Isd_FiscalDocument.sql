SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- SELECT A=dbo.Isd_FiscalDocument('FJ',2)

CREATE Function [dbo].[Isd_FiscalDocument] 
(
 @pTableName  Varchar(30),
 @pNrRendor   Int 
)

RETURNS BIT

AS

BEGIN


     DECLARE @sTableName     Varchar(30),
             @NrRendor       Int,
			 @Result         Bit;

         SET @sTableName   = ISNULL(@pTableName,'');
         SET @NrRendor     = ISNULL(@pNrRendor,0);

         SET @Result       = 0;

          IF @sTableName='FJ'
	         BEGIN
               If EXISTS ( SELECT * FROM FJ WHERE NrRendor = @NrRendor AND 1=1) -- te punohet filteri per kriterin e fiskalizimit
                  SET @Result = 1
             END;

          IF @sTableName='FD'
	         BEGIN
               If EXISTS ( SELECT * FROM FD WHERE NrRendor = @NrRendor AND 2=2) -- te punohet filteri per kriterin e fiskalizimit
                  SET @Result = 1
             END;


      RETURN @Result;


END
GO
