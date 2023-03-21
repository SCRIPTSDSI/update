SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   FUNCTION [dbo].[Isd_SegmentsToKodTest]
(
 @PKod        Varchar(100),
 @PModul      Varchar(10),
 @PSg1Bosh    Bit,
 @PSgxBosh    Bit
 )

Returns Varchar(200)

As

Begin

  Declare @Kod         Varchar(60),
          @TableName   Varchar(50),
          @List        Varchar(200),
          @Msg         Varchar(200)


  Declare @i Int,
          @j Int


  Set @Msg = ''
  if  @PModul='L' or @PModul='T'
      Set @List = 'LLOGARI,DEPARTAMENT,LISTE,MAGAZINA,MONEDHA';
  else
  if  @PModul='A' 
      Set @List = 'ARKAT,MONEDHA'
  else
  if  @PModul='B' 
      Set @List = 'BANKAT,MONEDHA'
  else
  if  @PModul='S' 
      Set @List = 'KLIENT,MONEDHA'
  else
  if  @PModul='F' 
      Set @List = 'FURNITOR,MONEDHA'
  else
  if  @PModul='M' 
      Set @List = 'MAGAZINA,ARTIKUJ,DEPARTAMENT,LISTE,MONEDHA';
  else
      Return (LTrim(RTrim(@Msg)));


  Set @i = 0
  Set @j = Len(@List)-Len(Replace(@List,',',''))+1;

  while (@i < @j) And (@Msg='')
	begin

      Set @i = @i + 1

	  Set @TableName = LTrim(RTrim(dbo.Isd_StringInListStr(@List,@i,',')))     
      Set @Kod = Dbo.Isd_SegmentFind(@PKod,0,@i);

      if  @Kod='' And ((@i=1 And @PSg1Bosh=1) or (@i>1 And @PSgxBosh=1))
          Continue;

      if  @Msg='' 
          begin
           if  @TableName='LLOGARI'     And (not Exists(SELECT KOD FROM LLOGARI     WHERE KOD=@Kod))
               Set @Msg = 'Reference Llogari panjohur:'+@Kod;

           if  @TableName='DEPARTAMENT' And (not Exists(SELECT KOD FROM DEPARTAMENT WHERE KOD=@Kod))
               Set @Msg = 'Reference Departament panjohur:'+@Kod;

           if  @TableName='LISTE'       And (not Exists(SELECT KOD FROM LISTE       WHERE KOD=@Kod))
               Set @Msg = 'Reference List panjohur:'+@Kod

           if  @TableName='MAGAZINA'    And (not Exists(SELECT KOD FROM MAGAZINA    WHERE KOD=@Kod))
               Set @Msg = 'Reference Magazine panjohur:'+@Kod

           if  @TableName='MONEDHA'     And (not Exists(SELECT KOD FROM MONEDHA     WHERE KOD=@Kod))
               Set @Msg = 'Reference Monedhe panjohur:'+@Kod

           if  @TableName='KLIENT'      And (not Exists(SELECT KOD FROM KLIENT      WHERE KOD=@Kod))
               Set @Msg = 'Reference Klient panjohur:'+@Kod;

           if  @TableName='FURNITOR'    And (not Exists(SELECT KOD FROM FURNITOR    WHERE KOD=@Kod))
               Set @Msg = 'Reference Furnitor panjohur:'+@Kod;

           if  @TableName='ARKAT'       And (not Exists(SELECT KOD FROM ARKAT       WHERE KOD=@Kod))
               Set @Msg = 'Reference Arke panjohur:'+@Kod;

           if  @TableName='BANKAT'      And (not Exists(SELECT KOD FROM BANKAT      WHERE KOD=@Kod))
               Set @Msg = 'Reference Banke panjohur:'+@Kod;


          end;

    end;

  
  Return (LTrim(RTrim(@Msg)))

End


GO
