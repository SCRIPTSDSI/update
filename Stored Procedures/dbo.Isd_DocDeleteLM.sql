SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE       Procedure [dbo].[Isd_DocDeleteLM]
( 
  @PTableName     Varchar(30),
  @PNrRendor      Int,
  @PPerdorues     Varchar(30),
  @PLgJob         Varchar(30),
  @PDeleteDoc     Bit
 )

As

-- EXEC dbo.Isd_DocDeleteLM 'ARKA',38031,'ADMIN','',0

BEGIN
         SET NOCOUNT ON

     DECLARE @NrRendor       Int,
             @NrRendorFk     Int,
             @Org            Varchar(10),
             @DocName        Varchar(30),
             @Sql            nVarchar(Max),

             @TableName      Varchar(30),
             @Perdorues      Varchar(30),
             @LgJob          Varchar(30),
             @Vlere          Float;

         SET @NrRendor     = @PNrRendor;
         SET @TableName    = @PTableName;
         SET @Perdorues    = @PPerdorues;
         SET @LgJob        = @PLgJob;


     -- 1.

          IF CHARINDEX(','+@TableName+',',',ARKA,BANKA,VS,FK,VSST,FKST,')<=0 OR 
             ISNULL(@NrRendor,0)<=0
             RETURN;




     -- 2.

          IF @TableName='ARKA'
             BEGIN

                    SELECT @NrRendorFk = ISNULL(NRDFK,0),
                           @Vlere      = ISNULL(VLERA,0)
                      FROM ARKA 
                     WHERE NRRENDOR    = @NrRendor;

                      EXEC dbo.LM_DELFK @NrRendorFk
                      EXEC dbo.Isd_GjenerimDitarOne  @TableName,-1,@NrRendor;
                      EXEC dbo.Isd_AppendTransLog    @TableName,   @NrRendor,@Vlere,'F',@Perdorues,@LgJob;

                        IF @PDeleteDoc=1
                           BEGIN
                             DELETE 
                               FROM ARKA 
                              WHERE NRRENDOR = @NrRendor;
                           END;

                    RETURN;

             END;

     -- 3.

          IF @TableName='BANKA'
             BEGIN


                    SELECT @NrRendorFk = ISNULL(NRDFK,0),
                           @Vlere      = ISNULL(VLERA,0)
                      FROM BANKA 
                     WHERE NRRENDOR    = @NrRendor;

                      EXEC dbo.LM_DELFK @NrRendorFk
                      EXEC dbo.Isd_GjenerimDitarOne  @TableName,-1,@NrRendor;
                      EXEC dbo.Isd_AppendTransLog    @TableName,   @NrRendor,@Vlere,'F',@Perdorues,@LgJob;

                        IF @PDeleteDoc=1
                           BEGIN
                             DELETE 
                               FROM BANKA 
                              WHERE NRRENDOR = @NrRendor;
                           END;

                    RETURN;

             END;

     -- 4.
          IF @TableName='VS'
             BEGIN


                    SELECT @NrRendorFk = Max(ISNULL(A.NRDFK,0)),
                           @Vlere      = Sum(ISNULL(B.DB,0))
                      FROM VS A INNER JOIN VSSCR B On A.NRRENDOR=B.NRD 
                     WHERE A.NRRENDOR  = @NrRendor
                  GROUP BY A.NRRENDOR;

                      EXEC dbo.LM_DELFK              @NrRendorFk
                      EXEC dbo.Isd_GjenerimDitarOne  @TableName,-1,@NrRendor;
                      EXEC dbo.Isd_AppendTransLog    @TableName,   @NrRendor,@Vlere,'F',@Perdorues,@LgJob;

                        IF @PDeleteDoc=1
                           BEGIN
                             DELETE 
                               FROM VS 
                              WHERE NRRENDOR = @NrRendor;
                           END;

                    RETURN;

             END;

     -- 5.

          IF @TableName='FK'
             BEGIN

          -- 5.1

                    SELECT @Vlere      = Sum(ISNULL(B.DB,0)),
                           @Org        = Max(ISNULL(A.ORG,''))
                      FROM FK A INNER JOIN FKSCR B On A.NRRENDOR=B.NRD 
                     WHERE A.NRRENDOR  = @NrRendor
                  GROUP BY A.NRRENDOR;

                    SELECT @DocName = dbo.Isd_DocNameFromOrg(@Org,'')

                        IF @Org='T'
                           EXEC dbo.Isd_AppendTransLog    @TableName,   @NrRendor,@Vlere,'F',@Perdorues,@LgJob;

                        IF ISNULL(@DocName,'')<>'' AND @DocName<>'FK'
                           BEGIN
                              SET  @Sql = '
                                              UPDATE '+@DocName+'
                                                 SET NRDFK=0 
                                               WHERE ISNULL(NRDFK,0) = '+CAST(CAST(@NrRendor As BigInt) As Varchar);
                             EXEC (@Sql);
                           END;

                        IF @PDeleteDoc=1
                           BEGIN
                             DELETE 
                               FROM FK 
                              WHERE NRRENDOR = @NrRendor;
                           END;
                       
                    RETURN;
             END;

          IF @TableName='FKST'
             BEGIN

          -- 5.2

                    SELECT @Vlere      = Sum(ISNULL(B.DB,0))
                      FROM FKST A INNER JOIN FKSTSCR B On A.NRRENDOR=B.NRD 
                     WHERE A.NRRENDOR  = @NrRendor
                  GROUP BY A.NRRENDOR;

                      EXEC dbo.Isd_AppendTransLog    @TableName,   @NrRendor,@Vlere,'F',@Perdorues,@LgJob;

                        IF @PDeleteDoc=1
                           BEGIN
                             DELETE 
                               FROM FKST 
                              WHERE NRRENDOR = @NrRendor;
                           END;

                    RETURN;
             END;


          IF @TableName='VSST'
             BEGIN

          -- 5.3

                    SELECT @Vlere      = Sum(ISNULL(B.DB,0))
                      FROM VSST A INNER JOIN VSSTSCR B On A.NRRENDOR=B.NRD 
                     WHERE A.NRRENDOR  = @NrRendor
                  GROUP BY A.NRRENDOR;

                      EXEC dbo.Isd_AppendTransLog    @TableName,   @NrRendor,@Vlere,'F',@Perdorues,@LgJob;

                        IF @PDeleteDoc=1
                           BEGIN
                             DELETE 
                               FROM VSST 
                              WHERE NRRENDOR = @NrRendor;
                           END;

                    RETURN;
             END;

END;
GO
