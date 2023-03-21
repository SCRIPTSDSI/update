SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   Procedure [dbo].[Isd_LikujdimFt]        -- Gjenerimi i Listes se faturave pa shlyer
(
  @PModul      Varchar(10),
  @PKod        Varchar(60),
  @PDate1      Varchar(20),
  @PDate2      Varchar(20),
  @PKMon       Varchar(20),
  @PKriterLik  Float,
  @PTbName     Varchar(50)
)

-- Gjenerimi i Listes se faturave pa shlyer. (Shiko Isd_LikujdimFt2 per shperndarje vlefte)

As 

Begin

--Exec dbo.Isd_LikujdimFt 
--     @PModul     = 'S',
--     @PKod       = 'K00001',
--     @PDate1     = '01/01/2010',
--     @PDate2     = '31/01/2013', 
--     @PKMon      = '', 
--     @PKriterLik = 0.05,
--     @PTbName    = '#FT_LIKUJDIM'

     Set NoCount On

 Declare @Kod         Varchar(60),
         @Date1       Varchar(20),
         @Date2       Varchar(20),
         @Sql         Varchar(Max),
         @ListFields  Varchar(Max),
         @TipDok      Varchar(10),
         @TregFt      Varchar(10),
         @TregLk      Varchar(10),
         @Modul       Varchar(10),
         @TableName   Varchar(20),
         @KriterLik   Real;

     Set @TableName = @PTbName;    --'#FT_LIKUJDIM'

     Set @Kod       = @PKod
     Set @Date1     = @PDate1
     Set @Date2     = @PDate2
     Set @TipDok    = 'FJ'
     Set @TregFt    = 'D'
     Set @TregLk    = 'K'
     Set @Modul     = @PModul;
     Set @KriterLik = @PKriterLik;
     if  @KriterLik<=0
         Set @KriterLik = 0.01;

     if  @Modul='F'
         begin
           Set @TipDok = 'FF'
           Set @TregFt = 'K'
           Set @TregLk = 'D'
         End;

  if Object_Id('TempDB..#FTTable1') is not null
     DROP TABLE #FTTable1;
  if Object_Id('TempDB..#FTTable2') is not null
     DROP TABLE #FTTable2;
  if Object_Id('TempDB..#FTReference') is not null
     DROP TABLE #FTReference;
  if Object_Id('TempDB..#FTDitar') is not null
     DROP TABLE #FTDitar;

        SELECT RowNumber = 0,
               KMON      = Space(10),
               KOD       = Space(60),
               TREGDK    = Space(10),
               DATEDOK   = GetDate(),
               NRFAT     = Space(60),
	           DTFAT     = GetDate(), 
	           TIPDOK    = Space(10),
	           NRDOK     = Cast(0 As Int),
               VLEFTA    = Cast(0 As Float),
               VLEFTAMV  = Cast(0 As Float),
               KURS1     = Cast(0 As Float),
               KURS2     = Cast(0 As Float),
               GJENDJE   = Cast(0 As Float),
               GJENDJEMV = Cast(0 As Float),
	           KOMENT    = Space(150),
               NRRENDOR  = Cast(0 AS Int)
          INTO #FTDitar         
         WHERE 1=2;


        SELECT *
          INTO #FTReference
          FROM
            (
        SELECT NRRENDOR,KOD,PERSHKRIM
          FROM KLIENT 
         WHERE @Modul='S'
     UNION ALL
        SELECT NRRENDOR,KOD,PERSHKRIM
          FROM FURNITOR
         WHERE @Modul='F'
             ) A


        INSERT INTO #FTDitar
              (RowNumber,KMON,KOD,DATEDOK,NRFAT,TREGDK,VLEFTA,VLEFTAMV,KURS1,KURS2,DTFAT,TIPDOK,NRDOK,KOMENT,NRRENDOR)

        SELECT ROW_NUMBER() OVER(--PARTITION BY KOD 
                                 ORDER BY CASE WHEN DTFAT Is Null Or DTFAT=0 Or DTFAT=Dbo.DATEVALUE('01/01/1900') 
                                               THEN DATEDOK 
                                               ELSE DTFAT END, NRFAT, KMON, VLEFTA, NRRENDOR DESC) AS RowNumber,
