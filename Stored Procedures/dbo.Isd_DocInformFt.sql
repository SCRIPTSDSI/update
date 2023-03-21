SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--        Exec [dbo].[Isd_DocInformFt] 'FJ',443250

CREATE Procedure [dbo].[Isd_DocInformFt]
(
  @PTableName     Varchar(20),
  @PNrRendor      Int
 )

As



     DECLARE @NrRendor        Int,

             @TableName       Varchar(20),
             @TipDok          Varchar(10),
             @Org             Varchar(10),

             @Kod             Varchar(60),
             @KMag            Varchar(20),
             @NrDMag          Int,

             @NrFat           Varchar(20),
             @DtFat           Varchar(20),
             @NrDFk           Int,
             @NrDFtExtra      Int,
             @KlaseTvsh       Varchar(10),
             @sNrRows         Varchar(20),

             @KomentMg        Varchar(150),
             @KomentLik       Varchar(150),
             @KomentLm        Varchar(150),
             @KomentArsh      Varchar(150),
             @KomentTran      Varchar(150),
             @KomentShoq      Varchar(150),
             @KomentDog       Varchar(150),
             @ErrorDokument   Varchar(150),
             @DtCreate        Varchar(50),
             @DtEdit          Varchar(50),
             @sListDok        Varchar(100);

         SET @TableName     = @PTableName;   -- 'FJ';
         SET @NrRendor      = @PNrRendor;    -- 443250;
         SET @TipDok        = @TableName;

         IF  @TableName = 'FJ'
             SET @Org       = 'S';
         IF  @TableName = 'FF'
             SET @Org       = 'F';

         SET @KomentMg      = '';
         SET @KomentArsh    = '';
         SET @KomentTran    = '';
         SET @KomentLik     = '';
         SET @KomentLm      = '';
         SET @KomentShoq    = '';
         SET @KomentDog     = '';
         SET @ErrorDokument = '';
         SET @sListDok      = '';


     DECLARE @Dif             Float,
             @NrRowsFk        Int,
             @ChangeDoc       Bit,
             @ChangeScr       Bit;

      SET    @sListDok = 'Arsh,NrRows,DtCr,DtEd,Error,';
      IF     @TableName='FJ' Or @TableName='FF'
             SET @sListDok = @sListDok + 'Lik,Trans,Fk,Mg,Link,Dg,'
      ELSE 
      IF     @TableName='FJT' Or @TableName='OFK' Or @TableName='ORK' Or @TableNAme='ORF'
             SET @sListDok = @sListDok + 'Link,'
      ELSE 
      IF     @TableName='FH' Or @TableName='FD'
             SET @sListDok = @sListDok + 'Trans,Fk,Mg,Link,Dg,';

