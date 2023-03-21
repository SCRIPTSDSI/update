SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create PROCEDURE [dbo].[VW_RAPORTETSHSMORARE](@ANGA AS VARCHAR(50),@ADERI AS VARCHAR(50),@DNGA AS DATETIME
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

--SELECT @ANGA,@ADERI

CREATE TABLE #T(
	KOD varchar(50) NULL,
	CMB float NULL,
	CMSH float NULL)
CREATE NONCLUSTERED INDEX IX_T ON #T 
(
	KOD ASC
)


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



select  SC.BC AS BARKOD ,MIN(SC.KARTLLG) AS KODARTIKULLI,
		MIN(SC.PERSHKRIM) AS EMERTIM,SUM(SC.SASI) AS SASIAESHITUR,MIN(SC.NJESI) AS NJESIA,
		CASE WHEN SUM(SC.SASI)=0 THEN AVG(SC.CMIMM) ELSE SUM(SC.VLERABS)/SUM(SC.SASI) END AS CMSHSH,
		CASE WHEN SUM(SC.SASI)=0 THEN AVG(SC.CMIMM) ELSE SUM(SC.VLERABS) END AS VLERASH,
		CASE WHEN SUM(SC.SASI)=0 THEN AVG(SC.CMIMM)-MIN(T.CMB) ELSE SUM(SC.VLERABS)/SUM(SC.SASI)-MIN(T.CMB) END  AS MARZHI,
		MIN(A.FURNKOD) AS FURNITORI,MIN(A.KLASIF) AS DIVIZION,MIN(A.KLASIF2) AS DEPARTAMENT,MIN(A.KLASIF3) AS KATEGORI
		--,MIN(T.CMB) AS CMBF,MIN(T.CMSH) AS CMSHF,MIN(T.CMSH)-MIN(T.CMB) AS MAKTUALF
FROM SMSCR AS SC
		INNER JOIN SM ON SM.NRRENDOR = SC.NRD
		LEFT JOIN ARTIKUJ A ON A.KOD = SC.KARTLLG
		LEFT JOIN #T AS T ON SC.KARTLLG = T.KOD
WHERE SC.KARTLLG>=@ANGA AND SC.KARTLLG<=@ADERI
		AND ISNULL(SC.BC,'00')>=@BCNGA AND ISNULL(SC.BC,'00')<=@BCDERI
		AND SM.KMAG>=@MNGA AND SM.KMAG<=@MDERI
		AND SM.DATEDOK>=@DNGA AND SM.DATEDOK<=@DDERI
		AND isnull(A.KLASIF,'00')>=@DIVNGA AND isnull(A.KLASIF,'00')<=@DIVDERI
		AND isnull(A.KLASIF2,'00')>=@DEPNGA AND isnull(A.KLASIF2,'00')<=@DEPDERI
		AND isnull(A.KLASIF3,'00')>=@KATNGA AND isnull(KLASIF3,'00')<=@KATDERI
		AND ISNULL(A.FURNKOD,'00')>=@FNGA AND ISNULL(A.FURNKOD,'00')<=@FDERI
		AND SC.TIPKLL='K'
GROUP BY SM.DATEDOK,DATEPART(HH,SM.DATEDOK),SC.BC,SC.KARTLLG,A.KOD
ORDER BY SC.BC


--SELECT * FROM #T WHERE KOD = @ANGA
--SELECT @ANGA,@ADERI
--SELECT * FROM FJSCR WHERE isnull(kartllg,'')='SM04150C2'
--SELECT * FROM fdscr WHERE isnull(kartllg,'')='SM04150C2'
--SELECT * FROM ARTIKUJ WHERE isnull(FURNKOD,'')=''
--SELECT * FROM ARTIKUJ WHERE isnull(KLASIF,'00')=''
--SELECT * FROM ARTIKUJ WHERE isnull(KLASIF2,'00')=''
--SELECT * FROM ARTIKUJ WHERE isnull(KLASIF3,'00')=''
--SELECT * FROM FJ WHERE ISNULL(KMAG,'')=''
--SELECT * FROM FJSCR ORDER BY KARTLLG 

--SELECT * FROM FDSCR

--select * from artikuj where KOD='SM04150C2'
GO