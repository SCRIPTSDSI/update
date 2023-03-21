SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE          procedure [dbo].[DitarFK]
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

--   DECLARE @VLength      Int;

--       SET @VLength    = 8;

     DECLARE @DtKp         DateTime,
             @DtKs         DateTime,
             @NrKp         BigInt,
             @NrKs         BigInt,
             @OrgKp        Varchar(30),
             @OrgKs        Varchar(30),
             @TipKp        VarChar(20),
             @TipKs        VarChar(20),
             @NumDokKp     BigInt,
             @NumDokKs     BigInt,
             @ReferDokKp   Varchar(30),
             @ReferDokKs   Varchar(30),
             @DstKp        VarChar(20),
             @DstKs        VarChar(20);

         SET @DtKp       = dbo.DateValue(@D1);  -- = CONVERT(VARCHAR,CONVERT(DATETIME,@D1,104),121)
         SET @DtKs       = dbo.DateValue(@D2);  -- = CONVERT(VARCHAR,CONVERT(DATETIME,@D2,104),121)
         SET @NrKp       = @N1;
         SET @NrKs       = @N2;
         SET @OrgKp      = RTRIM(LTRIM(@O1));
         SET @OrgKs      = RTRIM(LTRIM(@O2));
         SET @TipKp      = RTRIM(LTRIM(@T1));
         SET @TipKs      = RTRIM(LTRIM(@T2));
         SET @NumDokKp   = @U1;
         SET @NumDokKs   = @U2;
         SET @ReferDokKp = RTRIM(LTRIM(@R1));
         SET @ReferDokKs = RTRIM(LTRIM(@R2));
         SET @DstKp      = RTRIM(LTRIM(@S1));
         SET @DstKs      = RTRIM(LTRIM(@S2));

      SELECT RK          = 'K', 
             NRDFK       = FK.NRRENDOR,
             KOMENT      = FK.PERSHKRIM1, 
             PERSHKRIM   = ISNULL(FK.REFERDOK,'')+':'+ISNULL(FK.PERSHKRIM2,''),
             NRDATE      = RTRIM(CONVERT(Char(8), DATEDOK,4))+' / '+CONVERT(Char,FK.NUMDOK),
--           NRDATE      = RTRIM(CONVERT(Char(8), DATEDOK,4))+','  +Right(REPLICATE('0',@VLength)+RTRIM(CONVERT(Char,FK.NUMDOK)),@VLength),
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
             PROMPTDOK   = ISNULL(FK.TIPDOK,'')+'   '+ISNULL(FK.REFERDOK,'')+' :   '+
                           RTRIM(CONVERT(CHAR(8), DATEDOK,4))+' / '+RTRIM(CONVERT(CHAR,FK.NUMDOK))+
                           CASE WHEN ISNULL(FK.PERSHKRIM1,'')<>'' THEN '  - '+ISNULL(FK.PERSHKRIM1,'') ELSE '' END
        FROM  FK 

       WHERE (FK.NRRENDOR >= @NrKp         AND  FK.NRRENDOR <= @NrKs)        AND 
             (DATEDOK     >= @DtKp         AND  DATEDOK     <= @DtKs)        AND 
             (ORG         >= @OrgKp        AND  ORG         <= @OrgKs)       AND
             (FK.TIPDOK   >= @TipKp        AND  FK.TIPDOK   <= @TipKs)       AND
             (FK.NUMDOK   >= @NumDokKp     AND  FK.NUMDOK   <= @NumDokKs)    AND
             (FK.REFERDOK >= @ReferDokKp   AND  FK.REFERDOK <= @ReferDokKs)  AND
             (ISNULL(FK.DST,'') >= @DstKp  AND  ISNULL(FK.DST,'') <= @DstKs) 

   UNION ALL
 
      SELECT RK          = 'R',
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
             PROMPTDB    = CASE WHEN ABS(ROUND(ISNULL(FKSCR.DB,0),2))>=0.01 
                                THEN STR(ISNULL(FKSCR.DB,''),10,2)+' '+ISNULL(MONEDHA.SIMBOL,'') 
                                ELSE '' 
                           END,
             PROMPTKR    = CASE WHEN ABS(ROUND(ISNULL(FKSCR.KR,0),2))>=0.01 
                                THEN STR(ISNULL(FKSCR.KR,''),10,2)+' '+ISNULL(MONEDHA.SIMBOL,'') 
                                ELSE '' 
                           END,
             PROMPTDOK   = ISNULL(FK.TIPDOK,'')+'   '+ISNULL(FK.REFERDOK,'')+' :   '+
                           RTRIM(CONVERT(CHAR(8), DATEDOK,4))+' / '+RTRIM(CONVERT(CHAR,FK.NUMDOK))+
                           CASE WHEN ISNULL(FK.PERSHKRIM1,'')<>'' THEN '  - '+ISNULL(FK.PERSHKRIM1,'') ELSE '' END

        FROM  FK INNER JOIN (FKSCR LEFT JOIN MONEDHA ON FKSCR.KMON = MONEDHA.KOD) ON FK.NRRENDOR = FKSCR.NRD
       WHERE (FK.NRRENDOR >= @NrKp         AND  FK.NRRENDOR <= @NrKs)         AND 
             (DATEDOK     >= @DtKp         AND  DATEDOK     <= @DtKs)         AND 
             (ORG         >= @OrgKp        AND  ORG         <= @OrgKs)        AND
             (FK.TIPDOK   >= @TipKp        AND  FK.TIPDOK   <= @TipKs)        AND
             (FK.NUMDOK   >= @NumDokKp     AND  FK.NUMDOK   <= @NumDokKs)     AND
             (FK.REFERDOK >= @ReferDokKp   AND  FK.REFERDOK <= @ReferDokKs)   AND
             (ISNULL(FK.DST,'') >= @DstKp  AND  ISNULL(FK.DST,'') <= @DstKs)  

