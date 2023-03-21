SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   FUNCTION [dbo].[Isd_SegmentsTrim1]
(
  @PKod    Varchar(100)
)

Returns Varchar(100)

As

Begin


     Declare @Result  Varchar(100);

         Set @Result = LTrim(RTrim(IsNull(@PKod,'')));

       While CharIndex(' .',@Result)>0
         Set @Result = Replace(@Result,' .','.');

       While CharIndex('. ',@Result)>0
         Set @Result = Replace(@Result,'. ','.');


/*

-- Procedure e sakte kur do te vleresosh kodet analitike jo me shume se 5 segments
-- perdor Isd_SegmentsToKodLM ose Isd_SegmentsToKodAF
-- ose kete me poshte 

     Declare @Result  Varchar(100),
             @Kod     Varchar(100),
             @i       Int,
             @j       Int;

         Set @Kod   = LTrim(RTrim(IsNull(@PKod,''))); --'  6051 . 6052 . 6053 . 6054 . 6055 . 6056 .';
         Set @i     = DataLength(@Kod) - DataLength(Replace(@Kod,'.','')) + 1;
         if  @i > 5
             Set @i = 5;

         Set @Result = dbo.Isd_SegmentFind(@Kod,0,1);
         Set @j = 2;

         while @j<=@i
           begin
             Set @Result = @Result + '.' + dbo.Isd_SegmentFind(@Kod,0,@j);
             Set @j = @j + 1;
           end;
*/

  Return (LTrim(RTrim(@Result)))

End


GO
