SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--        EXEC dbo.Isd_DocSaveFJ 567717,'M',1,'#12345678','ADMIN','1234567890'

CREATE Procedure [dbo].[Isd_DocSaveFJ]
(
  @PNrRendor      Int,
  @PIDMStatus     Varchar(10),
  @PSaveMg        Bit,                -- Te hiqet sepse duhet 1 gjithmone...
  @PTableTmpLm    Varchar(40),
  @PPerdorues     Varchar(30),
  @PLgJob         Varchar(30)
 )

As


		IF @PIDMStatus='M'
		  BEGIN
			  UPDATE FJ SET FISRELATEDFIC=FISIIC WHERE NRRENDOR=@PNrRendor AND ISNULL(FISRELATEDFIC,'')='';
			  
		  END

		IF @PIDMStatus='S'
		  BEGIN
			  UPDATE FJ 
			  SET FISFIC='',FISRELATEDFIC=FISIIC,
			  ISDOCFISCAL=CASE WHEN ISNULL(ISDOCFISCAL,0)=1 THEN ISDOCFISCAL 
							ELSE 
							(SELECT TOP 1 B.ISDOCFISCAL FROM FJ A INNER JOIN KLIENT B ON A.KODFKL=B.KOD
							  WHERE A.NRRENDOR=@PNrRendor)
							END
			  WHERE NRRENDOR=@PNrRendor;
			 
		  
		  END

-- Njesoj me FF por Tipi='S',Isd_GjenerimFDFromFt dhe ka DokShoqerues.

         SET NOCOUNT ON

          IF ISNULL(@PNrRendor,0)<=0 -- ISNULL(@PTableName,'')<>'FJ' OR ISNULL(@PNrRendor,0)<=0
             RETURN;

     DECLARE @NrRendor       Int,
             @IDMStatus      Varchar(10),
             @TableTmpLm     Varchar(40),
          -- @SaveMg         Bit,       -- Te hiqet sepse duhet 1 gjithmone...
             @Perdorues      Varchar(30),
             @LgJob          Varchar(30),
             @TableName      Varchar(30),
             @KodKF          Varchar(30),
             @KMag           Varchar(30),
             @LlogTvsh       Varchar(30),
             @LlogZbr        Varchar(30),
             @LlogArk        Varchar(30),
             @NrMag          Int,
             @NrRndMg        Int,
             @NrRendorFk     Int,
             @AutoPostLmFJ   Bit,
             @Sql            nVarchar(MAX),
             @Transaksion    Varchar(20),
             @Vlere          Float;

         SET @NrRendor     = @PNrRendor;
         SET @IDMStatus    = @PIDMStatus;
         SET @TableTmpLm   = @PTableTmpLm;
      -- SET @SaveMg       = @PSaveMg;            -- Perdoret rasti kur nuk prekete Fd nga Programi,
         SET @Perdorues    = @PPerdorues;         -- por te hiqet sepse duhet 1 gjithmone... 
         SET @LgJob        = @PLgJob;
         SET @TableName    = 'FJ';
         SET @Transaksion  = 'IFMDS';  -- DELETE me F apo D, INSERT me I apo S


          -- Perdore ketu qe ta perdorin edhe Magazina dhe Arka
          IF OBJECT_ID('TempDb..'+@TableTmpLm) IS NOT NULL
             BEGIN
               EXEC ('DROP TABLE '+@TableTmpLm);
             END;

      SELECT @AutoPostLmFJ = CASE WHEN @PTableTmpLm<>'' THEN ISNULL(AUTOPOSTLMFJ,0) ELSE 0 END,
             @LlogTvsh     = LLOGTATS,
             @LlogZbr      = LLOGZBR,
             @LlogArk      = LLOGARK
        FROM CONFIGLM;
              


