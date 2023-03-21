SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE       VIEW [dbo].[QFFAFPAG] AS

      SELECT DATEDOK,
             NRDOK,
             KOD         = FF.KOD,
             KODFKL,
             SHENIM1,
             KMON        = ISNULL(FF.KMON,''),
             NRFAT       = NRDSHOQ,
             DTFAT       = ISNULL(DTDSHOQ,DATEDOK),
             NRDITAR,
             TIPDOK      = 'FF',
             DTAF        = ISNULL(DTAF,ISNULL(FURNITOR.AFAT,0)),        
             DTPAGESE    = ISNULL(DTDSHOQ,DATEDOK)+
                           ISNULL(DTAF,ISNULL(FURNITOR.AFAT,0)),
             VLERTOT,
             VLERTOTMB   = VLERTOT*KURS2/KURS1
        FROM FF INNER JOIN FURNITOR ON FF.KODFKL=FURNITOR.KOD
   UNION ALL
      SELECT DATEDOK     = ISNULL(DATEDOKREF,VS.DATEDOK),
             VS.NRDOK,
             VSSCR.KOD,
             VSSCR.LLOGARIPK,
             VSSCR.PERSHKRIM,
             VSSCR.KMON,
             NRFAT       = ISNULL(NRDOKREF,0),
             DTFAT       = ISNULL(DATEDOKREF,VS.DATEDOK),
             VSSCR.NRDITAR,
             TIPDOK      = 'FF',
             DTAF        = ISNULL(OPERNR,0),
             DTPAGESE    = ISNULL(DATEDOKREF,VS.DATEDOK)+ISNULL(OPERNR,0),
             VLERTOT     = DB-KR,
             VLERTOTMB   = DBKRMV
        FROM VSSCR INNER JOIN VS ON VSSCR.NRD=VS.NRRENDOR
       WHERE VSSCR.TIPKLL='F'


GO
