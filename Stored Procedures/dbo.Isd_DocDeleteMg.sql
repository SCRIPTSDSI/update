SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE       Procedure [dbo].[Isd_DocDeleteMg]
( 
  @PTableName     Varchar(30),
  @PNrRendor      Int,
  @PPerdorues     Varchar(30),
  @PLgJob         Varchar(30),
  @PDeleteDoc     Bit
 )

As

-- EXEC dbo.Isd_DocDeleteMg 'FD',38031,'ADMIN','',0

BEGIN
         SET NOCOUNT ON

     DECLARE @NrRendor       Int,
             @NrRendorFk     Int,
             @NrRendorFt     Int,

             @TableName      Varchar(30),
             @Perdorues      Varchar(30),
             @LgJob          Varchar(30),
             @Sql            nVarchar(Max),
             @Vlere          Float;

         SET @NrRendor     = @PNrRendor;
         SET @TableName    = @PTableName;
         SET @Perdorues    = @PPerdorues;
         SET @LgJob        = @PLgJob;

          IF @TableName<>'FH' AND @TableName<>'FD'
             RETURN;


     -- 1.
          IF @TableName='FH' 
             BEGIN

             -- 1.1
                    SELECT @NrRendorFt   = Max(ISNULL(A.NRRENDORFAT,0)),
                           @NrRendorFk   = Max(ISNULL(A.NRDFK,0)),
                           @Vlere        = Sum(B.VLERAM)
                      FROM FH A INNER JOIN FHSCR B On A.NRRENDOR=B.NRD
                     WHERE A.NRRENDOR = @NrRendor 
                  GROUP BY A.NRRENDOR;

             -- 1.2
                      EXEC dbo.LM_DELFK @NrRendorFk;
                      EXEC dbo.Isd_AppendTransLog @TableName, @NrRendor, @Vlere, 'F', @Perdorues, @LgJob;

             -- 1.3
                        IF ISNULL(@NrRendorFt,0)<>0
                           BEGIN
                             UPDATE FF  SET NRRENDDMG=0  WHERE NRRENDOR=@NrRendorFt AND ISNULL(NRRENDDMG,0)<>0; 
                           END;
             -- 1.4

                        IF @PDeleteDoc=1
                           BEGIN
                             DELETE  FROM FH  WHERE NRRENDOR=@NrRendor; 
                           END

                        ELSE

                        IF ISNULL(@NrRendorFk,0)<>0
                           BEGIN
                             UPDATE FH  SET NRDFK=0  WHERE NRRENDOR=@NrRendor;
                           END;
             END;




       -- 2.
          IF @TableName='FD' 
             BEGIN

             -- 2.1

                    SELECT @NrRendorFt   = Max(ISNULL(A.NRRENDORFAT,0)),
                           @NrRendorFk   = Max(ISNULL(A.NRDFK,0)),
                           @Vlere        = Sum(B.VLERAM)
                      FROM FD A INNER JOIN FDSCR B On A.NRRENDOR=B.NRD
                     WHERE A.NRRENDOR = @NrRendor 
                  GROUP BY A.NRRENDOR

             -- 2.2
                      EXEC dbo.LM_DELFK @NrRendorFk;
                      EXEC dbo.Isd_AppendTransLog @TableName, @NrRendor, @Vlere, 'F', @Perdorues, @LgJob

             -- 2.3
                        IF ISNULL(@NrRendorFt,0)<>0
                           BEGIN
                             UPDATE FJ  SET NRRENDDMG=0  WHERE NRRENDOR=@NrRendorFt AND ISNULL(NRRENDDMG,0)<>0; 
                           END;

             -- 2.4
                        IF @PDeleteDoc=1
                           BEGIN
                             DELETE  FROM FD  WHERE NRRENDOR=@NrRendor; 
                           END

                        ELSE

                        IF ISNULL(@NrRendorFk,0)<>0
                           BEGIN
                             UPDATE FD  SET NRDFK=0  WHERE NRRENDOR=@NrRendor;
                           END;
             END;



END;
GO
