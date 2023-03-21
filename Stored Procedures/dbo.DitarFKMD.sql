SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE     procedure [dbo].[DitarFKMD]
(
  @D1 VarChar(20),
  @D2 VarChar(20),
  @N1 BigInt,
  @N2 BigInt,
  @O1 VarChar(2),
  @O2 VarChar(2),
  @O3 VarChar(2),
  @O4 VarChar(2),
  @T1 VarChar(20),
  @T2 VarChar(20),
  @U1 BigInt,
  @U2 BigInt,
  @R1 VarChar(20),
  @R2 VarChar(20),
  @S1 VarChar(20),
  @S2 VarChar(20)
)
AS

      SELECT RK          = 'K', 
             FK.NRDFK,
             KOMENT      = FK.PERSHKRIM1,
             PERSHKRIM   = ISNULL(FK.REFERDOK,'')+':'+ISNULL(FK.PERSHKRIM2,''),
             NRDATE      = RTRIM(Convert(Char(8), DATEDOK,4))+', '+Right(REPLICATE('0',8)+RTRIM(CONVERT(Char,NRDOK)),8),
             FK.DATEDOK, 
             FK.ORG, 
             KOD         = '',
             DBKRMV      = 0,
             ORDPOST     = 0, 
             PROMPTTD    = ISNULL(FK.TIPDOK,' '),
             PROMPTOR    = FK.ORG,
             PROMPTMB    = ' ',
             PROMPTDB    = ' ',
             PROMPTKR    = ' ',
             ORDDOK      = CASE WHEN (FK.ORG='H' OR FK.ORG='D') THEN '2' ELSE '0' END, 
             NRDFKM      = CASE WHEN (FK.ORG='H' OR FK.ORG='D') AND ISNULL(QDITARNRDFKMD.NRDFKMASTER,0)<>0 
                                THEN QDITARNRDFKMD.NRDFKMASTER 
                                ELSE FK.NRRENDOR 
                           END,
             PROMPTFK    = ISNULL(FK.TIPDOK,'')+'   '+ISNULL(FK.REFERDOK,'')+' :   '+
                           RTRIM(CONVERT(CHAR(8), DATEDOK,4))+' / '+RTRIM(CONVERT(CHAR,FK.NUMDOK))+
                           CASE WHEN ISNULL(FK.PERSHKRIM1,'')<>'' THEN '  - '+ISNULL(FK.PERSHKRIM1,'') ELSE '' END

        FROM FK LEFT JOIN QDITARNRDFKMD  ON FK.NRRENDOR=QDITARNRDFKMD.NRDFKDETAIL
       WHERE (DATEDOK>=DBO.DATEVALUE(@D1) AND DATEDOK<=DBO.DATEVALUE(@D2)) AND
             (FK.NRRENDOR>=@N1 AND FK.NRRENDOR<=@N2) AND 
             (FK.ORG>=@O1      AND FK.ORG<=@O2)      AND 
             (FK.TIPDOK>=@T1   AND FK.TIPDOK<=@T2)   AND
             (FK.NUMDOK>=@U1   AND FK.NUMDOK<=@U2)   AND
             (FK.REFERDOK>=@R1 AND FK.REFERDOK<=@R2) AND
             (FK.DST>=@S1      AND FK.DST<=@S2) 

   UNION ALL 
      SELECT RK          = 'R',
             FK.NRDFK, 
             FKSCR.KOMENT,
             FKSCR.PERSHKRIM,
             NRDATE      = FKSCR.KOD, 
             FK.DATEDOK, 
             FK.ORG,
             FKSCR.KOD, 
             ROUND(FKSCR.DBKRMV,2), 
             FKSCR.ORDPOST, 
             PROMPTTD    = ' ',
             PROMPTOR    = '',
             PROMPTMB    = STR(FKSCR.DBKRMV,10,2),
             PROMPTDB    = CASE WHEN ABS(ROUND(ISNULL(FKSCR.DB,0),2))>=0.01 THEN STR(ISNULL(FKSCR.DB,''),10,2)+' '+ISNULL(MONEDHA.SIMBOL,'') ELSE '' END,
             PROMPTKR    = CASE WHEN ABS(ROUND(ISNULL(FKSCR.KR,0),2))>=0.01 THEN STR(ISNULL(FKSCR.KR,''),10,2)+' '+ISNULL(MONEDHA.SIMBOL,'') ELSE '' END,
             ORDDOK      = CASE WHEN (FK.ORG='H' OR FK.ORG='D') THEN '2' ELSE '0' END ,
             NRDFKM      = CASE WHEN (FK.ORG='H' OR FK.ORG='D') AND ISNULL(QDITARNRDFKMD.NRDFKMASTER,0)<>0  
                                THEN QDITARNRDFKMD.NRDFKMASTER 
                                ELSE FK.NRRENDOR 
                           END,
             PROMPTFK    = ISNULL(FK.TIPDOK,'')+'   '+ISNULL(FK.REFERDOK,'')+' :   '+
                           RTRIM(CONVERT(CHAR(8), DATEDOK,4))+' / '+RTRIM(CONVERT(CHAR,FK.NUMDOK))+
                           CASE WHEN ISNULL(FK.PERSHKRIM1,'')<>'' THEN '  - '+ISNULL(FK.PERSHKRIM1,'') ELSE '' END
 
        FROM (FK LEFT JOIN (FKSCR LEFT JOIN MONEDHA ON FKSCR.KMON = MONEDHA.KOD) ON FK.NRRENDOR = FKSCR.NRD)
                 LEFT JOIN QDITARNRDFKMD  ON FK.NRRENDOR=QDITARNRDFKMD.NRDFKDETAIL            
       WHERE  (DATEDOK>=DBO.DATEVALUE(@D1) AND DATEDOK<=DBO.DATEVALUE(@D2)) AND

            ( ((FK.NRRENDOR>=@N1 AND FK.NRRENDOR<=@N2) AND 
               (ORG>=@O1 AND ORG<=@O2)) OR  

              ((QDITARNRDFKMD.NRDFKMASTER>=@N1 AND QDITARNRDFKMD.NRDFKMASTER<=@N2) AND 
               (ORG>=@O3 AND ORG<=@O4))) AND

             (FK.TIPDOK>=@T1   AND FK.TIPDOK<=@T2) AND
             (FK.NUMDOK>=@U1   AND FK.NUMDOK<=@U2) AND
             (FK.REFERDOK>=@R1 AND FK.REFERDOK<=@R2) AND
             (FK.DST>=@S1      AND FK.DST<=@S2) 


   UNION ALL 
      SELECT RK          = 'Z',
             FK.NRDFK,
             KOMENT      = '',
             PERSHKRIM   = REPLICATE('_',100),
             NRDATE      = '',
             FK.DATEDOK,
             FK.ORG, 
             KOD         = '',
             DBKRMV      = 0,
             ORDPOST     = 0,
             PROMPTTD    = ' ',
             PROMPTOR    = '',
             PROMPTMB    = REPLICATE('_',100),
             PROMPTDB    = ' ',
             PROMPTKR    = ' ',
             ORDDOK      = CASE WHEN (FK.ORG='H' OR FK.ORG='D') THEN '2' ELSE '0' END,
             NRDFKM      = CASE WHEN (FK.ORG='H' OR FK.ORG='D') AND ISNULL(QDITARNRDFKMD.NRDFKMASTER,0)<>0 
                                THEN QDITARNRDFKMD.NRDFKMASTER 
                                ELSE FK.NRRENDOR 
                           END,
             PROMPTFK    = ISNULL(FK.TIPDOK,'')+'   '+ISNULL(FK.REFERDOK,'')+' :   '+
                           RTRIM(CONVERT(CHAR(8), DATEDOK,4))+' / '+RTRIM(CONVERT(CHAR,FK.NUMDOK))+
                           CASE WHEN ISNULL(FK.PERSHKRIM1,'')<>'' THEN '  - '+ISNULL(FK.PERSHKRIM1,'') ELSE '' END

        FROM FK LEFT JOIN QDITARNRDFKMD  ON FK.NRRENDOR=QDITARNRDFKMD.NRDFKDETAIL
       WHERE (DATEDOK>=DBO.DATEVALUE(@D1) AND DATEDOK<=DBO.DATEVALUE(@D2)) AND
             (FK.NRRENDOR>=@N1 AND FK.NRRENDOR<=@N2) AND 
             (ORG>=@O1         AND ORG<=@O2)         AND
             (FK.TIPDOK>=@T1   AND FK.TIPDOK<=@T2)   AND
             (FK.NUMDOK>=@U1   AND FK.NUMDOK<=@U2)   AND
             (FK.REFERDOK>=@R1 AND FK.REFERDOK<=@R2) AND
             (FK.DST>=@S1      AND FK.DST<=@S2) 
 
    ORDER BY DATEDOK, NRDFKM, RK, ORDDOK, NRDFK, ORDPOST, KOD





GO
