SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   FUNCTION [dbo].[Isd_TestLinkMgRows]
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

--   Select dbo.Isd_TestLinkMgRows(@KMag,@NrDok,@NrFraks,@Viti,
--                             @KMagLnk,@NrDokLnk,@NrFraksLnk,@VitiLnk,
--                             @TipTest,@TableName)



	Declare @Result   Varchar(Max),
            @Msg      Varchar(100)

		Set @Result = ''
        Set @Msg    = 'Mosperputhje ndermjet detaje te dokumentit '


--    Rasti FD me FH

   if @TableName = 'FD'

      begin

        if @Result='' And 

           Exists ( Select 1
			          From

				  ( Select KARTLLG, Nr1=Count(''), Sasi1=Sum(SASI) 
					  From FH A INNER JOIN FHSCR B On A.NRRENDOR=B.NRD
					 Where ((ISNULL(A.KMAG,'')       = @KMagLnk) And
							(ISNULL(A.NRDOK,0)       = @NrDokLnk) And
							(ISNULL(A.NRFRAKS,0)     = @NrFraksLnk) And
							(ISNULL(YEAR(DATEDOK),0) = @VitiLnk)) 
				  Group By KARTLLG ) A01

				                     Left Join

				  ( Select KARTLLG,Nr2=Count(''),SASI2=Sum(SASI) 
					  From FD A INNER JOIN FDSCR B On A.NRRENDOR=B.NRD 
					 Where ((ISNULL(A.KMAG,'')       = @KMag) And
							(ISNULL(A.NRDOK,0)       = @NrDok) And
							(ISNULL(A.NRFRAKS,0)     = @NrFraks) And
							(ISNULL(YEAR(DATEDOK),0) = @Viti))
				  Group By KARTLLG ) A02 

				ON A01.KARTLLG = A02.KARTLLG 
			 Where IsNull(NR1,0)<>IsNull(NR2,0) OR IsNull(SASI1,0)<>IsNull(SASI2,0) )

           Set @Result = @Msg+' /1.';


        if @Result='' And 

           Exists (	Select 1
 		              From

				  ( Select KARTLLG,Nr2=Count(''),SASI2=Sum(SASI) 
					  From FD A INNER JOIN FDSCR B On A.NRRENDOR=B.NRD 
					 Where ((ISNULL(A.KMAG,'')       = @KMag) And
							(ISNULL(A.NRDOK,0)       = @NrDok) And
							(ISNULL(A.NRFRAKS,0)     = @NrFraks) And
							(ISNULL(YEAR(DATEDOK),0) = @Viti))
				  Group By KARTLLG ) A01 

				                     Left Join

				  ( Select KARTLLG, Nr1=Count(''), Sasi1=Sum(SASI) 
					  From FH A INNER JOIN FHSCR B On A.NRRENDOR=B.NRD
					 Where ((ISNULL(A.KMAG,'')       = @KMagLnk) And
							(ISNULL(A.NRDOK,0)       = @NrDokLnk) And
							(ISNULL(A.NRFRAKS,0)     = @NrFraksLnk) And
							(ISNULL(YEAR(DATEDOK),0) = @VitiLnk)) 
				  Group By KARTLLG ) A02

				ON A01.KARTLLG = A02.KARTLLG 
			 Where IsNull(NR1,0)<>IsNull(NR2,0) OR IsNull(SASI1,0)<>IsNull(SASI2,0) )

           Set @Result = @Msg+' /2.';

      end


--    Rasti FH me FD

   if @TableName = 'FH'

      begin

        if @Result='' And 

           Exists ( Select 1
			          From
--                  @Result = Case When IsNull(NR1,0)  <>IsNull(NR2,0)   Then 'Mosperputhje Artikuj'
--							       When IsNull(SASI1,0)<>IsNull(SASI2,0) Then 'Mosperputhje Sasi' 
--							       Else 'Mosperputhje'
				  ( Select KARTLLG, Nr1=Count(''), Sasi1=Sum(SASI) 
					  From FD A INNER JOIN FDSCR B On A.NRRENDOR=B.NRD
					 Where ((ISNULL(A.KMAG,'')       = @KMagLnk) And
							(ISNULL(A.NRDOK,0)       = @NrDokLnk) And
							(ISNULL(A.NRFRAKS,0)     = @NrFraksLnk) And
							(ISNULL(YEAR(DATEDOK),0) = @VitiLnk)) 
				  Group By KARTLLG ) A01

				                     Left Join

				  ( Select KARTLLG,Nr2=Count(''),SASI2=Sum(SASI) 
					  From FH A INNER JOIN FHSCR B On A.NRRENDOR=B.NRD 
					 Where ((ISNULL(A.KMAG,'')       = @KMag) And
							(ISNULL(A.NRDOK,0)       = @NrDok) And
							(ISNULL(A.NRFRAKS,0)     = @NrFraks) And
							(ISNULL(YEAR(DATEDOK),0) = @Viti))
				  Group By KARTLLG ) A02 

				ON A01.KARTLLG = A02.KARTLLG 
			 Where IsNull(NR1,0)<>IsNull(NR2,0) OR IsNull(SASI1,0)<>IsNull(SASI2,0) )

           Set @Result = @Msg+' /3.';


        if @Result='' And 

           Exists (	Select 1
 		              From

				  ( Select KARTLLG,Nr2=Count(''),SASI2=Sum(SASI) 
					  From FH A INNER JOIN FHSCR B On A.NRRENDOR=B.NRD 
					 Where ((ISNULL(A.KMAG,'')       = @KMag) And
							(ISNULL(A.NRDOK,0)       = @NrDok) And
							(ISNULL(A.NRFRAKS,0)     = @NrFraks) And
							(ISNULL(YEAR(DATEDOK),0) = @Viti))
				  Group By KARTLLG ) A01 

				                     Left Join

				  ( Select KARTLLG, Nr1=Count(''), Sasi1=Sum(SASI) 
					  From FD A INNER JOIN FDSCR B On A.NRRENDOR=B.NRD
					 Where ((ISNULL(A.KMAG,'')       = @KMagLnk) And
							(ISNULL(A.NRDOK,0)       = @NrDokLnk) And
							(ISNULL(A.NRFRAKS,0)     = @NrFraksLnk) And
							(ISNULL(YEAR(DATEDOK),0) = @VitiLnk)) 
				  Group By KARTLLG ) A02

				ON A01.KARTLLG = A02.KARTLLG 
			 Where IsNull(NR1,0)<>IsNull(NR2,0) OR IsNull(SASI1,0)<>IsNull(SASI2,0) )

           Set @Result = @Msg+' /4.';

      end

  Return IsNull(@Result,'')

End






GO
