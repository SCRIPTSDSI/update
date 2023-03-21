SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[Isd_AQAMDateRange]
(     
  @Increment              CHAR(1),        -- Per amortizimin .....
  @iIncrement             Int,
  @StartDate              DATETIME,
  @EndDate                DATETIME
)

RETURNS  

   @SelectedRange  TABLE 
    (
      StartDate    DateTime,
      EndDate      DateTime
     )
  
AS
 
-- Declare @D1 DateTime,
--         @D2 DateTime;
-- SET @D1 = CONVERT(DATETIME,'05/03/2017',104)
-- SET @D2 = CONVERT(DATETIME,'31/12/2022',104)
-- SELECT A.StartDate,A.EndDate FROM Isd_AM_DateRange_Demo('m',5,@d1,@d2) A;
 
 
BEGIN

      ;WITH cteRange (DateRange) AS 
            (
               SELECT CASE WHEN MONTH(@StartDate)>=12 
                           THEN CONVERT(DATETIME,'01/01/'                                      +CAST(YEAR(@StartDate)+1 AS VARCHAR),104)
                           ELSE CONVERT(DATETIME,'01/'+CAST(MONTH(@StartDate)+1 AS VARCHAR)+'/'+CAST(YEAR(@StartDate)   AS VARCHAR),104)
                      END 
                       
            UNION ALL
            
               SELECT CASE WHEN YEAR(DateRange)<YEAR(CASE WHEN @Increment = 'd' THEN DATEADD(dd, @iIncrement, DateRange)
                                                          WHEN @Increment = 'w' THEN DATEADD(ww, @iIncrement, DateRange)
                                                          WHEN @Increment = 'm' THEN DATEADD(mm, @iIncrement, DateRange)
                                                     END)
                           THEN CONVERT(DATETIME,'01/01/'+CAST(YEAR(DateRange)+1 AS VARCHAR))
                           ELSE CASE WHEN @Increment = 'd' THEN DATEADD(dd, @iIncrement, DateRange)
                                     WHEN @Increment = 'w' THEN DATEADD(ww, @iIncrement, DateRange)
                                     WHEN @Increment = 'm' THEN DATEADD(mm, @iIncrement, DateRange)
                                END
                      END
                 FROM cteRange
                 
                WHERE  DateRange <= 
                       CASE WHEN @Increment = 'd' THEN DATEADD(dd, -1, @EndDate)
                            WHEN @Increment = 'w' THEN DATEADD(ww, -1, @EndDate)
                            WHEN @Increment = 'm' THEN DATEADD(mm, -1, @EndDate)
                       END
                )
      
          
      INSERT INTO @SelectedRange (StartDate,EndDate)
      
      SELECT DateRange,
      
             DateRange2 = CASE WHEN CASE WHEN YEAR(DateRange)=YEAR(CASE WHEN @Increment = 'd' THEN DATEADD(dd, @iIncrement, DateRange)
                                                                        WHEN @Increment = 'w' THEN DATEADD(ww, @iIncrement, DateRange)
                                                                        WHEN @Increment = 'm' THEN DATEADD(mm, @iIncrement, DateRange)
                                                                   END)
                                         THEN CASE WHEN @Increment = 'd' THEN DATEADD(dd, @iIncrement, DateRange)
                                                   WHEN @Increment = 'w' THEN DATEADD(ww, @iIncrement, DateRange)
                                                   WHEN @Increment = 'm' THEN DATEADD(mm, @iIncrement, DateRange)
                                              END
                                         ELSE CONVERT(DATETIME,'31/12/'+CAST(YEAR(DateRange) AS VARCHAR),104)
                                    END  >  @EndDate
                                    
                               THEN @EndDate
                               
                               ELSE     
                               
                                    CASE WHEN YEAR(DateRange)=YEAR(CASE WHEN @Increment = 'd' THEN DATEADD(dd, @iIncrement, DateRange)
                                                                        WHEN @Increment = 'w' THEN DATEADD(ww, @iIncrement, DateRange)
                                                                        WHEN @Increment = 'm' THEN DATEADD(mm, @iIncrement, DateRange)
                                                                   END)
                                         THEN CASE WHEN @Increment = 'd' THEN DATEADD(dd, @iIncrement, DateRange)
                                                   WHEN @Increment = 'w' THEN DATEADD(ww, @iIncrement, DateRange)
                                                   WHEN @Increment = 'm' THEN DATEADD(mm, @iIncrement, DateRange)
                                              END - 1
                                         ELSE CONVERT(DATETIME,'31/12/'+CAST(YEAR(DateRange) AS VARCHAR),104)
                                    END 
                          END          
                               
        FROM cteRange
        
      OPTION (MAXRECURSION 3660);
      

      DELETE 
        FROM @SelectedRange 
       WHERE StartDate>@EndDate;
       
      
      RETURN
      
      
END
GO
