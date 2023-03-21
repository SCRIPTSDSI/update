SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[gjendjeTcr]
as
select vlera =sum(vlera),tcrcode
from (
select vlera =sum(vlertot),tcrcode=k.FISCTCRNUM from sm 
inner join kase k on k.kod = sm.kase
group by k.FISCTCRNUM

union all
select vlera =sum(vlera),tcrcode from logarka 
where isnull(errormessage,'')=''
group by tcrcode) b
group by b.tcrcode
GO
