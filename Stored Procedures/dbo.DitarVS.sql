SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE         procedure [dbo].[DitarVS]
(
 @PDtKp          VarChar(20),
 @PDtKs          VarChar(20),
 @PDstKp         VarChar(30), 
 @PDstKs         VarChar(30),
 @PNrKp          BigInt,
 @PNrKs          BigInt,

 @PTipKp         VarChar(20), -- Fk
 @PTipKs         VarChar(20),
 @PNumDokKp      BigInt,      -- Fk
 @PNumDokKs      BigInt,
 @PReferDokKp    Varchar(30), -- Fk
 @PReferDokKs    Varchar(30),
 @POrgKp         Varchar(30), -- Fk
 @POrgKs         Varchar(30),
 @PKodKp         Varchar(30), -- Scr
 @PKodKs         Varchar(30),
 @PTipDocs       Varchar(20), -- Rasti FK per discret
 @PModuls        Varchar(20),
 @PDocument      Varchar(20), -- Vs,Fk (apo DG ne se duhet)
 @PNrRendor      BigInt
)

As

         Set NOCOUNT On

-- Exec [dbo].[DitarVS] '01/01/2011', '31/12/2015', 'CE','CE', 1,9999999999,'', '', 1, 9999999999, '','', '','', '','',    '','S,F','E',0
-- Exec [dbo].[DitarVS] '01/01/2011', '31/12/2015', 'CE','CE', 1,9999999999,'', '', 1, 9999999999, '','', '','', 'A','A',  '','S,F','T',0

     Declare @DtKp         DateTime,
             @DtKs         DateTime,
             @DstKp        VarChar(20),
             @DstKs        VarChar(20),
             @NrKp         BigInt,
             @NrKs         BigInt,

             @TipKp        VarChar(20),
             @TipKs        VarChar(20),
             @NumDokKp     BigInt,
             @NumDokKs     BigInt,
             @ReferDokKp   Varchar(30),
             @ReferDokKs   Varchar(30),
             @OrgKp        Varchar(30),
             @OrgKs        Varchar(30),
             @KodKp        Varchar(30),
             @KodKs        Varchar(30),
             @TipDocs      Varchar(20),
             @Moduls       Varchar(20),
             @Document     Varchar(20),
             @NrRendor     BigInt,
             @i            Int;

         Set @DtKp       = dbo.DateValue(@PDtKp)  -- = CONVERT(VARCHAR,CONVERT(DATETIME,@PDtKp,104),121)
         Set @DtKs       = dbo.DateValue(@PDtKs)  -- = CONVERT(VARCHAR,CONVERT(DATETIME,@PDtKs,104),121)
         Set @TipKp      = @PTipKp
         Set @TipKs      = @PTipKs
         Set @DstKp      = @PDstKp
         Set @DstKs      = @PDstKs
         Set @NrKp       = @PNrKp
         Set @NrKs       = @PNrKs

         Set @NumDokKp   = @PNumDokKp
         Set @NumDokKs   = @PNumDokKs
         Set @ReferDokKp = @PReferDokKp
         Set @ReferDokKs = @PReferDokKs
         Set @OrgKp      = @POrgKp
         Set @OrgKs      = @POrgKs
         Set @KodKp      = @PKodKp
         Set @KodKs      = @PKodKs
         Set @TipDocs    = @PTipDocs
         Set @Moduls     = @PModuls
         Set @Document   = @PDocument
         Set @NrRendor   = @PNrRendor;

          if @DstKs      = ''
             Set @DstKs      = 'zzzzz';
          if @NrKs   = 0 
             Set @NrKs       = 99999999;

          if @TipKs      = ''
             Set @TipKs      = 'zzzzz';
          if @NumDokKs   = 0 
             Set @NumDokKs   = 99999999;
          if @ReferDokKs = ''
             Set @ReferDokKs = 'zzzzz';
          if @OrgKs      = ''
             Set @OrgKs      = 'zzzzz';
          if @KodKs      = ''
             Set @KodKs      = 'zzzzz';


  -- Declare @TipDocuments Table (TipDocument Varchar(25));
     Declare @TipModuls    Table (TipModul    Varchar(25));


          -- TipKll

      Insert Into @TipModuls
      Select 'F'
   Union All
      Select 'S'
   Union All
      Select 'A'
   Union All
      SELECT 'B'
   Union All
      Select 'T';

          if @Moduls=''
             Set @Moduls = ',F,S,T,A,B,'
          else
             Set @Moduls = ','+@Moduls+','; 
            
      Delete 
        From @TipModuls 
       Where CharIndex(','+TipModul+',',@Moduls)=0;


    if @Document='E'
       begin

            SELECT RK          = 'K', 
                   RRAB        = '',
                   KODAB       = '',
                   TIPDOK      = 'VS',
                   NUMDOK      = A.NRDOK,
                   PERSHKRIM   = ISNULL(A.PERSHKRIM1,''), 
                   KOMENT      = ISNULL(A.PERSHKRIM2,''),  
                   NRDATE      = RTrim('VS'+'   '+RIGHT('        '+Convert(Varchar(20),A.NRDOK),8)+'  '+RTrim(Convert(Char(8), A.DATEDOK,4))),
                -- NRDATE      = RTrim('VS'+'   '+CONVERT(Char,A.NRDOK))+'  '+RTrim(Convert(Char(8), A.DATEDOK,4)),
                   A.DATEDOK, 
                   KOD         = '',
                   DBKRMV      = 0,
                   PROMPTTD    = 'VS',
                   PROMPTMB    = Str(0,10,2),
                   PROMPTDB    = '',
                   PROMPTKR    = '',
                   PROMPTOR    = A.DST,

                   VLERADB     = 0,
                   VLERAKR     = 0,
                   VLERADKMB   = 0,

                   SIMBOL      = '',
                   NRD         = A.NRRENDOR,
                   ORDERSCR    = '',
                   ORG         = 'E',
                   NRRENDORSCR = 0,
                   A.NRRENDOR,
                   PROMPTDOK   = RTRIM('VS '+RIGHT('        '+CONVERT(Varchar(20),A.NRDOK),8))+'  '+RTRIM(CONVERT(CHAR(8), A.DATEDOK,4))+
                                 CASE WHEN ISNULL(A.PERSHKRIM1,'')<>'' THEN '  / '+ISNULL(A.PERSHKRIM1,'') ELSE '' END+
                                 CASE WHEN ISNULL(A.PERSHKRIM2,'')<>'' THEN ',  ' +ISNULL(A.PERSHKRIM2,'') ELSE '' END

              FROM  VS A
 
             WHERE (A.DATEDOK >= @DtKp   AND A.DATEDOK <= @DtKs)  AND 
                   (A.NRDOK   >= @NrKp   AND A.NRDOK   <= @NrKs)  AND
                   (A.DST     >= @DstKp  AND A.DST     <= @DstKs)                


         UNION ALL  


            SELECT RK          = 'R',
                   RRAB        = '',
                   KODAB       = '',
                   TIPDOK      = 'VS',
                   NUMDOK      = A.NRDOK,

                   B.PERSHKRIM,
                   B.KOMENT, 
                   NRDATE      = B.KOD, 
                   A.DATEDOK, 

                   B.KOD, 
                   DBKRMV      = ROUND(B.DBKRMV,2), 
                   PROMPTTD    = ' ',
                   PROMPTMB    = Str(B.DBKRMV,10,2),
                   PROMPTDB    = CASE WHEN Abs(ROUND(IsNull(B.DB,0),2))>=0.01 THEN Str(IsNull(B.DB,''),10,2)+' '+IsNull(M.SIMBOL,'') ELSE '' END,
                   PROMPTKR    = CASE WHEN Abs(ROUND(IsNull(B.KR,0),2))>=0.01 THEN Str(IsNull(B.KR,''),10,2)+' '+IsNull(M.SIMBOL,'') ELSE '' END,
                   PROMPTOR    = A.DST,
            
                   VLERADB     = ROUND(CASE WHEN B.TREGDK='D' THEN B.DB ELSE 0 END,2),
                   VLERAKR     = ROUND(CASE WHEN B.TREGDK='K' THEN B.KR ELSE 0 END,2),
                   VLERADKMB   = ROUND(B.DBKRMV,2),
                   SIMBOL      = ISNULL(M.SIMBOL,''),
                   B.NRD,
                   B.ORDERSCR,
                   ORG         = 'E',
                   NRRENDORSCR = B.NRRENDOR,
                   NRRENDOR    = A.NRRENDOR,
                   PROMPTDOK   = RTRIM('VS '+RIGHT('        '+CONVERT(Varchar(20),A.NRDOK),8))+'  '+RTRIM(CONVERT(CHAR(8), A.DATEDOK,4))+
                                 CASE WHEN ISNULL(A.PERSHKRIM1,'')<>'' THEN '  / '+ISNULL(A.PERSHKRIM1,'') ELSE '' END+
                                 CASE WHEN ISNULL(A.PERSHKRIM2,'')<>'' THEN ',  ' +ISNULL(A.PERSHKRIM2,'') ELSE '' END

              FROM  VS A INNER JOIN (VSSCR B LEFT JOIN MONEDHA M ON ISNULL(B.KMON,'') = ISNULL(M.KOD,'')) ON A.NRRENDOR = B.NRD

             WHERE (A.DATEDOK >= @DtKp   AND A.DATEDOK <= @DtKs)  AND 
                   (A.NRDOK   >= @NrKp   AND A.NRDOK   <= @NrKs)  AND
                   (A.DST     >= @DstKp  AND A.DST     <= @DstKs) AND

                   (B.KOD     >= @KodKp  AND B.KOD     <= @KodKs) AND
                    B.TIPKLL IN (SELECT TipModul FROM @TipModuls)

          ORDER BY DATEDOK,TIPDOK,NUMDOK,NRD,RK,RRAB DESC,ORDERSCR,NRRENDORSCR

       end;
         

    if @Document='T'
       begin

            SELECT RK         = 'K', 
                   RRAB       = '',
                   KODAB      = A.REFERDOK,
                   TIPDOK     = A.TIPDOK,
                   A.NUMDOK,

                   PERSHKRIM   = A.PERSHKRIM1,
                   KOMENT      = CASE WHEN ISNULL(A.REFERDOK,'')<>''
                                      THEN ISNULL(A.REFERDOK,'')+':'
                                      ELSE '' 
                                 END +     ISNULL(A.PERSHKRIM2,''), 
                   NRDATE      = RTrim(IsNull(A.TIPDOK,'')+'   '+RIGHT('        '+Convert(Varchar(20),A.NUMDOK),8)+'  '+RTrim(Convert(Char(8), A.DATEDOK,4)))+
                                 CASE WHEN        ISNULL(A.REFERDOK,'')<>''
                                      THEN '  / '+ISNULL(A.REFERDOK,'')
                                      ELSE ''
                                 END,
                   A.DATEDOK,
 
                   KOD         = '',
                   DBKRMV      = 0,
                   PROMPTTD    = ISNULL(A.TIPDOK,''),
                   PROMPTMB    = '',
                   PROMPTDB    = '',
                   PROMPTKR    = '',
                   PROMPTOR    = A.DST,

                   VLERADB     = 0,
                   VLERAKR     = 0,
                   VLERADKMB   = 0,

                   SIMBOL      = '',
                   NRD         = A.NRRENDOR,
                   ORDERSCR    = '',
                   A.ORG,
                   NRRENDORSCR = 0,
                   A.NRRENDOR,
                   PROMPTDOK   = ISNULL(A.TIPDOK,'')+'   '+ISNULL(A.REFERDOK,'')+' :   '+
                                 RTRIM(CONVERT(CHAR(8), DATEDOK,4))+' / '+RTRIM(CONVERT(CHAR,A.NUMDOK))+
                                 CASE WHEN ISNULL(A.PERSHKRIM1,'')<>'' THEN '  - '+ISNULL(A.PERSHKRIM1,'') ELSE '' END

              FROM FK A
             WHERE (A.DATEDOK        >= @DtKp        AND A.DATEDOK        <= @DtKs)        AND 
                   (A.ORG            >= @OrgKp       AND A.ORG            <= @OrgKs)       AND
                   (A.TIPDOK         >= @TipKp       AND A.TIPDOK         <= @TipKs)       AND
                   (A.NUMDOK         >= @NumDokKp    AND A.NUMDOK         <= @NumDokKs)    AND
                   (A.REFERDOK       >= @ReferDokKp  AND A.REFERDOK       <= @ReferDokKs)  AND
                   (A.NRDOK          >= @NrKp        AND A.NRDOK          <= @NrKs)        AND
                   (IsNull(A.DST,'') >= @DstKp       AND IsNull(A.DST,'') <= @DstKs)              

         UNION ALL 

            SELECT RK          = 'R',
                   RRAB        = '',
                   KODAB       = A.REFERDOK,
                   TIPDOK      = A.TIPDOK,
                   A.NUMDOK, 

                   B.PERSHKRIM,
                   B.KOMENT, 
                   NRDATE      = B.KOD, 
                   A.DATEDOK, 

                   B.KOD, 
                   DBKRMV      = ROUND(B.DBKRMV,2), 
                   PROMPTTD    = '',
                   PROMPTMB    = Str(B.DBKRMV,10,2),
                   PROMPTDB    = CASE WHEN Abs(ROUND(IsNull(B.DB,0),2))>=0.01 THEN Str(IsNull(B.DB,''),10,2)+' '+IsNull(M.SIMBOL,'') ELSE '' END,
                   PROMPTKR    = CASE WHEN Abs(ROUND(IsNull(B.KR,0),2))>=0.01 THEN Str(IsNull(B.KR,''),10,2)+' '+IsNull(M.SIMBOL,'') ELSE '' END,
                   PROMPTOR    = '',

                   VLERADB     = ROUND(CASE WHEN B.TREGDK='D' THEN B.DB ELSE 0 END,2),
                   VLERAKR     = ROUND(CASE WHEN B.TREGDK='K' THEN B.KR ELSE 0 END,2),
                   VLERADKMB   = ROUND(B.DBKRMV,2),

                   SIMBOL      = ISNULL(M.SIMBOL,''),
                   B.NRD,
                   B.ORDERSCR,
                   A.ORG,
                   NRRENDORSCR = B.NRRENDOR,
                   NRRENDOR    = A.NRRENDOR,
                   PROMPTDOK   = ISNULL(A.TIPDOK,'')+'   '+ISNULL(A.REFERDOK,'')+' :   '+
                                 RTRIM(CONVERT(CHAR(8), DATEDOK,4))+' / '+RTRIM(CONVERT(CHAR,A.NUMDOK))+
                                 CASE WHEN ISNULL(A.PERSHKRIM1,'')<>'' THEN '  - '+ISNULL(A.PERSHKRIM1,'') ELSE '' END


              FROM FK A INNER JOIN (FKSCR B LEFT JOIN MONEDHA M ON B.KMON = M.KOD) ON A.NRRENDOR = B.NRD
             WHERE (A.DATEDOK        >= @DtKp        AND A.DATEDOK        <= @DtKs)        AND 
                   (A.ORG            >= @OrgKp       AND A.ORG            <= @OrgKs)       AND
                   (A.TIPDOK         >= @TipKp       AND A.TIPDOK         <= @TipKs)       AND
                   (A.NUMDOK         >= @NumDokKp    AND A.NUMDOK         <= @NumDokKs)    AND
                   (A.REFERDOK       >= @ReferDokKp  AND A.REFERDOK       <= @ReferDokKs)  AND
                   (A.NRDOK          >= @NrKp        AND A.NRDOK          <= @NrKs)        AND
                   (IsNull(A.DST,'') >= @DstKp       AND IsNull(A.DST,'') <= @DstKs)       AND

                   (B.KOD            >= @KodKp       AND B.KOD            <= @KodKs) 

         ORDER BY DATEDOK,TIPDOK,NUMDOK,NRD,RK,RRAB DESC,ORDERSCR,NRRENDORSCR

       end;
GO
