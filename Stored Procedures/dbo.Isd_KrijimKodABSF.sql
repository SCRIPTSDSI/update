SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE Procedure [dbo].[Isd_KrijimKodABSF]
 ( 
  @pModul        VARCHAR(10),
  @pCompact      INT
  )

AS

--      EXEC dbo.Isd_KrijimKodABSF 'A',0;


         SET NOCOUNT ON;
         
         
     DECLARE @Modul         VARCHAR(10),
             @Compact       INT,
             @DoubleKod     INT,
             @sSql          VARCHAR(MAX);
     
         SET @Modul       = UPPER(ISNULL(@pModul,''));
         SET @Compact     = ISNULL(@pCompact,0);
         SET @DoubleKod   = 1;   
         

          IF CHARINDEX(@Modul,'ABSF')=0
             RETURN;
             
             
          IF OBJECT_ID('TEMPDB..#TempLibraABSF') IS NOT NULL
             DROP TABLE #TempLibraABSF;


      SELECT KOD,
             SG1       = SPACE(60),
             SG2       = SPACE(60),
             SG3       = SPACE(60),
             SG4       = SPACE(60),
             SG5       = SPACE(60),
             PERSHKRIM = SPACE(150),
             KMON
        INTO #TempLibraABSF
        FROM
               
          (  SELECT A.KOD, KMON = RTRIM(LTRIM(ISNULL(A.KMON,''))), KD=B.KOD
               FROM DAR A LEFT JOIN LAR B ON A.KOD=B.KOD 
              WHERE @Modul='A' AND ISNULL(A.KOD,'''')<>'''' 
           GROUP BY A.KOD, A.KMON, B.KOD 
             HAVING ISNULL(B.KOD,'''')='''' 
              
             UNION ALL      
             
             SELECT A.KOD, KMON = RTRIM(LTRIM(ISNULL(A.KMON,''))), KD=B.KOD 
               FROM DBA A LEFT JOIN LBA B ON A.KOD=B.KOD 
              WHERE @Modul='B' AND ISNULL(A.KOD,'''')<>'''' 
           GROUP BY A.KOD, A.KMON, B.KOD 
             HAVING ISNULL(B.KOD,'''')='''' 
                
             UNION ALL      
             
             SELECT A.KOD, KMON = RTRIM(LTRIM(ISNULL(A.KMON,''))), KD=B.KOD 
               FROM DKL A LEFT JOIN LKL B ON A.KOD=B.KOD 
              WHERE @Modul='S' AND ISNULL(A.KOD,'''')<>'''' 
           GROUP BY A.KOD, A.KMON, B.KOD 
             HAVING ISNULL(B.KOD,'''')='''' 

             UNION ALL      
             
             SELECT A.KOD, KMON = RTRIM(LTRIM(ISNULL(A.KMON,''))), KD=B.KOD 
               FROM DFU A LEFT JOIN LFU B ON A.KOD=B.KOD 
              WHERE @Modul='F' AND ISNULL(A.KOD,'''')<>'''' 
           GROUP BY A.KOD, A.KMON, B.KOD 
             HAVING ISNULL(B.KOD,'''')='''' 
             
             ) A
                
    GROUP BY KOD,KMON  
    ORDER BY KOD,KMON; 
    
    
              
   RAISERROR (N' ',0,1) with NoWait;
   
   
              
      UPDATE #TempLibraABSF
         SET SG1 = Dbo.Isd_SegmentFind(KOD,0,1),
             SG2 = Dbo.Isd_SegmentFind(KOD,0,2),
             SG3 = '',  -- Dbo.Isd_SegmentFind(KD,0,3),
             SG4 = '',  -- Dbo.Isd_SegmentFind(KD,0,4),
             SG5 = '';       

--    UPDATE A
--       SET PERSHKRIM = ISNULL(B.PERSHKRIM,'')
--       --  SG3       = ISNULL((SELECT KOD FROM DEPARTAMENT C WHERE A.SG3=C.KOD),''),
--       --  SG4       = ISNULL((SELECT KOD FROM LISTE       C WHERE A.SG4=C.KOD),'')
--      FROM #TempLibraABSF A LEFT JOIN ARKAT B ON A.SG1=B.KOD;
                
              
      DELETE FROM #TempLibraABSF WHERE ISNULL(SG1,'')='';
                            

   RAISERROR (N' ',0,1) with NoWait;

   
         SET @sSql = '


          IF '+CAST(@DoubleKod AS VARCHAR)+'=1          --    Fshirje te dublikuarave 
             BEGIN

               DELETE A
                 FROM LAR A 
                WHERE (SELECT COUNT(''KOD'') FROM LAR B WHERE A.KOD=B.KOD AND A.NRRENDOR<B.NRRENDOR)>=1; 

               RAISERROR (N'' '',0,1) with NoWait; 
             END;



          IF '+CAST(@Compact AS VARCHAR)+  '=1          --    Fshirje e Kodeve te tepert, nuk kane origjine nga dokumenta (kompaktesimi) 
             BEGIN

               UPDATE LAR  SET   TAGNR=0   WHERE ISNULL(TAGNR,0)<>0;
               UPDATE A    SET   TAGNR=101 FROM LAR A INNER JOIN DAR B ON A.KOD=B.KOD;
               DELETE      FROM  LAR       WHERE ISNULL(TAGNR,0)<>101;
               UPDATE LAR  SET   TAGNR=0   WHERE ISNULL(TAGNR,0) =101;

               RAISERROR (N'' '',0,1) with NoWait;
             END;



--    Update NrLiber ne Ditar ????  Ku perdoren fushat NRLIBER ???

      UPDATE B    SET   B.NRLIBER=A.NRRENDOR FROM LAR A INNER JOIN DAR B ON A.KOD=B.KOD;
      
      RAISERROR (N'' '',0,1) with NoWait; ';
      
      

          IF @Modul='A'
             BEGIN
                 INSERT INTO LAR
                       (KOD,SG1,SG2,SG3,SG4,SG5,KMON,PERSHKRIM)
                 SELECT A.KOD,A.SG1,A.SG2,A.SG3,A.SG4,SG5,A.KMON, 
                        PERSHKRIM = ISNULL(R1.PERSHKRIM,'')
                                    + 
                                    CASE WHEN (A.SG2='') OR (ISNULL(R2.PERSHKRIM, '')='') THEN '' ELSE '/'+R2.PERSHKRIM  END 
                   FROM #TempLibraABSF A INNER JOIN ARKAT       R1 ON A.SG1=R1.KOD
                                         LEFT  JOIN MONEDHA     R2 ON A.KMON=ISNULL(R2.KOD,'')
               ORDER BY A.KOD;
             END;

          IF @Modul='B'
             BEGIN
                 INSERT INTO LBA
                       (KOD,SG1,SG2,SG3,SG4,SG5,KMON,PERSHKRIM)
                 SELECT A.KOD,A.SG1,A.SG2,A.SG3,A.SG4,SG5,A.KMON, 
                        PERSHKRIM = ISNULL(R1.PERSHKRIM,'')
                                    + 
                                    CASE WHEN (A.SG2='') OR (ISNULL(R2.PERSHKRIM, '')='') THEN '' ELSE '/'+R2.PERSHKRIM  END 
                   FROM #TempLibraABSF A INNER JOIN BANKAT      R1 ON A.SG1=R1.KOD
                                         LEFT  JOIN MONEDHA     R2 ON A.KMON=ISNULL(R2.KOD,'')
               ORDER BY A.KOD;

                    SET @sSql = REPLACE(REPLACE(@sSql,' LAR ',' LBA '),' DAR ',' DBA ');
             END;


          IF @Modul='S'
             BEGIN
                 INSERT INTO LKL
                       (KOD,SG1,SG2,SG3,SG4,SG5,KMON,PERSHKRIM)
                 SELECT A.KOD,A.SG1,A.SG2,A.SG3,A.SG4,SG5,A.KMON, 
                        PERSHKRIM = ISNULL(R1.PERSHKRIM,'')
                                    + 
                                    CASE WHEN (A.SG2='') OR (ISNULL(R2.PERSHKRIM, '')='') THEN '' ELSE '/'+R2.PERSHKRIM  END 
                   FROM #TempLibraABSF A INNER JOIN KLIENT      R1 ON A.SG1=R1.KOD
                                         LEFT  JOIN MONEDHA     R2 ON A.KMON=ISNULL(R2.KOD,'')
               ORDER BY A.KOD;

                    SET @sSql = REPLACE(REPLACE(@sSql,' LAR ',' LKL '),' DAR ',' DKL ');
             END;
            
              
          IF @Modul='F'
             BEGIN
                 INSERT INTO LFU
                       (KOD,SG1,SG2,SG3,SG4,SG5,KMON,PERSHKRIM)
                 SELECT A.KOD,A.SG1,A.SG2,A.SG3,A.SG4,SG5,A.KMON, 
                        PERSHKRIM = ISNULL(R1.PERSHKRIM,'')
                                    + 
                                    CASE WHEN (A.SG2='') OR (ISNULL(R2.PERSHKRIM, '')='') THEN '' ELSE '/'+R2.PERSHKRIM  END 
                   FROM #TempLibraABSF A INNER JOIN FURNITOR    R1 ON A.SG1=R1.KOD
                                         LEFT  JOIN MONEDHA     R2 ON A.KMON=ISNULL(R2.KOD,'')
               ORDER BY A.KOD;

                    SET @sSql = REPLACE(REPLACE(@sSql,' LAR ',' LFU '),' DAR ',' DFU ');
             END;


     
          IF OBJECT_ID('TEMPDB..#TempLibraABSF') IS NOT NULL
             DROP TABLE #TempLibraABSF;              


   RAISERROR (N' ',0,1) with NoWait;

PRINT @sSql;
       EXEC (@sSql);
       
      



      

GO
