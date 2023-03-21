SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE   procedure [dbo].[Isd_TestUpdFields]
(
  @TestTable Varchar(30)
)
AS

--      EXEC dbo.[Isd_TestUpdFields] ''

     DECLARE @Ind1        Int,
             @Nr1         Int,
             @Ind2        Int,
             @Nr2         Int,
             @TblList     Varchar(MAX),
             @FldList     Varchar(MAX),
             @SQLFilter00 Varchar(MAX),
             @SQLFilter01 Varchar(MAX),
             @ListTables  Varchar(MAX),
             @ListFields  Varchar(MAX),
             @TName       Varchar(50),
             @FName       Varchar(50);


-- 1.  UPDATE vetem KMon ne Dokumenta
-- 2.  Fushat referenca te duhet me germa te medha dhe pa boshe te teperta...
-- 3.  Dokumenta, Ditare, Libra per rastet Klient,Furnitor,Arke,Banke





-- 4.  Rrjeshta ne Scr te dokumentave per rastet Klient,Furnitor,Arke,Banke,Artikuj,Llogari  

--            KUJDES -- shiko komentet me poshte te sakta per KODAF ne Scr  dt 15.04.2016
    
       -- 4.1 Rrjeshta ne Scr te dokumentave per rastet Klient,Furnitor,Arke,Banke

       -- 4.2 Rrjeshta ne Scr te dokumentave per rastet Llogari (Arka,Banka,Vs,VsSt)
       -- 4.3 Rrjeshta ne Scr te dokumentave per rastet Llogari (Fk,FkSt)
       -- 4.4 Rrjeshta ne Scr te dokumentave per rastet Llogari (Faturimet)

       -- 4.5 Rrjeshta ne Scr te dokumentave per rastet Artikuj (FH/FD)
       -- 4.6 Rrjeshta ne Scr te dokumentave per rastet Artikuj (Faturimet)




-- 5.  Fushat me germa te medha dhe pa boshe te teperta ne CONFIGLM...
-- 6.  Fushat me germa te medha dhe pa boshe te teperta ne CONFIGMG...



