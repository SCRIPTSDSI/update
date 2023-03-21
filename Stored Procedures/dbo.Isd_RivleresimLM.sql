SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






--Exec [Isd_RivleresimLM]
-- @PModuls    = 'AFS',
-- @PDateKp    = '01/01/2010',
-- @PDateKs    = '31/03/2011',
-- @PKodArdh   = '766',
-- @PKodShpz   = '666',
-- @PKoment    = 'Rivleresim Value',
-- @PSqlFilter = ''
---- @PSqlFilter = ' WHERE ISNULL(A.KMON,'''')<>'''' AND 
----                          A.DATEDOK>=DBO.DATEVALUE(''01/01/2010'') AND 
----                          A.DATEDOK<=DBO.DATEVALUE(''31/03/2011'') AND 
----                          D.TAG=1 '


-- Executimi i Ri

--Declare @PNrRendorVS Int
--
--Exec [Isd_RivleresimLM]  
--'ABSF', 
--'01/01/2010', 
--'31/05/2011', 
--'766', 
--'666', 
--'Rivleresim valute: 01/01/2011 - 31/03/2011', 
--'',
--'ADMIN',
--@PNrRendorVS  Output
--



CREATE Procedure [dbo].[Isd_RivleresimLM]
 (
        @PModuls     Varchar(20),
        @PDateKp     Varchar(20),
        @PDateKs     Varchar(20),
        @PKodShpz    Varchar(20),
        @PKodArdh    Varchar(20),
        @PKoment     Varchar(150),
        @PSqlFilter  Varchar(Max),
        @PUser       Varchar(30),
        @PNrRendor   Int Output
  )
as

--Declare @PModuls    Varchar(20),
--        @PDateKp    Varchar(20),
--        @PDateKs    Varchar(20),
--        @PKodShpz   Varchar(20),
--        @PKodArdh   Varchar(20),
--        @PKoment    Varchar(150),
--        @PSqlFilter Varchar(Max)
--
--Set @PModuls  = 'AFS'
--Set @PDateKp  = '01/01/2010'
--Set @PDateKs  = '31/03/2011'
--Set @PKodArdh = '766'
--Set @PKodShpz = '666'
--Set @PKoment  = 'Rivleresim Value'
--Set @PSqlFilter = ' WHERE ISNULL(A.KMON,'''')<>'''' AND 
--                          A.DATEDOK>=DBO.DATEVALUE('''+@PDateKp+''') AND 
--                          A.DATEDOK<=DBO.DATEVALUE('''+@PDateKs+''') AND 
--                          D.TAG=1 '
    Set NoCount On

    Set @PNrRendor = 0

