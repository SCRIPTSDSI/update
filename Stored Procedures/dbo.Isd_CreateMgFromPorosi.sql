SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   Procedure [dbo].[Isd_CreateMgFromPorosi]
( 
  @PNrRendor  Int,
  @PListRef   Varchar(Max)
 )
As



       Set NoCount On

   Declare @NrRendor Int


-- Krijimi i dokumentave ne Baze

       Set @NrRendor = @PNrRendor

        if Object_Id('TempDB..#TMPD') is not null
           DROP TABLE #TMPD;
        if Object_Id('TempDB..#TMPDSCR') is not null
           DROP TABLE #TMPDSCR;
        if Object_Id('TempDB..#TMPH') is not null
           DROP TABLE #TMPH;
        if Object_Id('TempDB..#TMPHSCR') is not null
           DROP TABLE #TMPHSCR;


   Declare @NrDok     Int,
           @KMag      Varchar(10),
           @Tip       Varchar(10),
           @Shenim1   Varchar(150),
           @Shenim2   Varchar(150),
           @ListRef   Varchar(Max),
           @ListOrdOk Varchar(Max),
           @Sql       Varchar(Max),
           @DateDok   DateTime;

       Set @Tip     ='M';
       Set @ListRef = @PListRef;
       if  @ListRef='*'
           Set @ListRef = '';

       Set @KMag    = (SELECT KMAG    FROM ARTIKUJORD WHERE NRRENDOR=@NrRendor);
       Set @DateDok = (SELECT DATEDOK FROM ARTIKUJORD WHERE NRRENDOR=@NrRendor);
       Set @Shenim1 = (SELECT SHENIM1 FROM ARTIKUJORD WHERE NRRENDOR=@NrRendor);
    -- Set @Shenim2 = (SELECT SHENIM1 FROM ARTIKUJORD WHERE NRRENDOR=@NrRendor);

       Set @NrDok   = (SELECT MAX(NRDOK) 
                         FROM FD 
                        WHERE KMAG=@KMag AND YEAR(DATEDOK)=YEAR(@DateDok));

    SELECT NRRENDOR  = ROW_NUMBER() OVER(ORDER BY B.KODAF),
           KMAG      = MAX(A.KMAG),
           DATEDOK   = MAX(A.DATEDOK),
           NRDOK     = IsNull(@NrDok,0)+ROW_NUMBER() OVER(ORDER BY B.KODAF),
           KMAGLNK   = B.KODAF,
           NRDOKLNK  = ISNULL((SELECT MAX(NRDOK) 
                                 FROM FH 
                                WHERE KMAG=B.KODAF AND YEAR(DATEDOK)=YEAR(@DateDok)),0)+1 
      INTO #TMPD
      FROM ARTIKUJORD A INNER JOIN ARTIKUJORDSCR B ON A.NRRENDOR=B.NRD
     WHERE A.NRRENDOR = @NrRendor AND TIPKLL=@Tip
  GROUP BY B.KODAF


    SELECT B.KOD,
           KMAG       = A.KMAG,
           KMAGLNK    = B.KODAF,
           B.SASI,
           NRD        = T1.NRRENDOR,
           TAGNR      = T1.NRRENDOR
      INTO #TMPDSCR
      FROM ARTIKUJORD A INNER JOIN ARTIKUJORDSCR B ON A.NRRENDOR = B.NRD
                        LEFT  JOIN #TMPD T1 ON T1.KMAGLNK=B.KODAF
     WHERE A.NRRENDOR=@NrRendor AND TIPKLL=@Tip AND ABS(B.SASI)>=0.01
  ORDER BY B.KODAF,B.KOD

        if @ListRef<>''
           begin
             Set @Sql = ' 
      DELETE 
        FROM #TMPD
       WHERE CHARINDEX('',''+KMAGLNK+'','','',''+'''+@ListRef+'''+'','')=0; 

      DELETE 
        FROM #TMPDSCR
       WHERE CHARINDEX('',''+KMAGLNK+'','','',''+'''+@ListRef+'''+'','')=0 ';
          -- Print @Sql;
             Exec (@Sql);
           end;

