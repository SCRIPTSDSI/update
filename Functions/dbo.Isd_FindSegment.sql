SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



Create   FUNCTION [dbo].[Isd_FindSegment]
(@PKod  Varchar(100),
 @PiOrd Int)
Returns Varchar(100)

AS

Begin
  Declare @Kod  Varchar(60)
  Declare @VKod Varchar(60)
  Declare @i Int
  Declare @iOrd Int

    Set @Kod  = @PKod
    Set @VKod = ''
    Set @iOrd = 0
    Set @i    = 0

  While (@i <= 5 ) and (@i<=@PiOrd)

        Begin
          Set @iOrd = @iOrd + 1
          if CharIndex('.',@Kod)>0
             Begin
               if @iOrd=@PiOrd
                  Set @VKod = Substring(@Kod,1,CharIndex('.',@Kod)-1)

               Set @Kod  = Stuff(@Kod,1,CharIndex('.',@Kod),'')
               --Print @VKod
             End

          else
             Begin
               if @iOrd=@PiOrd
                  Set @VKod = @Kod
               Set @Kod  = ''
             End

          --Print @i
          Set @i = @i + 1
        End

  Return (LTrim(RTrim(@VKod)))

End


GO