-- 1.  UPDATE vetem KMon ne Dokumenta

      UPDATE MONEDHA 
         SET KOD=''
       WHERE KOD+'A'<>'A' AND MONVEND=1   -- Rasti Kod vetem disa Boshe ???? ....

      UPDATE MONEDHA 
         SET KOD  =  UPPER(LTRIM(RTRIM(ISNULL(KOD,'')))),
             KOD1 =  UPPER(LTRIM(RTRIM(ISNULL(KOD1,''))))
       WHERE KOD  <> UPPER(LTRIM(RTRIM(ISNULL(KOD,'''')))) Collate Latin1_General_CS_AS

         SET @TblList    = dbo.Isd_ListTables('','');
         SET @FldList    = 'KMON';
         SET @Nr1        = LEN(@TblList)-LEN(REPLACE(@TblList,',',''))+1;
         SET @Ind1       = 1;
         SET @ListTables = @TblList; 

         SET @SqlFilter00 = ' 
             UPDATE LLOGARI 
                SET K_O_D =  UPPER(LTRIM(RTRIM(ISNULL(K_O_D,''''))))
              WHERE (K_O_D IS NULL) OR (K_O_D +''A''<> UPPER(LTRIM(RTRIM(ISNULL(K_O_D,''''))))+''A'' Collate Latin1_General_CS_AS); '


  WHILE @Ind1 <= @Nr1
     BEGIN

       SET @TName = dbo.Isd_StringInListStr(@TblList,@Ind1,',');     

       IF (LEFT(@TName,2)<>'X_') AND (dbo.Isd_StringInListExs(@ListTables,@TName)>0)  
           BEGIN
             SET   @ListFields  = dbo.Isd_ListFieldsTable(@TName,'');
             SET   @ListFields  = dbo.Isd_ListFields2Lists(@ListFields,@FldList,''); 
             SET   @Nr2         = LEN(@ListFields)-LEN(REPLACE(@ListFields,',',''))+1;
             SET   @Ind2        = 1;
          --
             WHILE @Ind2 <= @Nr2
               BEGIN
                 SET   @FName = dbo.Isd_StringInListStr(@ListFields,@Ind2,',');
                 IF   (@FName<>'') AND dbo.Isd_FieldTableExists(@TName,@FName)>0  
                       BEGIN
                         SET   @SqlFilter01 = REPLACE(@SQLFilter00,'UPDATE LLOGARI','UPDATE '+@TName);
                         SET   @SqlFilter01 = REPLACE(@SQLFilter01,'K_O_D',@FName); 
                         EXEC (@SqlFilter01);                   
                       END;
                 SET @Ind2 = @Ind2 + 1;
                 
               END
           END;

       SET @Ind1 = @Ind1 + 1;
     END 



-- 2.   Fushat e meposhteme jane me germa te medha dhe pa boshe te teperta...

     -- Duhet Trajtim me Vete per Referencat per Fushen KOD, mund te sjelle dublikim KOD 
     -- dhe si rjedhim Nderprerje procedure. Me pare hiqen dublikimet....

        EXEC dbo.[Isd_TestUpdReference] '',0.01,'REFDBL',''

    -- 
        SET  @FldList   = 'KMAG,KMON,'+
                          'KODFKL,KOD,NIPT,LINKKLIENT,LISTE,DEP,'+
                          'NJESI,NJESB,NJESSH,NJESINV,KLASIF,KLASIF1,KLASIF2,KLASIF3,KLASIF4,KLASIF5,KLASIF6,'+
                          'LLOGTVSH,LLOGZBR,LLOGARK,'+
                          'KMAGRF,KMAGLNK,DST,RRAB,'+
                          'KODAB,TIPDOK,TIPFAT,'+
                          'KODAF,KARTLLG,LLOGARI,LLOGARIPK,TIPKLL,TREGDK,TIPREF,'+
                          'KODLM,LLOGINV,NDRGJEND,LLOGSH,LLOGB,LLOGSHPZ01,'+
                          'LLOGARIDB,LLOGARIKR,'+
                          'FAKLS,FADESTIN,FASTATUS,FAART,'+
                          'SG1,SG2,SG3,SG4,SG5,';

         SET @Ind1        = 1;
     --  SET @ListTables  = @TblList 
         SET @SqlFilter00 = ' 
             UPDATE LLOGARI 
                SET K_O_D =  UPPER(LTRIM(RTRIM(K_O_D)))
              WHERE K_O_D <> UPPER(LTRIM(RTRIM(K_O_D))) Collate Latin1_General_CS_AS ';

  WHILE @Ind1 <= @Nr1
     BEGIN

       SET @TName = dbo.Isd_StringInListStr(@TblList,@Ind1,',');     

       IF  (LEFT(@TName,2)<>'X_') AND (dbo.Isd_StringInListExs(@ListTables,@TName)>0)  
           BEGIN

             SET   @ListFields  = dbo.Isd_ListFieldsTable(@TName,'');
             SET   @ListFields  = dbo.Isd_ListFields2Lists(@ListFields,@FldList,''); 

             SET   @Nr2         = LEN(@ListFields)-LEN(REPLACE(@ListFields,',',''))+1;
             SET   @Ind2        = 1;
          --
             WHILE @Ind2 <= @Nr2
               BEGIN
                 SET   @FName = dbo.Isd_StringInListStr(@ListFields,@Ind2,',');
                 IF   (@FName<>'') AND dbo.Isd_FieldTableExists(@TName,@FName)>0  
                       BEGIN
                         SET   @SqlFilter01 = REPLACE(@SQLFilter00,'UPDATE LLOGARI','UPDATE '+@TName);
                         SET   @SqlFilter01 = REPLACE(@SQLFilter01,'K_O_D',@FName);
                         EXEC (@SqlFilter01);        
                       END;

                 SET @Ind2 = @Ind2 + 1;
               END

           END;

       SET @Ind1 = @Ind1 + 1;

     END 


-- 3.   Dokumenta, Ditare, Libra per rastet Klient,Furnitor,Arke,Banke

         SET @SqlFilter00 = ' 

		-- Dokument
		 UPDATE FJ
			SET KOD    = UPPER(LTRIM(RTRIM(KODFKL))+''.''+LTRIM(RTRIM(ISNULL(KMON,'''')))), 
				KODFKL = UPPER(LTRIM(RTRIM(KODFKL))),
				KMON   = UPPER(LTRIM(RTRIM(ISNULL(KMON,''''))))
		  WHERE 1=2 AND ISNULL(KODFKL,'''')<>'''' AND (ISNULL(KOD,'''')<>LTRIM(RTRIM(ISNULL(KODFKL,'''')))+''.''+LTRIM(RTRIM(ISNULL(KMON,''''))));

		-- Ditar
		 UPDATE DKL
			SET KOD    = UPPER(LTRIM(RTRIM(dbo.Isd_SegmentFind(KOD,0,1)))+''.''+LTRIM(RTRIM(ISNULL(KMON,'''')))), 
				KMON   = UPPER(LTRIM(RTRIM(ISNULL(KMON,''''))))
		  WHERE 1=2 AND ISNULL(KOD,'''')<>'''' AND (ISNULL(KOD,'''')<>dbo.Isd_SegmentFind(KOD,0,1)+''.''+ISNULL(KMON,''''));

		 UPDATE DKL
			SET DTFAT = DATEDOK 
		  WHERE 1=2 AND ISNULL(NRFAT,''0'')=''0'' AND ((DTFAT IS NULL) OR DTFAT<=DBO.DATEVALUE(''30/12/1899'')); 

		-- Liber
		 UPDATE LKL
			SET KOD  = UPPER(LTRIM(RTRIM(ISNULL(SG1,'''')))+''.''+LTRIM(RTRIM(ISNULL(KMON,'''')))),
				KMON = UPPER(LTRIM(RTRIM(ISNULL(KMON,''''))))
		  WHERE 1=2 AND LTRIM(RTRIM(ISNULL(SG1,'''')))<>'''' AND 
			   (ISNULL(KOD,'''')='''' OR ISNULL(KOD,'''')<>LTRIM(RTRIM(ISNULL(SG1,'''')))+''.''+LTRIM(RTRIM(ISNULL(KMON,'''')))); '
     -- FJ
		EXEC (@SqlFilter00);   

     -- FF
		SET   @SqlFilter01 = REPLACE(REPLACE(REPLACE(@SqlFilter00,'UPDATE FJ','UPDATE FF'),'UPDATE DKL','UPDATE DFU'),'UPDATE LKL','UPDATE LFU');
		EXEC (@SqlFilter01);   

     -- ARKA
		SET   @Nr1 = CHARINDEX('-- Ditar',@SqlFilter00);
		IF    @Nr1>0
			  SET @SqlFilter00 = SUBSTRING(@SqlFilter00,@Nr1,LEN(@SqlFilter00));
		SET   @SqlFilter00 = '
		-- Dokument
		 UPDATE ARKA
		    SET KODAB  = UPPER(LTRIM(RTRIM(KODAB))),
		        KMON   = UPPER(LTRIM(RTRIM(ISNULL(KMON,''''))))
		  WHERE 1=2 AND ISNULL(KODAB,'''')<>'''' AND (KODAB+''.''+KMON<>LTRIM(RTRIM(ISNULL(KODAB,'''')))+''.''+LTRIM(RTRIM(ISNULL(KMON,'''')))); 
		  
		  '+@SqlFilter00;

			  
		SET   @SqlFilter00 = REPLACE(REPLACE(@SqlFilter00,'UPDATE DKL','UPDATE DAR'),'UPDATE LKL','UPDATE LAR');
		SET   @SqlFilter01 = @SqlFilter00;
		EXEC (@SqlFilter01);   

     -- BANKA
		SET   @SqlFilter01 = REPLACE(REPLACE(REPLACE(@SqlFilter00,'UPDATE ARKA','UPDATE BANKA'),'UPDATE DAR','UPDATE DBA'),'UPDATE LAR','UPDATE LBA');
		EXEC (@SqlFilter01);   


-- 4    UPDATE Rrjeshta dokumenta

-- 4.1  Rrjeshta ne Scr te dokumentave per rastet Klient,Furnitor,Arke,Banke
		SET @SqlFilter00 = '
		 UPDATE ARKASCR
			SET KMON      = UPPER(LTRIM(RTRIM(ISNULL(KMON,'''')))),
				KOD       = UPPER(dbo.Isd_SegmentFind(KODAF,0,1)+''.''+LTRIM(RTRIM(ISNULL(KMON,'''')))),
				KODAF     = UPPER(dbo.Isd_SegmentFind(KODAF,0,1)), 
				LLOGARI   = UPPER(dbo.Isd_SegmentFind(KODAF,0,1)), 
				LLOGARIPK = UPPER(dbo.Isd_SegmentFind(KODAF,0,1)) 
		  WHERE CHARINDEX(TIPKLL,''ABFS'')>0    AND 
			   (
			    KOD   <>UPPER(dbo.Isd_SegmentFind(KODAF,0,1)+''.''+LTRIM(RTRIM(ISNULL(KMON,''''))))
			    OR
			    KODAF<>UPPER(LTRIM(RTRIM(KODAF)))
				OR
			    KMON <>UPPER(LTRIM(RTRIM(KMON)))
			    ); '
        SET   @SqlFilter01 = @SqlFilter00;
		EXEC (@SqlFilter01);   
		SET   @SqlFilter01 = REPLACE(@SqlFilter00,'UPDATE ARKA','UPDATE BANKA');
		EXEC (@SqlFilter01);   
		SET   @SqlFilter01 = REPLACE(@SqlFilter00,'UPDATE ARKA','UPDATE VS');
		EXEC (@SqlFilter01);   
		SET   @SqlFilter01 = REPLACE(@SqlFilter00,'UPDATE ARKA','UPDATE VSST');
		EXEC (@SqlFilter01);   


-- 4.2  Rrjeshta ne Scr te dokumentave per rastet Llogari (Arka,Banka,Vs,VsSt) -- me i sakte modeli i komentuar por me kujdes....

--		SET @SqlFilter00 = '
--		 UPDATE ARKASCR
--			SET KMON      = UPPER(LTRIM(RTRIM(ISNULL(KMON,'''')))),
--				KOD       = UPPER(dbo.Isd_SegmentFind(KODAF,0,1)+''.''+
--                                dbo.Isd_SegmentFind(KODAF,0,2)+''.''+
--                                dbo.Isd_SegmentFind(KODAF,0,3)+''.''+
--                                dbo.Isd_SegmentFind(KODAF,0,4)+''.''+
--                                LTRIM(RTRIM(ISNULL(KMON,'''')))),
--				LLOGARI   = UPPER(dbo.Isd_SegmentFind(KODAF,0,1)), 
--				LLOGARIPK = UPPER(dbo.Isd_SegmentFind(KODAF,0,1))--, 
--				KODAF     = UPPER(dbo.Isd_SegmentFind(KODAF,0,1)+
--                                CASE WHEN dbo.Isd_SegmentFind(KODAF,0,4)<>''''
--                                          THEN ''.'' + dbo.Isd_SegmentFind(KODAF,0,2) +
--                                               ''.'' + dbo.Isd_SegmentFind(KODAF,0,3) +
--                                               ''.'' + dbo.Isd_SegmentFind(KODAF,0,4) 

--                                     WHEN dbo.Isd_SegmentFind(KODAF,0,3)<>'''' 
--                                          THEN ''.'' + dbo.Isd_SegmentFind(KODAF,0,2) +
--                                               ''.'' + dbo.Isd_SegmentFind(KODAF,0,3) 

--                                     WHEN dbo.Isd_SegmentFind(KODAF,0,2)<>'''' 
--                                          THEN ''.'' + dbo.Isd_SegmentFind(KODAF,0,2)
 
--                                     ELSE      '''' 
--                                END )
--		  WHERE TIPKLL=''T'' AND 
--			  ((KOD  <>  UPPER(dbo.Isd_SegmentFind(KODAF,0,1)+''.''+
--                             dbo.Isd_SegmentFind(KODAF,0,2)+''.''+
--                             dbo.Isd_SegmentFind(KODAF,0,3)+''.''+
--                             dbo.Isd_SegmentFind(KODAF,0,4)+''.''+
--                             LTRIM(RTRIM(ISNULL(KMON,'''')))) ) OR
--			   (KODAF<>  UPPER(dbo.Isd_SegmentFind(KODAF,0,1)+
--                             CASE WHEN dbo.Isd_SegmentFind(KODAF,0,4)<>'''' 
--                                       THEN ''.'' + dbo.Isd_SegmentFind(KODAF,0,2) +
--                                            ''.'' + dbo.Isd_SegmentFind(KODAF,0,3) +
--                                            ''.'' + dbo.Isd_SegmentFind(KODAF,0,4)
 
--                                  WHEN dbo.Isd_SegmentFind(KODAF,0,3)<>'''' 
--                                       THEN ''.'' + dbo.Isd_SegmentFind(KODAF,0,2) +
--                                            ''.'' + dbo.Isd_SegmentFind(KODAF,0,3) 

--                                  WHEN dbo.Isd_SegmentFind(KODAF,0,2)<>'''' 
--                                       THEN ''.'' + dbo.Isd_SegmentFind(KODAF,0,2) 

--                                  ELSE      '''' 

--                             END ) OR
--			   (KMON <>UPPER(LTRIM(RTRIM(KMON)))) ); ';


		 SET @SqlFilter00 = '
		 UPDATE ARKASCR
			SET KMON      = UPPER(LTRIM(RTRIM(ISNULL(KMON,'''')))),
				KOD       = UPPER(dbo.Isd_SegmentFind(KODAF,0,1)+''.''+dbo.Isd_SegmentFind(KODAF,0,2)+''.''+
				                  dbo.Isd_SegmentFind(KODAF,0,3)+''.''+dbo.Isd_SegmentFind(KODAF,0,4)+''.''+LTRIM(RTRIM(ISNULL(KMON,'''')))),
				LLOGARI   = UPPER(dbo.Isd_SegmentFind(KODAF,0,1)), 
				LLOGARIPK = UPPER(dbo.Isd_SegmentFind(KODAF,0,1))
		  WHERE TIPKLL=''T'' AND 
			   (
			    KOD  <>UPPER(dbo.Isd_SegmentFind(KODAF,0,1)+''.''+dbo.Isd_SegmentFind(KODAF,0,2)+''.''+
                             dbo.Isd_SegmentFind(KODAF,0,3)+''.''+dbo.Isd_SegmentFind(KODAF,0,4)+''.''+LTRIM(RTRIM(ISNULL(KMON,''''))))
                OR
			    KMON <>UPPER(LTRIM(RTRIM(KMON))) 
			    ); ';

         SET @TblList = 'ARKA,BANKA,VS,VSST';
         SET @Nr1     = LEN(@TblList)-LEN(REPLACE(@TblList,',',''))+1;
         SET @Ind1    = 1;
       WHILE @Ind1 <= @Nr1
         BEGIN
           SET   @TName = dbo.Isd_StringInListStr(@TblList,@Ind1,',');     
    	   SET   @SqlFilter01 = REPLACE(@SqlFilter00,' ARKA',' '+@TName);
	       EXEC (@SqlFilter01);
           SET   @Ind1 = @Ind1 + 1;
         END;


-- 4.3  Rrjeshta ne Scr te dokumentave per rastet Llogari (Fk,FkSt) -- me i sakte modeli i komentuar por me kujdes....
--		SET @SqlFilter00 = '
--		 UPDATE FKSCR
--			SET KMON      = UPPER(LTRIM(RTRIM(ISNULL(KMON,'''')))),
--				KOD       = UPPER(dbo.Isd_SegmentFind(LLOGARI,0,1)+''.''+
--                                  dbo.Isd_SegmentFind(LLOGARI,0,2)+''.''+
--                                  dbo.Isd_SegmentFind(LLOGARI,0,3)+''.''+
--                                  dbo.Isd_SegmentFind(LLOGARI,0,4)+''.''+
--                                  LTRIM(RTRIM(ISNULL(KMON,'''')))),
--				LLOGARIPK = UPPER(dbo.Isd_SegmentFind(LLOGARI,0,1)), 
--				LLOGARI   = UPPER(dbo.Isd_SegmentFind(LLOGARI,0,1)+
--                                CASE WHEN dbo.Isd_SegmentFind(LLOGARI,0,4)<>''''
--                                          THEN ''.'' + dbo.Isd_SegmentFind(LLOGARI,0,2) +
--                                               ''.'' + dbo.Isd_SegmentFind(LLOGARI,0,3) +
--                                               ''.'' + dbo.Isd_SegmentFind(LLOGARI,0,4)
 
--                                     WHEN dbo.Isd_SegmentFind(LLOGARI,0,3)<>'''' 
--                                          THEN ''.'' + dbo.Isd_SegmentFind(LLOGARI,0,2) +
--                                               ''.'' + dbo.Isd_SegmentFind(LLOGARI,0,3) 

--                                     WHEN dbo.Isd_SegmentFind(LLOGARI,0,2)<>'''' 
--                                          THEN ''.'' + dbo.Isd_SegmentFind(LLOGARI,0,2) 

--                                     ELSE      '''' 
--                                END )
--		  WHERE 
--			  ((KOD    <>  UPPER(dbo.Isd_SegmentFind(LLOGARI,0,1)+''.''+
--                               dbo.Isd_SegmentFind(LLOGARI,0,2)+''.''+
--                               dbo.Isd_SegmentFind(LLOGARI,0,3)+''.''+
--                               dbo.Isd_SegmentFind(LLOGARI,0,4)+''.''+
--                               LTRIM(RTRIM(ISNULL(KMON,'''')))) ) OR
--			   (LLOGARI<>  UPPER(dbo.Isd_SegmentFind(LLOGARI,0,1)+
--                               CASE WHEN dbo.Isd_SegmentFind(LLOGARI,0,4)<>''''
--                                         THEN ''.'' + dbo.Isd_SegmentFind(LLOGARI,0,2) +
--                                              ''.'' + dbo.Isd_SegmentFind(LLOGARI,0,3) +
--                                              ''.'' + dbo.Isd_SegmentFind(LLOGARI,0,4)
 
--                                     WHEN dbo.Isd_SegmentFind(LLOGARI,0,3)<>'''' 
--                                         THEN ''.'' + dbo.Isd_SegmentFind(LLOGARI,0,2) +
--                                              ''.'' + dbo.Isd_SegmentFind(LLOGARI,0,3) 

--                                     WHEN dbo.Isd_SegmentFind(LLOGARI,0,2)<>'''' 
--                                         THEN ''.'' + dbo.Isd_SegmentFind(LLOGARI,0,2) 

--                                     ELSE     '''' 
--                               END ) OR
--			   (KMON   <>UPPER(LTRIM(RTRIM(KMON)))) ) '

/*          SET @SqlFilter00 = '
		 UPDATE FKSCR
			SET KMON      = UPPER(LTRIM(RTRIM(ISNULL(KMON,'''')))),
				KOD       = UPPER(dbo.Isd_SegmentFind(LLOGARI,0,1)+''.''+dbo.Isd_SegmentFind(LLOGARI,0,2)+''.''+
                                  dbo.Isd_SegmentFind(LLOGARI,0,3)+''.''+dbo.Isd_SegmentFind(LLOGARI,0,4)+''.''+LTRIM(RTRIM(ISNULL(KMON,'''')))),
				LLOGARIPK = UPPER(dbo.Isd_SegmentFind(LLOGARI,0,1))
		  WHERE 
			   (KOD    <>UPPER(dbo.Isd_SegmentFind(LLOGARI,0,1)+''.''+dbo.Isd_SegmentFind(LLOGARI,0,2)+''.''+
                               dbo.Isd_SegmentFind(LLOGARI,0,3)+''.''+dbo.Isd_SegmentFind(LLOGARI,0,4)+''.''+LTRIM(RTRIM(ISNULL(KMON,''''))))  
                OR
			    KMON   <>UPPER(LTRIM(RTRIM(KMON)))
			    ); ';
        SET   @SqlFilter01 = @SqlFilter00;
		EXEC (@SqlFilter01);   
		SET   @SqlFilter01 = REPLACE(@SqlFilter00,'UPDATE FK','UPDATE FKST'); */  -- u hoq 30.04.2021

-- 4.4  Rrjeshta ne Scr te dokumentave per rastet Llogari (Faturimet)

--		SET @SqlFilter00 = '
--		 UPDATE B
--			SET KOD       = UPPER(dbo.Isd_SegmentFind(KODAF,0,1)+''.''+
--                                dbo.Isd_SegmentFind(KODAF,0,2)+''.''+
--                                dbo.Isd_SegmentFind(KODAF,0,3)+''.''+
--                                dbo.Isd_SegmentFind(KODAF,0,4)+''.''+
--                                LTRIM(RTRIM(ISNULL(A.KMON,'''')))),
--				KARTLLG   = UPPER(dbo.Isd_SegmentFind(KODAF,0,1)), 
--				LLOGARIPK = UPPER(dbo.Isd_SegmentFind(KODAF,0,1)), 
--				KODAF     = UPPER(dbo.Isd_SegmentFind(KODAF,0,1)+
--                                CASE WHEN dbo.Isd_SegmentFind(KODAF,0,4)<>''''
--                                          THEN ''.'' + dbo.Isd_SegmentFind(KODAF,0,2) +
--                                               ''.'' + dbo.Isd_SegmentFind(KODAF,0,3) +
--                                               ''.'' + dbo.Isd_SegmentFind(KODAF,0,4)
 
--                                     WHEN dbo.Isd_SegmentFind(KODAF,0,3)<>'''' 
--                                          THEN ''.'' + dbo.Isd_SegmentFind(KODAF,0,2) +
--                                               ''.'' + dbo.Isd_SegmentFind(KODAF,0,3)
 
--                                     WHEN dbo.Isd_SegmentFind(KODAF,0,2)<>'''' 
--                                          THEN ''.'' + dbo.Isd_SegmentFind(KODAF,0,2) 

--                                     ELSE      '''' 
--                                END )
--           FROM FJ A INNER JOIN FJSCR B ON A.NRRENDOR=B.NRD
--		  WHERE B.TIPKLL=''L'' AND 
--			  ((B.KOD <>  UPPER(dbo.Isd_SegmentFind(KODAF,0,1)+''.''+
--                              dbo.Isd_SegmentFind(KODAF,0,2)+''.''+
--                              dbo.Isd_SegmentFind(KODAF,0,3)+''.''+
--                              dbo.Isd_SegmentFind(KODAF,0,4)+''.''+
--                              LTRIM(RTRIM(ISNULL(A.KMON,'''')))) ) OR
--			   (KODAF <>  UPPER(dbo.Isd_SegmentFind(KODAF,0,1)+
--                              CASE WHEN dbo.Isd_SegmentFind(KODAF,0,4)<>''''
--                                        THEN ''.'' + dbo.Isd_SegmentFind(KODAF,0,2) +
--                                             ''.'' + dbo.Isd_SegmentFind(KODAF,0,3) +
--                                             ''.'' + dbo.Isd_SegmentFind(KODAF,0,4)
 
--                                   WHEN dbo.Isd_SegmentFind(KODAF,0,3)<>'''' 
--                                        THEN ''.'' + dbo.Isd_SegmentFind(KODAF,0,2) +
--                                             ''.'' + dbo.Isd_SegmentFind(KODAF,0,3)
 
--                                   WHEN dbo.Isd_SegmentFind(KODAF,0,2)<>'''' 
--                                        THEN ''.'' + dbo.Isd_SegmentFind(KODAF,0,2) 

--                                   ELSE      '''' 
--                              END ) OR
--			   (A.KMON<>UPPER(LTRIM(RTRIM(A.KMON)))) ); ';

		 SET @SqlFilter00 = '
		 UPDATE B
			SET KOD       = UPPER(dbo.Isd_SegmentFind(KODAF,0,1)+''.''+dbo.Isd_SegmentFind(KODAF,0,2)+''.''+
                                  dbo.Isd_SegmentFind(KODAF,0,3)+''.''+dbo.Isd_SegmentFind(KODAF,0,4)+''.''+LTRIM(RTRIM(ISNULL(A.KMON,'''')))),
				KARTLLG   = UPPER(dbo.Isd_SegmentFind(KODAF,0,1)), 
				LLOGARIPK = UPPER(dbo.Isd_SegmentFind(KODAF,0,1))
           FROM FJ A INNER JOIN FJSCR B ON A.NRRENDOR=B.NRD
		  WHERE (B.TIPKLL=''L'' OR B.TIPKLL=''X'') 
		         AND 
			    (B.KOD <>UPPER(dbo.Isd_SegmentFind(KODAF,0,1)+''.''+dbo.Isd_SegmentFind(KODAF,0,2)+''.''+
                               dbo.Isd_SegmentFind(KODAF,0,3)+''.''+dbo.Isd_SegmentFind(KODAF,0,4)+''.''+LTRIM(RTRIM(ISNULL(A.KMON,''''))))  
                 OR
			     A.KMON<>UPPER(LTRIM(RTRIM(A.KMON)))
			     ); ';
			     
-- Kujdes: Rastet kur KODAF nuk ka magazinen ne rastet e llogarive ose aktive por fusha KOD mund ta kete ...???
-- Ne kete rast hiqet nga KOD segmenti KMAG i dokumentit ... Te rishikohet ...

-- Mire do te ishte qe te kishim ne vend te    dbo.Isd_SegmentFind(KODAF,0,4)   te kishim    dbo.Isd_SegmentFind(KOD,0,4), 
-- pra jo KODAF por KOD per segment[4]

         SET @TblList = 'FJ,FF,FJT,OFK,ORK,SM,ORF';
         SET @Nr1     = LEN(@TblList)-LEN(REPLACE(@TblList,',',''))+1;
         SET @Ind1    = 1;
       WHILE @Ind1 <= @Nr1
         BEGIN
           SET   @TName = dbo.Isd_StringInListStr(@TblList,@Ind1,',');     
    	   SET   @SqlFilter01 = REPLACE(@SqlFilter00,' FJ',' '+@TName);
	       EXEC (@SqlFilter01);
           SET   @Ind1 = @Ind1 + 1;
         END;


-- 4.5  Rrjeshta ne Scr te dokumentave per rastet Artikuj (Fh/Fd)

--		SET @SqlFilter00 = '
--		 UPDATE B
--			SET KOD       = UPPER(ISNULL(KMAG,'''')             +''.''+
--                                  dbo.Isd_SegmentFind(KODAF,0,1)+''.''+
--                                  dbo.Isd_SegmentFind(KODAF,0,2)+''.''+
--                                  dbo.Isd_SegmentFind(KODAF,0,3)+''.''+
--                                  ''''),
--				KARTLLG   = UPPER(dbo.Isd_SegmentFind(KODAF,0,1)), 
--				KODAF     = UPPER(dbo.Isd_SegmentFind(KODAF,0,1)+
--                                CASE WHEN dbo.Isd_SegmentFind(KODAF,0,3)<>''''
--                                          THEN ''.'' + dbo.Isd_SegmentFind(KODAF,0,2) +
--                                               ''.'' + dbo.Isd_SegmentFind(KODAF,0,3) +

--                                     WHEN dbo.Isd_SegmentFind(KODAF,0,2)<>'''' 
--                                          THEN ''.'' + dbo.Isd_SegmentFind(KODAF,0,2) +

--                                     ELSE '''' 

--                                END )
--           FROM FD A INNER JOIN FDSCR B ON A.NRRENDOR=B.NRD
--		  WHERE  
--			  ((B.KOD <>UPPER(ISNULL(KMAG,'''')               +''.''+
--                              dbo.Isd_SegmentFind(KODAF,0,1)+''.''+
--                              dbo.Isd_SegmentFind(KODAF,0,2)+''.''+
--                              dbo.Isd_SegmentFind(KODAF,0,3)+''.''+
--                              '''')) OR
--			   (KODAF <>UPPER(dbo.Isd_SegmentFind(KODAF,0,1)+
--                                CASE WHEN dbo.Isd_SegmentFind(KODAF,0,3)<>''''
--                                          THEN ''.'' + dbo.Isd_SegmentFind(KODAF,0,2) +
--                                               ''.'' + dbo.Isd_SegmentFind(KODAF,0,3) +

--                                     WHEN dbo.Isd_SegmentFind(KODAF,0,2)<>'''' 

--                                          THEN ''.'' + dbo.Isd_SegmentFind(KODAF,0,2) +

--                                     ELSE      '''' 
--                                END ) ); ';

		 SET @SqlFilter00 = '
		 UPDATE B
			SET KOD       = UPPER(ISNULL(KMAG,'''')+''.''+dbo.Isd_SegmentFind(KODAF,0,1)+''.''+dbo.Isd_SegmentFind(KODAF,0,2)+''.''+dbo.Isd_SegmentFind(KODAF,0,3)+''.''),
				KARTLLG   = UPPER(dbo.Isd_SegmentFind(KODAF,0,1))
           FROM FD A INNER JOIN FDSCR B ON A.NRRENDOR=B.NRD
		  WHERE  
			    B.KOD     <>UPPER(ISNULL(KMAG,'''')+''.''+dbo.Isd_SegmentFind(KODAF,0,1)+''.''+dbo.Isd_SegmentFind(KODAF,0,2)+''.''+dbo.Isd_SegmentFind(KODAF,0,3)+''.'');';

    	   SET   @SqlFilter01 = @SqlFilter00;
	       EXEC (@SqlFilter01);
    	   SET   @SqlFilter01 = REPLACE(@SqlFilter00,' FD',' FH');
	       EXEC (@SqlFilter01);


-- 4.6  Rrjeshta ne Scr te dokumentave per rastet Aktive (AQ)
-- Kujdes: Rastet kur KODAF nuk ka magazinen ne rastet e aktive por fusha KOD mund ta kete ...???
-- Ne kete rast hiqet nga KOD nuk prekete segmenti[4] i KMAG-ut ... Te rishikohet ...

		 SET @SqlFilter00 = '
		 UPDATE B
			SET KOD       = UPPER(dbo.Isd_SegmentFind(KODAF,0,1)+''.''+dbo.Isd_SegmentFind(KODAF,0,2)+''.''+
                                  dbo.Isd_SegmentFind(KODAF,0,3)+''.''+dbo.Isd_SegmentFind(KODAF,0,4)+''.''+LTRIM(RTRIM(ISNULL(A.KMON,'''')))),
				KARTLLG   = UPPER(dbo.Isd_SegmentFind(KODAF,0,1))
           FROM AQ A INNER JOIN AQSCR B ON A.NRRENDOR=B.NRD
		  WHERE (B.KOD <>UPPER(dbo.Isd_SegmentFind(KODAF,0,1)+''.''+dbo.Isd_SegmentFind(KODAF,0,2)+''.''+
                               dbo.Isd_SegmentFind(KODAF,0,3)+''.''+dbo.Isd_SegmentFind(KOD,0,4)  +''.''+LTRIM(RTRIM(ISNULL(A.KMON,''''))))  
                 OR
			     A.KMON<>UPPER(LTRIM(RTRIM(A.KMON)))
			     ); ';

    	   SET   @SqlFilter01 = @SqlFilter00;
	       EXEC (@SqlFilter01);


-- 4.7  Rrjeshta ne Scr te dokumentave per rastet Artikuj (Faturimet)

--		SET @SqlFilter00 = '
--		 UPDATE B
--			SET KOD       = UPPER(ISNULL(KMAG,'''')             +''.''+
--                                dbo.Isd_SegmentFind(KODAF,0,1)+''.''+
--                                dbo.Isd_SegmentFind(KODAF,0,2)+''.''+
--                                dbo.Isd_SegmentFind(KODAF,0,3)+''.''+
--                                LTRIM(RTRIM(ISNULL(A.KMON,'''')))),
--				KARTLLG   = UPPER(dbo.Isd_SegmentFind(KODAF,0,1)), 
--				LLOGARIPK = UPPER(dbo.Isd_SegmentFind(KODAF,0,1)), 
--				KODAF     = UPPER(dbo.Isd_SegmentFind(KODAF,0,1)+
--                                CASE WHEN dbo.Isd_SegmentFind(KODAF,0,3)<>''''
--                                          THEN ''.'' + dbo.Isd_SegmentFind(KODAF,0,2) +
--                                               ''.'' + dbo.Isd_SegmentFind(KODAF,0,3) +

--                                     WHEN dbo.Isd_SegmentFind(KODAF,0,2)<>'''' 
--                                          THEN ''.'' + dbo.Isd_SegmentFind(KODAF,0,2) +

--                                     ELSE      '''' 
--                                END )
--           FROM FJ A INNER JOIN FJSCR B ON A.NRRENDOR=B.NRD
--		  WHERE B.TIPKLL=''K'' AND 
--			  ((B.KOD <>  UPPER(ISNULL(KMAG,'''')             +''.''+
--                              dbo.Isd_SegmentFind(KODAF,0,1)+''.''+
--                              dbo.Isd_SegmentFind(KODAF,0,2)+''.''+
--                              dbo.Isd_SegmentFind(KODAF,0,3)+''.''+
--                              LTRIM(RTRIM(ISNULL(A.KMON,'''')))) ) OR
--			   (KODAF <>  UPPER(dbo.Isd_SegmentFind(KODAF,0,1)+
--                              CASE WHEN dbo.Isd_SegmentFind(KODAF,0,3)<>''''
--                                        THEN ''.'' + dbo.Isd_SegmentFind(KODAF,0,2) +
--                                             ''.'' + dbo.Isd_SegmentFind(KODAF,0,3) +

--                                   WHEN dbo.Isd_SegmentFind(KODAF,0,2)<>'''' 
--                                        THEN ''.'' + dbo.Isd_SegmentFind(KODAF,0,2) +

--                                   ELSE      '''' 
--                              END )) OR
--			   (A.KMON<>UPPER(LTRIM(RTRIM(A.KMON)))) ); ';

		 SET @SqlFilter00 = '
		 UPDATE B
			SET KOD       = UPPER(ISNULL(KMAG,'''')+''.''+dbo.Isd_SegmentFind(KODAF,0,1) + ''.'' +dbo.Isd_SegmentFind(KODAF,0,2) + ''.'' +
                                                          dbo.Isd_SegmentFind(KODAF,0,3) + ''.'' +LTRIM(RTRIM(ISNULL(A.KMON,'''')))),
				KARTLLG   = UPPER(dbo.Isd_SegmentFind(KODAF,0,1)), 
				LLOGARIPK = UPPER(dbo.Isd_SegmentFind(KODAF,0,1))
           FROM FJ A INNER JOIN FJSCR B ON A.NRRENDOR=B.NRD
		  WHERE B.TIPKLL=''K'' AND 
			   (
			    B.KOD     <>UPPER(ISNULL(KMAG,'''')+''.''+dbo.Isd_SegmentFind(KODAF,0,1) + ''.''+dbo.Isd_SegmentFind(KODAF,0,2) + ''.'' +
                                                          dbo.Isd_SegmentFind(KODAF,0,3) + ''.''+LTRIM(RTRIM(ISNULL(A.KMON,'''')))) 
                OR
			    A.KMON    <>UPPER(LTRIM(RTRIM(A.KMON)))
			    );';

         SET @TblList = 'FJ,FF,FJT,OFK,ORK,SM,ORF';
         SET @Nr1     = LEN(@TblList)-LEN(REPLACE(@TblList,',',''))+1;
         SET @Ind1    = 1;
       WHILE @Ind1 <= @Nr1
         BEGIN
           SET   @TName = dbo.Isd_StringInListStr(@TblList,@Ind1,',');     
    	   SET   @SqlFilter01 = REPLACE(@SqlFilter00,' FJ',' '+@TName);
	       EXEC (@SqlFilter01);
           SET   @Ind1 = @Ind1 + 1;
         END;


-- 5.  Fushat e meposhteme jane me germa te medha dhe pa boshe te teperta ne CONFIGLM...

         SET @TName = 'CONFIGLM';     
         SET @SqlFilter00 = ' 
                     UPDATE '+@TName+' 
                        SET K_O_D =  UPPER(LTRIM(RTRIM(K_O_D)))
                      WHERE K_O_D <> UPPER(LTRIM(RTRIM(K_O_D))) Collate Latin1_General_CS_AS; ';

       IF (dbo.Isd_StringInListExs(@ListTables,@TName)>0)  
           BEGIN
             SET   @ListFields  = dbo.Isd_ListFieldsTable(@TName,'');
             SET   @Nr2         = LEN(@ListFields)-LEN(REPLACE(@ListFields,',',''))+1;
             SET   @Ind2        = 1;
          --
             WHILE @Ind2 <= @Nr2
               BEGIN
                 SET @FName = dbo.Isd_StringInListStr(@ListFields,@Ind2,',');
                 IF (SUBSTRING(@FName,1,3)='LLG' OR SUBSTRING(@FName,1,4)='LLOG') AND 
                     dbo.Isd_FieldTableExists(@TName,@FName)>0  
                     BEGIN
                       SET   @SqlFilter01 = REPLACE(@SQLFilter00,'K_O_D',@FName);
                       EXEC (@SqlFilter01);                   
                     END;
                 SET @Ind2 = @Ind2 + 1;
               END;
           END;



-- 6.  Fushat e meposhteme jane me germa te medha dhe pa boshe te teperta ne CONFIGMG...

         SET @TName = 'CONFIGMG';     
         SET @SqlFilter00 = ' 
                     UPDATE '+@TName+' 
                        SET K_O_D =  UPPER(LTRIM(RTRIM(K_O_D)))
                      WHERE K_O_D <> UPPER(LTRIM(RTRIM(K_O_D))) Collate Latin1_General_CS_AS; ';

       IF (dbo.Isd_StringInListExs(@ListTables,@TName)>0)  
           BEGIN
             SET   @ListFields  = dbo.Isd_ListFieldsTable(@TName,'');
             SET   @Nr2         = LEN(@ListFields)-LEN(REPLACE(@ListFields,',',''))+1;
             SET   @Ind2        = 1;
          --
             WHILE @Ind2 <= @Nr2
               BEGIN
                 SET @FName = dbo.Isd_StringInListStr(@ListFields,@Ind2,',');
                 IF  SUBSTRING(@FName,1,4)='NJES' AND dbo.Isd_FieldTableExists(@TName,@FName)>0  
                     BEGIN
                       SET   @SqlFilter01 = REPLACE(@SQLFilter00,'K_O_D',@FName);
                       EXEC (@SqlFilter01);                   
                     END
                 SET @Ind2 = @Ind2 + 1;
               END;
           END;

GO
