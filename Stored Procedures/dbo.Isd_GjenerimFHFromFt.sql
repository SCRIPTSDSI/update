SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- Exec [Isd_GjenerimFHFromFt] 76156


CREATE         Procedure [dbo].[Isd_GjenerimFHFromFt]
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
             @IDMStatus      Varchar(5),

             @LlojDok        Varchar(10),
             @TipDokMg       Varchar(10),
             @TipDstMg       Varchar(10),
             @GrupMg         Varchar(10),
             @sKMag          Varchar(30),
             @NrMag          Int,
             @NrMag1         Int,
             @NrDMag         Int,
             @NrRendorMg     Int,
             @NrDFkMg        Int,
             @NewID          Int,
             @RowCount       Int,
             @Vlere          Float,
             @Kurs1          Float,
             @Kurs2          Float,
             @NewMg          Bit,

             @MbetjeDoc      Float,
             @ExtraVlereMg   Float,
             @ExtraModel     Int

         Set @NrRendor     = @PNrRendor;
         Set @Perdorues    = @PUser;
         Set @LgJob        = @PLgJob;


      Select @NewMg=0, @NewId=0, @NrDFkMg=0

      Select @NrRendorMg   = IsNull(NRRENDDMG,0), 
             @sKMag        = IsNull(KMAG,''),
             @NrMag        = IsNull(NRMAG,0),
             @NrDMag       = IsNull(NRDMAG,0),
             @Kurs1        = IsNull(KURS1,1),
             @Kurs2        = IsNull(KURS2,1),
             @LlojDok      = LLOJDOK
        From FF 
       Where NRRENDOR = @NrRendor --AND (NRMAG<>0) AND (NRDMAG<>0) 


-- Test i nevojshem sepse gjate importeve mbetet keq NRMAG tek FF

        Set  @NrMag1 = IsNull((Select NRRENDOR From MAGAZINA Where KOD=@sKMag),'');

         if  @NrMag<>@NrMag1
             begin

                  Set @NrMag = @NrMag1

               Update FF
                  Set NRMAG = @NrMag
                 From FF 
                Where NRRENDOR=@NrRendor

             end; 


          if @NrRendorMg>0
             begin
               Declare @ChangeDoc Bit,
                       @ChangeScr Bit;

                  Exec dbo.Isd_ChangeMgFromFt 'FF', '', @NrRendor, @ChangeDoc Out, @ChangeScr Out -- Select @ChangeDoc , @ChangeScr

                    if @ChangeDoc=0 And @ChangeScr=0
                       begin
                         Return;
                       end;

                    if @ChangeDoc=1 And @ChangeScr=0
                       begin
                         Exec dbo.Isd_UpdateFhFromFt @NrRendor,@Perdorues,@LgJob
                         Return;
                       end;
             end;

-- Vazhdon ndertimin e dokumentit magazine ...

          if @NrRendorMg>0
             begin
               Select @NewID        = NRRENDOR, 
                      @NrDFkMg      = IsNull(NRDFK,0),
                      @Vlere        = (Select Sum(VLERAM) From FHSCR Where NRD=@NrRendorMg),
                      @GrupMg       = (Select Case When CharIndex(Left(LTrim(RTrim(IsNull(GRUP,'A'))),1),'ABCDEFGHIJ')>0 
                                                   Then           Left(LTrim(RTrim(IsNull(GRUP,'A'))),1) 
                                                   Else 'A' End 
                                         From MAGAZINA B
                                        Where B.KOD=A.KMAG),

                   -- Shtese Extra ne Magazine

                      @ExtraVlereMg = IsNull(VLEXTRA,0),
                      @ExtraModel   = Case When IsNull(EXTMGFORME,0)=2 OR IsNull(EXTMGFORME,0)=3 
                                           Then EXTMGFORME 
                                           Else 1 End       --  'PCA'   Ponderim,Konstante,Artikuj
                 From FH A
                Where NRRENDOR=@NrRendorMg;

             end;

          if @NrDFkMg>0
             begin
               Exec Dbo.LM_DELFK @NrDFkMg
               Update FH
                  Set NRDFK=0
                Where NRRENDOR = @NrRendorMG;
             end;


          if @NrMag<>0 or @NrDMag<>0
             begin
               Select TOP 1 @NewMg=1  
                 From FFSCR 
                Where NRD=@NrRendor AND TIPKLL='K' AND IsNull(NOTMAG,0)=0
             end;

          if @NewMg=0
             begin

               if @NrRendorMg>0
                  begin
                      Exec dbo.Isd_AppendTransLog 'FH', @NrRendorMg, @Vlere,'D',@Perdorues,@LgJob;

                    Delete 
                      From FH 
                     Where NRRENDOR=@NrRendorMg  

                    Update FF 
                       Set NRRENDDMG=0 
                     Where NRRENDOR=@NrRendor
                  end;

               Return;

             end;


         Set @IDMStatus = 'M';

          if @NewID<=0         -- Print @NewID;
             begin            
                   Set  @NewID = 0;

                Insert  Into FH 
                       (NRRENDORFAT)
                Values (@NrRendor);

                   Set  @RowCount=@@ROWCOUNT;

                    if  @RowCount<>0
                        Select @NewID=@@IDENTITY;  

                   Set  @IDMStatus='S';
             end;
        

          if @NrRendorMg<>@NewID
             begin
               Update FF 
                  Set NRRENDDMG = @NewID
                Where NRRENDOR=@NrRendor;

                  Set @NrRendorMg = @NewID;
             end;

          if @NrRendorMg<=0
             Return;


      Select @TipDokMg='H', @TipDstMg='BL'

          if @LlojDok = 'K'         -- Kthim
             Set @TipDstMg = 'KM'
          else
          if @LlojDok = 'D'         -- Kthim Demtim
             Set @TipDstMg = 'DM'
          else
          if @LlojDok = 'T'         -- Stornim
             Set @TipDstMg = 'ST'
 
