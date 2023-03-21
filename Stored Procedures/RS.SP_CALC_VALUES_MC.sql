SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [RS].[SP_CALC_VALUES_MC]
AS 
BEGIN
	Exec [RS].SP_CalculateCustomDateValues_MC
	Exec [RS].SP_CALCULATE_TOT_COLS_MC
	Exec [RS].SP_CALCULATE_TOT_ROWS_MC

	DECLARE @RowID INT

	DECLARE CALC_CURSOR CURSOR FOR 
	SELECT
		DISTINCT RowID
	FROM ##RAP_ROWS WHERE IsFormule=1

	OPEN CALC_CURSOR;
	FETCH NEXT FROM CALC_CURSOR INTO @RowID

	WHILE @@FETCH_STATUS=0
	BEGIN
		Exec [RS].SP_CalculateFormuleRow_MC @RowID
	FETCH NEXT FROM CALC_CURSOR INTO @RowID
	END
	CLOSE CALC_CURSOR;
	DEALLOCATE CALC_CURSOR
END
GO