--Print @sListDok;


      IF @TableName='FJ'
         BEGIN

           SELECT @Kod           = KOD,

                  @NrFat         = NRDSHOQ,
                  @DtFat         = CASE WHEN ISNULL(DTDSHOQ,'')=''
                                        THEN ''
                                        ELSE CONVERT(VARCHAR,DTDSHOQ,104)
                                   END,

                  @KMag          = KMAG,
                  @NrDMag        = NRDMAG,
                  @NrDFk         = NRDFK,
                  @NrDFtExtra    = NRDFTEXTRA,
                  @KlaseTvsh     = KLASETVSH,
                  @DtCreate      = ISNULL(USI,'')+CASE WHEN DATECREATE IS NULL 
                                                       THEN ''
                                                       ELSE ': '+CONVERT(VARCHAR,DATECREATE,104)+ ', ora '+ CONVERT(VARCHAR,DATECREATE,108)
                                                  END,
                  @DtEdit        = ISNULL(USM,'')+CASE WHEN DATEEDIT IS NULL 
                                                       THEN '' 
                                                       ELSE ': '+CONVERT(VARCHAR,DATEEDIT,104)+ ', ora '+ CONVERT(VARCHAR,DATEEDIT,108) 
                                                  END
 
             FROM FJ 
            WHERE NRRENDOR=@NrRendor;


        -- Nr elemente
           SELECT @sNrRows = CAST(COUNT(*) AS VARCHAR)
             FROM FJSCR
            WHERE NRD=@NrRendor;


        -- Likujdimi fature
           SELECT @KomentLik = TIPDOK+
                               ', nr '+CONVERT(VARCHAR,CONVERT(BIGINT,NRDOK))+
                               ', dt '+CONVERT(VARCHAR,DATEDOK,4)+
                               ' :'   +CAST(VLEFTA AS VARCHAR)+ISNULL(B.SIMBOL,'')  
             FROM DKL A LEFT JOIN MONEDHA B ON A.KMON=B.KOD 
            WHERE (A.KOD=@Kod)   AND (TIPDOK<>@TipDok) AND 
                  (NRFAT=@NrFat) AND (DTFAT=DBO.DATEVALUE(@DtFat));


        -- Dokument fature shoqeruese
           SELECT @KomentShoq = 'Fature shoqerimi: '+@TableName+' nr '+CAST(NRDSHOQ AS VARCHAR)+', dt '+CONVERT(VARCHAR,DTDSHOQ,4) 
             FROM FJ
            WHERE NRRENDOR=@NrDFtExtra


        -- Element transporti
             IF   EXISTS ( SELECT 1 FROM FJSHOQERUES WHERE NRD=@NrRendor )
                  BEGIN
                    SELECT @KomentTran = TRANSPORTUES+'  -  '+TARGE FROM FJSHOQERUES WHERE NRD=@NrRendor
                  END;


         END;



      IF @TableName='FF'
         BEGIN

           SELECT @Kod           = KOD,

                  @NrFat         = NRDSHOQ,
                  @DtFat         = CASE WHEN ISNULL(DTDSHOQ,'')=''
                                        THEN ''
                                        ELSE CONVERT(VARCHAR,DTDSHOQ,104)
                                   END,

                  @KMag          = KMAG,
                  @NrDMag        = NRDMAG,
                  @NrDFk         = NRDFK,
                  @NrDFtExtra    = NRDFTEXTRA,
                  @KlaseTvsh     = KLASETVSH,
                  @DtCreate      = ISNULL(USI,'')+CASE WHEN DATECREATE IS NULL
                                                       THEN ''
                                                       ELSE ' : '+CONVERT(VARCHAR,DATECREATE,104)+ ', ora '+ CONVERT(VARCHAR,DATECREATE,108)
                                                  END,
                  @DtEdit        = ISNULL(USM,'')+CASE WHEN DATEEDIT IS NULL 
                                                       THEN ''
                                                       ELSE ' : '+CONVERT(VARCHAR,DATEEDIT,104)  + ', ora '+ CONVERT(VARCHAR,DATEEDIT,108)
                                                  END
             FROM FF 
            WHERE NRRENDOR=@NrRendor;


        -- Nr elemente
           SELECT @sNrRows = CAST(COUNT(*) AS VARCHAR)
             FROM FFSCR
            WHERE NRD=@NrRendor;


        -- Likujdimi fature
           SELECT @KomentLik = TIPDOK+
                               ', nr '+CONVERT(VARCHAR,CONVERT(BIGINT,NRDOK))+
                               ', dt '+CONVERT(VARCHAR,DATEDOK,4)+
                               ' :'   +CAST(VLEFTA AS VARCHAR)+ISNULL(B.SIMBOL,'')  
             FROM DFU A LEFT JOIN MONEDHA B ON A.KMON=B.KOD 
            WHERE (A.KOD=@Kod)   AND (TIPDOK<>@TipDok) AND 
                  (NRFAT=@NrFat) AND (DTFAT=DBO.DATEVALUE(@DtFat));


        -- Dokument fature shoqeruese
           SELECT @KomentShoq = 'Fature shoqerimi: '+@TableName+' nr '+CAST(NRDSHOQ AS VARCHAR)+', dt '+CONVERT(VARCHAR,DTDSHOQ,4) 
             FROM FF
            WHERE NRRENDOR=@NrDFtExtra


        -- Dokumenti doganor
           SELECT @KomentDog = 'Dogane '+Convert(Varchar,Convert(BigInt,NrDOK))+', dt '+Convert(Varchar,DATEDOK,4) 
             FROM DG 
            WHERE NRRENDORFAT=@NrRendor;

               IF ISNULL(@KomentDog,'')='' AND @KlaseTvsh='FIMP'
                  SET @KomentDog = 'Dg mungon'


         END;


      IF @TableName='FJT'
         BEGIN

           SELECT @DtCreate      = ISNULL(USI,'')+CASE WHEN DATECREATE IS NULL 
                                                       THEN ''
                                                       ELSE ': '+CONVERT(VARCHAR,DATECREATE,104)+ ', ora '+ CONVERT(VARCHAR,DATECREATE,108)
                                                  END,
                  @DtEdit        = ISNULL(USM,'')+CASE WHEN DATEEDIT IS NULL 
                                                       THEN '' 
                                                       ELSE ': '+CONVERT(VARCHAR,DATEEDIT,104)  + ', ora '+ CONVERT(VARCHAR,DATEEDIT,108) 
                                                  END
 
             FROM FJT 
            WHERE NRRENDOR=@NrRendor;


        -- Nr elemente
           SELECT @sNrRows = CAST(COUNT(*) AS VARCHAR)
             FROM FJTSCR
            WHERE NRD=@NrRendor;


        -- Element transporti
             IF   EXISTS ( SELECT 1 FROM FJTSHOQERUES WHERE NRD=@NrRendor )
                  BEGIN
                    SELECT @KomentTran = TRANSPORTUES+'  -  '+TARGE FROM FJTSHOQERUES WHERE NRD=@NrRendor
                  END;

        -- Gjeneruar fature
           SELECT @KomentShoq = 'Gjeneruar: FJ'+' nr '+CAST(NRDSHOQ AS VARCHAR)+', dt '+CONVERT(VARCHAR,DTDSHOQ,4) 
             FROM FJ
            WHERE NRRENDORFJT=@NrRendor


         END;


      IF @TableName='OFK'
         BEGIN

           SELECT @DtCreate      = ISNULL(USI,'')+CASE WHEN DATECREATE IS NULL
                                                       THEN ''
                                                       ELSE ' : '+CONVERT(VARCHAR,DATECREATE,104)+ ', ora '+ CONVERT(VARCHAR,DATECREATE,108)
                                                  END,
                  @DtEdit        = ISNULL(USM,'')+CASE WHEN DATEEDIT IS NULL 
                                                       THEN ''
                                                       ELSE ' : '+CONVERT(VARCHAR,DATEEDIT,104)  + ', ora '+ CONVERT(VARCHAR,DATEEDIT,108)
                                                  END
             FROM OFK 
            WHERE NRRENDOR=@NrRendor;


        -- Nr elemente
           SELECT @sNrRows = CAST(COUNT(*) AS VARCHAR)
             FROM OFKSCR
            WHERE NRD=@NrRendor;

        -- Gjeneruar fature
           SELECT @KomentShoq = 'Gjeneruar: FJ'+' nr '+CAST(NRDSHOQ AS VARCHAR)+', dt '+CONVERT(VARCHAR,DTDSHOQ,4) 
             FROM FJ
            WHERE NRRENDOROF=@NrRendor

         END;


      IF @TableName='ORK'
         BEGIN

           SELECT @DtCreate      = ISNULL(USI,'')+CASE WHEN DATECREATE IS NULL
                                                       THEN ''
                                                       ELSE ' : '+CONVERT(VARCHAR,DATECREATE,104)+ ', ora '+ CONVERT(VARCHAR,DATECREATE,108)
                                                  END,
                  @DtEdit        = ISNULL(USM,'')+CASE WHEN DATEEDIT IS NULL 
                                                       THEN ''
                                                       ELSE ' : '+CONVERT(VARCHAR,DATEEDIT,104)  + ', ora '+ CONVERT(VARCHAR,DATEEDIT,108)
                                                  END
             FROM ORK 
            WHERE NRRENDOR=@NrRendor;


        -- Nr elemente
           SELECT @sNrRows = CAST(COUNT(*) AS VARCHAR)
             FROM ORKSCR
            WHERE NRD=@NrRendor;

        -- Gjeneruar fature
           SELECT @KomentShoq = 'Gjeneruar: FJ'+' nr '+CAST(NRDSHOQ AS VARCHAR)+', dt '+CONVERT(VARCHAR,DTDSHOQ,4) 
             FROM FJ
            WHERE NRRENDOROR=@NrRendor

         END;

      IF @TableName='ORF'
         BEGIN

           SELECT @DtCreate      = ISNULL(USI,'')+CASE WHEN DATECREATE IS NULL
                                                       THEN ''
                                                       ELSE ' : '+CONVERT(VARCHAR,DATECREATE,104)+ ', ora '+ CONVERT(VARCHAR,DATECREATE,108)
                                                  END,
                  @DtEdit        = ISNULL(USM,'')+CASE WHEN DATEEDIT IS NULL 
                                                       THEN ''
                                                       ELSE ' : '+CONVERT(VARCHAR,DATEEDIT,104)  + ', ora '+ CONVERT(VARCHAR,DATEEDIT,108)
                                                  END
             FROM ORK 
            WHERE NRRENDOR=@NrRendor;


        -- Nr elemente
           SELECT @sNrRows = CAST(COUNT(*) AS VARCHAR)
             FROM ORFSCR
            WHERE NRD=@NrRendor;

        -- Gjeneruar fature
           SELECT @KomentShoq = 'Gjeneruar: FF'+' nr '+CAST(NRDSHOQ AS VARCHAR)+', dt '+CONVERT(VARCHAR,DTDSHOQ,4) 
             FROM FF
            WHERE NRRENDOROR=@NrRendor

         END;

      IF @TableName='SM'
         BEGIN

           SELECT @DtCreate      = ISNULL(USI,'')+CASE WHEN DATECREATE IS NULL
                                                       THEN ''
                                                       ELSE ' : '+CONVERT(VARCHAR,DATECREATE,104)+ ', ora '+ CONVERT(VARCHAR,DATECREATE,108)
                                                  END,
                  @DtEdit        = ISNULL(USM,'')+CASE WHEN DATEEDIT IS NULL 
                                                       THEN ''
                                                       ELSE ' : '+CONVERT(VARCHAR,DATEEDIT,104)  + ', ora '+ CONVERT(VARCHAR,DATEEDIT,108)
                                                  END
             FROM SM 
            WHERE NRRENDOR=@NrRendor;


        -- Nr elemente
           SELECT @sNrRows = CAST(     SUM(CASE WHEN ISNULL(STATROW,'')='*' THEN 0 ELSE 1 END) AS VARCHAR)+
                             CASE WHEN SUM(CASE WHEN ISNULL(STATROW,'')='*' THEN 0 ELSE 1 END)>0 
                                  THEN ' Akt, '
                                  ELSE ''
                             END
                             +
                             CAST(     SUM(CASE WHEN ISNULL(STATROW,'')='*' THEN 1 ELSE 0 END) AS VARCHAR)+
                             CASE WHEN SUM(CASE WHEN ISNULL(STATROW,'')='*' THEN 1 ELSE 0 END)>0
                                  THEN ' Del'
                                  ELSE ''
                             END
             FROM SMSCR
            WHERE NRD=@NrRendor;

         END;


      IF @TableName='FH'
         BEGIN

           SELECT @KMag          = KMAG,
                  @NrDMag        = CASE WHEN ISNULL(DOK_JB,0)=1 THEN NRRENDOR ELSE 0 END,
                  @DtCreate      = ISNULL(A.USI,'')+CASE WHEN DATECREATE IS NULL
                                                       THEN ''
                                                       ELSE ' : '+CONVERT(VARCHAR,DATECREATE,104)+ ', ora '+ CONVERT(VARCHAR,DATECREATE,108)
                                                  END,
                  @DtEdit        = ISNULL(A.USM,'')+CASE WHEN DATEEDIT IS NULL 
                                                       THEN ''
                                                       ELSE ' : '+CONVERT(VARCHAR,DATEEDIT,104)  + ', ora '+ CONVERT(VARCHAR,DATEEDIT,108)
                                                  END,
        -- Select @KomentShoq = dbo.Isd_TestLinkMgDok(@KMag,@NrDok,@NrFraks,@Viti,@KMagLnk,@NrDokLnk,@NrFraksLnk,@VitiLnk,@TipTest,@TableName)
                  @KomentShoq    = CASE WHEN ISNULL(A.DOK_JB,0) = 1     
                                        THEN ''
                                        ELSE CASE WHEN ISNULL(KMAGLNK,'')<>'' AND (dbo.Isd_TestLinkMgDok2 (@TableName,@NrRendor,0)<>'')
                                                       THEN dbo.Isd_TestLinkMgDok2(@TableName,@NrRendor,0)

                                                  WHEN ISNULL(KMAGLNK,'')<>'' 
                                                       THEN 'lidhur FD : mag '  +ISNULL(KMAGLNK,'') +
                                                            ', nr '+CONVERT(VARCHAR,CONVERT(BIGINT,ISNULL(A.NRDOKLNK,0)))+
                                                            CASE WHEN ISNULL(A.NRFRAKSLNK,0)<>0
                                                                 THEN '/'+CONVERT(VARCHAR,A.NRFRAKSLNK)
                                                                 ELSE ''
                                                            END+
                                                            ', dt '+CONVERT(VARCHAR,A.DATEDOKLNK,4)

                                                  ELSE ISNULL(A.DST,'')
                                             END
                                   END
             FROM FH A
            WHERE NRRENDOR=@NrRendor;

        -- Nr elemente
           SELECT @sNrRows = CAST(COUNT(*) AS VARCHAR)
             FROM FHSCR
            WHERE NRD=@NrRendor;

        -- Lidhje fature ose lidhje dokumenta 
           IF     @NrDMag > 0
                  BEGIN
                    SELECT @KomentShoq = 'FF'+
                                         ', nr '+CONVERT(VARCHAR,CONVERT(BIGINT,ISNULL(NRDOK,0)))+
                                         ', dt '+CONVERT(VARCHAR,DATEDOK,4)+
                                         ' :'   +CAST(VLERTOT AS VARCHAR)+ISNULL(B.SIMBOL,'')  
                      FROM FF A LEFT JOIN MONEDHA B ON ISNULL(A.KMON,'')=ISNULL(B.KOD,'') 
                     WHERE A.NRRENDDMG=@NrDMag AND A.KMAG=@KMag;

                    SET    @NrDMag     = CASE WHEN ISNULL(@KomentShoq,'')='' THEN 0 ELSE @NrDMag END;
                    SET    @KomentShoq = CASE WHEN ISNULL(@KomentShoq,'')='' THEN 'Gabim lidhje fat-magazine' ELSE @KomentShoq END;
 
                  END
         END;


      IF @TableName='FD'
         BEGIN

           SELECT @KMag          = KMAG,
                  @NrDMag        = CASE WHEN ISNULL(DOK_JB,0)=1 THEN NRRENDOR ELSE 0 END,
                  @DtCreate      = ISNULL(A.USI,'')+CASE WHEN DATECREATE IS NULL
                                                       THEN ''
                                                       ELSE ' : '+CONVERT(VARCHAR,DATECREATE,104)+ ', ora '+ CONVERT(VARCHAR,DATECREATE,108)
                                                    END,
                  @DtEdit        = ISNULL(A.USM,'')+CASE WHEN DATEEDIT IS NULL 
                                                       THEN ''
                                                       ELSE ' : '+CONVERT(VARCHAR,DATEEDIT,104)  + ', ora '+ CONVERT(VARCHAR,DATEEDIT,108)
                                                    END,
        
                  @KomentShoq    = CASE WHEN ISNULL(A.DOK_JB,0) = 1     
                                        THEN ''
                                        ELSE CASE WHEN ISNULL(KMAGLNK,'')<>'' AND (dbo.Isd_TestLinkMgDok2 (@TableName,@NrRendor,0)<>'')
                                                       THEN dbo.Isd_TestLinkMgDok2(@TableName,@NrRendor,0)

                                                  WHEN ISNULL(KMAGLNK,'')<>'' 
                                                       THEN 'lidhur FH : mag '  +ISNULL(KMAGLNK,'') +
                                                            ', nr '+CONVERT(VARCHAR,CONVERT(BIGINT,ISNULL(A.NRDOKLNK,0)))+
                                                            CASE WHEN ISNULL(A.NRFRAKSLNK,0)<>0
                                                                 THEN '/'+CONVERT(VARCHAR,A.NRFRAKSLNK)
                                                                 ELSE ''
                                                            END+
                                                            ', dt '+CONVERT(VARCHAR,A.DATEDOKLNK,4)

                                                  ELSE ISNULL(A.DST,'')

                                             END
                                   END
             FROM FD A
            WHERE NRRENDOR=@NrRendor;

        -- Nr elemente
           SELECT @sNrRows = CAST(COUNT(*) AS VARCHAR)
             FROM FDSCR
            WHERE NRD=@NrRendor;

        -- Lidhje fature ose lidhje dokumenta 
           IF     @NrDMag > 0
                  BEGIN
                    SELECT @KomentShoq = 'FJ'+
                                         ', nr '+CONVERT(VARCHAR,CONVERT(BIGINT,ISNULL(NRDOK,0)))+
                                         ', dt '+CONVERT(VARCHAR,DATEDOK,4)+
                                         ' :'   +CAST(VLERTOT AS VARCHAR)+ISNULL(B.SIMBOL,'')  
                      FROM FJ A LEFT JOIN MONEDHA B ON ISNULL(A.KMON,'')=ISNULL(B.KOD,'') 
                     WHERE A.NRRENDDMG=@NrDMag AND A.KMAG=@KMag;

                    SET    @NrDMag     = CASE WHEN ISNULL(@KomentShoq,'')='' THEN 0 ELSE @NrDMag END;
                    SET    @KomentShoq = CASE WHEN ISNULL(@KomentShoq,'')='' THEN 'Gabim lidhje fat-magazine' ELSE @KomentShoq END;
 
                  END

        -- Element transporti
             IF   EXISTS ( SELECT 1 FROM MGSHOQERUES WHERE NRD=@NrRendor )
                  BEGIN
                    SELECT @KomentTran = TRANSPORTUES+'  -  '+TARGE FROM MGSHOQERUES WHERE NRD=@NrRendor
                  END;

         END;








