SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[getprice](@KODART AS VARCHAR(100),@KMAG AS VARCHAR(20), @KKLI AS VARCHAR(30)
                            ,@SASIPERSHITJE AS FLOAT=1
                            )
                            RETURNS FLOAT 
                            AS
                            BEGIN

                            DECLARE @GRUP AS VARCHAR(50)
                            SET @GRUP = ISNULL((SELECT TOP 1 GRUP FROM KLIENT WHERE KOD = @KKLI),'A')
                            DECLARE @CMIM AS FLOAT;
                            IF (SELECT COUNT(1) FROM ARTIKUJ WHERE KOD = @KODART)<=0
                            BEGIN
	                            SET @KODART = (SELECT TOP 1 KOD FROM ARTIKUJ 
	                            left JOIN ARTIKUJBCSCR AS AC ON AC.NRD =ARTIKUJ.NRRENDOR
	                            WHERE ARTIKUJ.BC = @KODART OR AC.BC=@KODART)
                            END	
                            SET @CMIM =(SELECT TOP 1 CMIM= CASE WHEN O.VLFIX=1 THEN OS.CMIM ELSE A.CMSH*(100-OS.CMIM)/100 END
		                            FROM OFERTESCR AS OS
		                            INNER JOIN OFERTE AS O ON O.NRRENDOR=OS.NRD
		                            INNER JOIN OFERTESCHD AS OSC ON OSC.NRD=O.NRRENDOR
		                            INNER JOIN ARTIKUJ A ON A.KOD = OS.MENUELEMENTID
		                            WHERE OS.MENUELEMENTID = @KODART
		                            AND CONVERT(DATETIME,FLOOR(CONVERT(FLOAT,GETDATE()))+OSC.ORANGA)<=GETDATE()
		                            AND CONVERT(DATETIME,FLOOR(CONVERT(FLOAT,GETDATE()))+OSC.ORADERI)>=GETDATE()	
		                            AND OSC.DITA=DATEPART(WEEKDAY,GETDATE())
		                            AND O.STARTDATE<=GETDATE()
		                            AND O.ENDDATE>=GETDATE()
		                            AND O.AKTIV=1
		                            AND O.MEORAR=1
		                            AND (@KMAG IN (SELECT SPLITET FROM DBO.SPLIT(KMAG,',')) OR O.KMAG='*')
		                            AND (@KKLI IN (SELECT SPLITET FROM DBO.SPLIT(KKLI,',')) OR O.KKLI='*')
		                            AND OS.SASI>= @SASIPERSHITJE+DBO.GETSASISHITUR(@KODART,@KMAG,@KKLI,O.STARTDATE,O.KMAG)
                            ORDER BY O.NRRENDOR DESC)

                            IF @CMIM IS NOT NULL
	                            BEGIN
		                            RETURN @CMIM
	                            END
                            ELSE
	                            BEGIN
		                            SET @CMIM =(SELECT TOP 1 CMIM= CASE WHEN O.VLFIX=1 THEN OS.CMIM ELSE A.CMSH*(100-OS.CMIM)/100 END 
			                            FROM OFERTESCR AS OS
			                            INNER JOIN OFERTE AS O ON O.NRRENDOR=OS.NRD
			                            INNER JOIN ARTIKUJ A ON A.KOD = OS.MENUELEMENTID
			                            LEFT JOIN OFERTESCHD AS OSC ON OSC.NRD=O.NRRENDOR
			                            WHERE OS.MENUELEMENTID = @KODART
			                            AND O.STARTDATE<=GETDATE()
			                            AND O.ENDDATE>=GETDATE()
			                            AND O.AKTIV=1
			                            AND O.MEORAR=0
		                            AND (@KMAG IN (SELECT SPLITET FROM DBO.SPLIT(O.KMAG,',')) OR O.KMAG='*')
		                            AND (@KKLI IN (SELECT SPLITET FROM DBO.SPLIT(O.KKLI,',')) OR O.KKLI='*')
		                            AND OS.SASI>= @SASIPERSHITJE+DBO.GETSASISHITUR(@KODART,@KMAG,@KKLI,O.STARTDATE,O.KMAG)
		                            ORDER BY O.NRRENDOR DESC)
		                            IF @CMIM IS NOT NULL
			                            BEGIN
				                            RETURN @CMIM
			                            END
		                            ELSE
			                            BEGIN
					                            IF @KKLI='KJOESHTEKARTEKLIENTI'
						                            BEGIN
							                            SET @CMIM = (SELECT TOP 1 CMSHKLI FROM ARTIKUJ WHERE KOD =@KODART AND isnull(CMSH6,0)<=1)
							                            IF ISNULL(@CMIM,0) <> 0
								                            BEGIN
									                            RETURN @CMIM;
								                            END
							                            ELSE
								                            BEGIN
									                            SET @CMIM= (SELECT TOP 1 CMSH= CASE WHEN @GRUP = 'A' THEN CMSH
																		                            WHEN @GRUP = 'B' THEN CMSH1
																		                            WHEN @GRUP = 'C' THEN CMSH2
																		                            WHEN @GRUP = 'D' THEN CMSH3
																		                            WHEN @GRUP = 'E' THEN CMSH4
																		                            WHEN @GRUP = 'F' THEN CMSH5
																		                            WHEN @GRUP = 'G' THEN CMSH6
																		                            ELSE CMSH END
									                             FROM ARTIKUJ WHERE KOD =@KODART)
									                            RETURN @CMIM
								                            END
						                            END
					                            ELSE
						                            BEGIN
							                            SET @CMIM= (SELECT TOP 1 CMSH= CASE WHEN @GRUP = 'A' THEN CMSH
																		                            WHEN @GRUP = 'B' THEN CMSH1
																		                            WHEN @GRUP = 'C' THEN CMSH2
																		                            WHEN @GRUP = 'D' THEN CMSH3
																		                            WHEN @GRUP = 'E' THEN CMSH4
																		                            WHEN @GRUP = 'F' THEN CMSH5
																		                            WHEN @GRUP = 'G' THEN CMSH6
																		                            ELSE CMSH END
									                             FROM ARTIKUJ WHERE KOD =@KODART)
							                            RETURN @CMIM
						                            END
			                            END
	                            END
                            RETURN @CMIM
                            END
                
GO
