SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





-- Exec [Isd_GjenerimDitar] 
--                  @PDateKp = '01/03/2010',
--                  @PDateKs = '31/03/2010',
--                  @PTip    = 'A',
--                  @PForce  = '1'

CREATE         Procedure [dbo].[Isd_CreateDitar]
(
  @PDateKp    Varchar(20),
  @PDateKs    Varchar(20),
  @PTip       Varchar(10),
  @PForce     Varchar(1),
  @PNrRendor  Int
 )

As

     Set NoCount On
 
 Declare @SqlFilter    Varchar(5000),
         @SqlFilterUn1 Varchar(5000),
         @SqlFilterUn2 Varchar(5000),
         @SqlFilterDit Varchar(5000),
         @VSql         Varchar(200),
         @Ditar        Varchar(30),
         @Liber        Varchar(30),
         @Document     Varchar(30),
         @ProcUnion    Varchar(30),
         @Table        Varchar(20),
         @Treg1DK      Varchar(5),
         @Treg2DK      Varchar(5),
         @Field        Varchar(5000),
         @FieldMV      Varchar(5000),
         @LidhezAnd    Varchar(20),
         @NdarjePromoc Bit

     Set @PDateKp       = QuoteName(@PDateKp,'''')
     Set @PDateKs       = QuoteName(@PDateKs,'''')
     Set @SqlFilter     = ' (DATEDOK>=DBO.DATEVALUE('+@PDateKp+') AND DATEDOK<=DBO.DATEVALUE('+@PDateKs+'))'
     Set @SqlFilterDit  = Replace(@SqlFilter,'DATEDOK','A.DATEDOK')
     
     if  @PTip='A'
         Begin
           Set @Ditar     = 'DAR'
           Set @Liber     = 'LAR'
           Set @Document  = 'ARKA'
           Set @ProcUnion = 'T_DOKDIT_AR'
         End
     else
     if  @PTip='B'
         Begin
           Set @Ditar     = 'DBA'
           Set @Liber     = 'LBA'
           Set @Document  = 'BANKA'
           Set @ProcUnion = 'T_DOKDIT_BA'
         End
     else
     if  @PTip='S'
         Begin
           Set @Ditar     = 'DKL'
           Set @Liber     = 'LKL'
           Set @Document  = 'FJ'
           Set @ProcUnion = 'T_DOKDIT_KL'
         End
     else
     if  @PTip='F'
         Begin
           Set @Ditar     = 'DFU'
           Set @Liber     = 'LFU'
           Set @Document  = 'FF'
           Set @ProcUnion = 'T_DOKDIT_FU'
         End

-- GJENERIM ME FORCE								Fshirje Ditar

    if @PForce='1'

       Begin
         Set @LidhezAnd    = ''
         Set @SqlFilterUn1 = @SqlFilter
         if  @SqlFilter<>'' 
             Set @LidhezAnd = ' AND '

         Exec (' DELETE FROM '+@Ditar+' WHERE 1=1 '+@LidhezAnd+@SqlFilterUn1+'                
                 UPDATE '+@Document+' 
                    SET NRDITAR=0 
                  WHERE NRDITAR<>0 '+@LidhezAnd+@SqlFilterUn1)

         if @PTip='S'
            Exec(' UPDATE '+@Document+' 
                      SET NRDITARSHL=0, NRDITARPRMC=0 
                   WHERE (NRDITARPRMC<>0 OR NRDITARSHL<>0) '+@LidhezAnd+@SqlFilterUn1 + '

                  UPDATE B 
                     SET B.NRDITAR=0 
                    FROM '+@Document+' A INNER JOIN '+@Document+'SCR B ON A.NRRENDOR=B.NRD 
                   WHERE (B.NRDITAR<>0) '+@LidhezAnd+@SqlFilterUn1)

         else
         if @PTip='F' 
            Exec ('  UPDATE '+@Document+' 
                        SET NRDITARSHL=0 
                      WHERE (NRDITARSHL<>0) '+@LidhezAnd+@SqlFilterUn1)

         Set  @VSql = ' (TIPKLL = ' + QuoteName(@PTip,'''')+') '
         Exec (' UPDATE B SET B.NRDITAR=0 
                   FROM VS    A INNER JOIN VSSCR    B ON A.NRRENDOR=B.NRD 
                  WHERE '+@VSql+' AND (B.NRDITAR<>0) '+@LidhezAnd+@SqlFilterUn1+'

                 UPDATE B SET B.NRDITAR=0 
                   FROM ARKA  A INNER JOIN ARKASCR  B ON A.NRRENDOR=B.NRD 
                  WHERE '+@VSql+' AND (B.NRDITAR<>0) '+@LidhezAnd+@SqlFilterUn1+'

                 UPDATE B SET B.NRDITAR=0 
                   FROM BANKA A INNER JOIN BANKASCR B ON A.NRRENDOR=B.NRD 
                  WHERE '+@VSql+' AND (B.NRDITAR<>0) '+@LidhezAnd+@SqlFilterUn1)
       End
-- GJENERIM ME FORCE								FUND


-- Fshihen Rrjeshta Ditar per ato qe nuk lidhen me Dokumenta....

    Exec(' DELETE FROM '+@Ditar+' WHERE (DATEDOK IS NULL) 

           DELETE FROM '+@Ditar+'  
            WHERE '+@SQLFilter+' AND (TIPDOK<>''SP'') AND 
                 ((SELECT COUNT(*) FROM '+@ProcUnion+' B WHERE B.NRDITAR='+@Ditar+'.NRRENDOR))<>1

           UPDATE A 
              SET NRDITAR=0 
             FROM '+@Document+' A 
            WHERE '+@SQLFilter+' AND ((NRDITAR Is Null) OR (NRDITAR>0)) AND 
                  (NOT( EXISTS (SELECT NRRENDOR 
                                  FROM '+@Ditar+' B 
                                 WHERE B.NRRENDOR = A.NRDITAR))) ')

    if @PTip = 'S'

       Begin
         Exec( ' UPDATE '+@Document   +' 
                    SET VLERZBR=ISNULL(VLERZBR,0), PERQZBR=ISNULL(PERQZBR,0)
                  WHERE (VLERZBR Is Null) OR (PERQZBR Is Null)
               
                 UPDATE A						-- Pagese nga Fatura per Autpasion
                    SET NRDITARSHL=0 
                   FROM '+@Document   + ' A
                  WHERE ISNULL(NRDITARSHL,0)<>0 AND '+@SQLFilter  + ' AND (NOT( EXISTS (SELECT NRRENDOR FROM '+@Ditar+' B WHERE B.NRRENDOR = A.NRDITARSHL)))

                 UPDATE A                      -- Ditar nga Fatura per Promocion
                    SET  NRDITARPRMC = 0 
                   FROM '+@Document  + ' A 
                  WHERE ISNULL(NRDITARPRMC,0)<>0 AND '+@SQLFilter + ' AND (NOT( EXISTS (SELECT NRRENDOR FROM '+@Ditar+' B WHERE B.NRRENDOR = A.NRDITARPRMC)))

                 UPDATE B                  -- Ditar nga Fatura-Rrjeshta per klientin per rrjeshtat ku TIPKLL=''S''
                    SET B.NRDITAR = 0  
                   FROM '+@Document  + ' A LEFT JOIN '+@Document+'SCR B ON A.NRRENDOR = B.NRD 
                  WHERE '+@SQLFilter + ' AND (TIPKLL='''+@PTip+''') AND ISNULL(B.NRDITAR,0)<>0 AND (NOT( EXISTS (SELECT NRRENDOR  FROM '+@Ditar+' C WHERE C.NRRENDOR = B.NRDITAR)))')

       End

    else 

    if @PTip = 'F'
       Begin
         Exec( 'UPDATE A  
                   SET NRDITARSHL=0 
                  FROM ' + @Document  + ' A
                 WHERE ISNULL(NRDITARSHL,0)<>0 AND ' + @SQLFilter + ' AND (NOT( EXISTS (SELECT NRRENDOR FROM '+@Ditar+' B WHERE B.NRRENDOR = A.NRDITARSHL))) ')
       End   

    Exec(' UPDATE A
              SET NRDITAR = 0 
             FROM ARKASCR A INNER JOIN ARKA B ON A.NRD=B.NRRENDOR
            WHERE (A.TIPKLL='''+@PTip+''') AND ISNULL(A.NRDITAR,0)<>0 AND '+@SQLFilter+' AND
                  (NOT (EXISTS (SELECT NRRENDOR FROM '+@Ditar+' C WHERE C.NRRENDOR = A.NRDITAR)))
           UPDATE A
              SET NRDITAR = 0 
             FROM BANKASCR A INNER JOIN BANKA B ON A.NRD=B.NRRENDOR
            WHERE (A.TIPKLL='''+@PTip+''') AND ISNULL(A.NRDITAR,0)<>0 AND '+@SQLFilter+' AND
                  (NOT (EXISTS (SELECT NRRENDOR FROM '+@Ditar+' C WHERE C.NRRENDOR = A.NRDITAR)))
           UPDATE A
              SET NRDITAR = 0 
             FROM VSSCR A INNER JOIN VS B ON A.NRD=B.NRRENDOR
            WHERE (A.TIPKLL='''+@PTip+''') AND ISNULL(A.NRDITAR,0)<>0 AND '+@SQLFilter+' AND
                  (NOT (EXISTS (SELECT NRRENDOR FROM '+@Ditar+' C WHERE C.NRRENDOR = A.NRDITAR)))') 



-- GJENERIMI I RRJESHTAVE DITAR						Shtimi ne Ditar

-- Shtim ne Ditar nga Dokument (Kokat)

    Exec(' UPDATE ' + @Ditar + ' SET TAGNR=0, ORG='''' WHERE TAGNR<>0 OR ORG<>''''') 

    if @Ptip ='A' or @PTip = 'B'

       Begin
         Exec(' INSERT INTO ' + @Ditar + '
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
                       KODAB,0,NRRENDOR,'''+@PTip+''',''''
                  FROM '+@Document+' A
                 WHERE A.NRDITAR=0 OR (NOT (EXISTS (SELECT NRRENDOR FROM '+@Ditar+' B WHERE B.NRRENDOR = A.NRDITAR)))   

                UPDATE A 
                   SET A.NRDITAR = B.NRRENDOR 
                  FROM '+@Document+' A INNER JOIN ' + @Ditar +' B ON A.NRRENDOR = B.TAGNR  
                 WHERE '+@SqlFilterDit+' AND (B.TAGNR<>0) AND (B.ORG='''+@PTip+''') 
                UPDATE '+@Ditar+' SET TAGNR=0, ORG='''' WHERE ISNULL(TAGNR,0)<>0 OR ORG<>''''') 
       End

    if @PTip='F' 
       Begin
         Set  @Treg1DK      = '''K'''
         Set  @Treg2DK      = '''D'''
         Set  @SqlFilterUn1 = ' INSERT INTO '+@Ditar+'
                                      (KOD,PERSHKRIM,KOMENT,TIPDOK,TREGDK,
                                       NRDITAR,NRDOK,FRAKSDOK,DATEDOK,NRFAT,DTFAT,TIPFAT,
                                       KMON,VLEFTA,VLEFTAMV,KURS1,KURS2,
                                       KODMASTER,TAGNR,ORG,LLOJDOK )
                                SELECT KODFKL+''.''+KMON,SHENIM1,SHENIM3,'''+@Document+''','+@Treg1DK+',
                                       NRRENDOR,NRDOK,0,DATEDOK,ISNULL(NRDSHOQ,''''),DTDSHOQ,'''+@Document+''',
                                       KMON,VLERTOT,ROUND(VLERTOT*KURS2/KURS1,3),KURS1,KURS2,
                                       KODFKL,NRRENDOR,'''+@PTip+''',LLOJDOK 
                                  FROM '+@Document+' A
                                 WHERE (A.NRDITAR=0 OR (NOT (EXISTS (SELECT NRRENDOR FROM '+@Ditar+' B WHERE B.NRRENDOR = A.NRDITAR)))) 

                                UPDATE A 
                                   SET A.NRDITAR = B.NRRENDOR 
                                  FROM '+@Document+' A INNER JOIN ' + @Ditar +' B ON A.NRRENDOR = B.TAGNR  
                                 WHERE '+@SqlFilterDit+' AND (B.TAGNR<>0) AND (B.ORG='''+@PTip+''') 
                                UPDATE '+@Ditar+' SET TAGNR=0, ORG='''' WHERE ISNULL(TAGNR,0)<>0 OR ORG<>'''' '
         Exec(@SqlFilterUn1)

--													Rasti Likujdim parapagese FF
         Set  @SqlFilterUn1 = Replace(@SqlFilterUn1,'VLERTOT','PARAPG')
         Set  @SqlFilterUn1 = Replace(@SqlFilterUn1,'WHERE (A.NRDITAR=0','WHERE (ISNULL(A.PARAPG,0)<>0) AND (A.NRDITAR=0')
         Set  @SqlFilterUn1 = Replace(@SqlFilterUn1,@Treg1DK,@Treg2DK)
         Set  @SqlFilterUn1 = Replace(@SqlFilterUn1,'SHENIM3','SHENIM3+''/Shlyerje''')
         Set  @SqlFilterUn1 = Replace(@SqlFilterUn1,'A.NRDITAR','A.NRDITARSHL')
         Exec(@SqlFilterUn1)
       End

    if (@PTip='S') 

       Begin
         SELECT @NdarjePromoc = ISNULL(NDARJEPROMOCFJ,0) FROM CONFIGMG

         Set  @Treg1DK = '''D'''
         Set  @Treg2DK = '''K'''
         Set  @Field   = ' SUM(CASE WHEN ISNULL(B.PROMOC,0)=0 
                                    THEN ISNULL(B.VLPATVSH,0)+ISNULL(B.VLTVSH,0)
                                    ELSE 0 END - 
                               ISNULL(B.VLERAFR,0)) -
                           MAX(ISNULL(A.VLERZBR,0)) '
         Set  @FieldMV = '(SUM(CASE WHEN ISNULL(B.PROMOC,0)=0 
                                   THEN ISNULL(B.VLPATVSH,0)+ISNULL(B.VLTVSH,0)
                                   ELSE 0 END - 
                               ISNULL(B.VLERAFR,0)) -
                           MAX(ISNULL(A.VLERZBR,0)))* MAX(KURS2)/MAX(KURS1) '

         if @NdarjePromoc=1						--  NdarjePromoc
            Begin
              Set @Field   = Replace(@Field,  'ISNULL(B.PROMOC,0)=0','1=1')
              Set @FieldMV = Replace(@FieldMV,'ISNULL(B.PROMOC,0)=0','1=1')
            End

         Set  @SqlFilterUn1 = '   INSERT INTO '+@Ditar+'
                                        (KOD,PERSHKRIM,KOMENT,TIPDOK,TREGDK,
                                         NRDITAR,NRDOK,FRAKSDOK,DATEDOK,NRFAT,DTFAT,TIPFAT,
                                         KMON,VLEFTA,VLEFTAMV,KURS1,KURS2,
                                         KODMASTER,ISDOKSHOQ,TAGNR,ORG,LLOJDOK) 
                                  SELECT MAX(A.KODFKL+''.''+ISNULL(A.KMON,'''')),MAX(A.SHENIM1),MAX(A.SHENIM3),'''+@Document+''','+@Treg1DK+',
                                         A.NRRENDOR,MAX(A.NRDOK),0,MAX(A.DATEDOK),
                                         CASE WHEN MAX(ISNULL(A.LLOJDOK,''''))=''H'' THEN MAX(ISNULL(A.NRFATST,'''')) ELSE MAX(ISNULL(A.NRDSHOQ,A.DATEDOK)) END,
                                         CASE WHEN MAX(ISNULL(A.LLOJDOK,''''))=''H'' THEN MAX(ISNULL(A.DTFATST,0))    ELSE MAX(ISNULL(A.DTDSHOQ,A.DATEDOK)) END,'''+@Document+''',
                                         MAX(ISNULL(A.KMON,'''')),
                                         ROUND(0,3), ROUND(1,3),
                                         MAX(A.KURS1),MAX(A.KURS2),
                                         MAX(A.KODFKL),ISNULL(A.ISDOKSHOQ,0),A.NRRENDOR,'''+@PTip+''',
                                         MAX(ISNULL(A.LLOJDOK,'''')) 
                                    FROM '+@Document+' A LEFT JOIN '+@Document+'Scr B ON A.NRRENDOR=B.NRD  
                                   WHERE ((A.NRDITAR=0) OR (NOT (EXISTS (SELECT NRRENDOR FROM '+@Ditar+' C WHERE C.NRRENDOR = A.NRDITAR)))) 
                                GROUP BY A.NRRENDOR,ISNULL(A.ISDOKSHOQ,0) 
                                  HAVING ABS(ROUND(0,3))>=0.01

                                  UPDATE A 
                                     SET A.NRDITAR = B.NRRENDOR 
                                    FROM '+@Document+' A INNER JOIN ' + @Ditar +' B ON A.NRRENDOR = B.TAGNR  
                                   WHERE '+@SqlFilterDit+' AND (B.TAGNR<>0) AND (B.ORG='''+@PTip+''') 

                                 UPDATE '+@Ditar+' SET TAGNR=0, ORG='''' WHERE ISNULL(TAGNR,0)<>0 OR ORG<>'''' '


         Set  @SqlFilterUn2  = Replace(@SqlFilterUn1,'ROUND(0,3)','ROUND('+@Field  +',3)')
         Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'ROUND(1,3)','ROUND('+@FieldMV+',3)')
         Exec(@SqlFilterUn2)

         if @NdarjePromoc=1						--  NdarjePromoc  Promocion rrjesht me vete
            Begin
              Set  @Field         = ' SUM(ISNULL(B.VLPATVSH,0)+ISNULL(B.VLTVSH,0)) '
              Set  @FieldMV       = '(SUM(ISNULL(B.VLPATVSH,0)+ISNULL(B.VLTVSH,0))* MAX(KURS2)/MAX(KURS1)) '

              Set  @SqlFilterUn2  = Replace(@SqlFilterUn2, @Treg1DK, @Treg2DK)
              Set  @SqlFilterUn2  = Replace(@SqlFilterUn1,'ROUND(0,3)','ROUND('+@Field  +',3)')
              Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'ROUND(1,3)','ROUND('+@FieldMV+',3)')

              Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,' ((A.NRDITAR=0) ', '  ISNULL(B.PROMOC,0)=1 AND ((A.NRDITARPRMC=0)')
              Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'MAX(A.SHENIM3)',   '''Promocion FJ nr ''+MAX(ISNULL(A.NRDSHOQ,''''))+'', dt.''+MAX(CONVERT(CHAR(12),ISNULL(A.DTDSHOQ,A.DATEDOK))) ')
              Set  @SqlFilterUn2  = Replace(@SqlFilterUn2,'SET A.NRDITAR',    'SET A.NRDITARPRMC')
              Exec(@SqlFilterUn2)
            End
--													Rasti Likujdim parapagese FJ
         Set  @SqlFilterUn1 = ' INSERT INTO '+@Ditar+'
                                      (KOD,PERSHKRIM,KOMENT,TIPDOK,TREGDK,
                                       NRDITAR,NRDOK,FRAKSDOK,DATEDOK,NRFAT,DTFAT,TIPFAT,
                                       KMON,VLEFTA,VLEFTAMV,KURS1,KURS2,
                                       KODMASTER,TAGNR,ORG,LLOJDOK )
                                SELECT KODFKL+''.''+KMON,SHENIM1,SHENIM3+''/Shlyerje'','''+@Document+''',''K'',
                                       NRRENDOR,NRDOK,0,DATEDOK,ISNULL(NRDSHOQ,''''),DTDSHOQ,'''+@Document+''',
                                       KMON,PARAPG,ROUND(PARAPG*KURS2/KURS1,3),KURS1,KURS2,
                                       KODFKL,NRRENDOR,'''+@PTip+''',LLOJDOK 
                                  FROM '+@Document+' A
                                 WHERE (ISNULL(PARAPG,0)<>0) AND (A.NRDITARSHL=0 OR (NOT (EXISTS (SELECT NRRENDOR FROM '+@Ditar+' B WHERE B.NRRENDOR = A.NRDITARSHL)))) 

                                UPDATE A 
                                   SET A.NRDITARSHL = B.NRRENDOR 
                                  FROM '+@Document+' A INNER JOIN ' + @Ditar +' B ON A.NRRENDOR = B.TAGNR  
                                 WHERE '+@SqlFilterDit+' AND (B.TAGNR<>0) AND (B.ORG='''+@PTip+''') 
                                UPDATE '+@Ditar+' SET TAGNR=0, ORG='''' WHERE ISNULL(TAGNR,0)<>0 OR ORG<>'''' '
         Exec(@SqlFilterUn1)

       End
-- Shtim ne Ditar nga Dokumenta- Kokat			    Fund


-- Shtim ne Ditar nga Dokumenta- Rrjeshta			Ditari nga Rrjeshtat

    Set  @Table = 'ARKA'
    Exec(' UPDATE A
              SET NRDITAR = 0 
             FROM ' + @Table + 'Scr A
            WHERE TIPKLL='''+@PTip+''' AND A.NRDITAR<>0 AND 
                 (NOT (EXISTS (SELECT NRRENDOR FROM '+@Ditar+' B WHERE B.NRRENDOR = A.NRDITAR))) ')
    Set  @SqlFilterUn1 = ' INSERT INTO '+@Ditar+'
                                 (KOD,PERSHKRIM,KOMENT,TIPDOK,TREGDK,
                                  NRDOK,FRAKSDOK,DATEDOK,NRFAT,DTFAT,TIPFAT,
                                  KMON,VLEFTA,VLEFTAMV,KURS1,KURS2,
                                  KODMASTER,ISDOKSHOQ,TAGNR,ORG,LLOJDOK )
                           SELECT B.KOD,A.SHENIM1,B.KOMENT,A.TIPDOK,TREGDK,
                                  A.NUMDOK,A.FRAKSDOK,A.DATEDOK,B.NRDOKREF,B.DATEDOKREF,B.TIPREF,
                                  B.KMON, CASE WHEN B.TREGDK=''D'' THEN DB ELSE KR END,
                                          CASE WHEN B.TREGDK=''D'' THEN B.DBKRMV ELSE 0-B.DBKRMV END, B.KURS1,B.KURS2,
                                  A.KODAB,0,B.NRRENDOR,'''+@PTip+''',''''
                             FROM '+@Table+' A INNER JOIN '+@Table+'SCR B ON A.NRRENDOR=B.NRD 
                            WHERE (TIPKLL='''+@PTip+''') AND (B.NRDITAR=0 OR (NOT (EXISTS (SELECT NRRENDOR FROM '+@Ditar+' C WHERE C.NRRENDOR = B.NRDITAR)))) 

                           UPDATE A 
                              SET A.NRDITAR = B.NRRENDOR 
                             FROM '+@Table+'Scr A INNER JOIN ' + @Ditar +' B ON A.NRRENDOR = B.TAGNR  
                            WHERE (B.TAGNR<>0) AND (B.ORG='''+@PTip+''') 

                           UPDATE '+@Ditar+' SET TAGNR=0, ORG='''' WHERE ISNULL(TAGNR,0)<>0 OR ORG<>'''' '
    Exec(@SqlFilterUn1)

    Set  @SqlFilterUn2 = Replace(@SqlFilterUn1,' ARKA',' BANKA')
    Exec(@SqlFilterUn2)

    Set  @SqlFilterUn2 = Replace(@SqlFilterUn1,' ARKA',' VS')
    Set  @SqlFilterUn2 = Replace(@SqlFilterUn2,'A.SHENIM1,','B.PERSHKRIM,')
    Set  @SqlFilterUn2 = Replace(@SqlFilterUn2,'A.NUMDOK,A.FRAKSDOK','A.NRDOK,0')
    Set  @SqlFilterUn2 = Replace(@SqlFilterUn2,'A.KODAB,',''''',')
    Set  @SqlFilterUn2 = Replace(@SqlFilterUn2,'A.TIPDOK,','''SP'',')
    Exec(@SqlFilterUn2)


    if @PTip = 'S'
       Begin
         Set  @Table = 'FJ'
         Exec(' INSERT INTO ' + @Ditar + '                     
                      (KOD,PERSHKRIM,KOMENT,TIPDOK,TREGDK, 
                       NRDITAR,NRDOK,FRAKSDOK,DATEDOK,NRFAT,DTFAT,TIPFAT,
                       KMON,VLEFTA,VLEFTAMV,KURS1,KURS2,
                       KODMASTER,ISDOKSHOQ,TAGNR,ORG,LLOJDOK )
                SELECT B.KOD,B.PERSHKRIM,B.KOMENT,''SP'',''D'',
                       B.NRDITAR,A.NRDOK,0,A.DATEDOK,B.NRDOKREF,B.DATEDOKREF,B.TIPREF,A.KMON,
                       0-B.VLERABS,0-ROUND(CASE WHEN A.KURS2=0 THEN 0 ELSE (B.VLERABS*A.KURS2)/A.KURS1 END,3),
                       A.KURS1,A.KURS2,
                       KODFKL,0,B.NRRENDOR,'''+@PTip+''',''''
                  FROM '+@Table+' A INNER JOIN '+@Table+'SCR B ON A.NRRENDOR=B.NRD 
                 WHERE (TIPKLL='''+@PTip+''') AND (B.NRDITAR=0 OR (NOT (EXISTS (SELECT NRRENDOR FROM '+@Ditar+' C WHERE C.NRRENDOR = B.NRDITAR)))) 
                UPDATE A 
                   SET A.NRDITARSHL = B.NRRENDOR 
                  FROM '+@Document+' A INNER JOIN ' + @Ditar +' B ON A.NRRENDOR = B.TAGNR  
                 WHERE (B.TAGNR<>0) AND (B.ORG='''+@PTip+''') 

                UPDATE '+@Ditar+' SET TAGNR=0, ORG='''' WHERE ISNULL(TAGNR,0)<>0 OR ORG<>'''' ')
       End
-- Shtim ne Ditar nga Dokumenta- Rrjeshta		    Fund


-- Shtim Kode Ditar ne Libra						Shtimi i Kodeve ne Librat

    Set @Table = 'TMPLiber'+@Ditar
    if  Exists (SELECT Name FROM Sys.Objects WHERE Name=@Table and Type='U')
        Exec('DROP TABLE ' + @Table)

    Exec('  SELECT DISTINCT 
                   KOD, PERSHKRIM=PERSHKRIM+'' - ''+KMON, KMON,
                   SG1 = CASE WHEN CHARINDEX (''.'',KOD)>0
                              THEN LEFT(KOD,CHARINDEX (''.'',KOD)-1)
                              ELSE KOD END
              INTO '+@Table+'
              FROM '+@Ditar+' A
             WHERE NOT EXISTS(SELECT KOD FROM '+@Liber+' B WHERE B.KOD=A.KOD)
          ORDER BY KOD

            INSERT INTO '+@Liber+' 
                  (KOD,PERSHKRIM,KMON,SG1,SG2,SG3,SG4,SG5,SG6,SG7,SG8,SG9,SG10,TROW,TAGNR)
            SELECT KOD,PERSHKRIM,KMON,SG1,'''','''','''',KMON,'''', '''', '''', '''','''',0,0
              FROM '+@Table+'
          ORDER BY KOD 

            UPDATE A 
               SET A.NRLIBER=B.NRRENDOR 
              FROM '+@Ditar+' A INNER JOIN '+@Liber+' B ON A.KOD=B.KOD ')

    if  Exists (SELECT Name FROM Sys.Objects WHERE Name=@Table and Type='U')
        Exec('DROP TABLE ' + @Table)

-- Shtim Kode Ditar ne Libra						Fund


-- GJENERIMI I RRJESHTAVE DITAR						FUND




GO