--    Set @TipKost  = IsNull((Select IsNull(MODKSTDRAFT,'KM') From CONFIGMG),'KM')

       if @NrRendorMg>0
          begin
            Delete 
              From FHSCR 
             Where NRD=@NrRendorMG
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
             A.GRUP         = @GrupMg,
             A.KTH          = B.KTH,
             A.NRRENDORFAT  = B.NRRENDOR,
             A.TIPFAT       = 'F',
             A.DST          = Left(@TipDstMg,2),  
             A.KMAGRF       = '',
             A.KMAGLNK      = '',
             A.NRDOKLNK     = 0,
             A.NRFRAKSLNK   = 0,
             A.TIP          = @TipDokMg,
             A.USI          = B.USI,
             A.USM          = B.USM,
             A.POSTIM       = 0,
             A.LETER        = 0,  
             A.FIRSTDOK     = B.FIRSTDOK,
             A.NRDFK        = 0,
             A.DATEEDIT     = GETDATE()
        From FH A INNER JOIN FF B On A.NRRENDOR=B.NRRENDDMG
       Where A.NRRENDOR=@NrRendorMG AND B.NRRENDOR=@NrRendor;


      Insert Into FHSCR 
            (NRD,  KOD, KODAF, KARTLLG, PERSHKRIM, NRRENDKLLG, NJESI,
             SASI, 
             CMIMM, VLERAM, 
             CMIMOR, VLERAOR, CMIMBS, VLERABS, CMIMSH,VLERASH,VLERAFT, 
             KOEFSHB, NJESINV, TIPKLL, BC, KOMENT, KMON,SERI,
             RIMBURSIM, DTSKADENCE,KONVERTART,
             FPROFIL,FCOLOR,FLENGTH,FBARS,
             PESHANET,PESHABRT,PROMPTPROD1,
             TIPFR,SASIFR,VLERAFR)
      Select @NrRendorMG, 
             Dbo.Isd_SegmentNewInsert(A.KOD,'',5), 
             A.KODAF, A.KARTLLG, A.PERSHKRIM, A.NRRENDKLLG, A.NJESI,
             A.SASI,  
             Round((A.CMIMBS * @Kurs2)/@Kurs1,3), 
             Round((A.VLPATVSH*@Kurs2)/@Kurs1,3), 
             Round((A.CMIMBS * @Kurs2)/@Kurs1,3), 
             Round((A.VLPATVSH*@Kurs2)/@Kurs1,3),
             Round((A.CMIMBS * @Kurs2)/@Kurs1,3), 
             Round((A.VLPATVSH*@Kurs2)/@Kurs1,3),
             Case When @GrupMg='' or @GrupMg='A' Then CMSH
                  When @GrupMg='B' Then CMSH1 
                  When @GrupMg='C' Then CMSH2 
                  When @GrupMg='D' Then CMSH3 
                  When @GrupMg='E' Then CMSH4 
                  When @GrupMg='F' Then CMSH5 
                  When @GrupMg='G' Then CMSH6 
                  When @GrupMg='H' Then CMSH7 
                  When @GrupMg='I' Then CMSH8 
                  When @GrupMg='J' Then CMSH9 
                  When @GrupMg='K' Then CMSH10 
                  When @GrupMg='L' Then CMSH11 
                  When @GrupMg='M' Then CMSH12 
                  When @GrupMg='N' Then CMSH13 
                  When @GrupMg='O' Then CMSH14 
                  When @GrupMg='P' Then CMSH15 
                  When @GrupMg='Q' Then CMSH16 
                  When @GrupMg='R' Then CMSH17 
                  When @GrupMg='S' Then CMSH18 
                  When @GrupMg='T' Then CMSH19 
                  Else CMSH End,
             Round(SASI * 
                   Case When @GrupMg='' or @GrupMg='A' Then CMSH
                        When @GrupMg='B' Then CMSH1 
                        When @GrupMg='C' Then CMSH2 
                        When @GrupMg='D' Then CMSH3 
                        When @GrupMg='E' Then CMSH4 
                        When @GrupMg='F' Then CMSH5 
                        When @GrupMg='G' Then CMSH6 
                        When @GrupMg='H' Then CMSH7 
                        When @GrupMg='I' Then CMSH8 
                        When @GrupMg='J' Then CMSH9 
                        When @GrupMg='K' Then CMSH10 
                        When @GrupMg='L' Then CMSH11 
                        When @GrupMg='M' Then CMSH12 
                        When @GrupMg='N' Then CMSH13 
                        When @GrupMg='O' Then CMSH14 
                        When @GrupMg='P' Then CMSH15
                        When @GrupMg='Q' Then CMSH16 
                        When @GrupMg='R' Then CMSH17 
                        When @GrupMg='S' Then CMSH18 
                        When @GrupMg='T' Then CMSH19 
                        Else CMSH End,3),
             Round((A.VLPATVSH * @Kurs2) / @Kurs1,3), 
          -- B.KOSTMES, Round((SASI*B.KOSTMES),3), 
          -- B.KOSTMES, Round((SASI*B.KOSTMES),3),
             A.KOEFSHB, A.NJESINV, A.TIPKLL, A.BC, A.KOMENT, '',
             A.SERI,A.RIMBURSIM, A.DTSKADENCE,IsNull(B.KONV1,1)*IsNull(B.KONV2,1),
             0,'','','', 
          -- FPROFIL,FCOLOR,FLENGTH,FBARS,
             A.PESHANET,A.PESHABRT,PROMPTPROD1,
             TIPFR,SASIFR,VLERAFR
        From FFSCR A LEFT JOIN ARTIKUJ B On A.KARTLLG = B.KOD 
       Where (A.NRD=@NrRendor) AND (A.TIPKLL='K') AND (IsNull(A.NOTMAG,0)=0)
    Order By A.NRD,A.NRRENDOR;


