SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 
CREATE Proc [dbo].[Palm_Merr_Magazina]
(
	@Perdorues	nvarchar(60),
	@Tip		nvarchar(60)
)
As
Begin
	if(@Tip = 'SOURCE')
	Begin
	if object_id('drhreference') is not null 
		Exec('Select Kod, Pershkrim = Reference From drhreference Where Kodus = '''+@Perdorues +''' and Reference = ''Magazina''')
	Else 
		Exec('Select Kod, Pershkrim From Magazina Where Exists(Select 1 From DrhUser Where Modul =''M'' And TipDok = ''D'' And ActivModul = 1 And ActivKufij = 1 And KodUs = '''+ @Perdorues+''') And Kod = ''M01''')
	End
	Else 
	Select Kod, Pershkrim From Magazina 
End
--use finbaza select * from drhreference where kodus = 'M' and reference = 'Magazina'

--Palm_Merr_Magazina 'M', 'SOURCE'   Palm_Merr_Magazina 'M', 'DST' 

GO