--      Test per Kod-e, referenca, kurse etj.
        EXEC dbo.Isd_DocSaveTestFields @TableName,@NrRendor,@IDMStatus;


      SELECT @NrRendorFk   = NRDFK,
             @Vlere        = VLERTOT,
             @KodKF        = KODFKL,
             @KMag         = ISNULL(KMAG,''),
             @NrMag        = ISNULL(NRMAG,0)
        FROM FJ
       WHERE NRRENDOR = @NrRendor;


          IF NOT EXISTS 
             ( SELECT NRRENDOR 
                 FROM FJ A 
                WHERE A.NRRENDOR=@NrRendor AND (ISNULL(A.VLTVSH,0)<>0) AND 
                     (NOT EXISTS (SELECT KOD FROM LLOGARI B WHERE B.KOD=A.LLOGTVSH AND B.POZIC=1)) 
               )
             BEGIN
               UPDATE FJ  SET LLOGTVSH=@LlogTvsh  WHERE NRRENDOR=@NrRendor
             END;
             
          IF NOT EXISTS 
             ( SELECT NRRENDOR 
                 FROM FJ A 
                WHERE A.NRRENDOR=@NrRendor AND (ISNULL(A.VLERZBR,0)<>0) AND 
                     (NOT EXISTS (SELECT KOD FROM LLOGARI B WHERE B.KOD=A.LLOGZBR AND B.POZIC=1)) 
               )
             BEGIN
               UPDATE FJ  SET LLOGZBR =@LlogZbr  WHERE NRRENDOR=@NrRendor
             END;
             
          IF NOT EXISTS 
             ( SELECT NRRENDOR 
                 FROM FJ A 
                WHERE A.NRRENDOR=@NrRendor AND (ISNULL(A.PARAPG,0)<>0) AND (ISNULL(A.KODARK,'')='') AND 
                     (NOT EXISTS (SELECT KOD FROM LLOGARI B WHERE B.KOD=A.LLOGARK AND B.POZIC=1)) 
               )
             BEGIN
               UPDATE FJ  SET LLOGARK =@LlogArk  WHERE NRRENDOR=@NrRendor
             END;

      UPDATE A 
         SET KONVERTART = ROUND(CASE WHEN ISNULL(B.KONV2,1)*ISNULL(B.KONV1,1)<=0 
                                     THEN 1 
                                     ELSE ISNULL(B.KONV2,1)/ISNULL(B.KONV1,1) END,3) 
        FROM FJSCR A INNER JOIN ARTIKUJ B On A.KARTLLG=B.KOD
       WHERE NRD=@NrRendor;


      UPDATE A
         SET A.AGJENTSHITJELINK = ISNULL(B.KODMASTER,'')
        FROM FJ A INNER JOIN AGJENTSHITJE B ON ISNULL(A.KLASIFIKIM,'')=B.KOD
       WHERE A.NRRENDOR=@NrRendor;



--           Korigjimi i koeficenteve dhe vlerave per bonuse te Klient/Agjent sipas kategori artikuj

--           Ne se do te duhej te perdoret ne program atehere perpara BeforePost (ose RegjistrimSCR) perdor store procedure Isd_ArtikujKtgAgjKlGetVlere
--           Shiko ne program proceduren SysF5Sql.GetVleraArtikujKtgAgjKl(pTable,pDataSet);

          IF OBJECT_ID('TempDB..#TempKtgAgjKL') IS NOT NULL
             DROP TABLE #TempKtgAgjKL;

      SELECT NRRENDOR, KARTLLG, 
             KOEFICENTARTAGJ = MAX(KOEFICENTARTAGJ), 
             KOEFICENTARTKL  = MAX(KOEFICENTARTKL)  
             
         INTO #TempKtgAgjKL     
         FROM
         
            (    
                SELECT A.NRRENDOR, KARTLLG = B.KARTLLG, KOEFICENTARTAGJ = MAX(R32.VLEFTE), KOEFICENTARTKL = 0 
                  FROM FJ A  INNER JOIN FJSCR            B   ON A.NRRENDOR=B.NRD
                             INNER JOIN ARTIKUJ          R1  ON B.KARTLLG=R1.KOD AND ISNULL(R1.APLKATEGORIAGJ,0)=1
                             INNER JOIN ARTIKUJKTG       R2  ON ISNULL(R1.KATEGORI,'')=R2.KOD AND ISNULL(R2.NOTACTIV,0)=0
                             INNER JOIN ARTIKUJKTGAGJSCR R32 ON R32.KOD=ISNULL(A.KLASIFIKIM,'') AND R32.KODAF=R2.KOD
                             INNER JOIN ARTIKUJKTGAGJ    R31 ON R31.NRRENDOR=R32.NRD AND ISNULL(R31.ACTIV,0)=0
                 WHERE A.NRRENDOR=@NrRendor AND B.TIPKLL='K' AND ISNULL(A.KLASIFIKIM,'')<>''
              GROUP BY A.NRRENDOR,B.KARTLLG
            
             UNION ALL  
           
                SELECT A.NRRENDOR, KARTLLG = B.KARTLLG, KOEFICENTARTAGJ = 0, KOEFICENTARTKL = MAX(R32.VLEFTE) 
                  FROM FJ A  INNER JOIN FJSCR            B   ON A.NRRENDOR=B.NRD
                             INNER JOIN ARTIKUJ          R1  ON B.KARTLLG=R1.KOD AND ISNULL(R1.APLKATEGORIKL,0)=1
                             INNER JOIN ARTIKUJKTG       R2  ON ISNULL(R1.KATEGORI,'')=R2.KOD AND ISNULL(R2.NOTACTIV,0)=0
                             INNER JOIN ARTIKUJKTGKLSCR  R32 ON R32.KOD=A.KODFKL AND R32.KODAF=R2.KOD
                             INNER JOIN ARTIKUJKTGKL     R31 ON R31.NRRENDOR=R32.NRD AND ISNULL(R31.ACTIV,0)=0
                 WHERE A.NRRENDOR=@NrRendor AND B.TIPKLL='K' 
              GROUP BY A.NRRENDOR,B.KARTLLG
            
              ) A
              
    GROUP BY NRRENDOR,KARTLLG          
    ORDER BY NRRENDOR,KARTLLG;
   
      UPDATE A
         SET KOEFICENTARTAGJ = ISNULL(B.KOEFICENTARTAGJ,0), --VLERAARTAGJ = ISNULL(B.KOEFICENTARTAGJ,0) * A.VLPATVSH,
             KOEFICENTARTKL  = ISNULL(B.KOEFICENTARTKL,0)   --VLERAARTKL  = ISNULL(B.KOEFICENTARTKL, 0) * A.VLPATVSH
        FROM FJSCR A LEFT JOIN #TempKtgAgjKL B ON A.NRD=B.NRRENDOR AND A.KARTLLG=B.KARTLLG
       WHERE A.NRD=@NrRendor AND A.TIPKLL='K'; 


          IF OBJECT_ID('TempDB..#TempKtgAgjKL') IS NOT NULL
             DROP TABLE #TempKtgAgjKL;
             
