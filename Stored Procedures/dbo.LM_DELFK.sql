SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[LM_DELFK]
(
@pNrD AS INT
)
AS

     DECLARE @Org        VARCHAR(10),
             @sSql       VARCHAR(MAX),
             @NrRendor   INT,
             @i          INT;

         SET @NrRendor = @pNrD;
         SET @sSql     = '';
         
      SELECT @Org      = ISNULL(ORG,'')
        FROM FK
       WHERE NRRENDOR  = @NrRendor;

         SET @Org      = UPPER(ISNULL(@Org,''));
         

          IF CHARINDEX(@Org,'SFHDGABEX')>0
             BEGIN

                 SET   @sSql = ' UPDATE ARKA SET NRDFK=0 WHERE NRDFK='+CAST(CAST(@NrRendor AS BIGINT) AS VARCHAR(30));

                 IF    @Org='S'
                       SET @sSql = REPLACE(@sSql,' ARKA ',' FJ ')
                 ELSE
                 IF    @Org='F'
                       SET @sSql = REPLACE(@sSql,' ARKA ',' FF ')
                 ELSE
                 IF    @Org='H'
                       SET @sSql = REPLACE(@sSql,' ARKA ',' FH ')
                 ELSE
                 IF    @Org='D'
                       SET @sSql = REPLACE(@sSql,' ARKA ',' FD ')
                 ELSE
                 IF    @Org='G'
                       SET @sSql = REPLACE(@sSql,' ARKA ',' DG ')
                 ELSE
                 IF    @Org='A'
                       SET @sSql = REPLACE(@sSql,' ARKA ',' ARKA ')
                 ELSE
                 IF    @Org='B'
                       SET @sSql = REPLACE(@sSql,' ARKA ',' BANKA ')
                 ELSE
                 IF    @Org='E'
                       SET @sSql = REPLACE(@sSql,' ARKA ',' VS ')
                 ELSE
                 IF    @Org='X'
                       SET @sSql = REPLACE(@sSql,' ARKA ',' AQ ');
                      

                 IF    @sSql<>''
                       EXEC (@sSql);

                 PRINT @sSql;

             END;


      DELETE 
        FROM FK
       WHERE NRRENDOR=@NrRendor;


GO
