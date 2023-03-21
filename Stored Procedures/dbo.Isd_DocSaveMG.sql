SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE      Procedure [dbo].[Isd_DocSaveMG]
( 
  @PTableName     Varchar(30),
  @PNrRendor      Int,
  @PPerdorues     Varchar(30),
  @PLgJob         Varchar(30),
  @PIDMStatus     Varchar(10),
  @PTableTmp      Varchar(30)
 )

As

-- EXEC dbo.Isd_DocSaveMG 'FH',94428,'ADMIN','','M','##A001'

BEGIN  


         SET NOCOUNT ON


     DECLARE @TableName      Varchar(30),
             @NrRendor       Int,
             @Perdorues      Varchar(30),
             @LgJob          Varchar(30),
             @IDMStatus      Varchar(10),
             @TableTmp       Varchar(30),
             @Transaksion    Varchar(20),
             @KMag           Varchar(30),
             @NrMag          Int,
             @NrRndMg        Int,

             @NrRendorFk     Int,
             @AutoPostLM     Bit,
             @Org            Varchar(5),
             @ShkarkimPrdk   Bit,
             @Vlere          Float,
             @KMagLnk        Varchar(30),
             @NrDokLnk       Int;

         SET @Transaksion  = 'IFMDS';  -- DELETE me F apo D, INSERT me I apo S

         SET @TableName    = ISNULL(@PTableName,'');
         SET @NrRendor     = ISNULL(@PNrRendor,0);
         SET @Perdorues    = @PPerdorues;
         SET @LgJob        = @PLgJob;
         SET @IDMStatus    = ISNULL(@PIDMStatus,'');
         SET @TableTmp     = ISNULL(@PTableTmp,'');
         SET @ShkarkimPrdk = 0;
         SET @AutoPostLM   = 0;

          IF CHARINDEX(','+@TableName+',',',FH,FD,')<=0 OR @NrRendor<=0 OR @IDMStatus=''
             RETURN;




      SELECT @AutoPostLM   = CASE WHEN @TableName='FH' THEN ISNULL(AUTOPOSTLMFH,0)
                                  WHEN @TableName='FD' THEN ISNULL(AUTOPOSTLMFD,0) 
                                  ELSE 0 
                             END
        FROM CONFIGLM;


         SET @AutoPostLM     = ISNULL(@AutoPostLM,0);    

          IF @AutoPostLM=1 AND @TableTmp<>''
             BEGIN
               IF OBJECT_ID('TempDB..'+@TableTmp) IS NOT NULL
                  EXEC ('DELETE FROM '+@TableTmp);
             END;



-- Test KMag e mbushur sakte ose jo, NRMAG, KMAGRF, KMAGLNK
        EXEC dbo.Isd_DocSaveTestFields @TableName,@NrRendor,@IDMStatus;



