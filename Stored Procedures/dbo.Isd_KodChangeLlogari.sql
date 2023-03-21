SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






-- Exec [Dbo].[Isd_KodChangeLlogari]
-- Exec [Dbo].[Isd_KodChangeLlogari] '','',0,'KODFKL=''AAAA''',',FJ,FF',7
-- Exec [Dbo].[Isd_KodChangeLlogari] '467','46700',1,'','',1              -- Kalim nga Sintetik ne Analize

CREATE Procedure [dbo].[Isd_KodChangeLlogari]
(@PKod        Varchar(50),
 @PKodNew     Varchar(50),
 @PChangeName Int,

 @PWhere      Varchar(Max),
 @PListTables Varchar(Max),
 @PCaseUpdate Int
)
As

-- CaseUpdate 1:   Nje llogari te vetme nga ekrani Llogari
-- CaseUpdate 2:   Te gjitha sipas tabeles (Dokument,Reference, te gjitha)

-- CaseUpdate 5:   Te gjitha dokumentat pa filter (jo referencat)
-- CaseUpdate 6:   Te gjitha Referencat pa filter (jo dokumentat)

-- CaseUpdate 7:   Konkret per dokument apo reference dhe me filter...


     Declare @TableNameTmp Varchar(100),
             @ListTables   Varchar(Max),
             @TName        Varchar(100),
             @Where        Varchar(Max),
             @SqlFilter00  Varchar(Max),
             @SqlFilter01  Varchar(Max),
             @TblList      Varchar(Max),
             @Dokument     Bit,
             @Referenc     Bit,
             @MaxInd       Int,
             @Ind          Int

 
         Set @TableNameTmp = '#KODLLG'
         Set @TName        = ''
         Set @Dokument     = 0
         Set @Referenc     = 0
         Set @ListTables   = ''
         Set @Where        = ''
         Set @MaxInd       = 0



    if @PCaseUpdate=1 or @PCaseUpdate=2
       begin
         Set @Dokument  = 1
         Set @Referenc  = 1
       end
    else
    if @PCaseUpdate=5 
       begin
         Set @Dokument  = 1
       end
    else
    if @PCaseUpdate=6
       begin
         Set @Referenc  = 1
       end
    else
       begin
         Set @ListTables = Upper(@PListTables)
         Set @Where      = LTrim(RTrim(@PWhere))
       end

         Set @ListTables = Upper(','+@ListTables+',')
      
          if Exists (SELECT NAME FROM Sys.Objects Where Object_Id=Object_Id(@TableNameTmp))
		     DROP TABLE #KODLLG

      SELECT KOD,KODNEW,PERSHKRIM,CHANGENAME=0,TROW,TAGNR
        INTO #KODLLG
        FROM KODCHANGE 
       WHERE 1=2
   


   if @PCaseUpdate<>1

      begin

          INSERT INTO #KODLLG
                (KOD,KODNEW,CHANGENAME,TROW,TAGNR)
          SELECT KOD,KODNEW,1,         TROW,TAGNR
            FROM KODCHANGE A
           WHERE TIPKLL='LLG' AND 
                (ISNULL(KOD,'')<>'' AND ISNULL(KODNEW,'')<>'') AND
                (KOD<>KODNEW) --AND (NOT (EXISTS (SELECT KOD FROM LLOGARI B WHERE B.KOD=A.KODNEW)))
        ORDER BY KOD

      end

   else

      begin   -- Rasti nje Kod
          Insert Into #KODLLG 
                 (KOD,KODNEW,CHANGENAME,TAGNR)
          Values (@PKod,@PKodNew,@PChangeName,1)
      end


        if IsNull((SELECT TOP 1 1 FROM #KODLLG),0)=0
           Return 


    UPDATE A
       SET A.PERSHKRIM = B.PERSHKRIM
      FROM #KODLLG A INNER JOIN LLOGARI B ON A.KODNEW=B.KOD


-- Grupi Faturime

       Set @SqlFilter00 = '
			UPDATE B
			   SET B.KARTLLG    = C.KODNEW,
                   B.LLOGARIPK  = C.KODNEW,
				   B.KODAF      = Dbo.Isd_SegmentNewInsert(B.KODAF,C.KODNEW,1),
				   B.KOD        = C.KODNEW+''.''+
                                  Dbo.Isd_SegmentFind(B.KODAF,0,2)+''.''+
                                  Dbo.Isd_SegmentFind(B.KODAF,0,3)+''.''+
                                  Dbo.Isd_SegmentFind(B.KODAF,0,4)+''.''+
                                  IsNull(A.KMON,''''),
                   B.NRRENDKLLG = D.NRRENDOR,
                   B.PERSHKRIM  = CASE WHEN C.CHANGENAME=1 THEN D.PERSHKRIM ELSE B.PERSHKRIM END
			  FROM FJ A INNER JOIN FJSCR   B ON A.NRRENDOR = B.NRD
						INNER JOIN '+@TableNameTmp+' C ON B.KARTLLG  = C.KOD
                        INNER JOIN LLOGARI D ON C.KODNEW=D.KOD
             WHERE 1=1 AND TIPKLL=''L'''


       Set @TblList = 'FJ,FF,ORF,ORK,OFK,FJT,SM'
       Set @Ind     = 1

  while @Ind<=7
     begin
       Set @TName = dbo.Isd_StringInListStr(@TblList,@Ind,',')
       if  @Dokument=1 or CharIndex(','+@TName+',',@ListTables)>0  
           begin
             Set  @SqlFilter01 = Replace(@SQLFilter00,' FJ ',' '+@TName+' ')
             if   @Where<>''
                  Set @SqlFilter01 = Replace(@SqlFilter01,'1=1',@Where)
             Exec (@SqlFilter01)
           end
       Set @Ind = @Ind + 1
       Print  @TName
    end 



       Set @SqlFilter00 = '
			UPDATE A
			   SET A.LLOGTVSH = C.KODNEW
			  FROM FJ A INNER JOIN '+@TableNameTmp+' C ON A.LLOGTVSH = C.KOD
             WHERE 1=1 AND ISNULL(A.LLOGTVSH,'''')<>'''' 

			UPDATE A
			   SET A.LLOGARK  = C.KODNEW
			  FROM FJ A INNER JOIN '+@TableNameTmp+' C ON A.LLOGARK  = C.KOD
             WHERE 1=1 AND ISNULL(A.LLOGARK,'''')<>'''' 

			UPDATE A
			   SET A.LLOGZBR  = C.KODNEW
			  FROM FJ A INNER JOIN '+@TableNameTmp+' C ON A.LLOGZBR  = C.KOD
             WHERE 1=1 AND ISNULL(A.LLOGZBR,'''')<>'''' '

       Set @Ind     = 1

  while @Ind<=7
     begin
       Set @TName = dbo.Isd_StringInListStr(@TblList,@Ind,',')
       if  @Dokument=1 or CharIndex(','+@TName+',',@ListTables)>0  
           begin
             Set  @SqlFilter01 = Replace(@SQLFilter00,' FJ ',' '+@TName+' ')
             if   @Where<>''
                  Set @SqlFilter01 = Replace(@SqlFilter01,'1=1',@Where)
             Exec (@SqlFilter01)
           end
       Set @Ind = @Ind + 1
       Print  @TName
    end 


-- Dokumenti DG

       Set @TName = 'DG'
       if  @Dokument=1 or CharIndex(','+@TName+',',@ListTables)>0  
           begin
		     Set    @SqlFilter00 = '
			 	UPDATE B
				   SET B.KARTLLG      = C.KODNEW,
					   B.PERSHKRIMKLL = CASE WHEN C.CHANGENAME=1 THEN D.PERSHKRIM ELSE B.PERSHKRIM END
				  FROM DG A INNER JOIN DGSCR   B ON A.NRRENDOR = B.NRD
							INNER JOIN '+@TableNameTmp+' C ON B.KARTLLG  = C.KOD
							INNER JOIN LLOGARI D ON C.KODNEW=D.KOD
				 WHERE 1=1 AND TIPKLL=''L'''
		     Set   @SqlFilter01 = @SQLFilter00
             if    @Where<>''
                   Set @SqlFilter01 = Replace(@SqlFilter01,'1=1',@Where)
		     Exec (@SqlFilter01)
             Print  @TName
           end


-- Magazina FH,FD

	   Set @SqlFilter00 = '
			UPDATE A
			   SET A.KODLM = Dbo.Isd_SegmentNewInsert(A.KODLM,C.KODNEW,1)
			  FROM FH A INNER JOIN '+@TableNameTmp+' C ON Dbo.Isd_SegmentFind(A.KODLM,0,1)  = C.KOD
						INNER JOIN LLOGARI D ON C.KODNEW=D.KOD
			 WHERE 1=1 '
       Set @TblList = 'FH,FD'
       Set @Ind     = 1

   While @Ind <= 2 
     begin
       Set @TName = dbo.Isd_StringInListStr(@TblList,@Ind,',')
       if  @Dokument=1 or CharIndex(','+@TName+',',@ListTables)>0  
           begin
		     Set   @SqlFilter01 = Replace(@SQLFilter00,' FH ',' '+@TName+' ')
             if    @Where<>''
                   Set @SqlFilter01 = Replace(@SqlFilter01,'1=1',@Where)
		     Exec (@SqlFilter01)
           end
       Set @Ind = @Ind + 1
       Print @TName
      end


-- Grupi i LM  -  ARKA,BANKA,VS,VSST

       Set @SqlFilter00 = '
			UPDATE B
			   SET B.LLOGARI    = C.KODNEW,
                   B.LLOGARIPK  = C.KODNEW,
				   B.KODAF      = Dbo.Isd_SegmentNewInsert(B.KODAF,C.KODNEW,1),
				   B.KOD        = C.KODNEW+''.''+
                                  Dbo.Isd_SegmentFind(B.KODAF,0,2)+''.''+
                                  Dbo.Isd_SegmentFind(B.KODAF,0,3)+''.''+
                                  Dbo.Isd_SegmentFind(B.KODAF,0,4)+''.''+
                                  IsNull(B.KMON,''''),
                   B.PERSHKRIM  = CASE WHEN C.CHANGENAME=1 THEN D.PERSHKRIM ELSE B.PERSHKRIM END
			  FROM ARKA A INNER JOIN ARKASCR   B ON A.NRRENDOR = B.NRD
					 	  INNER JOIN '+@TableNameTmp+' C ON B.LLOGARIPK = C.KOD
                          INNER JOIN LLOGARI D ON C.KODNEW=D.KOD
             WHERE 1=1 AND TIPKLL=''T'''

       Set @TblList = 'ARKA,BANKA,VS,VSST'
       Set @Ind     = 1

   while @Ind<=4
      begin
        Set @TName = dbo.Isd_StringInListStr(@TblList,@Ind,',')
        if  @Dokument=1 or CharIndex(','+@TName+',',@ListTables)>0  
            begin
              Print  @TName
              Set    @SqlFilter01 = Replace(@SQLFilter00,' ARKA ',' '+@TName+' ')

              if @Where<>''
                 Set @SqlFilter01 = Replace(@SqlFilter01,'1=1',@Where)
              Exec  (@SqlFilter01)
            end
       Set @Ind = @Ind + 1
       Print @TName
      end 


-- FK

       Set @SqlFilter00 = '
			UPDATE B
			   SET B.LLOGARI    = Dbo.Isd_SegmentNewInsert(B.LLOGARI,C.KODNEW,1),
                   B.LLOGARIPK  = C.KODNEW,
				   B.KOD        = C.KODNEW+''.''+
                                  Dbo.Isd_SegmentFind(B.LLOGARI,0,2)+''.''+
                                  Dbo.Isd_SegmentFind(B.LLOGARI,0,3)+''.''+
                                  Dbo.Isd_SegmentFind(B.LLOGARI,0,4)+''.''+
                                  IsNull(B.KMON,''''),
                   B.PERSHKRIM  = CASE WHEN C.CHANGENAME=1 THEN D.PERSHKRIM ELSE B.PERSHKRIM END
			  FROM FK A   INNER JOIN FKSCR   B ON A.NRRENDOR = B.NRD
					 	  INNER JOIN '+@TableNameTmp+' C ON B.LLOGARIPK = C.KOD
                          INNER JOIN LLOGARI D ON C.KODNEW=D.KOD
             WHERE 1=1 '
       Set @TblList = 'FK,FKST'
       Set @Ind     = 1

   While @Ind<=2 
     begin
       Set @TName = dbo.Isd_StringInListStr(@TblList,@Ind,',')
       if  @Dokument=1 or CharIndex(','+@TName+',',@ListTables)>0  
           begin
	         Set   @SqlFilter01 = Replace(@SQLFilter00,' FK ',' '+@TName+' ')
             if    @Where<>''
                   Set @SqlFilter01 = Replace(@SqlFilter01,'1=1',@Where)
		     Exec (@SqlFilter01)
           end
       Set @Ind = @Ind + 1
       Print @TName
     end


-- R E F E R E N C A

       Set @SqlFilter00 = '
			UPDATE A
			   SET A.LLOGARI = C.KODNEW
			  FROM KLIENT A INNER JOIN '+@TableNameTmp+' C ON A.LLOGARI = C.KOD
             WHERE 1=1 '

       Set @TblList = 'KLIENT,FURNITOR,ARKAT,BANKAT,SHERBIM'
       Set @Ind     = 1
Print 'AA'

   While @Ind<=5 
     begin
       Set   @TName = dbo.Isd_StringInListStr(@TblList,@Ind,',')
       Set   @SqlFilter01     = Replace(@SQLFilter00,' KLIENT ',' '+@TName+' ')
       if    @TName='SHERBIM'
             Set @SqlFilter01 = Replace(@SQLFilter01,' A.LLOGARI',' A.LLOGSH')
	   Exec (@SqlFilter01)
       Set   @Ind = @Ind + 1
       Print @TName
     end
Print 'BB'


--  FA - Objekte Instalimi

       Set @TblList = 'A.SKEMELMW,A.SKEMELMA'   
       Set @Ind     = 1

   While @Ind<=2 
     begin
       Set   @TName = dbo.Isd_StringInListStr(@TblList,@Ind,',')
       Set   @SqlFilter01 = Replace(@SQLFilter00,' KLIENT ',' OBJEKTINST ')
       Set   @SqlFilter01 = Replace(@SQLFilter01,' A.LLOGARI',' '+@TName+' ')
	   Exec (@SqlFilter01)
       Set   @Ind = @Ind + 1
       Print @TName
     end


-- SkemeLM

       Set @TblList = 'A.LLOGINV,A.NDRGJEND,A.LLOGB,A.LLOGSH,A.LLOGSHPZ01'   
       Set @Ind     = 1

   While @Ind<=5 
     begin
       Set   @TName = dbo.Isd_StringInListStr(@TblList,@Ind,',')
       Set   @SqlFilter01 = Replace(@SQLFilter00,' KLIENT ',' SKEMELM ')
       Set   @SqlFilter01 = Replace(@SQLFilter01,' A.LLOGARI',' '+@TName+' ')
	   Exec (@SqlFilter01)
       Set   @Ind = @Ind + 1
       Print @TName
     end


-- LM
       Set @SqlFilter01 = '
            UPDATE A 
               SET SG1=C.KODNEW,
                   KOD=C.KODNEW+''.''+ISNULL(SG2,'''')+''.''+ISNULL(SG3,'''')+''.''+ISNULL(SG4,'''')+''.''+ISNULL(SG5,'''')
              FROM LM  A INNER JOIN '+@TableNameTmp+' C ON A.SG1 = C.KOD '
       Exec (@SqlFilter01)




-- CINFIGLM

       Set @TblList = '
           LLOGCEL, LLOGTATB, LLOGTATS, LLOGZBR, LLOGARK, LLOGBANK, LLOGDOG, LLAUTARK, KAUTBAN, LLAUTBAN, 
           LLGKLIENT, LLGFURNITOR, LLGVEPRIMAQ, LLOGINV, NDGJEND, LLOGB, LLOGSH, LLOGXHMG, LLOGXHIRUES, LLOGHUMBJE, 
           LLOGFITIM, LLOGDOKSH, LLOGTRANSP, LLOGDHURA, LLOGDHURB, LLOGDHURC, LLOGDHURD, FALLOGGARANCIKL, FALLOGGARANCIART, FAKALIMLMMG, 
           LLOGMRRJET, LLOGTAX, LLOGTVSHMA, LLOGTVSHPG '

       Set @SqlFilter00 = '

			UPDATE A
			   SET A.LLOGCEL = (SELECT KODNEW FROM '+@TableNameTmp+' C WHERE A.LLOGCEL=C.KOD)
			  FROM CONFIGLM A
             WHERE ISNULL(A.LLOGCEL,'''')<>'''' AND 
                   (Exists (SELECT KOD FROM '+@TableNameTmp+' C WHERE A.LLOGCEL=C.KOD))'

       Set @MaxInd  = Len(@TblList) - Len(Replace(@TblList,',','')) + 1
       Set @Ind     = 1


  while @Ind<=@MaxInd
     begin
       Set @TName = LTrim(RTrim(dbo.Isd_StringInListStr(@TblList,@Ind,',')))
       if  @TName<>''  
           begin
             Set   @SqlFilter01 = Replace(@SQLFilter00,'LLOGCEL',@TName)
             Exec (@SqlFilter01)
           end
       Set @Ind = @Ind + 1
    end 



GO
