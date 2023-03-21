SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  PROCEDURE [dbo].[FJFROMSM](@NRRENDORSM AS INT,
                        @KODKLI as varchar(10),@DATFAT as DATETIME,
                        @DATESHOQ as DATETIME,@NRSERIAL as VARCHAR(200),@SHENIM AS VARCHAR(250)='',@PARAPG AS FLOAT = 0,@nrrendornew AS INT OUTPUT)
                        AS
                        
                        BEGIN TRAN T1
                        BEGIN TRY
                        DECLARE CU CURSOR FOR 
                        SELECT 'IMPORT' AS USERN,S.DATEDOK,K.KODKL,'' AS MON,S.KMAG,1 AS KURS2,2 AS NRFAT,
                        SUM(S.VLERTOT) AS VLERTOT,S.KASE,sum(s.vlerzbr) as VLERZBR,SUM(S.VLERTOT) AS CASHFATURA,
						MIN(FIC) AS FIC,MIN(IIC) AS IIC,MIN(IICSIG) AS IICSIG,MIN(PROCES) AS PROCES,
                        MIN(FISCMENPAG) AS FISCMENPAG,MIN(FISCTIPDOK) AS FISCTIPDOK,min(shenim1) as pershkli

                        FROM SM AS S
                        INNER JOIN KASE AS K ON K.KOD = S.KASE
                        --INNER JOIN DRH..USERS AS U ON U.DRN = K.KOD
                        WHERE S.NRRENDOR = @NRRENDORSM
                        GROUP BY S.KMAG,S.DATEDOK,S.KASE,K.KODKL
                        DECLARE @PKODUSER  AS VARCHAR(10),@PDATEDOK  AS DATETIME,@PKODFKL   AS VARCHAR(10), @PKMON     AS VARCHAR(3),@PKMAG     AS VARCHAR(3),@PKURS2    AS FLOAT,@PNRRENDOR AS INT,@NRFAT AS INT,@VLERTOT AS FLOAT,@PKASE AS NVARCHAR(30),@VLERZBR as float,@CASH AS FLOAT,
						@FIC varchar(max),@iic varchar(max),@iicsig varchar(max),  @proces varchar(50),@fiscmenpag varchar(50),
                        @fisctipdok varchar(50),@KASE VARCHAR(50) ,@pershkli as varchar(200) 
						  
                        DECLARE @PTipKLL VARCHAR(1),@KODART VARCHAR(30),@CMIM FLOAT,@SASI FLOAT,@VPATVSH   FLOAT,@VTVSH     FLOAT,@VTOT      FLOAT

                        OPEN CU  
                        FETCH NEXT FROM CU INTO @PKODUSER,@PDATEDOK,@PKODFKL,@PKMON,@PKMAG,@PKURS2,@NRFAT,@VLERTOT,@PKASE,@VLERZBR,@CASH,
						@FIC ,@iic ,@iicsig ,@proces ,@fiscmenpag,
                        @fisctipdok,@pershkli


                        WHILE @@FETCH_STATUS = 0  
                        BEGIN  

                        EXEC DBO.FJ_INSERT_FJ @PKODUSER,@PDATEDOK,@KODKLI,@PKMON,@PKMAG,@PKURS2,@NRSERIAL,@SHENIM,@CASH,@FIC ,@iic ,@iicsig ,@proces ,@fiscmenpag,
                        @fisctipdok,@KASE,@pershkli,@PNRRENDOR=@PNRRENDOR OUTPUT
                                         
                        set @nrrendornew=@PNRRENDOR;
                                         
                        DECLARE CUSCR CURSOR FOR 
                        SELECT 'K',SC.KARTLLG, 
                        CMIM=ROUND(SC.CMIMm /CASE WHEN ISNULL(A.TATIM,0)=0 THEN 1 ELSE 1.2 END,2),
                        SUM(SC.SASI) AS SASI,
                        VLPATVSH = ROUND(SUM(ISNULL(SC.VLPATVSH,0))/CASE WHEN ISNULL(A.TATIM,0)=0 THEN 1 ELSE 1.2 END,2),
                        VLTVSH = SUM(ISNULL(SC.VLPATVSH,0))-ROUND(SUM(ISNULL(SC.VLPATVSH,0))/CASE WHEN ISNULL(A.TATIM,0)=0 THEN 1 ELSE 1.2 END,2) ,
                        SUM(ISNULL(SC.VLPATVSH,0)+ISNULL(SC.VLTVSH,0)) AS VLERTOT
                        FROM SM AS S
                        INNER JOIN SMSCR AS SC ON SC.NRD = S.NRRENDOR
                        INNER JOIN KASE AS K ON K.KOD = S.KASE
                        INNER JOIN ARTIKUJ A ON A.KOD = SC.KARTLLG
                        --INNER JOIN DRH..USERS AS U ON U.DRN = K.KOD
                        WHERE s.nrrendor = @NRRENDORSM
                        GROUP BY S.KMAG,S.DATEDOK,S.KASE,K.KODKL,SC.KARTLLG,SC.CMIMm,A.TATIM
                        OPEN CUSCR  
                        FETCH NEXT FROM CUSCR INTO @PTipKLL,@KODART,@CMIM ,@SASI,@VPATVSH,@VTVSH,@VTOT

                        WHILE @@FETCH_STATUS = 0  
                        BEGIN  

                        EXEC dbo.FJ_INSERT_FJSCR @PNRRENDOR,@PTipKLL,@KODART,@CMIM ,@SASI,@VPATVSH,@VTVSH,@VTOT 

                        FETCH NEXT FROM CUSCR INTO @PTipKLL,@KODART,@CMIM ,@SASI,@VPATVSH,@VTVSH,@VTOT 
                        END  
                        CLOSE CUSCR  
                        DEALLOCATE CUSCR
                        
                        UPDATE FJ
                                         SET     VLPATVSH    = ( SELECT SUM(FJSCR.VLPATVSH) FROM FJSCR INNER JOIN FJ ON FJSCR.NRD=FJ.NRRENDOR WHERE NRD = @PNrRendor),
                                                       VLTVSH      = ( SELECT SUM(FJSCR.VLTVSH) FROM FJSCR INNER JOIN FJ ON FJSCR.NRD=FJ.NRRENDOR WHERE NRD = @PNrRendor ),
                                                       VLERTOT     = ( SELECT SUM(FJSCR.VLERABS) FROM FJSCR INNER JOIN FJ ON FJSCR.NRD=FJ.NRRENDOR WHERE NRD = @PNrRendor)
                                         WHERE   NRRENDOR = @PNrRendor ;
                        
                        EXEC dbo.Isd_DocSaveFJ @PNRRENDOR,'S',1,'#12345678','ADMIN','1234567890'  
                        
                        --EXEC dbo.UPDATE_DITARE_FJ 'S','FJ',@PNRRENDOR
						--KUJDES!!! Kur eshte F5 standart te perdoret procedura UPDATE_DITARE_FJ dhe FJ_INSERT_FD dhe te komentohet procedura Isd_DocSaveFJ

						--exec [dbo].[FJ_INSERT_FD] @PNRRENDOR 

                        FETCH NEXT FROM CU INTO @PKODUSER,@PDATEDOK,@PKODFKL,@PKMON,@PKMAG,@PKURS2,@NRFAT,@VLERTOT,@PKASE,@VLERZBR,@CASH,
						@FIC ,@iic ,@iicsig ,@proces ,@fiscmenpag,
                        @fisctipdok,@pershkli

                      --  @PKODUSER,@PDATEDOK,@PKODFKL,@PKMON,@PKMAG,@PKURS2,@NRSERIAL,@NRFAT--,@VLERTOT,@PKASE,@VLERZBR
                                                
                                                
                        END  

                        CLOSE CU      
                        DEALLOCATE CU

                        --begin try
                            exec dbo.sm_insert_smbak @nrrendorsm
                        --end try
                        --begin catch
                        --end catch
                      UPDATE SM SET EXPORT=1 WHERE NRRENDOR=@NRRENDORSM
					--  UPDATE FJ SET NRSERIAL=@FIC

					--  dELETE FROM SM WHERE NRRENDOR=@NRRENDORSM
                      COMMIT TRAN T1
                      END TRY
                      BEGIN CATCH
                      ROLLBACK TRAN T1
                      
                      END CATCH

                        --DELETE FROM SM WHERE NRRENDOR = @NRRENDORSM;
                        return

GO
