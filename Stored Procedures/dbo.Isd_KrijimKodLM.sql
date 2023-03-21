SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE Procedure [dbo].[Isd_KrijimKodLM]
 (
  @pNrRendor     INT,
  @pCompact      INT
  )
             
AS  
         
--      EXEC dbo.Isd_KrijimKodLM 4682631,1;  


         SET NOCOUNT ON;
         

     DECLARE @NrRendor      INT,
             @NrRendorKp    INT,
             @NrRendorKs    BIGINT,
             @Compact       INT,
             @DoubleKod     INT;

         SET @NrRendor    = @pNrRendor;    
         SET @Compact     = ISNULL(@pCompact,0);
         SET @DoubleKod   = 1;   

          IF @NrRendor<>0
             BEGIN
               SET @Compact   = 0;
               SET @DoubleKod = 0;
             END;
             
          IF OBJECT_ID('TempDb..#TempLibraLM') IS NOT NULL
             DROP TABLE #TempLibraLM;


         SET @NrRendorKp  = 0;
         SET @NrRendorKs  = 9999999999;

          IF @NrRendor>0
             BEGIN
               SET @NrRendorKp = @NrRendor;
               SET @NrRendorKs = @NrRendor;
             END;

      SELECT KOD       = RTRIM(LTRIM(A.KOD)),
		     SG1       = REPLICATE('',60), 
		     SG2       = REPLICATE('',60), 
		     SG3       = REPLICATE('',60), 
		     SG4       = REPLICATE('',60), 
		     SG5       = REPLICATE('',60),
             PERSHKRIM = REPLICATE('',150),
             KMON      = RTRIM(LTRIM(ISNULL(A.KMON,'')))
 
        INTO #TempLibraLM

        FROM FKSCR A LEFT JOIN LM B ON A.KOD=B.KOD             
       WHERE (A.NRD>=@NrRendorKp AND A.NRD<=@NrRendorKs) AND (ISNULL(A.KOD,'')<>'') AND (B.KOD IS NULL) 
    -- WHERE (A.DB<>0 OR A.KR<>0 OR A.DBKRMV<>0) AND 
    GROUP BY A.KOD,A.KMON;


   RAISERROR (N' ',0,1) with NoWait;


      UPDATE #TempLibraLM       
 		 SET SG1 = Dbo.Isd_SegmentFind(KOD,0,1),         
		 	 SG2 = Dbo.Isd_SegmentFind(KOD,0,2), 
			 SG3 = Dbo.Isd_SegmentFind(KOD,0,3), 
			 SG4 = Dbo.Isd_SegmentFind(KOD,0,4),
			 SG5 = Dbo.Isd_SegmentFind(KOD,0,5); 


   RAISERROR (N' ',0,1) with NoWait;


      UPDATE A         
         SET SG1       = ISNULL(B.KOD,''),  
             SG2       = ISNULL((SELECT KOD FROM DEPARTAMENT C WHERE A.SG2=C.KOD),''),
             SG3       = ISNULL((SELECT KOD FROM LISTE       C WHERE A.SG3=C.KOD),''),
             SG4       = ISNULL((SELECT KOD FROM MAGAZINA    C WHERE A.SG4=C.KOD),''),
             SG5       = ISNULL((SELECT KOD FROM MONEDHA     C WHERE A.SG5=C.KOD),''), 
             PERSHKRIM = ISNULL(B.PERSHKRIM,'')
        FROM #TempLibraLM  A LEFT JOIN LLOGARI B ON A.SG1=B.KOD;


      DELETE FROM #TempLibraLM WHERE ISNULL(SG1,'')='';


   RAISERROR (N' ',0,1) with NoWait;
               

      UPDATE A    
         SET PERSHKRIM =                                        ISNULL(A.PERSHKRIM,'')+  
             CASE WHEN ISNULL(SG2,'')='' THEN '' ELSE '/' END + ISNULL(R2.PERSHKRIM,'')+
             CASE WHEN ISNULL(SG3,'')='' THEN '' ELSE '/' END + ISNULL(R3.PERSHKRIM,'')+
             CASE WHEN ISNULL(SG4,'')='' THEN '' ELSE '/' END + ISNULL(R4.PERSHKRIM,'')
        FROM #TempLibraLM A LEFT JOIN DEPARTAMENT R2 ON A.SG2 = R2.KOD  
                            LEFT JOIN LISTE       R3 ON A.SG3 = R3.KOD  
                            LEFT JOIN MAGAZINA    R4 ON A.SG4 = R4.KOD;  


   RAISERROR (N' ',0,1) with NoWait;


      INSERT INTO LM 
            (KOD,SG1,SG2,SG3,SG4,SG5,PERSHKRIM,KMON) 

      SELECT KOD,SG1,SG2,SG3,SG4,SG5,PERSHKRIM,KMON 
        FROM #TempLibraLM
    ORDER BY KOD;  


   RAISERROR (N' ',0,1) with NoWait;




          IF @DoubleKod=1          --             Fshirje te dublikuarave, behet sa here hidhet me @pNrRendor=0 
             BEGIN

               DELETE A
                 FROM LM A 
                WHERE (SELECT COUNT('KOD') FROM LM B WHERE A.KOD=B.KOD AND A.NRRENDOR<B.NRRENDOR)>=1;

               RAISERROR (N' ',0,1) with NoWait;
             END;


          IF @Compact=1            --             Fshirje kode qe nuk kane origjine nga dokumenta (kompaktesimi)
             BEGIN

               UPDATE LM   SET  TAGNR=0      WHERE ISNULL(TAGNR,0)<>0; 
               UPDATE A    SET  A.TAGNR=101  FROM  LM A INNER JOIN FKSCR B ON A.KOD=B.KOD; 
               DELETE      FROM LM           WHERE ISNULL(TAGNR,0)<>101; 
               UPDATE LM   SET  TAGNR=0      WHERE ISNULL(TAGNR,0) =101; 
               
               RAISERROR (N' ',0,1) with NoWait;
             END;


          IF OBJECT_ID('TempDb..#TempLibraLM') IS NOT NULL
             DROP TABLE #TempLibraLM;


GO
