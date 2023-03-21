SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Stored Procedure




 --EXEC [Isd_FisDisplayLog] 'A.DATEDOK>=DBO.DATEVALUE(''01/05/2021'') AND A.DATEDOK<=DBO.DATEVALUE(''31/05/2021'')', 'A.DATEDOK>=DBO.DATEVALUE(''01/05/2021'') AND A.DATEDOK<=DBO.DATEVALUE(''31/05/2021'')','##AAAA';



CREATE Procedure [dbo].[Isd_FisDisplayLog]
(
  @pWhereFJ         Varchar(MAX),
  @pWhereFF         Varchar(MAX),
  @pTmpTableName    Varchar(40)
 )

AS

         SET NOCOUNT ON;

     DECLARE @sSql              nVarchar(Max),
	         @sWhereFJ           Varchar(Max),
	         @sWhereFF           Varchar(Max),
			 @sFieldsDisplMas    Varchar(Max),
			 @sPromptsDisplMas   Varchar(Max),
			 @sFieldsDisplDet    Varchar(Max),
			 @sPromptsDisplDet   Varchar(Max),
			 @TmpTableName       Varchar(40),
		     @sTmpTbl            Varchar(40);

         SET @sWhereFJ         = ISNULL(@pWhereFJ,'');
         SET @sWhereFF         = ISNULL(@pWhereFF,'');
		 SET @TmpTableName     = ISNULL(@pTmpTableName,'');

--       SET @sFieldsDisplMas  = 'Tip,NrDok,       DateDok,KodFKL,Shenim1,Nipt,KMag,    VlPaTvsh,VlTvsh,VlerTot,FisKodReason';
--	     SET @sPromptsDisplMas = 'Dok,Nr dokumenti,Date,   Bleres,Emertim,Nipt,Magazine,VlPaTvsh,Tvsh,  Vlefte, Aresye';

         SET @sFieldsDisplMas  = 'NrRenditje,Tip,NrDok,Fiskalizuar, FISSTATUS,       DateDok,KodFKL,Shenim1,Nipt,KMag,    VlPaTvsh,VlTvsh,VlerTot,FISFIC, PromptPdf,   FisKodReason,TRow';
         SET @sPromptsDisplMas = 'NrRenditje,Dokument,Nr dokumenti,Fiskalizuar, Status e-fature,Date,   Bleres,Emertim,Nipt,Magazine,VlPaTvsh,Tvsh,  Vlefte, Kod FIC,DokumentPdf,Aresye,      Zgjedhur';

		 SET @sFieldsDisplDet  = 'KodAf,Pershkrim,Njesi,Sasi,VlPaTvsh,VlTvsh,VleraBs';
		 SET @sPromptsDisplDet = 'Kod,  Emertim,  Njesi,Sasi,VlPaTvsh,Tvsh,  Vlefte';

          IF OBJECT_ID('TEMPDB..#TmpFature') IS NOT NULL
             DROP TABLE #TmpFature;

       -- IF OBJECT_ID('TEMPDB..#TmpFjFiscal') IS NOT NULL
       --    DROP TABLE #TmpFjFiscal;

