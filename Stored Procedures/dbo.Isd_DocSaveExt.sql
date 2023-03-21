SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--        EXEC dbo.Isd_DocSaveExt 'AQHISTORISCR',41,'M','','ADMIN','1234567890'

CREATE Procedure [dbo].[Isd_DocSaveExt]
(
  @PTableName     Varchar(50),
  @PNrRendor      Int,
  @PIDMStatus     Varchar(10),
  @PTableTmpLm    Varchar(40),
  @PPerdorues     Varchar(30),
  @PLgJob         Varchar(30)
 )

As

         SET NOCOUNT ON

     DECLARE @NrRendor       Int,
             @IDMStatus      Varchar(10),
             @TableTmpLm     Varchar(40),
             @Perdorues      Varchar(30),
             @LgJob          Varchar(30),
             @TableName      Varchar(30),
             @NrRendorFk     Int,
             @AutoPostLm     Bit,
             @sSql           nVarchar(MAX),
             @Transaksion    Varchar(20),
             @Vlere          Float;

         SET @NrRendor     = @PNrRendor;
         SET @IDMStatus    = @PIDMStatus;
         SET @TableTmpLm   = @PTableTmpLm;
         SET @Perdorues    = @PPerdorues;
         SET @LgJob        = @PLgJob;
         SET @TableName    = @PTableName;
         SET @AutoPostLm   = 0;
         SET @Transaksion  = 'IFMDS';  -- DELETE me F apo D, INSERT me I apo S


          IF CHARINDEX(','+@TableName+',',',DG,AQ,FJT,ORF,ORK,OFK,SM,AQHISTORISCR,')<=0 Or @NrRendor<=0 Or @IDMStatus='' 
             RETURN;



--      Test per Kod-e, referenca, kurse etj.
        EXEC dbo.Isd_DocSaveTestFields @TableName,@NrRendor,@IDMStatus;

          IF CHARINDEX(','+@TableName+',',',FJT,ORK,OFK,')>0
             BEGIN
             
               SET @sSql = '
               UPDATE A
                  SET A.AGJENTSHITJELINK = ISNULL(B.KODMASTER,'''')
                 FROM '+@TableName+' A INNER JOIN AGJENTSHITJE B ON ISNULL(A.KLASIFIKIM,'''')=B.KOD
                WHERE A.NRRENDOR='+CAST(CAST(@NrRendor AS BIGINT) AS VARCHAR)+';';
                
                EXEC (@sSql);
                
             END;



          -- Perdore ketu qe ta perdorin edhe Magazina dhe Arka
          IF OBJECT_ID('TempDb..'+@TableTmpLm) IS NOT NULL
             BEGIN
               EXEC ('DROP TABLE '+@TableTmpLm);
             END;  


-- 1. 

      SELECT @AutoPostLm  = CASE WHEN @TableName='DG' THEN ISNULL(AUTOPOSTLMDG,0)
                                 WHEN @TableName='AQ' THEN ISNULL(AUTOPOSTLMAQ,0) 
                                 ELSE 0
                            END          
        FROM CONFIGLM;
        
          IF @TableName='DG'
             BEGIN
               SELECT @NrRendorFk   = MAX(ISNULL(A.NRDFK,0)),
                      @Vlere        = Sum(B.VLERATAT)
                 FROM DG A INNER JOIN DGSCR B On A.NRRENDOR=B.NRD
                WHERE A.NRRENDOR = @NrRendor;
             END;

          IF @TableName='AQ'
             BEGIN
             
               SELECT @NrRendorFk   = MAX(ISNULL(A.NRDFK,0)),
                      @Vlere        = Sum(B.VLERAM)
                 FROM AQ A INNER JOIN AQSCR B On A.NRRENDOR=B.NRD
                WHERE A.NRRENDOR = @NrRendor;

                 Exec dbo.Isd_KrijimKodAQ  @NrRendor,0;

             END;

          IF @NrRendorFk>=1
             EXEC dbo.LM_DelFk @NrRendorFk;
              

          IF CHARINDEX(','+@TableName+',', ',DG,AQ,AQHISTORISCR,')=0
             BEGIN
               SET  @sSql = '
                    SELECT @Vlere= VLERTOT FROM '+@TableName+' WHERE NRRENDOR = @NrRendor; ';
   
               EXEC Sp_Executesql @sSql, N'@NrRendor Int, @Vlere Float Out', @NrRendor, @Vlere Out ;
             END;


-- 2.
             
          IF CHARINDEX(@IDMStatus,@Transaksion)>0 
             BEGIN 
               EXEC dbo.Isd_AppendTransLog @TableName,@NrRendor,@Vlere,@IDMStatus,@Perdorues,@LgJob;
             END;


-- 3.

     -- FJT - Dokument Arke: Fillim

          IF @TableName='FJT'
             BEGIN	
               EXEC dbo.Isd_DocumentArkeFromFt @TableName,0,@NrRendor,@Perdorues,@LgJob;
             END;

     -- FJT - Dokument Arke: Fund


-- 4.   --   Kalimi ne LM


          IF CHARINDEX(','+@TableName+',', ',DG,AQ,')=0
             RETURN;


          IF @NrRendorFk>=1
             BEGIN
               IF ISNULL(@AutoPostLm,0)=1
                  BEGIN
                    DELETE FROM FKSCR          WHERE NRD=@NrRendorFk
                  END 
               ELSE
                  BEGIN
                    DELETE FROM FK             WHERE NRRENDOR=@NrRendorFk;
                    IF @TableName='DG'
                       UPDATE DG   SET NRDFK=0 WHERE NRRENDOR=@NrRendor;
                    IF @TableName='AQ'   
                       UPDATE AQ   SET NRDFK=0 WHERE NRRENDOR=@NrRendor;
                       
                    RETURN;
                  END;
             END;

          IF ISNULL(@AutoPostLm,0)=0 Or @TableTmpLm=''
             RETURN;


          IF @TableName='DG'
             EXEC [Isd_KalimLM] @PTip='G', @PNrRendor=@NrRendor, @PSQLFilter='', @PTableNameTmp=@TableTmpLm; 
          IF @TableName='AQ'   
             EXEC [Isd_KalimLM] @PTip='X', @PNrRendor=@NrRendor, @PSQLFilter='', @PTableNameTmp=@TableTmpLm;
GO
