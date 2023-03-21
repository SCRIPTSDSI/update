SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   Procedure [dbo].[Isd_OrderItemsCreateMg_ParaKonv]
( 
  @PNrRendor  Int,
  @PTip       Varchar(10),
  @PListRef   Varchar(Max)
 )
As



       SET NOCOUNT ON

   DECLARE @NrRendor Int


-- Krijimi i dokumentave ne Baze

       SET @NrRendor = @PNrRendor

        IF OBJECT_ID('TempDB..#TMPD') IS NOT NULL
           DROP TABLE #TMPD;
        IF OBJECT_ID('TempDB..#TMPDSCR') IS NOT NULL
           DROP TABLE #TMPDSCR;
        IF OBJECT_ID('TempDB..#TMPH') IS NOT NULL
           DROP TABLE #TMPH;
        IF OBJECT_ID('TempDB..#TMPHSCR') IS NOT NULL
           DROP TABLE #TMPHSCR;


   DECLARE @NrDokMg    Int,
           @KMag       Varchar(10),
        -- @Tip        Varchar(10),
           @Shenim1    Varchar(150),
           @Shenim2    Varchar(150),
           @TipMk      Varchar(10),
           @TipDq      Varchar(10),
           @ListRef    Varchar(Max),
           @ListOrdMk  Varchar(Max),
           @ListOrdDq  Varchar(Max),
        -- @ListOrdOk  Varchar(Max),
           @Sql        Varchar(Max),
           @DateDok    DateTime;

    -- SET @Tip      = 'M';

       IF  @PTip='M' 
           BEGIN
             SET @TipMk = @pTip
             SET @TipDq = '';
           END
       ELSE
       IF  @PTip='D' 
           BEGIN
             SET @TipMk = '';
             SET @TipDq = @PTip
           END
       ELSE
    -- IF  @PTip='' OR @PTip='*'
           BEGIN
             SET @TipMk = 'M';
             SET @TipDq = 'D';
           END;

       SET @ListRef = @PListRef;
       IF  @ListRef='*'
           SET @ListRef = '';


       SET @KMag     = (SELECT KMAG          FROM ORDERITEMS WHERE NRRENDOR=@NrRendor);
       SET @DateDok  = (SELECT DATEDOKCREATE FROM ORDERITEMS WHERE NRRENDOR=@NrRendor);
       SET @Shenim1  = (SELECT SHENIM1       FROM ORDERITEMS WHERE NRRENDOR=@NrRendor);
    -- SET @Shenim2  = (SELECT SHENIM1       FROM ORDERITEMS WHERE NRRENDOR=@NrRendor);

       SET @NrDokMg  = (SELECT MAX(NRDOK) FROM FD WHERE KMAG=@KMag   AND YEAR(DATEDOK)=YEAR(@DateDok));


    SELECT NRRENDOR  =                      ROW_NUMBER() OVER(ORDER BY B.KODAF),
           KMAG      = MAX(A.KMAG),
           DATEDOK   = MAX(A.DATEDOKCREATE),
           NRDOK     = ISNULL(@NrDokMg,0) + ROW_NUMBER() OVER(ORDER BY B.KODAF),
           KMAGLNK   = B.KODAF,
           NRDOKLNK  = ISNULL((SELECT MAX(NRDOK) FROM FH WHERE KMAG=B.KODAF AND YEAR(DATEDOK)=YEAR(@DateDok)),0) + 1 
      INTO #TMPD
      FROM ORDERITEMS A INNER JOIN ORDERITEMSSCR B ON A.NRRENDOR=B.NRD
     WHERE A.NRRENDOR = @NrRendor AND (TIPKLL=@TipMk OR TIPKLL=@TipDq)
  GROUP BY B.KODAF


    SELECT B.KOD,
           KMAG       = A.KMAG,
           KMAGLNK    = B.KODAF,
           B.SASI,
           NRD        = T1.NRRENDOR,
           TAGNR      = T1.NRRENDOR,
           TIPORD     = B.TIPKLL
      INTO #TMPDSCR
      FROM ORDERITEMS A INNER JOIN ORDERITEMSSCR B  ON A.NRRENDOR = B.NRD
                        LEFT  JOIN #TMPD         T1 ON T1.KMAGLNK=B.KODAF
     WHERE A.NRRENDOR=@NrRendor AND (TIPKLL=@TipMk OR TIPKLL=@TipDq) AND ABS(B.SASI)>=0.01
  ORDER BY B.KODAF,B.KOD

        IF @ListRef<>''
           BEGIN
             SET @Sql = ' 
      DELETE 
        FROM #TMPD
       WHERE CHARINDEX('',''+KMAGLNK+'','','',''+'''+@ListRef+'''+'','')=0; 

      DELETE 
        FROM #TMPDSCR
       WHERE CHARINDEX('',''+KMAGLNK+'','','',''+'''+@ListRef+'''+'','')=0 ';
          -- PRINT @Sql;
             EXEC (@Sql);
           END;

