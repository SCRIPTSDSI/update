SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  PROCEDURE [dbo].[P_ACMAD_IMPORT_ARTIKUJ] (@DBSTAND AS NVARCHAR(100)='') AS
DECLARE @QSTR AS VARCHAR(4000);
UPDATE A  SET
   A.PERSHKRIM=B.PERSHKRIM,
   A.KLASIF=B.KLASIF,
   A.CMSH  = B.CMSH,
   A.CMSH1 = B.CMSH1,
   A.CMSH2 = B.CMSH2,
   A.CMSH3 = B.CMSH3,
   A.CMSH4 = B.CMSH4,
   A.CMSH5 = B.CMSH5,
   A.CMSH6 = B.CMSH6,
   A.CMSH7 = B.CMSH7,
   A.CMSH8 = B.CMSH8,
   A.CMSH9 = B.CMSH9,
   A.BC    = B.BC,
   A.KLASIF2 = B.KLASIF2,
   A.KLASIF3 = B.KLASIF3,
   A.KLASIF4 = B.KLASIF4,
   A.KLASIF5 = B.KLASIF5,
   A.KLASIF6=B.KLASIF6,
   A.NOTACTIV=B.NOTACTIV,
   A.KOSTMES= B.KOSTMES,
   A.KOSTMES_MAN = B.KOSTMES,
   A.TATIM=b.TATIM
FROM ARTIKUJCMAD A
INNER JOIN ARTIKUJ B ON A.KOD=B.KOD
WHERE ISNULL(a.UPDATED,0) <> 1

INSERT INTO ARTIKUJCMAD ( KOD, PERSHKRIM, KLASIF, KOSTMES,KOSTMES_MAN,CMSH, CMSH1, CMSH2, CMSH3, CMSH4, CMSH5, CMSH6, CMSH7, CMSH8, CMSH9,  BC, KLASIF2, KLASIF3, KLASIF4, KLASIF5, KLASIF6,NOTACTIV,TATIM)
Select                    KOD, PERSHKRIM, KLASIF, KOSTMES,KOSTMES,CMSH, CMSH1, CMSH2, CMSH3, CMSH4, CMSH5, CMSH6, CMSH7, CMSH8, CMSH9,  BC, KLASIF2, KLASIF3, KLASIF4, KLASIF5, KLASIF6,NOTACTIV,TATIM
From Artikuj Where NOT exists (SELECT 1 from ARTIKUJCMAD a where artikuj.KOD=a.kod)



--SET @QSTR=
--' INSERT INTO '+@DBSTAND+'.DBO.ARTWEB (KOD)
--SELECT KOD FROM ARTIKUJ
-- Where ARTIKUJ.KOD NOT IN (SELECT KOD FROM '+@DBSTAND+'.DBO.ARTWEB) ';
--EXECUTE (@QSTR)

--P_ACMAD_IMPORT_ARTIKUJ 'UPDART_NEW'
--DUHET TE THIRRET PROCEDURA E KOSTOS MESATARE

GO