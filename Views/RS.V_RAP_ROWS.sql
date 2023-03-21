SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [RS].[V_RAP_ROWS]
AS

WITH CTE_RapRows(RapID, ID, Pershkrim, RefID, RowIndex,IsValueLeft,IsValueRight,ValueLeft,ValueRight, IsTotal,IsBold, IsNote,IsShowValue,IsAnalize, IsFirstChild, IsLastChild,IsSummRow, RowLevel,GRUP,IsFormule,Formula,[Sign],IsBeforeDate,IsEndDate,IsCustomDate,D,M,NrPrevYear) 
AS
 (
 SELECT    RapID, ID, Pershkrim, RefID, RowIndex,IsValueLeft,IsValueRight,ValueLeft,ValueRight, IsTotal,IsBold, IsNote,IsShowValue,IsAnalize, IsFirstChild, IsLastChild,IsSummRow,1 AS RowLevel,GRUP,IsFormule,Formula,[Sign],IsBeforeDate,IsEndDate,IsCustomDate,D,M,NrPrevYear
	FROM            RS.[Rows] AS P
	WHERE        (RefID IS NULL)
	UNION ALL
	SELECT        R.RapID, R.ID, R.Pershkrim, R.RefID, R.RowIndex,R.IsValueLeft,R.IsValueRight,R.ValueLeft,R.ValueRight, R.IsTotal,R.IsBold, R.IsNote,R.IsShowValue,R.IsAnalize, R.IsFirstChild,
							R.IsLastChild,R.IsSummRow, CTE.RowLevel + 1 AS RapLevel,R.GRUP,R.IsFormule,r.Formula,r.[Sign],r.IsBeforeDate,r.IsEndDate,R.IsCustomDate,R.D,R.M,R.NrPrevYear 
	FROM            RS.[Rows] AS R INNER JOIN
							CTE_RapRows AS CTE ON CTE.ID = R.RefID
	WHERE        (R.RefID IS NOT NULL)
)
SELECT        RapID, ID, Pershkrim, RefID, RowIndex,IsValueLeft,IsValueRight,ValueLeft,ValueRight, IsTotal, IsBold,IsNote,IsShowValue,IsAnalize, IsFirstChild, IsLastChild,IsSummRow,RowLevel,GRUP,IsFormule,Formula,[Sign],IsBeforeDate,IsEndDate,IsCustomDate,D,M,NrPrevYear 
FROM            CTE_RapRows
GO
