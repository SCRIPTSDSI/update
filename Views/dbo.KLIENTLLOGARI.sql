SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO






CREATE                        VIEW [dbo].[KLIENTLLOGARI] AS 

SELECT FJ.DATEDOK, FJ.NRDOK,FJ.NRDSHOQ,FJ.DTDSHOQ,FJ.KMON, FJ.KODFKL,FJ.SHENIM1,FJ.KMAG,
       TIPDOK    ='FJ',
       KARTLLG   =CASE WHEN FJSCR.TIPKLL='L' THEN FJSCR.KARTLLG
                       ELSE SKEMELM.LLOGSH END,
       KODART    =FJSCR.KARTLLG,
       CMIMBS,FJSCR.NJESI,
       SASISH    =FJSCR.SASI,
       VLPATVSHSH=FJSCR.VLPATVSH,
       VLTVSHSH  =FJSCR.VLTVSH,
       VLERAMSH  =VLERAM,
       VLERABSSH =VLERABS,
       FJSCR.KOD,
       KLASIF=ISNULL(ARTIKUJ.KLASIF,''),KLASIF2=ISNULL(ARTIKUJ.KLASIF2,''),KLASIF3=ISNULL(ARTIKUJ.KLASIF3,''),
       SG4='',KLIENT.VENDNDODHJE,KLASIFIKIM=ISNULL(FJ.KLASIFIKIM,''),KLIENT.AGJENTSHITJE

    FROM  FJ LEFT JOIN FJSCR   ON FJ.NRRENDOR  = FJSCR.NRD
             LEFT JOIN KLIENT  ON FJ.KODFKL    = KLIENT.KOD
             LEFT JOIN ARTIKUJ ON FJSCR.KARTLLG= ARTIKUJ.KOD
             LEFT JOIN SKEMELM ON ARTIKUJ.KODLM= SKEMELM.KOD
UNION ALL

SELECT FJ.DATEDOK, FJ.NRDOK,FJ.NRDSHOQ,FJ.DTDSHOQ,FJ.KMON, FJ.KODFKL,FJ.SHENIM1,FJ.KMAG,
       TIPDOK    = 'FJ',
       KARTLLG   = CASE WHEN FJSCR.TIPFR='A' THEN ARTIKUJFIR.LLOGARIA
                        WHEN FJSCR.TIPFR='B' THEN ARTIKUJFIR.LLOGARIB 
                        WHEN FJSCR.TIPFR='C' THEN ARTIKUJFIR.LLOGARIC 
                        WHEN FJSCR.TIPFR='D' THEN ARTIKUJFIR.LLOGARID 
                        ELSE '' END,
       FJSCR.KARTLLG,
       CMIMBS,FJSCR.NJESI,
       SASISH    =FJSCR.SASIFR,
       VLPATVSHSH=(-1)*FJSCR.VLERAFR,
       VLTVSHSH  =0,
       VLERAMSH  =(-1)*VLERAFR,
       VLERABSSH =(-1)*VLERAFR,
       FJSCR.KOD,
       KLASIF=ISNULL(ARTIKUJ.KLASIF,''),KLASIF2=ISNULL(ARTIKUJ.KLASIF2,''),KLASIF3=ISNULL(ARTIKUJ.KLASIF3,''),
       SG4='',KLIENT.VENDNDODHJE,ISNULL(FJ.KLASIFIKIM,''),KLIENT.AGJENTSHITJE

    FROM  FJ LEFT  JOIN FJSCR      ON FJ.NRRENDOR       = FJSCR.NRD
             LEFT  JOIN KLIENT     ON FJ.KODFKL         = KLIENT.KOD
             INNER JOIN ARTIKUJ    ON FJSCR.KARTLLG     = ARTIKUJ.KOD
             INNER JOIN ARTIKUJFIR ON ARTIKUJ.NRRENDOR  = ARTIKUJFIR.NRD


























GO