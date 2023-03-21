SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE      VIEW [dbo].[QARTIKUJSCR]

AS


      SELECT NRRENDOR,     
             NRD,      
             KOD,      
             PERSHKRIM,  
             KODPR, 
             NJESI,        
             KOSTMES,  
             QKOSTO          = '.'+A.DEP+'.'+A.LISTE,
             QKODAF          = CASE WHEN A.DEP<>'' AND A.LISTE<>'' THEN '.' +A.DEP+'.'+A.LISTE
                                    WHEN A.DEP<>''                 THEN '.' +A.DEP
                                    WHEN A.LISTE<>''               THEN '..'+A.LISTE
                                    ELSE '' 
                               END,
             AUTOSHKLPFJ     = ISNULL(AUTOSHKLPFJ,0), 
             AUTOSHKLPFDBR   = ISNULL(AUTOSHKLPFDBR,0), 
             KOEFICIENT      = ISNULL(KOEFICIENT,0), 
             KOEFICPERB      = ISNULL(KOEFICPERB,0)

        FROM 
            ( SELECT A.NRRENDOR,   
                     A.NRD,   
                     A.KOD,    
                     A.PERSHKRIM, 
                     A.KOEFICIENT, 
                     B.NJESI, 
                     B.KOSTMES,
                     DEP             = dbo.Isd_SegmentFind(ISNULL(A.QKOSTO,''),0,1),
                     LISTE           = dbo.Isd_SegmentFind(ISNULL(A.QKOSTO,''),0,2),
                     KODPR           = C.KOD, 
                     AUTOSHKLPFJ     = C.AUTOSHKLPFJ, 
                     AUTOSHKLPFDBR   = C.AUTOSHKLPFDBR, 
                     KOEFICPERB      = C.KOEFICPERB
                FROM ARTIKUJSCR A INNER JOIN ARTIKUJ B ON A.KOD = B.KOD
                                  INNER JOIN ARTIKUJ C ON C.NRRENDOR = A.NRD
              )   A ;
                                  

/*
SELECT  NRRENDOR,     NRD,      KOD,      PERSHKRIM,  KODPR, 
        NJESI,        KOSTMES,  
      --QKOSTO = ISNULL('.'+A.QKOSTO,''),
        QKOSTO        = '.'+QDEP+'.'+QLISTE,
        QKODAF        = CASE WHEN QDEP<>'' AND QLISTE<>'' THEN '.'+QDEP+'.'+QLISTE
                             WHEN QDEP<>''                THEN '.'+QDEP
                             WHEN QLISTE<>''              THEN '..'+QLISTE
                             ELSE '' END,
        AUTOSHKLPFJ   = ISNULL(AUTOSHKLPFJ,0), 
        AUTOSHKLPFDBR = ISNULL(AUTOSHKLPFDBR,0), 
        KOEFICIENT    = ISNULL(KOEFICIENT,0), 
        KOEFICPERB    = ISNULL(KOEFICPERB,0)

     -- Komentuar per rastet me koeficient 0, 21.01.2014
     -- KOEFICIENT    = CASE WHEN ISNULL(KOEFICIENT,0)=0 THEN 1 ELSE KOEFICIENT END, 
     -- KOEFICPERB    = CASE WHEN ISNULL(KOEFICPERB,0)=0 THEN 1 ELSE KOEFICPERB END

   FROM 
(SELECT A.NRRENDOR,   A.NRD,   A.KOD,    A.PERSHKRIM, 
        A.KOEFICIENT, B.NJESI, B.KOSTMES,
      --QKOSTO = ISNULL('.'+A.QKOSTO,'') ,
        QDEP          = dbo.Isd_SegmentFind(ISNULL(A.QKOSTO,''),0,1),
        QLISTE        = dbo.Isd_SegmentFind(ISNULL(A.QKOSTO,''),0,2),
        KODPR         = C.KOD, 
        AUTOSHKLPFJ   = C.AUTOSHKLPFJ, 
        AUTOSHKLPFDBR = C.AUTOSHKLPFDBR, 
        KOEFICPERB    = C.KOEFICPERB
--      KODPR         = (SELECT KOD           FROM ARTIKUJ WHERE ARTIKUJ.NRRENDOR=A.NRD), 
--      AUTOSHKLPFJ   = (SELECT AUTOSHKLPFJ   FROM ARTIKUJ WHERE ARTIKUJ.NRRENDOR=A.NRD), 
--      AUTOSHKLPFDBR = (SELECT AUTOSHKLPFDBR FROM ARTIKUJ WHERE ARTIKUJ.NRRENDOR=A.NRD), 
--      KOEFICPERB    = (SELECT KOEFICPERB    FROM ARTIKUJ WHERE ARTIKUJ.NRRENDOR=A.NRD)
   FROM ARTIKUJSCR A INNER JOIN ARTIKUJ B ON A.KOD = B.KOD
                     INNER JOIN ARTIKUJ C ON C.NRRENDOR = A.NRD) A
*/

GO