-- 19.12.2013                                  ELSE DTFAT END, NRFAT, KMON, NRRENDOR DESC) AS RowNumber,
               KMON,@Kod,DATEDOK,ISNULL(NRFAT,''),TREGDK,VLEFTA,VLEFTAMV,KURS1,KURS2,ISNULL(DTFAT,0),TIPDOK,NRDOK,KOMENT,NRRENDOR
          FROM DFU
		 WHERE @Modul='F' And 
               Case When CharIndex('.',KOD)>0 Then Left(KOD,CharIndex('.',KOD)-1) Else KOD End = @Kod And 
			   DATEDOK>=DBO.DATEVALUE(@Date1) And DATEDOK<=DBO.DATEVALUE(@Date2)

     UNION ALL

        SELECT ROW_NUMBER() OVER(--PARTITION BY KOD 
                                 ORDER BY CASE WHEN DTFAT Is Null Or DTFAT=0 Or DTFAT=Dbo.DATEVALUE('01/01/1900') 
                                               THEN DATEDOK 
                                               ELSE DTFAT END, NRFAT, KMON, VLEFTA, NRRENDOR DESC) AS RowNumber,
-- 19.12.2013                                  ELSE DTFAT END, NRFAT, KMON, NRRENDOR DESC) AS RowNumber,
               KMON,@Kod,DATEDOK,ISNULL(NRFAT,''),TREGDK,VLEFTA,VLEFTAMV,KURS1,KURS2,ISNULL(DTFAT,0),TIPDOK,NRDOK,KOMENT,NRRENDOR
          FROM DKL
		 WHERE @Modul='S' And 
               Case When CharIndex('.',KOD)>0 Then Left(KOD,CharIndex('.',KOD)-1) Else KOD End = @Kod And 
			   DATEDOK>=DBO.DATEVALUE(@Date1) And DATEDOK<=DBO.DATEVALUE(@Date2)

        SELECT GJENDJE   = SUM(CASE WHEN B.TREGDK=@TregFt THEN B.VLEFTA   ELSE 0-B.VLEFTA END),
               GJENDJEMV = SUM(CASE WHEN B.TREGDK=@TregFt THEN B.VLEFTAMV ELSE 0-B.VLEFTAMV END),
               KMON,NRFAT,DTFAT
          INTO #FTGjendje 
          FROM #FTDitar B
         WHERE (ISNULL(NRFAT,'')<>'' AND DTFAT is not null)
      GROUP BY KMON,NRFAT,DTFAT
      --HAVING ABS(SUM(CASE WHEN B.TREGDK='D' THEN B.VLEFTA ELSE 0-B.VLEFTA END))<=0.01




        UPDATE A
           SET GJENDJE   = ISNULL((SELECT SUM(ISNULL(B.GJENDJE,0))
                                     FROM #FTGjendje B
                                    WHERE B.KMON=A.KMON AND B.NRFAT=A.NRFAT AND B.DTFAT=A.DTFAT
                                 GROUP BY KMON,NRFAT,DTFAT),0),
               GJENDJEMV = ISNULL((SELECT SUM(ISNULL(B.GJENDJEMV,0))
                                     FROM #FTGjendje B
                                    WHERE B.KMON=A.KMON AND B.NRFAT=A.NRFAT AND B.DTFAT=A.DTFAT
                                 GROUP BY KMON,NRFAT,DTFAT),0)
          FROM #FTDitar A
         WHERE ISNULL(A.NRFAT,'')<>'' AND (A.DTFAT is not null);

-- Fshi te Likujduarat
        DELETE 
          FROM #FTDitar 
         WHERE ISNULL(NRFAT,'')<>'' AND (DTFAT is not null) AND ABS(ISNULL(GJENDJE,0))<=@KriterLik;  --0.01;

-- Fshi likujditetet e lidhura (qofte dhe gabim)
        DELETE 
          FROM #FTDitar 
         WHERE TREGDK=@TregLk And (Not (ISNULL(NRFAT,'')='' OR ISNULL(NRFAT,'')='0' OR (DTFAT is null)));

        UPDATE #FTDitar 
           SET GJENDJE   = 0, 
               GJENDJEMV = 0 
         WHERE TREGDK=@TregLk;

--    DELETE 
--      FROM #FTDitar 
--     WHERE ISNULL(NRFAT,'')<>'' AND DTFAT is not null AND TREGDK=@TregLk

