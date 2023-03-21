SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[updateklasatetvsh]
as 

update artikuj set kodtvsh = case when isnull(tatim,0)=0 then '0' else '2' end
where not exists (select 1 from klasatvsh where kod=artikuj.kodtvsh)



GO