/*
        IF @ListRef<>''
           BEGIN
             SET @Sql = ' 
    DELETE FROM #TMPD    WHERE NOT (KMAGLNK In ('+@ListRef+')) 
    DELETE FROM #TMPDSCR WHERE NOT (KMAGLNK In ('+@ListRef+')) ';
             EXEC (@Sql);
           END;
*/

    -- SET @ListOrdOk = '';
       SET @ListOrdMk = '';
       SET @ListOrdDq = '';
    SELECT --@ListOrdOk = @ListOrdOk + ',' + KMAGLNK,
           @ListOrdMk = @ListOrdMk + Case When TIPORD=@TipMk Then ','+KMAGLNK ELSE '' END,
           @ListOrdDq = @ListOrdDq + Case When TIPORD=@TipDq Then ','+KMAGLNK ELSE '' END
      FROM #TMPDSCR
  GROUP BY KMAGLNK,TIPORD
  ORDER BY KMAGLNK,TIPORD;

     -- IF SUBSTRING(@ListOrdOk,1,1)=','
     --    SET @ListOrdOk = SUBSTRING(@ListOrdOk,2,Len(@ListOrdOk));
        IF SUBSTRING(@ListOrdMk,1,1)=','
           SET @ListOrdMk = SUBSTRING(@ListOrdMk,2,Len(@ListOrdMk));
        IF SUBSTRING(@ListOrdDq,1,1)=','
           SET @ListOrdDq = SUBSTRING(@ListOrdDq,2,Len(@ListOrdDq));


    DELETE 
      FROM #TMPD
     WHERE NOT EXISTS (SELECT * FROM #TMPDSCR WHERE #TMPD.NRRENDOR=#TMPDSCR.NRD);

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


-- SELECT * FROM #TmpD
-- SELECT * FROM #TmpDScr
-- SELECT * FROM #TmpH
-- SELECT * FROM #TmpHScr
-- RETURN



-- INSERT NE DB

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

    UPDATE ORDERITEMS
       SET LISTORDEREDMK = ISNULL(LISTORDEREDMK,'') + CASE WHEN ISNULL(LISTORDEREDMK,'')<>'' AND @ListOrdMk<>'' THEN ',' ELSE '' END + @ListOrdMk,
           LISTORDEREDDQ = ISNULL(LISTORDEREDDQ,'') + CASE WHEN ISNULL(LISTORDEREDDQ,'')<>'' AND @ListOrdDq<>'' THEN ',' ELSE '' END + @ListOrdDq
     WHERE NRRENDOR=@NrRendor

--  SELECT * FROM #TMPD
--  SELECT * FROM #TMPDSCR
--  SELECT * FROM #TMPH
--  SELECT * FROM #TMPHSCR

--        IF OBJECT_ID('TempDB..#TMPD') IS NOT NULL
--           DROP TABLE #TMPD;
--        IF OBJECT_ID('TempDB..#TMPDSCR') IS NOT NULL
--           DROP TABLE #TMPDSCR;
--        IF OBJECT_ID('TempDB..#TMPH') IS NOT NULL
--           DROP TABLE #TMPH;
--        IF OBJECT_ID('TempDB..#TMPHSCR') IS NOT NULL
--           DROP TABLE #TMPHSCR;
GO
