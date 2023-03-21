SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Isd_GatiFiskalStatusGroup]  -- Fiskalizim ne group
(

 @pTableName   Varchar(40),
 @pTableTmp    Varchar(40)

)

AS

BEGIN

	     SET NOCOUNT ON;
    
	 DECLARE @TableTmp      Varchar(40),
		     @DateDokFrom   DATETIME,
			 @DateDokTo     DATETIME,
			 @sSql         nVARCHAR(MAX),
	         @Output3       VARCHAR(MAX);  

         SET @TableTmp   = ISNULL(@pTableTmp,'');


         SET @sSql = N'

      SELECT @DateDokFrom = MIN(A.DATEDOK), @DateDokTo=MAX(A.DATEDOK)+1
        FROM '+@TableTmp +' A ;';

     EXECUTE SP_EXECUTESQL @sSql, N'@DateDokFrom DateTime OUT,@DateDokTo DateTime OUT',@DateDokFrom OUTPUT,@DateDokTo OUTPUT;     

	    EXEC __eInvoiceGetRequestStatusGroup '', 'SELLER',@DateDokFrom, @DateDokTo, @TableTmp, @OUTPUT3 OUTPUT;

	  SELECT KodError1=@OUTPUT3, KodError2='', MsgError=''
	
END
GO
