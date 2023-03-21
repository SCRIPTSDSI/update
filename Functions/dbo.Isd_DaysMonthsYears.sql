SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   FUNCTION [dbo].[Isd_DaysMonthsYears]
(
  @pFirstDate  Varchar(20),
  @pLastDate   Varchar(20), 
  @pModel      Int
)

Returns Varchar(100) 

AS

BEGIN

     DECLARE @Result       Varchar(100),
             @FirstDate    DateTime,
             @LastDate     DateTime, 
             @Model        Int,
             @Month        Int,
             @Year         Int,
             @Day          Int;
             

         SET @FirstDate  = dbo.DateValue(@pFirstDate);
         SET @LastDate   = dbo.DateValue(@pLastDate);
         SET @Model      = @pModel;
         
          IF @FirstDate>@LastDate     -- Invers data
             BEGIN
               DECLARE @TmpDate      Datetime;

               SET     @TmpDate    = @LastDate;
               SET     @LastDate   = @FirstDate;
               SET     @FirstDate  = @TmpDate;
             END;
    


       SET @Month = DATEDIFF(MONTH,@FirstDate,@LastDate);

        IF DATEADD(MONTH,@Month,@FirstDate) > @LastDate
           BEGIN
             SET @Month=@Month-1;
           END;
           
       SET @Day   = DATEDIFF(DAY,DATEADD(MONTH,@Month,@FirstDate),@LastDate);
       SET @Year  = @Month/12;
       SET @Month = @Month % 12;

           
          IF @Model=0   
             BEGIN
               SET @Result = ('Year ' +CASE WHEN @Year=0  THEN '0' 
                                            WHEN @Year=1  THEN CONVERT(VARCHAR(50),@Year )
                                            WHEN @Year>1  THEN CONVERT(VARCHAR(50),@Year )
                                       END)+ 
                             ('Month '+CASE WHEN @Month=0 THEN '0' 
                                            WHEN @Month=1 THEN CONVERT(VARCHAR(50),@Month )  
                                            WHEN @Month>1 THEN CONVERT(VARCHAR(50),@Month )
                                       END)+ 
                             ('Day '  +CASE WHEN @Day=0   THEN '0' 
                                            WHEN @Day=1   THEN CONVERT(VARCHAR(50),@Day )   
                                            WHEN @Day>1   THEN CONVERT(VARCHAR(50),@Day )
                                       END)             
             END
          ELSE
          IF @Model=1   
             BEGIN
               SET @Result = ('Y'     +CASE WHEN @Year=0  THEN '0' 
                                            WHEN @Year=1  THEN CONVERT(VARCHAR(50),@Year )
                                            WHEN @Year>1  THEN CONVERT(VARCHAR(50),@Year )
                                       END)+ 
                             ('M'     +CASE WHEN @Month=0 THEN '0' 
                                            WHEN @Month=1 THEN CONVERT(VARCHAR(50),@Month )  
                                            WHEN @Month>1 THEN CONVERT(VARCHAR(50),@Month )
                                       END)+ 
                             ('D'     +CASE WHEN @Day=0   THEN '0' 
                                            WHEN @Day=1   THEN CONVERT(VARCHAR(50),@Day )   
                                            WHEN @Day>1   THEN CONVERT(VARCHAR(50),@Day )
                                       END)             
             END
             
             
      RETURN @Result

/*      -- Pedorimi    

    SELECT Y = SUBSTRING(YMD,2,CHARINDEX('M',YMD)-2),  
           M = SUBSTRING(YMD,  CHARINDEX('M',YMD)+1,  CHARINDEX('D',YMD)-CHARINDEX('M',YMD)-1),
           D = SUBSTRING(YMD,  CHARINDEX('D',YMD)+1, 2)
      FROM 
         (  SELECT YMD =[dbo].[Isd_DaysMonthsYears]('25/05/2016','25/04/2097',1)  )  A;
     
--Shiko edhe function ne fund te faqes: The Modified function
--https://stackoverflow.com/questions/1541570/how-to-use-datediff-to-return-year-month-and-day

*/







