SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[GetListField]
(
@emer_tab as varchar(100)
)
as

--set @emer_tab ='objektivascr'

declare @tab_id as int

set  @tab_id=(select [id] from [sysobjects] where [name]=@emer_tab )

print @tab_id

select [name] from [syscolumns] where [id]=@tab_id

GO
