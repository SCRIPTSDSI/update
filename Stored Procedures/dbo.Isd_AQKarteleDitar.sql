SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE    PROCEDURE [dbo].[Isd_AQKarteleDitar]
(
  @pKodKp    VARCHAR(50),
  @pKodKs    VARCHAR(50),
  @pWhere    VARCHAR(MAX)
 )

AS

-- EXEC Isd_AQKarteleDitar '','zzzz','';

         SET NOCOUNT ON
         
     DECLARE @sSql          VARCHAR(MAX),
             @sKodKp        Varchar(50),
             @sKodKs        Varchar(50),
             @sWhere        VARCHAR(MAX);    
     
         SET @sKodKp      = ISNULL(@pKodKp,'');
         SET @sKodKs      = ISNULL(@pKodKs,'zzz');
         SET @sWhere      = ISNULL(@pWhere,'');
         
         SET @sSql        = '

      SELECT B.KODAF, B.PERSHKRIM,
             B.KODOPER, B.DATEOPER, B.VLERABS, B.VLERAAM, B.NORMEAM,
             KodPerdorues = B.KODPRONESI,
             Perdorues    = B.PERSHKRIMPRONESI,
             KodVend      = B.KODLOCATION, 
             Vendodhje    = B.PERSHKRIMLOCATION,
             A.NRDOK, A.DATEDOK,Fature=A.DOK_JB,   --  A.DST, 
             A.SHENIM1,A.SHENIM2,
             
             KATEGORI     = R1.KATEGORI,
             PERSHKRIMKTG = R2.PERSHKRIM,
             GRUP         = R1.GRUP,
             PERSHKRIMGRP = R3.PERSHKRIM,
             B.VLERAFAT,B.KMON,B.VLERAFATMV,B.VLERAEXTMV,B.KURS1,B.KURS2,
             B.SASI,
             B.NJESI,
             A.TROW, 
             A.TAGNR, 
             A.NRRENDOR
        FROM AQ   A   INNER JOIN  AQSCR      B  ON A.NRRENDOR=B.NRD 
                      INNER JOIN  AQKARTELA  R1 ON B.KARTLLG=R1.KOD
                      LEFT  JOIN  AQKATEGORI R2 ON R2.KOD=R1.KATEGORI
                      LEFT  JOIN  AQGRUP     R3 ON R1.GRUP=R3.KOD
                        
       WHERE B.KODAF>='''+@sKodKp+''' AND B.KODAF<='''+@sKodKs+''' AND 1=1 
    ORDER BY B.KODAF,B.DATEOPER';
       

         IF @sWhere<>''
            SET @sSql = Replace(@sSql,'1=1',@sWhere);
            
            
       EXEC (@sSql);







GO