/*  -- Ishte deri 24.12.2020

ALTER   FUNCTION [dbo].[Isd_DaysMonthsYears]
(
 @pDt1      VARCHAR(30),
 @pDt2      VARCHAR(30),
 @pModel    INT
)
RETURNS VARCHAR(100) 

AS

BEGIN

     DECLARE @Dt1          DATETIME,
             @Dt2          DATETIME,
             @Model        INT,
             @Result       VARCHAR(100);
             
     DECLARE @TableData    TABLE 
           ( 
             NrYears       INT NULL,
             NrMonths      INT NULL,
             NrDays        INT NULL
            )

             
         SET @Dt1        = dbo.DATEVALUE(@pDt1);       -- dbo.DATEVALUE('25/04/2016'); 
         SET @Dt2        = dbo.DATEVALUE(@pDt2);       -- dbo.DATEVALUE('25/04/2018');
         SET @Model      = @pModel;
    


      INSERT INTO @TableData
             (NrYears,NrMonths,NrDays)

      SELECT A.NrYears, 
             A.NrMonths,
             NrDite = CASE WHEN                        DATEADD(MONTH, A.NrMonths, DATEADD(YEAR, A.NrYears, @Dt1))  >= @Dt2                
                                THEN     0
                                
                           WHEN          DATEPART(DAY, DATEADD(MONTH, A.NrMonths, DATEADD(YEAR, A.NrYears, @Dt1))) > DATEPART(DAY, @Dt2) 
                                THEN     DATEDIFF(DAY, DATEADD(MONTH, A.NrMonths, DATEADD(YEAR, A.NrYears, @Dt1)),@Dt2)-1
                                
                           ELSE      
                                         DATEDIFF(DAY, DATEADD(MONTH, A.NrMonths, DATEADD(YEAR, A.NrYears, @Dt1)),@Dt2)
                      END 
                          
        FROM              

           (           
           
             SELECT R.NrYears,       
                    NrMonths = CASE WHEN                     DATEADD(YEAR, R.NrYears, @Dt1)  > @Dt2                
                                         THEN 0
                                         
                                    WHEN      DATEPART(DAY,  DATEADD(YEAR, R.NrYears, @Dt1)) > DATEPART(DAY, @Dt2) 
                                         THEN DATEDIFF(MONTH,DATEADD(YEAR, R.NrYears, @Dt1),@Dt2)-1
                                    
                                    ELSE                                                                   
                                              DATEDIFF(MONTH,DATEADD(YEAR, R.NrYears, @Dt1),@Dt2)
                               END     
               FROM
                  (
                    SELECT NrYears  = CAST(CASE WHEN                                  @Dt1  >= @Dt2                           
                                                     THEN    0
                                                     
                                                WHEN         DATEPART(Day,@Dt1)> DATEPART(Day,@Dt2) 
                                                     THEN    DATEDIFF(MONTH,@Dt1,@Dt2)-1 
                                                     
                                                ELSE                                   
                                                             DATEDIFF(MONTH,@Dt1,@Dt2)
                                           END / 12 AS INT)
                    ) R 
             ) A
           
           
          IF @MOdel=0   
             BEGIN
               SELECT @Result = 'Years '  + CAST(ISNULL(NrYears,0)  AS VARCHAR) + ',' +
                                'Months ' + CAST(ISNULL(NrMonths,0) AS VARCHAR) + ',' +
                                'Days '   + CAST(ISNULL(NrDays,0)   AS VARCHAR)
                 FROM @TableData
             END
          ELSE
          IF @MOdel=1   
             BEGIN
               SELECT @Result = 'Y'       + CAST(ISNULL(NrYears,0)  AS VARCHAR) +
                                'M'       + CAST(ISNULL(NrMonths,0) AS VARCHAR) +
                                'D'       + CAST(ISNULL(NrDays,0)   AS VARCHAR)
                 FROM @TableData
             END
             
             
      RETURN @Result

/*      -- Pedorimi    

    SELECT Y = SUBSTRING(YMD,2,CHARINDEX('M',YMD)-2),  
           M = SUBSTRING(YMD,  CHARINDEX('M',YMD)+1,  CHARINDEX('D',YMD)-CHARINDEX('M',YMD)-1),
           D = SUBSTRING(YMD,  CHARINDEX('D',YMD)+1, 2)
      FROM 
         (  SELECT YMD =[dbo].[Isd_DaysMonthsYears]('25/05/2016','25/04/2097',1)  )  A;
     
--Shiko edhe function ne fund te faqes: The Modified function
--https://stackoverflow.com/questions/1541570/how-to-use-datediff-to-return-year-month-and-day

*/

END  */


END
GO
