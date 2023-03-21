SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE function [dbo].[Isd_SetOfDates]
(
	@FIRST_DATE		Datetime,
	@LAST_DATE		Datetime
)

--   Kopje sipas function F_TABLE_DATE por ka dhe fusha ne fund te shtuara 

--   Select * from [dbo].Isd_SetOfDates (dbo.DateValue('02/03/2014'), dbo.DateValue('02/03/2014'))

--   http://www.sqlteam.com/forums/topic.asp?TOPIC_ID=61519

/*
Function: dbo.F_TABLE_DATE

This function returns a date Table containing all dates
from @FIRST_DATE through @LAST_DATE inclusive.
@FIRST_DATE must be less than or equal to @LAST_DATE.
The valid date range is 1754-01-01 through 9997-12-31.
If any input parameters are invalid, the fuction will produce
an error.

The Table returned by F_TABLE_DATE contains a date and
columns with many calculated attributes of that date.
It is designed to make it convenient to get various commonly
needed date attributes without having to program and test
the same logic in many applications.

F_TABLE_DATE is primarily intended to load a permanant
date Table, but it can be used directly by an application
When the date range needed falls outside the range loaded
in a permanant Table.

If F_TABLE_DATE is used to load a permanant Table, the create
Table code can be copied from this function.  For a permanent
date Table, most columns should be indexed to produce the
best application performance.


Column Descriptions
------------------------------------------------------------------


DATE_ID               
	Unique ID = Days since 1753-01-01

DATE                            
	Date at Midnight(00:00:00.000)

NEXT_DAY_DATE                   
	Next day after DATE at Midnight(00:00:00.000)
	Intended to be used in queries against columns
	containing Datetime values (1998-12-13 14:35:16)
	that need to join to a DATE.
	Example:

	from
		MyTable a
		join
		DATE b
		on	a.DateTimeCol >= b. DATE	and
			a.DateTimeCol < b.NEXT_DAY_DATE

YEAR                            
	Year number in format YYYY, Example = 2005

YEAR_QUARTER                    
	Year and Quarter number in format YYYYQ, Example = 20052

YEAR_MONTH                      
	Year and Month number in format YYYYMM, Example = 200511

YEAR_DAY_OF_YEAR                
	Year and Day of Year number in format YYYYDDD, Example = 2005364

QUARTER                         
	Quarter number in format Q, Example = 4

MONTH                           
	Month number in format MM, Example = 11

DAY_OF_YEAR                     
	Day of Year number in format DDD, Example = 362

DAY_OF_MONTH                    
	Day of Month number in format DD, Example = 31

DAY_OF_WEEK                     
	Day of week number, Sun=1, Mon=2, Tue=3, Wed=4, Thu=5, Fri=6, Sat=7

YEAR_NAME                       
	Year name text in format YYYY, Example = 2005

YEAR_QUARTER_NAME               
	Year Quarter name text in format YYYY QQ, Example = 2005 Q3

YEAR_MONTH_NAME                 
	Year Month name text in format YYYY MMM, Example = 2005 Mar

YEAR_MONTH_NAME_LONG            
	Year Month long name text in format YYYY MMMMMMMMM,
	Example = 2005 September

QUARTER_NAME                    
	Quarter name text in format QQ, Example = Q1

MONTH_NAME                      
	Month name text in format MMM, Example = Mar

MONTH_NAME_LONG                 
	Month long name text in format MMMMMMMMM, Example = September

WEEKDAY_NAME                    
	Weekday name text in format DDD, Example = Tue

WEEKDAY_NAME_LONG               
	Weekday long name text in format DDDDDDDDD, Example = Wednesday

START_OF_YEAR_DATE              
	First Day of Year that DATE is in

END_OF_YEAR_DATE                
	Last Day of Year that DATE is in

START_OF_QUARTER_DATE           
	First Day of Quarter that DATE is in

END_OF_QUARTER_DATE             
	Last Day of Quarter that DATE is in

START_OF_MONTH_DATE             
	First Day of Month that DATE is in

END_OF_MONTH_DATE               
	Last Day of Month that DATE is in

*** Start and End of week columns allow selections by week
*** for any week start date needed.

START_OF_WEEK_STARTING_SUN_DATE 
	First Day of Week starting Sunday that DATE is in

END_OF_WEEK_STARTING_SUN_DATE   
	Last Day of Week starting Sunday that DATE is in

START_OF_WEEK_STARTING_MON_DATE 
	First Day of Week starting Monday that DATE is in

END_OF_WEEK_STARTING_MON_DATE   
	Last Day of Week starting Monday that DATE is in

START_OF_WEEK_STARTING_TUE_DATE 
	First Day of Week starting Tuesday that DATE is in

END_OF_WEEK_STARTING_TUE_DATE   
	Last Day of Week starting Tuesday that DATE is in

START_OF_WEEK_STARTING_WED_DATE 
	First Day of Week starting Wednesday that DATE is in

END_OF_WEEK_STARTING_WED_DATE   
	Last Day of Week starting Wednesday that DATE is in

START_OF_WEEK_STARTING_THU_DATE 
	First Day of Week starting Thursday that DATE is in

END_OF_WEEK_STARTING_THU_DATE   
	Last Day of Week starting Thursday that DATE is in

START_OF_WEEK_STARTING_FRI_DATE 
	First Day of Week starting Friday that DATE is in

END_OF_WEEK_STARTING_FRI_DATE   
	Last Day of Week starting Friday that DATE is in

START_OF_WEEK_STARTING_SAT_DATE 
	First Day of Week starting Saturday that DATE is in

END_OF_WEEK_STARTING_SAT_DATE   
	Last Day of Week starting Saturday that DATE is in

*** Sequence No columns are intended to allow easy offsets by
*** Quarter, Month, or Week for applications that need to look at
*** Last or Next Quarter, Month, or Week.  Thay can also be used to
*** generate dynamic cross tab results by Quarter, Month, or Week.

QUARTER_SEQ_NO                  
	Sequential Quarter number as offset from Quarter starting 1753/01/01

MONTH_SEQ_NO                    
	Sequential Month number as offset from Month starting 1753/01/01

WEEK_STARTING_SUN_SEQ_NO        
	Sequential Week number as offset from Week starting Sunday, 1753/01/07

WEEK_STARTING_MON_SEQ_NO        
	Sequential Week number as offset from Week starting Monday, 1753/01/01

WEEK_STARTING_TUE_SEQ_NO        
	Sequential Week number as offset from Week starting Tuesday, 1753/01/02

WEEK_STARTING_WED_SEQ_NO        
	Sequential Week number as offset from Week starting Wednesday, 1753/01/03

WEEK_STARTING_THU_SEQ_NO        
	Sequential Week number as offset from Week starting Thursday, 1753/01/04

WEEK_STARTING_FRI_SEQ_NO        
	Sequential Week number as offset from Week starting Friday, 1753/01/05

WEEK_STARTING_SAT_SEQ_NO        
	Sequential Week number as offset from Week starting Saturday, 1753/01/06

JULIAN_DATE                     
	Julian Date number as offset from noon on January 1, 4713 BCE
	to noon on day of DATE in system of Joseph Scaliger

MODIFIED_JULIAN_DATE            
	Modified Julian Date number as offset from midnight(00:00:00.000) on
	1858/11/17 to midnight(00:00:00.000) on day of DATE

ISO_DATE                        
	ISO 8601 Date in format YYYY-MM-DD, Example = 2004-02-29

ISO_YEAR_WEEK_NO                
	ISO 8601 year and week in format YYYYWW, Example = 200403

ISO_WEEK_NO                     
	ISO 8601 week of year in format WW, Example = 52

ISO_DAY_OF_WEEK                 
	ISO 8601 Day of week number, 
	Mon=1, Tue=2, Wed=3, Thu=4, Fri=5, Sat=6, Sun=7

ISO_YEAR_WEEK_NAME              
	ISO 8601 year and week in format YYYY-WNN, Example = 2004-W52

ISO_YEAR_WEEK_DAY_OF_WEEK_NAME  
	ISO 8601 year, week, and day of week in format YYYY-WNN-D,
	Example = 2004-W52-2

DATE_FORMAT_YYYY_MM_DD          
	Text date in format YYYY/MM/DD, Example = 2004/02/29

DATE_FORMAT_YYYY_M_D            
	Text date in format YYYY/M/D, Example = 2004/2/9

DATE_FORMAT_MM_DD_YYYY          
	Text date in format MM/DD/YYYY, Example = 06/05/2004

DATE_FORMAT_M_D_YYYY            
	Text date in format M/D/YYYY, Example = 6/5/2004

DATE_FORMAT_MMM_D_YYYY          
	Text date in format MMM D, YYYY, Example = Jan 4, 2006

DATE_FORMAT_MMMMMMMMM_D_YYYY    
	Text date in format MMMMMMMMM D, YYYY, Example = September 3, 2004

DATE_FORMAT_MM_DD_YY            
	Text date in format MM/DD/YY, Example = 06/05/97

DATE_FORMAT_M_D_YY              
	Text date in format M/D/YY, Example = 6/5/97

*/

  Returns  @DATE Table 


  (
	[DATE_ID]							[Int]			not null primary key clustered,
	[DATE]								[Datetime]		not null,
	[NEXT_DAY_DATE]						[Datetime]		not null,
	[YEAR]								[smallint]		not null,
	[YEAR_QUARTER]						[Int]			not null,
	[YEAR_MONTH]						[Int]			not null,
	[YEAR_DAY_OF_YEAR]					[Int]			not null,
	[QUARTER]							[tinyint]		not null,
	[MONTH]								[tinyint]		not null,
	[DAY_OF_YEAR]						[smallint]		not null,
	[DAY_OF_MONTH]						[smallint]		not null,
	[DAY_OF_WEEK]						[tinyint]		not null,

	[YEAR_NAME]							[Varchar] (4)	not null,
	[YEAR_QUARTER_NAME]					[Varchar] (7)	not null,
	[YEAR_MONTH_NAME]					[Varchar] (8)	not null,
	[YEAR_MONTH_NAME_LONG]				[Varchar] (14)	not null,
	[QUARTER_NAME]						[Varchar] (2)	not null,
	[MONTH_NAME]						[Varchar] (3)	not null,
	[MONTH_NAME_LONG]					[Varchar] (9)	not null,
	[WEEKDAY_NAME]						[Varchar] (3)	not null,
	[WEEKDAY_NAME_LONG]					[Varchar] (9)	not null,

	[START_OF_YEAR_DATE]				[Datetime]		not null,
	[END_OF_YEAR_DATE]					[Datetime]		not null,
	[START_OF_QUARTER_DATE]				[Datetime]		not null,
	[END_OF_QUARTER_DATE]				[Datetime]		not null,
	[START_OF_MONTH_DATE]				[Datetime]		not null,
	[END_OF_MONTH_DATE]					[Datetime]		not null,

	[START_OF_WEEK_STARTING_SUN_DATE]	[Datetime]      not null,
	[END_OF_WEEK_STARTING_SUN_DATE]		[Datetime]      not null,
	[START_OF_WEEK_STARTING_MON_DATE]	[Datetime]      not null,
	[END_OF_WEEK_STARTING_MON_DATE]		[Datetime]      not null,
	[START_OF_WEEK_STARTING_TUE_DATE]	[Datetime]      not null,
	[END_OF_WEEK_STARTING_TUE_DATE]		[Datetime]      not null,
	[START_OF_WEEK_STARTING_WED_DATE]	[Datetime]      not null,
	[END_OF_WEEK_STARTING_WED_DATE]		[Datetime]      not null,
	[START_OF_WEEK_STARTING_THU_DATE]	[Datetime]      not null,
	[END_OF_WEEK_STARTING_THU_DATE]		[Datetime]      not null,
	[START_OF_WEEK_STARTING_FRI_DATE]	[Datetime]      not null,
	[END_OF_WEEK_STARTING_FRI_DATE]		[Datetime]      not null,
	[START_OF_WEEK_STARTING_SAT_DATE]	[Datetime]      not null,
	[END_OF_WEEK_STARTING_SAT_DATE]		[Datetime]      not null,

	[QUARTER_SEQ_NO]					[Int]           not null,
	[MONTH_SEQ_NO]						[Int]           not null,

	[WEEK_STARTING_SUN_SEQ_NO]			[Int]           not null,
	[WEEK_STARTING_MON_SEQ_NO]			[Int]           not null,
	[WEEK_STARTING_TUE_SEQ_NO]			[Int]           not null,
	[WEEK_STARTING_WED_SEQ_NO]			[Int]           not null,
	[WEEK_STARTING_THU_SEQ_NO]			[Int]           not null,
	[WEEK_STARTING_FRI_SEQ_NO]			[Int]           not null,
	[WEEK_STARTING_SAT_SEQ_NO]			[Int]           not null,

	[JULIAN_DATE]						[Int]           not null,
	[MODIFIED_JULIAN_DATE]				[Int]           not null,

	[ISO_DATE]							[Varchar](10)   not null,
	[ISO_YEAR_WEEK_NO]					[Int]           not null,
	[ISO_WEEK_NO]						[smallint]      not null,
	[ISO_DAY_OF_WEEK]					[tinyint]       not null,
	[ISO_YEAR_WEEK_NAME]				[Varchar](8)    not null,
	[ISO_YEAR_WEEK_DAY_OF_WEEK_NAME]	[Varchar](10)   not null,

	[DATE_FORMAT_YYYY_MM_DD]			[Varchar](10)   not null,
	[DATE_FORMAT_YYYY_M_D]				[Varchar](10)   not null,
	[DATE_FORMAT_MM_DD_YYYY]			[Varchar](10)   not null,
	[DATE_FORMAT_M_D_YYYY]				[Varchar](10)   not null,
	[DATE_FORMAT_MMM_D_YYYY]			[Varchar](12)   not null,
	[DATE_FORMAT_MMMMMMMMM_D_YYYY]		[Varchar](18)   not null,
	[DATE_FORMAT_MM_DD_YY]				[Varchar](8)    not null,
	[DATE_FORMAT_M_D_YY]				[Varchar](8)    not null, 

-- Isd
    [DATE_FORMAT_DD_MM_YYYY]            [Varchar](10)   not null,
	[DATE_FORMAT_DD_MM_YY]				[Varchar](8)    not null,
	[DATE_FORMAT_D_M_YY]				[Varchar](8)    not null 
  )
 
