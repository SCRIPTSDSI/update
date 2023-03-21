SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 

CREATE   PROCEDURE [dbo].[Palm_FF_INSERT_FFSCR]
(
	@PNrRendor	int,
	@PTipKLL	nvarchar(1),
	@KODART		nvarchar(50),
	@CMIM		float,
	@SASI		float,
	@VPATVSH	float,
	@VTVSH		float,
	@VTOT		float,
	@Perqtvsh	float,
	@TvshKalk	bit = false
)
AS

Declare @Njesi		nvarchar(10), 
		@Pershkrim	nvarchar(100),
		@NrRendKllg bigint,
		@TipPagesa	nvarchar(10),
		@Kmon		nvarchar(10),
		@Kmag		nvarchar(10),
		@Kod		nvarchar(100),
		@Bc			nvarchar(100),
		@MultiBc	bit,
		@Shenim2	nvarchar(100)

Select @Njesi		= CASE @PTipKLL	WHEN 'K' THEN (SELECT NJESI FROM ARTIKUJ A WHERE A.KOD=@KODART) WHEN 'L' THEN ''  WHEN 'R' THEN (SELECT NJESI FROM SHERBIM A WHERE A.KOD=@KODART) END,
	   @Pershkrim	= CASE @PTipKLL WHEN 'K' THEN (SELECT PERSHKRIM FROM ARTIKUJ A WHERE A.KOD=@KODART) WHEN 'L' THEN (SELECT PERSHKRIM FROM LLOGARI A WHERE A.KOD=@KODART) WHEN 'R' THEN (SELECT PERSHKRIM FROM SHERBIM A WHERE A.KOD=@KODART) END,
	   @NrRendKllg	= CASE @PTipKLL WHEN 'K' THEN (SELECT NRRENDOR  FROM ARTIKUJ A WHERE A.KOD=@KODART) WHEN 'L' THEN (SELECT NRRENDOR  FROM LLOGARI A WHERE A.KOD=@KODART) WHEN 'R' THEN (SELECT NRRENDOR  FROM SHERBIM A WHERE A.KOD=@KODART) END
From Artikuj Where Kod = @KodArt

Select @TipPagesa = ModPg, @Kmon = IsNull(Kmon, ''), @Kmag = IsNull(Kmag, ''), @Shenim2 = SHENIM2 From Ff Where NrRendor = @PNrRendor
Set @Kod = CASE @PTipKLL WHEN 'K' THEN @Kmag + '.' + @KODART +'...' + @Kmon WHEN 'L' THEN @KodArt + '...' + @Kmon WHEN 'R' THEN @KodArt END

Set @MultiBc = IsNull((Select MultiBc from Configmg), 0)
Set @Bc = Case @PTipKLL WHEN 'K' THEN Case When @MultiBc = 0 Then ISNULL((SELECT BC FROM ARTIKUJ A WHERE A.KOD=@KODART),'') Else IsNull((Select Top 1 A.Bc from Artikuj N Inner Join Artikujbcscr A On N.NrRendor = A.Nrd), '') End ELSE '' END

INSERT INTO FFSCR
      (NRD, 
       KOD,
       KODAF,
       KARTLLG,
       PERSHKRIM,
       NRRENDKLLG,
       LLOGARIPK,
       NJESI,
       CMSHZB0,
       CMIMM,
       SASI,
       PERQDSCN,
       CMIMBS,
       VLERABS,
       VLERAM,
       VLPATVSH,
       VLTVSH,
       KOEFSHB,
       NJESINV,
       TIPKLL,
       BC,
       KOMENT,
       NOTMAG,
       RIMBURSIM,
       DTSKADENCE,
       SERI,
       KODKR,
       TROW,
       TAGNR,
       TIPFR,
       SASIFR,
       VLERAFR,
       VLTAX,
       KOEFICIENT,
	   Perqtvsh)
SELECT NRD			=	@PNrRendor,
       KOD			=	@Kod,
       KODAF		=	@KodArt,
       KARTLLG		=	@KodArt,
       PERSHKRIM	=   @Pershkrim,
       NRRENDKLLG	=	@NrRendKllg,
       LLOGARIPK	=	CASE @PTipKLL WHEN 'K' THEN '' WHEN 'L' THEN @KODART WHEN 'R' THEN @KODART END,
       NJESI		=   @Njesi,
       CMSHZB0		=	@CMIM,
       CMIMM		=	Case When @TvshKalk = 0 Then @CMIM Else Case When Round(@SASI, 3) = 0 Then @CMIM Else Round(@VTOT, 3)/@SASI End End,
       SASI			=	@SASI,
       PERQDSCN		=	0,
       CMIMBS		=	Case When @TvshKalk = 0 Then @CMIM Else Case When Round(@SASI, 3) = 0 Then @CMIM Else Round(@VTOT, 3)/@SASI End End,
       VLERABS		=	Round(@VTOT, 3),
       VLERAM		=	Round(@VPATVSH, 3),
       VLPATVSH		=	Case When @TvshKalk = 0 Then Round(@VPATVSH, 3) Else Round(@VTOT, 3) End,
       VLTVSH		=	Case When @TvshKalk = 0 Then Round(@VTVSH, 3) Else 0 End, 
       KOEFSHB		=	1,
	   NJESINV		=   @Njesi,
       TIPKLL		=	@PTipKLL,
       BC			=	@Bc,
       KOMENT		=	@Shenim2,
       NOTMAG		=	0,
       RIMBURSIM	=	0,
       DTSKADENCE	=	NULL,
       SERI			=	'',
       KODKR		=	'',
       TROW			=	0,
       TAGNR		=	0,
       TIPFR		=	'',
       SASIFR		=	0,
       VLERAFR		=	0,
       VLTAX		=	0,
       KOEFICIENT	=	0,
	   Perqtvsh		=	Case When @TvshKalk = 0 Then @Perqtvsh Else 0 End

Declare @v_vlertot	float,
		@v_vltvsh	float,
		@v_vlpatvsh	float	

Select @v_vlertot = sum(vlerabs), @v_vltvsh = sum(vltvsh), @v_vlpatvsh = sum(vlpatvsh) From Ffscr Where Nrd = @PNrRendor

UPDATE FF SET   VLPATVSH	=	@v_vlpatvsh,
				VLTVSH		=	@v_vltvsh,
				VLERTOT		=	@v_vlertot,
				ParaPg		=	Case When @TipPagesa = 'CA' Then @v_vlertot Else 0 End
WHERE NRRENDOR=@PNrRendor





GO