Declare @NewID        Int,
        @RowCount     Int,
        @SqlFilterUn1 Varchar(Max),
        @SqlFilterUn2 Varchar(Max),
        @Where        Varchar(Max),
        @LlogariHF    Varchar(30),
        @VlefteMV     Float,
        @Db           Float,
        @Kr           Float,
        @NrDok        Int

    Set @Where = ' 
                   WHERE LTRIM(RTRIM(ISNULL(A.KMON,'''')))<>'''' AND 
                         A.DATEDOK>=DBO.DATEVALUE('''+@PDateKp+''') AND  
                         A.DATEDOK<=DBO.DATEVALUE('''+@PDateKs+''') AND D.TAG=1 '
     if @PSqlFilter<>''
        Set @Where = @Where +' AND '+@PSqlFilter 


       SELECT * INTO #VsScrRV
         FROM VSSCR
        WHERE 1=2

if CharIndex('T',@PModuls)>0
   begin

     Set @Where = Replace(@Where,'A.KMON','B.KMON');

	 Set @SqlFilterUn1 = '
   
               INSERT INTO #VsScrRV
                     (KOD,KODAF,LLOGARI,LLOGARIPK,DB,KR,DBKRMV,KMON,PERSHKRIM,KURS1,KURS2,ORDERSCR,TIPKLL)
	  	       SELECT KOD        = B.KOD, 
				      KODAF      = MAX(dbo.Isd_SegmentsToKodAF(B.KOD)),  --MAX(Dbo.Isd_SegmentFind(B.KOD,0,1)),
				      LLOGARI    = MAX(Dbo.Isd_SegmentFind(B.KOD,0,1)),
				      LLOGARIPK  = MAX(Dbo.Isd_SegmentFind(B.KOD,0,1)),
                      DB         = 0,
                      KR         = 0,
				      DBKRMV     = ROUND(((SUM(CASE TREGDK WHEN ''D'' THEN DB   ELSE 0-KR   END) * MAX(KURS2R)) / MAX(KURS1R)) -
								 	      SUM(DBKRMV),2), 
				      KMON       = MIN(ISNULL(B.KMON,'''')),
				      PERSHKRIM  = MIN(CASE WHEN ISNULL(E.PERSHKRIM,'''')<>'''' THEN E.PERSHKRIM ELSE C.PERSHKRIM END),
                      KURS1      = MAX(KURS1R),
                      KURS2      = MAX(KURS2R),
                      ORDERSCR   = 1,
                      TIPKLL     = ''T''
		         FROM FK A LEFT JOIN FKSCR   B ON A.NRRENDOR=B.NRD 
 				      LEFT JOIN LLOGARI C ON Dbo.Isd_SegmentFind(B.KOD,0,1)=C.KOD 
				      LEFT JOIN MONEDHA D ON ISNULL(B.KMON,'''')=D.KOD 
				      LEFT JOIN LM      E ON B.KOD=E.KOD '+
               @Where+' 
	         GROUP BY B.KOD 
	           HAVING ABS(ROUND(((SUM(CASE TREGDK WHEN ''D'' THEN DB   ELSE 0-KR   END) * MAX(KURS2R)) / MAX(KURS1R)) - 
			  			          SUM(B.DBKRMV),2))>=0.01 ';
   end

else

    Set @SqlFilterUn1 = '

               INSERT INTO #VsScrRV
                     (KOD,KODAF,LLOGARI,LLOGARIPK,DB,KR,DBKRMV,KMON,PERSHKRIM,KURS1,KURS2,ORDERSCR,TIPKLL)
			   SELECT KOD        = A.KOD,
					  KODAF      = MIN(Dbo.Isd_SegmentFind(A.KOD,0,1)), 
					  LLOGARI    = MAX(Dbo.Isd_SegmentFind(A.KOD,0,1)), 
					  LLOGARIPK  = MAX(Dbo.Isd_SegmentFind(A.KOD,0,1)), 
                      DB         = 0,
                      KR         = 0,
					  DBKRMV     = ROUND(((SUM(CASE TREGDK WHEN ''D'' THEN VLEFTA   ELSE 0-VLEFTA   END) * MAX(KURS2R)) / MAX(KURS1R)) -
										   SUM(CASE TREGDK WHEN ''D'' THEN VLEFTAMV ELSE 0-VLEFTAMV END),2), 
					  KMON       = MIN(ISNULL(A.KMON,'''')),
					  PERSHKRIM  = MIN(C.PERSHKRIM),
                      KURS1      = MAX(KURS1R),
                      KURS2      = MAX(KURS2R),
                      ORDERSCR   = CHARINDEX(''A'',''ABFS''),
                      TIPKLL     = ''A''
				 FROM DAR A LEFT  JOIN ARKAT   C ON Dbo.Isd_SegmentFind(A.KOD,0,1)=C.KOD 
							LEFT  JOIN MONEDHA D ON ISNULL(A.KMON,'''')=D.KOD '+
                @Where+'
                 
			 GROUP BY A.KOD 
			   HAVING ABS(ROUND(((SUM(CASE TREGDK WHEN ''D'' THEN VLEFTA   ELSE 0-VLEFTA   END) * MAX(KURS2R)) / MAX(KURS1R)) - 
								  SUM(CASE TREGDK WHEN ''D'' THEN VLEFTAMV ELSE 0-VLEFTAMV END),2))>=0.01 
			 ORDER BY A.KOD '

  Print @SqlFilterUn1;

		Set @SqlFilterUn2 = @SqlFilterUn1;

		if CharIndex('T',@PModuls)>0
		   Exec(@SqlFilterUn1);

		if CharIndex('A',@PModuls)>0
		   Exec(@SqlFilterUn1);

		if CharIndex('B',@PModuls)>0
		   begin
			 Set @SQLFilterUn1=@SQLFilterUn2
			 Set @SQLFilterUn1=Replace(@SQLFilterUn1,' DAR ',  ' DBA ')
			 Set @SQLFilterUn1=Replace(@SQLFilterUn1,' ARKAT ',' BANKAT ')
			 Set @SQLFilterUn1=Replace(@SQLFilterUn1,'''A''',  '''B''')
			 Exec(@SqlFilterUn1);

             Print @SqlFilterUn1;
		   end;

		if CharIndex('F',@PModuls)>0
		   begin
			 Set @SQLFilterUn1=@SQLFilterUn2
			 Set @SQLFilterUn1=Replace(@SQLFilterUn1,' DAR ',  ' DFU ')
			 Set @SQLFilterUn1=Replace(@SQLFilterUn1,' ARKAT ',' FURNITOR ')
			 Set @SQLFilterUn1=Replace(@SQLFilterUn1,'''A''',  '''F''')
			 Exec(@SqlFilterUn1);
		   
             Print @SqlFilterUn1;
           end;

		if CharIndex('S',@PModuls)>0
		   begin
			 Set @SQLFilterUn1=@SQLFilterUn2
			 Set @SQLFilterUn1=Replace(@SQLFilterUn1,' DAR ',  ' DKL ')
			 Set @SQLFilterUn1=Replace(@SQLFilterUn1,' ARKAT ',' KLIENT ')
			 Set @SQLFilterUn1=Replace(@SQLFilterUn1,'''A''',  '''S''')
			 Exec(@SqlFilterUn1);

             Print @SqlFilterUn1;
		   end;



   if ISNULL((SELECT COUNT('') FROM #VsScrRV),0)<=0
      Return;
      


           Set @NewID = 0
           Insert Into VS 
                  (NRDOK)
           Values (0)

           SET @RowCount = @@ROWCOUNT;

           if  @RowCount<>0
               SELECT @NewID=@@IDENTITY  
           Set @PNrRendor  = @NewID;

           Set @VlefteMV   = Round((SELECT ISNULL(SUM(DBKRMV),0) FROM #VsScrRV),2);
           
           if  Abs(@VlefteMV)>0.019 
               begin

                 Select @Db=0, @Kr=0, @LlogariHF='', @VlefteMV = 0-@VlefteMV;

                 if     @VlefteMV>0
                    Select @Db =   @VlefteMV, @LlogariHF=@PKodArdh --@PKodShpz
                 else
                    Select @Kr = 0-@VlefteMV, @LlogariHF=@PKodShpz --@PKodArdh


                 INSERT INTO #VsScrRV
                       (KOD,KODAF,LLOGARI,LLOGARIPK,DB,KR,DBKRMV,KMON,PERSHKRIM,KURS1,KURS2,ORDERSCR,TIPKLL)
 			     SELECT @LlogariHF+'....',
				  	    @LlogariHF, 
				  	    @LlogariHF, 
				 	    @LlogariHF,
                        @Db,
                        @Kr,
					    @VlefteMV, 
					    '',
					    PERSHKRIM  = ISNULL((SELECT PERSHKRIM FROM LLOGARI WHERE KOD=@LlogariHF),''),
                        1,
                        1,
                        9,
                        'T'
               end;

		   UPDATE #VsScrRV
		      SET NRD       = @NewID,
				  KOMENT    = 'Rivleresim',
				  TIPREF    = '',
				  NRDOKREF  = '',
				  NRDITAR   = 0,
				  OPERLLOJ  = '',
				  OPERNR    = 0,
				  OPERAPL   = '',
				  OPERORD   = '',
				  OPERNRFAT = '',
				  FADESTIN  = '',
				  FAART     = '',
				  TREGDK    = CASE WHEN DBKRMV>=0 THEN 'D' ELSE 'K' END,
				  TAGNR     = 0,
				  TROW      = 0;


           SELECT @NrDok     = (  SELECT ISNULL(MAX(NRDOK),0) 
                                    FROM VS
                                   WHERE YEAR(DATEDOK)=YEAR(DBO.DATEVALUE(@PDateKs)))+1;

           UPDATE A 
              SET NRDOK      = @NrDok,
                  DATEDOK    = DBO.DATEVALUE(@PDateKs),
                  PERSHKRIM1 = @PKoment+Case When @PModuls='T' Then '' Else '  /'+@PModuls End,
                  PERSHKRIM2 = '',
                  KMON       = '',
                  KURS1      = 1,
                  KURS2      = 1,
                  NRDFK      = 0,
                  KLASIFIKIM = '',
                  FIRSTDOK   = 'E'+Cast(@NewID as Varchar(30)),
                  DST        = 'RV'
             FROM VS A
            WHERE NRRENDOR=@NewID;

           INSERT INTO VSSCR
                 (NRD,KOD,KODAF,LLOGARI,LLOGARIPK,KMON,PERSHKRIM,
                  DB,KR,KOMENT,DBKRMV,KURS1,KURS2,ORDERSCR,
                  TIPREF,NRDOKREF,NRDITAR,
                  OPERLLOJ,OPERNR,OPERAPL,OPERORD,OPERNRFAT,FAART,FADESTIN,
                  TREGDK,TIPKLL)
           SELECT NRD,KOD,KODAF,LLOGARI,LLOGARIPK,KMON,PERSHKRIM,
                  DB,KR,KOMENT,DBKRMV,KURS1,KURS2,ORDERSCR,
                  TIPREF,NRDOKREF,NRDITAR,
                  OPERLLOJ,OPERNR,OPERAPL,OPERORD,OPERNRFAT,FAART,FADESTIN,
                  TREGDK,TIPKLL
             FROM #VsScrRV
         ORDER BY ORDERSCR,KOD;   

         SELECT @VlefteMV = @Db+@Kr 


         Declare @OkIdLog Bit
        --Select @OkIdLog = IsNull(dbo.Isd_FieldTableExists('DITARVEPRIME', 'LgJob'),0)
          Select @OkIdLog = dbo.Isd_ParamExists('Isd_AppendLg','@PLgJob');

      if @OkIdLog=0
         Exec [Isd_AppendLog] 
              @PUser         = @PUser,   
              @PNrRendor     = @NewID,
              @PTip          = 'VS',
              @PMaster       = 'VS',
              @PNrdok        = @NrDok,
              @PNrFraks      = 0,
              @PDateDok      = @PDateKs,
              @PVlere        = @VlefteMV,
              @POperacion    = 'S',
              @POperacionDok = 'VS'
      else
         Exec [Isd_AppendLg] 
              @PUser         = @PUser,   
              @PNrRendor     = @NewID,
              @PTip          = 'VS',
              @PMaster       = 'VS',
              @PNrdok        = @NrDok,
              @PNrFraks      = 0,
              @PDateDok      = @PDateKs,
              @PVlere        = @VlefteMV,
              @POperacion    = 'S',
              @POperacionDok = 'VS',
              @PLgJob        = '';



         Exec [Isd_GjenerimDitarOne] @PTableName = 'VS', @PSgn = 0, @PNrRendor = @NewID;
      -- Exec [Isd_GjenerimDitarOne] @PTableName = 'VS', @PSgn = 1, @PNrRendor = @NewID;  -- 20.09.2014

         Exec [Isd_KalimLM]
              @PTip          = 'E',
              @PNrRendor     = @NewID,
              @PSQLFilter    = '',
              @PTableNameTmp = '##VsScrRV';

       SELECT @PNrRendor = @NewID;
GO
