SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   FUNCTION [dbo].[Isd_SegmentNewInsert]
(@PKod    Varchar(100),
 @PNewIns Varchar(30),
 @PiOrd   Int)
Returns Varchar(100)

AS
Begin


-- Inserton ne Segmentin e i-te vleren @PNewIns


--Declare @PKod    Varchar(100),
--        @PNewIns Varchar(30),
--        @PiOrd   Int
--Set @PKod ='123.35.26.256.EU'
--Set @PNewIns ='AAAAA'
--Set @PIOrd = 4

  Declare @VKod    Varchar(60)
  Declare @KodOrg  Varchar(100)
  Declare @i       Int
  Declare @iOrd    Int
  Declare @At1     Int
  Declare @At2     Int
  Declare @InsPike Int
  
      Set @KodOrg  = @PKod
      Set @VKod    = LTrim(RTrim(Isnull(@KodOrg,'')))
      Set @iOrd    = -1
      Set @i       = 0
      Set @At1     = 0
      Set @At2     = 0
      Set @InsPike = 0

  if Len(@KodOrg)-Len(Replace(@KodOrg,'.',''))+1>=@PiOrd -- Nr i dhene me i vogel ose baras me nr e pikave+1

     begin
 	   if Substring(@KodOrg,Len(@KodOrg),1)<>'.' 
	 	  begin
		    Set @KodOrg  = @KodOrg + '.'
		    Set @InsPike = 1
		  end

	   if CharIndex('.',@KodOrg)>0
	 	  begin
		    Set @At1  = 0
		    Set @At2  = CharIndex('.',@KodOrg)
		    Set @iOrd = 1
		  end

	   While (@i <= 5 ) and (@iOrd<@PiOrd)
			Begin
			  if CharIndex('.',@KodOrg,@At1+1)>0
				 begin
				   Set @At1 = @At2 
				   Set @At2 = CharIndex('.',@KodOrg,@At1+1) 
				   Set @iOrd = @iOrd + 1
				 end
			  else
				 Set @i = 5

			  Set @i = @i + 1
			End

	   if @iOrd = @PiOrd 
		  begin
		    if @At2<=@At1
		 	   Set @At2 = @At1+1
		    if @At1+1>Len(@KodOrg) 
			   Set @VKod = @KodOrg+@PNewIns
		    else
			   Set @VKod = Stuff(@KodOrg,@At1+1,@At2-@At1-1,@PNewIns)
		  end 

	   if @InsPike=1
		  Set @VKod = Stuff(@VKod,Len(@VKod),1,'')


     end

--Set @VKod = Cast(@At1 As Varchar(5))+','+Cast(@At2 As Varchar(5))
--Set @VKod = Cast(@At2 As Varchar(5))
--Set @VKod = Cast(@iOrd As Varchar(5))+','+Cast(@PiOrd As Varchar(5))
 
--  if @PQuote=1
--     Set @VKod = QuoteName(LTrim(RTrim(Isnull(@VKod,''))),'''')
--
  Return (LTrim(RTrim(Isnull(@VKod,''))))

End

GO
