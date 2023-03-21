SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE   FUNCTION [dbo].[Isd_DateTimeServer]
(
  @PFormat as varchar(3)
)

  Returns Varchar(30) 

AS

Begin

  Declare @Result Varchar(30)
      Set @Result = ''


  if  @PFormat='DD'    -- Date Vetem
      Set @Result = (SELECT Date               = Convert(Varchar(10),GetDate(),121))
  else
  if  @PFormat='DTS'   -- DateTime e Plote
      Set @Result = (SELECT DateMeTimeMeMs     = Convert(Varchar(30),GetDate(),121))
  else
  if  @PFormat='DT'    -- DateTime e Plote
      Set @Result = (SELECT DateMeTimePaMs     = Convert(Varchar(19),GetDate(),121))
  else
  if  @PFormat='TS'    -- Time me milisekonda
      Set @Result = (SELECT TimeMeMs = Substring(Convert(Varchar(30),GetDate(),121),12,30))
  else
  if  @PFormat='T'     -- Time pa milisekonda
      Set @Result = (SELECT TimePaMs = Substring(Convert(Varchar(30),GetDate(),121),12,8))

  Return (@Result)

End

GO
