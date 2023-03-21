SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[KERKIMWEB] (
@knga as nvarchar(100),
@kderi as nvarchar(100),
@kmag as nvarchar(100),
@klasif as nvarchar(100),
@klasif2 as nvarchar(100),
@klasif3 as nvarchar(100),
@klasif4 as nvarchar(100),
@persh as nvarchar(100),
@shenim as nvarchar(100))
AS

select 
KMAG AS KodMag, 
min(m.pershkrim) as Magazina,
KodArt=MIN(l.kartllg), 
Pershkrim=MIN(l.pershkrim), 
[Klasif I]=MIN(a.klasif), 
[Klasif II]=MIN(a.klasif2), 
[Klasif III]=MIN(a.klasif3), 
Hyrje=SUM(sasih), 
Dalje=SUM(sasid), 
Gjendje=ROUND(SUM(sasih-sasid),2)
from levizjehdsm as l
inner join artikuj as a on a.kod = l.kartllg
inner join magazina as m on m.kod = l.kmag
where kartllg>=@knga and kartllg<=@kderi 
and kmag like @kmag
and a.klasif like @klasif and a.klasif2 like @klasif2 
and a.klasif3 like @klasif3 and a.klasif4 like @klasif4
and l.pershkrim like @persh and l.shenim1 like @shenim
GROUP BY kmag,kartllg
order by l.kartllg asc
GO
