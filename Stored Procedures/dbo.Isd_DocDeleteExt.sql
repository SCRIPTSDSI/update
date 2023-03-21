SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE       Procedure [dbo].[Isd_DocDeleteExt]
( 
  @pTableName     Varchar(30),
  @pNrRendor      Int,
  @pPerdorues     Varchar(30),
  @pLgJob         Varchar(30),
  @pDeleteDoc     Bit
 )

As

-- EXEC dbo.Isd_DocDeleteExt 'DG',38031,'ADMIN','',0

BEGIN

         SET NOCOUNT ON

     DECLARE @NrRendor       Int,
             @NrRendorArk    Int,
             @NrRendorFk     Int,
             @NrID           Int,

             @TableName      Varchar(30),
             @TableMgName    Varchar(30),
             @Perdorues      Varchar(30),
             @LgJob          Varchar(30),
             @Sql            nVarchar(Max),
             @Dok_JB         Bit,
      --     @PromptField    Varchar(20),
             @sNrRendor      Varchar(20),
             @Vlere          Float;


         SET @NrRendor     = @pNrRendor;
         SET @TableName    = @pTableName;
         SET @Perdorues    = @pPerdorues;
         SET @LgJob        = @pLgJob;
         SET @TableMgName  = '';
         SET @Dok_JB       = 0;
      -- SET @PromptField  = 'VLERTOT';


          IF CHARINDEX(','+@TableName+',',',DG,AQ,FJT,ORF,ORK,OFK,SM,FKST,VSST,')<=0 
             RETURN;


         SET @Sql = '
                    SELECT @NrID         = A.NRRENDOR,
                           @NrRendorArk  = 0,
                           @NrRendorFk   = ISNULL(A.NRDFK,0),
                           @Vlere        = ISNULL(A.VLERTOT,0),
                           @Dok_JB       = CAST(0 AS BIT) 
                      FROM '+@TableName+' A 
                     WHERE A.NRRENDOR = @NrRendor ';


          IF @TableName='DG' OR @TableName='AQ'
             BEGIN

                SET @Sql = '
                    SELECT @NrID         = A.NRRENDOR,
                           @NrRendorArk  = 0,
                           @NrRendorFk   = MAX(ISNULL(A.NRDFK,0)),
                           @Vlere        = SUM(ISNULL(B.VLERATAT,0)),
                           @Dok_JB       = CAST(0 AS BIT) 
                      FROM '+@TableName+' A INNER JOIN '+@TableName+'Scr B On A.NRRENDOR=B.NRD
                     WHERE A.NRRENDOR = @NrRendor
                  GROUP BY A.NRRENDOR;';

                IF @TableName='AQ'
                   BEGIN
                     SET @Sql = Replace(@Sql,'B.VLERATAT,','B.VLERABS,');
                     SET @Sql = Replace(@Sql,'CAST(0 AS BIT)','ISNULL(A.DOK_JB,0)');
                     SET @Sql = Replace(@Sql,'BY A.NRRENDOR;','BY A.NRRENDOR,ISNULL(A.DOK_JB,0);');
                   END;  

             END;     

          IF @TableName='FJT'
             SET @Sql = Replace(@Sql,'= 0,','= A.NRRENDORAR,');

        EXEC Sp_Executesql @Sql, N'@NrRendor Int, @NrID Int Out, @NrRendorFk Int Out, @NrRendorArk Int Out, @Vlere Float Out,@Dok_JB Bit Out', 
                                   @NrRendor,     @NrID     Out, @NrRendorFk     Out, @NrRendorArk     Out, @Vlere       Out,@Dok_JB     Out;



     -- 1.
     
          IF (@NrRendorFk>0) AND (CHARINDEX(','+@TableName+',', ',DG,AQ,')>0)
             EXEC dbo.LM_DELFK @NrRendorFk;
             
        EXEC dbo.Isd_AppendTransLog @TableName, @NrRendor, @Vlere, 'F', @Perdorues, @LgJob



     -- 2.
     
          IF ISNULL(@NrRendorArk,0)<>0                    -- Rasti FJT kur krijon ARKE 
             BEGIN 

               SELECT @NrID       = NRRENDOR,
                      @NrRendorFk = NRDFK,
                      @Vlere      = VLERA
                 FROM ARKA 
                WHERE NRRENDOR = @NrRendorArk;

                   IF ISNULL(@NrID,0)>0
                      BEGIN
                        EXEC   dbo.LM_DELFK @NrRendorFk
                        EXEC   dbo.Isd_GjenerimDitarOne  'ARKA', -1, @NrID;
                        EXEC   dbo.Isd_AppendTransLog    'ARKA',     @NrID, @Vlere, 'F', @Perdorues, @LgJob;

                        DELETE FROM ARKA WHERE NRRENDOR = @NrID;
                      END;
             END;
             
         SET @sNrRendor = CAST(CAST(@NrRendor As BigInt) As Varchar);

     -- 3.
     
         SET @Sql = '';
         
          IF (@TableName='AQ') AND (@Dok_JB=1)
             BEGIN
                SET @Sql = ' 
                    UPDATE FJ SET NRRENDORAQ=0 WHERE NRRENDORAQ='+@sNrRendor+';
                    UPDATE FF SET NRRENDORAQ=0 WHERE NRRENDORAQ='+@sNrRendor+';';
             END;  

          IF @pDeleteDoc=1
             BEGIN

                SET @Sql = @Sql + '
                    DELETE FROM '+@TableName+' WHERE NRRENDOR='+@sNrRendor+';';

             END

          ELSE

          IF CHARINDEX(','+@Tablename+',', ',DG,AQ,')>0 AND ISNULL(@NrRendorFk,0)>0
             BEGIN
 
                SET @Sql = @Sql+'
                    UPDATE '+@TableName+' SET NRDFK=0 WHERE NRRENDOR='+@sNrRendor;
             END;
             
          IF @Sql<>''
             EXEC (@Sql);
             
             
END;
GO