-- Do te ishte me mire qe kur te luaje me date te mos afishohen me te kaluarat 
-- pavaresisht te mbyllura ose jo, por kjo te piqet me mire sepse duhet vertetuar

--      DELETE 
--        FROM #FTDitar 
--       WHERE EXISTS 
--           ( SELECT SUM(CASE WHEN B.TREGDK='D' THEN B.VLEFTA ELSE 0-B.VLEFTA END)
--               FROM #FTDitar B
--              WHERE #FTDitar.NRFAT=B.NRFAT
--           GROUP BY NRFAT
--             HAVING ABS(SUM(CASE WHEN B.TREGDK='D' THEN B.VLEFTA ELSE 0-B.VLEFTA END))<=0.01);


        CREATE INDEX FTIdx_NrRendor ON #FTDitar(ROWNUMBER);

        SELECT *
          INTO #FTTable1
          FROM

             (

		  SELECT A.KMON,                     -- Klient
				 A.KURS1,
				 A.KURS2,
				 A.KOD,
				 A.VLEFTA,
				 A.VLEFTAMV,
                 A.GJENDJE,
                 A.GJENDJEMV,
				 TOTALFATURA   = ( SELECT IsNull(Sum(GJENDJE),0) 
									 FROM #FTDitar B 
									WHERE B.KMON=A.KMON And TREGDK=@TregFt AND B.ROWNUMBER<A.ROWNUMBER),
		 
				 TOTALSHLYER   = ( SELECT IsNull(Sum(VLEFTA),0)
                                     FROM #FTDitar B 
                                    WHERE (B.KMON=A.KMON And TREGDK=@TregLk)),

                 PJESASHLYER   = CAST(0 AS FLOAT),

				 PJESASHLYERMV = A.VLEFTAMV - A.GJENDJEMV + 
                                 Case When    (SELECT IsNull(Sum(GJENDJEMV),0)           
											     FROM #FTDitar B 
									            WHERE TREGDK=@TregFt AND B.ROWNUMBER<A.ROWNUMBER) 

										      - 

										      (SELECT IsNull(Sum(VLEFTAMV),0) 
											     FROM #FTDitar B 
										        WHERE TREGDK=@TregLk) >= 0  

									  Then 0

									  When    (SELECT IsNull(Sum(GJENDJEMV),0)          
											     FROM #FTDitar B 
									            WHERE TREGDK=@TregFt AND B.ROWNUMBER<A.ROWNUMBER) 

										      - 

										      (SELECT IsNull(Sum(VLEFTAMV),0) 
											     FROM #FTDitar B 
											    WHERE TREGDK=@TregLk) <=      0 - VLEFTAMV 

									  Then    GJENDJEMV

									  Else  -((SELECT IsNull(Sum(GJENDJEMV),0)        
											     FROM #FTDitar B 
									            WHERE TREGDK=@TregFt AND B.ROWNUMBER<A.ROWNUMBER)  
											   - 
										      (SELECT IsNull(Sum(VLEFTAMV),0) 
											     FROM #FTDitar B 
											    WHERE TREGDK=@TregLk))

									  End,
				 A.NRFAT,
				 A.DTFAT, 
				 A.DATEDOK,
				 A.TIPDOK,
				 A.NRDOK,
				 A.KOMENT,
				 A.NRRENDOR,
				 NIPT          = IsNull(A1.NIPT,''),
				 NRFATURE      = Case When A.TIPDOK=@TipDok Then IsNull(A1.NRDSHOQ, '')
									  When A.TIPDOK='SP'    Then IsNull(A2.NRDOKREF,'') 
									  Else '' End,

				 DATEFATURE    = IsNull(A1.DTDSHOQ,IsNull(A2.DATEDOKREF,A.DATEDOK)),
				 AFATPAGESE    = Case When A.TIPDOK=@TipDok Then IsNull(A1.DTAF,0)
									  When A.TIPDOK='SP'    Then IsNull(A2.OPERNR,0) 
									  Else 0 End,

				 DITENGADOK    = DateDiff(Day,IsNull(A1.DTDSHOQ,IsNull(A2.DATEDOKREF,A.DATEDOK)),GetDate()),
				 DITENGAAFAT   = DateDiff(Day,DateAdd(Day,Case When A.TIPDOK=@TipDok Then IsNull(A1.DTAF,0)
															   When A.TIPDOK='SP'    Then IsNull(A2.OPERNR,0) 
															   Else 0 End,
													  IsNull(A1.DTDSHOQ,IsNull(A2.DATEDOKREF,A.DATEDOK))),
											  GetDate()),
				 A1.NRSERIAL,
                 A.ROWNUMBER
		  --INTO #FTTable1 
			FROM #FTDitar A LEFT JOIN FJ    A1 ON (A.NRRENDOR=A1.NRDITAR AND A.TIPDOK =@TipDok)
					        LEFT JOIN VSSCR A2 ON (A.NRRENDOR=A2.NRDITAR AND A.TIPDOK ='SP' AND A2.TIPKLL=@Modul)

		   Where @Modul='S' And A.TREGDK=@TregFt  And   --IsNull(A.KMON,'')=''   And A.KOD=@Kod   And 	
                 A.DATEDOK>=DBO.DATEVALUE(@Date1) And A.DATEDOK<=DBO.DATEVALUE(@Date2)

       UNION ALL

		  SELECT A.KMON,                           -- Funitor
				 A.KURS1,
				 A.KURS2,
				 A.KOD,
				 A.VLEFTA,
				 A.VLEFTAMV,
                 A.GJENDJE,
                 A.GJENDJEMV,
				 TOTALFATURA   = ( SELECT IsNull(Sum(GJENDJE),0) 
									 FROM #FTDitar B 
									WHERE B.KMON=A.KMON And TREGDK=@TregFt AND B.ROWNUMBER<A.ROWNUMBER),
							      --WHERE B.KMON=A.KMON AND B.KOD=A.KOD AND TREGDK=@TregFt AND B.ROWNUMBER<A.ROWNUMBER),
		 
				 TOTALSHLYER   = ( SELECT IsNull(Sum(VLEFTA),0)
                                     FROM #FTDitar B 
                                    WHERE (B.KMON=A.KMON And TREGDK=@TregLk)),
                                  --WHERE (B.KMON=A.KMON AND B.KOD=A.KOD AND TREGDK=@TregLk)),

                 PJESASHLYER   = CAST(0 AS FLOAT),

				 PJESASHLYERMV = A.VLEFTAMV - A.GJENDJEMV + 
                                 Case When    (SELECT IsNull(Sum(GJENDJEMV),0)           
											     FROM #FTDitar B 
									            WHERE TREGDK=@TregFt AND B.ROWNUMBER<A.ROWNUMBER) --B.KMON=A.KMON And 
									          --WHERE B.KMON=A.KMON AND B.KOD=A.KOD AND TREGDK=@TregFt AND B.ROWNUMBER<A.ROWNUMBER)
										      - 
										      (SELECT IsNull(Sum(VLEFTAMV),0) 
											     FROM #FTDitar B 
										        WHERE TREGDK=@TregLk) >= 0  --B.KMON=A.KMON And 
										      --WHERE B.KMON=A.KMON AND B.KOD=A.KOD AND TREGDK=@TregLk) >= 0 
									  Then    0

									  When    (SELECT IsNull(Sum(GJENDJEMV),0)          
											     FROM #FTDitar B 
									            WHERE TREGDK=@TregFt AND B.ROWNUMBER<A.ROWNUMBER) --B.KMON=A.KMON And 
									          --WHERE B.KMON=A.KMON AND B.KOD=A.KOD AND TREGDK=@TregFt AND B.ROWNUMBER<A.ROWNUMBER)
										      - 
										      (SELECT IsNull(Sum(VLEFTAMV),0) 
											     FROM #FTDitar B 
											    WHERE TREGDK=@TregLk) <= -VLEFTAMV  --B.KMON=A.KMON And 
											  --WHERE B.KMON=A.KMON AND B.KOD=A.KOD AND TREGDK=@TregLk) <= -VLEFTA 
									  Then    GJENDJEMV

									  Else  -((SELECT IsNull(Sum(GJENDJEMV),0)        
											     FROM #FTDitar B 
									            WHERE TREGDK=@TregFt AND B.ROWNUMBER<A.ROWNUMBER)  -- B.KMON=A.KMON And 
									          --WHERE B.KMON=A.KMON AND B.KOD=A.KOD AND TREGDK=@TregFt AND B.ROWNUMBER<A.ROWNUMBER)
											   - 
										      (SELECT IsNull(Sum(VLEFTAMV),0) 
											     FROM #FTDitar B 
											    WHERE TREGDK=@TregLk))               -- B.KMON=A.KMON And 
											  --WHERE B.KMON=A.KMON AND B.KOD=A.KOD AND TREGDK=@TregLk))
									  End,
				 A.NRFAT,
				 A.DTFAT, 
				 A.DATEDOK,
				 A.TIPDOK,
				 A.NRDOK,
				 A.KOMENT,
				 A.NRRENDOR,
				 NIPT          = IsNull(A1.NIPT,''),
				 NRFATURE      = Case When A.TIPDOK=@TipDok Then IsNull(A1.NRDSHOQ, '')
									  When A.TIPDOK='SP'    Then IsNull(A2.NRDOKREF,'') 
									  Else '' End,

				 DATEFATURE    = IsNull(A1.DTDSHOQ,IsNull(A2.DATEDOKREF,A.DATEDOK)),
				 AFATPAGESE    = Case When A.TIPDOK=@TipDok Then IsNull(A1.DTAF,0)
									  When A.TIPDOK='SP'    Then IsNull(A2.OPERNR,0) 
									  Else 0 End,

				 DITENGADOK    = DateDiff(Day,IsNull(A1.DTDSHOQ,IsNull(A2.DATEDOKREF,A.DATEDOK)),GetDate()),
				 DITENGAAFAT   = DateDiff(Day,DateAdd(Day,Case When A.TIPDOK=@TipDok Then IsNull(A1.DTAF,0)
															   When A.TIPDOK='SP'    Then IsNull(A2.OPERNR,0) 
															   Else 0 End,
													  IsNull(A1.DTDSHOQ,IsNull(A2.DATEDOKREF,A.DATEDOK))),
											  GetDate()),
				 A1.NRSERIAL,
                 A.ROWNUMBER
			FROM #FTDitar A LEFT JOIN FF    A1 ON (A.NRRENDOR=A1.NRDITAR AND A.TIPDOK =@TipDok)
					        LEFT JOIN VSSCR A2 ON (A.NRRENDOR=A2.NRDITAR AND A.TIPDOK ='SP' AND A2.TIPKLL=@Modul)

		   WHERE @Modul='F' And A.TREGDK=@TregFt  And   --IsNull(A.KMON,'')='' And A.KOD = @Kod And 
	             A.DATEDOK>=DBO.DATEVALUE(@Date1) And A.DATEDOK<=DBO.DATEVALUE(@Date2)

            ) A