-- Arshive dokumenti
        IF   EXISTS ( SELECT 1 FROM OBJECTSLINK WHERE TABELA=@TableName AND NRD=@NrRendor )
             BEGIN
               SET @KomentArsh = 'Lidhur me element arshive'
             END;



-- Flete kontabile
        IF   CHARINDEX(@TableName,'FJ,FF,FH,FD') > 0
             BEGIN

               IF  (@NrDFk=0) OR (NOT EXISTS ( SELECT 1 FROM FK WHERE NRRENDOR=@NrDFk ))
                    BEGIN
                      SET @KomentLm = 'Pa kaluar LM'
                    END
               ELSE
               IF   NOT EXISTS ( SELECT 1 FROM FK WHERE NRRENDOR=@NrDFk AND ORG=@Org AND TIPDOK=@TipDok )
                    BEGIN
                      SET @KomentLm = 'FK gabim - dokumenti'
                    END
               ELSE
                    BEGIN
                      SELECT @Dif = ABS(SUM(ISNULL(DBKRMV,0))), @NrRowsFk = COUNT(*)
                        FROM FKSCR
                       WHERE NRD=@NrDFk

                      SET    @KomentLm = CASE WHEN ISNULL(@NrRowsFk,0)=0  OR  ISNULL(@Dif,0)>=1 
                                              THEN 'FK gabim - detaje'
                                              ELSE ''
                                         END
                    END;
             END;

