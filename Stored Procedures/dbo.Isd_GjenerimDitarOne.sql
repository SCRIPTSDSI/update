SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Exec [Isd_GjenerimDitarOne] @PTableName = 'ARKA', @PSgn = 0, @PNrRendor = 1;

CREATE         Procedure [dbo].[Isd_GjenerimDitarOne]
(
  @pTableName Varchar(30),
  @pSgn       Int,
  @pNrRendor  Int
 )
As

         SET NOCOUNT ON
 
     DECLARE @TableName      Varchar(30),
             @Sgn            Int,
             @NrRendor       Int,

             @TableScrName   Varchar(30),
             @Ditar          Varchar(30),
             @Tip            Varchar(10),
             @TranNumber     Varchar(50),

             @String1        Varchar(100),
             @String2        Varchar(100), 
             @SqlFilterUn1   Varchar(5000),
             @SqlFilterUn2   Varchar(5000),

             @Treg1DK        Varchar(5),
             @Treg2DK        Varchar(5),
             @Field          Varchar(1000),
             @FieldMV        Varchar(1000),
             @PromocNdarje   Bit,
             @PromocExists   Bit,
             @ParaPg         Float,
             @sNrRendor      Varchar(30),
             @i              Int;

         SET @TableName    = @PTableName;
         SET @Sgn          = @PSgn;
         SET @NrRendor     = @PNrRendor;
         SET @TableScrName = @TableName+'Scr';
         SET @sNrRendor    = Cast(@NrRendor As Varchar);
         
         SET @i = dbo.Isd_StringInListInd('ARKA,BANKA,VS,FJ,FF',@TableName,',');
          IF @i<=0
             RETURN;

         SET @TranNumber   = dbo.Isd_RandomNumberChars(1);

         SET @Ditar        = dbo.Isd_StringInListStr('DAR,DBA,,DKL,DFU',@i,',');
         SET @Tip          = dbo.Isd_StringInListStr('A,B,E,S,F',@i,',');


-- 1     *****     FSHIRJA DITAREVE     *****

      IF @Sgn=0 OR @Sgn=-1

         BEGIN

           SET @SqlFilterUn1 = '';
 
            IF @TableName<>'VS'
               SET @SqlFilterUn1 = @SqlFilterUn1 + ' 
                 -- koka

                    DELETE FROM '+@Ditar+' WHERE NRRENDORDOK='+@sNrRendor+' AND ORG='''+@Tip+'''; ';


            IF @TableName='FJ'
               SET @SqlFilterUn1 = @SqlFilterUn1 + ' 

                    UPDATE '+@TableName+' SET NRDITAR=0,NRDITARSHL=0,NRDITARPRMC=0 WHERE NRRENDOR='+@sNrRendor+'; ';


            IF @TableName = 'FF'
               SET @SqlFilterUn1 = @SqlFilterUn1 + ' 

                    UPDATE '+@TableName+' SET NRDITAR=0,NRDITARSHL=0 WHERE NRRENDOR='+@sNrRendor+'; ';


            IF CHARINDEX(','+@TableName+',',',ARKA,BANKA,')>0
               SET @SqlFilterUn1 = @SqlFilterUn1+' 

                    UPDATE '+@TableName+' SET NRDITAR=0 WHERE NRRENDOR='+@sNrRendor+'; ';


           IF CHARINDEX(','+@TableName+',', ',ARKA,BANKA,VS,FJ,FF,')>0
              BEGIN

                  SET @SqlFilterUn1 = @SqlFilterUn1 + ' 

                 -- reshta

                    DELETE FROM DAR WHERE NRRENDORDOK='+@sNrRendor+' AND ORG='''+@Tip+'''; 

                    DELETE FROM DBA WHERE NRRENDORDOK='+@sNrRendor+' AND ORG='''+@Tip+'''; 

                    DELETE FROM DKL WHERE NRRENDORDOK='+@sNrRendor+' AND ORG='''+@Tip+'''; 

                    DELETE FROM DFU WHERE NRRENDORDOK='+@sNrRendor+' AND ORG='''+@Tip+'''; 

                    UPDATE '+@TableScrName+' 
                       SET NRDITAR = 0
                     WHERE NRD='+@sNrRendor+' AND ISNULL(NRDITAR,0)<>0; ';

              END;

           Exec (@SqlFilterUn1);


           IF @Sgn = -1
              RETURN; 

         END;

-- 1     *****     Fund Fshirje Ditare     *****



