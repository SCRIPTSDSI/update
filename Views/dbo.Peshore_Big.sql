SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 CREATE view [dbo].[Peshore_Big]
 as 
 select  [PLU NO]=bc, Name=pershkrim, Code=bc, 
 Price=CONVERT(VARCHAR(6),RIGHT('00000' + CONVERT(VARCHAR(20),cmsh),6)),
  Mode=0, Shelflife=1000, Tare=0,
        [Label NO]=1,	[Shop NO]=98
 from artikuj 
 where klasif4 ='P' and len(bc)=5


GO