-- tek  Unioni me siper ...
--				 PJESASHLYER =     A.VLEFTA - A.GJENDJE +
--                                   Case When      (SELECT IsNull(Sum(GJENDJE),0)       -- VLEFTA    
--											     FROM #FTDitar B 
--									            WHERE B.KMON=A.KMON And TREGDK=@TregFt AND B.ROWNUMBER<A.ROWNUMBER)
--									          --WHERE B.KMON=A.KMON AND B.KOD=A.KOD AND TREGDK=@TregFt AND B.ROWNUMBER<A.ROWNUMBER)
--										      - 
--										      (SELECT IsNull(Sum(VLEFTA),0) 
--											     FROM #FTDitar B 
--										        WHERE B.KMON=A.KMON And TREGDK=@TregLk ) >= 0 
--										      --WHERE B.KMON=A.KMON AND B.KOD=A.KOD AND TREGDK=@TregLk ) >= 0 
--									Then 0
--
--									When      (SELECT IsNull(Sum(GJENDJE),0)          
--											     FROM #FTDitar B 
--									            WHERE B.KMON=A.KMON And TREGDK=@TregFt AND B.ROWNUMBER<A.ROWNUMBER)
--									          --WHERE B.KMON=A.KMON AND B.KOD=A.KOD AND TREGDK=@TregFt AND B.ROWNUMBER<A.ROWNUMBER)
--										      - 
--										      (SELECT IsNull(Sum(VLEFTA),0) 
--											     FROM #FTDitar B 
--											    WHERE B.KMON=A.KMON And TREGDK=@TregLk ) <= - GJENDJE 
--											  --WHERE B.KMON=A.KMON AND B.KOD=A.KOD AND TREGDK=@TregLk ) <= - VLEFTA 
--									Then GJENDJE
--
--									Else  -  ((SELECT IsNull(Sum(GJENDJE),0)        
--											     FROM #FTDitar B 
--									            WHERE B.KMON=A.KMON And TREGDK=@TregFt AND B.ROWNUMBER<A.ROWNUMBER)
--									          --WHERE B.KMON=A.KMON AND B.KOD=A.KOD AND TREGDK=@TregFt AND B.ROWNUMBER<A.ROWNUMBER)
--											  - 
--										      (SELECT IsNull(Sum(VLEFTA),0) 
--											     FROM #FTDitar B 
--											    WHERE B.KMON=A.KMON And TREGDK=@TregLk))
--											  --WHERE B.KMON=A.KMON AND B.KOD=A.KOD AND TREGDK=@TregLk))
--									End,

