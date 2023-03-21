SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 CREATE FUNCTION [dbo].[GETSASISHITUR](@KODART AS VARCHAR(100),@KMAG AS VARCHAR(20), 
                                                @KKLI AS VARCHAR(30),@DATEDOKNGA AS DATETIME,
                                                @OKMAG AS VARCHAR(MAX))
                                                RETURNS FLOAT 
                                           AS
                                           BEGIN
                                           DECLARE @SASISHITUR AS FLOAT
                                           declare @pkodart as varchar(50)
                                           declare @pkmag as varchar(59)
                                           declare @pkkli as varchar(50)
                                           declare @pdatedoknga as datetime
                                           declare @pokmag as varchar(max)
                       set @pkodart = @kodart
                       set @pkmag=@kmag
                       set @pkkli = @pkkli
                       set @pdatedoknga = @datedoknga
                       set @pokmag = @okmag

                                    SET @SASISHITUR = ISNULL((SELECT SUM(SC.SASI) FROM SMSCR SC
                                    INNER JOIN SM S ON S.NRRENDOR = SC.NRD 
                                    WHERE SC.KARTLLG = @PKODART
                                    AND (@PKMAG IN (SELECT SPLITET FROM DBO.SPLIT(@POKMAG,',')) OR @POKMAG='*')
                                    AND S.DATEDOK>=@PDATEDOKNGA),0)
                                    SET @SASISHITUR = @SASISHITUR + 
                              ISNULL((SELECT SUM(SC.SASI) FROM SMBAKSCR SC
                                    INNER JOIN SMBAK S ON S.NRRENDOR = SC.NRD 
                                    WHERE SC.KARTLLG = @PKODART
                                    AND (@PKMAG IN (SELECT SPLITET FROM DBO.SPLIT(@POKMAG,',')) OR @POKMAG='*')
                                    AND S.DATEDOK>=@PDATEDOKNGA),0)
                                    RETURN @SASISHITUR;
                                     END 
GO
