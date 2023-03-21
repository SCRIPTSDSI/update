SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[P_BUXHET_T1T2_SELECT] 
  @TIPI INT, 
  @KOLONA VARCHAR(50) ,
  @KOLONA_TABELA VARCHAR(50),
  @RRESHTA VARCHAR(50),
  @RRESHTA_TABELA VARCHAR(50),
  @BUXHETI_KOD VARCHAR(25),
  @KODET_IN VARCHAR(4000)   AS
DECLARE  
  @sAND_BUXHET VARCHAR(50),
  @sWHERE VARCHAR(500),  
  @sWHEREDATA VARCHAR(1000),  
  @KOLONADATA VARCHAR(50) ,  
  @sHAVING VARCHAR(1000),     
  @QUERY NVARCHAR(4000),
  @KODET_IN_WHERE VARCHAR(4000);
SET @sAND_BUXHET=''
SET @sWHERE = '';
SET @sHAVING='';
SET @sWHEREDATA='';
SET @KODET_IN_WHERE='';

IF (@KODET_IN<>'' ) AND (@KOLONA_TABELA <> 'BUXHET_EMRA')
   SET @KODET_IN_WHERE=' AND T2.KOD IN ('+@KODET_IN+') ';
DECLARE   
  @sMIN_DATE VARCHAR(10),
  @sMAX_DATE  VARCHAR(10),
  @MIN_DATE DATETIME,
  @MAX_DATE DATETIME, 
  @sVITI VARCHAR(4); 


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

--NDERTIMI I TABELES TEMPORANE ME DATA
if object_id('dbo.DATA_TMP') is not null
begin
  drop table dbo.DATA_TMP
END

SELECT *  INTO DATA_TMP  
 FROM F_TABLE_DATE ( @sMIN_DATE,@sMAX_DATE )

-------------------------------------------------------------------------------------------------------
	IF @TIPI = 1 SET @KOLONADATA = 'DATE' 
	ELSE
	IF @TIPI = 2 SET @KOLONADATA = 'WEEK_STARTING_MON_DATE' 
	ELSE
	IF @TIPI = 3 SET @KOLONADATA = 'MONTH_DATE' 
	ELSE
	IF @TIPI = 4 SET @KOLONADATA = 'QUARTER_DATE' 
	ELSE
	IF (@TIPI = 5) OR  
	   (@TIPI = 6) 
				 SET @KOLONADATA = 'YEAR_DATE' ;
-------------------------------------------------------------------------------------------------------
	IF @TIPI <> 1 
	 BEGIN
	  SET @sWHEREDATA = ' AND T3.DATE >= T3.START_OF_'+@KOLONADATA+' AND T3.DATE<=T3.END_OF_'+@KOLONADATA;  
	  SET @KOLONADATA = 'START_OF_'+@KOLONADATA; 
	 END 

	IF @TIPI= 6 
	   SET @sHAVING = ' HAVING SUM(B.VLERA)>0 ' ;
	   
-------------------------------------------------------------------------------------------------------
   

   
IF @KOLONA_TABELA = 'BUXHET_EMRA'
   SET @sAND_BUXHET=' AND T2.KOD='''+@BUXHETI_KOD +''' '

IF RTRIM(LTRIM(@RRESHTA_TABELA))='LLOGARI'
    SET @sWHERE=' AND T1.POZIC>0 '
ELSE    
IF RTRIM(LTRIM(@KOLONA_TABELA))='LLOGARI'
    SET @sWHERE=' AND T2.POZIC>0 '
   
   
SET @QUERY=
'  SELECT 
   RRESHTI   = T1.KOD,
   PERSHKRIM = MAX(T1.PERSHKRIM), 
   KOLONA    = T2.KOD,
   VLERA     = SUM(B.VLERA),
   DATA = '+ @KOLONADATA +
' FROM '+@RRESHTA_TABELA+' T1 
INNER JOIN '+@KOLONA_TABELA+' T2 ON 1=1 '+@sAND_BUXHET+
' 	 INNER JOIN DATA_TMP  T3 ON 1=1   '+
' LEFT JOIN BUXHET B ON B.'+@RRESHTA+'=T1.KOD ' +
' AND B.'+@KOLONA+'=T2.KOD '+
' AND B.BUXHET_KOD='''+@BUXHETI_KOD +''' AND B.DATA= T3.DATE '+ 
' WHERE 1=1 '+
@sWHERE+
@sWHEREDATA +
@KODET_IN_WHERE+
' GROUP BY t1.kod,t2.kod,'+@KOLONADATA  


EXECUTE sp_executesql @QUERY

GO
