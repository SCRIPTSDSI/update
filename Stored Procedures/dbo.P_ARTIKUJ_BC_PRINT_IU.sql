SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[P_ARTIKUJ_BC_PRINT_IU] (@MULTI_BC INT,@FSHI INT) AS


--i ruaj shenimet qe mund te jene bere per artikullin  
  IF OBJECT_ID('temp_bc') IS NOT NULL  DROP TABLE temp_bc

  SELECT KOD,SHENIME into temp_bc FROM dbo.ARTIKUJ_BC_PRINT



DELETE FROM ARTIKUJ_BC_PRINT

IF @MULTI_BC=1  -- NESE ESHTE MULTI_BARKOD ----------------------------------------
 BEGIN
   PRINT '--------------------------------------------------------------------'
   PRINT 'Kopjohen rreshtat e tabeles ARTIKUJ_BC_PRINT (MULTI_BC)'
   
   	INSERT INTO ARTIKUJ_BC_PRINT
			( KOD ,
			  BC ,
			  NGJYRE,
			  MASE,
			  TAG
			  
			)
	 SELECT 
			  A.KOD ,
			  ABC.BC ,
			  abc.NGJYRE,
			  abc.MASE,
			  TAG =0
	FROM ARTIKUJ A
	INNER JOIN ARTIKUJBCSCR ABC ON ABC.NRD=A.NRRENDOR
 PRINT '--------------------------------------------------------------------'
END	
ELSE  -- NESE NUK ESHTE MULTI_BARKOD ----------------------------------------------
BEGIN
PRINT '--------------------------------------------------------------------'
   PRINT 'Kopjohen rreshtat e tabeles ARTIKUJ_BC_PRINT (JO MULTI_BC)'
	INSERT INTO dbo.ARTIKUJ_BC_PRINT
			( KOD ,
			  BC ,
			  NGJYRE,
			  MASE,			  
			  TAG
			)
	SELECT 
			  A.KOD ,
			  A.BC ,
			  NGJYRE='',
			  MASE='',			  
			  TAG =0
	FROM ARTIKUJ A
PRINT '--------------------------------------------------------------------'

UPDATE abp SET SHENIME = TBC.SHENIME FROM artikuj_bc_print abp
INNER JOIN   temp_bc tbc ON tbc.kod=abp.kod
END;
PRINT '--------------------------------------------------------------------'


GO
