SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--        Exec [dbo].[Isd_DocInformLM] 'VS',1

CREATE Procedure [dbo].[Isd_DocInformLm]
(
  @PTableName     Varchar(20),
  @PNrRendor      Int
 )

As



     DECLARE @NrRendor        Int,

             @TableName       Varchar(20),
             @TipDok          Varchar(10),
             @Org             Varchar(10),


             @LnkDok          Varchar(10),
             @LnkNrREndor     Int,


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
             @OrderRows       Varchar(50),
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
         Set @OrderRows     = '';


     DECLARE @Dif             Float,
             @NrRowsFk        Int,
             @ChangeDoc       Bit,
             @ChangeScr       Bit;

      SET    @sListDok = 'Arsh,NrRows,Fk,DtCr,DtEd,Error,Ordrows,id';
      IF     @TableName='ARKA' Or @TableName='BANKA'
             SET @sListDok = @sListDok + 'Link,';

--Print @sListDok;


      IF @TableName='ARKA'
         BEGIN

           SELECT @Kod           = KODAB,
                  @NrDFk         = NRDFK,
                  @Org           = 'A',
                  @TipDok        = TIPDOK,
                  @LnkDok        = LNKDOK,
                  @LnkNrRendor   = LNKNRRENDOR, 
                  @DtCreate      = ISNULL(USI,'')+CASE WHEN DATECREATE IS NULL 
                                                       THEN ''
                                                       ELSE ': '+CONVERT(VARCHAR,DATECREATE,104)+ ', ora '+ CONVERT(VARCHAR,DATECREATE,108)
                                                  END,
                  @DtEdit        = ISNULL(USM,'')+CASE WHEN DATEEDIT IS NULL 
                                                       THEN '' 
                                                       ELSE ': '+CONVERT(VARCHAR,DATEEDIT,104)  + ', ora '+ CONVERT(VARCHAR,DATEEDIT,108) 
                                                  END
             FROM ARKA 
            WHERE NRRENDOR=@NrRendor;

        -- Nr elemente
           SELECT @sNrRows = CAST(COUNT(*) AS VARCHAR)
             FROM ARKASCR
            WHERE NRD=@NrRendor;

        -- Dokument fature shoqeruese
             IF   @LnkDok='A'
                  BEGIN
                    SELECT @KomentShoq = 'Dest Arke  '+KODAB+', dokumenti '+TIPDOK+' nr '+CAST(CAST(NUMDOK AS BIGINT) AS VARCHAR)+', '+CONVERT(VARCHAR,DATEDOK,104) 
                      FROM ARKA 
                     WHERE NRRENDOR=@LnkNrRendor
                  END
             ELSE
             IF   @LnkDok='B'
                  BEGIN
                    SELECT @KomentShoq = 'Dest Banke '+KODAB+', dokumenti '+TIPDOK+' nr '+CAST(CAST(NUMDOK AS BIGINT) AS VARCHAR)+', '+CONVERT(VARCHAR,DATEDOK,104) 
                      FROM BANKA 
                     WHERE NRRENDOR=@LnkNrRendor
                  END
             ELSE
                  BEGIN
                    SELECT @KomentShoq = 'Origj '+ISNULL(DOK,'')+' '+KODAB+', dokumenti '+TIPDOK+' nr '+CAST(CAST(NUMDOK AS BIGINT) AS VARCHAR)+', '+CONVERT(VARCHAR,DATEDOK,104) 
                      FROM 
                     (
                        SELECT DOK = 'Arke', KODAB,TIPDOK,NUMDOK,DATEDOK 
                          FROM ARKA 
                         WHERE LNKNRRENDOR=@NrRendor AND LNKDOK='A'
                     UNION ALL 
                        SELECT DOK = 'Banke',KODAB,TIPDOK,NUMDOK,DATEDOK 
                          FROM BANKA 
                         WHERE LNKNRRENDOR=@NrRendor AND LNKDOK='A'

                      ) A

                  END
           SET    @KomentShoq= ISNULL(@KomentShoq,'');
           --     Kontrollo a jane Scr identike midis Org dhe Dest ....?


         END;



      IF @TableName='BANKA'
         BEGIN

           SELECT @Kod           = KODAB,
                  @NrDFk         = NRDFK,
                  @Org           = 'B',
                  @TipDok        = TIPDOK,
                  @LnkDok        = LNKDOK,
                  @LnkNrRendor   = LNKNRRENDOR, 
                  @DtCreate      = ISNULL(USI,'')+CASE WHEN DATECREATE IS NULL 
                                                       THEN ''
                                                       ELSE ': '+CONVERT(VARCHAR,DATECREATE,104)+ ', ora '+ CONVERT(VARCHAR,DATECREATE,108)
                                                  END,
                  @DtEdit        = ISNULL(USM,'')+CASE WHEN DATEEDIT IS NULL 
                                                       THEN '' 
                                                       ELSE ': '+CONVERT(VARCHAR,DATEEDIT,104)  + ', ora '+ CONVERT(VARCHAR,DATEEDIT,108) 
                                                  END
             FROM BANKA 
            WHERE NRRENDOR = @NrRendor;


        -- Nr elemente
           SELECT @sNrRows = CAST(COUNT(*) AS VARCHAR)
             FROM BANKASCR
            WHERE NRD=@NrRendor;

        -- Dokument fature shoqeruese
             IF   @LnkDok='A'
                  BEGIN
                    SELECT @KomentShoq = 'Dest Arke  '+KODAB+', dokumenti '+TIPDOK+' nr '+CAST(CAST(NUMDOK AS BIGINT) AS VARCHAR)+', '+CONVERT(VARCHAR,DATEDOK,104) 
                      FROM ARKA 
                     WHERE NRRENDOR=@LnkNrRendor
                  END
             ELSE
             IF   @LnkDok='B'
                  BEGIN
                    SELECT @KomentShoq = 'Dest Banke '+KODAB+', dokumenti '+TIPDOK+' nr '+CAST(CAST(NUMDOK AS BIGINT) AS VARCHAR)+', '+CONVERT(VARCHAR,DATEDOK,104) 
                      FROM BANKA 
                     WHERE NRRENDOR=@LnkNrRendor
                  END
             ELSE
                  BEGIN
                    SELECT @KomentShoq = 'Origj '+ISNULL(DOK,'')+' '+KODAB+', dokumenti '+TIPDOK+' nr '+CAST(CAST(NUMDOK AS BIGINT) AS VARCHAR)+', '+CONVERT(VARCHAR,DATEDOK,104) 
                      FROM 
                     (
                        SELECT DOK = 'Arke', KODAB,TIPDOK,NUMDOK,DATEDOK 
                          FROM ARKA 
                         WHERE LNKNRRENDOR=@NrRendor AND LNKDOK='B'
                     UNION ALL 
                        SELECT DOK = 'Banke',KODAB,TIPDOK,NUMDOK,DATEDOK 
                          FROM BANKA 
                         WHERE LNKNRRENDOR=@NrRendor AND LNKDOK='B'

                      ) A

                  END
           SET    @KomentShoq= ISNULL(@KomentShoq,'');
           --     Kontrollo a jane Scr identike midis Org dhe Dest ....?


         END;

      IF @TableName='VS'
         BEGIN

           SELECT @Kod           = '',
                  @NrDFk         = NRDFK,
                  @Org           = 'E',
                  @TipDok        = 'VS',
                  @DtCreate      = ISNULL(USI,'')+CASE WHEN DATECREATE IS NULL 
                                                       THEN ''
                                                       ELSE ': '+CONVERT(VARCHAR,DATECREATE,104)+ ', ora '+ CONVERT(VARCHAR,DATECREATE,108)
                                                  END,
                  @DtEdit        = ISNULL(USM,'')+CASE WHEN DATEEDIT IS NULL 
                                                       THEN '' 
                                                       ELSE ': '+CONVERT(VARCHAR,DATEEDIT,104)  + ', ora '+ CONVERT(VARCHAR,DATEEDIT,108) 
                                                  END
             FROM VS 
            WHERE NRRENDOR = @NrRendor;


        -- Nr elemente
           SELECT @sNrRows = CAST(COUNT(*) AS VARCHAR)
             FROM VSSCR
            WHERE NRD=@NrRendor;

         END;


      IF @TableName='FK'
         BEGIN

           SELECT @Kod           = REFERDOK,
                  @NrDFk         = NRRENDOR,
                  @Org           = ORG,
                  @TipDok        = TIPDOK,
                  @DtCreate      = ISNULL(USI,'')+CASE WHEN DATECREATE IS NULL 
                                                       THEN ''
                                                       ELSE ': '+CONVERT(VARCHAR,DATECREATE,104)+ ', ora '+ CONVERT(VARCHAR,DATECREATE,108)
                                                  END,
                  @DtEdit        = ISNULL(USM,'')+CASE WHEN DATEEDIT IS NULL 
                                                       THEN '' 
                                                       ELSE ': '+CONVERT(VARCHAR,DATEEDIT,104)  + ', ora '+ CONVERT(VARCHAR,DATEEDIT,108) 
                                                  END
 
             FROM FK 
            WHERE NRRENDOR = @NrRendor;


        -- Nr elemente
           SELECT @sNrRows = CAST(COUNT(*) AS VARCHAR)
             FROM FKSCR
            WHERE NRD=@NrRendor;


        -- Dokument fature shoqeruese

           IF     @Org='T' 
                  SET @KomentShoq = ''
           ELSE
           IF     @Org='A' AND (NOT EXISTS ( SELECT 1 FROM ARKA  WHERE NRDFK=@NrRendor ))
                  SET @KomentShoq = 'Mungon dokumenti origjine: Arke'
           ELSE
           IF     @Org='B' AND (NOT EXISTS ( SELECT 1 FROM BANKA WHERE NRDFK=@NrRendor ))
                  SET @KomentShoq = 'Mungon dokumenti origjine: Banke'
           ELSE
           IF     @Org='E' AND (NOT EXISTS ( SELECT 1 FROM VS    WHERE NRDFK=@NrRendor ))
                  SET @KomentShoq = 'Mungon dokumenti origjine: Vs'
           ELSE
           IF     @Org='G' AND (NOT EXISTS ( SELECT 1 FROM DG   WHERE NRDFK=@NrRendor ))
                  SET @KomentShoq = 'Mungon dokumenti origjine: Dogane'
           ELSE
           IF     @Org='H' AND (NOT EXISTS ( SELECT 1 FROM FH   WHERE NRDFK=@NrRendor ))
                  SET @KomentShoq = 'Mungon dokumenti origjine: Fh'
           ELSE
           IF     @Org='D' AND (NOT EXISTS ( SELECT 1 FROM FD   WHERE NRDFK=@NrRendor ))
                  SET @KomentShoq = 'Mungon dokumenti origjine: Fd'
           ELSE
           IF     @Org='F' AND (NOT EXISTS ( SELECT 1 FROM FF   WHERE NRDFK=@NrRendor ))
                  SET @KomentShoq = 'Mungon dokumenti origjine: Blerje'
           ELSE
           IF     @Org='S' AND (NOT EXISTS ( SELECT 1 FROM FJ   WHERE NRDFK=@NrRendor ))
                  SET @KomentShoq = 'Mungon dokumenti origjine: Shitje';
                   
 
           SELECT @Dif = ABS(SUM(ISNULL(DBKRMV,0))), @NrRowsFk = COUNT(*)
             FROM FKSCR
            WHERE NRD=@NrDFk;

           SET    @KomentLM = CASE WHEN ISNULL(@NrRowsFk,0)=0  OR  ISNULL(@Dif,0)>=1 
                                   THEN 'FK gabim - detaje'
                                   ELSE ''
                              END;

           SET    @KomentShoq= ISNULL(@KomentShoq,'');

         END;


      IF @TableName='VSST'
         BEGIN

           SELECT @Kod           = '',
                  @NrDFk         = 0,
                  @Org           = 'E',
                  @TipDok        = 'VSST',
                  @DtCreate      = ISNULL(USI,'')+CASE WHEN DATECREATE IS NULL 
                                                       THEN ''
                                                       ELSE ': '+CONVERT(VARCHAR,DATECREATE,104)+ ', ora '+ CONVERT(VARCHAR,DATECREATE,108)
                                                  END,
                  @DtEdit        = ISNULL(USM,'')+CASE WHEN DATEEDIT IS NULL 
                                                       THEN '' 
                                                       ELSE ': '+CONVERT(VARCHAR,DATEEDIT,104)  + ', ora '+ CONVERT(VARCHAR,DATEEDIT,108) 
                                                  END
             FROM VSST 
            WHERE NRRENDOR = @NrRendor;


        -- Nr elemente
           SELECT @sNrRows = CAST(COUNT(*) AS VARCHAR)
             FROM VSSTSCR
            WHERE NRD=@NrRendor;

         END;


      IF @TableName='FKST'
         BEGIN

           SELECT @Kod           = '',
                  @NrDFk         = 0,
                  @Org           = 'T',
                  @TipDok        = 'FKST',
                  @DtCreate      = ISNULL(USI,'')+CASE WHEN DATECREATE IS NULL 
                                                       THEN ''
                                                       ELSE ': '+CONVERT(VARCHAR,DATECREATE,104)+ ', ora '+ CONVERT(VARCHAR,DATECREATE,108)
                                                  END,
                  @DtEdit        = ISNULL(USM,'')+CASE WHEN DATEEDIT IS NULL 
                                                       THEN '' 
                                                       ELSE ': '+CONVERT(VARCHAR,DATEEDIT,104)  + ', ora '+ CONVERT(VARCHAR,DATEEDIT,108) 
                                                  END
             FROM FKST 
            WHERE NRRENDOR = @NrRendor;


        -- Nr elemente
           SELECT @sNrRows = CAST(COUNT(*) AS VARCHAR)
             FROM VSSCR
            WHERE NRD=@NrRendor;

         END;


      IF @TableName='VS'
         BEGIN

           SELECT @Kod           = '',
                  @NrDFk         = NRDFK,
                  @Org           = 'E',
                  @TipDok        = 'VS',
                  @DtCreate      = ISNULL(USI,'')+CASE WHEN DATECREATE IS NULL 
                                                       THEN ''
                                                       ELSE ': '+CONVERT(VARCHAR,DATECREATE,104)+ ', ora '+ CONVERT(VARCHAR,DATECREATE,108)
                                                  END,
                  @DtEdit        = ISNULL(USM,'')+CASE WHEN DATEEDIT IS NULL 
                                                       THEN '' 
                                                       ELSE ': '+CONVERT(VARCHAR,DATEEDIT,104)  + ', ora '+ CONVERT(VARCHAR,DATEEDIT,108) 
                                                  END
             FROM VS 
            WHERE NRRENDOR = @NrRendor;


        -- Nr elemente
           SELECT @sNrRows = CAST(COUNT(*) AS VARCHAR)
             FROM VSSCR
            WHERE NRD=@NrRendor;

         END;

      IF @TableName='DG'
         BEGIN

           SELECT @Kod           = '',
                  @NrDFk         = NRDFK,
                  @Org           = 'G',
                  @TipDok        = 'DG',
                  @DtCreate      = ISNULL(USI,'')+CASE WHEN DATECREATE IS NULL 
                                                       THEN ''
                                                       ELSE ': '+CONVERT(VARCHAR,DATECREATE,104)+ ', ora '+ CONVERT(VARCHAR,DATECREATE,108)
                                                  END,
                  @DtEdit        = ISNULL(USM,'')+CASE WHEN DATEEDIT IS NULL 
                                                       THEN '' 
                                                       ELSE ': '+CONVERT(VARCHAR,DATEEDIT,104)  + ', ora '+ CONVERT(VARCHAR,DATEEDIT,108) 
                                                  END
             FROM DG 
            WHERE NRRENDOR = @NrRendor;


        -- Nr elemente
           SELECT @sNrRows = CAST(COUNT(*) AS VARCHAR)
             FROM DGSCR
            WHERE NRD=@NrRendor;

         END;



