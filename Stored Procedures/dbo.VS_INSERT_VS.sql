SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE     PROCEDURE [dbo].[VS_INSERT_VS]
(
@PKODUSER     AS VARCHAR(10),--kodi i userit te finances
@PDATEDOK     AS DATETIME,   --data e fatures  
@PPERSHKRIM   AS VARCHAR(60),
@PKMON        AS VARCHAR(3), --kod i monedhes 
@PKURS2       AS FLOAT,      --kursi (ne rast lek=1)

@PNRRENDOR AS INT OUTPUT  --kthen nrrendorin e fj te sapo krijuar
)
AS

DECLARE @VNRDOKMIN AS INTEGER
DECLARE @VNRDOKMAX AS INTEGER
DECLARE @VNRDOK AS INTEGER

SET @VNRDOKMIN=1
SET @VNRDOKMAX=1000

SET @VNRDOK   =ISNULL((SELECT MAX(NRDOK) AS NRMAX FROM VS 
                WHERE (YEAR(DATEDOK)=YEAR(@PDATEDOK)) AND 
                (NRDOK BETWEEN @VNRDOKMIN AND @VNRDOKMAX))+1,@VNRDOKMIN)


INSERT INTO [VS]
           ([KODNENDITAR]
           ,[NRDOK]
           ,[DATEDOK]
           ,[PERSHKRIM1]
           ,[PERSHKRIM2]
           ,[KMON]
           ,[KURS1]
           ,[KURS2]
           ,[NRDFK]
           ,[POSTIM]
           ,[LETER]
           ,[FIRSTDOK]
           ,[KLASIFIKIM]
           ,[USI]
           ,[USM]
           ,[TROW]
           ,[TAGNR])
    SELECT ''
           ,@VNRDOK
           ,@PDATEDOK
           ,@PPERSHKRIM
           ,''
           ,ISNULL(@PKMON,'')
           ,1
           ,@PKURS2
           ,0
           ,0
           ,NULL
           ,''
           ,NULL
           ,'I'
           ,'I'
           ,0
           ,-1

SET @PNRRENDOR=@@IDENTITY

UPDATE VS SET FIRSTDOK='E'+CAST(CAST(@PNRRENDOR AS BIGINT) AS VARCHAR) WHERE NRRENDOR=@PNRRENDOR

RETURN







GO
