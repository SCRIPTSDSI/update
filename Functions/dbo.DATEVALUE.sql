SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE   FUNCTION [dbo].[DATEVALUE]
(@data as varchar(10))
RETURNS DATETIME 
AS
begin
	return (convert(datetime,@data,104))
end

GO
