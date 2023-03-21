SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Function [dbo].[Isd_StringIsInteger]  
(  
  @Number Varchar(64)  
)  
Returns Bit  

Begin

    Declare @Result Bit
        Set @Result = 0

    if Left(@Number, 1) = '-'  
        Set @Number = Substring(@Number, 2, Len(@Number))  

        Set @Result = Case When PatIndex('%[^0-9-]%', @Number) = 0 And 
                                CharIndex('-', @Number) <= 1 And 
                                @Number Not In ('.', '-', '+', '^') And Len(@Number)>0 And 
                                @Number Not Like '%-%' 
                           Then 1  
                           Else 0 End
  
    Return @Result 

End

GO