As

Begin

    Declare @cr			    Varchar(2);
    Declare @ErrorMessage	Varchar(400);
    Declare @START_DATE		Datetime;
    Declare @END_DATE		Datetime;
    Declare @LOW_DATE	    Datetime;

     Select @cr			  = Char(13)+Char(10);

    Declare	@start_no	Int
    Declare	@end_no	Int

 
    if @FIRST_DATE is null			-- Verify @FIRST_DATE is not null 
       begin
	     Select @ErrorMessage =	'@FIRST_DATE cannot be null'
	       Goto Error_Exit
       end;


    if @LAST_DATE is null			-- Verify @LAST_DATE is not null 
	   begin
	     Select @ErrorMessage =	'@LAST_DATE cannot be null'
	       Goto Error_Exit
	   end;


    if @FIRST_DATE < '17540101'		-- Verify @FIRST_DATE is not before 1754-01-01
       begin
	     Select @ErrorMessage = '@FIRST_DATE cannot before 1754-01-01'+
		                        ', @FIRST_DATE = '+
		                        Isnull(Convert(Varchar(40),@FIRST_DATE,121),'NULL')
	       Goto Error_Exit
	   end;


    if  @LAST_DATE > '99971231'		-- Verify @LAST_DATE is not after 9997-12-31
        begin
	      Select @ErrorMessage = '@LAST_DATE cannot be after 9997-12-31'+
		                         ', @LAST_DATE = '+
		                         Isnull(Convert(Varchar(40),@LAST_DATE,121),'NULL')
	        Goto Error_Exit
	    end;


    if @FIRST_DATE > @LAST_DATE		-- Verify @FIRST_DATE is not after @LAST_DATE
	   begin
	     Select @ErrorMessage =	'@FIRST_DATE cannot be after @LAST_DATE'+
		                        ', @FIRST_DATE = '+
		                        Isnull(Convert(Varchar(40),@FIRST_DATE,121),'NULL')+
		                        ', @LAST_DATE = '+
		                        Isnull(Convert(Varchar(40),@LAST_DATE,121),'NULL')
	       Goto Error_Exit
	   end;

      -- Set @START_DATE = @FIRST_DATE at midnight
      Select @START_DATE = DateAdd(dd,DateDiff(dd,0,@FIRST_DATE),0)

      -- Set @END_DATE   = @LAST_DATE at midnight
      Select @END_DATE	 = DateAdd(dd,DateDiff(dd,0,@LAST_DATE),0)

      -- Set @LOW_DATE   = earliest possible SQL Server Datetime
      Select @LOW_DATE	 = Convert(Datetime,'17530101')

      -- Find the number of day from 1753-01-01 to @START_DATE and @END_DATE
      Select @start_no	 = DateDiff(dd,@LOW_DATE,@START_DATE) ,
	         @end_no	 = DateDiff(dd,@LOW_DATE,@END_DATE)

      -- Declare number tables
     Declare @num1 Table (NUMBER Int not null primary key clustered);
     Declare @num2 Table (NUMBER Int not null primary key clustered);
     Declare @num3 Table (NUMBER Int not null primary key clustered);

      -- Declare Table of ISO Week ranges
     Declare @ISO_WEEK Table
     (
        [ISO_WEEK_YEAR]              Int         not null primary key clustered,
        [ISO_WEEK_YEAR_START_DATE]	 Datetime    not null,
        [ISO_WEEK_YEAR_END_DATE]	 Datetime    not null
      )

      -- Find rows needed in number tables
     Declare @rows_needed		     Int
     Declare @rows_needed_root	     Int

      Select @rows_needed      = @end_no - @start_no + 1
      Select @rows_needed      = Case When @rows_needed < 10	
                                      Then 10
		                              Else @rows_needed
		                         end
      Select @rows_needed_root = Convert(Int,Ceiling(Sqrt(@rows_needed)))

      --   Load number 0 to 16
      Insert Into @num1 
           (NUMBER)
      Select NUMBER = 0 Union all 
      Select          1 Union all 
      Select          2 Union all
      Select          3 Union all 
      Select          4 Union all 
      Select          5 Union all
      Select          6 Union all 
      Select          7 Union all 
      Select          8 Union all
      Select          9 Union all 
      Select         10 Union all 
      Select         11 Union all
      Select         12 Union all 
      Select         13 Union all 
      Select         14 Union all
      Select         15
    Order By 1;


      -- Load Table with numbers zero thru square root of the number of rows needed +1
      Insert into @num2 
            (NUMBER)
      Select NUMBER = a.NUMBER+(16*b.NUMBER)+(256*c.NUMBER)
        From @num1 a cross join @num1 b cross join @num1 c
       Where a.NUMBER+(16*b.NUMBER)+(256*c.NUMBER) < @rows_needed_root
    Order By 1;


      -- Load Table with the number of rows needed for the date range
      Insert Into @num3 
            (NUMBER)
      Select NUMBER = a.NUMBER+(@rows_needed_root*b.NUMBER)
        From @num2 a	cross join @num2 b
       Where a.NUMBER+(@rows_needed_root*b.NUMBER) < @rows_needed
    Order By 1

     Declare @iso_start_year  Int
     Declare @iso_end_year    Int

      Select @iso_start_year = DatePart(year,DateAdd(year,-1,@start_date))
      Select @iso_end_year   = DatePart(year,DateAdd(year,1,@end_date))


      -- Load Table with start and end dates for ISO week years
      Insert into @ISO_WEEK
	  (
	   [ISO_WEEK_YEAR],
	   [ISO_WEEK_YEAR_START_DATE],
	   [ISO_WEEK_YEAR_END_DATE]
      )
      Select
       [ISO_WEEK_YEAR]             = a.NUMBER,
       [0ISO_WEEK_YEAR_START_DATE] = DateAdd(dd,(  DateDiff(dd,@LOW_DATE,
		                                           DateAdd(day,3,DateAdd(year,a.[NUMBER]-1900,0)))/7)*7,@LOW_DATE),
       [ISO_WEEK_YEAR_END_DATE]    = DateAdd(dd,-1,DateAdd(dd,(DateDiff(dd,@LOW_DATE,
		                                           DateAdd(day,3,DateAdd(year,a.[NUMBER]+1-1900,0)))/7)*7,@LOW_DATE))
        From

	   (
	     Select NUMBER = NUMBER+@iso_start_year
	       From @num3
	      Where NUMBER+@iso_start_year <= @iso_end_year
	    ) a

    Order By a.NUMBER


      -- Load Date Table
      Insert Into @DATE
      Select

	[DATE_ID]			              = a.[DATE_ID],

	[DATE]				              = a.[DATE],

	[NEXT_DAY_DATE]                   = DateAdd(day,1,a.[DATE]),

	[YEAR]			                  = DatePart(year,a.[DATE]),

	[YEAR_QUARTER]                    = (10*DatePart(year,a.[DATE]))+DatePart(quarter,a.[DATE]) ,

	[YEAR_MONTH]                      = (100*DatePart(year,a.[DATE]))+DatePart(month,a.[DATE]),

	[YEAR_DAY_OF_YEAR]                = (1000*DatePart(year,a.[DATE]))+
		                                DateDiff(dd,DateAdd(yy,DateDiff(yy,0,a.[DATE]),0),a.[DATE])+1,

	[QUARTER]                         = DatePart(quarter,a.[DATE]),

	[MONTH]                           = DatePart(month,a.[DATE]),

	[DAY_OF_YEAR]                     = DateDiff(dd,DateAdd(yy,DateDiff(yy,0,a.[DATE]),0),a.[DATE])+1,

	[DAY_OF_MONTH]                    = DatePart(day,a.[DATE]),

	[DAY_OF_WEEK]                     = (DateDiff(dd,'17530107',a.[DATE])%7)+1,
                                     -- Sunday = 1, Monday = 2, ,,,Saturday = 7

	[YEAR_NAME]                       = DateName(year,a.[DATE]),

	[YEAR_QUARTER_NAME]               = DateName(year,a.[DATE])+' Q'+DateName(quarter,a.[DATE]),

	[YEAR_MONTH_NAME]                 = DateName(year,a.[DATE])+' '+left(DateName(month,a.[DATE]),3),

	[YEAR_MONTH_NAME_LONG]            = DateName(year,a.[DATE])+' '+DateName(month,a.[DATE]) ,

	[QUARTER_NAME]                    = 'Q'+DateName(quarter,a.[DATE]),

	[MONTH_NAME]                      = Left(DateName(month,a.[DATE]),3),

	[MONTH_NAME_LONG]	              = DateName(month,a.[DATE]),

	[WEEKDAY_NAME]                    = Left(DateName(weekday,a.[DATE]),3),

	[WEEKDAY_NAME_LONG]               = DateName(weekday,a.[DATE]),

	[START_OF_YEAR_DATE]              = DateAdd(year,DateDiff(year,0,a.[DATE]),0) ,

	[END_OF_YEAR_DATE]                = DateAdd(day,-1,DateAdd(year,DateDiff(year,0,a.[DATE])+1,0)) ,

	[START_OF_QUARTER_DATE]           = DateAdd(quarter,DateDiff(quarter,0,a.[DATE]),0) ,

	[END_OF_QUARTER_DATE]             = DateAdd(day,-1,DateAdd(quarter,DateDiff(quarter,0,a.[DATE])+1,0)) ,

	[START_OF_MONTH_DATE]             = DateAdd(month,DateDiff(month,0,a.[DATE]),0) ,

	[END_OF_MONTH_DATE]               = DateAdd(day,-1,DateAdd(month,DateDiff(month,0,a.[DATE])+1,0)),

	[START_OF_WEEK_STARTING_SUN_DATE] = DateAdd(dd, (DateDiff(dd,'17530107',a.[DATE])/7)*7,'17530107'),

	[END_OF_WEEK_STARTING_SUN_DATE]   = DateAdd(dd,((DateDiff(dd,'17530107',a.[DATE])/7)*7)+6,'17530107'),

	[START_OF_WEEK_STARTING_MON_DATE] =	DateAdd(dd, (DateDiff(dd,'17530101',a.[DATE])/7)*7,'17530101'),

	[END_OF_WEEK_STARTING_MON_DATE]   =	DateAdd(dd,((DateDiff(dd,'17530101',a.[DATE])/7)*7)+6,'17530101'),

	[START_OF_WEEK_STARTING_TUE_DATE] =	DateAdd(dd, (DateDiff(dd,'17530102',a.[DATE])/7)*7,'17530102'),

	[END_OF_WEEK_STARTING_TUE_DATE]   =	DateAdd(dd,((DateDiff(dd,'17530102',a.[DATE])/7)*7)+6,'17530102'),

	[START_OF_WEEK_STARTING_WED_DATE] =	DateAdd(dd, (DateDiff(dd,'17530103',a.[DATE])/7)*7,'17530103'),

	[END_OF_WEEK_STARTING_WED_DATE]   =	DateAdd(dd,((DateDiff(dd,'17530103',a.[DATE])/7)*7)+6,'17530103'),

	[START_OF_WEEK_STARTING_THU_DATE] =	DateAdd(dd, (DateDiff(dd,'17530104',a.[DATE])/7)*7,'17530104'),

	[END_OF_WEEK_STARTING_THU_DATE]   =	DateAdd(dd,((DateDiff(dd,'17530104',a.[DATE])/7)*7)+6,'17530104'),

	[START_OF_WEEK_STARTING_FRI_DATE] =	DateAdd(dd, (DateDiff(dd,'17530105',a.[DATE])/7)*7,'17530105'),

	[END_OF_WEEK_STARTING_FRI_DATE]   =	DateAdd(dd,((DateDiff(dd,'17530105',a.[DATE])/7)*7)+6,'17530105'),

	[START_OF_WEEK_STARTING_SAT_DATE] =	DateAdd(dd, (DateDiff(dd,'17530106',a.[DATE])/7)*7,'17530106'),

	[END_OF_WEEK_STARTING_SAT_DATE]   =	DateAdd(dd,((DateDiff(dd,'17530106',a.[DATE])/7)*7)+6,'17530106'),

	[QUARTER_SEQ_NO]                  = DateDiff(quarter,@LOW_DATE,a.[DATE]),

	[MONTH_SEQ_NO]                    =	DateDiff(month,@LOW_DATE,a.[DATE]),

	[WEEK_STARTING_SUN_SEQ_NO]        =	DateDiff(day,'17530107',a.[DATE])/7,

	[WEEK_STARTING_MON_SEQ_NO]        =	DateDiff(day,'17530101',a.[DATE])/7,

	[WEEK_STARTING_TUE_SEQ_NO]        =	DateDiff(day,'17530102',a.[DATE])/7,

	[WEEK_STARTING_WED_SEQ_NO]        =	DateDiff(day,'17530103',a.[DATE])/7,

	[WEEK_STARTING_THU_SEQ_NO]        =	DateDiff(day,'17530104',a.[DATE])/7,

	[WEEK_STARTING_FRI_SEQ_NO]        =	DateDiff(day,'17530105',a.[DATE])/7,

	[WEEK_STARTING_SAT_SEQ_NO]        =	DateDiff(day,'17530106',a.[DATE])/7,

	[JULIAN_DATE]                     =	DateDiff(day,@LOW_DATE,a.[DATE])+2361331,

	[MODIFIED_JULIAN_DATE]            =	DateDiff(day,'18581117',a.[DATE]),
