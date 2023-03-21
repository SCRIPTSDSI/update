SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- Exec dbo.Isd_UpdateFhFromFt 76156,'',''


CREATE         Procedure [dbo].[Isd_UpdateFhFromFt]
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
             @KMagNew        Varchar(30),
             @KMagOld        Varchar(30),
             @GrupMgFt       Varchar(10),
             @GrupMgDc       Varchar(10),
             @Vlere          Float,
             @NrRendorMg     Int,
             @NrDFkMg        Int,
             @Kurs1          Float,
             @Kurs2          Float;

         Set @NrRendor     = @PNrRendor;
         Set @Perdorues    = @PUser;
         Set @LgJob        = @PLgJob;
         Set @NrDFkMg      = 0;

   --    Set @TableTmpLm   = @PTableTmpLm;
   -- Select @AutoPostLmFH = IsNull(AUTOPOSTLMFH,0)  
   --   From CONFIGLM;


      Select @NrRendorMg   = IsNull(NRRENDDMG,0), 
             @KMagNew      = IsNull(KMAG,''''),
             @Kurs1        = IsNull(KURS1,1),
             @Kurs2        = IsNull(KURS2,1),
             @GrupMgFt     = (Select Case When CharIndex(Left(LTrim(RTrim(IsNull(GRUP,'A'))),1),'ABCDEFGHIJ')>0 
                                          Then           Left(LTrim(RTrim(IsNull(GRUP,'A'))),1) 
                                          Else 'A' End 
                               From MAGAZINA B
                              Where B.KOD=A.KMAG)
        From FF A
       Where NRRENDOR = @NrRendor; 



          if @NrRendorMg<=0
             Return;
-- End --


          if @KMagNew=''
             begin
             --Print 'U fshi Fh nga Update '
               Exec dbo.Isd_DocDeleteMg 'FH', @NrRendorMG, @Perdorues, @LgJob, 1;
               Return;
             end;
-- End --



     -- Exec dbo.Isd_ChangeMgFromFt 'FF', @NrRendor, @ChangeDoc Out, @ChangeScr Out  
     -- ska nevoje sepse pyetet tek dbo.Isd_GjenerimFhFromFt
     --  if @ChangeScr=1 or @ChangeDoc=0      -- Rasti @ChangeScr=1 Trajtohet tek Isd_GjenerimFhFromFt
     --     Return;
-- End --


--             Print 'U Update Fh nga procedure Update '

      Select @KMagOld      = A.KMAG, 
             @NrDFkMg      = IsNull(NRDFK,0),
             @Vlere        = (Select Sum(VLERAM) From FHSCR Where NRD=@NrRendorMg),
             @GrupMgDc     = (Select Case When CharIndex(Left(LTrim(RTrim(IsNull(GRUP,'A'))),1),'ABCDEFGHIJ')>0 
                                          Then           Left(LTrim(RTrim(IsNull(GRUP,'A'))),1) 
                                          Else 'A' End 
                                From MAGAZINA B
                               Where B.KOD=A.KMAG)

          -- Shtese Extra ne Magazine
          -- @ExtraVlereMg = IsNull(VLEXTRA,0),
          -- @ExtraModel   = Case When IsNull(EXTMGFORME,0)=2 OR IsNull(EXTMGFORME,0)=3 
          --                      Then EXTMGFORME 
          --                      Else 1 End       --  'PCA'   Ponderim,Konstante,Artikuj
        From FH A
       Where NRRENDOR=@NrRendorMg;


          if @NrDFkMg>0
             begin
               Exec Dbo.LM_DELFK @NrDFkMg;
               Update FH
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
             A.DOK_JB       = 1,
             A.GRUP         = @GrupMgFt,
             A.KTH          = B.KTH,
             A.DST          = Case When B.LLOJDOK = 'K' Then 'KM'
                                   When B.LLOJDOK = 'D' Then 'DM'
                                   When B.LLOJDOK = 'T' Then 'ST'
                                   Else                      'BL'
                              End,  
             A.USI          = B.USI,
             A.USM          = B.USM,

             A.FIRSTDOK     = B.FIRSTDOK,
             A.NRRENDORFAT  = B.NRRENDOR
        From FH A INNER JOIN FF B On A.NRRENDOR=B.NRRENDDMG
       Where A.NRRENDOR=@NrRendorMG AND B.NRRENDOR=@NrRendor;


      Update A
         Set KOD     = Case When @KMagNew <> @KMagOld  -- And @GrupMgFt=@GrupMgDc
                            Then Dbo.Isd_SegmentNewInsert(A.KOD,@KMagNew,1)
                            Else A.KOD End, 
             CMIMSH  = Case When @GrupMgFt='' or 
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
                            Else                    CMSH 
                       End,
             VLERASH = Case When @KMagNew =  @KMagOld  -- And @GrupMgFt=@GrupMgDc
                            Then A.VLERASH
                            Else Round(SASI * Case When @GrupMgFt='' or 
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
        From FHSCR A LEFT JOIN ARTIKUJ B On A.KARTLLG = B.KOD 
       Where A.NRD=@NrRendorMg;

-- Kujdes te futet....

--    Select @Vlere = Sum(IsNull(VLERAM,0))
--      From FHSCR A
--     Where NRD=@NrRendorMg;  
--      Exec dbo.Isd_AppendTransLog 'FH', @NrRendorMg, @Vlere, 'M', @Perdorues, @LgJob;


GO
