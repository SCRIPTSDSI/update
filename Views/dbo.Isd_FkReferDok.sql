SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO





CREATE   VIEW [dbo].[Isd_FkReferDok] 

AS

--  SELECT TOP 100 *,NRRENDOR=0,TROW=CAST(0 As Bit)
--    FROM
--  (  
       SELECT KOD       = A.REFERDOK,
              PERSHKRIM = 'FJ:  '+MAX(B.PERSHKRIM),
              ORG       = A.ORG,
              NRRENDOR  = 0,
              TROW      = CAST(0 As Bit)
         FROM FK A LEFT JOIN KLIENT B ON A.REFERDOK=B.KOD
        WHERE A.ORG='S'
     GROUP BY A.REFERDOK,A.ORG

    UNION ALL

       SELECT KOD       = A.REFERDOK,
              PERSHKRIM = 'FF:  '+MAX(B.PERSHKRIM),
              ORG       = A.ORG,
              NRRENDOR  = 0,
              TROW      = CAST(0 As Bit)
         FROM FK A LEFT JOIN FURNITOR B ON A.REFERDOK=B.KOD
        WHERE A.ORG='F'
     GROUP BY A.REFERDOK,A.ORG

    UNION ALL

       SELECT KOD       = A.REFERDOK,
              PERSHKRIM = 'AR:  '+MAX(B.PERSHKRIM),
              ORG       = A.ORG,
              NRRENDOR  = 0,
              TROW      = CAST(0 As Bit)
         FROM FK A LEFT JOIN ARKAT B ON A.REFERDOK=B.KOD
        WHERE A.ORG='A'
     GROUP BY A.REFERDOK,A.ORG

    UNION ALL

       SELECT KOD       = A.REFERDOK,
              PERSHKRIM = 'BA:  '+MAX(B.PERSHKRIM),
              ORG       = A.ORG,
              NRRENDOR  = 0,
              TROW      = CAST(0 As Bit)
         FROM FK A LEFT JOIN BANKAT B ON A.REFERDOK=B.KOD
        WHERE A.ORG='B'
     GROUP BY A.REFERDOK,A.ORG

    UNION ALL

       SELECT KOD       = A.REFERDOK,
              PERSHKRIM = 'MG:  '+MAX(B.PERSHKRIM),
              ORG       = 'M',
              NRRENDOR  = 0,
              TROW      = CAST(0 As Bit)
         FROM FK A LEFT JOIN MAGAZINA B ON A.REFERDOK=B.KOD
        WHERE A.ORG='H' OR A.ORG='D'
     GROUP BY A.REFERDOK

    UNION ALL

       SELECT KOD       = A.REFERDOK,
              PERSHKRIM = 'DG:  '+MAX(B.PERSHKRIM),
              ORG       = A.ORG,
              NRRENDOR  = 0,
              TROW      = CAST(0 As Bit)
         FROM FK A LEFT JOIN FURNITOR B ON A.REFERDOK=B.KOD 
        WHERE A.ORG='G' 
     GROUP BY A.REFERDOK,A.ORG

    UNION ALL

       SELECT KOD       = A.REFERDOK,
              PERSHKRIM = 'AQ:  '+MAX(A.PERSHKRIM1),
              ORG       = A.ORG,
              NRRENDOR  = 0,
              TROW      = CAST(0 As Bit)
         FROM FK A 
        WHERE A.ORG='Q' OR A.ORG='X' 
     GROUP BY A.REFERDOK,A.ORG
     
     
     
--   ) A
--
--     ORDER BY ORG,KOD
--

/*
   SELECT DISTINCT 
          KOD       = REFERDOK,
          PERSHKRIM = CASE WHEN ORG='A'            THEN 'AR - ' + A1.PERSHKRIM
                           WHEN ORG='B'            THEN 'BA - ' + A2.PERSHKRIM
                           WHEN ORG='H' OR ORG='D' THEN 'MG - ' + A3.PERSHKRIM
                           WHEN ORG='F'            THEN 'BL - ' + A5.PERSHKRIM
                           WHEN ORG='S'            THEN 'FJ - ' + A6.PERSHKRIM
                           WHEN ORG='G'            THEN 'DG - Dokument Dogane'
                           WHEN ORG='E'            THEN 'VS - Dokument Nd.mod'
                           WHEN ORG='T'            THEN 'FK - Dokument DP'
                           WHEN ORG<>''            THEN 'Dokument ......' 
                       END,
          NRRENDOR  = 0,
          TROW      = 0 
     FROM FK A LEFT JOIN ARKAT    A1 ON A.REFERDOK = A1.KOD AND A.ORG='A' 
               LEFT JOIN BANKAT   A2 ON A.REFERDOK = A2.KOD AND A.ORG='B' 
               LEFT JOIN MAGAZINA A3 ON A.REFERDOK = A3.KOD AND (A.ORG='H' OR A.ORG='D') 
               LEFT JOIN FURNITOR A5 ON A.REFERDOK = A5.KOD AND A.ORG='F' 
               LEFT JOIN KLIENT   A6 ON A.REFERDOK = A6.KOD AND A.ORG='S' 
    WHERE ISNULL(REFERDOK,'')<>''
 ORDER BY ORG,PERSHKRIM
*/




GO
