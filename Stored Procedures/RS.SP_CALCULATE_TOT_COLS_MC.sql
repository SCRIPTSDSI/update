SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [RS].[SP_CALCULATE_TOT_COLS_MC]
AS
BEGIN
UPDATE ##RAP_ROWS
	SET Value=B.Value
From ##RAP_ROWS A 
INNER JOIN 
	(
		SELECT ColID=B.ColID,RowID=A.RowID,Value=SUM(A.Value)
		FROM ##RAP_ROWS A
		INNER JOIN RS.TotColumns B ON A.ColID=B.TotColID
		GROUP BY B.ColID,RowID
	)AS B ON A.ColID=B.ColID AND A.RowID=B.RowID
WHERE ISNULL(IsValue,0)=0
END
GO
