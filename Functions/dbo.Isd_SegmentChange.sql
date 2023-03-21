SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE   FUNCTION [dbo].[Isd_SegmentChange]
(@PKod   Varchar(100),
 @PNewSg Varchar(100),
 @PQuote Int)
Returns Varchar(100)

AS

Begin
  Declare @Result Varchar(60),
          @Kod    Varchar(60)
  

      Set @Result = ''
      Set @Kod    = Isnull(@PKod,'')

       if CharIndex('.',@Kod)>0
          Set @Kod  = Stuff(@Kod,1,CharIndex('.',@Kod)-1,'')

       else
          Set @Kod  = ''

      Set @Result = LTrim(RTrim(IsNull(@PNewSg,'''') + @Kod))

      if  @PQuote=1
          Set @Result = QuoteName(@Result,'''')

  Return @Result

End





GO