--      EXEC dbo.Isd_FisDisplayLog '  ((DATEDOK=CONVERT(DATETIME,''15/05/2021'',104))) AND A=A1','#AAAA';

      SELECT NRRENDOR=CAST(0 AS BIGINT),SELECTED=CAST(0 AS BIT),TIP=LLOJDOK
	    INTO #TmpFature
	    FROM FJ
       WHERE 1=2;

   RAISERROR (N'
_______________________________________________________________________________

  1. Fillim procedura per afishim dokumenta fiskalizimi (Temp)
_______________________________________________________________________________', 0, 1) WITH NOWAIT;

	     SET @sSql = '
	  INSERT INTO #TmpFature
	        (NRRENDOR,SELECTED,TIP)
	  SELECT A.NRRENDOR,CAST(0 AS BIT),TIP=''FJ''
	    FROM FJ A 
	   WHERE 1=1;
	   
	  INSERT INTO #TmpFature
	        (NRRENDOR,SELECTED,TIP)
	  SELECT A.NRRENDOR,CAST(0 AS BIT),TIP=''FF''
	    FROM FF A 
	   WHERE 2=2;';

          IF @sWhereFJ<>''
	         SET @sSql = REPLACE(@sSql,'1=1',@sWhereFJ);
			 
          IF @sWhereFF<>''
	         SET @sSql = REPLACE(@sSql,'2=2',@sWhereFF);


			 PRINT(@sSql);
        EXEC (@sSql);

			 

      CREATE INDEX IndTmp ON #TmpFature(NRRENDOR);


   RAISERROR (N'
_______________________________________________________________________________

  2. Fillim procedura per afishim dokumenta fiskalizimi (FJ) 
_______________________________________________________________________________', 0, 1) WITH NOWAIT;

-- FJ

      SELECT -- per koludim Top 50 
	         NrRenditje = Row_Number() OVER(PARTITION BY YEAR(A.DATEDOK) ORDER BY YEAR(A.DATEDOK),A.NRDOK),
	         A.TROW,A.FISKALIZUAR,A.FISSTATUS,B.TIP,
             A.NRDOK,A.DATEDOK,A.KODFKL,A.SHENIM1,A.NIPT,A.KMAG,A.VLPATVSH,A.VLTVSH,A.VLERTOT,

			 PromptPdf       = LEFT(CASE WHEN LTRIM(RTRIM(ISNULL(A.FISPDF,'')))<>'' THEN 'Gjeneruar PDF' ELSE 'Nuk ka' END+Space(30),30),

			 A.FISKODREASON,
			 FISFIC=CONVERT(VARCHAR(100),A.FISFIC),A.FISEIC,A.FISPDF,
		     A.ISDOCFISCAL, A.FISPROCES,A.FISMENPAGESE,A.FISTIPDOK,A.FISKODOPERATOR,
			 A.FISBUSINESSUNIT,A.FISTCR,A.FISUUID,A.FISQRCODELINK, A.FISRELATEDFIC,
			 A.FISLASTERRORFIC,A.FISLASTERROREIC,A.FISLASTERRORTEXTFIC,A.FISLASTERRORTEXTEIC,
			 
		  -- A.FISFIC,A.FISKODREASON,A.FISEIC,A.FISPDF,A.ISDOCFISCAL,A.FISPROCES,A.FISSTATUS,A.FISMENPAGESE,A.FISTIPDOK,A.FISKODOPERATOR,
          -- A.FISBUSINESSUNIT,A.FISTCR,A.FISUUID,A.FISQRCODELINK, A.FISRELATEDFIC,
		  -- A.FISLASTERRORFIC,A.FISLASTERROREIC,A.FISLASTERRORTEXTFIC,A.FISLASTERRORTEXTEIC,
		  -- A.FISIIC,A.FISIICSIG,A.FISRESPONSEXMLFIC,A.FISRESPONSEXMLEIC,A.FISXMLSTRING,A.FISXMLSIGNED,
			 
			 NRRENDOR        = CAST(A.NRRENDOR AS BIGINT),
			 
             FieldsDisplMas  = @sFieldsDisplMas,
			 PromptsDisplMas = @sPromptsDisplMas,
			 FieldsDisplDet  = @sFieldsDisplDet,
			 PromptsDisplDet = @sPromptsDisplDet

        INTO #TmpFtFiscal

        FROM FJ A INNER JOIN #TmpFature B ON A.NRRENDOR=B.NRRENDOR AND B.TIP='FJ'

--  ORDER BY YEAR(DATEDOK), NrRenditje;


   RAISERROR (N'
_______________________________________________________________________________

  3. Fillim procedura per afishim dokumenta fiskalizimi (FF)
_______________________________________________________________________________', 0, 1) WITH NOWAIT;

-- FF

	  INSERT INTO #TmpFtFiscal
	        (NrRenditje,
	         TROW,FISKALIZUAR,FISSTATUS,TIP,
             NRDOK,DATEDOK,KODFKL,SHENIM1,NIPT,KMAG,VLPATVSH,VLTVSH,VLERTOT,

			 PromptPdf,

			 FISKODREASON,
	         FISFIC,FISEIC,FISPDF,
		     ISDOCFISCAL, FISPROCES,FISMENPAGESE,FISTIPDOK,FISKODOPERATOR,
			 FISBUSINESSUNIT,FISTCR,FISUUID,FISQRCODELINK,FISRELATEDFIC,
			 FISLASTERRORFIC,FISLASTERROREIC,FISLASTERRORTEXTFIC,FISLASTERRORTEXTEIC,
			 
		  -- A.FISFIC,A.FISKODREASON,A.FISEIC,A.FISPDF,A.ISDOCFISCAL,A.FISPROCES,A.FISSTATUS,A.FISMENPAGESE,A.FISTIPDOK,A.FISKODOPERATOR,
          -- A.FISBUSINESSUNIT,A.FISTCR,A.FISUUID,A.FISQRCODELINK, A.FISRELATEDFIC,
		  -- A.FISLASTERRORFIC,A.FISLASTERROREIC,A.FISLASTERRORTEXTFIC,A.FISLASTERRORTEXTEIC,
		  -- A.FISIIC,A.FISIICSIG,A.FISRESPONSEXMLFIC,A.FISRESPONSEXMLEIC,A.FISXMLSTRING,A.FISXMLSIGNED,
			 
			 NRRENDOR,
			
             FieldsDisplMas,
			 PromptsDisplMas,
			 FieldsDisplDet,
			 PromptsDisplDet
			)      
      SELECT -- per koludim Top 50 
	         NrRenditje = Row_Number() OVER(PARTITION BY YEAR(A.DATEDOK) ORDER BY YEAR(A.DATEDOK),A.NRDOK),
	         A.TROW,A.FISKALIZUAR,A.FISSTATUS,B.TIP,
             A.NRDOK,A.DATEDOK,A.KODFKL,A.SHENIM1,A.NIPT,A.KMAG,A.VLPATVSH,A.VLTVSH,A.VLERTOT,

			 PromptPdf       = LEFT(CASE WHEN LTRIM(RTRIM(ISNULL(A.FISPDF,'')))<>'' THEN 'Gjeneruar PDF' ELSE 'Nuk ka' END+Space(30),30),

			 A.FISKODREASON,
	         FISFIC=CONVERT(VARCHAR(100),A.FISFIC),A.FISEIC,A.FISPDF,
             A.ISDOCFISCAL, A.FISPROCES,A.FISMENPAGESE,A.FISTIPDOK,A.FISKODOPERATOR,
			 A.FISBUSINESSUNIT,A.FISTCR,A.FISUUID,A.FISQRCODELINK, A.FISRELATEDFIC,
			 A.FISLASTERRORFIC,A.FISLASTERROREIC,A.FISLASTERRORTEXTFIC,A.FISLASTERRORTEXTEIC,
			 
		  -- A.FISFIC,A.FISKODREASON,A.FISEIC,A.FISPDF,A.ISDOCFISCAL,A.FISPROCES,A.FISSTATUS,A.FISMENPAGESE,A.FISTIPDOK,A.FISKODOPERATOR,
          -- A.FISBUSINESSUNIT,A.FISTCR,A.FISUUID,A.FISQRCODELINK, A.FISRELATEDFIC,
		  -- A.FISLASTERRORFIC,A.FISLASTERROREIC,A.FISLASTERRORTEXTFIC,A.FISLASTERRORTEXTEIC,
		  -- A.FISIIC,A.FISIICSIG,A.FISRESPONSEXMLFIC,A.FISRESPONSEXMLEIC,A.FISXMLSTRING,A.FISXMLSIGNED,
			 
			 A.NRRENDOR,
			 
             FieldsDisplMas  = @sFieldsDisplMas,
			 PromptsDisplMas = @sPromptsDisplMas,
			 FieldsDisplDet  = @sFieldsDisplDet,
			 PromptsDisplDet = @sPromptsDisplDet

        FROM FF A INNER JOIN #TmpFature B ON A.NRRENDOR=B.NRRENDOR AND B.TIP='FF'

 -- ORDER BY YEAR(DATEDOK), NrRenditje;


--	  SELECT * FROM #TmpFtFiscal ORDER BY YEAR(DATEDOK), NrRenditje;



   RAISERROR (N'
_______________________________________________________________________________

  4. Afishimi dokumenta fiskalizimi 
_______________________________________________________________________________', 0, 1) WITH NOWAIT;


         SET @sTmpTbl = QUOTENAME('Tempdb..'+@TmpTableName,'''');        -- te perdoret kur te fiskalizohet nga disa usera ..... (Select te behet jo ne FJ por ne ##File)

         SET @sSql = '

          IF OBJECT_ID('+@sTmpTbl+') IS NOT NULL
             DROP TABLE '+@TmpTableName+'; 

      SELECT * 
        INTO '+@TmpTableName+'
        FROM #TmpFtFiscal 
--  ORDER BY YEAR(DATEDOK), NrRenditje; 

	  SELECT * 
	    FROM '+@TmpTableName+'
    ORDER BY YEAR(DATEDOK), NrRenditje; ';

--     PRINT @sSql;
       EXEC (@sSql); 


   RAISERROR (N'
_______________________________________________________________________________

  5. Fund afishim dokumenta fiskalizimi 
_______________________________________________________________________________', 0, 1) WITH NOWAIT;


GO
