SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE          procedure [dbo].[Isd_AQHistoriData]
(
  @pKodKp    VARCHAR(50),
  @pKodKs    VARCHAR(50),
  @pWhere    VARCHAR(MAX)
)

AS

-- EXEC Isd_AQHistoriData 'X01000001','X01000001',''; --'DATEDOK=dbo.DATEVALUE(''31/12/2017'')';
-- Perdoret tek kartela aktivit per afishim te dhena te aktivit ne te dhenat historike (tabsheet-3)
             
         SET NOCOUNT ON;


     DECLARE @sSql          VARCHAR(MAX),
             @sKodKp        Varchar(50),
             @sKodKs        Varchar(50),
             @sWhere        VARCHAR(MAX);    
     
         SET @sKodKp      = ISNULL(@pKodKp,'');
         SET @sKodKs      = ISNULL(@pKodKs,'zzz');
         SET @sWhere      = ISNULL(@pWhere,'');
         
         SET @sSql        = '

      SELECT A.KOD,B.KODAF, A.PERSHKRIM, 
             B.KodOper,B.DateOper, B.NrDok, B.DateDok,
             Vlefte=B.VLERABS,VlereAm=B.VLERAAM,B.NormeAm,
             Perdorim=B.KODPRONESI,EmerPerdorues=B.PERSHKRIMPRONESI, 
             Vend=B.KODLOCATION,PershkrimVend=B.PERSHKRIMLOCATION, KlFurn=B.KODFKL, PershkrimKlFurn=B.PERSHKRIMFKL,
             B.KMon, Kurs = CASE WHEN ISNULL(KURS1,0)*ISNULL(KURS2,0)=0 OR (KURS1=1 AND KURS2=1) THEN '''' 
                                      WHEN KURS1=1                                               THEN CAST(KURS2 AS VARCHAR) 
                                      ELSE CAST(ROUND(KURS2/KURS1,2) AS VARCHAR) 
                                 END,  
             B.VleraFat, B.VleraFatMv, B.VleraExtMv,
             B.Koment, Shenim1=B.Shenim1,B.Shenim2,
          -- B.Kurs1,  B.Kurs2, A.Kategori, PershkrimKTG = R2.PERSHKRIM, A.Grup, PershkrimGRP = R3.PERSHKRIM,
             
             B.Sasi,
             B.Njesi,
             A.TROW, 
             A.TAGNR, 
             A.NRRENDOR
        FROM AQKARTELA A   INNER JOIN  AQHistoriScr  B  ON A.NRRENDOR=B.NRD 
                           LEFT  JOIN  AQKATEGORI    R2 ON R2.KOD=A.KATEGORI
                           LEFT  JOIN  AQGRUP        R3 ON A.GRUP=R3.KOD
                        
       WHERE A.KOD>='''+@sKodKp+''' AND A.KOD<='''+@sKodKs+''' AND 1=1 ';
       

         IF @sWhere<>''
            SET @sSql = Replace(@sSql,'1=1',@sWhere);
   -- PRINT  @sSql;
       EXEC (@sSql);
      
GO