-- Duhet bere me poshte pas rillogaritjes se VLERAM

--      Select @Vlere = Sum(IsNull(VLERAM,0))
--        From FHSCR A
--       Where NRD=@NrRendorMg;  
--
--         Exec dbo.Isd_AppendTransLog 'FH', @NrRendorMg, @Vlere, @IDMStatus, @Perdorues, @LgJob;



--         Shtese Extra ne Magazine


-- Te krijohet nje Temp ku te ruhet NRRENDOR,VLEXTRA,TOTALDOC(Sipas Rastit SASI Apo Vlere),NrRendorDg,ExtraModel Etj 
-- Te perdoret sidomos per rastin e Global dokumentave.



           if @ExtraVlereMg <> 0  

              begin

                 if (@ExtraModel=1)               -- Ponderuar

                    begin

                      Update B
                         Set B.VLERAM =           Round( B.VLERAM + Case When IsNull(A.EXTMGFIELD,0)=2 
                                                                         Then B.SASI   / A1.TOTALSS
                                                                         Else B.VLERAM / A1.TOTALVL End * IsNull(A.VLEXTRA,0), 2),
                             B.CMIMM  = Case When IsNull(B.SASI,0)<>0 
                                             Then Round((B.VLERAM + Case When IsNull(A.EXTMGFIELD,0)=2
                                                                         Then B.SASI   / A1.TOTALSS
                                                                         Else B.VLERAM / A1.TOTALVL End * IsNull(A.VLEXTRA,0)) / SASI, 3)
                                             Else B.CMIMM End
                        From FH A INNER JOIN FHSCR B On A.NRRENDOR=B.NRD
                                  INNER JOIN (
						                      Select NRD,
                                                     TOTALSS = IsNull(SUM(SASI),0),
                                                     TOTALVL = IsNull(SUM(VLERAM),0) 
						                        From FHSCR 
                                               Where NRD=@NrRendorMg
					                        Group By NRD ) A1 On B.NRD=A1.NRD


                       Where A.NRRENDOR=@NrRendorMg And IsNull(A.VLEXTRA,0)<>0
                    end;


                 if (@ExtraModel=2)               -- Konstante

                    begin

                      Update B
                         Set B.VLERAM = Round(B.VLERAM + Case When A1.NRRECORDS<>0 
                                                              Then A.VLEXTRA/A1.NRRECORDS 
                                                              Else 0 End, 2),
                             B.CMIMM  = Case When IsNull(B.SASI,0)<>0 
                                             Then Round((B.VLERAM + Case When A1.NRRECORDS<>0 
                                                                         Then A.VLEXTRA/A1.NRRECORDS 
                                                                         Else 0 End) / B.SASI, 3)
                                             Else B.CMIMM End
                        From FH A INNER JOIN FHSCR B On A.NRRENDOR=B.NRD 
                                  INNER JOIN (
						                      Select NRD,
                                                     NRRECORDS = IsNull(COUNT(*),0) 
						                        From FHSCR 
                                               Where NRD=@NrRendorMg
					                        Group By NRD ) A1 On B.NRD=A1.NRD

                       Where A.NRRENDOR=@NrRendorMg And IsNull(A.VLEXTRA,0)<>0 And A1.NRRECORDS<>0

                    end;


                 if @ExtraModel=3                 -- Artikuj nga Dogana

                    begin

