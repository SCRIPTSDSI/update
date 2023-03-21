SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Stored Procedure




 --EXEC [Isd_FisDisplayLogSM] 'A.DATEDOK>=DBO.DATEVALUE(''01/05/2010'') AND A.DATEDOK<=DBO.DATEVALUE(''31/12/2021'')', 'A.DATEDOK>=DBO.DATEVALUE(''01/05/2010'') AND A.DATEDOK<=DBO.DATEVALUE(''31/12/2021'')','##AAAA';



CREATE Procedure [dbo].[Isd_FisDisplayLogSM]
(
  @pWhereSm         Varchar(MAX),
  @pWhereSmBak      Varchar(MAX),
  @pTmpTableName    Varchar(40)
 )

AS

         SET NOCOUNT ON;

     DECLARE @sSql              nVarchar(Max),
	         @sWhereSm           Varchar(Max),
	         @sWhereSmBak       Varchar(Max),
			 @sFieldsDisplMas    Varchar(Max),
			 @sPromptsDisplMas   Varchar(Max),
			 @sFieldsDisplDet    Varchar(Max),
			 @sPromptsDisplDet   Varchar(Max),
			 @TmpTableName       Varchar(40),
		     @sTmpTbl            Varchar(40);

         SET @sWhereSm         = ISNULL(@pWhereSm,'');
         SET @sWhereSmBak      = ISNULL(@pWhereSmBak,'');
		 SET @TmpTableName     = ISNULL(@pTmpTableName,'');

--       SET @sFieldsDisplMas  = 'Tip,NrDok,       DateDok,KodFKL,Shenim1,Nipt,KMag,    VlPaTvsh,VlTvsh,VlerTot,FisKodReason';
--	     SET @sPromptsDisplMas = 'Dok,Nr dokumenti,Date,   Bleres,Emertim,Nipt,Magazine,VlPaTvsh,Tvsh,  Vlefte, Aresye';

         SET @sFieldsDisplMas  = 'NrRenditje,Tip,     NrDok,       Fiskalizuar, KASE,DateDok,KodFKL,Shenim1,KMag,    VlPaTvsh,VlTvsh,VlerTot,FisKodReason,TRow';
         SET @sPromptsDisplMas = 'NrRenditje,Dokument,Nr dokumenti,Fiskalizuar, Kase,Date,   Bleres,Emertim,Magazine,VlPaTvsh,Tvsh,  Vlefte, Aresye,      Zgjedhur';

		 SET @sFieldsDisplDet  = 'KodAf,Pershkrim,Njesi,Sasi,VlPaTvsh,VlTvsh,VleraBs';
		 SET @sPromptsDisplDet = 'Kod,  Emertim,  Njesi,Sasi,VlPaTvsh,Tvsh,  Vlefte';

          IF OBJECT_ID('TEMPDB..#TmpSM') IS NOT NULL
             DROP TABLE #TmpSM;


      SELECT NRRENDOR=CAST(0 AS BIGINT),SELECTED=CAST(0 AS BIT),TIP=KODFKL
	    INTO #TmpFature
	    FROM SM
       WHERE 1=2;

   RAISERROR (N'
_______________________________________________________________________________

  1. Fillim procedura per afishim dokumenta fiskalizimi (Temp)
_______________________________________________________________________________', 0, 1) WITH NOWAIT;

	     SET @sSql = '
	  INSERT INTO #TmpFature
	        (NRRENDOR,SELECTED,TIP)
	  SELECT A.NRRENDOR,CAST(0 AS BIT),TIP=''SM''
	    FROM SM A 
	   WHERE 1=1;
	   
	  INSERT INTO #TmpFature
	        (NRRENDOR,SELECTED,TIP)
	  SELECT A.NRRENDOR,CAST(0 AS BIT),TIP=''SMBAK''
	    FROM SMBAK A 
	   WHERE 2=2;';

          IF @sWhereSm<>''
	         SET @sSql = REPLACE(@sSql,'1=1',@sWhereSm);
			 
          IF @sWhereSmBAk<>''
	         SET @sSql = REPLACE(@sSql,'2=2',@sWhereSmBak);

        EXEC (@sSql);

PRINT @sSql;			 

      CREATE INDEX IndTmp ON #TmpFature(NRRENDOR);


   RAISERROR (N'
_______________________________________________________________________________

  2. Fillim procedura per afishim dokumenta fiskalizimi (SM) 
_______________________________________________________________________________', 0, 1) WITH NOWAIT;



      SELECT -- per koludim Top 50 
	         NrRenditje = Row_Number() OVER(PARTITION BY YEAR(A.DATEDOK) ORDER BY YEAR(A.DATEDOK),A.NRDOK),
	         A.TROW,A.FISKALIZUAR,B.TIP,
             A.KASE,A.NRDOK,A.DATEDOK,A.SHENIM1,A.KMAG,A.VLPATVSH,A.VLTVSH,A.VLERTOT,

			 PromptPdf       = CASE WHEN LTRIM(RTRIM(ISNULL(A.FISPDF,'')))<>'' THEN 'Gjeneruar PDF' ELSE 'Nuk ka' END,

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

        FROM SM A INNER JOIN #TmpFature B ON A.NRRENDOR=B.NRRENDOR AND B.TIP='SM'

--  ORDER BY YEAR(DATEDOK), NrRenditje;



   RAISERROR (N'
_______________________________________________________________________________

  3. Fillim procedura per afishim dokumenta fiskalizimi (SMBAK)
_______________________________________________________________________________', 0, 1) WITH NOWAIT;



	  INSERT INTO #TmpFtFiscal
	        (NrRenditje,
	         A.TROW,A.FISKALIZUAR,A.TIP,
             A.KASE,A.NRDOK,A.DATEDOK,A.SHENIM1,A.KMAG,A.VLPATVSH,A.VLTVSH,A.VLERTOT,

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
	         A.TROW,A.FISKALIZUAR,B.TIP,
             A.KASE,A.NRDOK,A.DATEDOK,A.SHENIM1,A.KMAG,A.VLPATVSH,A.VLTVSH,A.VLERTOT,

			 PromptPdf       = CASE WHEN LTRIM(RTRIM(ISNULL(A.FISPDF,'')))<>'' THEN 'Gjeneruar PDF' ELSE 'Nuk ka' END,

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

        FROM SMBak A INNER JOIN #TmpFature B ON A.NRRENDOR=B.NRRENDOR AND B.TIP='SMBAK'

 -- ORDER BY YEAR(DATEDOK), NrRenditje;


--	  SELECT * FROM #TmpFtFiscal ORDER BY YEAR(DATEDOK), NrRenditje;



   RAISERROR (N'
_______________________________________________________________________________

  4. Afishimi dokumenta fiskalizimi 
_______________________________________________________________________________', 0, 1) WITH NOWAIT;


         SET @sTmpTbl = QUOTENAME('Tempdb..'+@TmpTableName,'''');        -- te perdoret kur te fiskalizohet nga disa usera ..... (Select te behet jo ne SM por ne ##File)

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
