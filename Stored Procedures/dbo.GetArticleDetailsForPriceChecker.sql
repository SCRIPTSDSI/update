SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROC [dbo].[GetArticleDetailsForPriceChecker](@barcode as varchar(50))
as
set @barcode = REPLACE(@barcode,'F','');
set @barcode = REPLACE(@barcode,CHAR(13),'');
--set @barcode = REPLACE(@barcode,'r','');
--set @barcode = SUBSTRING(@barcode,0,len(@barcode)-2)

select top 1 a.kod,a.pershkrim,a.cmsh from artikuj a
left join artikujbcscr b on b.nrd = a.nrrendor
where a.kod = @barcode or a.bc = @barcode or b.bc=@barcode




--exec GetArticleDetailsForPriceChecker 'F5304000011888'
GO
