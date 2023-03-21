SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- EXEC [dbo].[Isd_FifoSeriSkadence] 'PG1','P101',1742630,'AAAA','D'


CREATE   Procedure [dbo].[Isd_FifoSeriSkadence]    -- Ndryshime pas dates 16.02.2021 (shiko komentet me poshte per para 16.02.2021)
( 
 @pKMag         Varchar(30),
 @pKod          Varchar(50),
 @pNrRendorDok  Int,
 @pTmpTable     Varchar(30),
 @pTipDok       Varchar(10)   -- H ose D
 )
As


     DECLARE @KMag          Varchar(30),
             @Kod           Varchar(50),
             @NrRendor      Int,
             @sTmpTable     Varchar(30),
             @sSql          Varchar(Max),
             @sTip          Varchar(10);

         SET @Kod         = @pKod;
         SET @KMag        = @pKMag;
         SET @NrRendor    = @pNrRendorDok;
         SET @sTmpTable   = @pTmpTable;
         SET @sTip        = @pTipDok;


          IF OBJECT_ID('TEMPDB..#TmpSkadence') IS NOT NULL
             DROP TABLE #TmpSkadence;
             
             
             
-- Ndertohet tabela #TmpSkadence ku seleksionohen te dhenat ...
             
      SELECT DTSKADENCE,SERI,SASI
        INTO #TmpSkadence
        FROM FHSCR 
       WHERE 1=2;       
             
             
         SET @sSql = '
      INSERT INTO #TmpSkadence
            (DTSKADENCE,SERI,SASI) 
              
      SELECT DTSKADENCE,SERI=ISNULL(SERI,''''),SASI=0+SUM(SASI)
        FROM '+@sTmpTable+'   
       WHERE KARTLLG='''+@Kod+''' 
    GROUP BY DTSKADENCE,ISNULL(SERI,'''')
      HAVING (SUM(SASI)>0);';
      

          IF (@sTip='D') OR (@sTip='FD')
             SET @sSql = REPLACE(@sSql,'0+','0-');

       EXEC (@sSql);


      INSERT #TmpSkadence
            (DTSKADENCE,SERI,SASI)
            
      SELECT TOP 1 
             DTSKADENCE, SERI=ISNULL(SERI,''), SASI=SUM(SASIH-SASID)
        FROM LEVIZJEHD 
       WHERE KMAG=@KMag AND KARTLLG=@Kod AND (NrRendor<>@NrRendor) AND (NOT (DTSKADENCE IS NULL))
    GROUP BY KMAG,KARTLLG,DTSKADENCE,ISNULL(SERI,'') 
      HAVING (SUM(SASIH-SASID)>0) 
    ORDER BY DTSKADENCE;
    

/*    SELECT DTSKADENCE,SERI=ISNULL(SERI,''),SASI=SUM(SASIH-SASID)
        FROM LEVIZJEHD 
       WHERE KMAG=@KMag AND KARTLLG=@Kod AND (NrRendor<>@NrRendor) AND (NOT (DTSKADENCE IS NULL))
    GROUP BY KMAG,KARTLLG,DTSKADENCE,ISNULL(SERI,'') 
      HAVING (SUM(SASIH-SASID)>0) 
    ORDER BY DTSKADENCE;

      SELECT 'T',* FROM #TmpSkadence; */


      SELECT TOP 1 DTSKADENCE,SERI
        FROM #TmpSkadence 
       WHERE NOT (DTSKADENCE IS NULL)
    GROUP BY DTSKADENCE,SERI 
      HAVING (SUM(SASI)>0) 
    ORDER BY DTSKADENCE;
    




/*
ALTER   Procedure [dbo].[Isd_FifoSeriSkadence]         -- Ishte deri me 16.02.2021
( 
  @pKMag   Varchar(30),
  @pKod    Varchar(50)
 )
As


     DECLARE @KMag    Varchar(30),
             @Kod     Varchar(50);

         SET @Kod   = @pKod;
         SET @KMag  = @pKMag;


      SELECT TOP 1 DTSKADENCE, SERI 
        FROM LEVIZJEHD 
       WHERE KMAG=@KMag AND KARTLLG=@Kod
    GROUP BY KMAG,KARTLLG,DTSKADENCE,SERI 
      HAVING SUM(SASIH-SASID)>0 
    ORDER BY DTSKADENCE;
                                                       -- Ishte deri me 16.02.2021
*/




--    SELECT TOP 1 SERI 
--      FROM LEVIZJEHD 
--     WHERE KMAG=@KMag AND KARTLLG=@Kod AND DTSKADENCE=@Dt
--  GROUP BY KMAG,KARTLLG,DTSKADENCE,SERI 
--    HAVING SUM(SASIH-SASID)>0 


/*

-- Kodi ne program:
 
     Declare @DtSkadence DateTime,
             @Serial     Varchar(30); 

      SELECT TOP 1 @DtSkadence=DTSKADENCE 
        FROM LEVIZJEHD 
       WHERE KMAG = @KMag AND KARTLLG=@Kod
    GROUP BY KMAG,KARTLLG,DTSKADENCE 
      HAVING SUM(SASIH-SASID)>0 
    ORDER BY DTSKADENCE; 
          
      SELECT TOP 1 @Serial =SERI 
        FROM LEVIZJEHD 
       WHERE KMAG = @KMag AND KARTLLG=@Kod AND DTSKADENCE=@DtSkadence 
    GROUP BY KMAG,KARTLLG,DTSKADENCE,SERI 
      HAVING SUM(SASIH-SASID)>0 
    ORDER BY SERI; 

      SELECT DTSKADENCE=@DtSkadence, SERI=@serial; 
*/
GO
