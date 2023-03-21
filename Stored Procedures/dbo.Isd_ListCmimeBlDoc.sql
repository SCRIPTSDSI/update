SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE     Procedure [dbo].[Isd_ListCmimeBlDoc]
(
  @Kod    Varchar(100),
  @TipDok Int,
  @Round  Int
)

AS

--Declare @Kod   Varchar(30),
--        @KodKF Varchar(30)
--Set @Kod   = 'A000'
--Exec Isd_ListCmimeBl 'A001',1,2
--Exec Isd_ListCmimeBl 'A001',2,2


      if @Round<=-1
         begin
         --if @TipDok=2
              Select @Round = Cmim From Decimals Where TableName='FJ'
         --else
         --   Select @Round = Cmim From Decimals Where TableName='MG';
         end;
     Set @Round = IsNull(@Round,2);



  if @TipDok=2     -- Faturimi

     begin

		  Select Dokument   = 'Fature',
                 Kod        = B.KARTLLG,
                 Pershkrim  = C.PERSHKRIM,
                 CmimBl     = Round(B.CMIMBS,@Round),
                 Mon        = A.KMON,
                 CmimMg     = Round(Case When A.KURS1=1 And A.KURS2=1 Then B.CMIMBS 
                                         When A.KURS1*A.KURS2>0       Then Round((B.CMIMBS*A.KURS2)/A.KURS1,3)
                                         Else                              B.CMIMBS 
                                    end, @Round),
                 Emertim    = A.SHENIM1,
                 Furnitor   = A.KODFKL,
                 NrDok      = A.NRDOK,
                 Date       = A.DATEDOK,
                 NrFat      = A.NRDSHOQ, 
                 KMag       = A.KMAG,
                 Veprim     = 'BL',
                 A.TROW,
                 A.TAGNR
			From FF A Inner Join FFSCR B On A.NRRENDOR=B.NRD
                      Left  Join ARTIKUJ C On B.KARTLLG=C.KOD
		   Where B.KARTLLG=@Kod And TIPKLL='K'
		Order By B.KARTLLG,A.DATEDOK Desc,A.NRRENDOR

     end

  else

     begin         -- Magazinimi

		  Select 
                 Dokument   = 'Magazine',
                 Kod        = B.KARTLLG,
                 Pershkrim  = D.PERSHKRIM,
                 CmimMg     = Round(B.CMIMM, @Round),
                 CmimBl     = Round(B.CMIMBS,@Round),
                 Emertim    = A.SHENIM1,
                 Furnitor   = C.KODFKL,
                 NrDok      = A.NRDOK,
                 Date       = A.DATEDOK,
                 NrDokFt    = C.NRDOK,
				 NrFat      = C.NRDSHOQ,
                 KMag       = A.KMAG,
                 Veprim     = A.DST,
                 A.TROW,
                 A.TAGNR
			From FH A Inner Join FHSCR B On A.NRRENDOR=B.NRD
					  Left  Join FF C On A.NRRENDOR=C.NRRENDDMG 
                      Left  Join ARTIKUJ D On B.KARTLLG=D.KOD
		   Where (A.DOK_JB=1 Or A.DST='CE') And B.KARTLLG=@Kod
		Order By B.KARTLLG,A.DATEDOK Desc,A.NRRENDOR

     end

     
GO
