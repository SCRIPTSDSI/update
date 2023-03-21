SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE        procedure [dbo].[Isd_ArtikujPlanProdhim2]
(
  @pKodLpKp         Varchar(60),
  @pKodLpKs         Varchar(60),
  @pKodPrKp         Varchar(60),
  @pKodPrKs         Varchar(60)
)

AS

-- EXEC dbo.Isd_ArtikujPlanProdhim2 'P1','P9z','P1','P9z'

         SET NOCOUNT ON

          IF OBJECT_ID('TEMPDB..#ListArtikujProducts') IS NOT NULL
             DROP TABLE #ListArtikujProducts;
             
             

      SELECT NR=1,                                                               
             KOD=MAX(A.KOD),PERSHKRIM=MAX(A.PERSHKRIM),KOEFICIENT=1,KODLP=MAX(A.KOD),TIPROW=0,TROW=CAST(1 AS BIT)
             
        INTO #ListArtikujProducts
             
        FROM ARTIKUJSCR A INNER JOIN ARTIKUJ B ON A.NRD=B.NRRENDOR 
       WHERE A.KOD>=@pKodLpKp AND A.KOD<=@pKodLpKs AND B.KOD>=@pKodPrKp AND B.KOD<=@pKodPrKs
    GROUP BY A.KOD   
    
   UNION ALL
   
      SELECT NR=ROW_NUMBER() OVER (PARTITION BY A.KOD ORDER BY A.KOD,B.KOD) + 1, 
             KOD=B.KOD,PERSHKRIM=B.PERSHKRIM,A.KOEFICIENT,KODLP1=A.KOD,TIPROW=0,TROW=CAST(0 AS BIT) 
        FROM ARTIKUJSCR A INNER JOIN ARTIKUJ B ON A.NRD=B.NRRENDOR 
       WHERE B.KOD>=@pKodLpKp AND B.KOD<=@pKodLpKs AND B.KOD>=@pKodPrKp AND B.KOD<=@pKodPrKs
    
    ORDER BY KOD,NR;
    
    
        
        
-- Shtohen produkte qe skane lende te pare si detaje, por jane vete te tille

      INSERT INTO #ListArtikujProducts
            (NR,KOD,PERSHKRIM,KOEFICIENT,KODLP,TIPROW,TROW)
            
      SELECT NR=1,KOD=B.KOD,PERSHKRIM=B.PERSHKRIM,KOEFICIENT=1,KODLP=B.KOD,TIPROW=0,TROW=CAST(1 AS BIT) 
        FROM ARTIKUJ B 
       WHERE B.KOD>=@pKodPrKp AND B.KOD<=@pKodPrKs AND 
             B.TIP='P' AND (NOT EXISTS (SELECT KOD FROM #ListArtikujProducts C WHERE B.KOD=C.KOD))      
    ORDER BY B.KOD;
    
    
    
    
      SELECT NR,KOD,PERSHKRIM,KOEFICIENT,KODLP,TIPROW,TROW
        FROM #ListArtikujProducts 
    ORDER BY KOD,NR;
       

          IF OBJECT_ID('TEMPDB..#ListArtikujProducts') IS NOT NULL
             DROP TABLE #ListArtikujProducts;

    
    
GO
