SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE     Procedure [dbo].[Isd_ListCmimeShArt]
(
  @Kod    Varchar(100),
  @KodKF  Varchar(10),
  @Round  Int
)

AS

--  Exec dbo.Isd_ListCmimeSh 'A000', 'D001', 2
 
 Declare @FushatDis  Varchar(100), 
         @FushatArt  Varchar(Max), 
         @Grup       Varchar(10),
         @i          Int,
         @iRound     Int;

     Set @i         = 1;
     Set @iRound    = @Round;
     Set @FushatArt = '';
     Set @FushatDis = 'A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T';

      if @Round<=-1
         begin
           Select @iRound = Cmim From Decimals Where TableName='FJ';
              Set @iRound = IsNull(@iRound,@Round);
         end;



   while @i<=20
     begin
       Set @FushatArt = @FushatArt+',CmSh'+Cast(@i-1 As Varchar);
       Set @i = @i + 1;
     end;

      Set @FushatArt = Substring(@FushatArt,2,Len(@FushatArt)) ;


  Select @Grup=GRUP
    From KLIENT 
   Where KOD = @KodKF

     Set @Grup = Case When CharIndex(@Grup,@FushatDis)>0 Then @Grup Else 'A' End 

      -- Select Nr=Row_Number() Over (Partition By unpvt.Kod Order By unpvt.Kod), 
  Select Grup      = @Grup,
         CmimKlase = dbo.Isd_StringInListStr(@FushatDis,dbo.Isd_StringInListInd(@FushatArt,unpvt.Field,''),''), 
         unpvt.Kod,
         unpvt.Pershkrim,
         unpvt.Field as CMField,
         Cmim      = Round(unpvt.Cmim,@iRound),
         TRow      = Cast(0 As Bit),
         TagNr     = 0  
    From Artikuj c 

   UnPivot ( 
            Cmim for Field in (Cmsh,Cmsh1,CmSh2,CmSh3,CmSh4,CmSh5,CmSh6,CmSh7,CmSh8,CmSh9,
                               Cmsh10,Cmsh11,CmSh12,CmSh13,CmSh14,CmSh15,CmSh16,CmSh17,CmSh18,CmSh19) 
           ) unpvt 
     Where unpvt.Kod = @Kod

 Union All 

    Select Grup=@Grup,
           CmimKlase = 'Plan' ,
           C.Kod, 
           Pershkrim = C.Pershkrim,
           CMField   = 'CMPLAN', 
           Cmim      = Round(C.KostPlan,@iRound),
           TRow      = Cast(0 As Bit),
           TagNr     = 0 
      From Artikuj C 
     Where C.Kod=@Kod

 Union All 

    Select Grup=@Grup,
           CmimKlase = 'Special' ,
           A.Kod, 
           Pershkrim = C.Pershkrim,
           CMField   = 'CMPRF', 
           Cmim      = Round(A.Cmsh,@iRound),
           TRow      = Cast(0 As Bit),
           TagNr     = 0 
      From KlientCM A Left Join Klient  B On A.Nrd=B.NrRendor 
                      Left Join Artikuj C On A.Kod=C.Kod 
     Where B.Kod=@KodKF And A.Kod=@Kod
GO
