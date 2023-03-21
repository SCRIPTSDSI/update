SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO













CREATE          procedure [dbo].[Isd_GjenerimVitFiskal]
(
 @PStart   Varchar(50), 
 @PEnd     Varchar(50)
)

As

-- Exec dbo.Isd_GjenerimVitFiskal '01/01/2013','31/12/2014'

     Declare @Start       DateTime, 
             @End         DateTime,
             @ListMonth   Varchar(200)

         Set @Start     = Dbo.DateValue(@PStart)
         Set @End       = Dbo.DateValue(@PEnd)

         Set @ListMonth = 'Janar,Shkurt,Mars,Prill,Maj,Qershor,Korrik,Gusht,Shtator,Tetor,Nentor,Dhjetor'

;With mycte As

   (

      Select DateValue1 = Cast(@Start as datetime),
             DateValue2 = DateAdd(Month,1,cast(@Start as datetime))-1 ,
             Muaj       = Month(Cast(@Start as datetime)),
             Pershkrim  = Cast(Year (Cast(@Start as datetime)) as Varchar)+' '+
                          dbo.Isd_StringInListStr(@ListMonth, Month(cast(@Start as datetime)),''),
             Gjendje    = 'H',
             TRow       = Cast(1 As Bit)

   Union All

      Select DateValue1 = DateAdd(Month,1,DateValue1) ,
             DateValue2 = DateAdd(Month,2,DateValue1)-1,
             Muaj       = Month(DateAdd(Month,2,DateValue1)-1),
             Pershkrim  = Cast(Year (DateAdd(Month,2,DateValue1)-1) as Varchar)+' '+
                          dbo.Isd_StringInListStr(@ListMonth, Month(DateAdd(Month,2,DateValue1)-1),''),
             Gjendje    = 'H',
             TRow       = Cast(0 As Bit)

        From mycte   
       Where DateValue2  < @End

   )

      Insert Into Periudhe (DATA,DATA1,PERIUDHE,PERSHKRIM,GJENDJE,TROW)

      Select DateValue1,DateValue2,Muaj,Pershkrim,Gjendje,TRow
        From mycte
      Option (MaxRecursion 0)

GO
