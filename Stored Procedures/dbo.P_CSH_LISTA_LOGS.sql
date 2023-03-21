SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[P_CSH_LISTA_LOGS] 
  @ID INT,
  @OPERATOR VARCHAR(20),
  @TIP_VEPRIMI VARCHAR(2)
AS   
INSERT INTO dbo.CSH_LISTA_LOGS
           (TIP_SHITJE
           ,KOD_SHITJE
           ,KOD
           ,KMON
           ,NJESI
           ,SASIA_MINIMALE
           ,TIP_CMIMI
           ,CMIMI
           ,MARZHI
           ,DATE_FILLIMI
           ,DATE_MBARIMI
           ,PERFSHIN_TVSH
           ,LEJO_SKONTO_RRESHT
           ,LEJO_SKONTO_TOTAL
           ,VAT_Business_Posting_Group
           ,HOST
           --,HOST_IP
           ,OPERATOR
           ,DATA
           ,TIP_VEPRIMI )

SELECT 
           TIP_SHITJE
           ,KOD_SHITJE
           ,KOD
           ,KMON
           ,NJESI
           ,SASIA_MINIMALE
           ,TIP_CMIMI
           ,CMIMI
           ,MARZHI
           ,DATE_FILLIMI
           ,DATE_MBARIMI
           ,PERFSHIN_TVSH
           ,LEJO_SKONTO_RRESHT
           ,LEJO_SKONTO_TOTAL
           ,VAT_Business_Posting_Group
           ,HOST=HOST_NAME ()
           --,HOST_IP=client_net_address
           ,OPERATOR=@OPERATOR
           ,DATA=GETDATE()
           ,TIP_VEPRIMI=@TIP_VEPRIMI
FROM CSH_LISTA--,sys.dm_exec_connections
WHERE ID=@ID
           
GO
