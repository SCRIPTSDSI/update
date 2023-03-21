SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROC [dbo].[VW_ShitjeSipas](@dnga as datetime,@dderi as datetime)
as

select	datedok,
		sum(vlertot) as xhiro,
		(select count(1) from smbak sb
		where sb.datedok = s.datedok) as kupona,
		(select sum(sasi) from fjscr fs
		inner join fj f on f.nrrendor = fs.nrd where f.datedok=s.datedok) as artikuj
from fj s  
where datedok>=@dnga and datedok<=@dderi
group by datedok
order by datedok
GO
