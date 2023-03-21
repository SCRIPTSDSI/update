SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--select getdate()
--Exec Palm_MerrGjendjePivot 'a', 'z', 'a', 'z', '2014-12-01 11:19:14.973', 'ADMIN'
CREATE Proc [dbo].[Palm_MerrGjendjePivot]
(	
	@Magazina1	nvarchar(60),
	@Magazina2	nvarchar(60),
	@Artikull1	nvarchar(60),
	@Artikull2	nvarchar(60),
	@Date		datetime,
	@User		nvarchar(50)
)
As
--
--	Declare @kolona		nvarchar(max),
--			@pershkrim	nvarchar(max),
--			@sql		nvarchar(max)
--
--	if(@Magazina1 = '') 
--	Set @Magazina1 = '!'
--
--	if(@Magazina2 = '') 
--	Set @Magazina2 = 'Z'
--
--
--	if object_id('tempdb..#t') is not null
--	drop table #t
--	Create table #t(kod	nvarchar(50), pershkrim nvarchar(max))
--	insert into #t
--	Exec Palm_Merr_Magazina 'ADMIN', 'SOURCE'
--	--select * from #t
--	
--	Select @kolona = COALESCE(@kolona + ',[' + Kod + ']', '[' + Kod + ']') From #t
--	Select @pershkrim = COALESCE(@pershkrim + ',ISNULL([' + Kod + '],0)' + 'AS ['+ Pershkrim +']'   ,'ISNULL([' + Kod+ '],0)'+ 'AS ['+ Pershkrim +']' ) From #t
--
--	Set @sql =		' Select '+ @pershkrim
--				+	' From ( Select Kmag, Kartllg, Sasi =  (Sasih-Sasid) From Levizjehd Where Kmag >= '''+@Magazina1+''' And Kmag<='''+@Magazina2+''' And Kartllg >= '''+@Artikull1+''' And Kartllg<='''+@Artikull2+''') A '
--				+	' Pivot ( Sum(Sasi) For Kmag In (' + @kolona
--				+	' ))p Order By Kartllg'
--	print @Sql
--	Exec ( @Sql )

Select Sasi =Sum(Sasih-Sasid)
From Levizjehdsm 
Where Kartllg>= @Artikull1 And Kartllg<=@Artikull2
Group By Kmag, Kartllg
GO
