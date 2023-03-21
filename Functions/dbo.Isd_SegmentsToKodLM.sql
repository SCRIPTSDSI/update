SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   FUNCTION [dbo].[Isd_SegmentsToKodLM]
(@PKod    Varchar(100),
 @PMon    Varchar(20),
 @PInsMon Int)
Returns Varchar(100)

AS

Begin
  Declare @Kod  Varchar(60)
  Declare @Mon  Varchar(20)

  if @PInsMon=1
     Set @Mon = @PMon
  else
     Set @Mon = Dbo.Isd_SegmentFind(@PKod,0,5)

  Set @Kod = Dbo.Isd_SegmentFind(@PKod,0,1)+'.'+
             Dbo.Isd_SegmentFind(@PKod,0,2)+'.'+
             Dbo.Isd_SegmentFind(@PKod,0,3)+'.'+
             Dbo.Isd_SegmentFind(@PKod,0,4)+'.'+
             @Mon

  Return (LTrim(RTrim(@Kod)))

End


GO