-- 2     *****     SHTIMI NE DITARE     *****


    --       Arka, Banka, VS

    IF @TableName='ARKA' OR @TableName='BANKA' OR @TableName='VS'

       BEGIN

       -- Koka e Dokumentit

         IF @TableName='ARKA' OR @TableName='BANKA'
            BEGIN  
       
              SET @SqlFilterUn1 = ' 

               DECLARE @NewID        Int,
                       @RowCount     Int;

                INSERT INTO ' + @Ditar + '
                      (KOD,PERSHKRIM,KOMENT,TIPDOK,TREGDK,  
                       NRDITAR,NRDOK,FRAKSDOK,DATEDOK,NRFAT,DTFAT,TIPFAT, 
                       KMON,VLEFTA,VLEFTAMV,KURS1,KURS2, 
                       KODMASTER,ISDOKSHOQ,TAGNR,TIPKLL,NRRENDORDOK,ORG,LLOJDOK,TRANNUMBER )
                SELECT LTRIM(RTRIM(KODAB))+''.''+LTRIM(RTRIM(ISNULL(KMON,''''))),SHENIM1,SHENIM2,TIPDOK, 
                
                       CASE WHEN TIPDOK IN (''MA'',''XK'',''AB'',''DB'') THEN ''D'' ELSE ''K'' END, 

                       NRRENDOR,NUMDOK,FRAKSDOK,DATEDOK,NUMDOK,DATEDOK,TIPDOK, 
                       LTRIM(RTRIM(ISNULL(KMON,''''))),VLERA,VLERAMV,KURS1,KURS2, 
                       KODAB,0,0,'''',NRRENDOR,'''+@Tip+''','''','''+@TranNumber+'''
                  FROM '+@TableName+' A
                 WHERE A.NRRENDOR = '+@sNrRendor+' ;

                   SET @RowCount=@@ROWCOUNT;

                    IF @RowCount<>0
                       BEGIN
                         SELECT @NewID=@@IDENTITY;  
                         UPDATE '+@TableName+' SET NRDITAR=@NewID WHERE NRRENDOR='+@sNrRendor+'; 
                       END; ';

              Exec (@SqlFilterUn1); 

            END;


       --  Rrjeshtat Scr

         SET @SqlFilterUn1 = '

                UPDATE '+@TableScrName+' SET NRDITAR = 0 WHERE NRD='+@sNrRendor+' AND NRDITAR<>0; ';

        Exec (@SqlFilterUn1);


         SET  @SqlFilterUn1 = '

                INSERT INTO DAR 
                      (KOD,PERSHKRIM,KOMENT,TIPDOK,TREGDK,
                       NRDOK,FRAKSDOK,DATEDOK,NRFAT,DTFAT,TIPFAT,
                       KMON,
                       VLEFTA,VLEFTAMV,
                       KURS1,KURS2,
                       KODMASTER,KODREF,DET1,DET2,DET3,DET4,DET5,
					   ISDOKSHOQ,TAGNR,TIPKLL,NRRENDORDOK,ORG,LLOJDOK,TRANNUMBER)
             
                SELECT KOD=LTRIM(RTRIM(B.KOD)),B.PERSHKRIM,B.KOMENT,A.TIPDOK,TREGDK,
                       A.NUMDOK,A.FRAKSDOK,A.DATEDOK,B.NRDOKREF,B.DATEDOKREF,B.TIPREF,
                       LTRIM(RTRIM(ISNULL(B.KMON,''''))), 
                       CASE WHEN B.TREGDK=''D'' THEN DB       ELSE KR         END,
                       CASE WHEN B.TREGDK=''D'' THEN B.DBKRMV ELSE 0-B.DBKRMV END, 
                       B.KURS1,B.KURS2,
                       A.KODAB,
					   KODREF = dbo.Isd_SegmentFind(B.KOD,0,1),
					   DET1   = dbo.Isd_SegmentFind(B.KODDETAJ,0,1),
					   DET2   = dbo.Isd_SegmentFind(B.KODDETAJ,0,2),
					   DET3   = dbo.Isd_SegmentFind(B.KODDETAJ,0,3),
					   DET4   = '''', DET5 = '''',
					   ISDOKSHOQ=0,
					   B.NRRENDOR,B.TIPKLL,A.NRRENDOR,'''+@Tip+''','''','''+@TranNumber+'''
                  FROM '+@TableName+' A INNER JOIN '+@TableScrName+' B ON A.NRRENDOR=B.NRD 
                 WHERE A.NRRENDOR='+@sNrRendor+' AND TIPKLL=''_'' ; 

                UPDATE A 
                   SET A.NRDITAR = B.NRRENDOR 
                  FROM '+@TableScrName+' A INNER JOIN DAR B ON A.NRRENDOR = B.TAGNR  
                 WHERE A.NRD='+@sNrRendor+' AND B.TRANNUMBER='''+@TranNumber+''';

                UPDATE DAR SET TAGNR=0, TRANNUMBER='''' WHERE TRANNUMBER='''+@TranNumber+'''; ';

         IF @TableName='VS'
            BEGIN
              SET  @SqlFilterUn1 = REPLACE(@SqlFilterUn1,'A.SHENIM1,','B.PERSHKRIM,');
              SET  @SqlFilterUn1 = REPLACE(@SqlFilterUn1,'A.NUMDOK,A.FRAKSDOK','A.NRDOK,0');
              SET  @SqlFilterUn1 = REPLACE(@SqlFilterUn1,'A.KODAB,',''''',');
              SET  @SqlFilterUn1 = REPLACE(@SqlFilterUn1,'A.TIPDOK,','''SP'',');
            END;

      -- Shtim tek Ditari DAR
         SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn1,'''_''', '''A''');
         Exec (@SqlFilterUn2);  

      -- Shtim tek Ditari DBA
         SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn1,'''_''', '''B''');
         SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn2,' DAR',  ' DBA');
         Exec (@SqlFilterUn2);  

      -- Shtim tek Ditari DKL
         SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn1,'''_''', '''S''');
         SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn2,' DAR',  ' DKL');
         Exec (@SqlFilterUn2);  

      -- Shtim tek Ditari DFU
         SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn1,'''_''', '''F''');
         SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn2,' DAR',  ' DFU');
         Exec (@SqlFilterUn2);  
 
       END;



    --       FF

    IF @TableName='FF' 
       BEGIN

       -- Koka e Dokumentit

--       SET  @ParaPg       = ISNULL((SELECT PARAPG FROM FF WHERE NRRENDOR=@NrRendor),0);
         SET  @ParaPg       = ISNULL( ( SELECT PARAPG = CASE WHEN ISNULL(NRRENDORAR,0)<>0 THEN 0 ELSE ISNULL(PARAPG,0) END 
                                         FROM FF 
                                        WHERE NRRENDOR=@NrRendor),0);


         SET  @Treg1DK      = '''K''';
         SET  @Treg2DK      = '''D''';
         SET  @SqlFilterUn1 = '

               DECLARE @NewID        Int,
                       @RowCount     Int; 

                INSERT INTO '+@Ditar+'
                      (KOD,PERSHKRIM,KOMENT,TIPDOK,TREGDK,
                       NRDITAR,NRDOK,FRAKSDOK,DATEDOK,NRFAT,DTFAT,TIPFAT,
                       KMON,VLEFTA,VLEFTAMV,KURS1,KURS2,
                       KODMASTER,TAGNR,TIPKLL,NRRENDORDOK,ORG,LLOJDOK,TRANNUMBER )
                SELECT LTRIM(RTRIM(KODFKL))+''.''+LTRIM(RTRIM(ISNULL(KMON,''''))),SHENIM1,SHENIM3,'''+@TableName+''','+@Treg1DK+',
                       NRRENDOR,NRDOK,0,DATEDOK,ISNULL(NRDSHOQ,''''),DTDSHOQ,'''+@TableName+''',
                       LTRIM(RTRIM(ISNULL(KMON,''''))), VLERTOT, ROUND(VLERTOT*A.KURS2/A.KURS1,3), A.KURS1, A.KURS2,
                       KODFKL,0,'''',NRRENDOR,'''+@Tip+''',LLOJDOK,'''+@TranNumber+''' 
                  FROM '+@TableName+' A
                 WHERE A.NRRENDOR = '+@sNrRendor+' AND 1=1 ;

                   SET @RowCount=@@ROWCOUNT;
                    IF @RowCount<>0
                       BEGIN
                         SELECT @NewID=@@IDENTITY;  
                         UPDATE '+@TableName+' SET NRDITAR=@NewID WHERE NRRENDOR='+@sNrRendor+';
                       END; '; 

         SET  @SqlFilterUn1 = REPLACE(@SqlFilterUn1,'A.KURS1','CASE WHEN LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' THEN 1 ELSE A.KURS1 END');
         SET  @SqlFilterUn1 = REPLACE(@SqlFilterUn1,'A.KURS2','CASE WHEN LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' THEN 1 ELSE A.KURS2 END');

         Exec(@SqlFilterUn1);
         
         
         IF @ParaPG>0                           --	Rasti Likujdim parapagese FF
            BEGIN
              SET  @SqlFilterUn1 = REPLACE(@SqlFilterUn1,'VLERTOT','PARAPG');
              SET  @SqlFilterUn1 = REPLACE(@SqlFilterUn1,'1=1','(ISNULL(A.PARAPG,0)<>0 AND ISNULL(A.NRRENDORAR,0)=0)');
              SET  @SqlFilterUn1 = REPLACE(@SqlFilterUn1,@Treg1DK,@Treg2DK);
              SET  @SqlFilterUn1 = REPLACE(@SqlFilterUn1,'SHENIM3','SHENIM3+''/Shlyerje''');
              SET  @SqlFilterUn1 = REPLACE(@SqlFilterUn1,'A.NRDITAR','A.NRDITARSHL');
              Exec(@SqlFilterUn1);
            END;

         --       Rrjeshta

         SET @SqlFilterUn1 = ' 
                INSERT INTO ' + @Ditar + '                     
                      (KOD,PERSHKRIM,KOMENT,TIPDOK,TREGDK, 
                       NRDITAR,NRDOK,FRAKSDOK,DATEDOK,NRFAT,DTFAT,TIPFAT,
                       KMON,VLEFTA,VLEFTAMV,KURS1,KURS2,
                       KODMASTER,ISDOKSHOQ,TAGNR,TIPKLL,NRRENDORDOK,ORG,LLOJDOK,TRANNUMBER )
                SELECT LTRIM(RTRIM(B.KOD)),B.PERSHKRIM,B.KOMENT,'''+@TableName+''',''K'',
                       B.NRDITAR,A.NRDOK,0,A.DATEDOK,B.NRDOKREF,B.DATEDOKREF,B.TIPREF,
                       LTRIM(RTRIM(ISNULL(A.KMON,''''))),
                       0-B.VLERABS,
                       0-ROUND(CASE WHEN A.KURS2=0 THEN 0 ELSE (B.VLERABS*A.KURS2)/A.KURS1 END,3),
                       A.KURS1,
                       A.KURS2,
                       KODFKL,0,B.NRRENDOR,B.TIPKLL,A.NRRENDOR,'''+@Tip+''',ISNULL(A.LLOJDOK,''''),'''+@TranNumber+'''
                  FROM '+@TableName+' A INNER JOIN '+@TableScrName+' B ON A.NRRENDOR=B.NRD 
                 WHERE A.NRRENDOR='+@sNrRendor+' AND TIPKLL=''F'' ; 

                UPDATE A 
                   SET A.NRDITAR = B.NRRENDOR 
                  FROM '+@TableScrName+' A INNER JOIN ' + @Ditar +' B ON A.NRRENDOR = B.TAGNR  
                 WHERE A.NRD='+@sNrRendor+' AND B.TRANNUMBER='''+@TranNumber+''' ;

                UPDATE '+@Ditar+' SET TAGNR=0,TRANNUMBER='''' WHERE TRANNUMBER='''+@TranNumber+'''; ';

         SET  @SqlFilterUn2  = @SqlFilterUn1; 
         SET  @SqlFilterUn2  = REPLACE(@SqlFilterUn2,'A.KURS1','CASE WHEN LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' THEN 1 ELSE A.KURS1 END');
         SET  @SqlFilterUn2  = REPLACE(@SqlFilterUn2,'A.KURS2','CASE WHEN LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' THEN 1 ELSE A.KURS2 END');
         Exec(@SqlFilterUn2);

         SET  @SqlFilterUn2  = @SqlFilterUn1; 
         SET  @SqlFilterUn2  = REPLACE(@SqlFilterUn2,'A.KURS1','CASE WHEN LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' THEN 1 ELSE A.KURS1 END');
         SET  @SqlFilterUn2  = REPLACE(@SqlFilterUn2,'A.KURS2','CASE WHEN LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' THEN 1 ELSE A.KURS2 END');
         SET  @SqlFilterUn2  = REPLACE(@SqlFilterUn2,' DFU ',' DKL ');
         SET  @SqlFilterUn2  = REPLACE(@SqlFilterUn2,'TIPKLL=''F''','TIPKLL=''S''');
         Exec(@SqlFilterUn2);

       END;


    --       FJ

    IF @TableName='FJ'

       BEGIN

       -- Koka e Dokumentit
         
         SET    @ParaPg       = ISNULL( ( SELECT PARAPG = CASE WHEN ISNULL(NRRENDORAR,0)<>0 THEN 0 ELSE ISNULL(PARAPG,0) END 
                                            FROM FJ 
                                           WHERE NRRENDOR=@NrRendor),0);

         SELECT @PromocNdarje = ISNULL(NDARJEPROMOCFJ,0) FROM CONFIGMG;

         SET  @Treg1DK = '''D''';
         SET  @Treg2DK = '''K''';
         SET  @Field   = ' SUM(CASE WHEN ISNULL(B.PROMOC,0)=0 THEN ISNULL(B.VLPATVSH,0) ELSE 0 END - ISNULL(B.VLERAFR,0)) -
                               
                           MAX(ISNULL(A.VLERZBR,0)) + 
                           
                           CASE WHEN MAX(ISNULL(A.VLERZBR,0))=0 THEN SUM(ISNULL(B.VLTVSH,0)) ELSE MAX(ISNULL(A.VLTVSH,0)) END ';
         SET  @FieldMV = '(SUM(CASE WHEN ISNULL(B.PROMOC,0)=0   THEN ISNULL(B.VLPATVSH,0)    ELSE 0 END - ISNULL(B.VLERAFR,0)) -
                               
                           MAX(ISNULL(A.VLERZBR,0)) + 
                           
                           CASE WHEN MAX(ISNULL(A.VLERZBR,0))=0 THEN SUM(ISNULL(B.VLTVSH,0)) ELSE MAX(ISNULL(A.VLTVSH,0)) END)* MAX(A.KURS2)/MAX(A.KURS1) ';

         IF @PromocNdarje=1						--  NdarjePromoc
            BEGIN
              SET @Field   = REPLACE(@Field,  'ISNULL(B.PROMOC,0)=0','1=1');
              SET @FieldMV = REPLACE(@FieldMV,'ISNULL(B.PROMOC,0)=0','1=1');
            END;

         SET  @SqlFilterUn1 = '
               DECLARE @NewID        Int,
                       @RowCount     Int;  

                INSERT INTO '+@Ditar+'
                      (KOD,PERSHKRIM,KOMENT,TIPDOK,TREGDK,
                       NRDITAR,NRDOK,FRAKSDOK,DATEDOK,NRFAT,DTFAT,TIPFAT,
                       KMON,VLEFTA,VLEFTAMV,KURS1,KURS2,
                       KODMASTER,ISDOKSHOQ,TAGNR,TIPKLL,NRRENDORDOK,ORG,LLOJDOK,TRANNUMBER) 
                SELECT MAX(LTRIM(RTRIM(A.KODFKL))+''.''+LTRIM(RTRIM(ISNULL(A.KMON,'''')))),MAX(A.SHENIM1),MAX(A.SHENIM3),'''+@TableName+''','+@Treg1DK+',
                       A.NRRENDOR,MAX(A.NRDOK),0,MAX(A.DATEDOK),
                       CASE WHEN MAX(ISNULL(A.LLOJDOK,''''))=''H'' THEN MAX(ISNULL(A.NRFATST,'''')) ELSE MAX(ISNULL(A.NRDSHOQ,A.DATEDOK)) END,
                       CASE WHEN MAX(ISNULL(A.LLOJDOK,''''))=''H'' THEN MAX(ISNULL(A.DTFATST,0))    ELSE MAX(ISNULL(A.DTDSHOQ,A.DATEDOK)) END,'''+@TableName+''',
                       MAX(LTRIM(RTRIM(ISNULL(A.KMON,'''')))),
                       ROUND(0,3), 
                       ROUND(1,3),
                       MAX(A.KURS1),
                       MAX(A.KURS2),
                       MAX(A.KODFKL),ISNULL(A.ISDOKSHOQ,0),0,'''',A.NRRENDOR,'''+@Tip+''',
                       MAX(ISNULL(A.LLOJDOK,'''')),'''+@TranNumber+''' 
                  FROM '+@TableName+' A LEFT JOIN '+@TableScrName+' B ON A.NRRENDOR=B.NRD  
                 WHERE A.NRRENDOR = '+@sNrRendor+' AND 1=1 AND ISNULL(B.ISAMB,0)=0   -- 04.05.2015 -- Amballazh i kthyeshem
              GROUP BY A.NRRENDOR,ISNULL(A.ISDOKSHOQ,0) 
                HAVING ABS(ROUND(100,3))>=0.01 ; -- Te diskutohet per rjeshta me vlera 0

                   SET @RowCount=@@ROWCOUNT;
                    IF @RowCount<>0
                       BEGIN
                         SELECT @NewID=@@IDENTITY;  
                         UPDATE '+@TableName+' SET NRDITAR=@NewID WHERE NRRENDOR='+@sNrRendor+';
                       END; ';

         SET  @SqlFilterUn2  = REPLACE(@SqlFilterUn1,'ROUND(0,3)','ROUND('+@Field  +',3)');
         SET  @SqlFilterUn2  = REPLACE(@SqlFilterUn2,'ROUND(1,3)','ROUND('+@FieldMV+',3)');
         SET  @SqlFilterUn2  = REPLACE(@SqlFilterUn2,'A.KURS1','CASE WHEN LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' THEN 1 ELSE A.KURS1 END');
         SET  @SqlFilterUn2  = REPLACE(@SqlFilterUn2,'A.KURS2','CASE WHEN LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' THEN 1 ELSE A.KURS2 END');
         Exec(@SqlFilterUn2);

         IF @PromocNdarje=1						--  NdarjePromoc  Promocion rrjesht me vete
            BEGIN
              SET  @Field         = ' SUM(ISNULL(B.VLPATVSH,0)+ISNULL(B.VLTVSH,0)) ';
              SET  @FieldMV       = '(SUM(ISNULL(B.VLPATVSH,0)+ISNULL(B.VLTVSH,0))* MAX(A.KURS2)/MAX(A.KURS1)) ';

              SET  @SqlFilterUn2  = REPLACE(@SqlFilterUn1, @Treg1DK, @Treg2DK);
              SET  @SqlFilterUn2  = REPLACE(@SqlFilterUn2,'ROUND(0,3)','ROUND('+@Field  +',3)');
              SET  @SqlFilterUn2  = REPLACE(@SqlFilterUn2,'ROUND(1,3)','ROUND('+@FieldMV+',3)');

              SET  @SqlFilterUn2  = REPLACE(@SqlFilterUn2,'1=1', 'ISNULL(B.PROMOC,0)=1 AND A.NRDITARPRMC=0');
              SET  @SqlFilterUn2  = REPLACE(@SqlFilterUn2,'MAX(A.SHENIM3)',   '''Promocion FJ nr ''+MAX(ISNULL(A.NRDSHOQ,''''))+'', dt.''+MAX(CONVERT(CHAR(12),ISNULL(A.DTDSHOQ,A.DATEDOK))) ');
              SET  @SqlFilterUn2  = REPLACE(@SqlFilterUn2,'SET A.NRDITAR',    'SET A.NRDITARPRMC');

              SET  @SqlFilterUn2  = REPLACE(@SqlFilterUn2,'A.KURS1','CASE WHEN LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' THEN 1 ELSE A.KURS1 END');
              SET  @SqlFilterUn2  = REPLACE(@SqlFilterUn2,'A.KURS2','CASE WHEN LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' THEN 1 ELSE A.KURS2 END');
              Exec(@SqlFilterUn2);
            END;

     

         IF @ParaPg<>0                          --	Rasti Likujdim parapagese FJ
            BEGIN

              SET  @SqlFilterUn1 = '
               DECLARE @NewID        Int,
                       @RowCount     Int; 

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
                       KODFKL,0,'''',NRRENDOR,'''+@Tip+''',LLOJDOK,'''+@TranNumber+''' 
                  FROM '+@TableName+' A
                 WHERE NRRENDOR='+@sNrRendor+' AND (ISNULL(PARAPG,0)<>0 AND ISNULL(A.NRRENDORAR,0)=0) ;

                   SET @RowCount=@@ROWCOUNT;
                    IF @RowCount<>0
                       BEGIN
                         SELECT @NewID=@@IDENTITY;  
                         UPDATE '+@TableName+' SET NRDITARSHL=@NewID WHERE NRRENDOR='+@sNrRendor+';
                       END; '; 

              SET  @SqlFilterUn2  = @SqlFilterUn1; 
              SET  @SqlFilterUn2  = REPLACE(@SqlFilterUn2,'A.KURS1','CASE WHEN LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' THEN 1 ELSE A.KURS1 END');
              SET  @SqlFilterUn2  = REPLACE(@SqlFilterUn2,'A.KURS2','CASE WHEN LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' THEN 1 ELSE A.KURS2 END');
              Exec(@SqlFilterUn2);

            END;


         --       Rrjeshta

         SET @SqlFilterUn1 = ' 
                INSERT INTO ' + @Ditar + '                     
                      (KOD,PERSHKRIM,KOMENT,TIPDOK,TREGDK, 
                       NRDITAR,NRDOK,FRAKSDOK,DATEDOK,NRFAT,DTFAT,TIPFAT,
                       KMON,VLEFTA,VLEFTAMV,KURS1,KURS2,
                       KODMASTER,ISDOKSHOQ,TAGNR,TIPKLL,NRRENDORDOK,ORG,LLOJDOK,TRANNUMBER )
                SELECT LTRIM(RTRIM(B.KOD)),B.PERSHKRIM,B.KOMENT,'''+@TableName+''',''D'',
                       B.NRDITAR,A.NRDOK,0,A.DATEDOK,B.NRDOKREF,B.DATEDOKREF,B.TIPREF,
                       LTRIM(RTRIM(ISNULL(A.KMON,''''))),
                       0-B.VLERABS,
                       0-ROUND(CASE WHEN A.KURS2=0 THEN 0 ELSE (B.VLERABS*A.KURS2)/A.KURS1 END,3),
                       A.KURS1, 
                       A.KURS2, 
                       KODFKL,0,B.NRRENDOR,B.TIPKLL,A.NRRENDOR,'''+@Tip+''',A.LLOJDOK,'''+@TranNumber+'''
                  FROM '+@TableName+' A INNER JOIN '+@TableScrName+' B ON A.NRRENDOR=B.NRD 
                 WHERE A.NRRENDOR='+@sNrRendor+' AND TIPKLL=''S'' ; 

                UPDATE A 
                   SET A.NRDITAR = B.NRRENDOR 
                  FROM '+@TableScrName+' A INNER JOIN ' + @Ditar +' B ON A.NRRENDOR = B.TAGNR  
                 WHERE A.NRD='+@sNrRendor+' AND B.TRANNUMBER='''+@TranNumber+''' ;

                UPDATE '+@Ditar+' SET TAGNR=0,TRANNUMBER='''' WHERE TRANNUMBER='''+@TranNumber+'''; ';

         SET  @SqlFilterUn2  = @SqlFilterUn1; 
         SET  @SqlFilterUn2  = REPLACE(@SqlFilterUn2,'A.KURS1','CASE WHEN LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' THEN 1 ELSE A.KURS1 END');
         SET  @SqlFilterUn2  = REPLACE(@SqlFilterUn2,'A.KURS2','CASE WHEN LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' THEN 1 ELSE A.KURS2 END');
         Exec(@SqlFilterUn2);

         SET  @SqlFilterUn2  = @SqlFilterUn1; 
         SET  @SqlFilterUn2  = REPLACE(@SqlFilterUn2,'A.KURS1','CASE WHEN LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' THEN 1 ELSE A.KURS1 END');
         SET  @SqlFilterUn2  = REPLACE(@SqlFilterUn2,'A.KURS2','CASE WHEN LTRIM(RTRIM(ISNULL(A.KMON,'''')))='''' THEN 1 ELSE A.KURS2 END');
         SET  @SqlFilterUn2  = REPLACE(@SqlFilterUn2,' DKL ',' DFU ');
         SET  @SqlFilterUn2  = REPLACE(@SqlFilterUn2,'TIPKLL=''S''','TIPKLL=''F''');
         Exec(@SqlFilterUn2);


       END;

-- 2     ***** Fund shtim ne ditare *****



-- 3     ***** Shtim ne Libra *****

      SET @SqlFilterUn1 = '  

                INSERT INTO LAR  
                      (KOD,PERSHKRIM,KMON,SG1,SG2,SG3,SG4,SG5,SG6,SG7,SG8,SG9,SG10,TROW,TAGNR)
                SELECT A.KOD,
                       PRS   = ( SELECT TOP 1 PERSHKRIM
                                   FROM ARKAT A1
                                  WHERE A1.KOD=CASE WHEN CHARINDEX (''.'',A.KOD)>0 THEN LEFT(A.KOD,CHARINDEX (''.'',A.KOD)-1) ELSE A.KOD END
                                ),
                       KMON  = LTRIM(RTRIM(ISNULL(A.KMON,''''))),
                       SG1   = CASE WHEN CHARINDEX (''.'',A.KOD)>0 THEN LEFT(A.KOD,CHARINDEX (''.'',A.KOD)-1) ELSE A.KOD END,
                       SG2   = '''', SG3='''', SG5='''',SG5=LTRIM(RTRIM(ISNULL(A.KMON,''''))),SG6='''', SG7='''', SG8='''', SG9='''', SG10='''', TROW=0, TAGNR=0
                  FROM '+@TableName+' A0 INNER JOIN '+@TableScrName+' A ON A0.NRRENDOR=A.NRD
                                         INNER JOIN ARKAT B ON A.LLOGARIPK = B.KOD 
                 WHERE (A.NRD='+@sNrRendor+' AND A.TIPKLL=''A'') AND (NOT EXISTS ( SELECT KOD FROM LAR L WHERE L.KOD=A.KOD ) )
              ORDER BY A.KOD;';

      IF @TableName='FJ' OR @TableName='FF'
         BEGIN
           SET   @SqlFilterUn1 = REPLACE(@SqlFilterUn1,'A.KMON','A0.KMON');
         END;


      Exec (@SqlFilterUn1);

      SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn1,' DAR',' DBA');
      SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn2,' LAR',' LBA');
      SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn2,' ARKAT',' BANKAT');
      SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn2,'=''A''','=''B''');
      Exec (@SqlFilterUn2);

      SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn1,' DAR',' DFU');
      SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn2,' LAR',' LFU');
      SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn2,' ARKAT',' FURNITOR');
      SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn2,'=''A''','=''F''');
      Exec (@SqlFilterUn2);

      SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn1,' DAR',' DKL');
      SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn2,' LAR',' LKL');
      SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn2,' ARKAT',' KLIENT');
      SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn2,'=''A''','=''S''');
      Exec (@SqlFilterUn2);




