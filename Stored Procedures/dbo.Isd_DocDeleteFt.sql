SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE       Procedure [dbo].[Isd_DocDeleteFt]
( 
  @PTableName     Varchar(30),
  @PNrRendor      Int,
  @PPerdorues     Varchar(30),
  @PLgJob         Varchar(30),
  @PDeleteDoc     Bit
 )

As

-- EXEC dbo.Isd_DocDeleteFt 'FF',38031,'ADMIN','',0

BEGIN
         SET NOCOUNT ON

     DECLARE @NrRendor       Int,
             @NrRendorFk     Int,
             @NrRendorMg     Int,
             @NrRendorArk    Int,
             @NrRendorAmb    Int,
             @NrRendorAq     Int,
             @NrID           Int,

             @TableName      Varchar(30),
             @TableMgName    Varchar(30),
             @Perdorues      Varchar(30),
             @LgJob          Varchar(30),
             @Sql            nVarchar(Max),
             @Vlere          Float;

         SET @NrRendor     = @PNrRendor;
         SET @TableName    = @PTableName;
         SET @Perdorues    = @PPerdorues;
         SET @LgJob        = @PLgJob;
         SET @TableMgName  = '';

          IF @TableName<>'FJ' AND @TableName<>'FF'
             RETURN;

         SET @Sql = '
                    SELECT @NrID         = NRRENDOR,
                           @NrRendorMg   = NRRENDDMG,
                           @NrRendorFk   = NRDFK,
                           @NrRendorArk  = NRRENDORAR,
                           @NrRendorAmb  = NRRENDORAMB,
                           @NrRendorAq   = NRRENDORAQ,
                           @Vlere        = VLERTOT  
                      FROM '+@TableName+' 
                     WHERE NRRENDOR = @NrRendor ';
   
        EXEC Sp_Executesql @Sql, N'@NrRendor Int, @NrID Int Out, @NrRendorMg Int Out, @NrRendorFk Int Out, @NrRendorArk Int Out, @NrRendorAmb Int Out, @NrRendorAq Int Out, @Vlere Float Out', 
                                   @NrRendor,     @NrID     Out, @NrRendorMg     Out, @NrRendorFk     Out, @NrRendorArk     Out, @NrRendorAmb     Out, @NrRendorAq     Out, @Vlere       Out ;


         SET @TableMgName='FH'

          IF @TableName='FJ'
             BEGIN

                  SET @TableMgName='FD'
     -- 1.
               DELETE 
                 FROM FJPG 
                WHERE NRD = @NrRendor;
                               
               DELETE 
                 FROM FJSHOQERUES 
                WHERE NRD = @NrRendor;

             END;


     -- 2.
        EXEC dbo.Isd_GjenerimDitarOne @TableName,-1,@NrID;
        EXEC dbo.LM_DELFK @NrRendorFk;
        EXEC dbo.Isd_AppendTransLog @TableName, @NrRendor, @Vlere, 'F', @Perdorues, @LgJob

     -- 3.
          IF ISNULL(@NrRendorArk,0)<>0
             BEGIN 

               SELECT @NrID       = NRRENDOR,
                      @NrRendorFk = NRDFK,
                      @Vlere      = VLERA
                 FROM ARKA 
                WHERE NRRENDOR = @NrRendorArk;

                   IF ISNULL(@NrID,0)>0
                      BEGIN
                        EXEC dbo.LM_DELFK @NrRendorFk
                        EXEC dbo.Isd_GjenerimDitarOne  'ARKA',-1,@NrID;
                        EXEC dbo.Isd_AppendTransLog    'ARKA',   @NrID,@Vlere,'F',@Perdorues,@LgJob

                        DELETE 
                          FROM ARKA 
                         WHERE NRRENDOR = @NrID
                      END;
             END;

     -- 4.
          IF ISNULL(@NrRendorMg,0)<>0
             BEGIN

                SET @Sql = '
                    SELECT @NrID       = A.NRRENDOR,
                           @NrRendorFk = Max(A.NRDFK),
                           @Vlere      = Sum(B.VLERAM) 
                      FROM '+@TableMgName+' A INNER JOIN '+@TableMgName+'Scr B On A.NRRENDOR=B.NRD 
                     WHERE A.NRRENDOR = @NrRendorMg 
                  GROUP BY A.NRRENDOR'

                 EXEC Sp_Executesql @Sql, N'@NrRendorMg Int, @NrID Int Out, @NrRendorFk Int Out, @Vlere Float Out ', 
                                            @NrRendorMg,     @NrID     Out, @NrRendorFk     Out, @Vlere       Out;
                   IF ISNULL(@NrID,0)>0
                      BEGIN

                        EXEC  dbo.Isd_DocDeleteMg @TableMgName,@NrID,@Perdorues,@LgJob,1;

                   --   EXEC  dbo.LM_DELFK @NrRendorFk;
                   --   EXEC  dbo.Isd_AppendTransLog @TableMgName, @NrID, @Vlere, 'F', @Perdorues, @LgJob;

                   --    SET  @Sql = ' DELETE FROM '+@TableMgName+' WHERE NRRENDOR = '+CAST(CAST(@NrID As BigInt) As Varchar);
                   --   EXEC (@Sql);
                      END;
             END;

     -- 5.
          IF @TableName='FJ' AND (ISNULL(@NrRendorAmb,0)<>0)
             BEGIN
              
                SET @TableMgName = 'FH';
                SET @NrRendorMg  = @NrRendorAmb;
                SET @Sql = '
                      SELECT @NrID       = A.NRRENDOR,
                             @NrRendorFk = Max(A.NRDFK),
                             @Vlere      = Sum(B.VLERAM) 
                        FROM '+@TableMgName+' A INNER JOIN '+@TableMgName+'Scr B On A.NRRENDOR=B.NRD 
                       WHERE A.NRRENDOR = @NrRendorMg 
                    GROUP BY A.NRRENDOR'

               EXEC Sp_Executesql @Sql, N'@NrRendorMg Int, @NrID Int Out, @NrRendorFk Int Out, @Vlere Float Out ', 
                                          @NrRendorMg,     @NrID     Out, @NrRendorFk     Out, @Vlere       Out;

                 IF ISNULL(@NrID,0)>0
                    EXEC  dbo.Isd_DocDeleteMg @TableMgName,@NrID,@Perdorues,@LgJob,1;

             END;

     -- 6.
          IF ISNULL(@NrRendorAq,0)<>0
             BEGIN
              
                SET @Sql = '
                      SELECT @NrID       = A.NRRENDOR,
                             @NrRendorFk = Max(A.NRDFK),
                             @Vlere      = Sum(B.VLERABS) 
                        FROM AQ A INNER JOIN AQSCR B On A.NRRENDOR=B.NRD 
                       WHERE A.NRRENDOR = @NrRendorAq 
                    GROUP BY A.NRRENDOR'

               EXEC Sp_Executesql @Sql, N'@NrRendorAq Int, @NrID Int Out, @NrRendorFk Int Out, @Vlere Float Out ', 
                                          @NrRendorAq,     @NrID     Out, @NrRendorFk     Out, @Vlere       Out;

                 IF ISNULL(@NrID,0)>0
                    EXEC  dbo.Isd_DocDeleteExt 'AQ',@NrID,@Perdorues,@LgJob,1;

             END;

     -- 7.
          IF @PDeleteDoc=1
             BEGIN

                SET  @Sql = ' DELETE FROM '+@TableName+' WHERE NRRENDOR = '+CAST(CAST(@NrRendor As BigInt) As Varchar);
               EXEC (@Sql);

             END
          ELSE
          IF ISNULL(@NrRendorFk,0)>0
             BEGIN

                SET  @Sql = ' UPDATE '+@TableName + '
                                 SET NRDFK = 0 
                               WHERE NRRENDOR='+CAST(CAST(@NrRendor As BigInt) As Varchar);
               EXEC (@Sql);

             END;


END;
GO
