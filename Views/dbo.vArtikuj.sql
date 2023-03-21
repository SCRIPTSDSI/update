SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE View [dbo].[vArtikuj] 
As
Select z.KOD 
	   ,Bc			= Case When (Select Multibc From Configmg) = 0 Then IsNull(Z.Bc, '') Else IsNull(S.Bc, '') End
	   ,Pershkrim	= IsNull(Z.Pershkrim, '')
	   ,Njesi		= IsNull(Njesi, '')
	   ,Cmsh		= IsNull(Cmsh, 0)
	   ,Cmb			= Round(Case When IsNull(Tatim, 0) = 1 Then IsNull((Select Top 1 Cmimm From Fhscr Inner Join Fh On Fhscr.Nrd = Fh.NrRendor Where Dst in ('BL', 'CE') And Kartllg = Z.Kod Order by Datedok Desc), IsNull(Cmb, 0))/1
						   Else IsNull((Select Top 1 Cmimm From Fhscr Inner Join Fh On Fhscr.Nrd = Fh.NrRendor Where Dst in ('BL', 'CE') And Kartllg = z.Kod Order by Datedok Desc), IsNull(Cmb, 0))
						   End, 2)
		,Cmb2		= Round(Case When IsNull(Tatim, 0) = 1 Then IsNull((Select Top 1 Cmimm From Fhscr Inner Join Fh On Fhscr.Nrd = Fh.NrRendor Where Dst in ('BL', 'CE') And Kartllg = Z.Kod Order by Datedok Desc), IsNull(Cmb, 0))*1.2
						   Else IsNull((Select Top 1 Cmimm From Fhscr Inner Join Fh On Fhscr.Nrd = Fh.NrRendor Where Dst in ('BL', 'CE') And Kartllg = z.Kod Order by Datedok Desc), IsNull(Cmb, 0))
						   End, 2)
	   ,KostMes     = IsNull(KostMes, 0)
	   ,Tatim		= IsNull(Tatim, 0)
	   ,Tvsh		= kt.PERQTVSH--Case When IsNull(Tatim, 0) = 0 Then 0 Else 20 End
		,Marzhi		= Round((Case When Cmsh = 0 Then 0 Else (IsNull(Cmsh, 0)-Round(Case When IsNull(Tatim, 0) = 1 Then IsNull((Select Top 1 Cmimm From Fhscr Inner Join Fh On Fhscr.Nrd = Fh.NrRendor Where Dst in ('BL', 'CE') And Kartllg = Z.Kod Order by Datedok Desc), IsNull(Cmb, 0))*1.2
						   Else IsNull((Select Top 1 Cmimm From Fhscr Inner Join Fh On Fhscr.Nrd = Fh.NrRendor Where Dst in ('BL', 'CE') And Kartllg = z.Kod Order by Datedok Desc), IsNull(Cmb, 0))
						   End, 2))/IsNull(Cmsh, 0) End)*100, 2)
		,Klasif		= IsNull(Klasif, '')
		,Klasif2	= IsNull(Klasif2, '')
		,Klasif3	= IsNull(Klasif3, '')
		,Klasif4	= IsNull(Klasif4, '')
		,Ditore		= IsNull((Select Sum(Sasi) From Fjscr A Inner Join Fj B On A.Nrd = B.NrRendor Where A.Kartllg = Z.Kod And Datediff(dd, Datedok, Convert(datetime, floor(convert(float, Getdate()))))<=1), 0)
		,Javore		= IsNull((Select Sum(Sasi) From Fjscr A Inner Join Fj B On A.Nrd = B.NrRendor Where A.Kartllg = Z.Kod And Datediff(dd, Datedok, Convert(datetime, floor(convert(float, Getdate()))))<=7), 0)
		,Mujore		= IsNull((Select Sum(Sasi) From Fjscr A Inner Join Fj B On A.Nrd = B.NrRendor Where A.Kartllg = Z.Kod And Datediff(mm, Datedok, Convert(datetime, floor(convert(float, Getdate()))))<=1), 0)
		,Mini		= IsNull(Mini, 0)
		,Maks		= IsNull(Maks, 0)
		,Hyrje		= IsNull((Select Sum(Sasih) From LevizjeHd L Where L.Kartllg = Z.Kod), 0)
		,Dalje		= IsNull((Select Sum(Sasid) From LevizjeHd L Where L.Kartllg = Z.Kod), 0)
From Artikuj Z 
inner join KLASATVSH kt on kt.KOD = z.KODTVSH
Left Join Artikujbcscr S On Z.NrRendor = S.Nrd

GO
