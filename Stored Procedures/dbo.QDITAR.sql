SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE          procedure [dbo].[QDITAR]
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

     DECLARE @VLength Int;

         SET @VLength=8;

      SELECT RK='K', 
             NRDFK       = FK.NRRENDOR,
             KOMENT      = FK.PERSHKRIM1, 
             PERSHKRIM   = ISNULL(FK.REFERDOK,'')+':'+ISNULL(FK.PERSHKRIM2,''),
             NRDATE      = RTRIM(CONVERT(Char(8), DATEDOK,4))+' / '+CONVERT(Char,FK.NUMDOK),
    --       NRDATE      = RTRIM(CONVERT(Char(8), DATEDOK,4))+','  +Right(REPLICATE('0',@VLength)+RTRIM(CONVERT(Char,FK.NUMDOK)),@VLength),
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
             PROMPTFK    = ISNULL(FK.TIPDOK,'')+'   '+ISNULL(FK.REFERDOK,'')+' :   '+
                           RTRIM(CONVERT(CHAR(8), DATEDOK,4))+' / '+RTRIM(CONVERT(CHAR,FK.NUMDOK))+
                           CASE WHEN ISNULL(FK.PERSHKRIM1,'')<>'' THEN '  - '+ISNULL(FK.PERSHKRIM1,'') ELSE '' END
        FROM FK 
       WHERE (FK.NRRENDOR>=@N1 AND FK.NRRENDOR<=@N2) AND 
             (DATEDOK>=DBO.DATEVALUE(@D1) AND DATEDOK<=DBO.DATEVALUE(@D2)) AND 
             (ORG>=RTRIM(LTRIM(@O1)) AND ORG<=RTRIM(LTRIM(@O2))) AND
             (FK.TIPDOK>=@T1   AND FK.TIPDOK<=@T2) AND
             (FK.NUMDOK>=@U1   AND FK.NUMDOK<=@U2) AND
             (FK.REFERDOK>=@R1 AND FK.REFERDOK<=@R2) AND
             (ISNULL(FK.DST,'')>=@S1 AND ISNULL(FK.DST,'')<=@S2) 

   UNION ALL 
      SELECT RK='R',
             NRDFK       = FKSCR.NRD, 
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
             PROMPTFK    = ISNULL(FK.TIPDOK,'')+'   '+ISNULL(FK.REFERDOK,'')+' :   '+
                           RTRIM(CONVERT(CHAR(8), DATEDOK,4))+' / '+RTRIM(CONVERT(CHAR,FK.NUMDOK))+
                           CASE WHEN ISNULL(FK.PERSHKRIM1,'')<>'' THEN '  - '+ISNULL(FK.PERSHKRIM1,'') ELSE '' END

        FROM FK INNER JOIN (FKSCR LEFT JOIN MONEDHA ON FKSCR.KMON = MONEDHA.KOD) ON FK.NRRENDOR = FKSCR.NRD
       WHERE (FK.NRRENDOR>=@N1 AND FK.NRRENDOR<=@N2) AND 
             (DATEDOK>=DBO.DATEVALUE(@D1) AND DATEDOK<=DBO.DATEVALUE(@D2)) AND 
             (ORG>=RTRIM(LTRIM(@O1)) AND ORG<=RTRIM(LTRIM(@O2))) AND
             (FK.TIPDOK>=@T1   AND FK.TIPDOK<=@T2) AND
             (FK.NUMDOK>=@U1   AND FK.NUMDOK<=@U2) AND
             (FK.REFERDOK>=@R1 AND FK.REFERDOK<=@R2) AND
             (ISNULL(FK.DST,'')>=@S1 AND ISNULL(FK.DST,'')<=@S2)  


   UNION ALL 
      SELECT RK='Z',
             NRDFK       = MAX(FK.NRRENDOR), 
             KOMENT      = REPLICATE('_',100),
             PERSHKRIM   = REPLICATE('_',100),
             NRDATE      = CASE WHEN ABS(ROUND(ISNULL(SUM(DBKRMV),0),2))>=0.01 THEN 'Gabim' ELSE REPLICATE('_',100) END,
             DATEDOK     = MAX(FK.DATEDOK), 
             ORG         = MAX(FK.ORG),
             KOD         = ' ',
             DBKRMV      = ROUND(ISNULL(SUM(DBKRMV),0),2),
             ORDPOST     = 0,
             PROMPTTD    = ' ',
             PROMPTOR    = CASE WHEN ABS(ROUND(ISNULL(SUM(DBKRMV),0),2))>=0.01 THEN '!!' ELSE ' ' END,
             PROMPTMB    = CASE WHEN ABS(ROUND(ISNULL(SUM(DBKRMV),0),2))>=0.01 
                                THEN STR(ISNULL(SUM(DBKRMV),0),10,2) 
                                ELSE REPLICATE('_',100) 
                           END,
             PROMPTDB    = REPLICATE('_',100),
             PROMPTKR    = REPLICATE('_',100),
             PROMPTFK    = MAX(ISNULL(FK.TIPDOK,'')+'   '+ISNULL(FK.REFERDOK,'')+' :   '+
                               RTRIM(CONVERT(CHAR(8), DATEDOK,4))+' / '+RTRIM(CONVERT(CHAR,FK.NUMDOK))+
                           CASE WHEN ISNULL(FK.PERSHKRIM1,'')<>'' THEN '  - '+ISNULL(FK.PERSHKRIM1,'') ELSE '' END)
        FROM FK INNER JOIN FKSCR ON FK.NRRENDOR=FKSCR.NRD
       WHERE (FK.NRRENDOR>=@N1 AND FK.NRRENDOR<=@N2) AND 
             (DATEDOK>=DBO.DATEVALUE(@D1) AND DATEDOK<=DBO.DATEVALUE(@D2)) AND 
             (ORG>=RTRIM(LTRIM(@O1)) AND ORG<=RTRIM(LTRIM(@O2))) AND
             (FK.TIPDOK>=@T1   AND FK.TIPDOK<=@T2) AND
             (FK.NUMDOK>=@U1   AND FK.NUMDOK<=@U2) AND
             (FK.REFERDOK>=@R1 AND FK.REFERDOK<=@R2) AND
             (ISNULL(FK.DST,'')>=@S1 AND ISNULL(FK.DST,'')<=@S2)  
    GROUP BY FK.NRRENDOR

    ORDER BY DATEDOK, NRDFK, RK, ORDPOST, KOD















GO