-- Fund      Korigjimi i koeficentave dhe vlerave per bonuse te Klient/Agjent sipas kategori artikuj            





-- 1.
        EXEC dbo.Isd_GjenerimDitarOne @TableName, 0, @NrRendor;


-- 2.
          IF CHARINDEX(@IDMStatus,@Transaksion)>0  -- DELETE me F apo D, INSERT me I apo S
             EXEC dbo.Isd_AppendTransLog @TableName,@NrRendor,@Vlere,@IDMStatus,@Perdorues,@LgJob;

     -- Postimi shiko me poshte -- Ketu le te behet fshirja ....
          IF @NrRendorFk>=1
             BEGIN
               EXEC dbo.LM_DelFk @NrRendorFk;
             END;
     -- Postimi shiko me poshte 


-- 3.1
       -- IF @SaveMg=1  -- Gjithmone ..... dallimi behet brenda tek    dbo.Isd_GjenerimFDFromFt
             EXEC Isd_GjenerimFDFromFt      @NrRendor,@Perdorues,@LgJob;

-- 3.2
       -- IF @SaveMg=1  -- Gjithmone ..... dallimi behet brenda tek    dbo.Isd_GjenerimFhFromFtAmb
             EXEC Isd_GjenerimFHFromFtAmb   @NrRendor,@Perdorues,@LgJob;

-- 3.3
             EXEC Isd_GjenerimAQFromFt 'FJ',@NrRendor,@Perdorues,@LgJob;

-- 4.
     -- FJ - DokShoq:  Fillim'

          IF NOT EXISTS (SELECT * FROM FJSHOQERUES WHERE NRD=@NrRendor)
             BEGIN
               
               INSERT  INTO FJSHOQERUES
                      (NRD,[DATE],[TIME])
               VALUES (@NrRendor,GETDATE(),dbo.Isd_DateTimeServer ('T'));

               UPDATE A 
                  SET A.NIPT            = B.NIPT,
                      A.NIPTCERTIFIKATE = B.NIPTCERTIFIKATE,
                      A.KODFISKAL       = B.KODFISKAL,
                      A.NRLICENCE       = B.NRLICENCE,
                      A.TARGE           = B.TARGE,
                      A.MJET            = B.MJET,
                      A.KOMPANI         = B.KOMPANI,
                      A.TRANSPORTUES    = B.PERSHKRIM,
                      A.SHENIM1         = B.ADRESA1,
                      A.SHENIM2         = B.ADRESA2,
                      A.SHENIM3         = B.ADRESA3,
                      A.TELEFON1        = B.TELEFON1,
                      A.TELEFON2        = B.TELEFON2,
                      A.FAX             = B.FAX 
                 FROM FJSHOQERUES A, TRANSPORT B
                WHERE A.NRD = @NrRendor AND B.LINKKLIENT = @KodKF;

             END;
     -- FJ - DokShoq:  Fund'


-- 5.

     -- FJ - Dokument Arke: Fillim

        EXEC dbo.Isd_DocumentArkeFromFt @TableName,0,@NrRendor,@Perdorues,@LgJob;

     -- FJ - Dokument Arke: Fund


