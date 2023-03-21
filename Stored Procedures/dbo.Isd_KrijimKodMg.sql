SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE Procedure [dbo].[Isd_KrijimKodMg]
 ( 
  @pNrRendor     INT,
  @pCompact      INT 
  )

AS

--      EXEC dbo.Isd_KrijimKodMg 0,0;


         SET NOCOUNT ON;


     DECLARE @Compact       INT,
             @DoubleKod     INT;

         SET @Compact     = ISNULL(@pCompact,0);
         SET @DoubleKod   = 1;   


          IF OBJECT_ID('TEMPDB..#TempLibraMg') IS NOT NULL
             DROP TABLE #TempLibraMg;


      SELECT KD,
             KOD,
             NJESI        = SPACE(10),
             PERSHKRIM    = SPACE(150),
             SG1          = SPACE(60),
             SG2          = SPACE(60),
             SG3          = SPACE(60),
             SG4          = SPACE(60)
        INTO #TempLibraMg
        FROM
               
          (  SELECT KD=A.KOD, B.KOD
               FROM FHSCR A LEFT JOIN LMG B ON A.KOD=B.KOD 
              WHERE ISNULL(A.KOD,'''')<>'''' 
           GROUP BY A.KOD, B.KOD 
             HAVING ISNULL(B.KOD,'''')='''' 
              
             UNION ALL      
             
             SELECT KD=A.KOD, B.KOD 
               FROM FDSCR A LEFT JOIN LMG B ON A.KOD=B.KOD 
              WHERE ISNULL(A.KOD,'''')<>'''' 
           GROUP BY A.KOD, B.KOD 
             HAVING ISNULL(B.KOD,'''')='''' 
                
             ) A
                
    GROUP BY KD,KOD  
    ORDER BY KD,KOD; 
              

   RAISERROR (N' ',0,1) with NoWait;

              
      UPDATE #TempLibraMg
         SET SG1 = Dbo.Isd_SegmentFind(KD,0,1),
             SG2 = Dbo.Isd_SegmentFind(KD,0,2),
             SG3 = Dbo.Isd_SegmentFind(KD,0,3),
             SG4 = Dbo.Isd_SegmentFind(KD,0,4);
                    

   RAISERROR (N' ',0,1) with NoWait;


      UPDATE A
         SET PERSHKRIM = ISNULL(B.PERSHKRIM,''),
             NJESI     = ISNULL(B.NJESI,''),
             SG1       = ISNULL((SELECT KOD FROM MAGAZINA    C WHERE A.SG1=C.KOD),''),
             SG3       = ISNULL((SELECT KOD FROM DEPARTAMENT C WHERE A.SG3=C.KOD),''),
             SG4       = ISNULL((SELECT KOD FROM LISTE       C WHERE A.SG4=C.KOD),'')
        FROM #TempLibraMg A LEFT JOIN ARTIKUJ B ON A.SG2=B.KOD;
                
              
      DELETE FROM #TempLibraMg WHERE ISNULL(SG2,'')='';
                            

   RAISERROR (N' ',0,1) with NoWait;


      INSERT INTO LMG
            (KOD,SG1,SG2,SG3,SG4,SG5,KMON,NRMAG,SASI,VLERE,PERSHKRIM)

      SELECT A.KD, A.SG1, A.SG2, A.SG3, A.SG4, SG5='', KMON='', NRMAG=0, SASI=0, VLERE=0,
             PERSHKRIM =           ISNULL(R1.PERSHKRIM,'')                                      +
                         CASE WHEN ISNULL(A.PERSHKRIM, '')='' THEN '' ELSE '/'+A.PERSHKRIM  END +
                         CASE WHEN ISNULL(R3.PERSHKRIM,'')='' THEN '' ELSE '/'+R3.PERSHKRIM END +
                         CASE WHEN ISNULL(R4.PERSHKRIM,'')='' THEN '' ELSE '/'+R4.PERSHKRIM END
        FROM #TempLibraMg A LEFT JOIN MAGAZINA    R1 ON A.SG1=R1.KOD
                            LEFT JOIN DEPARTAMENT R3 ON A.SG3=R3.KOD
                            LEFT JOIN LISTE       R4 ON A.SG4=R4.KOD
    ORDER BY A.KOD;              
            
              
   RAISERROR (N' ',0,1) with NoWait;




          IF @DoubleKod=1          --    Fshirje te dublikuarave 
             BEGIN
             
               DELETE A
                 FROM LMG A 
                WHERE (SELECT COUNT('KOD') FROM LMG B WHERE A.KOD=B.KOD AND A.NRRENDOR<B.NRRENDOR)>=1;

               RAISERROR (N' ',0,1) with NoWait;
             END;  


          IF @Compact=1            --    Fshirje kode qe nuk kane origjine nga dokumenta (kompaktesimi)
             BEGIN

               UPDATE LMG  SET  TAGNR=0      WHERE ISNULL(TAGNR,0)<>0; 
               UPDATE A    SET  A.TAGNR=101  FROM  LMG A INNER JOIN FHSCR B ON A.KOD=B.KOD; 
               UPDATE A    SET  A.TAGNR=101  FROM  LMG A INNER JOIN FDSCR B ON A.KOD=B.KOD WHERE A.TAGNR=0; 
               DELETE      FROM LMG          WHERE ISNULL(TAGNR,0)<>101; 
               UPDATE LMG  SET  TAGNR=0      WHERE ISNULL(TAGNR,0) =101; 
               
               RAISERROR (N' ',0,1) with NoWait;
             END;



          IF OBJECT_ID('TEMPDB..#TempLibraMg') IS NOT NULL
             DROP TABLE #TempLibraMg;              
              
GO
