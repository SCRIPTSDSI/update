SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE Proc [dbo].[GeneralViewKase]
(
  @NrRendor      Int,
  @Fature        nVarchar(10),
  @Banke         nVarchar(10),
  @NumerFat      nVarchar(50),
  @Tip           nVarchar(10) -- @Tip per rastet Sm ose Fature
)

As

-- KASA KOSOVARE

--    Select Res = '1;'
--               + Convert(varchar(40),A.nrrendor)
--               + ';;'
--               + Left(A.pershkrim,40)
--               + ';;'
--               + Convert(Varchar(30),SC.sasi) +';'
--               + Case When Kt.Perqtvsh>0 Then 'B' Else 'A' End + ';'
--               + Convert(Varchar(30),Sc.cmimM) + ';'
--               + '0;0'
--      From Sm S
--           Inner Join  SmScr     Sc on Sc.nrd = S.nrrendor
--           Inner Join  ARTIKUJ   A  on A.Kod = SC.KartLlg
--           Inner Join  KlasaTvsh Kt on Kt.kod = a.kodtvsh
--     Where S.NrRendor = @NrRendor

-- Union All

--    Select Res = Convert(Varchar(30),Sum(VlerTot))+';;;'
--      From Sm Where NrRendor=@NrRendor

--IVA

Begin

         Set Nocount On;

     Declare @Hapje          nVarchar(100),
             @FatNr          nVarchar(100),
             @Subtotal       nVarchar(100),
             @Total          nVarchar(100),
             @Tastiera       nVarchar(100),
             @Pagesa         nVarchar(100),
             @Vlera          Float,
             @KodKli         nVarchar(50),
             @DtFat          Datetime;
            
         Set @Vlera        = (Select IsNull(Vlertot, 0) From Sm Where NrRendor = @NrRendor);
         Set @KodKli       = (Select IsNull(Kodfkl, '') From Sm Where NrRendor = @NrRendor);
         Set @DtFat        = Convert(Datetime, Floor(Convert(Float, Getdate())));
         Set @Hapje        = 'H,1,______,_,__;';
         Set @FatNr        = 'M,1,______,_,__;'+@NumerFat;
         Set @Subtotal     = 'T,1,______,_,__;4;;;;;';
         Set @Total        = 'T,1,______,_,__;';
         Set @Tastiera     = 'F,1,______,_,__;';
         Set @Pagesa       = 'T,1,______,_,__;2;' + Convert(nVarchar(10), @Vlera)+';;;;;';
          If Object_Id('tempdb..#fatura') Is Not Null
             Drop Table #fatura;
    
    
      Create Table #fatura
     (
      Id     Int Identity (1,1),
      Rresht nVarchar(Max)
     )
      Insert Into #Fatura(Rresht)
      Select @Hapje;

         if (@Fature ='1')
            Begin
              Insert Into #Fatura(Rresht)
              Select @FatNr
            End;
            
      Insert into #fatura(Rresht)
      Select 'S,1,______,_,__;' + Left(dbo.RemoveSpecialChars(artikuj.pershkrim), 18) + ';'
                                + Case When Sasi>=0 then Convert(nVarchar(10), ROUND((CmimBs)*1,0)) else Convert(nVarchar(10),-1* Round((CmimBs)*1,0)) end + ';'
                                + Convert(nVarchar(10), Round(Sasi,5)) + ';'
                                + Convert(nVarchar(10), Case When Tatim = 0 Then 2 Else 2 End) + ';1;1;'
                                + Convert(Varchar(50),CmimBs-CmshZb0) -- zbritje rresht
                                + ';0;'
                               
        From SmScr  Inner Join Artikuj On SmScr.Kartllg = Artikuj.Kod
       Where Nrd = @NrRendor
    Order By Sasi Desc;
    

     Declare @VlerZbr Float;
         Set @VlerZbr = IsNull((Select Top 1 VlerZbr From Sm Where NrRendor=@NrRendor),0);



    --      Zbritja
    
          If @Vlerzbr>0
             begin
               Insert Into #Fatura(Rresht)
	           Select @Subtotal
	  
	           Insert Into #Fatura(Rresht)
	           Select 'N,1,______,_,__;'+'1;1;1;'+Convert(Varchar(25),(Select Sum(Vlerzbr) From Sm Where NrRendor=@NrRendor)*-1)
             end;
    


      Insert Into #Fatura(Fresht)
      
 (    Select @Pagesa Where @Banke = '1'
   Union All
      Select @Total  )
   Union All
      Select @Tastiera;
      
      
         
         Set Nocount off;
    
          If Not (@Fature = '1' and @Banke = '1')
             Select Rresht From #Fatura Order By Id;
        
