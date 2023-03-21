SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE       VIEW [dbo].[QFJAFPAG] AS

      SELECT DATEDOK,
             NRDOK,
             KOD         = FJ.KOD,
             KODFKL,
             SHENIM1,
             KMON        = ISNULL(FJ.KMON,''),
             NRFAT       = NRDSHOQ,
             DTFAT       = ISNULL(DTDSHOQ,DATEDOK),
             NRDITAR,
             TIPDOK      = 'FJ',
             DTAF        = ISNULL(DTAF,ISNULL(KLIENT.AFAT,0)),        
             DTPAGESE    = ISNULL(DTDSHOQ,DATEDOK)+
                           ISNULL(DTAF,ISNULL(KLIENT.AFAT,0)),
             VLERTOT,
             VLERTOTMB   = VLERTOT*KURS2/KURS1
        FROM FJ INNER JOIN KLIENT ON FJ.KODFKL=KLIENT.KOD
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
             TIPDOK      = 'FJ',
             DTAF        = ISNULL(OPERNR,0),
             DTPAGESE    = ISNULL(DATEDOKREF,VS.DATEDOK)+ISNULL(OPERNR,0),
             VLERTOT     = DB-KR,
             VLERTOTMB   = DBKRMV
        FROM VSSCR INNER JOIN VS ON VSSCR.NRD=VS.NRRENDOR
       WHERE VSSCR.TIPKLL='S'


GO
