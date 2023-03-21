SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[P_CSH_PROMOCION_nga_KALKULIMI] 
(
 @ID INT
 ) 
AS


--select * from CSH_PROMOCION

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
           ,HOST_IP
           ,OPERATOR
           ,DATA
           ,TIP_VEPRIMI )

SELECT 
           CSH_LISTA.TIP_SHITJE
           ,CSH_LISTA.KOD_SHITJE
           ,CSH_LISTA.KOD
           ,CSH_LISTA.KMON
           ,CSH_LISTA.NJESI
           ,CSH_LISTA.SASIA_MINIMALE
           ,CSH_LISTA.TIP_CMIMI
           ,CSH_LISTA.CMIMI
           ,CSH_LISTA.MARZHI
           ,CSH_LISTA.DATE_FILLIMI
           ,CSH_LISTA.DATE_MBARIMI
           ,CSH_LISTA.PERFSHIN_TVSH
           ,CSH_LISTA.LEJO_SKONTO_RRESHT
           ,CSH_LISTA.LEJO_SKONTO_TOTAL
           ,CSH_LISTA.VAT_Business_Posting_Group
           ,HOST=HOST_NAME ()
           ,HOST_IP=(Select top 1 client_net_address from sys.dm_exec_connections 
                     where session_id = @@SPID)
           ,C.OPERATOR
           ,DATA=GETDATE()
           ,TIP_VEPRIMI='UP'
FROM CSH_PROMOCION_SCR CS 
INNER JOIN CSH_PROMOCION C ON C.ID = CS.MASTER_ID 
inner join CSH_LISTA On C.DATE_FILLIMI = CSH_LISTA.DATE_FILLIMI 
                And C.TIP_SHITJE = CSH_LISTA.TIP_SHITJE
                And isnull(C.KOD_SHITJE,'') = isnull(CSH_LISTA.KOD_SHITJE,'')
                And CS.KOD       = CSH_LISTA.KOD 
WHERE C.ID=@ID 


Update CSH_LISTA Set CMIMI = CS.Cmimi
FROM CSH_PROMOCION_SCR CS 
INNER JOIN CSH_PROMOCION C ON C.ID = CS.MASTER_ID 
Inner Join csh_lista On C.DATE_FILLIMI = CSH_LISTA.DATE_FILLIMI 
                And C.TIP_SHITJE = CSH_LISTA.TIP_SHITJE
                And isnull(C.KOD_SHITJE,'') = isnull(CSH_LISTA.KOD_SHITJE,'')
                And CS.KOD       = CSH_LISTA.KOD 
WHERE C.ID=@id
 

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
           ,HOST_IP
           ,OPERATOR
           ,DATA
           ,TIP_VEPRIMI )

SELECT 
            TIP_SHITJE
           ,KOD_SHITJE
           ,CS.KOD
           ,KMON					= ''
           ,NJESI
           ,SASIA_MINIMALE  =0
           ,TIP_CMIMI
           ,CMIMI
           ,MARZHI=0
           ,DATE_FILLIMI
           ,DATE_MBARIMI
           ,PERFSHIN_TVSH = 0
           ,LEJO_SKONTO_RRESHT		= 0
           ,LEJO_SKONTO_TOTAL		= 0
           ,VAT_Business_Posting_Group = 0
           ,HOST=HOST_NAME ()
           ,HOST_IP=(Select top 1 client_net_address from sys.dm_exec_connections 
                     where session_id = @@SPID)
           ,C.OPERATOR
           ,DATA=GETDATE()
           ,TIP_VEPRIMI='IN'
FROM CSH_PROMOCION_SCR CS 
INNER JOIN CSH_PROMOCION C ON C.ID = CS.MASTER_ID 
WHERE C.ID=@ID 
And Not Exists (Select 1 From CSH_LISTA A 
				Where C.DATE_FILLIMI = A.DATE_FILLIMI 
				And C.TIP_SHITJE = A.TIP_SHITJE
				And isnull(C.KOD_SHITJE,'') = isnull(A.KOD_SHITJE,'')
				And CS.KOD       = A.KOD )



INSERT INTO CSH_LISTA
           (
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
           ,BC
           ,PRIORITET
           
           )
SELECT             
			TIP_SHITJE              = C.TIP_SHITJE
           ,KOD_SHITJE 				= (CASE WHEN C.TIP_SHITJE='PR' THEN C.KOD ELSE C.KOD_SHITJE END)
           ,KOD						= CS.KOD
           ,KMON					= ''
           ,NJESI					= CS.NJESI
           ,SASIA_MINIMALE			= 0	
           ,TIP_CMIMI               = C.TIP_CMIMI
           ,CMIMI					= CS.CMIMI
           ,MARZHI					= 0
           ,DATE_FILLIMI			= C.DATE_FILLIMI
           ,DATE_MBARIMI			= C.DATE_MBARIMI
           ,PERFSHIN_TVSH			= 0
           ,LEJO_SKONTO_RRESHT		= 0
           ,LEJO_SKONTO_TOTAL		= 0
           ,VAT_Business_Posting_Group = 0
           ,BC						= ''
           ,PRIORITET				= C.PRIORITET
FROM CSH_PROMOCION_SCR CS 
INNER JOIN CSH_PROMOCION C ON C.ID = CS.MASTER_ID 
WHERE 
C.ID=@ID 
And Not Exists (Select 1 From CSH_LISTA A 
                Where C.DATE_FILLIMI = A.DATE_FILLIMI 
                And C.TIP_SHITJE = A.TIP_SHITJE
                And isnull(C.KOD_SHITJE,'') = isnull(A.KOD_SHITJE,'')
                And CS.KOD       = A.KOD )

GO
