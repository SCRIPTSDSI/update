SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   FUNCTION [dbo].[Isd_SegmentsTrim2]
(
  @PKodAF  Varchar(100),
  @PKMon   Varchar(10),
  @PKMag   Varchar(30),
  @PModul  Varchar(10),
  @PField  Varchar(30),
  @PDoc    Varchar(30)
)

Returns Varchar(100)

AS

Begin

  Declare @Result  Varchar(100),
          @KodAF   Varchar(100),
          @KMon    Varchar(10),
          @KMag    Varchar(30),
          @Modul   Varchar(10),
          @Field   Varchar(30),
          @Doc     Varchar(30),
          @sSg1    Varchar(30),
          @sSg2    Varchar(30),
          @sSg3    Varchar(30),
          @sSg4    Varchar(30);


      Set @KodAF = LTrim(RTrim(IsNull(@PKodAF,'')));
      Set @KMon  = LTrim(RTrim(IsNull(@PKMon, '')));
      Set @KMag  = LTrim(RTrim(IsNull(@PKMag, '')));
      Set @Modul = LTrim(RTrim(IsNull(@PModul,'')));
      Set @Field = LTrim(RTrim(IsNull(@PField,'')));
      Set @Doc   = LTrim(RTrim(IsNull(@PDoc,'')));


    while CharIndex(' .',@KodAF) > 0
      Set @KodAF = Replace(@KodAF,' .','.');
    while CharIndex('. ',@KOdAF) > 0
      Set @KodAF = Replace(@KodAF,'. ','.');

      Set @Result = @KodAF;


       if @PField='KODAF'
          begin
            Set @Result = Dbo.Isd_SegmentFind(@KodAF,0,1);
            Set @sSg2   = Dbo.Isd_SegmentFind(@KodAF,0,2);
            Set @sSg3   = Dbo.Isd_SegmentFind(@KodAF,0,3);
            Set @sSg4   = Dbo.Isd_SegmentFind(@KodAF,0,4);
            if  CharIndex(@Modul,'K')>0
                begin
                  if  @sSg3<>''
                      Set @Result = @Result+'.'+@sSg2+'.'+@sSg3
                  else
                  if  @sSg2<>''
                      Set @Result = @Result+'.'+@sSg2;
                end;
            if  CharIndex(@Modul,'LTX')>0
                begin
                  if  @sSg4<>''
                      Set @Result = @Result+'.'+@sSg2+'.'+@sSg3+'.'+@sSg4
                  else
                  if  @sSg3<>''
                      Set @Result = @Result+'.'+@sSg2+'.'+@sSg3
                  else
                  if  @sSg2<>''
                      Set @Result = @Result+'.'+@sSg2;
                end;
--          if  CharIndex(@Modul,'ABSFR')>0
--              begin
--                 Set @Result = Dbo.Isd_SegmentFind(@KodAF,0,1);
--              end
--          else
--              begin
--                Set @Result = Dbo.Isd_SegmentsToKodAF(@KodAF);
--              end;
          end;

       if @PField='KOD'
          begin

            if CharIndex(','+@Doc+',', ',FH,FD,')>0
               Set @KMon = '';
      
            if CharIndex(@Modul,'ABSFR')>0
               Set @Result = Dbo.Isd_SegmentFind(@KodAF,0,1)+'.'+@KMon;

            if CharIndex(','+@Doc+',', ',FJ,FF,FJT,ORK,OFK,ORF,SM,FH,FD,')=0    -- Arka,Banka,Vs,Fk,Aq
               begin
                 if CharIndex(@Modul,'LTX')>0
                    Set @Result = Dbo.Isd_SegmentFind(@KodAF,0,1)+'.'+Dbo.Isd_SegmentFind(@KodAF,0,2)+'.'+Dbo.Isd_SegmentFind(@KodAF,0,3)+'.'+Dbo.Isd_SegmentFind(@KodAF,0,4)+ '.'+@KMon;
               end

            if CharIndex(','+@Doc+',', ',FJ,FF,FJT,ORK,OFK,ORF,SM,FH,FD,')>0
               begin
                 if CharIndex(@Modul,'K')>0
                    Set @Result = @KMag+ '.'+Dbo.Isd_SegmentFind(@KodAF,0,1)+'.'+Dbo.Isd_SegmentFind(@KodAF,0,2)+'.'+Dbo.Isd_SegmentFind(@KodAF,0,3)+'.'+@KMon;
                 if CharIndex(@Modul,'LTX')>0
                    begin
                      Set @sSg4 = Dbo.Isd_SegmentFind(@KodAF,0,4);
                      if  @sSg4 = ''
                          Set @sSg4 = @KMag;
                      Set @Result = Dbo.Isd_SegmentFind(@KodAF,0,1)+'.'+Dbo.Isd_SegmentFind(@KodAF,0,2)+'.'+Dbo.Isd_SegmentFind(@KodAF,0,3)+'.'+@sSg4+'.'+@KMon
                    end;
               end;
          end;

--  Print @Result;

  Return (LTrim(RTrim(@Result)))

End


GO
