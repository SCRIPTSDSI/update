SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[VW_Shitje_Kase](@dnga as datetime,@dderi as datetime
							,@mnga as varchar(20),@mderi as varchar(50))
as

if @mnga =''
	set @mnga = '0'
if @mderi = ''
	set @mderi = 'ZZ'
	
select	Magazina = s.kmag,
		Kod = sc.kartllg,
		Pershkrim = min(sc.pershkrim),
		Sasi = sum(sc.sasi),
		VlPatvsh = sum(sc.vlpatvsh),
		VlTvsh = sum(sc.vltvsh),
		Vlere = sum(sc.vlpatvsh+sc.vltvsh),
		Kase = Convert(int,s.nekase),
		Dnga = @dnga,
		Dderi = @dderi,
		Mnga  = @mnga,
		Mderi = @mderi
from smbak s
inner join smbakscr sc on sc.nrd = s.nrrendor
where s.datedok >= @dnga and s.datedok<=@dderi
and s.kmag>=@mnga and s.kmag<=@mderi
group by convert(int,s.nekase),sc.kartllg,s.kmag
union all
select	Magazina = s.kmag,
		Kod = sc.kartllg,
		Pershkrim = min(sc.pershkrim),
		Sasi = sum(sc.sasi),
		VlPatvsh = sum(sc.vlpatvsh),
		VlTvsh = sum(sc.vltvsh),
		Vlere = sum(sc.vlpatvsh+sc.vltvsh),
		Kase = Convert(int,s.nekase),
		Dnga = @dnga,
		Dderi = @dderi,
		Mnga  = @mnga,
		Mderi = @mderi
from sm s
inner join smscr sc on sc.nrd = s.nrrendor
where s.datedok >= @dnga and s.datedok<=@dderi
and s.kmag>=@mnga and s.kmag<=@mderi
group by convert(int,s.nekase),sc.kartllg,s.kmag

--VW_Shitje_Kase '01-01-2010 00:00:000','12-31-2015 00:00:000','',''

GO
