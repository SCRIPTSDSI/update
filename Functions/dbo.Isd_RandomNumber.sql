SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- SELECT AA=DBO.ISD_RANDOMNUMBER()
-- Format Character
-- SELECT AA=Convert(Varchar(30),Dbo.Isd_RandomNumber(),128)


CREATE   FUNCTION [dbo].[Isd_RandomNumber]
()
 Returns Float

As

Begin
  Return (SELECT RandomNumber FROM Dbo.Isd_vRandomNumber)
--Return (Select Convert(Varchar(30),(SELECT RandomNumber FROM Dbo.Isd_vRandomNumber),128))
End



GO
