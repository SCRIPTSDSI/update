SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   FUNCTION [dbo].[Isd_SegmentsToKodAF]
(               
 @PKod    Varchar(100)
 )

Returns Varchar(100)

--      Vlen per LM sepse per magazinen do kujdes segmenti i pare       --

AS

Begin

     Declare @Kod  Varchar(60),
             @Sg2  Varchar(60),
             @Sg3  Varchar(60),
             @Sg4  Varchar(60);

         Set @Sg2 = Dbo.Isd_SegmentFind(@PKod,0,2);
         Set @Sg3 = Dbo.Isd_SegmentFind(@PKod,0,3);
         Set @Sg4 = Dbo.Isd_SegmentFind(@PKod,0,4);

         Set @Kod = Dbo.Isd_SegmentFind(@PKod,0,1)+
                    Case When @Sg4<>'' Then '.'+@Sg2+'.'+@Sg3+'.'+@Sg4
                         When @Sg3<>'' Then '.'+@Sg2+'.'+@Sg3
                         When @Sg2<>'' Then '.'+@Sg2
                         Else '' 
                    End;

      Return (LTrim(RTrim(@Kod)));

End


GO