--                      Set @NrRendorDg = (Select NRRENDOR From DG Where NRRENDORFAT=@NrRendor);
--                      if  IsNull(@NrRendorDg,0) > 0
--                          Update FHSCR
--                             Set VLERAM = Round(A.VLERAM + IsNull(B.VLERATAX,0),2),
--                                 CMIMM  = Case When IsNull(A.SASI,0)<>0 
--                                               Then Round((A.VLERAM + IsNull(B.VLERATAX,0)) / A.SASI, 3)
--                                               Else CMIMM End
--                            From FHSCR A INNER JOIN DGSCR B On A.KARTLLG=B.KARTLLG AND B.TIPKLL='K' --AND B.NRD=@NrRendorDG
--                           Where A.NRD = @NrRendorMg AND B.NRD=@NrRendorDg;

                          Update B1
                             Set B1.VLERAM = Round(B1.VLERAM + IsNull(B2.VLERATAX,0),2),
                                 B1.CMIMM  = Case When IsNull(B1.SASI,0)<>0 
                                                  Then Round((B1.VLERAM + IsNull(B2.VLERATAX,0)) / B1.SASI, 3)
                                                  Else B1.CMIMM End
                            From FH A INNER JOIN DG    D  On A.NRRENDORFAT=D.NRRENDORFAT AND D.TIPFT='F'
                                      INNER JOIN FHSCR B1 On A.NRRENDOR=B1.NRD
                                      INNER JOIN DGSCR B2 On D.NRRENDOR=B2.NRD And B1.KARTLLG=B2.KARTLLG AND B2.TIPKLL='K'
                           Where A.NRRENDOR=@NrRendorMg

                    end;


             -- Ne se ka diferenca

                Declare @MbetjeDIF  Float,
                        @LastID     Int

                 Select @MbetjeDIF = SUM(VLERAM-VLERAOR)-MAX(A.VLEXTRA),
                        @LastID    = IsNull(MAX(B.NRRENDOR),0)
                   From FH A INNER JOIN FHSCR B On A.NRRENDOR=B.NRD
                  Where A.NRRENDOR = @NrRendorMg;

                  if Abs(@MbetjeDIF)>=0.02 And @LastID<>0
                     begin
                       Update FHSCR
                          Set VLERAM = VLERAM - @MbetjeDIF
                        Where NRRENDOR=@LastID
                     end;
                  Print @MbetjeDIF



              end;


      Select @Vlere = Sum(IsNull(VLERAM,0))
        From FHSCR A
       Where NRD=@NrRendorMg;  

        Exec dbo.Isd_AppendTransLog 'FH', @NrRendorMg, @Vlere, @IDMStatus, @Perdorues, @LgJob;
GO
