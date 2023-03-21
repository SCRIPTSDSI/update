SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  VIEW [dbo].[FKSCRZGJ]
AS

SELECT A.NRDOK, 
       A.DATEDOK, 
       A.ORG, 
       A.DST,
       A.TIPDOK, 
       A.NUMDOK, 
       A.REFERDOK,          
       A.NRRENDOR,          -- Kujdes u modifikua 11.06.2016       ishte:   NRRENDOR=B.NRRENDOR 
                            --                                     u be:    NRRENDOR=A.NRRENDOR dhe NRRENDORSCR=B.NRRENDOR
       B.NRD, 
       NRRENDORSCR=B.NRRENDOR, 
       KOD = B.KOD, 
       B.LLOGARIPK, 
       B.KMON, 
       B.KURS1, 
       B.KURS2, 
       B.DB, 
       B.KR, 
       B.DBKRMV, 
       PERSHKRIMFKSCR = B.PERSHKRIM, 
       KOMENT         = ISNULL(A.PERSHKRIM1,'') +
                        CASE WHEN ISNULL(A.PERSHKRIM1,'')='' THEN '' ELSE '-' END + 
                        ISNULL(B.KOMENT,''), 
       B.TREGDK, 
       C.MBARTUR, 
       C.MBARTURMV,
       SG2 = CASE WHEN LTRIM(RTRIM(ISNULL(C.SG2,'')))='' 
                  THEN ISNULL(G.DEP,'')
                  ELSE ISNULL(C.SG2,'') END, 
       SG1 = ISNULL(C.SG1,''), 
       SG3 = ISNULL(C.SG3,''), 
       SG4 = ISNULL(C.SG4,''), 
       SG5 = ISNULL(C.SG5,''), 
       SG6 = ISNULL(C.SG6,''), 
       SG7 = ISNULL(C.SG7,''), 
       SG8 = ISNULL(C.SG8,''), 
       SG9 = ISNULL(C.SG9,''), 
       SG10= ISNULL(C.SG10,''), 
       PERSHKRIMLLG = D.PERSHKRIM, 
       D.SUP, 
       D.NIV, 
       D.KLASA, 
       D.TIPI, 
       D.POZIC, 
       D.AKTPASIV, 
       PERSHKRIMLS = F.PERSHKRIM, 
       SUPL        = F.SUP, 
       NIVL        = F.NIV, 
       POZICL      = F.POZIC,
       KLASIF1L    = F.KLASIFIKIM1,
       KLASIF2L    = F.KLASIFIKIM2,

       PERSHKRIMDP = CASE WHEN LTrim(RTrim(ISNULL(E.PERSHKRIM,'')))='' 
                          THEN H.PERSHKRIM
                          ELSE E.PERSHKRIM END,
       SUPD        = E.SUP,
       NIVD        = E.NIV, 
       POZICD      = E.POZIC,
       KLASIF1D    = E.KLASIFIKIM1,
       KLASIF2D    = E.KLASIFIKIM2,
 
       KODMG       = G.KOD, 
       PERSHKRIMMG = G.PERSHKRIM, 
       NRTIMEDB    = CASE WHEN B.TREGDK='D' THEN 1 ELSE 0 END

 FROM  FK A LEFT JOIN FKSCR B       ON A.NRRENDOR = B.NRD
            LEFT JOIN LM C          ON B.KOD = C.KOD 
            LEFT JOIN LLOGARI D     ON C.SG1 = D.KOD
            LEFT JOIN DEPARTAMENT E ON C.SG2 = E.KOD
            LEFT JOIN LISTE F       ON C.SG3 = F.KOD
            LEFT JOIN MAGAZINA G    ON C.SG4 = G.KOD
            LEFT JOIN DEPARTAMENT H ON G.DEP = H.KOD
GO
