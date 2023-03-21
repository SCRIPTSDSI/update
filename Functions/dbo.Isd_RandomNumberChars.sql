SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- SELECT AA=DBO.ISD_RANDOMNUMBER()

-- Format Character
-- SELECT AA=Convert(Varchar(30),Dbo.Isd_RandomNumber(),128)
-- Me ose Pa Piken e Decimalit 
-- SELECT AA=Dbo.Isd_RandomNumberChars(1)

CREATE   FUNCTION [dbo].[Isd_RandomNumberChars]
(@StringFormat Bit)

 Returns Varchar(30)

As

Begin

  Declare @V Varchar(30)
--Return (SELECT RandomNumber FROM Dbo.Isd_vRandomNumber)
  Select @V = (Select Convert(Varchar(30),(SELECT RandomNumber FROM Dbo.Isd_vRandomNumber),128))
  if CharIndex('.',@V)>0 and (@StringFormat=1)
     Set @V = Substring(@V,CharIndex('.',@V)+1,30)

  Return @V 
End
GO
