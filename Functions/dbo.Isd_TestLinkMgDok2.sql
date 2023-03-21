SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   FUNCTION [dbo].[Isd_TestLinkMgDok2]
(
	@PTableName    Varchar(100),
    @PNrRendor     Int,
    @PTipTest      Int
)
RETURNS Varchar(Max)

AS

BEGIN

--	DECLARE @KMag         Varchar(10),
--			@NrDok        Int,
--			@NrFraks      Int,
--			@Viti         Int,
--			@KMagLnk      Varchar(10),
--			@NrDokLnk     Int,
--			@NrFraksLnk   Int,
--			@VitiLnk      Int,
--			@TipTest      Int,
--			@TableName    Varchar(100)
--	        
--
--		SET @KMag       = 'PG1'
--		SET @NrDok      = 6
--		SET @NrFraks    = 0
--		SET @Viti       = 2012
--
--		SET @KMagLnk    = 'D011'
--		SET @NrDokLnk   = 2
--		SET @NrFRaksLnk = 0
--		SET @VitiLnk    = 2012 
--
--		SET @TipTest    = 1
--		SET @TableName  = 'FD'

--   Select dbo.Isd_TestLinkMgDok(@KMag,@NrDok,@NrFraks,@Viti,
--                                @KMagLnk,@NrDokLnk,@NrFraksLnk,@VitiLnk,
--                                @TipTest,@TableName)

     DECLARE @KMag          Varchar(10),
             @NrDok         Int,
             @NrFraks       Int,
             @Viti          Int,
             @KMagLnk       Varchar(10),
             @NrDokLnk      Int,
             @NrFraksLnk    Int,
             @VitiLnk       Int,
             @TipTest       Int,

             @TableName     Varchar(100),
             @NrRendor      Int;

         SET @TableName   = @PTableName;
         SET @NrRendor    = @PNrRendor;
         SET @TipTest     = @PTipTest;

	 DECLARE @Result        Varchar(Max),
             @sMsgError0    Varchar(100),
			 @sMsgError1    Varchar(100),
			 @sMsgError2    Varchar(100),
			 @sMsgError3    Varchar(100),
			 @sMsgError4    Varchar(100),
			 @sTableName    Varchar(30),
             @ErrorRow	    Varchar(100)

		 SET @sTableName  = CASE WHEN @TableName='FH' THEN 'FD' ELSE 'FH' END

		 SET @sMsgError0  = 'Lidhje jo e rregullt ..!'
		 SET @sMsgError1  = 'Dokumenti ' +@TableName  +' i referohet nje dokumenti '+@sTableName+' qe nuk egziston ..!'
		 SET @sMsgError2  = 'Dokumenti ' +@sTableName +' i lidhur me tjeter '  +@TableName+' ..!'
		 SET @sMsgError3  = 'Dokumentit '+@TableName  +' i referohen te tjera '+@sTableName+' ..!'
		 SET @sMsgError4  = 'Dokumentit '+@sTableName +' i referohen te tjera '+@TableName+' ..!'

		 SET @Result     = ''


   IF @TableName = 'FD'
      BEGIN

        SELECT @KMag        = ISNULL(KMAG,''),
			   @NrDok       = ISNULL(NRDOK,0),
			   @NrFraks     = ISNULL(NRFRAKS,0),
			   @Viti        = ISNULL(YEAR(DATEDOK),0),
			   @KMagLnk     = ISNULL(KMAGLNK,''),
			   @NrDokLnk    = ISNULL(NRDOKLNK,0),
			   @NrFraksLnk  = ISNULL(NRFRAKSLNK,0),
			   @VitiLnk     = ISNULL(YEAR(DATEDOKLNK),0)
		  FROM FD 
		 WHERE NRRENDOR=@NrRendor

      END

   ELSE     -- IF @TableName = 'FH'

      BEGIN;
        SELECT @KMag        = ISNULL(KMAG,''),
			   @NrDok       = ISNULL(NRDOK,0),
			   @NrFraks     = ISNULL(NRFRAKS,0),
			   @Viti        = ISNULL(YEAR(DATEDOK),0),
			   @KMagLnk     = ISNULL(KMAGLNK,''),
			   @NrDokLnk    = ISNULL(NRDOKLNK,0),
			   @NrFraksLnk  = ISNULL(NRFRAKSLNK,0),
			   @VitiLnk     = ISNULL(YEAR(DATEDOKLNK),0)
		  FROM FH 
		 WHERE NRRENDOR=@NrRendor;

      END;


 --    Rasti FD me FH

   IF @TableName = 'FD'

      BEGIN

		IF @TipTest = 0	         -- Test i thjeshte

		   BEGIN

             IF NOT EXISTS
			    ( SELECT NRRENDOR
			        FROM FH 
			       WHERE ((ISNULL(KMAG,'')            = @KMagLnk) And
					      (ISNULL(NRDOK,0)            = @NrDokLnk) And
					      (ISNULL(NRFRAKS,0)          = @NrFraksLnk) And
					      (ISNULL(YEAR(DATEDOK),0)    = @VitiLnk)) And 
					     ((ISNULL(KMAGLNK,'')         = @KMag) And 
					      (ISNULL(NRDOKLNK,0)         = @NrDok) And 
					      (ISNULL(NRFRAKSLNK,0)       = @NrFraks) And 
					      (ISNULL(YEAR(DATEDOKLNK),0) = @Viti)) )
                SET @Result = @sMsgError0

		   END


		IF @TipTest = 1	         -- Test i plote

           BEGIN

			 IF (NOT EXISTS( SELECT NRRENDOR
							   FROM FH 
							  WHERE ((ISNULL(KMAG,'')            = @KMagLnk) And
									 (ISNULL(NRDOK,0)            = @NrDokLnk) And
									 (ISNULL(NRFRAKS,0)          = @NrFraksLnk) And
									 (ISNULL(YEAR(DATEDOK),0)    = @VitiLnk)) ))
				 SET @Result = @Result + ';' + @sMsgError1;


			 IF  EXISTS(     SELECT NRRENDOR
							   FROM FH 
							  WHERE ((ISNULL(KMAG,'')            = @KMagLnk) And
									 (ISNULL(NRDOK,0)            = @NrDokLnk) And
									 (ISNULL(NRFRAKS,0)          = @NrFraksLnk) And
									 (ISNULL(YEAR(DATEDOK),0)    = @VitiLnk)) And
									(NOT
									((ISNULL(KMAGLNK,'')         = @KMag) And 
									 (ISNULL(NRDOKLNK,0)         = @NrDok) And 
									 (ISNULL(NRFRAKSLNK,0)       = @NrFraks) And 
									 (ISNULL(YEAR(DATEDOKLNK),0) = @Viti)) ) )
				 SET @Result = @Result + ';' + @sMsgError2;


			 IF  EXISTS(     SELECT NRRENDOR
							   FROM FH 
							  WHERE (NOT 
									((ISNULL(KMAG,'')            = @KMagLnk) And
									 (ISNULL(NRDOK,0)            = @NrDokLnk) And
									 (ISNULL(NRFRAKS,0)          = @NrFraksLnk) And
									 (ISNULL(YEAR(DATEDOK),0)    = @VitiLnk)) ) And

									((ISNULL(KMAGLNK,'')         = @KMag) And 
									 (ISNULL(NRDOKLNK,0)         = @NrDok) And 
									 (ISNULL(NRFRAKSLNK,0)       = @NrFraks) And 
									 (ISNULL(YEAR(DATEDOKLNK),0) = @Viti)) )
				 SET @Result = @Result + ';' + @sMsgError3;


			 IF  EXISTS(     SELECT NRRENDOR
							   FROM FD 
							  WHERE (NOT 
									((ISNULL(KMAG,'')            = @KMag) And
									 (ISNULL(NRDOK,0)            = @NrDok) And
									 (ISNULL(NRFRAKS,0)          = @NrFraks) And
									 (ISNULL(YEAR(DATEDOK),0)    = @Viti)) ) And

									((ISNULL(KMAGLNK,'')         = @KMagLnk) And 
									 (ISNULL(NRDOKLNK,0)         = @NrDokLnk) And 
									 (ISNULL(NRFRAKSLNK,0)       = @NrFraksLnk) And 
									 (ISNULL(YEAR(DATEDOKLNK),0) = @VitiLnk)) )
				 SET @Result = @Result + ';' + @sMsgError4;


             IF @Result = ''
                SET @Result = dbo.Isd_TestLinkMgRows(@KMag,@NrDok,@NrFraks,@Viti,
                                                     @KMagLnk,@NrDokLnk,@NrFraksLnk,@VitiLnk,
                                                     @TipTest,@TableName)

           END
      END


