SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[Isd_GetDatesDifference] 
(
    @psFromDate  Varchar(20),
    @psToDate    Varchar(20),
    @pFromDate   DateTime,
    @pToDate     DateTime
)

    Returns     nVarchar(100)

As

--  DECLARE @FromDate   DATETIME, 
--          @ToDate     DATETIME;
--      Set @ToDate   = '2015-11-25 00:00:00.000'
--      Set @FromDate = '2015-10-30 23:59:59.000';
--   SELECT @FromDate FromDate, @ToDate ToDate, dbo.Isd_GetDatesDifference('','',@FromDate, @ToDate) AS 'Difference between dates';

Begin


     Declare @FromDate      DateTime, 
             @ToDate        DateTime,
             @Years         Int, 
             @Months        Int, 
             @Days          Int, 
             @tmpFromDate   DateTime,
             @Result       nVarchar(100);


          if (@psFromDate<>'') And (@psToDate<>'')
             begin
               Set @FromDate = dbo.DateValue(@psFromDate); --'01/22/2012';
               Set @ToDate   = dbo.DateValue(@psToDate);   --'10/22/2012';
             end
          else
             begin
               Set @FromDate = @pFromDate;
               Set @ToDate   = @pToDate;
             end;


          if (@FromDate > @ToDate)
             begin
               Set @tmpFromDate = @ToDate;
    	       Set @ToDate      = @pFromDate;
    	       Set @FromDate    = @tmpFromDate;
             End;

      -- Set @FromDate    = @pFromDate; --'2010-10-30 23:59:59.000';
      -- Set @ToDate      = @pToDate;   --'2015-01-01 00:00:00.000';

         Set @Years       = DateDiff(Year, @FromDate, @ToDate)
                            - 
                           (Case When DateAdd(Year, DateDiff(Year, @FromDate, @ToDate), @ToDate) > @ToDate 
                                 Then 1 
                                 Else 0 
                            End); 
   
         Set @tmpFromDate = DateAdd(Year, @Years , @FromDate);
         Set @Months      = DateDiff(Month, @tmpFromDate, @ToDate)
                            - 
                        -- (Case When DateAdd(Month,DateDiff(Month, @tmpFromDate, @ToDate), @ToDate) > @ToDate 
                           (Case When DateAdd(Month,DateDiff(Month, @tmpFromDate, @ToDate), @tmpFromDate) > @ToDate 
                                 Then 1 
                                 Else 0 
                            End); 
   
         Set @tmpFromDate = DateAdd(Month, @Months, @tmpFromDate)
         Set @Days        = DateDiff(Day,  @tmpFromDate, @ToDate)
                            - 
                        -- (Case When DateAdd(Day, DateDiff(Day, @tmpFromDate, @ToDate), @ToDate) > @ToDate 
                           (Case When DateAdd(Day, DateDiff(Day, @tmpFromDate, @ToDate), @tmpFromDate) > @ToDate 
                                 Then 1 
                                 Else 0 
                            End); 
   
   -- Select @FromDate As FromDate, @ToDate As ToDate, @Years As Years,  @Months As Months, @Days As Days;

         Set @Result = Case When @Years>0 
                            Then Cast(@Years As Varchar(10))  + ' v'+      -- ' vjet, '
                                 Case When @Months>0 Or @Days>0
                                      Then ', '
                                      Else ''
                                 End
                            Else '' 
                       End
                       +
                       Case When @Months>0
                            Then Cast(@Months As Varchar(10)) + ' m'+      -- ' muaj, '
                                 Case When @Days>0
                                      Then ', '
                                      Else ''
                                 End
                            Else ''
                       End
                       +
                       Case When @Days<=0
                            Then ''  
                            Else Cast(@Days As Varchar(10))+ ' d'          -- ' dite'
                       End;
Return @Result;


/*



     Declare @ResultY   int,
			 @ResultM   int,
			 @ResultD   int,
			 @Return    nVarchar(100),
			 @DateX     Datetime,
			 @DateY     Datetime;

          if (@DateA < @DateB)
             begin
    	       Set @DateX = @DateA;
    	       Set @DateY = @DateB;
             End
          Else
             begin
    	       Set @DateX = @DateB;
    	       Set @DateY = @DateA;
             End;

         Set @ResultM = ( Select Case When DatePart(Day,   @DateX) > DatePart(Day, @DateY) 
                                      Then DateDiff(Month, @DateX, @DateY) - 1 
                                      Else DateDiff(Month, @DateX, @DateY) 
                                 End );

	      if (@ResultM>=12)
	         begin
		       Set @ResultY = @ResultM / 12
		       Set @ResultM = @ResultM % 12
		       Set @Return  = Convert(nVarchar(20), @ResultY) + ' vite '
	         End;

	      if (@ResultM = 0)
	         Set @ResultD = Abs(DateDiff(dd, @DateX, @DateY))
	      Else 
	         Set @ResultD = Abs(DateDiff(dd, GetDate()+Day(@DateX), GetDate()+Day(@DateY)));

      Return IsNull(@Return, '') + Case When @ResultM <> 0 
                                        Then Convert(nVarchar(20), @ResultM) + ' muaj ' 
                                        Else '' 
                                   End 
                                 + Case When @ResultD <> 0 
                                        Then Convert(nVarchar(20), @ResultD) + ' dite' 
                                        Else '' 
                                   End;
*/

End
GO
