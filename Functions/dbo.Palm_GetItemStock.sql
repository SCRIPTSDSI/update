SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Function [dbo].[Palm_GetItemStock]
(
	@Artikull	nvarchar(50), 
	@Barkod		nvarchar(50), 
	@Magazina	nvarchar(50)
)
Returns Float
As
Begin

Declare @Sasi float

	Select @Sasi = Sum(Sasih-Sasid) 
	From LevizjeHd 
	Where Kartllg = @Artikull 
	And Kmag = @Magazina

Return IsNull(@Sasi, 0)
End

GO
