SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create PROCEDURE [dbo].[VW_SHITJESIPASPOSKLIENTE](@ANGA AS VARCHAR(50),@ADERI AS VARCHAR(50),@DNGA AS DATETIME
,@DDERI AS DATETIME,@MNGA AS VARCHAR(50),@MDERI AS VARCHAR(50),@DIVNGA AS VARCHAR(50),@DIVDERI AS VARCHAR(50)
,@KATNGA AS VARCHAR(50),@KATDERI AS VARCHAR(50),@DEPNGA AS VARCHAR(50),@DEPDERI AS VARCHAR(50),@FNGA AS VARCHAR(50),
@FDERI AS VARCHAR(50)
,@BCNGA AS VARCHAR(50),@BCDERI AS VARCHAR(50))
AS
IF @ANGA='' SET @ANGA = '00'
IF @ADERI='' SET @ADERI = 'ZZ'
IF @DNGA='' SET @DNGA = (SELECT dbo.DATEVALUE('01/01/2000'))
IF @DDERI='' SET @DDERI = (SELECT dbo.DATEVALUE('31/12/2099'))
IF @MNGA='' SET @MNGA = '00'
IF @MDERI='' SET @MDERI = 'ZZ'
IF @DIVNGA='' SET @DIVNGA = '00'
IF @DIVDERI='' SET @DIVDERI = 'ZZ'
IF @KATNGA='' SET @KATNGA = '00'
IF @KATDERI='' SET @KATDERI = 'ZZ'
IF @DEPNGA='' SET @DEPNGA = '00'
IF @DEPDERI='' SET @DEPDERI = 'ZZ'
IF @FNGA='' SET @FNGA = '00'
IF @FDERI='' SET @FDERI = 'ZZ'
IF @BCNGA='' SET @BCNGA = '00'
IF @BCDERI='' SET @BCDERI = 'ZZ'

CREATE TABLE #T(
	KOD varchar(50) NULL,
	CMB float NULL,
	CMSH float NULL)


INSERT INTO #T(KOD,CMB,CMSH) 
SELECT KOD, (SELECT TOP 1 CMIMB= CASE WHEN SASI=0 THEN CMIMM ELSE VLERABS/SASI END FROM FFSCR 
INNER JOIN FF ON FF.NRRENDOR= FFSCR.NRD
WHERE FF.DATEDOK<=@DDERI AND FFSCR.KARTLLG = ARTIKUJ.Kod
ORDER BY FF.DATEDOK DESC)
AS CMB, (SELECT TOP 1 CMIMSH= CASE WHEN SASI=0 THEN CMIMM ELSE VLERABS/SASI END FROM FJSCR 
INNER JOIN FJ ON FJ.NRRENDOR= FJSCR.NRD
WHERE FJ.DATEDOK<=@DDERI AND FJSCR.KARTLLG = ARTIKUJ.Kod
ORDER BY FJ.DATEDOK DESC)
AS CMSH FROM ARTIKUJ


SELECT S1.KMAG,CONVERT(VARCHAR(10), S1.DATEDOK, 103) +' '+MIN(JAVA.PERSHKRIM) AS DATEDOK,
COUNT(1) AS NR,MIN(JAVA.PERSHKRIM) AS DITA
FROM SM AS S1
INNER JOIN JAVA ON JAVA.KOD = DATEPART(WEEKDAY,S1.DATEDOK)
WHERE  S1.KMAG>=@MNGA AND S1.KMAG<=@MDERI
AND S1.DATEDOK>=@DNGA AND S1.DATEDOK<=@DDERI
--AND isnull(A.KLASIF,'00')>=@DIVNGA AND isnull(A.KLASIF,'00')<=@DIVDERI
--AND isnull(A.KLASIF2,'00')>=@DEPNGA AND isnull(A.KLASIF2,'00')<=@DEPDERI
--AND isnull(A.KLASIF3,'00')>=@KATNGA AND isnull(KLASIF3,'00')<=@KATDERI
--AND ISNULL(A.FURNKOD,'00')>=@FNGA AND ISNULL(A.FURNKOD,'00')<=@FDERI
GROUP BY S1.KMAG,S1.DATEDOK

UNION ALL

SELECT S1.KMAG,'Mesatarja',COUNT(1)/(SELECT COUNT(DISTINCT DATEDOK) FROM SM
WHERE  SM.KMAG=S1.KMAG
AND SM.DATEDOK>=@DNGA AND SM.DATEDOK<=@DDERI )
,CONVERT(VARCHAR(20), DATEDIFF(DD,MIN(S1.DATEDOK),MAX(S1.DATEDOK)))
FROM SM AS S1
WHERE  S1.KMAG>=@MNGA AND S1.KMAG<=@MDERI
AND S1.DATEDOK>=@DNGA AND S1.DATEDOK<=@DDERI
--AND isnull(A.KLASIF,'00')>=@DIVNGA AND isnull(A.KLASIF,'00')<=@DIVDERI
--AND isnull(A.KLASIF2,'00')>=@DEPNGA AND isnull(A.KLASIF2,'00')<=@DEPDERI
--AND isnull(A.KLASIF3,'00')>=@KATNGA AND isnull(KLASIF3,'00')<=@KATDERI
--AND ISNULL(A.FURNKOD,'00')>=@FNGA AND ISNULL(A.FURNKOD,'00')<=@FDERI
GROUP BY S1.KMAG
GO