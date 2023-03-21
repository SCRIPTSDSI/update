SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









-- Exec [Isd_GjenerimDitarOne]  
----                @PDateKp    = '01/03/2010',
----                @PDateKs    = '31/03/2010',
----                @PTip       = 'A',
----                @PForce     = '1',
--                  @PTableName = 'ARKA',
--                  @PSgn       = 1,
--                  @PNrRendor  = 1


CREATE         Procedure [dbo].[Isd_GjenerimDitarOneKujdes]
(
--@PDateKp    Varchar(20),
--@PDateKs    Varchar(20),
--@PTip       Varchar(10),
--@PForce     Varchar(1),
  @PTableName Varchar(30),
  @PSgn       Int,
  @PNrRendor  Int
 )
As

     Set NoCount On

-- U zevendesua me Isd_GjenerimDitarOne procedure e re me 20.09.2014
 
 Declare 
         @String1      Varchar(5000),
         @String2      Varchar(5000), 
         @SqlFilterUn1 Varchar(5000),
         @SqlFilterUn2 Varchar(5000),
--       @SqlFilterDit Varchar(5000),
--       @VSql         Varchar(200),
         @Ditar        Varchar(30),
         @Liber        Varchar(30),
--       @Document     Varchar(30),
--       @ProcUnion    Varchar(30),
         @TmpLiber     Varchar(20),
         @Treg1DK      Varchar(5),
         @Treg2DK      Varchar(5),
         @Field        Varchar(5000),
         @FieldMV      Varchar(5000),
--       @LidhezAnd    Varchar(20),
         @PromocNdarje Bit,
         @PromocExists Bit,
         @ParaPg       Float,
         @SPNrRendor   Varchar(30),
         @Tip          Varchar(10)

