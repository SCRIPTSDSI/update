SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- EXEC [Isd_TestRowSaCmVl] 'FJSCR', 1199753, 0.00;

CREATE Procedure [dbo].[Isd_TestRowSaCmVl]
(
 @pTable       Varchar(30),
 @pNrRendor    Int, 
 @pRound       Float              -- u zbut kontrolli per diference sepse jepte perafrime dhe mesazhe te bezdisura .... Alta Group etj 02.9.19
 )
AS

        
         SET NOCOUNT ON

     DECLARE @sError       Varchar(MAX),
             @sSql        nVarchar(MAX),
             @sTable       Varchar(30),
             @sRound       Varchar(30),
             @sWhere       Varchar(MAX);
        
         SET @sError     = '';
         SET @sWhere     = CASE WHEN @pNrRendor>0 
                                THEN 'NRD='+CAST(CAST(@pNrRendor AS BIGINT) AS VARCHAR)
                                ELSE '' 
                           END;
         SET @sTable     = @pTable;
--       IF  @pRound<=0
             SET @sRound = '0.5'
--       ELSE
--           SET @sRound = CAST(@pRound AS VARCHAR(30));
             




-- Keto reshta u futen me force per AP dhe vetem per FJT2                -- 09.11.2019
-- jepte probleme relacionet (Vlefte, Sasi, Cmim)

        SET @sSql = '';
        
         IF  @sWhere='' AND @pTable='#FJTSCR'
             BEGIN
               SET @sSql = N'
         
      UPDATE '+@sTable+'
         SET VLPATVSH = ROUND(SASI*CMIMBS,3),
             VLTVSH   = ROUND((SASI*CMIMBS*PERQTVSH)/100,3),
             VLERABS  = ROUND(SASI*CMIMBS,3)+ROUND((SASI*CMIMBS*PERQTVSH)/100,3)
       WHERE (TIPKLL=''K'' OR TIPKLL=''R'') ';

             END;
             
-- Fund bdryshime AP                                   -- 09.11.2019



         SET @sSql = @sSql+N'
         
      SELECT TOP 20 @sError = @sError+'',''+ISNULL(KARTLLG,'''') 
        FROM '+@sTable+' 
       WHERE (1=1) AND 
             (TIPKLL=''K'' OR TIPKLL=''R'') AND 
             (ABS(ROUND((CMIMBS*SASI)-VLPATVSH,2))>='+@sRound+' OR ABS(ROUND((CMIMBS*SASI)+ISNULL(VLTVSH,0)-VLERABS,2))>='+@sRound+')
--  ORDER BY NRRENDOR; ';

         IF  @sWhere<>''
             SET @sSql = REPLACE(@sSql,'1=1',@sWhere);

     PRINT @sSql;             

     EXECUTE SP_EXECUTESQL @sSql, N'@sError VARCHAR(MAX) OUT',@sError OUTPUT;
 
         IF  SUBSTRING(@sError,1,1)=','
             SET @sError = SUBSTRING(@sError,2,LEN(@sError));
         IF  @sError<>'' 
             SET @sError = 'Artikuj: '+@sError;
             
      SELECT Msg = @sError;
        
GO
