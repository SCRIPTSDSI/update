SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Function [dbo].[Palm_Sales_Price]
(   
  @Artikull    varchar(50),    
  @Barkod      varchar(50),    
  @Klient      varchar(50),    
  @Date        datetime,
  @Sasi        float 
) 
Returns Float As
Begin
Declare @Klasa varchar(3)
    Set @Klasa = (Select Grup From Klient Where Kod = @Klient)
Declare @Cmim float              

Set @Cmim = ISNull(@Cmim, (Select Cmim = Case @Klasa	When 'A' Then Cmsh
														When 'B' Then Cmsh1
														When 'C' Then Cmsh2
														When 'D' Then Cmsh3
														When 'E' Then Cmsh4
														When 'F' Then Cmsh5
														When 'G' Then Cmsh6
														When 'H' Then Cmsh7
														When 'I' Then Cmsh8
														When 'J' Then Cmsh9
														Else Cmsh
														End
                           From Artikuj 
                           Where Kod = @Artikull))
Return @Cmim

End

GO