--     Set @PDateKp       = QuoteName(@PDateKp,'''')
--     Set @PDateKs       = QuoteName(@PDateKs,'''')
--     Set @SqlFilter     = ' (DATEDOK>=DBO.DATEVALUE('+@PDateKp+') AND DATEDOK<=DBO.DATEVALUE('+@PDateKs+'))'
--     Set @SqlFilterDit  = Replace(@SqlFilter,'DATEDOK','A.DATEDOK')
     
     if  @PTableName='ARKA'
         Begin
           Set @Ditar     = 'DAR'
           Set @Liber     = 'LAR'
--         Set @Document  = 'ARKA'
           Set @Tip       = 'A'
--         Set @ProcUnion = 'T_DOKDIT_AR'
         End
     else
     if  @PTableName='BANKA'
         Begin
           Set @Ditar     = 'DBA'
           Set @Liber     = 'LBA'
--         Set @Document  = 'BANKA'
           Set @Tip       = 'B'
--         Set @ProcUnion = 'T_DOKDIT_BA'
         End
     else
     if  @PTableName='VS'
         Begin
--         Set @Ditar     = 'DBA'
--         Set @Liber     = 'LBA'
--         Set @Document  = 'VS'
           Set @Tip       = 'E'
--         Set @ProcUnion = 'T_DOKDIT_BA'
         End
     else
     if  @PTableName='FJ'
         Begin
           Set @Ditar     = 'DKL'
           Set @Liber     = 'LKL'
--         Set @Document  = 'FJ'
           Set @Tip       = 'S'
--         Set @ProcUnion = 'T_DOKDIT_KL'
         End
     else
     if  @PTableName='FF'
         Begin
           Set @Ditar     = 'DFU'
           Set @Liber     = 'LFU'
--         Set @Document  = 'FF'
           Set @Tip       = 'F'
--         Set @ProcUnion = 'T_DOKDIT_FU'
         End


      Set @SPNrRendor = Cast(@PNrRendor As VarChar)



--                      1                       --

--    F S H I R J A     E     D I T A R E V E

      if @PSgn=0 or @PSgn=-1

         Begin

--         Koka

           Set @SqlFilterUn1 = ''

           if @PTableName <> 'VS'

              Begin

                SELECT @String1='@NrDitar1=NRDITAR', @String2='NRDITAR=0'

                if @PTableName='FJ' or @PTableName='FF'
                   Begin
                     SELECT @String1=@String1+', @NrDitar2=NRDITARSHL',
                            @String2=@String2+', NRDITARSHL=0'
                   End
                if @PTableName='FJ' 
                   Begin
                     SELECT @String1=@String1+', @NrDitar3=NRDITARPRMC',
                            @String2=@String2+', NRDITARPRMC=0'
                   End

                Set  @SqlFilterUn1 = ' 
                     Declare @NrDitar1 Int,
                             @NrDitar2 Int,
                             @NrDitar3 Int

                     SELECT @NrDitar1=0, @NrDitar2=0, @NrDitar3=0
  
                     SELECT '+@String1+'
                       FROM '+@PTableName+' 
                      WHERE NRRENDOR = '+@SPNrRendor+'

                     DELETE 
                       FROM '+@Ditar+' 
                      WHERE NRRENDOR=@NrDitar1 or NRRENDOR=@NrDitar2 or NRRENDOR=@NrDitar3

                     UPDATE '+@PTableName+'
                        SET '+@String2+'
                      WHERE NRRENDOR='+@SPNrRendor+' '
              End

           if @SqlFilterUn1<>''
              Exec(@SqlFilterUn1)

--         Rrjeshtat

           Set @SqlFilterUn1 = ''
           if @PTableName='ARKA' or @PTableName='BANKA' or @PTableName='VS' or @PTableName='FJ'
              Begin
                Set  @SqlFilterUn1 = ' 

                     DELETE DAR
                       FROM '+@PTableName+'Scr A INNER JOIN DAR B ON A.NRDITAR=B.NRRENDOR 
                      WHERE A.NRD='+@SPNrRendor+' AND A.TIPKLL=''A'' 

                     DELETE DBA
                       FROM '+@PTableName+'Scr A INNER JOIN DBA B ON A.NRDITAR=B.NRRENDOR 
                      WHERE A.NRD='+@SPNrRendor+' AND A.TIPKLL=''B'' 

                     DELETE DKL
                       FROM '+@PTableName+'Scr A INNER JOIN DKL B ON A.NRDITAR=B.NRRENDOR 
                      WHERE A.NRD='+@SPNrRendor+' AND A.TIPKLL=''S'' 

                     DELETE DFU
                       FROM '+@PTableName+'Scr A INNER JOIN DFU B ON A.NRDITAR=B.NRRENDOR 
                      WHERE A.NRD='+@SPNrRendor+' AND A.TIPKLL=''F'' 

                     UPDATE A 
                        SET A.NRDITAR = 0
                       FROM '+@PTableName+'Scr A 
                      WHERE A.NRD='+@SPNrRendor+' AND A.NRDITAR<>0 '

               Exec(@SqlFilterUn1)

              End

           if @PSgn = -1
              Return

         End


--                      2                       --

--    S H T I M I       I     D I T A R E V E

--       A R K A,   B A N K A,   V S

    if @PTableName='ARKA' or @PTableName='BANKA' or @PTableName='VS'

       Begin

--       Koka e Dokumentit

         if @PTableName='ARKA' or @PTableName='BANKA'         
             Exec(' 
               Declare @NewID        Int,
                       @RowCount     Int

                INSERT INTO ' + @Ditar + '
                      (KOD,PERSHKRIM,KOMENT,TIPDOK,TREGDK,  
                       NRDITAR,NRDOK,FRAKSDOK,DATEDOK,NRFAT,DTFAT,TIPFAT, 
                       KMON,VLEFTA,VLEFTAMV,KURS1,KURS2, 
                       KODMASTER,ISDOKSHOQ,TAGNR,ORG,LLOJDOK )
                SELECT KODAB+''.''+ISNULL(KMON,''''),SHENIM1,SHENIM2,TIPDOK, 
                       CASE WHEN TIPDOK IN (''MA'',''XK'',''AB'',''DB'') 
                            THEN ''D''
                            ELSE ''K'' END, 
                       NRRENDOR,NUMDOK,FRAKSDOK,DATEDOK,NUMDOK,DATEDOK,TIPDOK, 
                       KMON,VLERA,VLERAMV,KURS1,KURS2, 
                       KODAB,0,NRRENDOR,'''+@Tip+''',''''
                  FROM '+@PTableName+' A
                 WHERE A.NRRENDOR = '+@SPNrRendor+' 

                   SET @RowCount=@@ROWCOUNT

                    if @RowCount<>0
                       Begin
                         SELECT @NewID=@@IDENTITY  
                         UPDATE A  
                            SET A.NRDITAR = @NewID 
                           FROM '+@PTableName+' A
                          WHERE NRRENDOR='+@SPNrRendor+'
                       End ') 


--       Rrjeshtat Scr

         Exec(' UPDATE A
                   SET NRDITAR = 0 
                  FROM '+@PTableName+'Scr A
                 WHERE A.NRD='+@SPNrRendor+' AND NRDITAR<>0 ')

         Set  @SqlFilterUn1 = ' INSERT INTO DAR 
                                      (KOD,PERSHKRIM,KOMENT,TIPDOK,TREGDK,
                                       NRDOK,FRAKSDOK,DATEDOK,NRFAT,DTFAT,TIPFAT,
                                       KMON,VLEFTA,VLEFTAMV,KURS1,KURS2,
                                       KODMASTER,ISDOKSHOQ,TAGNR,NRRENDORDOK,ORG,LLOJDOK)
                                SELECT B.KOD,A.SHENIM1,B.KOMENT,A.TIPDOK,TREGDK,
                                       A.NUMDOK,A.FRAKSDOK,A.DATEDOK,B.NRDOKREF,B.DATEDOKREF,B.TIPREF,
                                       B.KMON, CASE WHEN B.TREGDK=''D'' THEN DB ELSE KR END,
                                               CASE WHEN B.TREGDK=''D'' THEN B.DBKRMV ELSE 0-B.DBKRMV END, B.KURS1,B.KURS2,
                                       A.KODAB,0,B.NRRENDOR,A.NRRENDOR,''A'',''''
                                  FROM '+@PTableName+' A INNER JOIN '+@PTableName+'SCR B ON A.NRRENDOR=B.NRD 
                                 WHERE A.NRRENDOR='+@SPNrRendor+' AND TIPKLL=''A''  

                                UPDATE A 
                                   SET A.NRDITAR = B.NRRENDOR 
                                  FROM '+@PTableName+'Scr A INNER JOIN DAR B ON A.NRRENDOR = B.TAGNR  
                                 WHERE A.NRD='+@SPNrRendor+' AND 
                                       B.NRRENDORDOK='+@SPNrRendor+' AND B.TAGNR<>0 AND B.ORG=''A'' 

                                UPDATE DAR 
                                   SET TAGNR=0, ORG='''', NRRENDORDOK=0 
                                 WHERE NRRENDORDOK='+@SPNrRendor+' AND (ISNULL(TAGNR,0)<>0 OR ORG<>'''') '

         if @PTableName='VS'
            Begin
              Set  @SqlFilterUn1 = Replace(@SqlFilterUn1,'A.SHENIM1,','B.PERSHKRIM,')
              Set  @SqlFilterUn1 = Replace(@SqlFilterUn1,'A.NUMDOK,A.FRAKSDOK','A.NRDOK,0')
              Set  @SqlFilterUn1 = Replace(@SqlFilterUn1,'A.KODAB,',''''',')
              Set  @SqlFilterUn1 = Replace(@SqlFilterUn1,'A.TIPDOK,','''SP'',')
            End

         Set @SqlFilterUn2 = @SqlFilterUn1 

--       Shtim tek Ditari DAR
         Exec(@SqlFilterUn2)

--       Shtim tek Ditari DBA
         Set  @SqlFilterUn2 = Replace(@SqlFilterUn1,'''A''', '''B''')
         Set  @SqlFilterUn2 = Replace(@SqlFilterUn2,' DAR',  ' DBA')
         Exec(@SqlFilterUn2)

--       Shtim tek Ditari DKL
         Set  @SqlFilterUn2 = Replace(@SqlFilterUn1,'''A''', '''S''')
         Set  @SqlFilterUn2 = Replace(@SqlFilterUn2,' DAR',  ' DKL')
         Exec(@SqlFilterUn2)

--       Shtim tek Ditari DFU
         Set  @SqlFilterUn2 = Replace(@SqlFilterUn1,'''A''', '''F''')
         Set  @SqlFilterUn2 = Replace(@SqlFilterUn2,' DAR',  ' DFU')
         Exec(@SqlFilterUn2)
 
       End



--       FF

    if @PTableName='FF' 
       Begin

--       Koka e Dokumentit

         Set  @ParaPg = IsNull((SELECT PARAPG FROM FF WHERE NRRENDOR=@PNrRendor),0)

         Set  @Treg1DK      = '''K'''
         Set  @Treg2DK      = '''D'''
         Set  @SqlFilterUn1 = '
                               Declare @NewID        Int,
                                       @RowCount     Int 

                               INSERT INTO '+@Ditar+'
                                      (KOD,PERSHKRIM,KOMENT,TIPDOK,TREGDK,
                                       NRDITAR,NRDOK,FRAKSDOK,DATEDOK,NRFAT,DTFAT,TIPFAT,
                                       KMON,VLEFTA,VLEFTAMV,KURS1,KURS2,
                                       KODMASTER,TAGNR,ORG,LLOJDOK )
                                SELECT KODFKL+''.''+KMON,SHENIM1,SHENIM3,'''+@PTableName+''','+@Treg1DK+',
                                       NRRENDOR,NRDOK,0,DATEDOK,ISNULL(NRDSHOQ,''''),DTDSHOQ,'''+@PTableName+''',
                                       KMON,VLERTOT,
                                       ROUND(VLERTOT*A.KURS2/A.KURS1,3),
                                       A.KURS1,
                                       A.KURS2,
                                       KODFKL,NRRENDOR,'''+@Tip+''',LLOJDOK 
                                  FROM '+@PTableName+' A
                                 WHERE A.NRRENDOR = '+@SPNrRendor+' AND 1=1

                                   SET @RowCount=@@ROWCOUNT
                                    if @RowCount<>0
                                       Begin
                                         SELECT  @NewID=@@IDENTITY  
                                         UPDATE A 
                                            SET A.NRDITAR = @NewID 
                                           FROM '+@PTableName+' A
                                          WHERE NRRENDOR='+@SPNrRendor+'
                                       End ' 

         Set  @SqlFilterUn1 = Replace(@SqlFilterUn1,'A.KURS1','CASE WHEN ISNULL(A.KMON,'''')='''' THEN 1 ELSE A.KURS1 END')
         Set  @SqlFilterUn1 = Replace(@SqlFilterUn1,'A.KURS2','CASE WHEN ISNULL(A.KMON,'''')='''' THEN 1 ELSE A.KURS2 END')

         Exec(@SqlFilterUn1)
         
--		 Rasti Likujdim parapagese FF

         if @ParaPG>0
            Begin
              Set  @SqlFilterUn1 = Replace(@SqlFilterUn1,'VLERTOT','PARAPG')
              Set  @SqlFilterUn1 = Replace(@SqlFilterUn1,'1=1','ISNULL(A.PARAPG,0)<>0')
              Set  @SqlFilterUn1 = Replace(@SqlFilterUn1,@Treg1DK,@Treg2DK)
              Set  @SqlFilterUn1 = Replace(@SqlFilterUn1,'SHENIM3','SHENIM3+''/Shlyerje''')
              Set  @SqlFilterUn1 = Replace(@SqlFilterUn1,'A.NRDITAR','A.NRDITARSHL')
              Exec(@SqlFilterUn1)
            End

       End


--       FJ

    if @PTableName='FJ'

       Begin

--       Koka e Dokumentit

         Set    @ParaPg       = IsNull((SELECT PARAPG FROM FJ WHERE NRRENDOR=@PNrRendor),0)
         SELECT @PromocNdarje = IsNull(NDARJEPROMOCFJ,0) FROM CONFIGMG

         Set  @Treg1DK = '''D'''
         Set  @Treg2DK = '''K'''
         Set  @Field   = ' SUM(CASE WHEN ISNULL(B.PROMOC,0)=0 
                                    THEN ISNULL(B.VLPATVSH,0)
                                    ELSE 0 END - 
                               ISNULL(B.VLERAFR,0)) -
                           MAX(ISNULL(A.VLERZBR,0)) + MAX(ISNULL(A.VLTVSH,0)) '
         Set  @FieldMV = '(SUM(CASE WHEN ISNULL(B.PROMOC,0)=0 
                                    THEN ISNULL(B.VLPATVSH,0)
                                    ELSE 0 END - 
                               ISNULL(B.VLERAFR,0)) -
                           MAX(ISNULL(A.VLERZBR,0)) + MAX(ISNULL(A.VLTVSH,0)))* MAX(A.KURS2)/MAX(A.KURS1) '

--         Set  @Field   = ' SUM(CASE WHEN ISNULL(B.PROMOC,0)=0 
--                                    THEN ISNULL(B.VLPATVSH,0)+ISNULL(B.VLTVSH,0)
--                                    ELSE 0 END - 
--                               ISNULL(B.VLERAFR,0)) -
--                           MAX(ISNULL(A.VLERZBR,0)) '
--         Set  @FieldMV = '(SUM(CASE WHEN ISNULL(B.PROMOC,0)=0 
--                                    THEN ISNULL(B.VLPATVSH,0)+ISNULL(B.VLTVSH,0)
--                                    ELSE 0 END - 
--                               ISNULL(B.VLERAFR,0)) -
--                           MAX(ISNULL(A.VLERZBR,0)))* MAX(KURS2)/MAX(KURS1) '


         if @PromocNdarje=1						--  NdarjePromoc
            Begin
              Set @Field   = Replace(@Field,  'ISNULL(B.PROMOC,0)=0','1=1')
              Set @FieldMV = Replace(@FieldMV,'ISNULL(B.PROMOC,0)=0','1=1')
            End

         Set  @SqlFilterUn1 = '  Declare @NewID        Int,
                                         @RowCount     Int  

                                  INSERT INTO '+@Ditar+'
                                        (KOD,PERSHKRIM,KOMENT,TIPDOK,TREGDK,
                                         NRDITAR,NRDOK,FRAKSDOK,DATEDOK,NRFAT,DTFAT,TIPFAT,
                                         KMON,VLEFTA,VLEFTAMV,KURS1,KURS2,
                                         KODMASTER,ISDOKSHOQ,TAGNR,ORG,LLOJDOK) 
                                  SELECT MAX(A.KODFKL+''.''+ISNULL(A.KMON,'''')),MAX(A.SHENIM1),MAX(A.SHENIM3),'''+@PTableName+''','+@Treg1DK+',
                                         A.NRRENDOR,MAX(A.NRDOK),0,MAX(A.DATEDOK),
                                         CASE WHEN MAX(ISNULL(A.LLOJDOK,''''))=''H'' THEN MAX(ISNULL(A.NRFATST,'''')) ELSE MAX(ISNULL(A.NRDSHOQ,A.DATEDOK)) END,
                                         CASE WHEN MAX(ISNULL(A.LLOJDOK,''''))=''H'' THEN MAX(ISNULL(A.DTFATST,0))    ELSE MAX(ISNULL(A.DTDSHOQ,A.DATEDOK)) END,'''+@PTableName+''',
                                         MAX(ISNULL(A.KMON,'''')),
                                         ROUND(0,3), 
                                         ROUND(1,3),
                                         MAX(A.KURS1),
                                         MAX(A.KURS2),
                                         MAX(A.KODFKL),ISNULL(A.ISDOKSHOQ,0),A.NRRENDOR,'''+@Tip+''',
                                         MAX(ISNULL(A.LLOJDOK,'''')) 
                                    FROM '+@PTableName+' A LEFT JOIN '+@PTableName+'Scr B ON A.NRRENDOR=B.NRD  
                                   WHERE A.NRRENDOR = '+@SPNrRendor+' AND 1=1 
                                GROUP BY A.NRRENDOR,ISNULL(A.ISDOKSHOQ,0) 
                                  HAVING ABS(ROUND(100,3))>=0.01  -- Te diskutohet per rjeshta me vlera 0

                                     SET @RowCount=@@ROWCOUNT
                                      if @RowCount<>0
                                         Begin
                                           SELECT  @NewID=@@IDENTITY  
                                           UPDATE A 
                                              SET A.NRDITAR = @NewID 
                                             FROM '+@PTableName+' A
                                            WHERE NRRENDOR='+@SPNrRendor+'
                                         End '

         Set  @SqlFilterUn2  = Replace(@SqlFilterUn1,'ROUND(0,3)','ROUND('+@Field  +',3)')
         Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'ROUND(1,3)','ROUND('+@FieldMV+',3)')

         Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'A.KURS1','CASE WHEN ISNULL(A.KMON,'''')='''' THEN 1 ELSE A.KURS1 END')
         Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'A.KURS2','CASE WHEN ISNULL(A.KMON,'''')='''' THEN 1 ELSE A.KURS2 END')
         Exec(@SqlFilterUn2)

         if @PromocNdarje=1						--  NdarjePromoc  Promocion rrjesht me vete
            Begin
              Set  @Field         = ' SUM(ISNULL(B.VLPATVSH,0)+ISNULL(B.VLTVSH,0)) '
              Set  @FieldMV       = '(SUM(ISNULL(B.VLPATVSH,0)+ISNULL(B.VLTVSH,0))* MAX(A.KURS2)/MAX(A.KURS1)) '

              Set  @SqlFilterUn2  = Replace(@SqlFilterUn1, @Treg1DK, @Treg2DK)
              Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'ROUND(0,3)','ROUND('+@Field  +',3)')
              Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'ROUND(1,3)','ROUND('+@FieldMV+',3)')

              Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'1=1', 'ISNULL(B.PROMOC,0)=1 AND A.NRDITARPRMC=0')
              Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'MAX(A.SHENIM3)',   '''Promocion FJ nr ''+MAX(ISNULL(A.NRDSHOQ,''''))+'', dt.''+MAX(CONVERT(CHAR(12),ISNULL(A.DTDSHOQ,A.DATEDOK))) ')
              Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'SET A.NRDITAR',    'SET A.NRDITARPRMC')

              Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'A.KURS1','CASE WHEN ISNULL(A.KMON,'''')='''' THEN 1 ELSE A.KURS1 END')
              Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'A.KURS2','CASE WHEN ISNULL(A.KMON,'''')='''' THEN 1 ELSE A.KURS2 END')
              Exec(@SqlFilterUn2)
            End
--													Rasti Likujdim parapagese FJ
         if @ParaPg<>0
            Begin

              Set  @SqlFilterUn1 = 'Declare @NewID        Int,
                                            @RowCount     Int 

                                     INSERT INTO '+@Ditar+'
                                           (KOD,PERSHKRIM,KOMENT,TIPDOK,TREGDK,
                                            NRDITAR,NRDOK,FRAKSDOK,DATEDOK,NRFAT,DTFAT,TIPFAT,
                                            KMON,VLEFTA,VLEFTAMV,KURS1,KURS2,
                                            KODMASTER,TAGNR,ORG,LLOJDOK )
                                     SELECT KODFKL+''.''+KMON,SHENIM1,SHENIM3+''/Shlyerje'','''+@PTableName+''',''K'',
                                            NRRENDOR,NRDOK,0,DATEDOK,ISNULL(NRDSHOQ,''''),DTDSHOQ,'''+@PTableName+''',
                                            KMON,
                                            PARAPG,
                                            ROUND(PARAPG*A.KURS2/A.KURS1,3),
                                            A.KURS1,
                                            A.KURS2,
                                            KODFKL,NRRENDOR,'''+@Tip+''',LLOJDOK 
                                       FROM '+@PTableName+' A
                                      WHERE NRRENDOR='+@SPNrRendor+' AND ISNULL(PARAPG,0)<>0

                                        SET @RowCount=@@ROWCOUNT
                                         if @RowCount<>0
                                            Begin
                                              SELECT @NewID=@@IDENTITY  
                                              UPDATE A 
                                                 SET A.NRDITARSHL = @NewID 
                                                FROM '+@PTableName+' A 
                                               WHERE NRRENDOR='+@SPNrRendor+'
                                            End ' 
              Set  @SqlFilterUn2  = @SqlFilterUn1; 
              Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'A.KURS1','CASE WHEN ISNULL(A.KMON,'''')='''' THEN 1 ELSE A.KURS1 END')
              Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'A.KURS2','CASE WHEN ISNULL(A.KMON,'''')='''' THEN 1 ELSE A.KURS2 END')
              Exec(@SqlFilterUn2)

            End


--       Rrjeshta

         Set @SqlFilterUn1 = ' 
                INSERT INTO ' + @Ditar + '                     
                      (KOD,PERSHKRIM,KOMENT,TIPDOK,TREGDK, 
                       NRDITAR,NRDOK,FRAKSDOK,DATEDOK,NRFAT,DTFAT,TIPFAT,
                       KMON,VLEFTA,VLEFTAMV,KURS1,KURS2,
                       KODMASTER,ISDOKSHOQ,TAGNR,NRRENDORDOK,ORG,LLOJDOK )
                SELECT B.KOD,B.PERSHKRIM,B.KOMENT,''SP'',''D'',
                       B.NRDITAR,A.NRDOK,0,A.DATEDOK,B.NRDOKREF,B.DATEDOKREF,B.TIPREF,
                       A.KMON,
                       0-B.VLERABS,
                       0-ROUND(CASE WHEN A.KURS2=0 THEN 0 ELSE (B.VLERABS*A.KURS2)/A.KURS1 END,3),
                       A.KURS1,
                       A.KURS2,
                       KODFKL,0,B.NRRENDOR,A.NRRENDOR,'''+@Tip+''',''''
                  FROM '+@PTableName+' A INNER JOIN '+@PTableName+'SCR B ON A.NRRENDOR=B.NRD 
                 WHERE A.NRRENDOR='+@SPNrRendor+' AND TIPKLL='''+@Tip+'''  

                UPDATE A 
                   SET A.NRDITAR = B.NRRENDOR 
                  FROM '+@PTableName+'Scr A INNER JOIN ' + @Ditar +' B ON A.NRRENDOR = B.TAGNR  
                 WHERE A.NRD='+@SPNrRendor+' AND 
                       B.NRRENDORDOK='+@SPNrRendor+' AND B.TAGNR<>0 AND B.ORG='''+@Tip+''' 

                UPDATE '+@Ditar+' 
                   SET TAGNR=0, ORG='''', NRRENDORDOK=0 
                 WHERE NRRENDORDOK='+@SPNrRendor+' AND (ISNULL(TAGNR,0)<>0 or ORG<>'''') ';

         Set  @SqlFilterUn2  = @SqlFilterUn1; 
         Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'A.KURS1','CASE WHEN ISNULL(A.KMON,'''')='''' THEN 1 ELSE A.KURS1 END')
         Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'A.KURS2','CASE WHEN ISNULL(A.KMON,'''')='''' THEN 1 ELSE A.KURS2 END')
         Exec(@SqlFilterUn2);


       End;


--                      3                       --

--    S H T I M I       I     L I B R A V E


--       Shtim Kode Ditar ne Libra						

--    Set @TmpLiber = 'TMPLiber'+@Ditar
--    if  Exists (SELECT Name FROM Sys.Objects WHERE Name=@TmpLiber and Type='U')
--        Exec('DROP TABLE ' + @TmpLiber)


      Set @SqlFilterUn1 = '  

            INSERT INTO LAR  
                  (KOD,PERSHKRIM,KMON,SG1,SG2,SG3,SG4,SG5,SG6,SG7,SG8,SG9,SG10,TROW,TAGNR)
            SELECT A.KOD,
                   PRS = (SELECT MAX(PERSHKRIM)
                            FROM ARKAT A1
                           WHERE A1.KOD=CASE WHEN CHARINDEX (''.'',A.KOD)>0
                                             THEN LEFT(A.KOD,CHARINDEX (''.'',A.KOD)-1)
                                             ELSE A.KOD END),
                   A.KMON,
                   SG1 = CASE WHEN CHARINDEX (''.'',A.KOD)>0
                              THEN LEFT(A.KOD,CHARINDEX (''.'',A.KOD)-1)
                              ELSE A.KOD END,
                   '''','''','''',A.KMON,'''', '''', '''', '''','''',0,0
              FROM DAR A 
             WHERE NOT EXISTS(SELECT KOD FROM LAR B WHERE B.KOD=A.KOD)
          GROUP BY A.KMON,A.KOD
          ORDER BY A.KOD 

            UPDATE A 
               SET A.NRLIBER=B.NRRENDOR 
              FROM DAR A INNER JOIN LAR B ON A.KOD=B.KOD 
             WHERE ISNULL(A.NRLIBER,0)<>B.NRRENDOR '

      Exec (@SqlFilterUn1)

      Set  @SqlFilterUn2 = Replace(@SqlFilterUn1,' DAR',' DBA')
      Set  @SqlFilterUn2 = Replace(@SqlFilterUn2,' LAR',' LBA')
      Set  @SqlFilterUn2 = Replace(@SqlFilterUn2,' ARKAT',' BANKAT')
      Exec(@SqlFilterUn2)

      Set  @SqlFilterUn2 = Replace(@SqlFilterUn1,' DAR',' DFU')
      Set  @SqlFilterUn2 = Replace(@SqlFilterUn2,' LAR',' LFU')
      Set  @SqlFilterUn2 = Replace(@SqlFilterUn2,' ARKAT',' FURNITOR')
      Exec(@SqlFilterUn2)

      Set  @SqlFilterUn2 = Replace(@SqlFilterUn1,' DAR',' DKL')
      Set  @SqlFilterUn2 = Replace(@SqlFilterUn2,' LAR',' LKL')
      Set  @SqlFilterUn2 = Replace(@SqlFilterUn2,' ARKAT',' KLIENT')
      Exec(@SqlFilterUn2)




--      Exec( '  
--            SELECT DISTINCT 
--                   KOD, PERSHKRIM=PERSHKRIM+'' - ''+KMON, KMON,
--                   SG1 = CASE WHEN CHARINDEX (''.'',KOD)>0
--                              THEN LEFT(KOD,CHARINDEX (''.'',KOD)-1)
--                              ELSE KOD END
--              INTO #TMPLiber 
--              FROM '+@Ditar+' A
--             WHERE NOT EXISTS(SELECT KOD FROM '+@Liber+' B WHERE B.KOD=A.KOD)
--          ORDER BY KOD
--
--            INSERT INTO '+@Liber+' 
--                  (KOD,PERSHKRIM,KMON,SG1,SG2,SG3,SG4,SG5,SG6,SG7,SG8,SG9,SG10,TROW,TAGNR)
--            SELECT KOD,PERSHKRIM,KMON,SG1,'''','''','''',KMON,'''', '''', '''', '''','''',0,0
--              FROM #TMPLiber
--          ORDER BY KOD 
--
--            UPDATE A 
--               SET A.NRLIBER=B.NRRENDOR 
--              FROM '+@Ditar+' A INNER JOIN '+@Liber+' B ON A.KOD=B.KOD 
--             WHERE A.NRLIBER<>B.NRRENDOR ')















--    if  Exists (SELECT Name FROM Sys.Objects WHERE Name=@TmpLiber and Type='U')
--        Exec('DROP TABLE ' + @TmpLiber)

 --Shtim Kode Ditar ne Libra						Fund


-- Shtim ne Ditar nga Dokumenta- Rrjeshta			Ditari nga Rrjeshtat

--
--    Set  @Table = 'ARKA'
--    Exec(' UPDATE A
--              SET NRDITAR = 0 
--             FROM ' + @Table + 'Scr A
--            WHERE A.NRD='+@SPNrRendor)
--
--    Set  @SqlFilterUn1 = ' INSERT INTO '+@Ditar+'
--                                 (KOD,PERSHKRIM,KOMENT,TIPDOK,TREGDK,
--                                  NRDOK,FRAKSDOK,DATEDOK,NRFAT,DTFAT,TIPFAT,
--                                  KMON,VLEFTA,VLEFTAMV,KURS1,KURS2,
--                                  KODMASTER,ISDOKSHOQ,TAGNR,ORG,LLOJDOK )
--                           SELECT B.KOD,A.SHENIM1,B.KOMENT,A.TIPDOK,TREGDK,
--                                  A.NUMDOK,A.FRAKSDOK,A.DATEDOK,B.NRDOKREF,B.DATEDOKREF,B.TIPREF,
--                                  B.KMON, CASE WHEN B.TREGDK=''D'' THEN DB ELSE KR END,
--                                          CASE WHEN B.TREGDK=''D'' THEN B.DBKRMV ELSE 0-B.DBKRMV END, B.KURS1,B.KURS2,
--                                  A.KODAB,0,B.NRRENDOR,'''+@PTip+''',''''
--                             FROM '+@Table+' A INNER JOIN '+@Table+'SCR B ON A.NRRENDOR=B.NRD 
--                            WHERE (TIPKLL='''+@PTip+''') AND (B.NRDITAR=0 OR (NOT (EXISTS (SELECT NRRENDOR FROM '+@Ditar+' C WHERE C.NRRENDOR = B.NRDITAR)))) 
--
--                           UPDATE A 
--                              SET A.NRDITAR = B.NRRENDOR 
--                             FROM '+@Table+'Scr A INNER JOIN ' + @Ditar +' B ON A.NRRENDOR = B.TAGNR  
--                            WHERE (B.TAGNR<>0) AND (B.ORG='''+@PTip+''') 
--
--                           UPDATE '+@Ditar+' SET TAGNR=0, ORG='''' WHERE ISNULL(TAGNR,0)<>0 OR ORG<>'''' '
--    Exec(@SqlFilterUn1)
--
--    Set  @SqlFilterUn2 = Replace(@SqlFilterUn1,' ARKA',' BANKA')
--    Exec(@SqlFilterUn2)
--
--    Set  @SqlFilterUn2 = Replace(@SqlFilterUn1,' ARKA',' VS')
--    Set  @SqlFilterUn2 = Replace(@SqlFilterUn2,'A.SHENIM1,','B.PERSHKRIM,')
--    Set  @SqlFilterUn2 = Replace(@SqlFilterUn2,'A.NUMDOK,A.FRAKSDOK','A.NRDOK,0')
--    Set  @SqlFilterUn2 = Replace(@SqlFilterUn2,'A.KODAB,',''''',')
--    Set  @SqlFilterUn2 = Replace(@SqlFilterUn2,'A.TIPDOK,','''SP'',')
--    Exec(@SqlFilterUn2)
--
--
--    if @PTip = 'S'
--       Begin
--         Set  @Table = 'FJ'
--         Exec(' INSERT INTO ' + @Ditar + '                     
--                      (KOD,PERSHKRIM,KOMENT,TIPDOK,TREGDK, 
--                       NRDITAR,NRDOK,FRAKSDOK,DATEDOK,NRFAT,DTFAT,TIPFAT,
--                       KMON,VLEFTA,VLEFTAMV,KURS1,KURS2,
--                       KODMASTER,ISDOKSHOQ,TAGNR,ORG,LLOJDOK )
--                SELECT B.KOD,B.PERSHKRIM,B.KOMENT,''SP'',''D'',
--                       B.NRDITAR,A.NRDOK,0,A.DATEDOK,B.NRDOKREF,B.DATEDOKREF,B.TIPREF,A.KMON,
--                       0-B.VLERABS,0-ROUND(CASE WHEN A.KURS2=0 THEN 0 ELSE (B.VLERABS*A.KURS2)/A.KURS1 END,3),
--                       A.KURS1,A.KURS2,
--                       KODFKL,0,B.NRRENDOR,'''+@PTip+''',''''
--                  FROM '+@Table+' A INNER JOIN '+@Table+'SCR B ON A.NRRENDOR=B.NRD 
--                 WHERE (TIPKLL='''+@PTip+''') AND (B.NRDITAR=0 OR (NOT (EXISTS (SELECT NRRENDOR FROM '+@Ditar+' C WHERE C.NRRENDOR = B.NRDITAR)))) 
--                UPDATE A 
--                   SET A.NRDITARSHL = B.NRRENDOR 
--                  FROM '+@Document+' A INNER JOIN ' + @Ditar +' B ON A.NRRENDOR = B.TAGNR  
--                 WHERE (B.TAGNR<>0) AND (B.ORG='''+@PTip+''') 
--
--                UPDATE '+@Ditar+' SET TAGNR=0, ORG='''' WHERE ISNULL(TAGNR,0)<>0 OR ORG<>'''' ')
--       End
---- Shtim ne Ditar nga Dokumenta- Rrjeshta		    Fund

--
---- Shtim Kode Ditar ne Libra						Shtimi i Kodeve ne Librat
--
--    Set @Table = 'TMPLiber'+@Ditar
--    if  Exists (SELECT Name FROM Sys.Objects WHERE Name=@Table and Type='U')
--        Exec('DROP TABLE ' + @Table)
--
--    Exec('  SELECT DISTINCT 
--                   KOD, PERSHKRIM=PERSHKRIM+'' - ''+KMON, KMON,
--                   SG1 = CASE WHEN CHARINDEX (''.'',KOD)>0
--                              THEN LEFT(KOD,CHARINDEX (''.'',KOD)-1)
--                              ELSE KOD END
--              INTO '+@Table+'
--              FROM '+@Ditar+' A
--             WHERE NOT EXISTS(SELECT KOD FROM '+@Liber+' B WHERE B.KOD=A.KOD)
--          ORDER BY KOD
--
--            INSERT INTO '+@Liber+' 
--                  (KOD,PERSHKRIM,KMON,SG1,SG2,SG3,SG4,SG5,SG6,SG7,SG8,SG9,SG10,TROW,TAGNR)
--            SELECT KOD,PERSHKRIM,KMON,SG1,'''','''','''',KMON,'''', '''', '''', '''','''',0,0
--              FROM '+@Table+'
--          ORDER BY KOD 
--
--            UPDATE A 
--               SET A.NRLIBER=B.NRRENDOR 
--              FROM '+@Ditar+' A INNER JOIN '+@Liber+' B ON A.KOD=B.KOD ')
--
--    if  Exists (SELECT Name FROM Sys.Objects WHERE Name=@Table and Type='U')
--        Exec('DROP TABLE ' + @Table)

-- Shtim Kode Ditar ne Libra						Fund


-- GJENERIMI I RRJESHTAVE DITAR						FUND








GO
