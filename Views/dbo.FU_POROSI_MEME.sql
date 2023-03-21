SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO




CREATE  VIEW [dbo].[FU_POROSI_MEME] AS 

SELECT NRRENDOR=MAX(ORF.NRRENDOR),DATEDOK=MAX(ORF.DATEDOK),NRDOK=MAX(ORF.NRDOK),KODFKL=MAX(ORF.KODFKL),
       SHENIM1=MAX(ORF.SHENIM1),NRDSHOQ=MAX(FF.NRDSHOQ),DTDSHOQ=MAX(FF.DTDSHOQ),
       KMON=MAX(ORF.KMON),KURS1=MAX(FF.KURS1),KURS2=MAX(FF.KURS2),NRRENDOROR=ORF.NRDFTEXTRA,
       FFSCR.KARTLLG,PERSHKRIM=MAX(FFSCR.PERSHKRIM),NJESI=MAX(FFSCR.NJESI),SASI=SUM(FFSCR.SASI),
       CMIMBS=CASE WHEN SUM(FFSCR.SASI)<>0 THEN SUM(FFSCR.VLPATVSH)/SUM(FFSCR.SASI) ELSE 1 END,
       VLPATVSH=SUM(FFSCR.VLPATVSH),VLTVSH=SUM(FFSCR.VLTVSH),VLERABS=SUM(FFSCR.VLERABS),FFSCR.TIPKLL
FROM ORF INNER JOIN FF    ON FF.NRRENDOROR=ORF.NRRENDOR 
         INNER JOIN FFSCR ON FF.NRRENDOR=FFSCR.NRD
WHERE ISNULL(FF.NRRENDOROR,0)<>0
GROUP BY ORF.NRDFTEXTRA,FFSCR.KARTLLG,FFSCR.TIPKLL






GO