SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   FUNCTION [dbo].[Isd_TestLinkMgDok]
(
	@KMag         Varchar(10),
	@NrDok        Int,
	@NrFraks      Int,
	@Viti         Int,
	@KMagLnk      Varchar(10),
	@NrDokLnk     Int,
	@NrFraksLnk   Int,
	@VitiLnk      Int,
	@TipTest      Int,
	@TableName    Varchar(100)
)
Returns Varchar(Max)

AS

Begin

--	Declare @KMag         Varchar(10),
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
--		Set @KMag       = 'PG1'
--		Set @NrDok      = 6
--		Set @NrFraks    = 0
--		Set @Viti       = 2012
--
--		Set @KMagLnk    = 'D011'
--		Set @NrDokLnk   = 2
--		Set @NrFRaksLnk = 0
--		Set @VitiLnk    = 2012 
--
--		Set @TipTest    = 1
--		Set @TableName  = 'FD'

--   Select dbo.Isd_TestLinkMgDok(@KMag,@NrDok,@NrFraks,@Viti,
--                                @KMagLnk,@NrDokLnk,@NrFraksLnk,@VitiLnk,
--                                @TipTest,@TableName)



	Declare @Result        Varchar(Max),
            @sMsgError0    Varchar(100),
			@sMsgError1    Varchar(100),
			@sMsgError2    Varchar(100),
			@sMsgError3    Varchar(100),
			@sMsgError4    Varchar(100),
			@sTableName    Varchar(30),
            @ErrorRow	   Varchar(100)

		Set @sTableName  = Case When @TableName='FH' then 'FD' Else 'FH' End

		Set @sMsgError0  = 'Lidhje jo e rregullt ..!'
		Set @sMsgError1  = 'Dokumenti '+@TableName  +' i referohet nje dokumenti '+@sTableName+' qe nuk egziston ..!'
		Set @sMsgError2  = 'Dokumenti '+@sTableName +' i lidhur me tjeter '+@TableName+' ..!'
		Set @sMsgError3  = 'Dokumentit '+@TableName +' i referohen te tjera '+@sTableName+' ..!'
		Set @sMsgError4  = 'Dokumentit '+@sTableName+' i referohen te tjera '+@TableName+' ..!'

		Set @Result     = ''


--    Rasti FD me FH

   if @TableName = 'FD'

      begin

		if @TipTest = 0	         -- Test i thjeshte

		   begin

             if Not Exists
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
                Set @Result = @sMsgError0

		   end


		if @TipTest = 1	         -- Test i plote

           begin

			 if (Not Exists(SELECT NRRENDOR
							   FROM FH 
							  WHERE ((ISNULL(KMAG,'')            = @KMagLnk) And
									 (ISNULL(NRDOK,0)            = @NrDokLnk) And
									 (ISNULL(NRFRAKS,0)          = @NrFraksLnk) And
									 (ISNULL(YEAR(DATEDOK),0)    = @VitiLnk)) ))
				 Set @Result = @Result + ';' + @sMsgError1;


			 if  Exists(     SELECT NRRENDOR
							   FROM FH 
							  WHERE ((ISNULL(KMAG,'')            = @KMagLnk) And
									 (ISNULL(NRDOK,0)            = @NrDokLnk) And
									 (ISNULL(NRFRAKS,0)          = @NrFraksLnk) And
									 (ISNULL(YEAR(DATEDOK),0)    = @VitiLnk)) And
									(Not
									((ISNULL(KMAGLNK,'')         = @KMag) And 
									 (ISNULL(NRDOKLNK,0)         = @NrDok) And 
									 (ISNULL(NRFRAKSLNK,0)       = @NrFraks) And 
									 (ISNULL(YEAR(DATEDOKLNK),0) = @Viti)) ) )
				 Set @Result = @Result + ';' + @sMsgError2;


			 if  Exists(     SELECT NRRENDOR
							   FROM FH 
							  WHERE (Not 
									((ISNULL(KMAG,'')            = @KMagLnk) And
									 (ISNULL(NRDOK,0)            = @NrDokLnk) And
									 (ISNULL(NRFRAKS,0)          = @NrFraksLnk) And
									 (ISNULL(YEAR(DATEDOK),0)    = @VitiLnk)) ) And

									((ISNULL(KMAGLNK,'')         = @KMag) And 
									 (ISNULL(NRDOKLNK,0)         = @NrDok) And 
									 (ISNULL(NRFRAKSLNK,0)       = @NrFraks) And 
									 (ISNULL(YEAR(DATEDOKLNK),0) = @Viti)) )
				 Set @Result = @Result + ';' + @sMsgError3;


			 if  Exists(     SELECT NRRENDOR
							   FROM FD 
							  WHERE (Not 
									((ISNULL(KMAG,'')            = @KMag) And
									 (ISNULL(NRDOK,0)            = @NrDok) And
									 (ISNULL(NRFRAKS,0)          = @NrFraks) And
									 (ISNULL(YEAR(DATEDOK),0)    = @Viti)) ) And

									((ISNULL(KMAGLNK,'')         = @KMagLnk) And 
									 (ISNULL(NRDOKLNK,0)         = @NrDokLnk) And 
									 (ISNULL(NRFRAKSLNK,0)       = @NrFraksLnk) And 
									 (ISNULL(YEAR(DATEDOKLNK),0) = @VitiLnk)) )
				 Set @Result = @Result + ';' + @sMsgError4;


             if @Result = ''
                Set @Result = dbo.Isd_TestLinkMgRows(@KMag,@NrDok,@NrFraks,@Viti,
                                                     @KMagLnk,@NrDokLnk,@NrFraksLnk,@VitiLnk,
                                                     @TipTest,@TableName)

           end
      end


