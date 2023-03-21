SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





-- Exec [Isd_GetListKodSameValue] 'ARTIKUJ', 'BC', '5304000030599', 0

CREATE         Procedure [dbo].[Isd_GetListKodSameValue] -- Find kod qe plotesojne nje kriter te njejte psh. Artikuj me te njejten barkod etj.
(
   @pTable      Varchar(60),
   @pFld        Varchar(60),
   @pValue      Varchar(60),
   @pNrRendor   Int
 )

As     
     
-- Gjenerohet nje string me kodet e references qe kane te njejten vlere te ndonje fushe.
-- Psh: Ne se kemi fushen BC (pra @pFld='BC') dhe tabelen ARTIKUJ (pra @pTable='ARTIKUJ'
--      atehere afishohen kodet qe kane fushen BC te barabarte me vleren @pValue.
         SET NOCOUNT ON;
         
     DECLARE @sTable      Varchar(60),
             @sFld        Varchar(60),
             @sValue      Varchar(60), 
             @NrRendor    Int,
             
             @sList       Varchar(MAX),
             @sSql       nVarchar(MAX),
             @NrID        Int,
             @iLength     Int;
         
         SET @sTable    = @pTable;
         SET @sFld      = @pFld;
         SET @sValue    = @pValue;
         SET @NrRendor  = @pNrRendor;
        
         SET @sList     = '';
         SET @NrID      = 0;
         SET @iLength   = 100;

         SET @sSql = N'
      SELECT @sList=@sList+'',''+ISNULL(KOD,'''') 
        FROM '+@sTable+' 
       WHERE NRRENDOR<>'+CAST(CAST(@NrRendor AS BIGINT) AS VARCHAR(30))+' AND '+@sFld+'='''+@sValue+'''
    ORDER BY KOD;
    
      SELECT TOP 1 @NrID=NRRENDOR
        FROM '+@sTable+' 
       WHERE NRRENDOR<>'+CAST(CAST(@NrRendor AS BIGINT) AS VARCHAR(30))+' AND '+@sFld+'='''+@sValue+'''
    ORDER BY KOD; ';
     EXECUTE SP_EXECUTESQL @sSql, N'@sList VARCHAR(MAX) OUT,@NrID INT OUT',@sList OUTPUT,@NrId OUTPUT;
--     PRINT @sList

          IF @sList<>''
             SET @sList = SUBSTRING(@sList,2,Len(@sList));

          IF DATALENGTH(@sList)>@iLength
             SET @sList = SUBSTRING(@sList,1,@iLength-4)+'...';

          IF @sList<>''
             SET @sList = '('+@sList+')';
      SELECT NRID=@NrID, LISTKOD = @sList;   -- @NrID NRRENDOR i pare ne kete liste
             
--     PRINT @sList;
       

GO
