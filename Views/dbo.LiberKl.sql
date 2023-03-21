SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO







CREATE   VIEW [dbo].[LiberKl] 

AS
 
      SELECT -- TOP 100 PERCENT 
            
			 A.KOD,A.PERSHKRIM,A.KOMENT,A.KMON,A.KURS1,A.KURS2,A.VLEFTA,A.VLEFTAMV,
		     A.TIPDOK,A.NRDOK,A.FRAKSDOK,A.DATEDOK,A.TIPFAT,A.NRFAT,A.DTFAT,
			 A.TREGDK,A.TIPKLL,A.ISDOKSHOQ,A.KODMASTER,A.ORG,A.LLOJDOK,A.KODREF,
			 A.ORDERTD,A.NRRENDORDOK,A.TRANNUMBER,A.NRLIBER,A.NRDITAR,A.NRRENDOR,A.TROW,A.TAGNR,

		     A.DET1,A.DET2,A.DET3,A.DET4,A.DET5,

			 KODAN              = ISNULL(B.KOD,'')+'.'+ISNULL(A.DET1,'')+'.'+ISNULL(A.DET2,'')+'.'+ISNULL(A.DET3,'')+'.'+ISNULL(A.KMON,''),
			 PERSHKRIMAN        = A.PERSHKRIM + CASE WHEN ISNULL(A.DET1,'')<>'' THEN '/'+ISNULL(R1.PERSHKRIM,'') ELSE '' END+
			                                    CASE WHEN ISNULL(A.DET2,'')<>'' THEN '/'+ISNULL(R2.PERSHKRIM,'') ELSE '' END+
                                                CASE WHEN ISNULL(A.DET3,'')<>'' THEN '/'+ISNULL(R3.PERSHKRIM,'') ELSE '' END,
             KODRF              = B.KOD,
             PERSHKRIMRF        = ISNULL(B.PERSHKRIM,''),
             LLOGARIRF          = ISNULL(B.LLOGARI,''),
             DEPRF              = ISNULL(B.DEP,''),
             LISTERF            = ISNULL(B.LISTE,''),
             NIPTRF             = ISNULL(B.NIPT,''),
             KMAGRF             = ISNULL(B.KMAG,''),
             KMONRF             = ISNULL(B.KMON,''),
             AFATRF             = ISNULL(B.AFAT,0),
             MODPGRF            = ISNULL(B.MODPG,''),
             KLASIFIKIM1RF      = ISNULL(B.KLASIFIKIM1,''),
             KLASIFIKIM2RF      = ISNULL(B.KLASIFIKIM2,''),
             KLASIFIKIM3RF      = ISNULL(B.KLASIFIKIM3,''),
             KLASIFIKIM4RF      = ISNULL(B.KLASIFIKIM4,''),
             KLASIFIKIM5RF      = ISNULL(B.KLASIFIKIM5,''),
             KLASIFIKIM6RF      = ISNULL(B.KLASIFIKIM6,''),
             VENDHUAJRF         = ISNULL(B.VENDHUAJ,''),
             GRUPRF             = ISNULL(B.GRUP,''),
             KATEGORIRF         = ISNULL(B.KATEGORI,''),
             VENDNDODHJERF      = ISNULL(B.VENDNDODHJE,''),
             RAJONRF            = ISNULL(B.RAJON,''),
             AGJENTSHITJERF     = ISNULL(B.AGJENTSHITJE,''),
             KODLINKKFRF        = ISNULL(B.KODLINKKF,''),
             LINKKLIENTRF       = ISNULL(B.LINKKLIENT,''),
             TELEFON1RF         = ISNULL(B.TELEFON1,''),
             TELEFON2RF         = ISNULL(B.TELEFON2,''),
             
             KREDIRF            = ISNULL(B.KREDI,0),
             APLKREDILIMRF      = ISNULL(B.APLKREDILIM,0),
             KREDIWARNINGRF     = ISNULL(B.KREDIWARNING,0),
             KOMENTRF           = ISNULL(B.KOMENT,''),
             KOMENTACTIVRF      = ISNULL(B.KOMENTACTIV,''),
             BLOCKDTRF          = ISNULL(B.BLOCKDT,0),
             
             NRORDERDTFAT       = Row_Number() OVER (PARTITION BY B.Kod ORDER BY B.Kod,ISNULL(A.DTFAT,A.DATEDOK)),
             NOTACTIVRF         = ISNULL(B.NOTACTIV,0)
             
        FROM DKL A INNER JOIN KLIENT B ON CASE WHEN CHARINDEX('.',A.KOD)<>0 THEN LEFT(A.KOD,CHARINDEX('.',A.KOD)-1) ELSE A.KOD END = B.KOD
		           LEFT  JOIN DEPARTAMENT R1 ON ISNULL(A.DET1,'')=ISNULL(R1.KOD,'')
				   LEFT  JOIN LISTE       R2 ON ISNULL(A.DET2,'')=ISNULL(R2.KOD,'')
				   LEFT  JOIN MAGAZINA    R3 ON ISNULL(A.DET3,'')=ISNULL(R3.KOD,'')

 -- ORDER BY KMON,DKODRF

 
 

GO