--    Rasti FH me FD

   IF @TableName = 'FH'

      BEGIN

		IF @TipTest = 0	         -- Test i thjeshte
		   BEGIN
             IF NOT EXISTS
			    ( SELECT NRRENDOR
			        FROM FD 
			       WHERE ((ISNULL(KMAG,'')            = @KMagLnk) And
					      (ISNULL(NRDOK,0)            = @NrDokLnk) And
					      (ISNULL(NRFRAKS,0)          = @NrFraksLnk) And
					      (ISNULL(YEAR(DATEDOK),0)    = @VitiLnk)) And 
					     ((ISNULL(KMAGLNK,'')         = @KMag) And 
					      (ISNULL(NRDOKLNK,0)         = @NrDok) And 
					      (ISNULL(NRFRAKSLNK,0)       = @NrFraks) And 
					      (ISNULL(YEAR(DATEDOKLNK),0) = @Viti)) )
                 SET @Result = @Result + ';' + @sMsgError0;

		   END


		IF @TipTest = 1	         -- Test i plote

           BEGIN

			 IF  NOT EXISTS(SELECT NRRENDOR
							   FROM FD 
							  WHERE ((ISNULL(KMAG,'')            = @KMagLnk) And
									 (ISNULL(NRDOK,0)            = @NrDokLnk) And
									 (ISNULL(NRFRAKS,0)          = @NrFraksLnk) And
									 (ISNULL(YEAR(DATEDOK),0)    = @VitiLnk)) )
				 SET @Result = @Result + ';' + @sMsgError1;


			 IF  EXISTS(     SELECT NRRENDOR
							   FROM FD 
							  WHERE ((ISNULL(KMAG,'')            = @KMagLnk) And
									 (ISNULL(NRDOK,0)            = @NrDokLnk) And
									 (ISNULL(NRFRAKS,0)          = @NrFraksLnk) And
									 (ISNULL(YEAR(DATEDOK),0)    = @VitiLnk)) And
									(NOT
									((ISNULL(KMAGLNK,'')         = @KMag) And 
									 (ISNULL(NRDOKLNK,0)         = @NrDok) And 
									 (ISNULL(NRFRAKSLNK,0)       = @NrFraks) And 
									 (ISNULL(YEAR(DATEDOKLNK),0) = @Viti)) ) )
				 SET @Result = @Result + ';' + @sMsgError2;


			 IF  EXISTS(     SELECT NRRENDOR
							   FROM FD 
							  WHERE (NOT 
									((ISNULL(KMAG,'')            = @KMagLnk) And
									 (ISNULL(NRDOK,0)            = @NrDokLnk) And
									 (ISNULL(NRFRAKS,0)          = @NrFraksLnk) And
									 (ISNULL(YEAR(DATEDOK),0)    = @VitiLnk)) ) And

									((ISNULL(KMAGLNK,'')         = @KMag) And 
									 (ISNULL(NRDOKLNK,0)         = @NrDok) And 
									 (ISNULL(NRFRAKSLNK,0)       = @NrFraks) And 
									 (ISNULL(YEAR(DATEDOKLNK),0) = @Viti)) )
				 SET @Result = @Result + ';' + @sMsgError3;


			 IF  EXISTS(     SELECT NRRENDOR
							   FROM FH 
							  WHERE (NOT 
									((ISNULL(KMAG,'')            = @KMag) And
									 (ISNULL(NRDOK,0)            = @NrDok) And
									 (ISNULL(NRFRAKS,0)          = @NrFraks) And
									 (ISNULL(YEAR(DATEDOK),0)    = @Viti)) ) And

									((ISNULL(KMAGLNK,'')         = @KMagLnk) And 
									 (ISNULL(NRDOKLNK,0)         = @NrDokLnk) And 
									 (ISNULL(NRFRAKSLNK,0)       = @NrFraksLnk) And 
									 (ISNULL(YEAR(DATEDOKLNK),0) = @VitiLnk)) )
				 SET @Result = @Result + ';' + @sMsgError4;

             IF @Result = ''
                SET @Result = dbo.Isd_TestLinkMgRows(@KMag,@NrDok,@NrFraks,@Viti,
                                                     @KMagLnk,@NrDokLnk,@NrFraksLnk,@VitiLnk,
                                                     @TipTest,@TableName)

           END

      END



  IF CHARINDEX(';',@Result)=1
     SET @Result = Substring(@Result,2,Len(@Result))

  RETURN @Result

END






GO
