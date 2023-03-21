SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE function [dbo].[SasiAgjentBak] (@AGJENTI AS NVARCHAR(30),@DNGA AS DATETIME,@DDERI AS DATETIME,@MAG AS NVARCHAR(20))
returns Float
as
BEGIN
DECLARE @RET AS FLOAT;
SET @RET = (select sum(isnull(sasi,0)) from smbakscr 
inner join smbak on smbak.nrrendor = smbakscr.nrd 
where smbak.datedok>=@dnga 
and smbak.datedok<=@dderi 
and smbak.klasifikim like @agjenti 
and smbak.kmag like @mag)

RETURN @RET;
END
GO
