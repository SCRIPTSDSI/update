SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE          procedure [dbo].[DitarAB]
(
 @PDtKp      VarChar(20),
 @PDtKs      VarChar(20),
 @PTipKp     VarChar(20),
 @PTipKs     VarChar(20),
 @PNumDokKp  BigInt,
 @PNumDokKs  BigInt,
 @PKodABKp   VarChar(20),
 @PKodABKs   VarChar(20),
 @PKodKp     Varchar(30),
 @PKodKs     Varchar(30),
 @PTipDocs   Varchar(20),
 @PModuls    Varchar(20),
 @PDocument  Varchar(20),
 @PNrRendor  BigInt
)

As

-- Exec [dbo].[DitarAB] '01/01/2015', '31/12/2015', 'MA', 'MP', 1, 9999999, 'A01', 'A02','','','MA,MP','S,F','A',0

     Declare @DtKp         DateTime,
             @DtKs         DateTime,
             @TipKp        VarChar(20),
             @TipKs        VarChar(20),
             @NumDokKp     BigInt,
             @NumDokKs     BigInt,
             @KodABKp      VarChar(20),
             @KodABKs      VarChar(20),
             @KodKp        Varchar(30),
             @KodKs        Varchar(30),
             @TipDocs      Varchar(20),
             @Moduls       Varchar(20),
             @Document     Varchar(20),
             @NrRendor     BigInt,
             @i            Int;


         Set @DtKp       = dbo.DateValue(@PDtKp);  -- = CONVERT(VARCHAR,CONVERT(DATETIME,@PDtKp,104),121)
         Set @DtKs       = dbo.DateValue(@PdtKs);  -- = CONVERT(VARCHAR,CONVERT(DATETIME,@PDtKs,104),121)
         Set @TipKp      = @PTipKp;
         Set @TipKs      = @PTipKs;
         Set @NumDokKp   = @PNumDokKp;
         Set @NumDokKs   = @PNumDokKs;
         Set @KodABKp    = @PKodABKp;
         Set @KodABKs    = @PKodABKs;
         Set @KodKp      = @PKodKp;
         Set @KodKs      = @PKodKs;
         Set @TipDocs    = @PTipDocs;
         Set @Moduls     = @PModuls;
         Set @Document   = @PDocument;
         Set @NrRendor   = @PNrRendor;

          if @TipKs=''
             Set @TipKs  = 'zzzzz';
          if @KodKs=''
             Set @KodKs  = 'zzzzz';

     Declare @TipDocuments Table (TipDocument Varchar(25));
     Declare @TipModuls    Table (TipModul    Varchar(25));


          -- TipKll

      Insert Into @TipModuls
      Select 'F'
   Union All
      Select 'S'
   Union All
      Select 'A'
   Union All
      Select 'B'
   Union All
      Select 'T';

          if @Moduls=''
             Set @Moduls = ',F,S,T,A,B,'
          else
             Set @Moduls = ','+@Moduls+','; 
            
      DELETE 
        FROM @TipModuls 
       WHERE CHARINDEX(','+TipModul+',',@Moduls)=0;



