SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Function [dbo].[Isd_StringIsNumeric]
(  
  @Number Varchar(64)  
)  
Returns Bit  

Begin  

    Declare @Result Bit
    Declare @Pos    TinyInt  

        Set @Result = 0

     if Left(@Number, 1) = '-'  
        Set @Number = Substring(@Number, 2, Len(@Number))  


        Set @Pos = 1 + Len(@Number) - CharIndex('.', Reverse(@Number))  


        Set @Result = Case When PatIndex('%[^0-9.-]%', @Number) = 0 And 
                                @Number Not In ('.', '-', '+', '^') And
                                Len(@Number)>0 And 
                                @Number Not Like '%-%' And  
                               (
                                ((@pos = Len(@Number)+1) OR @pos = CharIndex('.', @Number))  
                               )  
                           Then 1  
                           Else 0 End  
  Return @Result
End  
GO