--/*

	[ISO_DATE]                        =	Replace(Convert(Char(10),a.[DATE],111),'/','-') ,

	[ISO_YEAR_WEEK_NO]                =	(100*b.[ISO_WEEK_YEAR])+
                                        (DateDiff(dd,b.[ISO_WEEK_YEAR_START_DATE],a.[DATE])/7)+1,

	[ISO_WEEK_NO]                     =	(DateDiff(dd,b.[ISO_WEEK_YEAR_START_DATE],a.[DATE])/7)+1 ,

	[ISO_DAY_OF_WEEK]                 =	(DateDiff(dd,@LOW_DATE,a.[DATE])%7)+1,
		                             -- Sunday = 1, Monday = 2, ,,,Saturday = 7

	[ISO_YEAR_WEEK_NAME]              =	Convert(Varchar(4),b.[ISO_WEEK_YEAR])+'-W'+
		                                Right('00'+Convert(Varchar(2),(DateDiff(dd,b.[ISO_WEEK_YEAR_START_DATE],a.[DATE])/7)+1),2) ,

	[ISO_YEAR_WEEK_DAY_OF_WEEK_NAME]  =	Convert(Varchar(4),b.[ISO_WEEK_YEAR])+'-W'+
		                                right('00'+Convert(Varchar(2),(DateDiff(dd,b.[ISO_WEEK_YEAR_START_DATE],a.[DATE])/7)+1),2) +
		                                '-'+Convert(Varchar(1),(DateDiff(dd,@LOW_DATE,a.[DATE])%7)+1) ,

--*/
	[DATE_FORMAT_YYYY_MM_DD]          = Convert(Char(10),a.[DATE],111),

	[DATE_FORMAT_YYYY_M_D]            = Convert(Varchar(10),Convert(Varchar(4),year(a.[DATE]))+'/'+
                                                            Convert(Varchar(2),month(a.[DATE]))+'/'+
                                                            Convert(Varchar(2),day(a.[DATE]))),

    [DATE_FORMAT_MM_DD_YYYY]          = Convert(Char(10),a.[DATE],101),

    [DATE_FORMAT_M_D_YYYY]            = Convert(Varchar(10),Convert(Varchar(2),month(a.[DATE]))+'/'+
                                                            Convert(Varchar(2),day(a.[DATE]))+'/'+
                                                            Convert(Varchar(4),year(a.[DATE]))),

    [DATE_FORMAT_MMM_D_YYYY]          = Convert(Varchar(12),left(DateName(month,a.[DATE]),3)+' '+
                                                            Convert(Varchar(2),day(a.[DATE]))+', '+
                                                            Convert(Varchar(4),year(a.[DATE]))),

    [DATE_FORMAT_MMMMMMMMM_D_YYYY]    = Convert(Varchar(18),DateName(month,a.[DATE])+' '+
                                                            Convert(Varchar(2),day(a.[DATE]))+', '+
                                                            Convert(Varchar(4),year(a.[DATE]))),

    [DATE_FORMAT_MM_DD_YY]            =	Convert(Char(8),a.[DATE],1) ,

	[DATE_FORMAT_M_D_YY]              = Convert(Varchar(8),Convert(Varchar(2),month(a.[DATE]))+'/'+
                                                           Convert(Varchar(2),day(a.[DATE]))+'/'+
                                                           right(Convert(Varchar(4),year(a.[DATE])),2)),