-- ARKA

    if @Document='A'
       begin

            Insert Into @TipDocuments                  -- TipDok
            Select 'MA'
         Union All
            Select 'MP';

                if @TipDocs=''
                   Set @TipDocs = ',MA,MP,'
                else
                   Set @TipDocs = ','+@TipDocs+','; 

            Delete 
              From @TipDocuments 
             Where CharIndex(','+TipDocument+',',@TipDocs)=0
       
            SELECT RK          = 'K', 
                   RRAB        = '',
                   A.KODAB,
                   A.TIPDOK,
                   A.NUMDOK,
                   PERSHKRIM   = ISNULL(A.SHENIM1,''), 
                   KOMENT      = ISNULL(A.SHENIM2,''),  
                   NRDATE      = RTrim(A.TIPDOK+'   '+RIGHT('        '+Convert(Varchar(20),A.NUMDOK),8)+'  '+RTrim(Convert(Char(8), A.DATEDOK,4))),
                -- NRDATE      = RTrim(A.TIPDOK+'   '+CONVERT(Char,A.NUMDOK))+'  '+RTrim(Convert(Char(8), A.DATEDOK,4)),
                   A.DATEDOK, 
                   KOD         = '',
                   DBKRMV      = 0,
                   PROMPTTD    = ISNULL(A.TIPDOK,' '),
                   PROMPTMB    = Str(A.VLERAMV,10,2),
                   PROMPTDB    = CASE WHEN CHARINDEX(','+A.TIPDOK+',',',MA,XK,AB,DB,') >0
                                      THEN Str(A.VLERA,10,2)+' '+IsNull(M.SIMBOL,'')
                                      ELSE '' END,
                   PROMPTKR    = CASE WHEN CHARINDEX(','+A.TIPDOK+',',',MA,XK,AB,DB,')<=0
                                      THEN Str(A.VLERA,10,2)+' '+IsNull(M.SIMBOL,'')
                                      ELSE '' END,
                   PROMPTOR    = A.KODAB,

                   VLERADB     = CASE WHEN CHARINDEX(','+A.TIPDOK+',',',MA,XK,AB,DB,') >0
                                      THEN ROUND(A.VLERA,2)
                                      ELSE 0 END,
                   VLERAKR     = CASE WHEN CHARINDEX(','+A.TIPDOK+',',',MA,XK,AB,DB,')<=0
                                      THEN ROUND(A.VLERA,2)
                                      ELSE 0 END,
                   VLERADKMB   = ROUND(A.VLERAMV,2),

                   SIMBOL      = ISNULL(M.SIMBOL,''),
                   NRD         = A.NRRENDOR,
                   ORDERSCR    = '',
                   ORG         = 'A',
                   NRRENDORSCR = 0,
                   A.NRRENDOR,
                   PROMPTDOK   = --ISNULL(A.TIPDOK,'')+'   '+ISNULL(FK.REFERDOK,'')+' :   '+
                                 RTRIM(A.TIPDOK+'   '+RIGHT('        '+CONVERT(Varchar(20),A.NUMDOK),8))+'  '+RTRIM(CONVERT(CHAR(8), A.DATEDOK,4))+
                                 CASE WHEN ISNULL(A.KODAB,'')  <>'' THEN '  - '+ISNULL(A.KODAB,'')   ELSE '' END +
                                 CASE WHEN ISNULL(A.SHENIM1,'')<>'' THEN '  / '+ISNULL(A.SHENIM1,'') ELSE '' END+
                                 CASE WHEN ISNULL(A.SHENIM2,'')<>'' THEN ',  ' +ISNULL(A.SHENIM2,'') ELSE '' END
              FROM  ARKA A LEFT  JOIN MONEDHA M ON ISNULL(A.KMON,'') = ISNULL(M.KOD,'')
             WHERE (A.KODAB   >= @KodABKp   AND A.KODAB   <= @KodABKs)    AND 
                   (A.DATEDOK >= @DtKp      AND A.DATEDOK <= @DtKs)       AND 
                   (A.TIPDOK  >= @TipKp     AND A.TIPDOK  <= @TipKs)      AND
                   (A.NUMDOK  >= @NumDokKp  AND A.NUMDOK  <= @NumDokKs)   AND
                   (A.TIPDOK IN (SELECT TipDocument FROM @TipDocuments))


         UNION ALL  


            SELECT RK          = 'R',
                   B.RRAB,
                   A.KODAB,
                   A.TIPDOK,
                   A.NUMDOK,
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
                   PROMPTOR    = '',
            
                   VLERADB     = ROUND(CASE WHEN B.TREGDK='D' THEN B.DB ELSE 0 END,2),
                   VLERAKR     = ROUND(CASE WHEN B.TREGDK='K' THEN B.KR ELSE 0 END,2),
                   VLERADKMB   = ROUND(B.DBKRMV,2),
                   SIMBOL      = ISNULL(M.SIMBOL,''),
                   B.NRD,
                   B.ORDERSCR,
                   ORG         = 'A',
                   NRRENDORSCR = B.NRRENDOR,
                   NRRENDOR    = A.NRRENDOR,
                   PROMPTDOK   = --ISNULL(A.TIPDOK,'')+'   '+ISNULL(FK.REFERDOK,'')+' :   '+
                                 RTRIM(A.TIPDOK+'   '+RIGHT('        '+CONVERT(Varchar(20),A.NUMDOK),8))+'  '+RTRIM(CONVERT(CHAR(8), A.DATEDOK,4))+
                                 CASE WHEN ISNULL(A.KODAB,'')  <>'' THEN '  - '+ISNULL(A.KODAB,'')   ELSE '' END+
                                 CASE WHEN ISNULL(A.SHENIM1,'')<>'' THEN '  / '+ISNULL(A.SHENIM1,'') ELSE '' END+
                                 CASE WHEN ISNULL(A.SHENIM2,'')<>'' THEN ',  ' +ISNULL(A.SHENIM2,'') ELSE '' END

              FROM  ARKA A INNER JOIN (ARKASCR B LEFT JOIN MONEDHA M ON ISNULL(B.KMON,'') = ISNULL(M.KOD,'')) ON A.NRRENDOR = B.NRD
             WHERE (A.KODAB   >= @KodABKp   AND A.KODAB   <= @KodABKs)    AND
                   (A.DATEDOK >= @DtKp      AND A.DATEDOK <= @DtKs)       AND 
                   (A.TIPDOK  >= @TipKp     AND A.TIPDOK  <= @TipKs)      AND
                   (A.NUMDOK  >= @NumDokKp  AND A.NUMDOK  <= @NumDokKs)   AND
                   (A.TIPDOK IN (SELECT TipDocument FROM @TipDocuments))  AND

                   (B.KOD     >= @KodKp     AND B.KOD     <= @KodKs)      AND
                    B.TIPKLL IN (SELECT TipModul FROM @TipModuls)

          ORDER BY KODAB,DATEDOK,TIPDOK,NUMDOK,NRD,RK,RRAB DESC,ORDERSCR,NRRENDORSCR

       end;

         
