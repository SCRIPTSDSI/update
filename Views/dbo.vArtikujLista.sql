SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE View [dbo].[vArtikujLista] 
As
Select Kod 
	   ,Bc			= Case When (Select Multibc From Configmg) = 0 Then IsNull(A.Bc, '') Else IsNull(S.Bc, '') End
	   ,Pershkrim	= IsNull(A.Pershkrim, '')
	   ,Njesi		= IsNull(Njesi, '')
	   ,Cmsh		= IsNull(Cmsh, 0)
	   ,Cmb			= Round(Case When IsNull(Tatim, 0) = 1 Then IsNull((Select Top 1 Cmimm From Fhscr Inner Join Fh On Fhscr.Nrd = Fh.NrRendor Where Dst in ('BL', 'CE') And Kartllg = A.Kod Order by Datedok Desc), IsNull(Cmb, 0))/1.2
						   Else IsNull((Select Top 1 Cmimm From Fhscr Inner Join Fh On Fhscr.Nrd = Fh.NrRendor Where Dst in ('BL', 'CE') And Kartllg = A.Kod Order by Datedok Desc), IsNull(Cmb, 0))
						   End, 2)
	   ,KostMes     = IsNull(KostMes, 0)
	   ,Tatim		= IsNull(Tatim, 0)
	   ,Tvsh		= Case When IsNull(Tatim, 0) = 0 Then 0 Else 20 End
From Artikuj A Left Join Artikujbcscr S On A.NrRendor = S.Nrd
GO