-- Shtesa te Isd .....
	[DATE_FORMAT_DD_MM_YYYY]          = Substring(Convert(Char(10),a.[DATE],101),4,2)+'/'+
                                        Substring(Convert(Char(10),a.[DATE],101),1,2)+'/'+
                                        Substring(Convert(Char(10),a.[DATE],101),7,4),

    [DATE_FORMAT_DD_MM_YY]            =	Substring(Convert(Char(8),a.[DATE],1),4,2)+'/'+
                                        Substring(Convert(Char(8),a.[DATE],1),1,2)+'/'+
                                        Substring(Convert(Char(8),a.[DATE],1),7,2),

	[DATE_FORMAT_D_M_YY]              = Convert(Varchar(8),Convert(Varchar(2),day(a.[DATE]))+'/'+
                                                           Convert(Varchar(2),month(a.[DATE]))+'/'+
                                                           right(Convert(Varchar(4),year(a.[DATE])),2))
       From

	(
	-- Derived Table is all dates needed for date range

	  Select Top 100 percent
		[DATE_ID] = aa.[NUMBER],
		[DATE]    =	DateAdd(dd,aa.[NUMBER],@LOW_DATE)

	    From
		(
		  Select NUMBER = NUMBER+@start_no 
		    From @num3
           Where NUMBER+@start_no <= @end_no
		) aa
	Order By aa.[NUMBER]

	 ) a        -- Match each date to the proper ISO week year
	        Join   @ISO_WEEK  b  On  a.[DATE] between b.[ISO_WEEK_YEAR_START_DATE] And 
		                                              b.[ISO_WEEK_YEAR_END_DATE]
	
   Order by	a.[DATE_ID]


  Return

  Error_Exit:

  -- Return a pseudo error message by trying to
  -- Convert an error message string to an Int.
  -- This method is used because the error displays
  -- the string it was trying to Convert, and so the
  -- calling application sees a formatted error message.

  Declare @Error Int

      Set @Error = Convert(Int,@cr+@cr+

'*******************************************************************'+@cr+
'* Error in function F_TABLE_DATE:'+@cr+'* '+Isnull(@ErrorMessage,'Unknown Error')+@cr+
'*******************************************************************'+@cr+@cr)

  Return

end
GO
