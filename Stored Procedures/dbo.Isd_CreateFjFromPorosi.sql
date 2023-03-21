SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   Procedure [dbo].[Isd_CreateFjFromPorosi]
( 
  @PNrRendor  Int,
  @PTip       Varchar(10),
  @PListRef   Varchar(Max)
 )
As


-- Krijimi i dokumentave dhe kalim ne Baze,Krijim ditare per FJ

       Set NoCount On

        if Object_Id('TempDB..#TMPD') is not null
           DROP TABLE #TMPD;
        if Object_Id('TempDB..#TMPDSCR') is not null
           DROP TABLE #TMPDSCR;

   Declare @NrRendor   Int,
           @NrDok      Int,
           @NrDokFt    Int,
           @KMag       Varchar(10),
           @Shenim1    Varchar(150),
           @Shenim2    Varchar(150),
           @DateDok    DateTime,
           @DateDitar  Varchar(20),
           @ListRef    Varchar(Max),
           @TipDq      Varchar(10),
           @TipKl      Varchar(10),
           @ListOrdDq  Varchar(Max),
           @ListOrdKl  Varchar(Max),
           @ListCommun Varchar(Max),
           @Sql        Varchar(Max);


       Set @NrRendor = @PNrRendor;
       Set @ListRef  = @PListRef;

       if  @ListRef='*'
           Set @ListRef = '';

       if  @PTip='D' 
           begin
             Set @TipDq = @PTip
             Set @TipKl = '';
           end
       else
       if  @PTip='K' 
           begin
             Set @TipDq = '';
             Set @TipKl = @PTip
           end
       else
    -- if  @PTip='' or @PTip='*'
           begin
             Set @TipDq = 'D';
             Set @TipKl = 'K';
           end;
       
       Set @KMag    = (SELECT KMAG    FROM ARTIKUJORD WHERE NRRENDOR=@NrRendor);
       Set @DateDok = (SELECT DATEDOK FROM ARTIKUJORD WHERE NRRENDOR=@NrRendor);
       Set @Shenim1 = (SELECT SHENIM1 FROM ARTIKUJORD WHERE NRRENDOR=@NrRendor);
    -- Set @Shenim2 = (SELECT SHENIM1 FROM ARTIKUJORD WHERE NRRENDOR=@NrRendor);

       Set @NrDok   = (SELECT MAX(NRDOK) 
                         FROM FD 
                        WHERE KMAG=@KMag AND YEAR(DATEDOK)=YEAR(@DateDok));

       Set @NrDokFt = (SELECT MAX(NRDOK) -- Fashat ?
                         FROM FJ 
                        WHERE YEAR(DATEDOK)=YEAR(@DateDok));

    SELECT *
      INTO #TMPD
      FROM FJ
     WHERE 1=2;

    SELECT *
      INTO #TMPDSCR
      FROM FJSCR
     WHERE 1=2;

     ALTER TABLE #TMPD     DROP COLUMN NRRENDOR
     ALTER TABLE #TMPD     ADD         NRRENDOR BigInt      Default 0
     ALTER TABLE #TMPDSCR  ADD         KODFKL   Varchar(30) Default ''
     ALTER TABLE #TMPDSCR  ADD         TIPORD   Varchar(10) Default '';



    INSERT INTO #TMPD
          (NRRENDOR,DATEDOK,NRDOK,NRFRAKS,KODFKL,KMAG,NRMAG,NRDMAG,NRRENDDMG) 
    SELECT NRRENDOR   = ROW_NUMBER() OVER(ORDER BY B.KODAF),
           DATEDOK    = MAX(A.DATEDOK),
           NRDOK      = IsNull(@NrDok,0)  +ROW_NUMBER() OVER(ORDER BY B.KODAF),
           NRFRAKS    = 0,
           KODFKL     = B.KODAF,
           KMAG       = MAX(A.KMAG),
           NRMAG      = MAX(M.NRRENDOR),
           NRDMAG     = IsNull(@NrDokFt,0)+ROW_NUMBER() OVER(ORDER BY B.KODAF),
           NRRENDDMG  = 0
      FROM ARTIKUJORD A INNER JOIN ARTIKUJORDSCR B ON A.NRRENDOR=B.NRD
                        LEFT  JOIN MAGAZINA M      ON A.KMAG=M.KOD
     WHERE A.NRRENDOR = @NrRendor AND (TIPKLL=@TipDq OR TIPKLL=@TipKl)
  GROUP BY B.KODAF;


    INSERT INTO #TMPDSCR
          (KOD,KARTLLG,KODFKL,SASI,NRD,TIPORD,TAGNR)
    SELECT A.KMAG+'.'+B.KODAF+'...',
           B.KOD,
           KODFKL     = B.KODAF,
           B.SASI,
           NRD        = T1.NRRENDOR,
           TIPORD     = B.TIPKLL,
           TAGNR      = T1.NRRENDOR
      FROM ARTIKUJORD A INNER JOIN ARTIKUJORDSCR B  ON A.NRRENDOR = B.NRD
                        LEFT  JOIN #TMPD         T1 ON T1.KODFKL  = B.KODAF
     WHERE A.NRRENDOR=@NrRendor AND (TIPKLL=@TipDq OR TIPKLL=@TipKl) AND ABS(B.SASI)>=0.01
  ORDER BY B.KODAF,B.KOD;



        if @ListRef<>''
           begin
             Set @Sql = ' 
      DELETE 
        FROM #TMPD
       WHERE CHARINDEX('',''+KODFKL+'','','',''+'''+@ListRef+'''+'','')=0; 

      DELETE 
        FROM #TMPDSCR
       WHERE CHARINDEX('',''+KODFKL+'','','',''+'''+@ListRef+'''+'','')=0 ';
          -- Print @Sql;
             Exec (@Sql);
           end;

