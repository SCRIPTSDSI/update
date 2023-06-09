SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   FUNCTION [dbo].[Isd_GetSeriFj]
( 
  @PViti      INT,
  @PKufiP     BIGINT,
  @PKufiS     BIGINT
 )
 
RETURNS       VARCHAR(30)

AS

BEGIN


	 DECLARE @Result     VARCHAR(30),
			 @NrDigit    INT,
			 @Seri       BIGINT,
			 @sSeri      VARCHAR(50);

	  SELECT @NrDigit  = NRSERIALDIGITFJ FROM CONFIGMG; -- NRDIGITSERIAL  u ndryshua me 05.02.2019, u fut per FJ,FF,FD,FH fushe me vete

	  SELECT @Seri     =   ISNULL(MAX(CASE WHEN ISNUMERIC(NRSERIAL)=1 THEN CAST(NRSERIAL AS BIGINT) ELSE 0 END),0) 
	      -- @Seri     = 1+ISNULL(MAX(CASE WHEN ISNUMERIC(NRSERIAL)=1 THEN CAST(NRSERIAL AS BIGINT) ELSE 0 END),0) 
          -- @Seri     = 1+ISNULL(MAX(CASE WHEN ISNUMERIC(NRSERIAL)=1 THEN NRSERIAL ELSE 0 END),0) 
		FROM FJ
       WHERE YEAR(DATEDOK)=@PViti 
		     AND
			 CASE WHEN ISNUMERIC(NRSERIAL)=1 THEN CAST(NRSERIAL AS BIGINT) ELSE 0 END>=@PKufiP 
			 AND
			 CASE WHEN ISNUMERIC(NRSERIAL)=1 THEN CAST(NRSERIAL AS BIGINT) ELSE 0 END<@PKufiS;


      SELECT @Seri  = CASE WHEN @Seri=0 THEN @pKufiP ELSE @Seri+1 END;
	  SELECT @sSeri = LTRIM(RTRIM(CAST(CAST(@Seri AS BIGINT) As VARCHAR)));


          IF @NrDigit>0
	         SELECT @Result = RIGHT(REPLICATE('0',@NrDigit)+@sSeri,@NrDigit)
	      ELSE
	         SELECT @Result = @sSeri;


	  RETURN @Result;

END


GO
