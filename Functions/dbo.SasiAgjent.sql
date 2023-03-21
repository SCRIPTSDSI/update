SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[SasiAgjent] (@AGJENTI AS NVARCHAR(30),@DNGA AS DATETIME,@DDERI AS DATETIME,@MAG AS NVARCHAR(20))
returns Float
as
BEGIN
DECLARE @RET AS FLOAT;
SET @RET = (select sum(isnull(sasi,0)) from smscr 
inner join sm on sm.nrrendor = smscr.nrd 
where sm.datedok>=@dnga 
and sm.datedok<=@dderi 
and sm.klasifikim like @agjenti 
and sm.kmag like @mag)

RETURN @RET;
END
GO