/*
        if @ListRef<>''
           begin
             Set @Sql = ' 
    DELETE FROM #TMPD    WHERE NOT (KMAGLNK In ('+@ListRef+')) 
    DELETE FROM #TMPDSCR WHERE NOT (KMAGLNK In ('+@ListRef+')) ';
             Exec (@Sql);
           end;
*/

       Set @ListOrdOk = '';
    Select @ListOrdOk = @ListOrdOk + ',' + KMAGLNK
      From #TMPDSCR
  Group By KMAGLNK
  Order By KMAGLNK;

        if Substring(@ListOrdOk,1,1)=','
           Set @ListOrdOk = Substring(@ListOrdOk,2,Len(@ListOrdOk));


    DELETE 
      FROM #TMPD
     WHERE Not Exists (SELECT * FROM #TMPDSCR WHERE #TMPD.NRRENDOR=#TMPDSCR.NRD);

    SELECT A.NRRENDOR,
           KMAG       = A.KMAGLNK,
           A.DATEDOK,
           NRDOK      = A.NRDOKLNK,
           KMAGLNK    = A.KMAG,
           NRDOKLNK   = A.NRDOK
      INTO #TMPH
      FROM #TMPD A
  ORDER BY KMAG

    SELECT KOD,
           KMAG       = KMAGLNK,
           KMAGLNK    = KMAG,
           SASI,NRD,TAGNR
      INTO #TMPHSCR
      FROM #TMPDSCR
  ORDER BY NRD,KOD


Select * From #TmpD
SELECT * FROM #TmpDScr
Select * From #TmpH
SELECT * FROM #TmpHScr
Return


-- Inserto ne DB
   -- FD

    INSERT INTO FD
          (TIP,KMAG,NRMAG,NRDOK,NRFRAKS,DATEDOK,KMAGLNK,NRDOKLNK,NRFRAKSLNK,DATEDOKLNK,DOK_JB,NRSERIAL,DST,
           KMAGRF,SHENIM1,SHENIM2,SHENIM3,SHENIM4,GRUP,
           NRRENDORFAT,TIPFAT,KODLM,KALIMLMZGJ,FAKLS,FADESTIN,FABUXHET,KLASIFIKIM,
           FIRSTDOK,NRDFK,POSTIM,LETER,TAGNR)
    SELECT TIP        = 'D',
           KMAG       = A.KMAG,
           NRMAG      = M.NRRENDOR,
           NRDOK      = A.NRDOK,
           NRFRAKS    = 0,
           DATEDOK    = A.DATEDOK,
           KMAGLNK    = A.KMAGLNK,
           NRDOKLNK   = A.NRDOKLNK,
           0,
           A.DATEDOK,
           0,
           '',
           'LB',
           KMAGRF     = A.KMAGLNK,
           @Shenim1,'','','',M.GRUP,0,'','',0,'','','','','',0,0,0,
           A.NRRENDOR
      FROM #TMPD A LEFT JOIN MAGAZINA M ON A.KMAG=M.KOD
  ORDER BY KMAG

    UPDATE A
       SET A.NRD=B.NRRENDOR
      FROM #TMPDSCR A INNER JOIN FD B ON A.TAGNR=B.TAGNR
     WHERE B.TAGNR<>0

   -- FDSCR

     INSERT INTO FDSCR
          (KOD,KODAF,KARTLLG,PERSHKRIM,KOMENT,NRRENDKLLG,
           NJESI,NJESINV,KONVERTART,BC,KOEFSHB,
           SASI,
           CMIMM,VLERAM,CMIMSH,VLERASH,
           CMIMBS,VLERABS,CMIMOR,VLERAOR,
           TIPKLL,KMON,PROMOC,PROMOCTIP,RIMBURSIM,GJENROWAUT,TIPKTH,TIPFR,SASIFR,VLERAFR,PESHANET,PESHABRT,
           VLERAFT,FAKLS,FADESTIN,FASTATUS,SERI,LLOGLM,KOEFICIENT,KLSART,
           NRD)
    SELECT KMAG+'.'+A.KOD+'...',A.KOD,A.KOD,B.PERSHKRIM,@Shenim1,B.NRRENDOR,
           B.NJESI,B.NJESI,1,B.BC,1,
           A.SASI,
           B.KOSTMES, VLERAM  = ROUND(A.SASI*B.KOSTMES,2),
           B.CMSH,    VLERASH = ROUND(A.SASI*B.CMSH,2),
           B.KOSTMES, VLERABS = ROUND(A.SASI*B.KOSTMES,2),
           B.KOSTMES, VLERAOR = ROUND(A.SASI*B.KOSTMES,2),
           'K','',0,'',0,0,'','',0,0,0,0,0,'','','','','',0,'',
           A.NRD
      FROM #TMPDSCR A LEFT JOIN ARTIKUJ B ON A.KOD=B.KOD
  ORDER BY A.NRD,A.KOD

    UPDATE FD
       SET TAGNR=0
     WHERE ISNULL(TAGNR,0)<>0


   -- FH
 
    INSERT INTO FH
          (TIP,KMAG,NRMAG,NRDOK,NRFRAKS,DATEDOK,KMAGLNK,NRDOKLNK,NRFRAKSLNK,DATEDOKLNK,DOK_JB,NRSERIAL,DST,
           KMAGRF,SHENIM1,SHENIM2,SHENIM3,SHENIM4,GRUP,
           NRRENDORFAT,TIPFAT,KODLM,KALIMLMZGJ,FAKLS,FADESTIN,FABUXHET,KLASIFIKIM,
           FIRSTDOK,NRDFK,POSTIM,LETER,TAGNR)
    SELECT TIP      = 'H',
           KMAG     = A.KMAG,
           NRMAG    = M.NRRENDOR,
           NRDOK    = A.NRDOK,
           NRFRAKS  = 0,
           A.DATEDOK,
           KMAGLNK  = A.KMAGLNK,
           NRDOKLNK = A.NRDOKLNK,
           0,
           A.DATEDOK,
           0,
           '',
           'LB',
           KMAGRF   = A.KMAGLNK,
           @Shenim1,'','','',M.GRUP,0,'','',0,'','','','','',0,0,0,
           A.NRRENDOR
      FROM #TMPH A LEFT JOIN MAGAZINA M ON A.KMAG=M.KOD
  ORDER BY KMAG


   -- FHSCR

    UPDATE A
       SET A.NRD=B.NRRENDOR
      FROM #TMPHSCR A INNER JOIN FH B ON A.TAGNR=B.TAGNR
     WHERE B.TAGNR<>0

     INSERT INTO FHSCR
          (KOD,KODAF,KARTLLG,PERSHKRIM,KOMENT,NRRENDKLLG,
           NJESI,NJESINV,KONVERTART,BC,KOEFSHB,
           SASI,
           CMIMM,VLERAM,CMIMSH,VLERASH,
           CMIMBS,VLERABS,CMIMOR,VLERAOR,
           TIPKLL,KMON,PROMOC,PROMOCTIP,RIMBURSIM,GJENROWAUT,TIPKTH,TIPFR,SASIFR,VLERAFR,PESHANET,PESHABRT,
           VLERAFT,FAKLS,FADESTIN,FASTATUS,SERI,LLOGLM,KOEFICIENT,KLSART,
           NRD)
    SELECT KMAG+'.'+A.KOD+'...',A.KOD,A.KOD,B.PERSHKRIM,'',0,--@Shenim1,B.NRRENDOR,
           B.NJESI,B.NJESI,1,B.BC,1,
           A.SASI,
           B.KOSTMES, VLERAM  = ROUND(A.SASI*B.KOSTMES,2),
           CMSH,      VLERASH = ROUND(A.SASI*B.CMSH,2),
           B.KOSTMES, VLERABS = ROUND(A.SASI*B.KOSTMES,2),
           B.KOSTMES, VLERAOR = ROUND(A.SASI*B.KOSTMES,2),
           'K','',0,'',0,0,'','',0,0,0,0,0,'','','','','',0,'',
           A.NRD
      FROM #TMPHSCR A LEFT JOIN ARTIKUJ B ON A.KOD=B.KOD
  ORDER BY A.NRD,A.KOD

    UPDATE FH
       SET TAGNR=0
     WHERE ISNULL(TAGNR,0)<>0

    UPDATE ARTIKUJORD
       SET LISTORDEREDMK = ISNULL(LISTORDEREDMK,'') + 
                           CASE WHEN ISNULL(LISTORDEREDMK,'')=''
                                THEN ''
                                ELSE ',' END +
                           @ListOrdOk
     WHERE NRRENDOR=@NrRendor

--  SELECT * FROM #TMPD
--  SELECT * FROM #TMPDSCR
--  SELECT * FROM #TMPH
--  SELECT * FROM #TMPHSCR

--        if Object_Id('TempDB..#TMPD') is not null
--           DROP TABLE #TMPD;
--        if Object_Id('TempDB..#TMPDSCR') is not null
--           DROP TABLE #TMPDSCR;
--        if Object_Id('TempDB..#TMPH') is not null
--           DROP TABLE #TMPH;
--        if Object_Id('TempDB..#TMPHSCR') is not null
--           DROP TABLE #TMPHSCR;
GO
