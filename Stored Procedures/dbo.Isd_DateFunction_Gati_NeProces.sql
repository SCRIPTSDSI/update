SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- Exec [dbo].[Isd_DateFunction] '31/10/2014','YTD','DD_MM_YYYY'

CREATE        Procedure [dbo].[Isd_DateFunction_Gati_NeProces]
(
  @PDate      Varchar(20),
  @PFunction  Varchar(20),
  @PFormat    Varchar(20)
 )

As

--Select * from [dbo].[F_TABLE_DATE] (dbo.DateValue('01/01/2014'), dbo.DateValue('31/12/2014'))
--Select * from [dbo].Isd_SetOfDates (dbo.DateValue('02/03/2014'), dbo.DateValue('02/03/2014'))


        Declare @DateKs   Datetime,
                @D1d      Datetime,
                @D2d      Datetime,
                @Prompt   Varchar(40);

            Set @DateKs = dbo.DateValue(@PDate);

     

-- 1.				Daily, Monthly, Quarterly, Yearly

   if @PFunction = 'D'
      begin
        Select @Prompt = 'Daily',                             -- Daily
               @D1D    = @DateKs, 
               @D2D    = @DateKs    
         From dbo.Isd_SetOfDates (@DateKs, @DateKs);
      end;

   if @PFunction = 'W'
      begin
        Select @Prompt = 'Weekly',                            -- Weekly
               @D1D    = Start_Of_Week_Starting_Mon_Date,
               @D2D    = End_Of_Month_Date
          From dbo.Isd_SetOfDates (@DateKs,@DateKs)
      end;     

   if @PFunction = 'M'
      begin
        Select @Prompt = 'Monthly',                           -- Monthly
               @D1D    = Start_Of_Month_Date,
               @D2D    = End_Of_Month_Date
          From dbo.Isd_SetOfDates (@DateKs,@DateKs) 
      end;

   if @PFunction = 'Q'
      begin
        Select @Prompt = 'Quarterly',                         -- Quarterly
               @D1D    = Start_Of_Quarter_Date,
               @D2D    = End_Of_Quarter_Date
          From dbo.Isd_SetOfDates (@DateKs,@DateKs)
      end;

   if @PFunction = 'Y'
      begin
        Select @Prompt = 'Yearly',                            -- Yearly
               @D1d    = Start_Of_Year_Date,
               @D2d    = End_Of_Year_Date
          From dbo.Isd_SetOfDates (@DateKs,@DateKs)
      end;

-- 1.				Fund Daily, Monthly, Quarterly, Yearly




-- 2.				Week_to_date, Month_to_date, Quarter_to_date, Year_to_date

 
   if @PFunction = 'WTD'
      begin
        Select @Prompt = 'Week_to_date',                      -- Week_to_date
               @D1d    = Start_Of_Week_Starting_Mon_Date,
               @D2d    = @DateKs
          From dbo.Isd_SetOfDates (@DateKs,@DateKs)
      end;

   if @PFunction = 'MTD'
      begin
        Select @Prompt = 'Month_to_date',                     -- Month_to_date
               @D1d    = Start_Of_Month_Date,
               @D2d    = @DateKs
          From dbo.Isd_SetOfDates (@DateKs,@DateKs)
      end;

   if @PFunction = 'QTD'
      begin
        Select @Prompt = 'Quarter_to_date',                   -- Quarter_to_date
               @D1d    = Start_Of_Quarter_Date,
               @D2d    = @DateKs
          From dbo.Isd_SetOfDates (@DateKs,@DateKs)
      end;
    
   if @PFunction = 'YTD'
      begin
        Select @Prompt = 'Year_to_date',                      -- Year_to_date
               @D1d    = Start_Of_Year_Date,
               @D2d    = @DateKs
          From dbo.Isd_SetOfDates (@DateKs,@DateKs)
      end; 

-- 2.				Fund Week_to_date, Month_to_date, Quarter_to_date, Year_to_date




-- 3.				Last_Week, Last_Month, Last_Quarter, Last_Year, 
--					Last_7_days, Last_30_days, Last_12_months

 
   if @PFunction = 'LW'
      begin
        Select @Prompt = 'Last_Week',                         -- Last_Week
               @D1d    = Start_Of_Week_Starting_Mon_Date,
               @D2d    = End_Of_Week_Starting_Mon_Date-1
          From dbo.Isd_SetOfDates (DateAdd(wk,-1,@DateKs),DateAdd(wk,-1,@DateKs))
        end;

   if @PFunction = 'LM'
      begin
        Select @Prompt = 'Last_Month',                        -- Last_Month
               @D1d    = Start_Of_Month_Date,
               @D2d    = End_Of_Month_Date
          From dbo.Isd_SetOfDates (DateAdd(mm,-1,@DateKs),DateAdd(mm,-1,@DateKs))
      end;

   if @PFunction = 'LQ'
      begin
        Select @Prompt = 'Last_Quarter',                      -- Last_Quarter
               @D1d    = Start_Of_Quarter_Date,
               @D2d    = End_Of_Quarter_Date
          From dbo.Isd_SetOfDates (DateAdd(qq,-1,@DateKs),DateAdd(qq,-1,@DateKs))
      end;

   if @PFunction = 'LY'
      begin
        Select @Prompt = 'Last_Year',                         -- Last_Year
               @D1d    = Start_Of_Year_Date,
               @D2d    = End_Of_Year_Date
          From dbo.Isd_SetOfDates (DateAdd(yy,-1,@DateKs),DateAdd(yy,-1,@DateKs))
      end;

   if @PFunction = 'L7D'
      begin
        Select @Prompt = 'Last_7_days',                       -- Last_7_days
               @D1d    = @DateKs-7,
               @D2d    = @DateKs-1
      end;

   if @PFunction = 'L30D'
      begin
        Select @Prompt = 'Last_30_days',                      -- Last_30_days
               @D1d    = @DateKs-30,
               @D2d    = @DateKs-1
      end;

   if @PFunction = 'L12M'
      begin
        Select @Prompt = 'Last_12_months',                    -- Last_12_months
               @D1d    = DateAdd(mm,-12,@DateKs),
               @D2d    = @DateKs - 1
      end;

   if @Prompt=''
      begin
        Select PROMPT = '', D1D=@PDate, D2D=@PDate, 
               D1S    = dbo.Isd_DateFormatDMY(@PDate,@PFormat), 
               D2S    = dbo.Isd_DateFormatDMY(@PDate,@PFormat)
        Return
      end;
                                                              -- without hours,minutes
   Select @D1d   = DateAdd(day, DateDiff(day,0,@D1d),0),
          @D2d   = DateAdd(day, DateDiff(day,0,@D2d),0)

   Select PROMPT = @Prompt, D1D=@D1d, D2D=@D2d, 
          D1S    = dbo.Isd_DateFormatDMY(@D1d,@PFormat), 
          D2S    = dbo.Isd_DateFormatDMY(@D2d,@PFormat)


-- 3.				Fund Last_Week, Last_Month,   Last_Quarter, Last_Year, 
--					Last_7_days,    Last_30_days, Last_12_months



GO
