SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[ELEMINOKODEDOPJO]
AS
BEGIN TRY
	DROP TABLE __KODET
END TRY
BEGIN CATCH
END CATCH

-- KUJDES ESHTE SINGLE BARKOD DHE MBUSH NJE TABELE ME KOLONAT KODIIVJETER DHE KODIIRI


Declare @Old varchar(20),
        @New varchar(20)
        
Declare Cu Cursor For 

SELECT KOD = KODIVJETER,KODNEW = KODIRI FROM __KODET


Open Cu
Fetch Next From Cu Into @Old, @New
 
While @@Fetch_Status = 0
Begin 
 
Update A Set Kod     = Replace(Kod, @Old, @New),
             Kodaf   = Replace(Kodaf, @Old, @New),
             Kartllg = Replace(Kartllg, @Old, @New)
From Fhscr A 
Where A.Kartllg = @Old
 
Update A Set Kod     = Replace(Kod, @Old, @New),
             Kodaf   = Replace(Kodaf, @Old, @New),
             Kartllg = Replace(Kartllg, @Old, @New)
From Fdscr A 
Where A.Kartllg = @Old
 
Update A Set Kod     = Replace(Kod, @Old, @New),
             Kodaf   = Replace(Kodaf, @Old, @New),
             Kartllg = Replace(Kartllg, @Old, @New)
From Ffscr A 
Where A.Kartllg = @Old And Tipkll = 'K'
 
Update A Set Kod     = Replace(Kod, @Old, @New),
             Kodaf   = Replace(Kodaf, @Old, @New),
             Kartllg = Replace(Kartllg, @Old, @New)
From Fjscr A 
Where A.Kartllg = @Old And Tipkll = 'K'
 
 
Update A Set Kod     = Replace(Kod, @Old, @New),
             Kodaf   = Replace(Kodaf, @Old, @New),
             Kartllg = Replace(Kartllg, @Old, @New)
From Smscr A 
Where A.Kartllg = @Old And Tipkll = 'K'
 
Update A Set Kod     = Replace(Kod, @Old, @New),
             Kodaf   = Replace(Kodaf, @Old, @New),
             Kartllg = Replace(Kartllg, @Old, @New)
From Smbakscr A 
Where A.Kartllg = @Old And Tipkll = 'K'
 
Update A Set MenuElementId = @New
From OferteScr A 
Where MenuElementId = @Old
 
--SKRIPTI I KOMENTUAR ME POSHTE ESHTE PER TU PERDORUR NESE KLIENTI KA MOBSYS
--Update A Set ItemCode = @New
--From Inventory..InventoryLines A
--Where A.ItemCode = @Old
 
--Update A Set ItemCode = @New
--From Inventory..TransferBase A
--Where A.ItemCode = @Old
 
--Update A Set ItemCode = @New
--From Inventory..TransferLines A
--Where A.ItemCode = @Old
 
--Update A Set ItemCode = @New
--From Inventory..PurchaseLines A
--Where A.ItemCode = @Old
 
--Update A Set ItemCode = @New
--From Inventory..OrderLines A
--Where A.ItemCode = @Old
 
Update A
Set Kod = @New
From Artikujscr A
Where A.Kod = @Old
 
Update A
Set Kod = @New
From Artikuj A
Where A.Kod = @Old
Fetch Next From Cu Into @Old, @New
End
 
Close Cu
Deallocate Cu

GO
