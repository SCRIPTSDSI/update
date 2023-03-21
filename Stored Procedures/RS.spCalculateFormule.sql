SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [RS].[spCalculateFormule](@rowID as int,@formule varchar(100),@isNoteOrTotal bit)
as
begin
declare @tempStr varchar(100),
		@fRowID int,
		@isAnalize bit,
		@isNote bit,
		@isTotal bit,
		@lValue float,
		@rValue float,
		@vLeft float,
		@vRight float,
		@totLeftVl float,
		@totRightVl float,
		@sTotLeftVl float,
		@sTotRightVl float,
		@fLeft varchar(500),
		@fRight varchar(500),
		@sql nvarchar(max)

set @lValue=0
set @rValue=0
set @fLeft=@formule
set @fRight=@formule

while charindex('[',@formule)<>0
begin
	set @tempStr=substring(@formule,charindex('[',@formule),charindex(']',@formule)-charindex('[',@formule) + len(']'))
	set @fRowID=replace(replace(@tempStr,'[',''),']','')

	select @isAnalize=IsAnalize,@isTotal=IsTotal,@isNote=IsNote,@vLeft=VLEFT,@vRight=VRIGHT,@totLeftVl=TOT_LEFT_VL,@totRightVl=TOT_RIGHT_VL,@sTotLeftVl=SUB_TOT_ROW_LEFT_VL,@sTotRightVl=SUB_TOT_ROW_RIGHT_VL
	from ##RAP_ROWS
	where ID=@fRowID

	if @isAnalize=1
	begin
		if (@isTotal=1 or @isNote=1)
		begin
			set @lValue=isnull(round(@totLeftVl,2),0)
			set @rValue=isnull(round(@totRightVl,2),0)
		end
		else
		begin
			set @lValue=isnull(round(@vLeft,2),0)
			set @rValue=isnull(round(@vRight,2),0)
		end
	end
	else
	begin -- is not analize
		set @lValue=isnull(round(@sTotLeftVl,2),0)
		set @rValue=isnull(round(@sTotRightVl,2),0)  
	end
	set @fLeft=replace(@fLeft,@tempStr,'('+cast(cast(@lValue as decimal(20,4)) as varchar)+')')
    set @fRight=replace(@fRight,@tempStr,'('+cast(cast(@rValue as decimal(20,4)) as varchar)+')')
    set @formule=replace(@formule,@tempStr,'');

end --end while


set @Sql=N'SELECT @lValue='+@fLeft+',@rValue='+@fRight

exec sp_executesql @Sql,N'@lValue FLOAT OUTPUT,@rValue FLOAT OUTPUT',@lValue OUTPUT,@rValue OUTPUT

if @isNoteOrTotal=1
	update ##RAP_ROWS set TOT_LEFT_VL=@lValue,TOT_RIGHT_VL=@rValue WHERE ID=@rowID
else
	update ##RAP_ROWS set VLEFT=@lValue,VRIGHT=@rValue WHERE ID=@rowID

end --end procedure
GO
