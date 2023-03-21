SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO






CREATE   VIEW [dbo].[zzTransportFieldsReport] 

AS
 
      SELECT TOP 100 PERCENT 
             KOD,
             TARGE         = F009,
             SHOFER        = F004,
             UDHETIM       = F001,
             DATENISJE     = F011,
             VENDNISJE     = F012,
             DATEKTHIM     = F013,
             VENDKTHIM     = F014,
             EKSPORT       = F005,
             TRANZIT       = F007,
             KODDEP        = KODDEP,
             KODLIST       = KODLIST,
             KMNISJE       = F103,
             KMKTHIM       = F105,
             KMTOTAL       = F101,
             
             NAFTELITRA    = F109,
             NAFTEKM       = F110,
             ADBLUELITRA   = F111,
             ADBLUEKM      = F112
             
         --  KMDIF         = CASE WHEN ISNUMERIC(REPLACE(F103,',',''))=1 AND ISNUMERIC(REPLACE(F105,',',''))=1 
         --                       THEN CAST(REPLACE(F105,',','') AS BIGINT) - CAST(REPLACE(F103,',','') AS BIGINT) 
         --                       ELSE 0 
         --                  END
             
           --,* 
        FROM zzTransportData01 
--  ORDER BY DATENISJE 






GO