--SELECT TIP='3',* FROM #FTTable1 ORDER BY NRFATURE


  UPDATE #FTTable1
     SET PJESASHLYER   = Round(Case When  IsNull(KMON,'')='' 
                                    Then  PJESASHLYERMV 
                                    Else (PJESASHLYERMV*KURS1)/KURS2 End,2),
         PJESASHLYERMV = Round(PJESASHLYERMV,2)


  SELECT A.NRRENDOR,
         A.DATEDOK,
         TOTALFATURA   = Round(A.TOTALFATURA,2),
         TOTALSHLYER   = Round(A.TOTALSHLYER,2),
         A.KOD,
         A.KMON,
         A.KURS1,
         A.KURS2,
         VLEFTA        = Round(A.VLEFTA,2),
         VLEFTAMV      = Round(A.VLEFTAMV,2),
         PJESASHLYER   = Round(PJESASHLYER,2),
         PJESASHLYERMV = Round(PJESASHLYERMV,2),
         A.NRFAT,
         A.NRDOK,
         A.TIPDOK,
         A.KOMENT,
         NRFATURE,
         DATEFATURE,
         AFATPAGESE,
         EMERTIM      = B.PERSHKRIM,
         PERSHKRIMMN  = M.PERSHKRIM,
         M.SIMBOL,
         DETYRIM      = Round(VLEFTA  -PJESASHLYER,2),
         DETYRIMMV    = Round(VLEFTAMV-PJESASHLYERMV,2),
         LIKUJDIM     = Cast(0 As Float),
         LIKUJDIMMV   = Cast(0 As Float),
         ACTIV        = Cast(1 As Bit),
         ROWNUMBER,
         TROW         = Cast(0 As Bit)
    INTO #FTTable2
    FROM #FTTable1 A LEFT JOIN #FTReference B ON A.KOD=B.KOD 
                     LEFT JOIN MONEDHA M      ON A.KMON=M.KOD
   WHERE Abs(VLEFTA-PJESASHLYER)>=@KriterLik                    
ORDER BY A.KOD,A.DATEDOK,NRFATURE,A.NRRENDOR;
 
   Select @ListFields = dbo.Isd_ListFields2Tables(@TableName,'#FTTable2','');

   Select @Sql = '

 TRUNCATE TABLE '+@TableName+';
    
   INSERT INTO '+@TableName+' 
         ('+@ListFields+') 
   SELECT '+@ListFields+'
     FROM #FTTable2 A; ';

-- Print @Sql 
   Exec (@Sql);

  if Object_Id('TempDB..#FTTable1') is not null
     DROP TABLE #FTTable1;

  if Object_Id('TempDB..#FTTable2') is not null
     DROP TABLE #FTTable2;

  if Object_Id('TempDB..#FTReference') is not null
     DROP TABLE #FTReference;

  if Object_Id('TempDB..#FTDitar') is not null
     DROP TABLE #FTDitar;
  if Exists (Select NAME From Sys.Indexes Where NAME=N'FTIdx_NrRendor')
     DROP INDEX FTIdx_NrRendor ON #FTDitar;

   Exec ('SELECT * FROM '+@TableName+' A ORDER BY ROWNUMBER; --A.KOD,A.DATEFATURE,NRFATURE, KMON;');

End;




									
GO
