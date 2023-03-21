SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Function [dbo].[Isd_ProperCase](@PText as varchar(8000))

 Returns Varchar(Max)

As

Begin

-- Declare @PText Varchar(Max)
--     Set @PText = 'ky eshte demo per kete funksion, si mendon? Preferoni nje mc''donalds'
--  Select dbo.Isd_ProperCase('ky eshte demo per kete funksion, si mendon? Preferoni nje mc''donalds')

   Declare @Result   Varchar(Max),
           @Ind      Int,
           @Chr      Char(1),
           @Reset    Bit

       Set @Result = '' 
       Set @Reset  = 1
       Set @Ind    = 1
   
   While (@Ind <= Len(@PText))

   	     Select @Chr    = Substring(@PText,@Ind,1),
                @Result = @Result + Case When @Reset=1 Then Upper(@Chr) Else Lower(@Chr) end,
                @Reset  =           Case When @Chr like '[a-zA-Z]' Then 0 Else 1 end,
                @Ind    = @Ind +1

-- Print  @Result

   Return @Result
End

GO