--    *****     FH     *****    --



          IF @TableName='FH'
             BEGIN

                  SET @Org          = 'H'

    -- 1.1
               SELECT @KMag         = MAX(ISNULL(A.KMAG,'')),
                      @NrMag        = MAX(ISNULL(A.NRMAG,0)),

                      @NrRendorFk   = MAX(ISNULL(A.NRDFK,0)),
                      @Vlere        = Sum(ISNULL(B.VLERAM,0)),
                      @KMagLnk      = MAX(ISNULL(A.KMAGLNK,'')),
                      @NrDokLnk     = MAX(ISNULL(A.NRDOKLNK,0)),
                      @ShkarkimPrdk = CASE WHEN MAX(ISNULL(A.DST,''))='PR' THEN 1 ELSE 0 END
                                             -- MAX(ISNULL(A.DOK_JB,0))=0 AND MAX(ISNULL(A.DST,''))='PR'
                 FROM FH A INNER JOIN FHSCR B On A.NRRENDOR=B.NRD
                WHERE A.NRRENDOR = @NrRendor
             GROUP BY A.NRRENDOR;



       -- Fillim Test per NRMAG
               SELECT @NrRndMg = NRRENDOR  FROM MAGAZINA  WHERE KOD=@KMag;

                   IF ISNULL(@NrMag,0)<>ISNULL(@NrRndMg,0)
                      BEGIN
                        UPDATE FH  SET NRMAG = ISNULL(@NrRndMg,0)  WHERE NRRENDOR=@NrRendor;
                      END;
       -- Fund   Test per NRMAG



    -- 1.2
               UPDATE A 
                  SET KONVERTART = ROUND(CASE WHEN ISNULL(B.KONV2,1)*ISNULL(B.KONV1,1)<=0 
                                              THEN 1 
                                              ELSE ISNULL(B.KONV2,1)/ISNULL(B.KONV1,1) 
                                         END,3) 
                 FROM FHSCR A INNER JOIN ARTIKUJ B On A.KARTLLG=B.KOD 
                WHERE A.NRD=@NrRendor;


    -- 1.3
               INSERT INTO LMG
                     (KOD,SG1,SG2,SG3,SG4,SG5,PERSHKRIM,
                      KMON,NRMAG,SASI,VLERE)

               SELECT A.KOD, A.SG1, A.SG2, A.SG3, A.SG4, A.SG5,
                      PERSHKRIM = CASE WHEN SG1<>'' THEN ''                  ELSE '' END +
                                  CASE WHEN SG2<>'' THEN       R2.PERSHKRIM  ELSE '' END +
                                  CASE WHEN SG3<>'' THEN ' / '+R3.PERSHKRIM  ELSE '' END +
                                  CASE WHEN SG4<>'' THEN ' / '+R4.PERSHKRIM  ELSE '' END,
                      KMON='', NRMAG=0, SASI=0, VLERE=0
                 FROM
              (
               SELECT A.KOD,
                      SG1 = Dbo.Isd_SegmentFind(A.KOD,0,1),
                      SG2 = Dbo.Isd_SegmentFind(A.KOD,0,2),
                      SG3 = Dbo.Isd_SegmentFind(A.KOD,0,3),
                      SG4 = Dbo.Isd_SegmentFind(A.KOD,0,4),
                      SG5 = ''
                 FROM FHSCR A LEFT JOIN LMG B ON A.KOD = B.KOD 
                WHERE A.NRD=@NrRendor AND ISNULL(B.KOD,'')=''
               ) 
                   A  LEFT JOIN MAGAZINA    R1 On A.SG1=R1.KOD
                      LEFT JOIN ARTIKUJ     R2 On A.SG2=R2.KOD
                      LEFT JOIN DEPARTAMENT R3 On A.SG3=R3.KOD
                      LEFT JOIN LISTE       R4 On A.SG4=R4.KOD
             ORDER BY A.KOD;


    -- 1.4
                   IF ISNULL(@KMagLnk,'')<>'' AND ISNULL(@NrDokLnk,0)>0
                      BEGIN
                        UPDATE B 
                           SET B.KMAGLNK    = A.KMAG,    B.NRDOKLNK   = A.NRDOK,
                               B.NRFRAKSLNK = A.NRFRAKS, B.DATEDOKLNK = A.DATEDOK
                          FROM FD B,

                                 ( SELECT KMAG,    NRDOK,    NRFRAKS,    DATEDOK,
                                          KMAGLNK, NRDOKLNK, NRFRAKSLNK, DATEDOKLNK
                                     FROM FH A 
                                    WHERE A.NRRENDOR = @NrRendor ) A
             
                         WHERE ISNULL(B.KMAG,'')   = A.KMAGLNK    AND ISNULL(B.NRDOK,0)         = A.NRDOKLNK        AND 
                               ISNULL(B.NRFRAKS,0) = A.NRFRAKSLNK AND ISNULL(YEAR(B.DATEDOK),0) = YEAR(A.DATEDOKLNK); 
                      END;

             END;




