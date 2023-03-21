SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Exec [Isd_GjenerimDitar] @PDateKp='01/03/2010', @PDateKs='31/03/2010', @PTip='A', @PForce='1';

CREATE         Procedure [dbo].[Isd_GjenerimDitar]
 (
  @PDateKp    Varchar(20),
  @PDateKs    Varchar(20),
  @PTip       Varchar(10),
  @PForce     Varchar(1)
  )
As

         Set NoCount On
 
     Declare @Tip            Varchar(10),
             @Force          Varchar(1),

             @Ditar          Varchar(30),
             @TableName      Varchar(30),
             @StProcName     Varchar(30), 
             @Treg1DK        Varchar(5),
             @Treg2DK        Varchar(5),
             @Field          Varchar(1000),
             @FieldMV        Varchar(1000),
             @SqlFilter      Varchar(5000),
             @SqlFilterUn1   Varchar(5000),
             @SqlFilterUn2   Varchar(5000),
             @Where          Varchar(150),
             @NdarjePromoc   Bit,
             @i              Int,
             @TranNumber     Varchar(30);

         Set @Tip          = @PTip;
         Set @Force        = @PForce;
         Set @SqlFilter    = ' (DATEDOK>=DBO.DATEVALUE('''+@PDateKp+''') AND DATEDOK<=DBO.DATEVALUE('''+@PDateKs+'''))';

         Set @i = Charindex(@PTip,'ABSF');
          if @i<=0
             Return;

         Set @TranNumber   = dbo.Isd_RandomNumberChars(1);

         Set @Ditar        = dbo.Isd_StringInListStr('DAR,DBA,DKL,DFU' ,@i,',');
         Set @TableName    = dbo.Isd_StringInListStr('ARKA,BANKA,FJ,FF',@i,',');
         Set @StProcName   = dbo.Isd_StringInListStr('T_DOKDIT_AR,T_DOKDIT_BA,T_DOKDIT_KL,T_DOKDIT_FU',@i,',');




-- 1     Fillim - GJENERIM ME FORCE	           *****     Fshirje Ditar

          if @Force='1'

             begin

               Set @Where = @SqlFilter;
                if @Where<>''
                   Set @Where = ' And ' + @Where;

               Set @SqlFilterUn1 = '

                DELETE 
                  FROM ' + @Ditar + '
                 WHERE 1=1 ' + @Where + ';

                UPDATE ' + @TableName + '
                   SET NRDITAR=0 
                 WHERE NRDITAR<>0 ' + @Where + ';';


                if @Tip='S'
                   Set @SqlFilterUn1 = @SqlFilterUn1 + '

                UPDATE ' + @TableName + ' 
                   SET NRDITARSHL=0, NRDITARPRMC=0 
                 WHERE (ISNULL(NRDITARPRMC,0)<>0 OR ISNULL(NRDITARSHL,0)<>0) '+@Where + ';

                UPDATE B 
                   SET B.NRDITAR=0 
                  FROM ' + @TableName + ' A INNER JOIN ' + @TableName + 'SCR B ON A.NRRENDOR=B.NRD 
                 WHERE ISNULL(B.NRDITAR,0)<>0 ' + @Where+';';


                if @Tip='F'
                   Set @SqlFilterUn1 = @SqlFilterUn1 + '

                UPDATE ' + @TableName + ' 
                   SET NRDITARSHL=0 
                 WHERE ISNULL(NRDITARSHL,0)<>0 ' + @Where + ';

                UPDATE B 
                   SET B.NRDITAR=0 
                  FROM ' + @TableName + ' A INNER JOIN ' + @TableName + 'SCR B ON A.NRRENDOR=B.NRD 
                 WHERE ISNULL(B.NRDITAR,0)<>0 ' + @Where+';';



               Set @SqlFilterUn1 = @SqlFilterUn1 + ' 

                UPDATE B 
                   SET B.NRDITAR=0 
                  FROM VS    A INNER JOIN VSSCR    B ON A.NRRENDOR=B.NRD 
                 WHERE B.TIPKLL='''+@Tip+''' AND ISNULL(B.NRDITAR,0)<>0 '+@Where+';

                UPDATE B 
                   SET B.NRDITAR=0 
                  FROM ARKA  A INNER JOIN ARKASCR  B ON A.NRRENDOR=B.NRD 
                 WHERE B.TIPKLL='''+@Tip+''' AND ISNULL(B.NRDITAR,0)<>0 '+@Where+';

                UPDATE B 
                   SET B.NRDITAR=0 
                  FROM BANKA A INNER JOIN BANKASCR B ON A.NRRENDOR=B.NRD 
                 WHERE B.TIPKLL='''+@Tip+''' AND ISNULL(B.NRDITAR,0)<>0 '+@Where;

               Exec (@SqlFilterUn1);

             end;

-- 1     Fund  -  GJENERIM ME FORCE	           *****     Fshirje Ditar




-- 2     Fillim - Fshihen Rrjeshta Ditar per ato qe nuk lidhen me Dokumenta....

         Set  @SqlFilterUn1 = '
 
                DELETE 
                  FROM '+@Ditar+' 
                 WHERE (DATEDOK IS NULL); 

                DELETE 
                  FROM '+@Ditar+'  
                 WHERE '+@SQLFilter+' AND TIPDOK<>''SP'' AND 
                      (( SELECT COUNT(*) 
                           FROM ' + @StProcName + ' B 
                          WHERE B.NRDITAR='+@Ditar+'.NRRENDOR))<>1;

                UPDATE A 
                   SET NRDITAR=0 
                  FROM ' + @TableName + ' A 
                 WHERE ' + @SQLFilter + ' AND ((NRDITAR Is Null) OR (NRDITAR>0)) AND 
                      (Not ( Exists (SELECT NRRENDOR 
                                       FROM '+@Ditar+' B 
                                      WHERE B.NRRENDOR = A.NRDITAR))) ;';

         Exec (@SqlFilterUn1);


           if @Tip = 'S'

              begin
                Set   @SqlFilterUn1 = '

                UPDATE ' + @TableName +' 
                   SET VLERZBR=ISNULL(VLERZBR,0), PERQZBR=ISNULL(PERQZBR,0)
                 WHERE (VLERZBR Is Null) OR (PERQZBR Is Null);
               
                UPDATE A						-- Pagese nga Fatura per Autpasion
                   SET NRDITARSHL=0 
                  FROM ' + @TableName + ' A
                 WHERE ISNULL(NRDITARSHL,0)<>0 AND '+@SQLFilter  + ' AND 
                      (Not( Exists (SELECT NRRENDOR 
                                      FROM '+@Ditar+' B 
                                     WHERE B.NRRENDOR = A.NRDITARSHL)));

                UPDATE A                        -- Ditar nga Fatura per Promocion
                   SET  NRDITARPRMC = 0 
                  FROM ' + @TableName + ' A 
                 WHERE ISNULL(NRDITARPRMC,0)<>0 AND '+@SQLFilter + ' AND 
                      (Not( Exists (SELECT NRRENDOR 
                                      FROM '+@Ditar+' B 
                                     WHERE B.NRRENDOR = A.NRDITARPRMC)));

                UPDATE B                        -- Ditar nga Fatura-Rrjeshta per klientin-furnitor per rrjeshtat ku TIPKLL=''S'' Or TIPKLL=''F''
                   SET B.NRDITAR = 0  
                  FROM ' + @TableName + ' A LEFT JOIN ' + @TableName + 'SCR B ON A.NRRENDOR = B.NRD 
                 WHERE ' + @SQLFilter + ' AND (TIPKLL='''+@Tip+''') AND ISNULL(B.NRDITAR,0)<>0 AND 
                      (Not( Exists (SELECT NRRENDOR  
                                      FROM '+@Ditar+' C 
                                     WHERE C.NRRENDOR = B.NRDITAR)));';

                Exec (@SqlFilterUn1);
              end;


           if @Tip = 'F'

              begin

                Set  @SqlFilterUn1 = '

                DELETE 
                  FROM DKL  
                 WHERE '+@SQLFilter+' AND TIPDOK=''FF'' AND 
                      (NOT EXISTS ( SELECT * 
                                      FROM FFSCR B 
                                     WHERE B.NRDITAR=DKL.NRRENDOR));

                UPDATE A  
                   SET NRDITARSHL=0 
                  FROM ' + @TableName + ' A
                 WHERE ISNULL(NRDITARSHL,0)<>0 AND ' + @SQLFilter + ' AND 
                      (Not( Exists (SELECT NRRENDOR 
                                      FROM '+@Ditar+' B 
                                     WHERE B.NRRENDOR = A.NRDITARSHL)));

                UPDATE B                        -- Ditar nga Fatura-Rrjeshta per klientin-furnitor per rrjeshtat ku TIPKLL=''S'' Or TIPKLL=''F''
                   SET B.NRDITAR = 0  
                  FROM ' + @TableName + ' A LEFT JOIN ' + @TableName + 'SCR B ON A.NRRENDOR = B.NRD 
                 WHERE ' + @SQLFilter + ' AND (TIPKLL=''S'') AND ISNULL(B.NRDITAR,0)<>0 AND 
                      (Not( Exists (SELECT NRRENDOR  
                                      FROM DKL C 
                                     WHERE C.NRRENDOR = B.NRDITAR)));';
         
                Exec (@SqlFilterUn1); 

             end;


         Set   @SqlFilterUn1 = '
 
                UPDATE A
                   SET NRDITAR = 0 
                  FROM ARKASCR A INNER JOIN ARKA B ON A.NRD=B.NRRENDOR
                 WHERE A.TIPKLL='''+@Tip+''' AND ISNULL(A.NRDITAR,0)<>0 AND '+@SQLFilter+' AND
                      (Not (Exists (SELECT NRRENDOR 
                                      FROM '+@Ditar+' C 
                                     WHERE C.NRRENDOR = A.NRDITAR)));
                UPDATE A
                   SET NRDITAR = 0 
                  FROM BANKASCR A INNER JOIN BANKA B ON A.NRD=B.NRRENDOR
                 WHERE A.TIPKLL='''+@Tip+''' AND ISNULL(A.NRDITAR,0)<>0 AND '+@SQLFilter+' AND
                      (Not (Exists (SELECT NRRENDOR 
                                      FROM '+@Ditar+' C 
                                     WHERE C.NRRENDOR = A.NRDITAR)));
                UPDATE A
                   SET NRDITAR = 0 
                  FROM VSSCR A INNER JOIN VS B ON A.NRD=B.NRRENDOR
                 WHERE A.TIPKLL='''+@Tip+''' AND ISNULL(A.NRDITAR,0)<>0 AND '+@SQLFilter+' AND
                      (Not (Exists (SELECT NRRENDOR 
                                      FROM '+@Ditar+' C 
                                     WHERE C.NRRENDOR = A.NRDITAR)));';
         Exec (@SqlFilterUn1); 

-- 2     Fund  -  Fshihen Rrjeshta Ditar per ato qe nuk lidhen me Dokumenta....




-- 3     Fillim - GJENERIMI DITAR						Shtimi ne Ditar


         -- 3.1   Fillim - Shtim ne Ditar nga Dokumenta - Kokat

           if @Tip ='A' or @Tip = 'B'

              begin

                Set   @SqlFilterUn1 = ' 

                INSERT INTO ' + @Ditar + '
                      (KOD,PERSHKRIM,KOMENT,TIPDOK,TREGDK,  
                       NRDITAR,NRDOK,FRAKSDOK,DATEDOK,NRFAT,DTFAT,TIPFAT, 
                       KMON,VLEFTA,VLEFTAMV,KURS1,KURS2, 
                       KODMASTER,ISDOKSHOQ,TAGNR,TIPKLL,NRRENDORDOK,ORG,LLOJDOK,TRANNUMBER )
                SELECT LTRIM(RTRIM(KODAB))+''.''+LTRIM(RTRIM(ISNULL(KMON,''''))),SHENIM1,SHENIM2,TIPDOK, 
                       Case When TIPDOK IN (''MA'',''XK'',''AB'',''DB'') 
                            Then ''D''
                            Else ''K'' End, 
                       NRRENDOR,NUMDOK,FRAKSDOK,DATEDOK,NUMDOK,DATEDOK,TIPDOK, 
                       LTRIM(RTRIM(ISNULL(KMON,''''))),VLERA,VLERAMV,KURS1,KURS2, 
                       KODAB,0,NRRENDOR,'''',NRRENDOR,'''+@Tip+''','''','''+@TranNumber+'''
                  FROM ' + @TableName + ' A
                 WHERE A.NRDITAR=0 OR (Not (Exists (SELECT NRRENDOR 
                                                      FROM '+@Ditar+' B 
                                                     WHERE B.NRRENDOR = A.NRDITAR)));   

                UPDATE A 
                   SET A.NRDITAR = B.NRRENDOR 
                  FROM ' + @TableName + ' A INNER JOIN ' + @Ditar +' B ON A.NRRENDOR = B.TAGNR  
                 WHERE B.TRANNUMBER='''+@TranNumber+''';

                UPDATE '+@Ditar+'
                   SET TAGNR=0, TRANNUMBER='''' 
                 WHERE TRANNUMBER='''+@TranNumber+''';';
         
                Exec (@SqlFilterUn1); 
              end;


           if @Tip='F' 
              begin
                Set  @Treg1DK      = '''K''';
                Set  @Treg2DK      = '''D''';
                Set  @SqlFilterUn1 = '
 
                INSERT INTO '+@Ditar+'
                      (KOD,PERSHKRIM,KOMENT,TIPDOK,TREGDK,
                       NRDITAR,NRDOK,FRAKSDOK,DATEDOK,NRFAT,DTFAT,TIPFAT,
                       KMON,VLEFTA,VLEFTAMV,KURS1,KURS2,
                       KODMASTER,TAGNR,TIPKLL,NRRENDORDOK,ORG,LLOJDOK,TRANNUMBER )
                SELECT LTRIM(RTRIM(KODFKL))+''.''+LTRIM(RTRIM(ISNULL(KMON,''''))),SHENIM1,SHENIM3,'''+@TableName+''','+@Treg1DK+',
                       NRRENDOR,NRDOK,0,DATEDOK,ISNULL(NRDSHOQ,''''),DTDSHOQ,'''+@TableName+''',
                       LTRIM(RTRIM(ISNULL(KMON,''''))),
                       VLERTOT,
                       ROUND(VLERTOT*A.KURS2/A.KURS1,3),
                       A.KURS1,
                       A.KURS2,
                       KODFKL,NRRENDOR,'''',NRRENDOR,'''+@Tip+''',LLOJDOK,'''+@TranNumber+''' 
                  FROM ' + @TableName + ' A
                 WHERE (A.NRDITAR=0 OR (Not (Exists (SELECT NRRENDOR 
                                                       FROM '+@Ditar+' B 
                                                      WHERE B.NRRENDOR = A.NRDITAR)))); 

                UPDATE A 
                   SET A.NRDITAR = B.NRRENDOR 
                  FROM ' + @TableName + ' A INNER JOIN ' + @Ditar +' B ON A.NRRENDOR = B.TAGNR  
                 WHERE B.TRANNUMBER='''+@TranNumber+'''; 

                UPDATE '+@Ditar+' 
                   SET TAGNR=0, TRANNUMBER='''' 
                 WHERE TRANNUMBER='''+@TranNumber+''';';

                Set  @SqlFilterUn1  = Replace(@SqlFilterUn1,'A.KURS1','Case When LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' Then 1 Else A.KURS1 End');
                Set  @SqlFilterUn1  = Replace(@SqlFilterUn1,'A.KURS2','Case When LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' Then 1 Else A.KURS2 End');
                Exec(@SqlFilterUn1);

--													Rasti Likujdim parapagese FF
                Set  @SqlFilterUn1 = Replace(@SqlFilterUn1,'VLERTOT','PARAPG');
                Set  @SqlFilterUn1 = Replace(@SqlFilterUn1,'WHERE (A.NRDITAR=0','WHERE (ISNULL(A.PARAPG,0)<>0 AND ISNULL(A.NRRENDORAR,0)=0) 
                        AND 
                       (A.NRDITAR=0');
                Set  @SqlFilterUn1 = Replace(@SqlFilterUn1,@Treg1DK,@Treg2DK);
                Set  @SqlFilterUn1 = Replace(@SqlFilterUn1,'SHENIM3','SHENIM3+''/Shlyerje''');
                Set  @SqlFilterUn1 = Replace(@SqlFilterUn1,'A.NRDITAR','A.NRDITARSHL');
                Exec(@SqlFilterUn1);
              end;

           if @Tip='S'

              begin
                SELECT @NdarjePromoc = ISNULL(NDARJEPROMOCFJ,0) FROM CONFIGMG;

                Set @Treg1DK = '''D''';
                Set @Treg2DK = '''K''';
                Set @Field   = ' SUM(Case When ISNULL(B.PROMOC,0)=0 
                                          Then ISNULL(B.VLPATVSH,0)
                                          Else 0 End - 
                                     ISNULL(B.VLERAFR,0)
                                     ) -
                                     
                                 MAX(ISNULL(A.VLERZBR,0)) + 
                                     
                                 CASE WHEN MAX(IsNull(A.VLERZBR,0))=0 
                                      THEN SUM(IsNull(B.VLTVSH,0)) 
                                      ELSE MAX(IsNull(A.VLTVSH,0))
                                 END ';
                Set @FieldMV = '(SUM(Case When ISNULL(B.PROMOC,0)=0 
                                          Then ISNULL(B.VLPATVSH,0)
                                          Else 0 End - 
                                     ISNULL(B.VLERAFR,0)) -
                                     
                                 MAX(ISNULL(A.VLERZBR,0)) + 
                                 
                                 CASE WHEN MAX(IsNull(A.VLERZBR,0))=0 
                                      THEN SUM(IsNull(B.VLTVSH,0)) 
                                      ELSE MAX(IsNull(A.VLTVSH,0))
                                 END)* MAX(A.KURS2)/MAX(A.KURS1) ';

                 if @NdarjePromoc=1						--  NdarjePromoc
                    begin
                      Set @Field   = Replace(@Field,  'ISNULL(B.PROMOC,0)=0','1=1');
                      Set @FieldMV = Replace(@FieldMV,'ISNULL(B.PROMOC,0)=0','1=1');
                    end;


                Set @SqlFilterUn1 = '
   
                INSERT INTO '+@Ditar+'
                      (KOD,PERSHKRIM,KOMENT,TIPDOK,TREGDK,
                       NRDITAR,NRDOK,FRAKSDOK,DATEDOK,NRFAT,DTFAT,TIPFAT,
                       KMON,VLEFTA,VLEFTAMV,KURS1,KURS2,
                       KODMASTER,ISDOKSHOQ,
                       TAGNR,TIPKLL,NRRENDORDOK,ORG,LLOJDOK,TRANNUMBER) 
                SELECT MAX(LTRIM(RTRIM(A.KODFKL))+''.''+LTRIM(RTRIM(ISNULL(A.KMON,'''')))),MAX(A.SHENIM1),MAX(A.SHENIM3),'''+@TableName+''','+@Treg1DK+',
                       A.NRRENDOR,MAX(A.NRDOK),0,MAX(A.DATEDOK),
                       Case When MAX(ISNULL(A.LLOJDOK,''''))=''H'' 
                            Then MAX(ISNULL(A.NRFATST,'''')) 
                            Else MAX(ISNULL(A.NRDSHOQ,A.DATEDOK)) End,
                       Case When MAX(ISNULL(A.LLOJDOK,''''))=''H'' 
                            Then MAX(ISNULL(A.DTFATST,0))
                            Else MAX(ISNULL(A.DTDSHOQ,A.DATEDOK)) End,
                       '''+@TableName+''',
                       MAX(LTRIM(RTRIM(ISNULL(A.KMON,'''')))),
                       ROUND(0,3), 
                       ROUND(1,3),
                       MAX(A.KURS1),
                       MAX(A.KURS2),
                       MAX(A.KODFKL),ISNULL(A.ISDOKSHOQ,0),
                       A.NRRENDOR,'''',A.NRRENDOR,'''+@Tip+''',MAX(ISNULL(A.LLOJDOK,'''')),'''+@TranNumber+''' 
                  FROM ' + @TableName + ' A LEFT JOIN ' + @TableName + 'Scr B ON A.NRRENDOR=B.NRD  
                 WHERE ((A.NRDITAR=0) OR (Not (Exists (SELECT NRRENDOR FROM '+@Ditar+' C WHERE C.NRRENDOR = A.NRDITAR)))) 

                       AND ISNULL(B.ISAMB,0)=0                                        -- 04.05.2015 -- Amballazh i kthyeshem

              GROUP BY A.NRRENDOR,ISNULL(A.ISDOKSHOQ,0) 
                HAVING ABS(ROUND(100,3))>=0.01;  -- Te diskutohet per rjeshta me vlera 0

                UPDATE A 
                   SET A.NRDITAR = B.NRRENDOR 
                  FROM ' + @TableName + ' A INNER JOIN ' + @Ditar +' B ON A.NRRENDOR = B.TAGNR  
                 WHERE B.TRANNUMBER='''+@TranNumber+'''; 

                UPDATE '+@Ditar+' 
                   SET TAGNR=0, TRANNUMBER='''' 
                 WHERE TRANNUMBER='''+@TranNumber+''';';

                Set   @SqlFilterUn2  = @SqlFilterUn1;
                Set   @SqlFilterUn2  = Replace(@SqlFilterUn2,'A.KURS1','Case When LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' Then 1 Else A.KURS1 End');
                Set   @SqlFilterUn2  = Replace(@SqlFilterUn2,'A.KURS2','Case When LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' Then 1 Else A.KURS2 End');
                Set   @SqlFilterUn2  = Replace(@SqlFilterUn2,'ROUND(0,3)','ROUND('+@Field  +',3)');
                Set   @SqlFilterUn2  = Replace(@SqlFilterUn2,'ROUND(1,3)','ROUND('+@FieldMV+',3)');
                Exec (@SqlFilterUn2);

                 if @NdarjePromoc=1						--  NdarjePromoc  Promocion rrjesht me vete
                    begin
                      Set  @Field         = ' SUM(ISNULL(B.VLPATVSH,0)+ISNULL(B.VLTVSH,0)) ';
                      Set  @FieldMV       = '(SUM(ISNULL(B.VLPATVSH,0)+ISNULL(B.VLTVSH,0))* MAX(A.KURS2)/MAX(A.KURS1)) ';

                      Set  @SqlFilterUn2  = Replace(@SqlFilterUn1, @Treg1DK, @Treg2DK);
                      Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'A.KURS1','Case When LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' Then 1 Else A.KURS1 End');
                      Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'A.KURS2','Case When LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' Then 1 Else A.KURS2 End');

                      Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'ROUND(0,3)','ROUND('+@Field  +',3)');
                      Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'ROUND(1,3)','ROUND('+@FieldMV+',3)');

                      Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,' ((A.NRDITAR=0) ', '  ISNULL(B.PROMOC,0)=1 AND ((A.NRDITARPRMC=0)');
                      Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'MAX(A.SHENIM3)',   '''Promocion FJ nr ''+MAX(ISNULL(A.NRDSHOQ,''''))+'', dt.''+MAX(CONVERT(CHAR(12),ISNULL(A.DTDSHOQ,A.DATEDOK))) ');
                      Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'SET A.NRDITAR',    'SET A.NRDITARPRMC');

                      Exec(@SqlFilterUn2);
                    end;

--													Rasti Likujdim parapagese FJ
                Set  @SqlFilterUn1 = '
 
                INSERT INTO '+@Ditar+'
                      (KOD,PERSHKRIM,KOMENT,TIPDOK,TREGDK,
                       NRDITAR,NRDOK,FRAKSDOK,DATEDOK,NRFAT,DTFAT,TIPFAT,
                       KMON,VLEFTA,VLEFTAMV,KURS1,KURS2,
                       KODMASTER,TAGNR,TIPKLL,NRRENDORDOK,ORG,LLOJDOK,TRANNUMBER )
                SELECT LTRIM(RTRIM(KODFKL))+''.''+LTRIM(RTRIM(ISNULL(KMON,''''))),SHENIM1,SHENIM3+''/Shlyerje'','''+@TableName+''',''K'',
                       NRRENDOR,NRDOK,0,DATEDOK,ISNULL(NRDSHOQ,''''),DTDSHOQ,'''+@TableName+''',
                       LTRIM(RTRIM(ISNULL(KMON,''''))),
                       PARAPG,
                       ROUND(PARAPG*A.KURS2/A.KURS1,3),
                       A.KURS1,
                       A.KURS2,
                       KODFKL,NRRENDOR,'''',NRRENDOR,'''+@Tip+''',LLOJDOK,'''+@TranNumber+''' 
                  FROM ' + @TableName + ' A
                 WHERE (ISNULL(A.PARAPG,0)<>0 AND ISNULL(A.NRRENDORAR,0)=0) 
                        AND 
                       ((A.NRDITARSHL=0)      OR (NOT (Exists (SELECT NRRENDOR 
                                                                 FROM '+@Ditar+' B 
                                                                WHERE B.NRRENDOR = A.NRDITARSHL)))); 

                UPDATE A 
                   SET A.NRDITARSHL = B.NRRENDOR 
                  FROM ' + @TableName + ' A INNER JOIN ' + @Ditar +' B ON A.NRRENDOR = B.TAGNR  
                 WHERE B.TRANNUMBER='''+@TranNumber+'''; 

                UPDATE '+@Ditar+' 
                   SET TAGNR=0, TRANNUMBER='''' 
                 WHERE TRANNUMBER='''+@TranNumber+''';';

                Set  @SqlFilterUn2  = @SqlFilterUn1;
                Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'A.KURS1','Case When LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' Then 1 Else A.KURS1 End');
                Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'A.KURS2','Case When LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' Then 1 Else A.KURS2 End');

                Exec(@SqlFilterUn2); 
              end;

-- 3.1   Fund  -  Shtim ne Ditar nga Dokumenta - Kokat




-- 3.2   Fillim - Shtim ne Ditar nga Dokumenta - Reshtat

      
         Set  @SqlFilterUn1 = '

                UPDATE A
                   SET NRDITAR = 0 
                  FROM ARKASCR A
                 WHERE TIPKLL='''+@Tip+''' AND A.NRDITAR<>0 AND 
                      (Not (Exists (SELECT NRRENDOR 
                                      FROM '+@Ditar+' B 
                                     WHERE B.NRRENDOR = A.NRDITAR))); 

                INSERT INTO '+@Ditar+'
                      (KOD,PERSHKRIM,KOMENT,TIPDOK,TREGDK,
                       NRDOK,FRAKSDOK,DATEDOK,NRFAT,DTFAT,TIPFAT,
                       KMON,VLEFTA,VLEFTAMV,KURS1,KURS2,
                       KODMASTER,KODREF,DET1,DET2,DET3,DET4,DET5,
					   ISDOKSHOQ,TAGNR,TIPKLL,NRRENDORDOK,ORG,LLOJDOK,TRANNUMBER )
             
                SELECT LTRIM(RTRIM(B.KOD)),B.PERSHKRIM,B.KOMENT,A.TIPDOK,TREGDK,
                       A.NUMDOK,A.FRAKSDOK,A.DATEDOK,B.NRDOKREF,B.DATEDOKREF,B.TIPREF,
                       LTRIM(RTRIM(ISNULL(B.KMON,''''))), 
                       Case When B.TREGDK=''D'' Then DB Else KR End,
                       Case When B.TREGDK=''D'' Then B.DBKRMV Else 0-B.DBKRMV End, 
                       B.KURS1,B.KURS2,
                       A.KODAB,
					   KODREF = dbo.Isd_SegmentFind(B.KOD,0,1),
					   DET1   = dbo.Isd_SegmentFind(B.KODDETAJ,0,1),
					   DET2   = dbo.Isd_SegmentFind(B.KODDETAJ,0,2),
					   DET3   = dbo.Isd_SegmentFind(B.KODDETAJ,0,3),
					   DET4   = '''', DET5 = '''',
					   ISDOKSHOQ = 0,B.NRRENDOR,B.TIPKLL,A.NRRENDOR,''_'','''','''+@TranNumber+'''
                  FROM ARKA A INNER JOIN ARKASCR B ON A.NRRENDOR=B.NRD 
                 WHERE (B.TIPKLL='''+@Tip+''') AND 
                       (B.NRDITAR=0 OR (Not (Exists (SELECT NRRENDOR 
                                                       FROM '+@Ditar+' C 
                                                      WHERE C.NRRENDOR = B.NRDITAR)))); 

                UPDATE A 
                   SET A.NRDITAR = B.NRRENDOR 
                  FROM ARKASCR A INNER JOIN ' + @Ditar +' B ON A.NRRENDOR = B.TAGNR  
                 WHERE B.TRANNUMBER='''+@TranNumber+'''; 

                UPDATE '+@Ditar+' 
                   SET TAGNR=0, TRANNUMBER='''' 
                 WHERE TRANNUMBER='''+@TranNumber+''';';

         Set   @SqlFilterUn2 = Replace(@SqlFilterUn1,'''_''','''A''');
         Exec (@SqlFilterUn2); 


         Set   @SqlFilterUn2 = Replace(@SqlFilterUn1,'''_''','''B''');
         Set   @SqlFilterUn2 = Replace(@SqlFilterUn2,' ARKA',' BANKA');
         Exec (@SqlFilterUn2); 

         Set   @SqlFilterUn2 = Replace(@SqlFilterUn1,'''_''','''E''');
         Set   @SqlFilterUn2 = Replace(@SqlFilterUn2,' ARKA',' VS');
         Set   @SqlFilterUn2 = Replace(@SqlFilterUn2,'A.SHENIM1,','B.PERSHKRIM,');
         Set   @SqlFilterUn2 = Replace(@SqlFilterUn2,'A.NUMDOK,A.FRAKSDOK','A.NRDOK,0');
         Set   @SqlFilterUn2 = Replace(@SqlFilterUn2,'A.KODAB,',''''',');
         Set   @SqlFilterUn2 = Replace(@SqlFilterUn2,'A.TIPDOK,','''SP'',');
         Exec (@SqlFilterUn2);


           if @Tip = 'S'
              begin
                Set @SqlFilterUn1 = '
 
                INSERT INTO ' + @Ditar + '                     
                      (KOD,PERSHKRIM,KOMENT,TIPDOK,TREGDK, 
                       NRDITAR,NRDOK,FRAKSDOK,DATEDOK,NRFAT,DTFAT,TIPFAT,
                       KMON,VLEFTA,VLEFTAMV,KURS1,KURS2,
                       KODMASTER,ISDOKSHOQ,TAGNR,TIPKLL,NRRENDORDOK,ORG,LLOJDOK,TRANNUMBER )
                SELECT LTRIM(RTRIM(B.KOD)),B.PERSHKRIM,B.KOMENT,''FJ'',''D'',
                       B.NRDITAR,A.NRDOK,0,A.DATEDOK,B.NRDOKREF,B.DATEDOKREF,B.TIPREF,
                       LTRIM(RTRIM(ISNULL(A.KMON,''''))),
                       0-B.VLERABS,
                       0-ROUND((B.VLERABS*A.KURS2)/A.KURS1,3),
                       A.KURS1,
                       A.KURS2,
                       KODFKL,0,B.NRRENDOR,B.TIPKLL,A.NRRENDOR,'''+@Tip+''',A.LLOJDOK,'''+@TranNumber+'''
                  FROM FJ A INNER JOIN FJSCR B ON A.NRRENDOR=B.NRD 
                 WHERE (B.TIPKLL='''+@Tip+''') AND 
                       (B.NRDITAR=0 OR (Not (Exists (SELECT NRRENDOR 
                                                       FROM '+@Ditar+' C 
                                                      WHERE C.NRRENDOR = B.NRDITAR)))); 

                UPDATE A 
                   SET A.NRDITAR = B.NRRENDOR 
                  FROM FJSCR A INNER JOIN ' + @Ditar +' B ON A.NRRENDOR = B.TAGNR  
                 WHERE B.TRANNUMBER='''+@TranNumber+'''; 

                UPDATE '+@Ditar+' 
                   SET TAGNR=0, TRANNUMBER='''' 
                 WHERE TRANNUMBER='''+@TranNumber+'''; ';

                Set  @SqlFilterUn2  = @SqlFilterUn1;
                Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'A.KURS1','Case When LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' Then 1 Else A.KURS1 End');
                Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'A.KURS2','Case When LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' Then 1 Else A.KURS2 End');
                Exec(@SqlFilterUn2); 
              end;


           if @Tip = 'F'
              begin

                Set @SqlFilterUn1 = '
 
                INSERT INTO ' + @Ditar + '                     
                      (KOD,PERSHKRIM,KOMENT,TIPDOK,TREGDK, 
                       NRDITAR,NRDOK,FRAKSDOK,DATEDOK,NRFAT,DTFAT,TIPFAT,
                       KMON,VLEFTA,VLEFTAMV,KURS1,KURS2,
                       KODMASTER,ISDOKSHOQ,TAGNR,TIPKLL,NRRENDORDOK,ORG,LLOJDOK,TRANNUMBER )
                SELECT LTRIM(RTRIM(B.KOD)),B.PERSHKRIM,B.KOMENT,''FF'',''K'',
                       B.NRDITAR,A.NRDOK,0,A.DATEDOK,B.NRDOKREF,B.DATEDOKREF,B.TIPREF,
                       LTRIM(RTRIM(ISNULL(A.KMON,''''))),
                       0-B.VLERABS,
                       0-ROUND((B.VLERABS*A.KURS2)/A.KURS1,3),
                       A.KURS1,
                       A.KURS2,
                       KODFKL,0,B.NRRENDOR,B.TIPKLL,A.NRRENDOR,'''+@Tip+''',A.LLOJDOK,'''+@TranNumber+'''
                  FROM FF A INNER JOIN FFSCR B ON A.NRRENDOR=B.NRD 
                 WHERE (B.TIPKLL='''+@Tip+''') AND 
                       (B.NRDITAR=0 OR (Not (Exists (SELECT NRRENDOR 
                                                       FROM '+@Ditar+' C 
                                                      WHERE C.NRRENDOR = B.NRDITAR)))); 

                UPDATE A 
                   SET A.NRDITAR = B.NRRENDOR 
                  FROM FFSCR A INNER JOIN ' + @Ditar +' B ON A.NRRENDOR = B.TAGNR  
                 WHERE B.TRANNUMBER='''+@TranNumber+'''; 

                UPDATE '+@Ditar+' 
                   SET TAGNR=0, TRANNUMBER='''' 
                 WHERE TRANNUMBER='''+@TranNumber+'''; ';

                Set  @SqlFilterUn2  = @SqlFilterUn1;
                Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'A.KURS1','Case When LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' Then 1 Else A.KURS1 End');
                Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'A.KURS2','Case When LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' Then 1 Else A.KURS2 End');
                Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,' DFU ',' DKL ');
                Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'TIPKLL=''F''','TIPKLL=''S''');

                Exec(@SqlFilterUn2); 

              end;

-- 3.2   Fund  -  Shtim ne Ditar nga Dokumenta - Reshtat




-- 4     Fillim - Shtim Kode Ditar ne Libra


         Set @SqlFilterUn1 = '  

                INSERT INTO LAR  
                      (KOD,PERSHKRIM,KMON,SG1,SG2,SG3,SG4,SG5,SG6,SG7,SG8,SG9,SG10,TROW,TAGNR)
                SELECT A.KOD,
                       PRS = ( SELECT MAX(PERSHKRIM)
                                 FROM ARKAT A1
                                WHERE A1.KOD=Case When Charindex (''.'',A.KOD)>0
                                                  Then LEFT(A.KOD,Charindex (''.'',A.KOD)-1)
                                                  Else A.KOD 
                                             End
                              ),
                       LTRIM(RTRIM(ISNULL(A.KMON,''''))),
                       SG1 = Case When Charindex (''.'',A.KOD)>0
                                  Then LEFT(A.KOD,Charindex (''.'',A.KOD)-1)
                                  Else A.KOD 
                             End,
                       '''','''','''',LTRIM(RTRIM(ISNULL(A.KMON,''''))),'''', '''', '''', '''','''',0,0
                  FROM DAR A 
                 WHERE Not Exists ( SELECT KOD 
                                      FROM LAR B 
                                     WHERE B.KOD=A.KOD)
              GROUP BY A.KMON,A.KOD
              ORDER BY A.KOD; ';

         Exec (@SqlFilterUn1);

         Set  @SqlFilterUn2 = Replace(@SqlFilterUn1,' DAR',' DBA');
         Set  @SqlFilterUn2 = Replace(@SqlFilterUn2,' LAR',' LBA');
         Set  @SqlFilterUn2 = Replace(@SqlFilterUn2,' ARKAT',' BANKAT');
         Exec(@SqlFilterUn2);

         Set  @SqlFilterUn2 = Replace(@SqlFilterUn1,' DAR',' DFU');
         Set  @SqlFilterUn2 = Replace(@SqlFilterUn2,' LAR',' LFU');
         Set  @SqlFilterUn2 = Replace(@SqlFilterUn2,' ARKAT',' FURNITOR');
         Exec(@SqlFilterUn2);

         Set  @SqlFilterUn2 = Replace(@SqlFilterUn1,' DAR',' DKL');
         Set  @SqlFilterUn2 = Replace(@SqlFilterUn2,' LAR',' LKL');
         Set  @SqlFilterUn2 = Replace(@SqlFilterUn2,' ARKAT',' KLIENT');
         Exec(@SqlFilterUn2);



----
---- Komentet me poshte jane per efekt shpejtesie tek Arka ose Banke, por tek Klient-Furnitor duhet nga Ditari
--
---- Arke + Banke (Monedhe e references)
--
--         Set @SqlFilterUn1 = '  
--
--                INSERT INTO LAR  
--                      (KOD,PERSHKRIM,KMON,SG1,SG2,SG3,SG4,SG5,SG6,SG7,SG8,SG9,SG10,TROW,TAGNR)
--                SELECT KOD   = LTRIM(RTRIM(ISNULL(A.KOD, '''')))+''.''+
--                               LTRIM(RTRIM(ISNULL(A.KMON,''''))), 
--                       PERSHKRIM = A.PERSHKRIM,
--                       KMON  = LTRIM(RTRIM(ISNULL(A.KMON,''''))),
--                       SG1   = LTRIM(RTRIM(ISNULL(A.KOD,''''))),
--                       SG2   = '''',
--                       SG3   = '''',
--                       SG4   = '''',
--                       SG5   = LTRIM(RTRIM(ISNULL(A.KMON,''''))),
--                       SG6   = '''',
--                       SG7   = '''', 
--                       SG8   = '''', 
--                       SG9   = '''', 
--                       SG10  = '''',
--                       TROW  = 0,
--                       TAGNR = 0
--                  FROM ARKAT A 
--                 WHERE Not Exists( SELECT KOD 
--                                     FROM LAR B 
--                                    WHERE LTRIM(RTRIM(ISNULL(B.KOD,'''')))+''.''+LTRIM(RTRIM(ISNULL(B.KMON,'''')))=
--                                          LTRIM(RTRIM(ISNULL(A.KOD,'''')))+''.''+LTRIM(RTRIM(ISNULL(A.KMON,'''')))
--                                   )
--              ORDER BY A.KOD; ';
--
--         Exec (@SqlFilterUn1);
--
--         Set   @SqlFilterUn2 = Replace(@SqlFilterUn1,' LAR',' LBA');
--         Set   @SqlFilterUn2 = Replace(@SqlFilterUn2,' ARKAT',' BANKAT');
--         Exec (@SqlFilterUn2);
--
--
--
---- Klient + Furnitor (Monedhe e dokumentit)
--
--         Set @SqlFilterUn1 = '  
--
--                INSERT INTO LFU  
--                      (KOD,PERSHKRIM,KMON,SG1,SG2,SG3,SG4,SG5,SG6,SG7,SG8,SG9,SG10,TROW,TAGNR)
--                SELECT A.KOD,
--                       PRS = ( SELECT TOP 1 PERSHKRIM
--                                 FROM FURNITOR A1
--                                WHERE A1.KOD = CASE WHEN CHARINDEX (''.'',A.KOD)>0
--                                                    THEN LEFT(A.KOD,CHARINDEX (''.'',A.KOD)-1)
--                                                    ELSE A.KOD 
--                                               END
--                              ),
--                       LTRIM(RTRIM(ISNULL(A.KMON,''''))),
--                       SG1 = CASE WHEN CHARINDEX (''.'',A.KOD)>0
--                                  THEN LEFT(A.KOD,CHARINDEX (''.'',A.KOD)-1)
--                                  ELSE A.KOD 
--                             END,
--                       '''','''','''',LTRIM(RTRIM(ISNULL(A.KMON,''''))),'''', '''', '''', '''','''',0,0
--                  FROM DFU A 
--                 WHERE NOT EXISTS ( SELECT KOD 
--                                      FROM LFU B 
--                                     WHERE B.KOD=A.KOD
--                                   )
--              GROUP BY A.KMON,A.KOD
--              ORDER BY A.KOD; ';
--
--         Exec (@SqlFilterUn2);
--
--         Set   @SqlFilterUn2 = Replace(@SqlFilterUn1,' DFU',' DKL');
--         Set   @SqlFilterUn2 = Replace(@SqlFilterUn1,' LFU',' LKL');
--         Set   @SqlFilterUn2 = Replace(@SqlFilterUn2,' FURNITOR',' KLIENT');
--         Exec (@SqlFilterUn2);
--
--


-- 4     Fund  -  Shtim Kode Ditar ne Libra
GO