--       Set Nocount On;
--       if (@Fature = '1')
--          Exec FjFromSm @NrRendor, @KodKli, @DtFat, @DtFat, @NumerFat;
--       Set Nocount off;
  
End


--SEKTORI BNT
--Begin

--         Set Nocount On;
         
--     Declare @Hapje          nVarchar(100),
--             @FatNr          nVarchar(100),
--             @Subtotal       nVarchar(100),
--             @Total          nVarchar(100),
--             @Tastiera       nVarchar(100),
--             @Pagesa         nVarchar(100),
--             @Vlera          Float,
--             @KodKli         nVarchar(50),
--             @DtFat          Datetime;


--         Set @vlera        = (Select IsNull(Vlertot, 0) From Sm Where NrRendor = @NrRendor);
--         Set @KodKli       = (Select IsNull(Kodfkl, '') From Sm Where NrRendor = @NrRendor);
--         Set @DtFat        = Convert(Datetime, Floor(Convert(Float, Getdate())));

--         Set @Hapje        = 'H,1,______,_,__;'
--         Set @FatNr        = 'Q,0,______,_,__;'+@NumerFat
--         Set @Subtotal     = 'T,1,______,_,__;4;;;;;'
--         Set @Total        = 'T,1,______,_,__;'
--         Set @Tastiera     = 'F,1,______,_,__;'
--         Set @Pagesa       = 'T,1,______,_,__;2;' + Convert(nVarchar(10), @vlera)+';;;;;'

--          If OBJECT_ID('tempdb..#fatura') Is Not Null
--             Drop Table #fatura;

--      Create Table #fatura
--      (
--            id int identity (1,1),
--        rresht nVarchar(max)
--       )

--   -- insert into #fatura(rresht)
--   -- Select @hapje

--         if (@Fature ='1')
--             begin
--               Insert Into #Fatura(Rresht)
--               Select @FatNr
--             end;

--      Insert Into #Fatura(Rresht)
--      Select 'S,1,______,_,__;'
--           + Left(dbo.RemoveSpecialChars(artikuj.pershkrim), 18) + ';'
--           + Case When Sasi>=0 Then Convert(nVarchar(10), Round((Cmimbs),0)) Else Convert(nVarchar(10),-1* Round((Cmimbs),0)) End + ';'
--           + Convert(nVarchar(10), Round(Sasi,5)) + ';'
--           + Convert(nVarchar(10), KT.KODKASE)+ '1;1;'
--           + ';0;0;'
--        From SmScr  Inner Join Artikuj On SmScr.Kartllg = Artikuj.kod
--                    Inner Join KLASATVSH Kt On Kt.Kod = Artikuj.KodTvsh
--       Where Nrd = @NrRendor
--    Order By Sasi Desc;

--      Insert Into #Fatura(Rresht)
-- --   Select @Subtotal
-- -- Union All
--      (
--         -- Select @Pagesa Where @Banke = '1'
--         -- Union All
--            Select @total
--      )
--      --union all
--      --Select @Tastiera

--      Set Nocount Off

--      If Not (@Fature = '1' And @Banke = '1')
--         Select Rresht From #fatura Order By Id;
         
--End

--Select * From SmScr
--Exec GeneralViewKase 1960298, 1, 1, '111111111'

--GO
GO