--    *****     FD     *****    --



          IF @TableName='FD'
             BEGIN

                  SET @Org          = 'D'

                   IF EXISTS (SELECT 1 FROM ARTIKUJ WHERE AUTOSHKLPFDBR=1)
                      SET @ShkarkimPrdk = 1;


    -- 2.1
               SELECT @KMag         = MAX(ISNULL(A.KMAG,'')),
                      @NrMag        = MAX(ISNULL(A.NRMAG,0)),

                      @NrRendorFk   = MAX(ISNULL(A.NRDFK,0)),
                      @Vlere        = Sum(ISNULL(B.VLERAM,0)),
                      @KMagLnk      = MAX(ISNULL(A.KMAGLNK,'')),
                      @NrDokLnk     = MAX(ISNULL(A.NRDOKLNK,0)),
                      @ShkarkimPrdk = MAX(CASE WHEN ISNULL(A.DOK_JB,0)=0 THEN @ShkarkimPrdk ELSE 0 END)
                 FROM FD A INNER JOIN FDSCR B On A.NRRENDOR=B.NRD
                WHERE A.NRRENDOR = @NrRendor
             GROUP BY A.NRRENDOR;



       -- Fillim Test per NRMAG
               SELECT @NrRndMg = NRRENDOR  FROM MAGAZINA  WHERE KOD=@KMag;

                   IF ISNULL(@NrMag,0)<>ISNULL(@NrRndMg,0)
                      BEGIN
                        UPDATE FD SET NRMAG=ISNULL(@NrRndMg,0) WHERE NRRENDOR=@NrRendor;
                      END;
       -- Fund   Test per NRMAG



    -- 2.2 
               UPDATE A 
                  SET KONVERTART = ROUND(CASE WHEN ISNULL(B.KONV2,1)*ISNULL(B.KONV1,1)<=0 
                                              THEN 1 
                                              ELSE ISNULL(B.KONV2,1)/ISNULL(B.KONV1,1) 
                                         END,3) 
                 FROM FDSCR A INNER JOIN ARTIKUJ B On A.KARTLLG=B.KOD 
                WHERE A.NRD=@NrRendor;


    -- 2.3
               INSERT INTO LMG
                     (KOD,SG1,SG2,SG3,SG4,SG5,PERSHKRIM,
                      KMON,NRMAG,SASI,VLERE)

               SELECT A.KOD, A.SG1, A.SG2, A.SG3, A.SG4, A.SG5,
                      PERSHKRIM = CASE WHEN SG1<>'' THEN ''                 ELSE '' END +
                                  CASE WHEN SG2<>'' THEN       R2.PERSHKRIM ELSE '' END +
                                  CASE WHEN SG3<>'' THEN ' / '+R3.PERSHKRIM ELSE '' END +
                                  CASE WHEN SG4<>'' THEN ' / '+R4.PERSHKRIM ELSE '' END,
                      KMON='', NRMAG=0, SASI=0, VLERE=0
                 FROM
              (
               SELECT A.KOD,
                      SG1 = Dbo.Isd_SegmentFind(A.KOD,0,1),
                      SG2 = Dbo.Isd_SegmentFind(A.KOD,0,2),
                      SG3 = Dbo.Isd_SegmentFind(A.KOD,0,3),
                      SG4 = Dbo.Isd_SegmentFind(A.KOD,0,4),
                      SG5 = ''
                  FROM FDSCR A LEFT JOIN LMG B ON A.KOD = B.KOD 
                WHERE A.NRD=@NrRendor AND ISNULL(B.KOD,'')=''
               ) 
                   A  LEFT JOIN MAGAZINA    R1 On A.SG1=R1.KOD
                      LEFT JOIN ARTIKUJ     R2 On A.SG2=R2.KOD
                      LEFT JOIN DEPARTAMENT R3 On A.SG3=R3.KOD
                      LEFT JOIN LISTE       R4 On A.SG4=R4.KOD
             ORDER BY A.KOD;


    -- 2.4
                   IF ISNULL(@KMagLnk,'')<>'' AND ISNULL(@NrDokLnk,0)>0
                      BEGIN
                        UPDATE B 
                           SET B.KMAGLNK    = A.KMAG,    B.NRDOKLNK   = A.NRDOK,
                               B.NRFRAKSLNK = A.NRFRAKS, B.DATEDOKLNK = A.DATEDOK
                          FROM FH B,

                                 ( SELECT KMAG,    NRDOK,    NRFRAKS,    DATEDOK,
                                          KMAGLNK, NRDOKLNK, NRFRAKSLNK, DATEDOKLNK
                                     FROM FD A 
                                    WHERE A.NRRENDOR = @NrRendor ) A
             
                         WHERE ISNULL(B.KMAG,'')   = A.KMAGLNK    AND ISNULL(B.NRDOK,0)         = A.NRDOKLNK        AND 
                               ISNULL(B.NRFRAKS,0) = A.NRFRAKSLNK AND ISNULL(YEAR(B.DATEDOK),0) = YEAR(A.DATEDOKLNK); 
                      END;
                   


             END;







    -- 3.1 
          IF @ShkarkimPrdk=1
             BEGIN
               EXEC dbo.Isd_ShkarkimProdukt @Org, @NrRendor;
             END;


    -- 3.2
          IF CHARINDEX(@IDMStatus,@Transaksion)>0  
             BEGIN
               EXEC dbo.Isd_AppendTransLog @TableName, @NrRendor, @Vlere, @IDMStatus, @Perdorues, @LgJob;
             END;


    -- 3.3.1
          IF @NrRendorFk>=1
             BEGIN

               DELETE FROM  FK  WHERE NrRendor=@NrRendorFk;

               IF @TableName='FH'
                  UPDATE FH  SET NRDFK=0  WHERE NRRENDOR = @NrRendor AND NRDFK<>0;

               IF @TableName='FD'
                  UPDATE FD  SET NRDFK=0  WHERE NRRENDOR = @NrRendor AND NRDFK<>0;

             END;

    -- 3.3.2
          IF @AutoPostLM=1
             BEGIN
               EXEC [Isd_KalimLM] @Org, @NrRendor, '', @TableTmp;
             END;


END;


GO
