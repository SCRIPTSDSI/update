SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- Te provohet ?????????????????????????

-- Exec [Dbo].[Isd_KodChangeDep] 'A001','A003',1,'','',1

CREATE Procedure [dbo].[Isd_KodChangeDep]
(@PKod          Varchar(50),
 @PKodNew       Varchar(50),
 @PChangeName   Int,

 @PWhere        Varchar(Max),
 @PListTables   Varchar(Max),
 @PCaseUpdate   Int
)
As

-- CaseUpdate 1:   Nje Departament te vetme nga ekrani Departament
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

 
         Set @TableNameTmp = '#KODDEP'
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
      
          if Object_Id('TempDB..'+@TableNameTmp) is not null
		     DROP TABLE #KODDEP


      SELECT KOD,KODNEW,PERSHKRIM,CHANGENAME=0,TROW,TAGNR
        INTO #KODDEP
        FROM KODCHANGE 
       WHERE 1=2
   


   if @PCaseUpdate<>1

      begin

          INSERT INTO #KODDEP
                (KOD,KODNEW,CHANGENAME,TROW,TAGNR)
          SELECT KOD,KODNEW,1,         TROW,TAGNR
            FROM KODCHANGE A
           WHERE TIPKLL='DEP' AND 
                (ISNULL(KOD,'')<>'' AND ISNULL(KODNEW,'')<>'') AND
                (KOD<>KODNEW) --AND (NOT (EXISTS (SELECT KOD FROM DEPARTAMENT B WHERE B.KOD=A.KODNEW)))
        ORDER BY KOD

      end

   else

      begin   -- Rasti nje Kod
          Insert Into #KODDEP 
                 (KOD,KODNEW,CHANGENAME,TAGNR)
          Values (@PKod,@PKodNew,@PChangeName,1)
      end


        if IsNull((SELECT TOP 1 1 FROM #KODDEP),0)=0
           Return 


    UPDATE A
       SET A.PERSHKRIM = B.PERSHKRIM
      FROM #KODDEP A INNER JOIN DEPARTAMENT B ON A.KODNEW=B.KOD


-- Grupi Faturime

       Set @SqlFilter00 = '
			UPDATE B
			   SET B.KODAF      = Dbo.Isd_SegmentNewInsert(B.KODAF,C.KODNEW,2),
				   B.KOD        = CASE WHEN TIPKLL=''K'' 
                                            THEN IsNull(A.KMAG,'''')             +''.''+
                                                 Dbo.Isd_SegmentFind(B.KODAF,0,2)+''.''+
                                                 C.KODNEW                        +''.''+
                                                 Dbo.Isd_SegmentFind(B.KODAF,0,4)+''.''+
                                                 IsNull(A.KMON,'''')
                                       WHEN TIPKLL=''L''
                                            THEN Dbo.Isd_SegmentFind(B.KODAF,0,1)+''.''+
                                                 C.KODNEW                        +''.''+
                                                 Dbo.Isd_SegmentFind(B.KODAF,0,3)+''.''+
                                                 Dbo.Isd_SegmentFind(B.KODAF,0,4)+''.''+
                                                 IsNull(A.KMON,'''')
                                       ELSE B.KOD 
                                  END
                 --B.PERSHKRIM  = CASE WHEN C.CHANGENAME=1 THEN D.PERSHKRIM ELSE B.PERSHKRIM END
			  FROM FJ A INNER JOIN FJSCR             B ON A.NRRENDOR = B.NRD
						INNER JOIN '+@TableNameTmp+' C ON Dbo.Isd_SegmentFind(B.KODAF,0,2) = C.KOD
                        INNER JOIN DEPARTAMENT       D ON C.KODNEW=D.KOD
             WHERE 1=1 AND (TIPKLL=''L'' OR TIPKLL=''K'') '


       Set @TblList = 'FJ,FF,ORF,ORK,OFK,FJT,SM,FH,FD'
       Set @Ind     = 1

  while @Ind<=7
     begin
       Set @TName = dbo.Isd_StringInListStr(@TblList,@Ind,',')
       if  @Dokument=1 or CharIndex(','+@TName+',',@ListTables)>0  
           begin
             Set  @SqlFilter01 = Replace(@SQLFilter00,' FJ',' '+@TName)
             if   @Where<>''
                  Set @SqlFilter01 = Replace(@SqlFilter01,'1=1',@Where)
             Exec (@SqlFilter01)
           end
       Set @Ind = @Ind + 1
 RaisError (@TName, 0, 1) with NoWait
    end 




-- Magazina FH,FD

       Set @SqlFilter00 = '
			UPDATE B
			   SET B.KODAF      = Dbo.Isd_SegmentNewInsert(B.KODAF,C.KODNEW,2),
				   B.KOD        = IsNull(A.KMAG,'''')             +''.''+
                                  Dbo.Isd_SegmentFind(B.KODAF,0,1)+''.''+
                                  C.KODNEW                        +''.''+
                                  Dbo.Isd_SegmentFind(B.KODAF,0,4)+''.''+''''
                -- B.PERSHKRIM  = CASE WHEN C.CHANGENAME=1 THEN D.PERSHKRIM ELSE B.PERSHKRIM END
			  FROM FH A INNER JOIN FHSCR             B ON A.NRRENDOR = B.NRD
						INNER JOIN '+@TableNameTmp+' C ON Dbo.Isd_SegmentFind(B.KODAF,0,2) = C.KOD
                        INNER JOIN DEPARTAMENT       D ON C.KODNEW=D.KOD
             WHERE 1=1 ';
       Set @TblList = 'FH,FD'
       Set @Ind     = 1

   While @Ind <= 2 
     begin
       Set @TName = dbo.Isd_StringInListStr(@TblList,@Ind,',')
       if  @Dokument=1 or CharIndex(','+@TName+',',@ListTables)>0  
           begin
		     Set   @SqlFilter01 = Replace(@SQLFilter00,' FH',' '+@TName)
             if    @Where<>''
                   Set @SqlFilter01 = Replace(@SqlFilter01,'1=1',@Where)
		     Exec (@SqlFilter01)
           end
       Set @Ind = @Ind + 1
 RaisError (@TName, 0, 1) with NoWait
      end;


	   Set @SqlFilter00 = '
			UPDATE A
			   SET A.KODLM = Dbo.Isd_SegmentNewInsert(A.KODLM,C.KODNEW,2)
			  FROM FH A INNER JOIN '+@TableNameTmp+' C ON Dbo.Isd_SegmentFind(A.KODLM,0,2)  = C.KOD
						INNER JOIN DEPARTAMENT D ON C.KODNEW=D.KOD
			 WHERE 1=1 '
       Set @TblList = 'FH,FD'
       Set @Ind     = 1

   While @Ind <= 2 
     begin
       Set @TName = dbo.Isd_StringInListStr(@TblList,@Ind,',')
       if  @Dokument=1 or CharIndex(','+@TName+',',@ListTables)>0  
           begin
		     Set   @SqlFilter01 = Replace(@SQLFilter00,' FH',' '+@TName)
             if    @Where<>''
                   Set @SqlFilter01 = Replace(@SqlFilter01,'1=1',@Where)
		     Exec (@SqlFilter01)
           end
       Set @Ind = @Ind + 1
 RaisError (@TName, 0, 1) with NoWait
      end;





-- Grupi i LM  -  ARKA,BANKA,VS,VSST

       Set @SqlFilter00 = '
			UPDATE B
			   SET B.KODAF      = Dbo.Isd_SegmentNewInsert(B.KODAF,C.KODNEW,2),
				   B.KOD        = Dbo.Isd_SegmentFind(B.KODAF,0,1)+''.''+
                                  C.KODNEW                        +''.''+
                                  Dbo.Isd_SegmentFind(B.KODAF,0,3)+''.''+
                                  Dbo.Isd_SegmentFind(B.KODAF,0,4)+''.''+
                                  IsNull(B.KMON,'''')
                 --B.PERSHKRIM  = CASE WHEN C.CHANGENAME=1 THEN D.PERSHKRIM ELSE B.PERSHKRIM END
			  FROM ARKA A INNER JOIN ARKASCR           B ON A.NRRENDOR = B.NRD
					 	  INNER JOIN '+@TableNameTmp+' C ON Dbo.Isd_SegmentFind(B.KODAF,0,2) = C.KOD
                          INNER JOIN DEPARTAMENT       D ON C.KODNEW=D.KOD
             WHERE 1=1 AND TIPKLL=''T'''

       Set @TblList = 'ARKA,BANKA,VS,VSST'
       Set @Ind     = 1

   while @Ind<=4
      begin
        Set @TName = dbo.Isd_StringInListStr(@TblList,@Ind,',')
        if  @Dokument=1 or CharIndex(','+@TName+',',@ListTables)>0  
            begin
            --Print  @TName
              Set    @SqlFilter01 = Replace(@SQLFilter00,' ARKA',' '+@TName)

              if @Where<>''
                 Set @SqlFilter01 = Replace(@SqlFilter01,'1=1',@Where)
              Exec  (@SqlFilter01)
            end
       Set @Ind = @Ind + 1
 RaisError (@TName, 0, 1) with NoWait
      end 



-- FK

       Set @SqlFilter00 = '
			UPDATE B
			   SET --B.LLOGARI    = Dbo.Isd_SegmentNewInsert(B.LLOGARI,C.KODNEW,2),
				   B.KOD        = Dbo.Isd_SegmentFind(B.KOD,0,1)+''.''+
                                  C.KODNEW                          +''.''+
                                  Dbo.Isd_SegmentFind(B.KOD,0,3)+''.''+
                                  Dbo.Isd_SegmentFind(B.KOD,0,4)+''.''+
                                  IsNull(B.KMON,'''')
                -- B.PERSHKRIM  = CASE WHEN C.CHANGENAME=1 THEN D.PERSHKRIM ELSE B.PERSHKRIM END
			  FROM FK A   INNER JOIN FKSCR   B ON A.NRRENDOR = B.NRD
					 	  INNER JOIN '+@TableNameTmp+' C ON Dbo.Isd_SegmentFind(B.KOD,0,2) = C.KOD
                          INNER JOIN DEPARTAMENT D ON C.KODNEW=D.KOD
             WHERE 1=1 '
       Set @TblList = 'FK,FKST'
       Set @Ind     = 1

   While @Ind<=2 
     begin
       Set @TName = dbo.Isd_StringInListStr(@TblList,@Ind,',')
       if  @Dokument=1 or CharIndex(','+@TName+',',@ListTables)>0  
           begin
	         Set   @SqlFilter01 = Replace(@SQLFilter00,' FK',' '+@TName)
             if    @Where<>''
                   Set @SqlFilter01 = Replace(@SqlFilter01,'1=1',@Where)
		     Exec (@SqlFilter01)
           end
       Set @Ind = @Ind + 1
 RaisError (@TName, 0, 1) with NoWait
     end;


-- R E F E R E N C A

       Set @SqlFilter00 = '
			UPDATE A
			   SET A.DEP = C.KODNEW
			  FROM KLIENT A INNER JOIN '+@TableNameTmp+' C ON A.DEP = C.KOD
             WHERE 1=1 '

       Set @TblList = 'KLIENT,FURNITOR,ARKAT,BANKAT,SHERBIM,ARTIKUJ,MAGAZINA'
       Set @MaxInd  = Len(@TblList) - Len(Replace(@TblList,',','')) + 1
       Set @Ind     = 1

   While @Ind<=@MaxInd 
     begin
       Set   @TName = dbo.Isd_StringInListStr(@TblList,@Ind,',')
       Set   @SqlFilter01     = Replace(@SQLFilter00,' KLIENT ',' '+@TName+' ')
     --if    @TName='MAGAZINA' Or @TName='ARTIKUJ'
     --      Set @SqlFilter01 = Replace(@SQLFilter01,' A.LISTE',' A.LIST')
	   Exec (@SqlFilter01)
        Set  @Ind = @Ind + 1
  RaisError (@TName, 0, 1) with NoWait
     end;


-- LM
       Set @SqlFilter01 = '
            UPDATE A 
               SET SG2 = C.KODNEW,
                   KOD = ISNULL(SG1,'''')+''.''+C.KODNEW+''.''+ISNULL(SG3,'''')+''.''+ISNULL(SG4,'''')+''.''+ISNULL(SG5,'''')
              FROM LM  A INNER JOIN '+@TableNameTmp+' C ON A.SG2 = C.KOD '
       Exec (@SqlFilter01);
  RaisError ('LM', 0, 1) with NoWait


-- LMG
       Set @SqlFilter01 = '
            UPDATE A 
               SET SG3 = C.KODNEW,
                   KOD = ISNULL(SG1,'''')+''.''+ISNULL(SG2,'''')+''.''+C.KODNEW+''.''+ISNULL(SG4,'''')+''.''+ISNULL(SG5,'''')
              FROM LMG  A INNER JOIN '+@TableNameTmp+' C ON A.SG3 = C.KOD '
       Exec (@SqlFilter01);
  RaisError ('LMG', 0, 1) with NoWait





GO