-- BANKA

    if @Document='B'
       begin
 
           Set @i = 1;                                 
         While @i<=6 
           begin                                       -- TipDok
            Insert Into @TipDocuments
            Select Substring('XK,AB,DB,XJ,CJ,KR',(@i*3)-2, 2);

               Set @i = @i + 1; 
           end;
           
                if @TipDocs=''
                   Set @TipDocs = ',XK,AB,DB,XJ,CJ,KR,'
                else
                   Set @TipDocs = ','+@TipDocs+','; 

            Delete 
              From @TipDocuments 
             Where CharIndex(','+TipDocument+',',@TipDocs)=0
       

            SELECT RK          = 'K', 
                   RRAB        = '',
                   A.KODAB,
                   A.TIPDOK,
                   A.NUMDOK,
                   PERSHKRIM   = ISNULL(A.SHENIM1,''), 
                   KOMENT      = ISNULL(A.SHENIM2,''),  
                   NRDATE      = RTrim(A.TIPDOK+'   '+RIGHT('        '+Convert(Varchar(20),A.NUMDOK),8)+'  '+RTrim(Convert(Char(8), A.DATEDOK,4))),
                -- NRDATE      = RTrim(A.TIPDOK+'   '+CONVERT(Char,A.NUMDOK))+'  '+RTrim(Convert(Char(8), A.DATEDOK,4)),
                   A.DATEDOK, 
                   KOD         = '',
                   DBKRMV      = 0,
                   PROMPTTD    = ISNULL(A.TIPDOK,' '),
                   PROMPTMB    = Str(A.VLERAMV,10,2),
                   PROMPTDB    = CASE WHEN CHARINDEX(','+A.TIPDOK+',',',MA,XK,AB,DB,') >0
                                      THEN Str(A.VLERA,10,2)+' '+IsNull(M.SIMBOL,'')
                                      ELSE '' END,
                   PROMPTKR    = CASE WHEN CHARINDEX(','+A.TIPDOK+',',',MA,XK,AB,DB,')<=0
                                      THEN Str(A.VLERA,10,2)+' '+IsNull(M.SIMBOL,'')
                                      ELSE '' END,
                   PROMPTOR    = A.KODAB,

                   VLERADB     = CASE WHEN CHARINDEX(','+A.TIPDOK+',',',MA,XK,AB,DB,') >0
                                      THEN ROUND(A.VLERA,2)
                                      ELSE 0 END,
                   VLERAKR     = CASE WHEN CHARINDEX(','+A.TIPDOK+',',',MA,XK,AB,DB,')<=0
                                      THEN ROUND(A.VLERA,2)
                                      ELSE 0 END,
                   VLERADKMB   = ROUND(A.VLERAMV,2),

                   SIMBOL      = ISNULL(M.SIMBOL,''),
                   NRD         = A.NRRENDOR,
                   ORDERSCR    = '',
                   ORG         = 'B',
                   NRRENDORSCR = 0,
                   A.NRRENDOR,
                   PROMPTDOK   = --ISNULL(A.TIPDOK,'')+'   '+ISNULL(FK.REFERDOK,'')+' :   '+
                                 RTRIM(A.TIPDOK+'   '+RIGHT('        '+CONVERT(Varchar(20),A.NUMDOK),8))+'  '+RTRIM(CONVERT(CHAR(8), A.DATEDOK,4))+
                                 CASE WHEN ISNULL(A.KODAB,'')  <>'' THEN '  - '+ISNULL(A.KODAB,'')   ELSE '' END+
                                 CASE WHEN ISNULL(A.SHENIM1,'')<>'' THEN '  / '+ISNULL(A.SHENIM1,'') ELSE '' END+
                                 CASE WHEN ISNULL(A.SHENIM2,'')<>'' THEN ',  ' +ISNULL(A.SHENIM2,'') ELSE '' END

              FROM  BANKA A LEFT JOIN MONEDHA M ON ISNULL(A.KMON,'') = ISNULL(M.KOD,'')
             WHERE (A.KODAB   >= @KodABKp   AND A.KODAB   <= @KodABKs)    AND 
                   (A.DATEDOK >= @DtKp      AND A.DATEDOK <= @DtKs)       AND 
                   (A.TIPDOK  >= @TipKp     AND A.TIPDOK  <= @TipKs)      AND
                   (A.NUMDOK  >= @NumDokKp  AND A.NUMDOK  <= @NumDokKs)   AND
                   (A.TIPDOK IN (SELECT TipDocument FROM @TipDocuments))            
          

         UNION ALL  


            SELECT RK          = 'R',
                   B.RRAB,
                   A.KODAB,
                   A.TIPDOK,
                   A.NUMDOK,
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
                   PROMPTOR    = '',
            
                   VLERADB     = ROUND(CASE WHEN B.TREGDK='D' THEN B.DB ELSE 0 END,2),
                   VLERAKR     = ROUND(CASE WHEN B.TREGDK='K' THEN B.KR ELSE 0 END,2),
                   VLERADKMB   = ROUND(B.DBKRMV,2),
                   SIMBOL      = ISNULL(M.SIMBOL,''),
                   B.NRD,
                   B.ORDERSCR,
                   ORG         = 'B',
                   NRRENDORSCR = B.NRRENDOR,
                   NRRENDOR    = A.NRRENDOR,
                   PROMPTDOK   = --ISNULL(A.TIPDOK,'')+'   '+ISNULL(FK.REFERDOK,'')+' :   '+
                                 RTRIM(A.TIPDOK+'   '+RIGHT('        '+CONVERT(Varchar(20),A.NUMDOK),8))+'  '+RTRIM(CONVERT(CHAR(8), A.DATEDOK,4))+
                                 CASE WHEN ISNULL(A.KODAB,'')  <>'' THEN '  - '+ISNULL(A.KODAB,'')   ELSE '' END+
                                 CASE WHEN ISNULL(A.SHENIM1,'')<>'' THEN '  / '+ISNULL(A.SHENIM1,'') ELSE '' END+
                                 CASE WHEN ISNULL(A.SHENIM2,'')<>'' THEN ',  ' +ISNULL(A.SHENIM2,'') ELSE '' END

              FROM  BANKA A INNER JOIN (BANKASCR B LEFT JOIN MONEDHA M ON ISNULL(B.KMON,'') = ISNULL(M.KOD,'')) ON A.NRRENDOR = B.NRD
             WHERE (A.KODAB   >= @KodABKp   AND A.KODAB   <= @KodABKs)    AND
                   (A.DATEDOK >= @DtKp      AND A.DATEDOK <= @DtKs)       AND 
                   (A.TIPDOK  >= @TipKp     AND A.TIPDOK  <= @TipKs)      AND
                   (A.NUMDOK  >= @NumDokKp  AND A.NUMDOK  <= @NumDokKs)   AND
                   (A.TIPDOK IN (SELECT TipDocument FROM @TipDocuments))  AND

                   (B.KOD>=@KodKp           AND B.KOD<=@KodKs)            AND
                    B.TIPKLL IN (SELECT TipModul FROM @TipModuls)

          ORDER BY KODAB,DATEDOK,TIPDOK,NUMDOK,NRD,RK,RRAB DESC,ORDERSCR,NRRENDORSCR


       end;
GO
