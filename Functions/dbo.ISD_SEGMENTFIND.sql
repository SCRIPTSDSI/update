SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   FUNCTION [dbo].[ISD_SEGMENTFIND]  -- Prove
(@PKod   Varchar(100),
 @PQuote Int,
 @PiOrd  Int)
Returns Varchar(100)

AS
Begin
  Declare @Result   Varchar(100),
          @Kod      Varchar(100),
          @i        Int,
          @iOrd     Int,
          @Order    Int,
          @Quote    Int;

      Set @Result = ''
      Set @Kod    = LTrim(RTrim(IsNull(@PKod,'')));
      Set @Order  = @PiOrd
      Set @Quote  = @PQuote
      Set @iOrd   = 0
      Set @i      = 0;

  if @Order>=1 And @Order<=5
     begin

       While (@i <= 5 ) and (@i<=@Order)

         begin
           Set @iOrd = @iOrd + 1
           if  CharIndex('.',@Kod)>0
               begin
                 if @iOrd=@Order
                    Set @Result = Substring(@Kod,1,CharIndex('.',@Kod)-1)

                 Set @Kod  = Stuff(@Kod,1,CharIndex('.',@Kod),'')
               --Print @Result
               end

           else

              begin
                if @iOrd=@Order
                   Set @Result = @Kod
                Break;
              --Set @Kod  = ''
              end

           --Print @i
           Set @i = @i + 1

        end

     end;

  Set @Result = LTrim(RTrim(Isnull(@Result,'')));

  if  @Quote=1
      Set @result = QuoteName(@Result,'''');

  Return @Result;

End

GO
