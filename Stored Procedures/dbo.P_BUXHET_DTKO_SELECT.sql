SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[P_BUXHET_DTKO_SELECT]
  @TIPI INT,
  @RRESHTA VARCHAR(50),
  @RRESHTA_TABELA VARCHAR(50),
  @BUXHETI_KOD VARCHAR(25) AS
DECLARE 
  @KOLONA VARCHAR(50) ,
  @sMIN_DATE VARCHAR(10),
  @sMAX_DATE  VARCHAR(10),
  @MIN_DATE DATETIME,
  @MAX_DATE DATETIME,
  @sVITI VARCHAR(4),
  @sWHERE VARCHAR(2000),
  @sHAVING VARCHAR(1000),
  @sAND_RRESHTI VARCHAR(50),
  @QUERY NVARCHAR(4000);
  
  
--viti maksimal i te dhenave ne tabelen BUXHET
SET @sVITI = CONVERT(VARCHAR(4),YEAR(GETDATE()))
  

------------------------------------------------------------------------------------------------------
-- DATA MINIMALE
------------------------------------------------------------------------------------------------------
--Nese datat minimale dhe maximale jane brenda te njejtit vit
--       YYYYMMDD
-- DUHET 20120101
SELECT @MIN_DATE = ISNULL(MIN(DATA),GETDATE()),@MAX_DATE=ISNULL(MAX(DATA),GETDATE()) FROM dbo.BUXHET;

IF YEAR(@MIN_DATE)=year(GETDATE()) 
SET @sMIN_DATE=@sVITI+'0101' 
ELSE
SET @sMIN_DATE=
     CONVERT(VARCHAR(4),YEAR(@MIN_DATE))+
     REPLICATE('0',2-DATALENGTH(CONVERT(VARCHAR(2),MONTH(@MIN_DATE))))+CONVERT(VARCHAR(2),MONTH(@MIN_DATE))+
     REPLICATE('0',2-DATALENGTH(CONVERT(VARCHAR(2),DAY(@MIN_DATE))))+CONVERT(VARCHAR(2),DAY(@MIN_DATE))
------------------------------------------------------------------------------------------------------
-- DATA MAKSIMALE
------------------------------------------------------------------------------------------------------
IF YEAR(@MAX_DATE)>year(GETDATE()) 
   SET @sVITI = CONVERT(VARCHAR(4),YEAR(@MAX_DATE))
SET @sMAX_DATE=@sVITI+'1231';
------------------------------------------------------------------------------------------------------
--NDERTIMI I TABELES TEMPORANE ME DATA
if object_id('dbo.DATA_TMP') is not null
begin
  drop table dbo.DATA_TMP
END

SELECT *  INTO DATA_TMP  
 FROM F_TABLE_DATE ( @sMIN_DATE,@sMAX_DATE )

SET @sWHERE=' ';
SET @sHAVING=' ';
SET @sAND_RRESHTI=' ';

IF @RRESHTA='LLOGARI_KOD' 
  SET  @sAND_RRESHTI=' AND T1.POZIC=1 '

-------------------------------------------------------------------------------------------------------
IF @TIPI = 1 SET @KOLONA = 'DATE' 
ELSE
IF @TIPI = 2 SET @KOLONA = 'WEEK_STARTING_MON_DATE' 
ELSE
IF @TIPI = 3 SET @KOLONA = 'MONTH_DATE' 
ELSE
IF @TIPI = 4 SET @KOLONA = 'QUARTER_DATE' 
ELSE
IF (@TIPI = 5) OR  
   (@TIPI = 6) 
             SET @KOLONA = 'YEAR_DATE' ;
-------------------------------------------------------------------------------------------------------
IF @TIPI <> 1 
 BEGIN
  SET @sWHERE = ' AND T2.DATE >= T2.START_OF_'+@KOLONA+' AND T2.DATE<=T2.END_OF_'+@KOLONA;  
  SET @KOLONA = 'START_OF_'+@KOLONA; --...KUJDES...NUK DUHET TE KALOJ SIPER RRESHTI SET @sWHERE ...
 END 

IF @TIPI= 6 
   SET @sHAVING = ' HAVING SUM(B.VLERA)>0 ' ;


	SET @QUERY=
	'SELECT  
	  RRESHTI = T1.KOD, 
	  PERSHKRIM=MAX(T1.PERSHKRIM),
      KOLONA=MAX(t2.'+@KOLONA+'),   
      VLERA=SUM(B.VLERA) 
	  FROM '+@RRESHTA_TABELA+' T1 
	  INNER JOIN DATA_TMP  T2 ON 1=1 
	  LEFT JOIN BUXHET B ON B.'+@RRESHTA+'=T1.KOD AND B.DATA=T2.DATE AND B.BUXHET_KOD= '''+@BUXHETI_KOD +''' WHERE 1=1 ' +
	   +@sWHERE +@sAND_RRESHTI+
	 ' GROUP BY T1.KOD, t2.'+@KOLONA +' '
	   +@sHAVING+
	 ' ORDER BY T1.KOD,MAX(t2.'+@KOLONA+')'
	 
	--SELECT @QUERY; 
	EXECUTE sys.sp_executesql @QUERY 
GO