--   UNION ALL 
--
--      SELECT RK          = 'Z',
--             NRDFK       = MAX(FK.NRRENDOR), 
--             KOMENT      = REPLICATE('_',100),
--             PERSHKRIM   = REPLICATE('_',100),
--             NRDATE      = CASE WHEN ABS(ROUND(ISNULL(SUM(DBKRMV),0),2))>=0.01 THEN 'Gabim' ELSE REPLICATE('_',100) END,
--             DATEDOK     = MAX(FK.DATEDOK), 
--             ORG         = MAX(FK.ORG),
--             KOD         = ' ',
--             DBKRMV      = ROUND(ISNULL(SUM(DBKRMV),0),2),
--             ORDPOST     = 0,
--             PROMPTTD    = ' ',
--             PROMPTOR    = CASE WHEN ABS(ROUND(ISNULL(SUM(DBKRMV),0),2))>=0.01 
--                                THEN '!!'
--                                ELSE ' ' 
--                           END,
--             PROMPTMB    = CASE WHEN ABS(ROUND(ISNULL(SUM(DBKRMV),0),2))>=0.01 
--                                THEN STR(ISNULL(SUM(DBKRMV),0),10,2) 
--                                ELSE REPLICATE('_',100) 
--                           END,
--             PROMPTDB    = REPLICATE('_',100),
--             PROMPTKR    = REPLICATE('_',100),
--             PROMPTDOK   = MAX(ISNULL(FK.TIPDOK,'')+'   '+ISNULL(FK.REFERDOK,'')+' :   '+
--                           RTRIM(CONVERT(CHAR(8), DATEDOK,4))+' / '+RTRIM(CONVERT(CHAR,FK.NUMDOK))+
--                           CASE WHEN ISNULL(FK.PERSHKRIM1,'')<>'' THEN '  - '+ISNULL(FK.PERSHKRIM1,'') ELSE '' END)
--        FROM  FK INNER JOIN FKSCR ON FK.NRRENDOR=FKSCR.NRD
--       WHERE (FK.NRRENDOR >= @NrKp         AND  FK.NRRENDOR <= @NrKs)         AND 
--             (DATEDOK     >= @DtKp         AND  DATEDOK     <= @DtKs)         AND 
--             (ORG         >= @OrgKp        AND  ORG         <= @OrgKs)        AND
--             (FK.TIPDOK   >= @TipKp        AND  FK.TIPDOK   <= @TipKs)        AND
--             (FK.NUMDOK   >= @NumDokKp     AND  FK.NUMDOK   <= @NumDokKs)     AND
--             (FK.REFERDOK >= @OrgKp        AND  FK.REFERDOK <= @OrgKs)        AND
--             (ISNULL(FK.DST,'') >= @DstKp  AND  ISNULL(FK.DST,'') <= @dstKs)  
--    GROUP BY FK.NRRENDOR

    ORDER BY DATEDOK, NRDFK, RK, ORDPOST, KOD


















GO