-- Arshive dokumenti
        IF   EXISTS ( SELECT 1 FROM OBJECTSLINK WHERE TABELA=@TableName AND NRD=@NrRendor )
             BEGIN
               SET @KomentArsh = 'Lidhur me element arshive'
             END;



-- Flete kontabile
        IF   CHARINDEX(@TableName,'ARKA,BANKA,VS,DG') > 0
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
                    BEGIN    -- shiko @ErrorDokument
                      SELECT @Dif = ABS(SUM(ISNULL(DBKRMV,0))), @NrRowsFk = COUNT(*)
                        FROM FKSCR
                       WHERE NRD=@NrDFk

                      SET    @KomentLm = CASE WHEN ISNULL(@NrRowsFk,0)=0  OR  ISNULL(@Dif,0)>=1 
                                              THEN 'FK gabim - detaje'
                                              ELSE ''
                                         END
                    END;
             END;

-- Renditje detaje
      SELECT @OrderRows = ISNULL(B.PERSHKRIM,'') + 
                          CASE WHEN ISNULL(A.EDITMODE,0)=1 THEN '  / + Modifikim' ELSE '' END
        FROM ORDROWSDOC A INNER JOIN ORDROWSCFG B ON A.KOD=B.KOD 
       WHERE DOC=@TableName;


