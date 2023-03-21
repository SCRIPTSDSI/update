SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[Isd_FisNrFiskalizim] 
(
 @pTableName    As Varchar(40),
 @pNrRendor     As Int,
 @pNrFiskalizim As Bigint Output 
)

AS

-- DECLARE @NrFiskalizim   Int;	EXEC dbo.Isd_FisNrFiskalizim 'FJ',0,@NrFiskalizim Output;

     DECLARE @Businunit    As VarchaR(50),
			 @TcrCode	   As VarchaR(50),
             @Datedok      As Datetime,
             @Nr           As Bigint,
		     @Nrd          As Varchar(30),
			 @sTableName   As Varchar(40),
		     @NrRendor     As Int;
 
		 SET @Nr            = 0;
         SET @sTableName    = @pTableName;
         SET @NrRendor      = @pNrRendor;

	      IF @sTableName IN ('FJ','FF')
	         BEGIN

                IF @sTableName='FJ'
		           BEGIN
                     SELECT @Datedok = Datedok, @Businunit = FisBusinessunit , @Nrd=NrFiskalizim ,
	                        @TcrCode=(SELECT TOP 1 KODTCR FROM FisTCR A WHERE KOD=FJ.FISTCR)
	                   FROM FJ 
	                  WHERE NrRendor = @NrRendor;
	               END;
  
                IF @sTableName='FF'
		           BEGIN
                     SELECT @Datedok = Datedok, @Businunit = FisBusinessunit , @Nrd=NrFiskalizim ,
	                        @TcrCode=(SELECT TOP 1 KODTCR FROM FisTCR A WHERE KOD=FF.FISTCR)
	                   FROM FF 
	                  WHERE NrRendor = @NrRendor;
	               END;


               SET @Nr = ( 
		                   SELECT  ISNULL(MAX(CONVERT(BIGINT,NrFiskalizim)),0)+1  
		                     FROM 
							      (    SELECT NRFISKALIZIM FROM FJ f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                                    WHERE ISNULL(f.isDocFiscal,0)=1 
							                  AND f.FisBusinessunit = @BusinUnit 
			                                  AND T.KODTCR=@TcrCode 
							                  AND YEAR(Datedok)=YEAR(@Datedok) 
							                  AND ISNUMERIC(NrFiskalizim)=1 
							                  AND F.NRRENDOR<>@NrRendor

							        UNION ALL

							           SELECT NRFISKALIZIM FROM FF f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                                    WHERE ISNULL(f.isDocFiscal,0)=1 
							                  AND f.FisBusinessunit = @BusinUnit 
			                                  AND T.KODTCR=@TcrCode 
							                  AND YEAR(Datedok)=YEAR(@Datedok) 
							                  AND ISNUMERIC(NrFiskalizim)=1 
							                  AND F.NRRENDOR<>@NrRendor
							       ) AS A
					       )

		     END ;




	      IF @sTableName='FD'
	         BEGIN

               SELECT @Datedok = Datedok, @Businunit = FisBusinessunit , @Nrd=NrFiskalizim
	             FROM FD 
	            WHERE NrRendor = @NrRendor;

                  SET @Nr = ( 
		                      SELECT  ISNULL(MAX(CONVERT(BIGINT,f.NrFiskalizim)),0)+1  
		                        FROM FD f
	                           WHERE ISNULL(f.isDocFiscal,0)=1 
							         AND f.FisBusinessunit = @BusinUnit 
							         AND YEAR(Datedok)=YEAR(@Datedok) 
							         AND ISNUMERIC(f.NrFiskalizim)=1 
							         AND F.NRRENDOR<>@NrRendor
					          ) 
	         END;




	      IF @sTableName= 'SM'
	         BEGIN

               SELECT @Datedok = Datedok, @Businunit = FisBusinessunit , @Nrd=NrFiskalizim ,
	                  @TcrCode=(SELECT TOP 1 KODTCR FROM FisTCR A WHERE KOD=SM.FISTCR)
	             FROM SM 
	            WHERE NrRendor = @NrRendor;
	
                  SET @Nr = ( 
		                      SELECT  ISNULL(MAX(CONVERT(BIGINT,NrFiskalizim)),0)+1  
		                        FROM SM f LEFT JOIN FisTCR T ON F.FISTCR=T.KOD
	                           WHERE ISNULL(f.isDocFiscal,0)=1 
							         AND f.FisBusinessunit = @BusinUnit 
			                         AND T.KODTCR=@TcrCode 
							         AND YEAR(Datedok)=YEAR(@Datedok) 
							         AND ISNUMERIC(NrFiskalizim)=1 
							         AND F.NRRENDOR<>@NrRendor
					          )
	         END;




         SET @pNrFiskalizim = @Nr;

      SELECT NRFISKALIZIM   = @Nr;

GO
