SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Stored Procedure




 -- EXEC [Isd_FisDisplayLogWTN] 'A.DATEDOK>=DBO.DATEVALUE(''01/05/2021'') AND A.DATEDOK<=DBO.DATEVALUE(''31/05/2021'')', '##AAAA';



CREATE Procedure [dbo].[Isd_FisDisplayLogWTN]
(
  @pWhere           Varchar(MAX),
  @pTmpTableName    Varchar(40)
 )

AS

         SET NOCOUNT ON;

     DECLARE @sSql              nVarchar(Max),
	         @sWhere             Varchar(Max),
			 @sFieldsDisplMas    Varchar(Max),
			 @sPromptsDisplMas   Varchar(Max),
			 @sFieldsDisplDet    Varchar(Max),
			 @sPromptsDisplDet   Varchar(Max),
			 @TmpTableName       Varchar(40),
		     @sTmpTbl            Varchar(40);

         SET @sWhere           = ISNULL(@pWhere,'');
		 SET @TmpTableName     = ISNULL(@pTmpTableName,'');

--       SET @sFieldsDisplMas  = 'Tip,NrDok,       DateDok,KodFKL,Shenim1,Nipt,KMag,    VlPaTvsh,VlTvsh,VlerTot,FisKodReason';
--	     SET @sPromptsDisplMas = 'Dok,Nr dokumenti,Date,   Bleres,Emertim,Nipt,Magazine,VlPaTvsh,Tvsh,  Vlefte, Aresye';

         SET @sFieldsDisplMas  = 'NrRenditje,Tip,KMAG,         NrDok,       Fiskalizuar, DateDok,KMagRf,     Shenim1,Dst,   FisKodReason,TRow';
         SET @sPromptsDisplMas = 'NrRenditje,Dokument,Magazine,Nr dokumenti,Fiskalizuar, Date,   Destinacion,Shenim, Qellim,Aresye,      Zgjedhur';

		 SET @sFieldsDisplDet  = 'KodAf,Pershkrim,Njesi,Sasi,VleraBs';
		 SET @sPromptsDisplDet = 'Kod,  Emertim,  Njesi,Sasi,Vlefte';

          IF OBJECT_ID('TEMPDB..#TmpFDFiscal') IS NOT NULL
             DROP TABLE #TmpFDFiscal;


--      EXEC dbo.Isd_FisDisplayLog '  ((DATEDOK=CONVERT(DATETIME,''15/05/2021'',104))) AND A=A1','#AAAA';

      SELECT NRRENDOR=CAST(0 AS BIGINT),SELECTED=CAST(0 AS BIT),TIP=DST
	    INTO #TmpFDFiscal
	    FROM FD
       WHERE 1=2;

   RAISERROR (N'
_______________________________________________________________________________

  1. Fillim procedura per afishim dokumenta fiskalizimi (Temp)
_______________________________________________________________________________', 0, 1) WITH NOWAIT;

	     SET @sSql = '
	  INSERT INTO #TmpFDFiscal
	        (NRRENDOR,SELECTED,TIP)
	  SELECT A.NRRENDOR,CAST(0 AS BIT),TIP=''FD''
	    FROM FD A 
	   WHERE 1=1; ';

          IF @sWhere<>''
	         SET @sSql = REPLACE(@sSql,'1=1',@sWhere);
			 

        EXEC (@sSql);


      CREATE INDEX IndTmp ON #TmpFDFiscal(NRRENDOR);


   RAISERROR (N'
_______________________________________________________________________________

  2. Fillim procedura per afishim dokumenta fiskalizimi (FD) 
_______________________________________________________________________________', 0, 1) WITH NOWAIT;

-- FD

      SELECT -- per koludim Top 50 
	         NrRenditje = Row_Number() OVER(PARTITION BY YEAR(A.DATEDOK),KMAG ORDER BY YEAR(A.DATEDOK),KMAG,A.NRDOK),
	         A.TROW,A.FISKALIZUAR,B.TIP,
             A.KMAG,A.NRDOK,A.DATEDOK,A.SHENIM1,A.DST,A.KMAGRF,

		  -- PromptPdf       = CASE WHEN LTRIM(RTRIM(ISNULL(A.FISPDF,'')))<>'' THEN 'Gjeneruar PDF' ELSE 'Nuk ka' END,

		     A.ISDOCFISCAL, A.FISTIPDOK, A.FISKODOPERATOR, A.FISBUSINESSUNIT,FISKODREASON=SPACE(30), -- A.FISSTATUS,A.FISPROCES, 
			 
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

        FROM FD A INNER JOIN #TmpFDFiscal B ON A.NRRENDOR=B.NRRENDOR 

--  ORDER BY YEAR(DATEDOK), NrRenditje;


 
   RAISERROR (N'
_______________________________________________________________________________

  3. Afishimi dokumenta fiskalizimi 
_______________________________________________________________________________', 0, 1) WITH NOWAIT;


         SET @sTmpTbl = QUOTENAME('Tempdb..'+@TmpTableName,'''');        -- te perdoret kur te fiskalizohet nga disa usera ..... (Select te behet jo ne FD por ne ##File)

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

  4. Fund afishim dokumenta fiskalizimi 
_______________________________________________________________________________', 0, 1) WITH NOWAIT;


GO
