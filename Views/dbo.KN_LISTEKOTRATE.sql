SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO










CREATE      VIEW [dbo].[KN_LISTEKOTRATE] AS 
SELECT TOP 100 PERCENT KONTRATA.NRRENDOR,NRDOK,REFERENCE,KODFKL,KONTRATA.PERSHKRIM,DTFILLIM,DTFUND,
       DTFM01=CASE WHEN DTFILLIM>DTFATURE           THEN DTFILLIM          ELSE DTFATURE END,
       DTFM02=CASE WHEN DATEADD(mm, 1*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm, 1*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM03=CASE WHEN DATEADD(mm, 2*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm, 2*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM04=CASE WHEN DATEADD(mm, 3*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm, 3*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM05=CASE WHEN DATEADD(mm, 4*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm, 4*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM06=CASE WHEN DATEADD(mm, 5*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm, 5*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM07=CASE WHEN DATEADD(mm, 6*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm, 6*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM08=CASE WHEN DATEADD(mm, 7*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm, 7*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM09=CASE WHEN DATEADD(mm, 8*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm, 8*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM10=CASE WHEN DATEADD(mm, 9*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm, 9*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM11=CASE WHEN DATEADD(mm,10*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm,10*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM12=CASE WHEN DATEADD(mm,11*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm,11*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,

       DTFM13=CASE WHEN DATEADD(mm,12*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm,12*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM14=CASE WHEN DATEADD(mm,13*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm,13*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM15=CASE WHEN DATEADD(mm,14*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm,14*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM16=CASE WHEN DATEADD(mm,15*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm,15*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM17=CASE WHEN DATEADD(mm,16*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm,16*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM18=CASE WHEN DATEADD(mm,17*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm,17*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM19=CASE WHEN DATEADD(mm,18*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm,18*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM20=CASE WHEN DATEADD(mm,19*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm,19*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM21=CASE WHEN DATEADD(mm,20*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm,20*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM22=CASE WHEN DATEADD(mm,21*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm,21*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM23=CASE WHEN DATEADD(mm,22*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm,22*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM24=CASE WHEN DATEADD(mm,23*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm,23*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,

       DTFM25=CASE WHEN DATEADD(mm,24*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm,24*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM26=CASE WHEN DATEADD(mm,25*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm,25*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM27=CASE WHEN DATEADD(mm,26*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm,26*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM28=CASE WHEN DATEADD(mm,27*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm,27*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM29=CASE WHEN DATEADD(mm,28*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm,28*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM30=CASE WHEN DATEADD(mm,29*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm,29*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM31=CASE WHEN DATEADD(mm,30*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm,30*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM32=CASE WHEN DATEADD(mm,31*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm,31*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM33=CASE WHEN DATEADD(mm,32*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm,32*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM34=CASE WHEN DATEADD(mm,33*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm,33*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM35=CASE WHEN DATEADD(mm,34*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm,34*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,
       DTFM36=CASE WHEN DATEADD(mm,35*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END)>=DTFUND THEN DTFILLIM ELSE DATEADD(mm,35*PERIUDHA,CASE WHEN DTFILLIM>DTFATURE THEN DTFILLIM ELSE DTFATURE END) END,

       PERIUDHA,KMON,KURS1,KURS2,
       KOD,PERSHKRIMSH=KONTRATASCR.PERSHKRIM,CMIM,SASI=PERIUDHA,FIRSTFAT,ARDHSHTYRE 
FROM  KONTRATA INNER JOIN KONTRATASCR ON KONTRATA.NRRENDOR=KONTRATASCR.NRD
WHERE KONTRATA.NOTACTIV=0
ORDER BY KONTRATA.NRRENDOR






GO