SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[Isd_DateRange]
(     
  @Increment    Char(1),
  @StartDate    DateTime,
  @EndDate      DateTime
)

Returns
  
  @SelectedRange Table (IndividualDate DateTime)

AS

-- Menyra e Pare (Vonon me shume se e dyta !!??, si dhe kufizimin per recursion)
 
Begin        -- Select IndividualDate From DateRange('y', '11/25/2012', '11.25.2016') 
      ;With cteRange (DateRange) AS (
            Select @StartDate
            Union All
            Select 
                  Case
                        When @Increment = 'd' Then DateAdd(dd, 1, DateRange)
                        When @Increment = 'w' Then DateAdd(ww, 1, DateRange)
                        When @Increment = 'm' Then DateAdd(mm, 1, DateRange)
                        When @Increment = 'y' Then DateAdd(yy, 1, DateRange)
                  End
            From cteRange
            Where DateRange <= 
                  Case
                        When @Increment = 'd' Then DateAdd(dd, -1, @EndDate)
                        When @Increment = 'w' Then DateAdd(ww, -1, @EndDate)
                        When @Increment = 'm' Then DateAdd(mm, -1, @EndDate)
                        When @Increment = 'y' Then DateAdd(yy, -1, @EndDate)
                  End)
          
      Insert Into @SelectedRange (IndividualDate)
      Select DateRange
        From cteRange
      Option (MaxRecursion 3660);

      Return

End


-- Menyra e dyte 
--Begin
----Declare @SelectedRange Table(IndividualDate DateTime)    
--  Declare @dateFrom DateTime
--  Declare @dateTo DateTime
--
--  Set @dateFrom = @StartDate --'2001/01/01'
--  Set @dateTo   = @EndDate   --'2012/01/12'
--
--
--  While(@dateFrom < @dateTo)
--    Begin
--      Select @dateFrom = DateAdd(day, 1,@dateFrom)
--      Insert Into @SelectedRange 
--      Select @dateFrom
--    End
--
----Select * From @dates
--
--  Return 
--
--End


/*



-- Ditet me transaksione 

Select a.IndividualDate,b.DateDok 
  From DateRange('d', '01/01/2014', '12/31/2014') as a 
       INNER JOIN FK as b on a.IndividualDate = b.DateDok


-- Ditet pa transaksione 

Select a.IndividualDate,b.DateDok 
  From DateRange('d', '01/01/2014', '12/31/2014') as a 
       LEFT JOIN FK as b on a.IndividualDate = b.DateDok
 Where B.DateDok Is Null

*/
GO
