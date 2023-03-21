SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[getKodeX](@bc as varchar(50))
as
select top 10 Kod,Pershkrim,Cmsh from artikuj
GO