/*
        if @ListRef<>''
           begin
             Set @Sql = ' 
      DELETE FROM #TMPD    WHERE NOT (KODFKL In ('+@ListRef+')) 
      DELETE FROM #TMPDSCR WHERE NOT (KODFKL In ('+@ListRef+')) ';
             Exec (@Sql);
           end;
*/

       Set @ListOrdDq = '';
       Set @ListOrdKl = '';
    Select @ListOrdDq = @ListOrdDq + 
                        Case When TIPORD=@TipDq 
                             Then ',' + KODFKL
                             Else '' End,
           @ListOrdKl = @ListOrdKl + 
                        Case When TIPORD=@TipKl 
                             Then ',' + KODFKL
                             Else '' End
      From #TMPDSCR
  Group By KODFKL,TIPORD
  Order By KODFKL,TIPORD;


        if Substring(@ListOrdDq,1,1)=','
           Set @ListOrdDq = Substring(@ListOrdDq,2,Len(@ListOrdDq));
        if Substring(@ListOrdKl,1,1)=','
           Set @ListOrdKl = Substring(@ListOrdKl,2,Len(@ListOrdKl));

    DELETE 
      FROM #TMPD
     WHERE Not Exists (SELECT * FROM #TMPDSCR WHERE #TMPD.NRRENDOR=#TMPDSCR.NRD);

-- Regullime ne Dokument dhe reshta
    UPDATE A
       SET KODAF      = A.KARTLLG,
           LLOGARIPK  = A.KARTLLG,
           PERSHKRIM  = B.PERSHKRIM,
           CMIMM      = B.KOSTMES,
           VLERAM     = ROUND(A.SASI*B.KOSTMES,2),
           CMSHZB0    = B.CMSH,
           CMSHZB0MV  = B.CMSH,
           PERQDSCN   = 0,                   -- Sipas Klases se klientit  
           CMIMBS     = B.CMSH,
           VLPATVSH   = ROUND(A.SASI*B.CMSH,2),
           VLTVSH     = CASE WHEN B.TATIM=1
                             THEN ROUND(A.SASI*B.CMSH*ISNULL(K.PERQINDJE,0),2)
                             ELSE 0 END,      -- Sipas Tvsh se Artikullit
           VLTAX      = 0,
           VLERABS    = ROUND(A.SASI*B.CMSH,2)+
                        CASE WHEN B.TATIM=1
                             THEN ROUND(A.SASI*B.CMSH*ISNULL(K.PERQINDJE,0),2)
                             ELSE 0 END,
           PERQTVSH   = CASE WHEN B.TATIM=1 
                             THEN ISNULL(K.PERQINDJE,0)
                             ELSE 0 END,      -- Sipas Klases TVSH

           NJESI      = B.NJESI,
           NJESINV    = B.NJESI,
           KOMENT     = @Shenim1,
           KODTVSH    = B.KODTVSH,

           PROMOC     = 0,
           PROMOCTIP  = '',
           NOTMAG     = 0,
           RIMBURSIM  = 0,
           SASIFR     = 0,
           VLERAFR    = 0,
           TIPFR      = '',
           PROMOCKOD  = '',
           PESHANET   = ROUND(A.SASI*ISNULL(B.PESHANET,0),3),       
           PESHABRT   = ROUND(A.SASI*ISNULL(B.PESHABRT,0),3),       
           TIPREF     = '',
           NRDOKREF   = '',
           SERI       = '',
           NRDITAR    = 0,
           TIPKTH     = '',
           KOEFICIENT = 0,
           KLSART     = '',
           TIPKLL     = 'K',

           KONVERTART = ISNULL(B.KONV1,1) * ISNULL(B.KONV2,1),
           BC         = B.BC,
           KOEFSHB    = B.KOEFSH,
           NRRENDKLLG = B.NRRENDOR,
           ORDERSCR   = A.NRRENDOR
      FROM #TMPDSCR A LEFT JOIN ARTIKUJ    B ON A.KARTLLG=B.KOD
                      LEFT JOIN KLASATATIM K ON B.KODTVSH=K.KOD;

-- Print @ListOrdDq
-- Print @ListOrdKl
--Select * From #TmpD
--SELECT * FROM #TmpDScr
--Return

--         I N S E R T I M   ne   DB


--         1. Regullim dhe Insertim i FJ

    UPDATE A
       SET A.KOD         = A.KODFKL+'.',  
           A.NIPT        = K.NIPT,
           A.SHENIM1     = K.PERSHKRIM,
           A.SHENIM2     = @Shenim1,
           A.SHENIM3     = '',
           A.SHENIM4     = '',

           A.KMON        = '',
           A.KURS1       = 1,
           A.KURS2       = 1,
           A.DTDMAG      = A.DATEDOK,
           A.FRDMAG      = 0,
           A.TIPDMG      = 'D',
           A.NRDSHOQ     = CAST(CAST(A.NRDOK As BigInt) As Varchar), --CAST(CAST(A.NRDOKLNK As BigInt) As Varchar)
           A.DTDSHOQ     = A.DATEDOK,

           A.VLPATVSH    = B.VLPATVSH,
           A.VLTVSH      = B.VLTVSH,
           A.VLTAX       = B.VLTAX,
           A.VLERZBR     = 0,
           A.PARAPG      = 0,
           A.VLERTOT     = B.VLPATVSH+B.VLTVSH+B.VLTAX,
           A.PERQTVSH    = 0,
           A.PERQZBR     = 0,
           A.KTH         = 0,
           A.NRSERIAL    = '',

           A.DTAF        = 0,
           A.PERQDS      = 0,
           A.MODPG       = '',

           A.LLOJDOK     = 'A',
           A.ISDG        = 0,
           A.ISDOKSHOQ   = 0,
           A.LLOGTVSH    = '',
           A.LLOGZBR     = '',
           A.LLOGARK     = '',
           A.NRDITAR     = 0,
           A.NRDITARSHL  = 0,
           A.NRDITARPRMC = 0,
           A.NRDFK       = 0,
           A.POSTIM      = 0,
           A.LETER       = 0,
           A.KLASAKF     = K.GRUP,
           A.VENHUAJ     = K.VENDHUAJ,
           A.RRETHI      = V.PERSHKRIM,
           A.KODARK      = '',
           A.NRRENDORAR  = 0

      FROM #TMPD A INNER JOIN 
           (SELECT KODFKL,
                   VLPATVSH  = SUM(ISNULL(T2.VLPATVSH,0)),
                   VLTVSH    = SUM(ISNULL(T2.VLTVSH,0)),
                   VLTAX     = SUM(ISNULL(T2.VLTAX,0))
              FROM #TMPDSCR T2 
          GROUP BY KODFKL ) B ON A.KODFKL=B.KODFKL
                   LEFT JOIN KLIENT      K ON A.KODFKL=K.KOD
                   LEFT JOIN VENDNDODHJE V ON K.VENDNDODHJE=V.KOD;

       Set @ListCommun = dbo.Isd_ListFields2Tables('FJ','#TMPD','NRRENDOR,TAGNR,TAGRND');
       Set @Sql= ' INSERT INTO FJ 
                         ('+@ListCommun+',TAGNR) 
                   SELECT '+@ListCommun+',NRRENDOR
                     FROM #TMPD 
                 ORDER BY NRRENDOR ';
      Exec ( @Sql );

    UPDATE A
       SET A.NRRENDDMG=B.NRRENDOR
      FROM #TMPD A INNER JOIN FJ B ON A.NRRENDOR=B.TAGNR
     WHERE B.TAGNR<>0;

    UPDATE FJ
       SET FIRSTDOK = 'S'+Cast(Cast(NRRENDOR As BigInt) As Varchar),
           TAGNR    = 0
     WHERE ISNULL(TAGNR,0)<>0;

--         2. Regullim dhe Insertim i FJSCR

    UPDATE A
       SET A.NRD=B.NRRENDDMG
      FROM #TMPDSCR A INNER JOIN #TMPD B ON A.TAGNR=B.NRRENDOR;

       Set @ListCommun = dbo.Isd_ListFields2Tables('FJSCR','#TMPDSCR','NRRENDOR,TAGNR,TAGRND');
       Set @Sql= ' INSERT INTO FJSCR 
                         ('+@ListCommun+',TAGNR,TAGRND) 
                   SELECT '+@ListCommun+',0,''''
                     FROM #TMPDSCR 
                    WHERE NRD<>0
                 ORDER BY NRD,KOD ';
      Exec ( @Sql );


--         3. Regullim dhe Insertim i FD

    INSERT INTO FD
          (KMAG,NRMAG,DATEDOK,NRDOK,NRFRAKS,TIP,DST,
           KMAGRF,KMAGLNK,NRDOKLNK,NRFRAKSLNK,
           SHENIM1,SHENIM2,SHENIM3,SHENIM4,
           NRSERIAL,KODLM,NRRENDORFAT,DOK_JB,TIPFAT,GRUP,KTH,NRDFK,POSTIM,LETER,KALIMLMZGJ,
           FAKLS,FADESTIN,FABUXHET,KLASIFIKIM,TAGNR)
    SELECT KMAG,NRMAG,DATEDOK,NRDOK,NRFRAKS,'D','SH',
           KMAGRF      = '',
           KMAGLNK     = '',
           NRDOKLNK    = 0,
           NRFRAKSLNK  = 0,
           A.SHENIM1,
           A.SHENIM2,
           A.SHENIM3,
           A.SHENIM4,
           A.NRSERIAL,
           KODLM       = '',
           A.NRRENDDMG,
           DOK_JB      = 1,
           TIPFAT      = 'S',
           GRUP        = M.GRUP,
           KTH         = 0,
           0,0,0,0,'','','','',
           A.NRRENDOR
      FROM #TMPD A LEFT JOIN MAGAZINA M ON A.KMAG=M.KOD
  ORDER BY A.NRRENDOR;


    UPDATE A
       SET A.NRRENDDMG=B.NRRENDOR
      FROM #TMPD A INNER JOIN FD B ON A.NRRENDOR=B.TAGNR
     WHERE B.TAGNR<>0;

    UPDATE FD
       SET FIRSTDOK = TIP + Cast(Cast(NRRENDOR As BigInt) As Varchar),
           TAGNR    = 0
     WHERE ISNULL(TAGNR,0)<>0;


    UPDATE ARTIKUJORD
       SET LISTORDEREDDQ = ISNULL(LISTORDEREDDQ,'') + 
                           CASE WHEN ISNULL(LISTORDEREDDQ,'')<>'' AND @ListOrdDq<>''
                                THEN ','
                                ELSE '' END +
                           @ListOrdDq,
           LISTORDEREDKL = ISNULL(LISTORDEREDKL,'') + 
                           CASE WHEN ISNULL(LISTORDEREDKL,'')<>'' AND @ListOrdKl<>''
                                THEN ','
                                ELSE '' END +
                           @ListOrdKl
     WHERE NRRENDOR=@NrRendor


--         4. Regullim dhe Insertim i FDSCR

    UPDATE A
       SET A.NRD=B.NRRENDDMG
      FROM #TMPDSCR A INNER JOIN #TMPD B ON A.TAGNR=B.NRRENDOR

       Set @ListCommun = dbo.Isd_ListFields2Tables('FDSCR','#TMPDSCR','NRRENDOR,TAGNR,TAGRND')
       Set @Sql= ' INSERT INTO FDSCR 
                         ('+@ListCommun+',KMON,CMIMSH,VLERASH,VLERAFT,CMIMOR,VLERAOR,
                          FAKLS,FASTATUS,FADESTIN,GJENROWAUT,TAGRND,TAGNR) 
                   SELECT '+@ListCommun+','''',CMIMBS,VLPATVSH,VLPATVSH,CMIMBS,VLPATVSH,'''','''','''',0,0,0
                     FROM #TMPDSCR 
                    WHERE NRD<>0
                 ORDER BY NRD,KOD ';
      Exec ( @Sql );

        if Object_Id('TempDB..#TMPD') is not null
           DROP TABLE #TMPD;
        if Object_Id('TempDB..#TMPDSCR') is not null
           DROP TABLE #TMPDSCR;

--         5. Kalim i FJ ne Ditar

      Set  @DateDitar = Convert(Varchar,@DateDok,104);
      Exec [Isd_GjenerimDitar] @PDateKp = @DateDitar,
                               @PDateKs = @DateDitar,
                               @PTip    = 'S',
                               @PForce  = '0';


GO