-- Magazina
        IF   CHARINDEX(@TableName,'FJ,FF,FH,FD') > 0
             BEGIN
               IF   @KMag<>'' AND @NrDMag<>0
                    BEGIN
                      IF @TableName='FH'
                         EXEC dbo.Isd_ChangeMgFromFt 'FF',       '', @NrDMag,   @ChangeDoc Out, @ChangeScr Out
                      ELSE
                      IF @TableName='FD'
                         EXEC dbo.Isd_ChangeMgFromFt 'FJ',       '', @NrDMag,   @ChangeDoc Out, @ChangeScr Out
                      ELSE
                         EXEC dbo.Isd_ChangeMgFromFt @TableName, '', @NrRendor, @ChangeDoc Out, @ChangeScr Out

                      IF   @ChangeDoc<>0 AND @ChangeScr<>0
                           BEGIN
                             SET @KomentMg = 'Mosperputhje fat-magazine / dok + reshta'
                           END
                      ELSE
                      IF   @ChangeDoc<>0
                           BEGIN
                             SET @KomentMg = 'Mosperputhje fat-magazine / dok'
                           END
                      ELSE
                      IF   @ChangeScr<>0
                           BEGIN
                             SET @KomentMg = 'Mosperputhje fat-magazine / reshta'
                           END
                    END;
             END;


