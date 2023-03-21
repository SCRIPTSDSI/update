SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [RS].[spCalculateTotRows](@RowID as integer) 
as
begin
declare @IsTotal bit,
		@IsFormule bit,
		@IsNote bit,
		@IsAnalize bit,
		@totLeftVl float,
		@totRightVl float,
		@vLeft float,
		@vRight float,
		@sTotLeft float,
		@sTotRight float,
		@vl1 float,
		@vl2 float

set @vl1=0
set @vl2=0

	Declare db_totCursor cursor for
	SELECT rp.IsTotal,rp.IsFormule,rp.IsNote,rp.IsAnalize,rp.TOT_LEFT_VL,rp.TOT_RIGHT_VL,rp.VLEFT,rp.VRIGHT,rp.SUB_TOT_ROW_LEFT_VL,rp.SUB_TOT_ROW_RIGHT_VL
    From Rs.TotRows tr                                  
    Inner Join ##RAP_ROWS rp ON tr.TotRowID=rp.ID       
    Where tr.RowID=@RowID

	open db_totCursor;
	fetch next from db_totCursor into @IsTotal,@IsFormule,@IsNote,@IsAnalize,@totLeftVl,@totRightVl,@vLeft,@vRight,@sTotLeft,@sTotRight

	While @@FETCH_STATUS=0
	begin
		if @IsAnalize=1
		begin
			if (@IsTotal=1) or (@IsFormule=1 and @IsNote=1)
			begin
				set @vl1=@vl1+isnull(@totLeftVl,0)
				set @vl2=@vl2+isnull(@totRightVl,0)
			end
			else
			begin
				set @vl1=@vl1+isnull(@vLeft,0)
				set @vl2=@vl2+isnull(@vRight,0)
			end
		end
		else --not analize
		begin
			set @vl1=@vl1+isnull(@sTotLeft,0)
			set @vl2=@vl2+isnull(@sTotRight,0)
		end
	fetch next from db_totCursor into @IsTotal,@IsFormule,@IsNote,@IsAnalize,@totLeftVl,@totRightVl,@vLeft,@vRight,@sTotLeft,@sTotRight
	end
	update ##RAP_ROWS SET TOT_LEFT_VL=@vl1, TOT_RIGHT_VL=@vl2 where ID=@RowID

	close db_totCursor
	deallocate db_totCursor
end
GO