-- Shtimi i Dokumentit tek Librat ....

      SET @SqlFilterUn1 = '  

                INSERT INTO LAR  
                      (KOD,PERSHKRIM,KMON,SG1,SG2,SG3,SG4,SG5,SG6,SG7,SG8,SG9,SG10,TROW,TAGNR)
                SELECT KOD   = LTRIM(RTRIM(A.KODAB))+''.''+LTRIM(RTRIM(ISNULL(A.KMON,''''))),
                       PRS   = ( SELECT TOP 1 PERSHKRIM FROM ARKAT A1 WHERE A1.KOD=A.KODAB ),
                       KMON  = LTRIM(RTRIM(ISNULL(A.KMON,''''))),
                       SG1   = A.KODAB, SG2='''', SG3='''', SG4='''', SG5=LTRIM(RTRIM(ISNULL(A.KMON,''''))), SG6='''', SG7='''', SG8='''', SG9='''', SG10='''', TROW=0, TAGNR=0
                  FROM '+@TableName+' A 
                 WHERE (A.NRRENDOR='+@sNrRendor+') AND 
                       (NOT EXISTS ( SELECT KOD 
                                       FROM LAR L 
                                      WHERE LTRIM(RTRIM(L.KOD))=LTRIM(RTRIM(A.KODAB))+''.''+LTRIM(RTRIM(ISNULL(A.KMON,'''')))
                                    )
                        ) ';



      IF @TableName='ARKA'
         BEGIN
           SET   @SqlFilterUn2 = @SqlFilterUn1
           EXEC (@SqlFilterUn2);
         END;

      IF @TableName='BANKA'
         BEGIN
           SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn1,' LAR',' LBA')
           SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn2,' ARKAT',' BANKAT');
           EXEC (@SqlFilterUn2);
         END;

      IF @TableName='FJ'
         BEGIN
           SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn1,' LAR',' LKL')
           SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn2,' ARKAT',' KLIENT');
           SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn2,'A.KODAB','A.KODFKL');
           EXEC (@SqlFilterUn2);
         END;

      IF @TableName='FF'
         BEGIN
           SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn1,' LAR',' LFU')
           SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn2,' ARKAT',' FURNITOR');
           SET   @SqlFilterUn2 = REPLACE(@SqlFilterUn2,'A.KODAB','A.KODFKL');
           EXEC (@SqlFilterUn2);
         END;

-- 3     ***** Fund shtim ne libra *****
GO
