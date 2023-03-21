SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE         procedure [dbo].[Isd_AQAMSeriDates_Ishte]
(
  @pTableName   Varchar(50),
  @pTableDest   Varchar(50),
  @pEndDate     Varchar(20)
)

AS

--      SELECT NRRENDOR=CAST(0 AS BIGINT),StartDate=DATEDOK,EndDate=DATEDOK,TROW INTO #TempSeri FROM AQ WHERE 1=2;
--      EXEC   dbo.Isd_AQAMSeriDates 'AQ','#TempSeri','31/12/2019';
--      SELECT * FROM #TempSeri;

         
         SET NOCOUNT ON;

     DECLARE @sSql           nVarchar(MAX),
             @i              Int,
             @j              Int,
             @sList          Varchar(MAX),
             @sTableName     Varchar(50),
             @sTableDest     Varchar(50),
             @sNrRendor      Varchar(30),
             @bOk            Bit,
             @sNrTime        Varchar(20),
             @sDokDate       Varchar(30),
             @sEndDate       Varchar(30);
             
         SET @sEndDate     = dbo.DateValue(@pEndDate);
         SET @sTableName   = @pTableName;
         SET @sTableDest   = ISNULL(@pTableDest,'');
         SET @bOk          = 1;
         
          IF OBJECT_ID('TEMPDB..#TempDatesDok') IS NOT NULL
             DROP TABLE #TempDatesDok;
             
          IF OBJECT_ID('TEMPDB..#TempDok') IS NOT NULL
             DROP TABLE #TempDok;

      SELECT NRRENDOR = CAST(0 AS BIGINT), 
             NRTIME   = CAST(0 AS INT), 
             DATEDOK, TROW
        INTO #TempDok
        FROM AQ
       WHERE 1=2;
--EXEC ('SELECT * FROM '+@sTableName);
         SET @sSql = '
             INSERT INTO #TempDok
                   (NRRENDOR,DATEDOK,NRTIME,  TROW)
             SELECT NRRENDOR,DTAM,NRTIMEAM,0    -- ishte NRRENDOR,DATEDOK,NRTIMEAM,0  deri daten 28.08.2018
               FROM '+@sTableName+' 
           ORDER BY NRRENDOR;';
           
       EXEC (@sSql);
       
       
--    SELECT * FROM #TempDok
             

      SELECT NRRENDOR = CAST(0 AS BIGINT), StartDate=DATEDOK, EndDate=DATEDOK, NrTime, TROW
        INTO #TempDatesDok
        FROM #TempDok
       WHERE 1=2;
        
     

       WHILE @bOk=1
         BEGIN


           SELECT @sList = '';
           
           SELECT TOP 1500 @sList = @sList + ','+CAST(NRRENDOR AS VARCHAR)
             FROM #TempDok
            WHERE ISNULL(TROW,0)=0;
           
           UPDATE #TempDok
              SET TROW = 1
            WHERE CHARINDEX(','+CAST(NRRENDOR AS VARCHAR)+',',','+@sList+',')>0;
        
              SET @sList = SUBSTRING(@sList,2,LEN(@sList));
              SET @i     = LEN(@sList) - LEN(REPLACE(@sList,',',''))+1;
              SET @j     = 1;

               IF @sList=''
                  BEGIN 
                    SET @bOk = 0;
                    SET @j   = @i + 1;
                  END;   

         
--          PRINT @sList; 


            WHILE @j<=@i
              BEGIN
              
                     SET @sNrRendor = dbo.Isd_StringInListStr(@sList,@j,',');
                     
                  SELECT @sDokDate = DATEDOK, @sNrTime=NRTIME    -- u zevendesua DATEDOK me DTAM  daten 28.08.2018
                    FROM #TempDok
                   WHERE NRRENDOR=CAST(@sNrRendor AS BIGINT);
                   
                   
                     SET @sSql = '
                 DECLARE @D1      DateTime,
                         @D2      DateTime;
                     SET @D1    = CONVERT(DateTime,'''+@sDokDate+''',104);
                     SET @D2    = CONVERT(DateTime,'''+@sEndDate+''',104);
                     
                  INSERT INTO #TempDatesDok
                        (NRRENDOR,StartDate,EndDate)
                  SELECT '+@sNrRendor+',A.StartDate,A.EndDate 
                    FROM Isd_AQAMDateRange(''m'', '+@sNrTime+', @D1, @D2) A; ';
                  
                -- PRINT  @sSql; 
                    EXEC (@sSql);

                    SET  @j = @j + 1;  

              END;
         
         END;
      
      IF @sTableDest<>''
         BEGIN

           SET   @sSql = '
           
                  INSERT INTO '+@sTableDest+'
                        (NRRENDOR,StartDate,EndDate)
                  SELECT A.NrRendor,A.StartDate,A.EndDate
                    FROM #TempDatesDok A
                ORDER BY A.NrRendor, A.StartDate;';

           EXEC (@sSql);
           
         END;
         
GO