--    Rasti FH me FD

   if @TableName = 'FH'

      begin

		if @TipTest = 0	         -- Test i thjeshte
		   begin
             if Not Exists
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
                 Set @Result = @Result + ';' + @sMsgError0;

		   end


		if @TipTest = 1	         -- Test i plote

           begin

			 if  Not Exists(SELECT NRRENDOR
							   FROM FD 
							  WHERE ((ISNULL(KMAG,'')            = @KMagLnk) And
									 (ISNULL(NRDOK,0)            = @NrDokLnk) And
									 (ISNULL(NRFRAKS,0)          = @NrFraksLnk) And
									 (ISNULL(YEAR(DATEDOK),0)    = @VitiLnk)) )
				 Set @Result = @Result + ';' + @sMsgError1;


			 if  Exists(     SELECT NRRENDOR
							   FROM FD 
							  WHERE ((ISNULL(KMAG,'')            = @KMagLnk) And
									 (ISNULL(NRDOK,0)            = @NrDokLnk) And
									 (ISNULL(NRFRAKS,0)          = @NrFraksLnk) And
									 (ISNULL(YEAR(DATEDOK),0)    = @VitiLnk)) And
									(Not
									((ISNULL(KMAGLNK,'')         = @KMag) And 
									 (ISNULL(NRDOKLNK,0)         = @NrDok) And 
									 (ISNULL(NRFRAKSLNK,0)       = @NrFraks) And 
									 (ISNULL(YEAR(DATEDOKLNK),0) = @Viti)) ) )
				 Set @Result = @Result + ';' + @sMsgError2;


			 if  Exists(     SELECT NRRENDOR
							   FROM FD 
							  WHERE (Not 
									((ISNULL(KMAG,'')            = @KMagLnk) And
									 (ISNULL(NRDOK,0)            = @NrDokLnk) And
									 (ISNULL(NRFRAKS,0)          = @NrFraksLnk) And
									 (ISNULL(YEAR(DATEDOK),0)    = @VitiLnk)) ) And

									((ISNULL(KMAGLNK,'')         = @KMag) And 
									 (ISNULL(NRDOKLNK,0)         = @NrDok) And 
									 (ISNULL(NRFRAKSLNK,0)       = @NrFraks) And 
									 (ISNULL(YEAR(DATEDOKLNK),0) = @Viti)) )
				 Set @Result = @Result + ';' + @sMsgError3;


			 if  Exists(     SELECT NRRENDOR
							   FROM FH 
							  WHERE (Not 
									((ISNULL(KMAG,'')            = @KMag) And
									 (ISNULL(NRDOK,0)            = @NrDok) And
									 (ISNULL(NRFRAKS,0)          = @NrFraks) And
									 (ISNULL(YEAR(DATEDOK),0)    = @Viti)) ) And

									((ISNULL(KMAGLNK,'')         = @KMagLnk) And 
									 (ISNULL(NRDOKLNK,0)         = @NrDokLnk) And 
									 (ISNULL(NRFRAKSLNK,0)       = @NrFraksLnk) And 
									 (ISNULL(YEAR(DATEDOKLNK),0) = @VitiLnk)) )
				 Set @Result = @Result + ';' + @sMsgError4;

             if @Result = ''
                Set @Result = dbo.Isd_TestLinkMgRows(@KMag,@NrDok,@NrFraks,@Viti,
                                                     @KMagLnk,@NrDokLnk,@NrFraksLnk,@VitiLnk,
                                                     @TipTest,@TableName)

           end

      end


--Print @Result
  if CharIndex(';',@Result)=1
     Set @Result = Substring(@Result,2,Len(@Result))

  Return @Result

End






GO
