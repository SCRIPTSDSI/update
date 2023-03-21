SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[Isd_DatesBetween2Dates]
(
 @PDate1 DateTime, 
 @PDate2 Datetime
)

Returns Table As

-- Select * From dbo.Isd_DatesBetween2Dates('20040115','20040615')
-- ose 
-- Select * From dbo.Isd_DatesBetween2Dates(dbo.DateValue('15/01/2010'),dbo.DateValue('20/03/2011'))
Return (

With 
 N0 As (SELECT 1 As n UNION ALL SELECT 1),
 N1 As (SELECT 1 As n FROM N0 t1, N0 t2),
 N2 As (SELECT 1 As n FROM N1 t1, N1 t2),
 N3 As (SELECT 1 As n FROM N2 t1, N2 t2),
 N4 As (SELECT 1 As n FROM N3 t1, N3 t2),
 N5 As (SELECT 1 As n FROM N4 t1, N4 t2),
 N6 As (SELECT 1 As n FROM N5 t1, N5 t2),
 Series As (SELECT Row_Number() OVER (ORDER BY (SELECT 1)) As Nr FROM N6)

 Select DateAdd(Day,Nr-1,@PDate1) As Data
   From Series
  Where Nr <= DateDiff(Day,@PDate1,@PDate2) + 1);
GO