-- 6.

     -- FJ - Kalimi ne Lm: Fillim

     --   IF @NrRendorFk>=1
     --      EXEC dbo.LM_DelFk @NrRendorFk;

          IF @NrRendorFk>=1
             BEGIN
               IF ISNULL(@AutoPostLmFJ,0)=1
                  BEGIN
                    DELETE FROM FKSCR     WHERE NrD=@NrRendorFk
                  END 
               ELSE
                  BEGIN
                    DELETE FROM FK        WHERE NrRendor=@NrRendorFk;
                    UPDATE FJ SET NRDFK=0 WHERE NRRENDOR=@NrRendor;

                    RETURN;

                  END;
             END;

          IF ISNULL(@AutoPostLmFJ,0)=0 OR @TableTmpLm=''
             RETURN;

--        Jo ketu fshirja sepse mund te perdoret nga Arka ose magazina ....
--        IF OBJECT_ID('TempDb..'+@TableTmpLm) IS NOT NULL
--           EXEC ('DROP TABLE '+@TableTmpLm);

        EXEC [Isd_KalimLM] @PTip='S', @PNrRendor=@NrRendor, @PSQLFilter='', @PTableNameTmp=@TableTmpLm; 

     -- FJ - Kalimi ne Lm: Fund 

/*                   PJESA TEST TEPER E RENDESISHME
  DECLARE @NrRendor Int
      SET @NrRendor=567717

   SELECT T01Dok='FJ-Fj     ',* FROM Fj          WHERE NrRendor =@NrRendor;
   SELECT T02Dok='FJ-FjRow  ',* FROM FjScr       WHERE Nrd      =@NrRendor;
   SELECT T03Dok='FJ-Tr     ',* FROM FJSHOQERUES WHERE Nrd      =@NrRendor;
   SELECT T04Dok='FJ-Pg     ',* FROM FJPG        WHERE Nrd      =@NrRendor;
   SELECT T05Dok='FJ-FjDt   ',* FROM DKL         WHERE NrRendor =(SELECT NRDITAR    FROM Fj WHERE NrRendor=@NrRendor);

   SELECT T06Dok='FJ-Fd     ',* FROM FD          WHERE NrRendor =(SELECT NRRENDDMG  FROM Fj WHERE NrRendor=@NrRendor);
   SELECT T07Dok='FJ-FdRow  ',* FROM FDScr       WHERE Nrd      =(SELECT NRRENDDMG  FROM Fj WHERE NrRendor=@NrRendor);

   SELECT T08Dok='FJ-Ar     ',* FROM Arka        WHERE NrRendor =(SELECT NRRENDORAR FROM Fj WHERE NrRendor=@NrRendor);
   SELECT T09Dok='FJ-ArRow  ',* FROM ArkaScr     WHERE Nrd      =(SELECT NRRENDORAR FROM Fj WHERE NrRendor=@NrRendor);
   SELECT T10Dok='FJ-ArDt   ',* FROM DAR         WHERE NrRendor =(SELECT NRDITAR 
                                                                    FROM Arka
                                                                   WHERE NrRendor=(SELECT NRRENDORAR FROM Fj WHERE NrRendor=@NrRendor));
-- Fk-Fj
   SELECT T11Dok='FJ-Fk     ',* FROM FK          WHERE NrRendor =(SELECT NRDFK      FROM Fj WHERE NrRendor=@NrRendor);
   SELECT T12Dok='FJ-FkRow  ',* FROM FKScr       WHERE Nrd      =(SELECT NRDFK      FROM Fj WHERE NrRendor=@NrRendor);
-- Fk-Fd
   SELECT T13Dok='FJ-FdFk   ',* FROM FK          WHERE NrRendor =(SELECT NRDFK 
                                                                    FROM FD
                                                                   WHERE NrRendor=(SELECT NRRENDDMG  FROM Fj WHERE NrRendor=@NrRendor));
   SELECT T14Dok='FJ-FdFkRow',* FROM FKScr       WHERE Nrd      =(SELECT NRDFK 
                                                                    FROM FD
                                                                   WHERE NrRendor=(SELECT NRRENDDMG  FROM Fj WHERE NrRendor=@NrRendor));
-- Fk-Arka
   SELECT T15Dok='FJ-ArFk   ',* FROM FK          WHERE NrRendor =(SELECT NRDFK 
                                                                    FROM Arka
                                                                   WHERE NrRendor =(SELECT NRRENDORAR FROM Fj WHERE NrRendor=@NrRendor));
   SELECT T16Dok='FJ-ArFkRow',* FROM FKScr       WHERE Nrd      =(SELECT NRDFK 
                                                                    FROM Arka
                                                                   WHERE NrRendor =(SELECT NRRENDORAR FROM Fj WHERE NrRendor=@NrRendor));
*/
GO
