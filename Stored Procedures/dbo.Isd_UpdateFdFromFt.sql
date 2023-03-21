SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- Exec [Isd_UpdateFdFromFt] 76156,'',''


CREATE         Procedure [dbo].[Isd_UpdateFdFromFt]

(
  @PNrRendor      Int,
  @PUser          Varchar(20),
  @PLgJob         Varchar(30)
 )

As

         Set NoCount On

     Declare @NrRendor       Int,
             @Perdorues      Varchar(30),
             @LgJob          Varchar(30),
             @KMagNew        Varchar(30),  -- Ft
             @KMagOld        Varchar(30),  -- Dok Mg
             @GrupMgFt       Varchar(10),
             @GrupMgDc       Varchar(10),
             @Vlere          Float,
             @NrRendorMg     Int,
             @NrDFkMg        Int,
             @Kurs1          Float,        -- disponibel
             @Kurs2          Float;


         Set @NrRendor     = @PNrRendor;
         Set @Perdorues    = @PUser;
         Set @LgJob        = @PLgJob;
         Set @NrDFkMg      = 0; 

   --    Set @TableTmpLm   = @PTableTmpLm;
   -- Select @AutoPostLmFD = IsNull(AUTOPOSTLMFD,0)  
   --   From CONFIGLM;


      Select @NrRendorMg   = IsNull(NRRENDDMG,0), 
             @KMagNew      = IsNull(KMAG,''''),
             @GrupMgFt     = (Select Case When CharIndex(Left(LTrim(RTrim(IsNull(GRUP,'A'))),1),'ABCDEFGHIJ')>0 
                                          Then           Left(LTrim(RTrim(IsNull(GRUP,'A'))),1) 
                                          Else 'A' End 
                               From MAGAZINA B
                              Where B.KOD=A.KMAG)
        From FJ A
       Where NRRENDOR = @NrRendor; 


          if @NrRendorMg<=0
             Return;
-- End --



          if @KMagNew=''
             begin
             --Print 'U fshi Fd nga Update '
               Exec dbo.Isd_DocDeleteMg 'FD', @NrRendorMG, @Perdorues, @LgJob, 1;
               Return;
             end;
-- End --



     -- Exec dbo.Isd_ChangeMgFromFt 'FJ', @NrRendor, @ChangeDoc Out, @ChangeScr Out  
     -- ska nevoje sepse pyetet tek dbo.Isd_GjenerimFdFromFt
     --  if @ChangeScr=1 or @ChangeDoc=0      -- Rasti @ChangeScr=1 Trajtohet tek Isd_GjenerimFdFromFt
     --     Return;
-- End --


--             Print 'U Update Fd nga procedure Update '

      Select @KMagOld  = A.KMAG,
             @NrDFkMg  = IsNull(A.NRDFK,0),
             @Vlere    = (Select Sum(VLERAM) From FDSCR Where NRD=@NrRendorMg),
             @GrupMgDc = (Select Case When CharIndex(Left(LTrim(RTrim(IsNull(B.GRUP,'A'))),1),'ABCDEFGHIJ')>0 
                                      Then           Left(LTrim(RTrim(IsNull(B.GRUP,'A'))),1) 
                                      Else 'A' End 
                            From MAGAZINA B
                           Where B.KOD=A.KMAG)

        From FD A INNER JOIN FJ B On A.NRRENDOR=B.NRRENDDMG
       Where A.NRRENDOR = @NrRendorMG AND B.NRRENDOR=@NrRendor;


          if @NrDFkMg > 0
             begin            
               Exec   Dbo.LM_DELFK @NrDFkMg;    -- Print 'U fshi Fk';
               Update FD
                  Set NRDFK=0
                Where NRRENDOR = @NrRendorMG;
             end;


      Update A
         Set A.NRMAG        = B.NRMAG,
             A.KMAG         = B.KMAG,
             A.NRDOK        = B.NRDMAG,
             A.DATEDOK      = B.DTDMAG,
             A.NRFRAKS      = B.FRDMAG,
             A.SHENIM1      = B.SHENIM1,
             A.SHENIM2      = B.SHENIM2,
             A.SHENIM3      = B.SHENIM3,
             A.SHENIM4      = B.SHENIM4,
             A.GRUP         = @GrupMgFt,
             A.KTH          = B.KTH,
             A.DST          = Case When B.LLOJDOK = 'K'  Then 'KM'
                                   When B.LLOJDOK = 'D'  Then 'DM'
                                   When B.LLOJDOK = 'T'  Then 'ST'
                                   When B.LLOJDOK = 'FR' Then 'FR'
                                   Else                       'SH'
                              End,
             A.KODPACIENT   = B.KODPACIENT,
             A.KODDOCTEGZAM = B.KODDOCTEGZAM,
             A.KODDOCTREFER = B.KODDOCTREFER,
             A.USI          = B.USI,
             A.USM          = B.USM
        From FD A INNER JOIN FJ B On A.NRRENDOR=B.NRRENDDMG
       Where A.NRRENDOR = @NrRendorMG AND B.NRRENDOR=@NrRendor;


      UpDate A
         Set KOD     = Case When @KMagNew <> @KMagOld
                            Then Dbo.Isd_SegmentNewInsert(A.KOD,@KMagNew,1)
                            Else A.KOD End, 
             CMIMSH  = Case When @KMagNew =  @KMagOld  -- And @GrupMgFt=@GrupMgDc
                            Then A.CMIMSH
                            Else Case When @GrupMgFt=''  or 
                                           @GrupMgFt='A' Then CMSH
                                      When @GrupMgFt='B' Then CMSH1 
                                      When @GrupMgFt='C' Then CMSH2 
                                      When @GrupMgFt='D' Then CMSH3 
                                      When @GrupMgFt='E' Then CMSH4 
                                      When @GrupMgFt='F' Then CMSH5 
                                      When @GrupMgFt='G' Then CMSH6 
                                      When @GrupMgFt='H' Then CMSH7 
                                      When @GrupMgFt='I' Then CMSH8 
                                      When @GrupMgFt='J' Then CMSH9 
                                      When @GrupMgFt='K' Then CMSH10 
                                      When @GrupMgFt='L' Then CMSH11 
                                      When @GrupMgFt='M' Then CMSH12 
                                      When @GrupMgFt='N' Then CMSH13 
                                      When @GrupMgFt='O' Then CMSH14 
                                      When @GrupMgFt='P' Then CMSH15 
                                      When @GrupMgFt='Q' Then CMSH16 
                                      When @GrupMgFt='R' Then CMSH17 
                                      When @GrupMgFt='S' Then CMSH18 
                                      When @GrupMgFt='T' Then CMSH19 
                                      Else                    CMSH End
                            End,
             VLERASH = Case When @KMagNew =  @KMagOld  -- And @GrupMgFt=@GrupMgDc
                            Then A.VLERASH
                            Else Round(SASI * Case When @GrupMgFt=''  or 
                                                        @GrupMgFt='A' Then CMSH
                                                   When @GrupMgFt='B' Then CMSH1 
                                                   When @GrupMgFt='C' Then CMSH2 
                                                   When @GrupMgFt='D' Then CMSH3 
                                                   When @GrupMgFt='E' Then CMSH4 
                                                   When @GrupMgFt='F' Then CMSH5 
                                                   When @GrupMgFt='G' Then CMSH6 
                                                   When @GrupMgFt='H' Then CMSH7 
                                                   When @GrupMgFt='I' Then CMSH8 
                                                   When @GrupMgFt='J' Then CMSH9 
                                                   When @GrupMgFt='K' Then CMSH10 
                                                   When @GrupMgFt='L' Then CMSH11 
                                                   When @GrupMgFt='M' Then CMSH12 
                                                   When @GrupMgFt='N' Then CMSH13 
                                                   When @GrupMgFt='O' Then CMSH14 
                                                   When @GrupMgFt='P' Then CMSH15 
                                                   When @GrupMgFt='Q' Then CMSH16 
                                                   When @GrupMgFt='R' Then CMSH17 
                                                   When @GrupMgFt='S' Then CMSH18 
                                                   When @GrupMgFt='T' Then CMSH19 
                                                   Else                    CMSH End,3)
                            End
--           KOMENT,   FPROFIL,FCOLOR,FLENGTH,FBARS,   A.PESHANET,A.PESHABRT,  TIPFR,SASIFR,VLERAFR   -- ?? A duhet per keto ...
--           VLERAFT = Round((A.VLPATVSH * @Kurs2) / @Kurs1,3)  -- ?? 
        From FDSCR A LEFT JOIN ARTIKUJ B On A.KARTLLG = B.KOD 
       Where A.NRD = @NrRendorMg

-- Kujdes te futet....

--    Select @Vlere = Sum(IsNull(VLERAM,0))
--      From FDSCR A
--     Where NRD=@NrRendorMg;  
--      Exec dbo.Isd_AppendTransLog 'FD', @NrRendorMg, @Vlere, 'M', @Perdorues, @LgJob; 









-- AutoShkarkim                     -- if @ShkarkimLPFt=1

--   if (Select IsNull(Count(''),0)  
--         From FDSCR A INNER JOIN ARTIKUJ B On A.KARTLLG=B.KOD 
--        Where A.NRD=@NrRendorMg AND B.TIP='P' AND B.AUTOSHKLPFJ=1)>0
--      Exec Isd_ShkarkimProdukt 'D', @NrRendorMg



--    AutoShkarkim                     if @ShkarkimLPFt=1

--    Select * From FDSCR Where NRD=@NrRendorMg
--      Exec Isd_ShkarkimProdukt 'D', @NrRendorMg;






--    Postimi ne LM
      --  if @AutoPostLmFD=0 Or @TableTmpLm=''
      --     Return;
     -- Exec [Isd_KalimLM] @PTip='D', @PNrRendor=@NrID, @PSQLFilter='', @PTableNameTmp=@TableTmpLm; 
GO
