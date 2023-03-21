SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[vindex]
as

select datedok,year(datedok) as viti,nrdok,vlertot from sm
GO
