SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE     PROCEDURE [dbo].[Isd_AQHistoriTestDoc]
(
 @pKod            Varchar(60),   -- Test per nje dokument AQHistoriScr (para kalimit ne database te te dhenave) tek ekrani te Dhena Historike.
 @pTableScr       Varchar(60),   -- Tek ekrani Dhena historike kemi dy teste kur regjistrohet dokumenti (button bSave): 
 @pNrd            Int            -- 1. nje rresht per rresht qe perdor Isd_AQHistoriTestDoc
                                 -- 2. dhe kjo procedure Isd_AQHistoriTestDoc. 
                                 
)                                -- Problem mund te jete vonesa tek testi rresht per rresht me Isd_AQHistoriTestDoc 
                                 -- prandaj mund te perdoret me vone vetem Isd_AQHistoriTestDoc


AS  
--      EXEC dbo.Isd_AQHistoriTestDoc 'X01000003','AQHistoriScr',41;


BEGIN

         SET NOCOUNT ON;
         
     DECLARE @DateMinHis      DateTime,
             @DateMaxHis      DateTime,
             @DateMinDit      DateTime,
             @DateMaxDit      DateTime,
             @DateMaxBlHis    DateTime,
             @DateMinShHis    DateTime,
             @DateMinCrHis    DateTime,
             @sKod            Varchar(60),
             @Result          Varchar(200),
             @sSql            nVarchar(MAX),
             @sNrd            Varchar(50);
             
         SET @sKod          = @pKod;  
         SET @Result        = '';
         SET @sNrd          = '';
          IF @pNrd<>0 
             SET @sNrd      = CAST(CAST(ISNULL(@pNrd,0) AS BIGINT) AS VARCHAR);
         

          IF OBJECT_ID('TEMPDB..#AQHistoriTest') IS NOT NULL
             DROP TABLE #AQHistoriTest;
             
      SELECT NRRENDOR=CAST(0 AS BIGINT),KOD,KODAF,KARTLLG,PERSHKRIM,DATEOPER,KODOPER,DATEDOK 
        INTO #AQHistoriTest
        FROM AQHistoriScr
       WHERE 1=2;
       
         SET @sSql = '
      INSERT INTO #AQHistoriTest
            (NRRENDOR,KOD,KODAF,KARTLLG,PERSHKRIM,DATEOPER,KODOPER,DATEDOK)
      SELECT NRRENDOR,KOD,KODAF,KARTLLG,PERSHKRIM,DATEOPER,KODOPER,DATEDOK 
        FROM '+@pTableScr+' 
       WHERE 1=1 
    ORDER BY NRRENDOR;';
    
       -- IF @sNrd<>'' AND @sNrd<>'0'
       --    SET @sSql = REPLACE(@sSql,'1=1','NRD='+@sNrd);
             
          IF @sKod<>''
             SET @sSql = REPLACE(@sSql,'1=1','KARTLLG='+QuoteName(@sKod,''''));
             
        EXEC (@sSql);



      SELECT @DateMinHis    = MIN(ISNULL(DATEOPER,0)), 
             @DateMaxHis    = MAX(ISNULL(CASE WHEN NOT (KODOPER='NP' OR KODOPER='SR') THEN DATEOPER END,0)),
             @DateMaxBlHis  = MAX(       CASE WHEN KODOPER='BL'                       THEN DATEOPER END),
             @DateMinShHis  = MIN(       CASE WHEN KODOPER='SH'                       THEN DATEOPER END),
             @DateMinCrHis  = MIN(       CASE WHEN KODOPER='CR' OR KODOPER='JP'       THEN DATEOPER END)
        FROM #AQHistoriTest
--   PRINT @DateMinHis; PRINT @DateMaxHis; PRINT @DateMaxBlHis; PRINT @DateMinShHis; PRINT @DateMinCrHis ;
       
      SELECT @DateMinDit    = MIN(CASE WHEN ISNULL(B.DATEOPER,0)=0 THEN A.DATEDOK ELSE B.DATEOPER END), 
             @DateMaxDit    = MAX(CASE WHEN ISNULL(B.DATEOPER,0)=0 THEN A.DATEDOK ELSE B.DATEOPER END)
        FROM AQ A INNER JOIN AQScr B ON A.NRRENDOR=B.NRD
       WHERE B.KARTLLG=@sKod
       
                                                                            -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
      SELECT TOP 1 @Result = @sKod+': Detaje veprimi ''BL,CE,SH,CR,JP'' te perseritura disa here '
        FROM                                                                -- Vetem 'RK','RV','SR','AM','NP','SI' lejojne perseritje, 
           (                                                                -- NDOSHTA DHE 'CE' TE LEJOHET TEK DITARI HISTORIK DISA HERE
             SELECT NR=COUNT(*),KODOPER                                     -- por 'CE' jo me shume se 1 tek Ditari AQScr
               FROM #AQHistoriTest B 
              WHERE CHARINDEX(','+ISNULL(KODOPER,'')+',',',BL,CE,SH,CR,JP,')>0
           GROUP BY KODOPER
             HAVING COUNT(*)>1
      
             ) A;



         SET @Result = ISNULL(@Result,'');


          IF @Result<>''
             SET @Result = @Result
             
          ELSE
          IF EXISTS (SELECT KODOPER FROM #AQHistoriTest WHERE ISNULL(DATEOPER,0)=0)
             SET @Result = 'Detaje me [date veprimi] jo te sakte ' 
                                  
          ELSE                                                              -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
          IF EXISTS (SELECT KODOPER FROM #AQHistoriTest WHERE CHARINDEX(','+KODOPER+',',',BL,RK,RV,SR,CE,SH,AM,NP,SI,CR,JP,')=0)
             SET @Result = 'Detaje me [kod veprimi] jo te sakte '
  
          ELSE  
          IF (NOT ((@DateMaxHis IS NULL) OR (@DateMinDit IS NULL))) AND (@DateMaxHis>@DateMinDit)
             SET @Result = 'Datat e veprimeve tek detajet duhen perpara datave te veprimeve ne [ditari aktivi] '

          ELSE  
          IF EXISTS (SELECT * FROM #AQHistoriTest WHERE KODOPER<>'BL' AND DATEOPER<@DateMaxBlHis)
             SET @Result = 'Detaje me date veprime perpara dates se blerjes '
             
          ELSE   
          IF EXISTS (SELECT * FROM #AQHistoriTest WHERE CHARINDEX(','+KODOPER+',',',SH,JP,CR,')=0 AND DATEOPER>@DateMinShHis)
             SET @Result = 'Detaje me date veprimi pas dates se shitjes '
             
          ELSE
          IF EXISTS (SELECT * FROM #AQHistoriTest WHERE (KODOPER<>'JP') AND (KODOPER<>'CR') AND DATEOPER<@DateMinCrHis)
             SET @Result = 'Detaje me date veprimi pas dates se cregjistrimit ';



          IF ISNULL(@Result,'')<>''
             SET @Result = @sKod+':     '+@Result+' ..!';

      SELECT Msg=@Result;


          IF OBJECT_ID('TEMPDB..#AQHistoriTest') IS NOT NULL
             DROP TABLE #AQHistoriTest;

END   

GO
