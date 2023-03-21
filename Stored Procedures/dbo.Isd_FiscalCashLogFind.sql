SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE          procedure [dbo].[Isd_FiscalCashLogFind]
(
  @pTCRCode  Varchar(50),
  @pDateDok  Varchar(20),
  @pTipi     Varchar(10)
)
AS

--      EXEC dbo.Isd_FiscalCashLogFind 'hy521rx101','26/06/2021','INITIAL'


     Declare @TCRCode    Varchar(50),
             @DateDok    DateTime,
		     @Tipi       Varchar(10),
			 @Result     Int;


         SET @TCRCode  = @pTcrCode;
		 SET @DateDok  = dbo.DateValue(@pDateDok);
		 SET @Tipi     = @pTipi;

         SET @Result   = 0;

         IF  EXISTS (SELECT 1 FROM LogArka Where TCRCODE=@TCRCode AND TIPI=@Tipi AND DATEDOK=@DateDok AND ISNULL([ERROR],0)=0) 
             SET @Result = 1;

      SELECT RESULT    = @Result;
       PRINT @Result;
GO