-- Diferenca per shumat ...
      SELECT @ErrorDokument = dbo.Isd_TestTotalDok(@TableName, @NrRendor);




-- Dogane per blerjen ...




      SELECT *
        FROM
    (
      SELECT PERSHKRIM='Arshive',        KOMENT = @KomentArsh,    NRORD =  1, INDEXBS =  0, SHORTNAME = 'Arsh',   NRRENDOR=0,TROW=CAST(CASE WHEN @KomentArsh='' THEN 0 ELSE 1 END AS BIT)
   UNION ALL
      SELECT PERSHKRIM='Likujdim',       KOMENT = @KomentLik,     NRORD =  2, INDEXBS =  1, SHORTNAME = 'Lik',    NRRENDOR=0,TROW=CAST(CASE WHEN @KomentLik ='' THEN 0 ELSE 1 END AS BIT)
   UNION ALL
      SELECT PERSHKRIM='Transport',      KOMENT = @KomentTran,    NRORD =  3, INDEXBS = -1, SHORTNAME = 'Trans',  NRRENDOR=0,TROW=CAST(CASE WHEN @KomentTran='' THEN 0 ELSE 1 END AS BIT)
   UNION ALL
      SELECT PERSHKRIM='Kontabilizim',   KOMENT = @KomentLm,      NRORD =  4, INDEXBS =  3, SHORTNAME = 'Fk',     NRRENDOR=0,TROW=CAST(CASE WHEN @KomentLm  ='' THEN 0 ELSE 1 END AS BIT)
   UNION ALL
      SELECT PERSHKRIM='Magazine',       KOMENT = @KomentMg,      NRORD =  5, INDEXBS = -1, SHORTNAME = 'Mg',     NRRENDOR=0,TROW=CAST(CASE WHEN @KomentMg  ='' THEN 0 ELSE 1 END AS BIT)
   UNION ALL
      SELECT PERSHKRIM='Dok.shoqeruese', KOMENT = @KomentShoq,    NRORD =  6, INDEXBS =  2, SHORTNAME = 'Link',   NRRENDOR=0,TROW=CAST(CASE WHEN @KomentShoq='' THEN 0 ELSE 1 END AS BIT)

   UNION ALL
      SELECT PERSHKRIM='Dok.doganor',    KOMENT = @KomentDog,     NRORD =  7, INDEXBS =  4, SHORTNAME = 'Dog',    NRRENDOR=0,TROW=CAST(CASE WHEN @KomentDog ='' THEN 0 ELSE 1 END AS BIT)


-- Amballazhi ...????

   UNION ALL
      SELECT PERSHKRIM='Nr reshta',      KOMENT = @sNrRows,       NRORD = 15, INDEXBS = -1, SHORTNAME = 'NrRows', NRRENDOR=0,TROW=CAST(0 AS BIT)


   UNION ALL
      SELECT PERSHKRIM='Krijim',         KOMENT = @DtCreate,      NRORD = 50, INDEXBS =  5, SHORTNAME = 'DtCr',   NRRENDOR=0,TROW=CAST(0 AS BIT)
   UNION ALL
      SELECT PERSHKRIM='Modifikim',      KOMENT = @DtEdit,        NRORD = 51, INDEXBS = -1, SHORTNAME = 'DtEd',   NRRENDOR=0,TROW=CAST(0 AS BIT)
-- UNION ALL
--    SELECT PERSHKRIM='Dt print',       KOMENT = @DtPrintim,     NRORD = 52, INDEXBS = -1, SHORTNAME = 'DtPr'
-- UNION ALL
--    SELECT PERSHKRIM='Dt postim',      KOMENT = @DtPostim,      NRORD = 53, INDEXBS = -1, SHORTNAME = 'DtLm'


   UNION ALL
      SELECT PERSHKRIM='Kuadrime',       KOMENT = @ErrorDokument, NRORD = 90, INDEXBS = -1, SHORTNAME = 'Error',  NRRENDOR=0,TROW=CAST(CASE WHEN @ErrorDokument='' THEN 0 ELSE 1 END AS BIT)

      ) A

       WHERE CHARINDEX(SHORTNAME,@sListDok)>0

    ORDER BY NRORD;



GO
