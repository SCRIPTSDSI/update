SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE  FUNCTION [dbo].[Isd_SegmentsWithSpaces]
(
  @PKod    Varchar(100)
)

Returns Bit

As

Begin

     Declare @sString     Varchar(5),
             @Kod         Varchar(100),
             @sKod        Varchar(100),
             @Result      Bit;

         Set @Result    = 0; 

         Set @sString   = 'a';
         Set @sKod      = @PKod;
         Set @Kod       = LTrim(RTrim(IsNull(@PKod,'')));

       While CharIndex(' .',@Kod)>0
         Set @Kod       = Replace(@Kod,' .','.');
       While CharIndex('. ',@Kod)>0
         Set @Kod       = Replace(@Kod,'. ','.');


         if (@sString+@sKod+@sString) <> (@sString+@Kod+@sString)
             Set @Result = 1;

  Return (@Result)

End


GO
