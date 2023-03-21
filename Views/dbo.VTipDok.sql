SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 

CREATE View [dbo].[VTipDok]
As
Select Top 100 Percent Tipdok, Kod = Replace(Replace(Kod, 'NO', ''), 'F', ''), Pershkrim = Replace(IsNull(Pershkrim, ''), 'Fature blerje', '') From Tipdok
--Where Tipdok = 'H'
Order By Pershkrim
 

GO
