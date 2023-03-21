SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





-- Exec [Isd_NrDitarToNrRendor] @PDitarName = 'DAR', @PNrDitar = 100;

CREATE        Procedure [dbo].[Isd_NrDitarToNrRendor]
(
  @PDitarName  Varchar(50),
  @PNrDitar    Int,

  @PTableName  Varchar(50)  Output,
  @PPershkrim  Varchar(150) Output, 
  @POrg        Varchar(5)   Output, 
  @PNrRendor   BigInt       Output 
 )

As

         Set NoCount Off

     Declare @TipDok      Varchar(10),
             @TableName   Varchar(50),
             @FieldName   Varchar(30),
             @OrgDok      Varchar(10),
             @NrRendor    Int,
             @Sql         Varchar(Max);

          if Object_Id('TempDB..#TMP') is not null
             DROP TABLE #TMP;
--      Exec(' 
--            Use TempDB   
--             if Exists (SELECT Name FROM Sys.Tables WHERE Object_Id=Object_Id(''#TMP''))
--                DROP TABLE #TMP');

      Select NRRENDOR  = 0,
             TIPDOK    = Replicate(' ',20),
             TABLENAME = Replicate(' ',100),
             FIELDNAME = Replicate(' ',100),
             ORGDOK    = Replicate(' ',10)
        Into #TMP 
       Where 1=2;

         Set @Sql = ' 
                      INSERT INTO #TMP 
                            (TIPDOK,NRRENDOR,TABLENAME,FIELDNAME,ORGDOK) 
                      SELECT TIPDOK,0,'''','''','''' 
                        FROM '+@PDitarName+'
                       WHERE NRRENDOR='+Convert(Varchar,@PNrDitar);
        Exec(@Sql);

      Select @TipDok=TIPDOK
        From #TMP; 

      Delete 
        From #TMP;


          if CharIndex(','+@TipDok+',',',MA,MP,')>0 
             begin
               Set @TableName = 'ARKA';
               Set @OrgDok    = 'A';
               if  @PDitarName<>'DAR'
                   Set @TableName = @TableName+'SCR';
             end
          else
          if CharIndex(','+@TipDok+',',',XK,AB,DB,XJ,CJ,KR,')>0 
             begin
               Set @TableName = 'BANKA';
               Set @OrgDok    = 'B';
                if @PDitarName<>'DBA'
                   Set @TableName = @TableName+'SCR';
             end
          else
          if CharIndex(','+@TipDok+',',',FJ,SJ,')>0 
             begin
               Set @TableName = 'FJ';
               Set @OrgDok    = 'S';
                if @PDitarName<>'DKL'
                   Set @TableName = @TableName+'SCR';
             end
          else
          if CharIndex(','+@TipDok+',',',FF,')>0 
             begin
               Set @TableName = 'FF';
               Set @OrgDok    = 'F';
                if @PDitarName<>'DFU'
                   Set @TableName = @TableName+'SCR';
             end
          else
          if CharIndex(','+@TipDok+',',',SP,')>0 
             begin
               Set @TableName = 'VSSCR';
               Set @OrgDok    = 'E';
             end;


         Set @FieldName = 'NRRENDOR';
          if CharIndex('SCR',@TableName)>0
             Set @FieldName = 'NRD';

          if @TableName='FJ'

             Set @Sql = '
                  INSERT INTO #TMP
                        (NRRENDOR,TABLENAME,TIPDOK,FIELDNAME,ORGDOK) 
                  SELECT '+@FieldName+','''+@TableName+''','''+@TipDok+''','''+@FieldName+''','''+@OrgDok+'''
                    FROM '+@TableName+'
                   WHERE NRDITAR     = '+Convert(Varchar,@PNrDitar)+' OR 
                         NRDITARSHL  = '+Convert(Varchar,@PNrDitar)+' OR
                         NRDITARPRMC = '+Convert(Varchar,@PNrDitar) 
          else
          if @TableName='FF'

             Set @Sql = '
                  INSERT INTO #TMP
                        (NRRENDOR,TABLENAME,TIPDOK,FIELDNAME,ORGDOK) 
                  SELECT '+@FieldName+','''+@TableName+''','''+@TipDok+''','''+@FieldName+''','''+@OrgDok+'''
                    FROM '+@TableName+'
                   WHERE NRDITAR     = '+Convert(Varchar,@PNrDitar)+' OR 
                         NRDITARSHL  = '+Convert(Varchar,@PNrDitar) 

          else

             Set @Sql = '
                  INSERT INTO #TMP
                        (NRRENDOR,TABLENAME,TIPDOK,FIELDNAME,ORGDOK) 
                  SELECT '+@FieldName+','''+@TableName+''','''+@TipDok+''','''+@FieldName+''','''+@OrgDok+'''
                    FROM '+@TableName+'
                   WHERE NRDITAR     = '+Convert(Varchar,@PNrDitar); 

        Exec (@Sql);

      Select @PTableName = TABLENAME, 
             @PPershkrim = '', 
             @POrg       = ORGDOK, 
             @PNrRendor  = NRRENDOR
        From #TMP;

--SELECT * FROM #TMP
--Print @PTableName
--Print @POrg
--Print @PNrRendor

          if Object_Id('TempDB..#TMP') is not null
             DROP TABLE #TMP;
GO