-- Diferenca per shumat ...
      SELECT @ErrorDokument = dbo.Isd_TestTotalDok(@TableName, @NrRendor);



-- Dogane per blerjen ...




      SELECT *
        FROM
    (
      SELECT PERSHKRIM='Arshive',         KOMENT = @KomentArsh,    NRORD =  1, INDEXBS =  0, SHORTNAME = 'Arsh',   NRRENDOR=0,TROW=CAST(CASE WHEN @KomentArsh='' THEN 0 ELSE 1 END AS BIT)
   UNION ALL
      SELECT PERSHKRIM='Likujdim',        KOMENT = @KomentLik,     NRORD =  2, INDEXBS =  1, SHORTNAME = 'Lik',    NRRENDOR=0,TROW=CAST(CASE WHEN @KomentLik ='' THEN 0 ELSE 1 END AS BIT)
   UNION ALL
      SELECT PERSHKRIM='Transport',       KOMENT = @KomentTran,    NRORD =  3, INDEXBS = -1, SHORTNAME = 'Trans',  NRRENDOR=0,TROW=CAST(CASE WHEN @KomentTran='' THEN 0 ELSE 1 END AS BIT)
   UNION ALL
      SELECT PERSHKRIM='Kontabilizim',    KOMENT = @KomentLm,      NRORD =  4, INDEXBS =  3, SHORTNAME = 'Fk',     NRRENDOR=0,TROW=CAST(CASE WHEN @KomentLm  ='' THEN 0 ELSE 1 END AS BIT)
   UNION ALL
      SELECT PERSHKRIM='Magazine',        KOMENT = @KomentMg,      NRORD =  5, INDEXBS = -1, SHORTNAME = 'Mg',     NRRENDOR=0,TROW=CAST(CASE WHEN @KomentMg  ='' THEN 0 ELSE 1 END AS BIT)
   UNION ALL
      SELECT PERSHKRIM='Dok.shoqeruese',  KOMENT = @KomentShoq,    NRORD =  6, INDEXBS =  2, SHORTNAME = 'Link',   NRRENDOR=0,TROW=CAST(CASE WHEN @KomentShoq='' THEN 0 ELSE 1 END AS BIT)

   UNION ALL
      SELECT PERSHKRIM='Dok.doganor',     KOMENT = @KomentDog,     NRORD =  7, INDEXBS =  4, SHORTNAME = 'Dog',    NRRENDOR=0,TROW=CAST(CASE WHEN @KomentDog ='' THEN 0 ELSE 1 END AS BIT)


-- Amballazhi ...????

   UNION ALL
      SELECT PERSHKRIM='Nr reshta',       KOMENT = @sNrRows,       NRORD = 15, INDEXBS = -1, SHORTNAME = 'NrRows', NRRENDOR=0,TROW=CAST(0 AS BIT)


   UNION ALL
      SELECT PERSHKRIM='Krijim',          KOMENT = @DtCreate,      NRORD = 50, INDEXBS =  5, SHORTNAME = 'DtCr',   NRRENDOR=0,TROW=CAST(0 AS BIT)
   UNION ALL
      SELECT PERSHKRIM='Modifikim',       KOMENT = @DtEdit,        NRORD = 51, INDEXBS = -1, SHORTNAME = 'DtEd',   NRRENDOR=0,TROW=CAST(0 AS BIT)
-- UNION ALL
--    SELECT PERSHKRIM='Dt print',        KOMENT = @DtPrintim,     NRORD = 52, INDEXBS = -1, SHORTNAME = 'DtPr'
-- UNION ALL
--    SELECT PERSHKRIM='Dt postim',       KOMENT = @DtPostim,      NRORD = 53, INDEXBS = -1, SHORTNAME = 'DtLm'


   UNION ALL
      SELECT PERSHKRIM='Kuadrime',        KOMENT = @ErrorDokument, NRORD = 90, INDEXBS = -1, SHORTNAME = 'Error',  NRRENDOR=0,TROW=CAST(CASE WHEN @ErrorDokument='' THEN 0 ELSE 1 END AS BIT)

   UNION ALL
      SELECT PERSHKRIM='id',              KOMENT = CAST(CAST(@NrRendor AS BIGINT) AS VARCHAR),  NRORD = 98, INDEXBS = -1, SHORTNAME = 'id',     NRRENDOR=0,TROW=CAST(0 AS BIT)

   UNION ALL
      SELECT PERSHKRIM='Renditje detaj ', KOMENT = @OrderRows,  NRORD = 99, INDEXBS = -1, SHORTNAME = 'Ordrows',     NRRENDOR=0,TROW=CAST(0 AS BIT)

      ) A

       WHERE CHARINDEX(SHORTNAME,@sListDok)>0

    ORDER BY NRORD;



GO
