SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE          procedure [dbo].[Isd_FiroDetajZerim]
(
  @pTipDok         Varchar(10),
  @pTableScrName   Varchar(50),
  @pDst            Varchar(20),
  @pNrRendor       BigInt
)
AS
-- Exec Isd_FiroDetajZerim 'FJ','FJSCR', '', 1
-- Exec Isd_FiroDetajZerim 'FD','FDSCR', 'FR', 0
             
         SET NOCOUNT ON;


     DECLARE @sTipDok         Varchar(20),
             @sTableScrName   Varchar(50),
             @sDst            Varchar(20),
             @NrRendor        BigInt,
             @sSql            nVarchar(MAX);

         SET @sTipDok       = @pTipDok;
         SET @sDst          = @pDst;
         SET @NrRendor      = @pNrRendor;
         SET @sTableScrName = @pTableScrName;    -- Mund te jete dhe Temporare
         

          IF CHARINDEX('#',@sTableScrName)>0
             SET @NrRendor  = 0;
             

         SET @sSql = '
             UPDATE '+@sTableScrName+' 
                SET SASI     = 0,    VLERAM  = 0, VLERABS = 0, KOEFICIENT = 0, -- Koli
                 -- VLPATVSH = 0,    VLTVSH  = 0, VLTAX   = 0,
                 -- VLERASH  = 0,    VLERAFT = 0, VLERAOR = 0, 
                    TIPFR    = '''', SASIFR  = 0, VLERAFR = 0
              WHERE NRRENDOR>0 AND 
                   (ISNULL(TIPFR,'''')<>'''' OR ISNULL(SASI,0)<>0 OR ISNULL(VLERAM,0)<>0 OR ISNULL(VLERABS,0)<>0 OR ISNULL(KOEFICIENT,0)<>0) ';


          IF @sTipDok='FJ' AND @sDst='FR'
             BEGIN
               SET @sSql = REPLACE(@sSql,'-- VLPATVSH','   VLPATVSH');
             END

          ELSE  

          IF (@sTipDok='FD' OR @sTipDok='FH') AND (CHARINDEX(','+@sDst+',',',FR,MB,KA,RP,RK,')>0)
             BEGIN     
               SET @sSql = REPLACE(@sSql,'-- VLERASH','   VLERASH');
               IF  CHARINDEX('#',@sTableScrName)>0   -- @NrRendor=0 
                   SET @sSql = REPLACE(@sSql,' SASIFR',' PROMPTFIRO = '''', SASIFR');
             END

          ELSE
             BEGIN
               SET @sSql = '';
             END;   


             
          IF @NrRendor>0
             BEGIN
               SET @sSql = REPLACE(@sSql,'NRRENDOR>0','NRD='+CAST(@NrRendor As Varchar))
             END;           

      PRINT  @sSql;
       IF    @sSql<>''
             BEGIN
               EXEC (@sSql);
             END
      


               


















GO
