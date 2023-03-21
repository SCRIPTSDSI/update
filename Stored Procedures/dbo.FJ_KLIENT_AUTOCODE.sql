SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE   procedure [dbo].[FJ_KLIENT_AUTOCODE]
(
@PUSERTYPE AS VARCHAR(1),
@PSHOPCODE AS VARCHAR(3),

@NEWCODE   AS VARCHAR(14) OUTPUT
)
AS

DECLARE @VPRFIKS  AS VARCHAR(10)
DECLARE @VAUTOINC AS VARCHAR(4)


SET @VPRFIKS =@PUSERTYPE+
              RIGHT(CAST(YEAR(GETDATE())      AS VARCHAR),2)+
              RIGHT('0'+CAST(MONTH(GETDATE()) AS VARCHAR),2)+
              RIGHT('0'+CAST(DAY(GETDATE())   AS VARCHAR),2)+
              @PSHOPCODE

SET @VAUTOINC=RIGHT('000'+CAST((SELECT COUNT('')+1 
                                 FROM KLIENT 
                                WHERE LEFT(KOD,10)=@VPRFIKS) AS VARCHAR),4)

SET @NEWCODE=@VPRFIKS+@VAUTOINC

SELECT KODIRI=@NEWCODE



GO
