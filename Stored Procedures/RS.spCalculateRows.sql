SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure  [RS].[spCalculateRows](@NDERM as varchar(15),@NDERM_PARA as varchar(15))
as 
begin
declare @isAnalize bit,
		@isTotal bit,
		@isFormule bit,
		@IsCalculated bit,
		@isNoteOrTotal bit,
		@isNote bit,
		@formule varchar(100),
		@id int,
		@sql nvarchar(max)
	


--llogarisim rreshtat qe jane "Custom Date"
SET @SQL=N'
UPDATE ##RAP_ROWS 
	SET VLEFT= ([Sign])*(CASE WHEN IsValueLeft=1
					THEN VLEFT
					ELSE (SELECT SUM(ISNULL(DBKRMV,0)) FROM ['+@NDERM+']..FK A INNER JOIN ['+@NDERM+']..FKSCR B ON B.NRD=A.NRRENDOR WHERE DATEDOK <= ##RAP_ROWS.CUSTOM_DATE AND LLOGARIPK IN (SELECT KOD FROM RS.RowLlogs WHERE RowID=##RAP_ROWS.ID AND POS=''L''))
				END),
		VRIGHT=([Sign])*(CASE WHEN IsValueRight=1
					THEN VRIGHT
					ELSE (SELECT SUM(ISNULL(DBKRMV,0)) FROM ['+@NDERM_PARA+']..FK A INNER JOIN ['+@NDERM_PARA+']..FKSCR B ON B.NRD=A.NRRENDOR WHERE DATEDOK <= DATEADD(YEAR,-1,##RAP_ROWS.CUSTOM_DATE) AND LLOGARIPK IN (SELECT KOD FROM RS.RowLlogs WHERE RowID=##RAP_ROWS.ID AND POS=''R''))
				END),
		Calculated=CAST(1 AS BIT)	
WHERE IsCustomDate=1'
EXEC sp_executesql @SQL


declare db_cursor cursor for
SELECT ID,IsAnalize,IsTotal,IsFormule,IsNote,IsCalculated,Formula FROM ##RAP_ROWS
WHERE ISNULL(Calculated,0)=0 ORDER BY RowLevel DESC,RowIndex 

open db_cursor
fetch next from DB_CURSOR into @id,@isAnalize,@istotal,@isFormule,@isNote,@isCalculated,@formule

while @@FETCH_STATUS=0
begin
if @isAnalize=1 
begin
	if (@isTotal=1 or @isNote=1)
		set @isNoteOrTotal=1
	else
		set @isNoteOrTotal=0

	if @isTotal=1
		Exec rs.spCalculateTotRows @id
	else
		Exec rs.spCalculateFormule @id,@formule,@isNoteOrTotal
end
else
begin 
--llogarisim rreshtin qe ka nenrreshta
	UPDATE ##RAP_ROWS
		 SET SUB_TOT_ROW_LEFT_VL =ISNULL((SELECT SUM(isnull(round(VLEFT,3),0))  FROM ##RAP_ROWS A INNER JOIN RS.GET_SUB_ROWS(@id) B ON A.ID=B.ID),0), 
			 SUB_TOT_ROW_RIGHT_VL=ISNULL((SELECT SUM(isnull(VRIGHT,0)) FROM ##RAP_ROWS A INNER JOIN RS.GET_SUB_ROWS(@id) B ON A.ID=B.ID),0) 
	WHERE ID=@id
end	
fetch next from db_cursor into @id,@isAnalize,@istotal,@isFormule,@isNote,@isCalculated,@formule
end

close db_cursor
deallocate db_cursor

end
GO
