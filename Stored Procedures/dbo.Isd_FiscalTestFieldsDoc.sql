SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Stored Procedure



-- EXEC Isd_FiscalTestFieldsDoc 4207,'FD','ADMIN'

CREATE   procedure [dbo].[Isd_FiscalTestFieldsDoc]
(
  @pNrRendor     Int,
  @pTableName    Varchar(20),    
  @pUser         Varchar(30)
)


AS


     DECLARE @NrRendor        Int,
             @Minutes         Int,
             @FisBusUnit      Varchar(30),
             @FisProces       Varchar(30),
             @FisTipDok       Varchar(30),
             @FisMenPagese    Varchar(30),
			 @FisTcrCode	  Varchar(30),
			 @FisOperator	  Varchar(30),
             @OkUnit          Int,
             @OkProc          Int,
             @OkTip           Int,
             @OkPag           Int,
			 @OkkodTVSH		  Int,
			 @OkTcrCode		  Int,
			 @OkOperator	  Int,
             @sMsg            Varchar(500),
             @sMin            Varchar(30),
			 @sTableName      Varchar(20),
			 @kodTvsh		  Varchar(20);
             
         SET @sTableName    = ISNULL(@pTableName,'');  
         SET @NrRendor      = ISNULL(@pNrRendor,0);
		 SET @sMsg          = '';

		  IF @sTableName IN ('FJ','SM','FF')
		     BEGIN

               IF @sTableName='FJ'
			      BEGIN
			            IF @NrRendor<=0 OR (NOT EXISTS (SELECT * FROM FJ WHERE NRRENDOR=@NrRendor))
                           BEGIN
                             SELECT MsgError = 'Dokumenti fature shitje e panjohur ..!';
                             RETURN;
                           END;

                    SELECT @FisBusUnit    = ISNULL(FisBusinessUnit,''),
                           @FisProces     = ISNULL(FisProces,''),
                           @FisTipDok     = ISNULL(FisTipDok,''),
                           @FisMenPagese  = ISNULL(FisMenPagese,''),
                           @Minutes       = DATEDIFF(MINUTE,DateCreate,GetDate()),
						   @FisTcrCode	  = ISNULL(Fistcr,''),
						   @FisOperator	  = fj.FISKODOPERATOR
                      FROM FJ 
                     WHERE NRRENDOR=@pNrRendor; 
					
					SET @kodTvsh=( SELECT COUNT('') FROM FJSCR 
					WHERE NRD=@pNrRendor AND NOT EXISTS (SELECT * FROM KlasaTatim B WHERE FJSCR.KODTVSH=B.KOD))
				  END;

				    IF @sTableName='FF'
			      BEGIN
			            IF @NrRendor<=0 OR (NOT EXISTS (SELECT * FROM FF WHERE NRRENDOR=@NrRendor))
                           BEGIN
                             SELECT MsgError = 'Dokumenti fature blerje e panjohur ..!';
                             RETURN;
                           END;

                    SELECT @FisBusUnit    = ISNULL(FisBusinessUnit,''),
                           @FisProces     = ISNULL(FisProces,''),
                           @FisTipDok     = ISNULL(FisTipDok,''),
                           @FisMenPagese  = ISNULL(FisMenPagese,''),
                           @Minutes       = DATEDIFF(MINUTE,DateCreate,GetDate()),
						   @FisTcrCode	  = ISNULL(Fistcr,''),
						   @FisOperator	  = ff.FISKODOPERATOR
                      FROM FF 
                     WHERE NRRENDOR=@pNrRendor; 

					 SET @kodTvsh=( SELECT COUNT('') FROM FFSCR 
					WHERE NRD=@pNrRendor AND NOT EXISTS (SELECT * FROM KlasaTatim B WHERE FFSCR.KODTVSH=B.KOD))
				  END;
             

               IF @sTableName='SM'
			      BEGIN
			            IF @NrRendor<=0 OR (NOT EXISTS (SELECT * FROM SM WHERE NRRENDOR=@NrRendor))
                           BEGIN
                             SELECT MsgError = 'Dokumenti pike shitje i panjohur ..!';
                             RETURN;
                           END;

                    SELECT @FisBusUnit    = ISNULL(FisBusinessUnit,''),
                           @FisProces     = ISNULL(FisProces,''),
                           @FisTipDok     = ISNULL(FisTipDok,''),
                           @FisMenPagese  = ISNULL(FisMenPagese,''),
                           @Minutes       = DATEDIFF(MINUTE,DateCreate,GetDate()),
						   @FisTcrCode	  = ISNULL(Fistcr,''),
						   @FisOperator	  = SM.FISKODOPERATOR
                      FROM SM 
                     WHERE NRRENDOR=@pNrRendor; 

				  END;
           
   --                 SELECT @FisBusUnit    = ISNULL(FisBusinessUnit,''),
   --                        --@FisProces     = ISNULL(FisProces,''),
   --                        --@FisTipDok     = ISNULL(FisTipDok,''),
   --                        --@FisMenPagese  = ISNULL(FisMenPagese,''),
   --                        @Minutes       = DATEDIFF(MINUTE,DateCreate,GetDate())
   --			           --@FisTcrCode	  = ISNULL(Fistcr,'')
   --                   FROM FD 
   --                  WHERE NRRENDOR=@pNrRendor
			--END

                  SET @Minutes       = ISNULL(@Minutes,0);
                  SET @FisBusUnit    = ISNULL(@FisBusUnit,'');
                  SET @FisProces     = ISNULL(@FisProces,'');
                  SET @FisTipDok     = ISNULL(@FisTipDok,'');
                  SET @FisMenPagese  = ISNULL(@FisMenPagese,'');     
                  SET @sMsg          = '';    
                  SET @sMin          = CONVERT(Varchar(30),CAST(@Minutes AS BIGINT));
				  SET @FisTcrCode	 = ISNULL(@FISTCRCODE,'');
				  SET @FisOperator   = ISNULL(@FISOPERATOR,'');
     
	 PRINT @FisTcrCode
               SELECT @OkUnit		= CASE WHEN EXISTS (SELECT NRRENDOR FROM FISBUSUNIT    WHERE KOD=@FisBusUnit)   THEN 1 ELSE 0 END,
                      @OkProc		= CASE WHEN EXISTS (SELECT NRRENDOR FROM FISPROCES     WHERE KOD=@FisProces)    THEN 1 ELSE 0 END,
                      @OkTip		= CASE WHEN EXISTS (SELECT NRRENDOR FROM FISTIPDOKFT   WHERE KOD=@FisTipDok)    THEN 1 ELSE 0 END,
                      @OkPag		= CASE WHEN EXISTS (SELECT NRRENDOR FROM FISMENPAGESE  WHERE KOD=@FisMenPagese) THEN 1 ELSE 0 END,
					  @OkkodTVSH	= CASE WHEN isnull(@kodTvsh,0)=0 THEN 1 ELSE 0 END,
					  @OkTcrCode	= CASE WHEN EXISTS (SELECT NRRENDOR FROM FisTCR		   WHERE KOD=@FisTcrCode AND ISNULL(KODTCR,'')<>'')   THEN 1 ELSE 0 END,
					  @OkOperator	= CASE WHEN EXISTS (SELECT NRRENDOR FROM FisOperator   WHERE KOD=@FisOperator)   THEN 1 ELSE 0 END

                 --IF @Minutes>=60
                 --   SET @sMsg = @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Koha e e rregjistrimit te fatures me e madhe se 1 ore ['+@sMin+' min].'
                   IF @OkUnit = 0
                      SET @sMsg = @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Njesi biznesi panjohur ['+@FisBusUnit+'].';   
                   IF @OkProc = 0
                      SET @sMsg = @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Proces fiskalizim i pa njohur ['+@FisProces+'].';
                   IF @OkTip  = 0
                      SET @sMsg = @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Tip fiskalizim i panjohur ['+@FisTipDok+'].';     
                   IF @OkPag  = 0
                      SET @sMsg = @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Menyre pagese panjohur ['+@FisMenPagese+'].';   
				   IF @OkkodTVSH =0
					  SET @sMsg= @sMsg + CASE WHEN @kodTvsh<>'' THEN ' / ' ELSE '' END + 'Kod tvsh i panjohur .';
				   IF @OkTcrCode =0
					  SET @sMsg= @sMsg + CASE WHEN @FisTcrCode<>'' THEN ' / ' ELSE '' END + 'Kod TCR i panjohur .';
				   IF @OkOperator =0
					  SET @sMsg= @sMsg + CASE WHEN @FisOperator<>'' THEN ' / ' ELSE '' END + 'Kod Operatori i panjohur .';
            

             -- PRINT @sMsg;
               SELECT MsgError = @sMsg;      

	         END; 

          
		  IF @sTableName='FF'  
		     BEGIN

               IF @NrRendor<=0 OR (NOT EXISTS (SELECT * FROM FF WHERE NRRENDOR=@NrRendor))
                  BEGIN
                    SELECT MsgError = 'Dokumenti fature blerje e panjohur ..!';
                    RETURN;
                  END;
				     SELECT MsgError = @sMsg;

			 END;


			-- Zhvilloje ....   !!!!!!!

            IF @sTableName='FD'
		     BEGIN

               IF @NrRendor<=0 OR (NOT EXISTS (SELECT * FROM FD WHERE NRRENDOR=@NrRendor)) -- Dok_JB=0 AND DST='?????'
                  BEGIN
                    SELECT MsgError = 'Dokumenti shoqerimit i panjohur ..!';
                    RETURN;
                  END;

				  DECLARE @FisTransport AS VARCHAR(MAX);

                    SELECT @FisBusUnit    = ISNULL(FisBusinessUnit,''),
                           @FisProces     = ISNULL(FisProces,''),
                           @FisTipDok     = ISNULL(FisTipDok,''),
                           @FisTransport  = ISNULL(M.KOD,''),
                           @Minutes       = DATEDIFF(MINUTE,A.DateCreate,GetDate()),
						   @FisOperator	  = A.FISKODOPERATOR
   			           --@FisTcrCode	  = ISNULL(Fistcr,'')
                      FROM FD A LEFT JOIN MGSHOQERUES M ON A.NRRENDOR=M.NRD
                     WHERE A.NRRENDOR=@pNrRendor
			   
			      SET @Minutes       = ISNULL(@Minutes,0);
                  SET @FisBusUnit    = ISNULL(@FisBusUnit,'');
                  SET @FisProces     = ISNULL(@FisProces,'');
                  SET @FisTipDok     = ISNULL(@FisTipDok,'');
                  SET @FisTransport  = ISNULL(@FisTransport,'');     
                  SET @sMsg          = '';    
                  SET @sMin          = CONVERT(Varchar(30),CAST(@Minutes AS BIGINT));
				  SET @FisTcrCode	 = ISNULL(@FISTCRCODE,'');
				  SET @FisOperator   = ISNULL(@FISOPERATOR,'');

				  PRINT @FisBusUnit
				  PRINT @sTableName
		     SELECT @OkUnit		= CASE WHEN EXISTS (SELECT NRRENDOR FROM FISBUSUNIT    WHERE KOD=@FisBusUnit)   THEN 1 ELSE 0 END,
                      --@OkProc		= CASE WHEN EXISTS (SELECT NRRENDOR FROM FISPROCES     WHERE KOD=@FisProces)    THEN 1 ELSE 0 END,
       --               @OkTip		= CASE WHEN EXISTS (SELECT NRRENDOR FROM FISTIPDOKFT   WHERE KOD=@FisTipDok)    THEN 1 ELSE 0 END,
       --               @OkPag		= CASE WHEN EXISTS (SELECT NRRENDOR FROM FISMENPAGESE  WHERE KOD=@FisMenPagese) THEN 1 ELSE 0 END,
					  --@OkkodTVSH	= CASE WHEN isnull(@kodTvsh,0)=0 THEN 1 ELSE 0 END,
					  --@OkTcrCode	= CASE WHEN EXISTS (SELECT NRRENDOR FROM FisTCR    WHERE KOD=@FisTcrCode AND ISNULL(KODTCR,'')<>'')   THEN 1 ELSE 0 END
                   @OkOperator	= CASE WHEN EXISTS (SELECT NRRENDOR FROM FisOperator   WHERE KOD=@FisOperator)   THEN 1 ELSE 0 END
				   
                 --IF @Minutes>=60
                 --   SET @sMsg = @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Koha e e rregjistrimit te fatures me e madhe se 1 ore ['+@sMin+' min].'
                   IF @OkUnit = 0
                      SET @sMsg = @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Njesi biznesi panjohur ['+@FisBusUnit+'].';   
       --            IF @OkProc = 0
       --               SET @sMsg = @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Proces fiskalizim i pa njohur ['+@FisProces+'].';
       --            IF @OkTip  = 0
       --               SET @sMsg = @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Tip fiskalizim i panjohur ['+@FisTipDok+'].';     
       --            IF @OkPag  = 0
       --               SET @sMsg = @sMsg + CASE WHEN @sMsg<>'' THEN ' / ' ELSE '' END + 'Menyre pagese panjohur ['+@FisMenPagese+'].';   
				   --IF @OkkodTVSH =0
					  --SET @sMsg= @sMsg + CASE WHEN @kodTvsh<>'' THEN ' / ' ELSE '' END + 'Kod tvsh i panjohur .';
				   -- IF @OkTcrCode =0
					  --SET @sMsg= @sMsg + CASE WHEN @FisTcrCode<>'' THEN ' / ' ELSE '' END + 'Kod TCR i panjohur .';
             IF @OkOperator =0
					  SET @sMsg= @sMsg + CASE WHEN @FisOperator<>'' THEN ' / ' ELSE '' END + 'Kod Operatori i panjohur .';
             IF @FisTransport=''
					  SET @sMsg= @sMsg + 'Mungon transportuesi';

			
			SELECT MsgError = @sMsg;

			END;
               
			   
			   
		  
		 

			-- Zhvilloje ....   !!!!!!!

          
GO
