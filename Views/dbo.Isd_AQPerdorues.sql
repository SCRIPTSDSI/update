SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE View [dbo].[Isd_AQPerdorues]  

AS

       SELECT A.*,
           -- KODMASTER   = '', TIPMASTER = '', REFORDER = CASE WHEN ISNULL(NOTACTIV,0)=1 AND ListRefNotActiv=1 THEN 'z' ELSE '' END, 
           -- NRROW       = ROW_NUMBER() OVER(PARTITION BY A.GRUP ORDER BY CASE WHEN ISNULL(A.NOTACTIV,0)=1 AND B.ListRefNotActiv=1 THEN 'z' ELSE '' END, A.KOD),
              TAGNR       = 0,
              TROW        = CAST(CASE WHEN ROW_NUMBER() OVER(PARTITION BY A.GRUP ORDER BY CASE WHEN ISNULL(A.NOTACTIV,0)=1 AND B.ListRefNotActiv=1 THEN 'z' ELSE '' END, A.KOD)=1 
                                      THEN 1 
                                      ELSE 0 
                                 END AS BIT)
         FROM
      (  
       SELECT KOD,PERSHKRIM,REFERENCE='PERSONEL',     GRUP=100,NRRENDOR=NRRENDOR+010000,NOTACTIV FROM PERSONEL
    UNION ALL   
       SELECT KOD,PERSHKRIM,REFERENCE='LISTE',        GRUP=200,NRRENDOR=NRRENDOR+020000,NOTACTIV FROM LISTE
    UNION ALL
       SELECT KOD,PERSHKRIM,REFERENCE='DEPARTAMENT',  GRUP=300,NRRENDOR=NRRENDOR+030000,NOTACTIV FROM DEPARTAMENT
    UNION ALL
       SELECT KOD,PERSHKRIM,REFERENCE='AQVENDNDODHJE',GRUP=400,NRRENDOR=NRRENDOR+040000,NOTACTIV FROM AQVENDNDODHJE
    UNION ALL
       SELECT KOD,PERSHKRIM,REFERENCE='MAGAZINA',     GRUP=500,NRRENDOR=NRRENDOR+050000,NOTACTIV FROM MAGAZINA
    UNION ALL
       SELECT KOD,PERSHKRIM,REFERENCE='KLIENT',       GRUP=600,NRRENDOR=NRRENDOR+060000,NOTACTIV FROM KLIENT
    UNION ALL
       SELECT KOD,PERSHKRIM,REFERENCE='FURNITOR',     GRUP=700,NRRENDOR=NRRENDOR+070000,NOTACTIV FROM FURNITOR

       ) A, CONFND B
       
-- ORDER BY GRUP,REFORDER,KOD       


GO
