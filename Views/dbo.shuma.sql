SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[shuma] as
SELECT  min(k.pershkrim) as Kasa,
                    min([Vlera Totale]) as Vlera
                     from smv inner join kase as k on k.kod = smv.kase 
 group by smv.kase,nrdok

GO
