SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--Exec [dbo].[Isd_ChangeAQFromFt] 'AQSCR',1,'',1,1

CREATE Procedure [dbo].[Isd_ChangeAqFromFt] -- Nuk e di a perdoret ....
(
  @pTableName   Varchar(100),
  @pNrRendor    Int,
  @pKMag        Varchar(30),  -- ??
  @pKurs1       Float,
  @pKurs2       Float
)


AS

BEGIN

         SET NOCOUNT ON

     DECLARE @sSql         nVarchar(Max),
             @TableName    Varchar(30),
             @TableDok     Varchar(30),
             @NrRendor     Int,
             @Kurs1        Float,
             @Kurs2        Float,
             @GetTest      Int,
             @Result       Bit;

         SET @TableName  = UPPER(LTRIM(RTRIM(@pTableName)));
         SET @NrRendor   = @pNrRendor; 
         SET @Kurs1      = ISNULL(@pKurs1,1);
         SET @Kurs2      = ISNULL(@pKurs2,1);

         SET @GetTest    = 2;
         SET @Result     = 0;

          IF (LEFT(@TableName,1) ='#' AND (OBJECT_ID('Tempdb..'+@TableName) IS NULL)) OR
             (LEFT(@TableName,1)<>'#' AND (OBJECT_ID(@TableName) IS NULL)) OR  @NrRendor<=0
             BEGIN
               SET  @GetTest = 0;
               GOTO Display_Result;
             END;




      SELECT @TableDok='FF';
      
          IF CHARINDEX('FJSCR',@TableName)>0
             SET @TableDok = 'FJ';
          
          
          
-- Test per Fature
 
          IF @TableDok='FF'
             BEGIN
               IF (@GetTest<>0) AND 
                  ( EXISTS ( SELECT KURS1,KURS2 FROM FF WHERE NrRendor = @NrRendor 

                             EXCEPT

                             SELECT KURS1=@Kurs1, KURS2=@Kurs2 ) 
                            )
                   BEGIN
                     SET  @GetTest = 1;
                     GOTO Display_Result;
                   END;
             END;


          IF @TableDok='FJ'
             BEGIN
               IF (@GetTest<>0) And 
                  ( EXISTS ( SELECT KURS1,KURS2 FROM FF WHERE NrRendor = @NrRendor 

                             EXCEPT

                             SELECT KURS1=@Kurs1, KURS2=@Kurs2 ) 
                            )
                   BEGIN
                     SET  @GetTest = 1;
                     GOTO Display_Result;
                   END;
             END;


-- Test per AQ

         SET @sSql       = N'

         SET NOCOUNT ON

     DECLARE @ChangeScr    Bit,
             @NrRendor     Int,
             @NrRendorAq   Int,
             @Kurs1        Float,
             @Kurs2        Float;

         SET @NrRendor   = '+Cast(Cast(@NrRendor AS BIGINT) AS VARCHAR)+';
         SET @ChangeScr  = 0;    

      SELECT @NrRendorAq = ISNULL(NRRENDORAQ,0),
             @Kurs1      = KURS1,
             @Kurs2      = KURS2
        FROM '+@TableDok+' A
       WHERE NRRENDOR=@NrRendor;

         SET @NrRendorAq=ISNULL(@NrRendorAq,0);

          IF ( EXISTS ( SELECT KODAF, SASI, 
                               Round((CMIMBS   * @Kurs2)/@Kurs1,3), 
                               Round((VLPATVSH * @Kurs2)/@Kurs1,3),
                               NrRow = (SELECT COUNT(*) FROM FFSCR WHERE NrD=@NrRendor AND TIPKLL=''X'')
                          FROM '+@TableDok+'SCR
                         WHERE NrD = @NrRendor And TIPKLL=''X''

                        EXCEPT

                        SELECT KODAF, SASI, CMIMOR, VLERAOR, 
                               NrRow = (SELECT COUNT(*) FROM AQSCR WHERE NrD=@NrRendorAq)
                          FROM AQSCR 
                         WHERE NrD = @NrRendorAq ) ) 

             OR

             ( EXISTS ( SELECT KODAF, SASI, CMIMOR, VLERAOR, 
                               NrRow = (SELECT COUNT(*) FROM AQSCR Where NrD=@NrRendorAq) 
                          FROM AQSCR 
                         WHERE NrD = @NrRendorAq

                        EXCEPT

                        SELECT KODAF, SASI, 
                               Round((CMIMBS   * @Kurs2)/@Kurs1,3), 
                               Round((VLPATVSH * @Kurs2)/@Kurs1,3),
                               NrRow = (SELECT COUNT(*) FROM FFSCR WHERE NrD=@NrRendor AND TIPKLL=''X'') 
                          FROM '+@TableDok+'SCR 
                         WHERE NRD = @NrRendor AND TIPKLL=''X''))

             SET @ChangeScr = 1;


       SET @Result = @ChangeScr;  ';


          IF @TableName<>'FFSCR'
             BEGIN
               SET @sSql = REPLACE(@sSql,'FFSCR',@TableName);
             END;
             
          IF LEFT(@TableName,1)='#'
             BEGIN
               SET @sSql = REPLACE(@sSql,'NRD=@NrRendor AND ','');
             END;
    -- PRINT @sSql;

          IF @GetTest=2
             BEGIN
               EXECUTE sp_ExecuteSql @sSql, N'@Result BIT OUT',@Result OUTPUT;
               IF @Result=0
                  SET @GetTest = 0
               ELSE 
                  SET @GetTest = 1;
             END;



Display_Result:


          IF (@GetTest=1) 
             BEGIN
               SELECT RESULT=CAST(1 AS BIT)
                 FROM AQ
                Where NRRENDOR = (SELECT NRRENDORAQ FROM FF Where NRRENDOR=@NrRendor);
             END;

          IF @GetTest=0
             BEGIN
               SELECT RESULT=CAST(0 AS BIT);
             END;

END
GO
