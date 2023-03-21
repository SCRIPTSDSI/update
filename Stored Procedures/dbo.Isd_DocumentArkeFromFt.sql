SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--Exec Isd_DocumentArkeFromFt 'FJ', 0, 4489,' ADMIN',''

CREATE         Procedure [dbo].[Isd_DocumentArkeFromFt]
(
  @PTableName     Varchar(30),
  @PNrDokArk      Int,  -- Bie
  @PNrRendorFt    Int,

--@PTableTmpLm    Varchar(40),

  @PPerdorues     Varchar(30),
  @PLgJob         Varchar(30)
 )

As


         Set NoCount On
 
     Declare @NrRendorFt     Int,
             @NrDokFt        Varchar(60),
             @NrMax          Int,
             @NrRendorRF     Int,
             @DateDok        DateTime,
             @LlogariLM      VarChar(30),
             @KodFKL         VarChar(30),
             @PershkrimLM    VarChar(30),
             @Shenim1        VarChar(30),
             @Shenim2        VarChar(30),
             @KodARK         VarChar(30),
             @KMonARK        VarChar(10),
             @KMonFt         VarChar(10),
             @Kurs1          Float,
             @Kurs2          Float,
             @Vlefta         Float,
             @VleftaMV       Float,
             @Db             Float,
             @Kr             Float,
             @DbKrMv         Float,
             @TipDokFt       VarChar(30),
             @TipDokArk      VarChar(10),
             @TipKLL         VarChar(2),
             @TregDK         VarChar(2),
             @Perdorues      Varchar(30),
             @LgJob          Varchar(30),
          -- @NewIDAr        Int,
          -- @RowCount       Int,
             @NrID           Int,
             @NrRendorArk    Int,
             @NrRendorFk     Int,
             @NumDok         Int,
             @Vlere          Float,
             @ArkeDokFt      Bit,
             @CashPgFull     Bit, 
             @IDMStatus      Varchar(5),
             @CreateArk      Bit,
             @AutoPostLmAR   Bit,
             @TableTmpLm     Varchar(30);


      Select @TipDokFt     = @PTableName, 
             @NrRendorFt   = @PNrRendorFt,
          -- @TableTmpLm   = @PTableTmpLm,
             @Perdorues    = @PPerdorues,
             @LgJob        = @PLgJob;

         Set @Vlere        = 0;
         Set @NrID         = 0;

-- @CashPgFull ku ta perdor ketu

      Select @ArkeDokFt  = Case When @TipDokFt='FJ' Or @TipDokFt='FJT'
                                Then IsNull(MANDATFROMFJ,0)
                                Else IsNull(MANDATFROMFF,0) End,
             @CashPgFull = Case When @TipDokFt='FJ' Or @TipDokFt='FJT'
                                Then CASHPGFULLFJ
                                Else CASHPGFULLFF End
        From ConfigMg;

      Select @AutoPostLmAR = IsNull(AUTOPOSTLMAR,0)  
        From CONFIGLM;



          if IsNull(@ArkeDokFt,0)=1 
             begin
               Select @ArkeDokFt = ARKEDOKFT 
                 From DRHUSER 
                Where KODUS  = @Perdorues And 
                      TIPDOK = @TipDokFt And 
                      MODUL  = Case When @TipDokFt='FJ' Or @TipDokFt='FJT' 
                                    Then 'S' 
                                    Else 'F' 
                               End;
             end;

          if @TipDokFt='FJ'   

             Select @KodARK    = KODARK,  @NrDokFt = NRDSHOQ, @DateDok = DATEDOK, @KodFKL = KODFKL,
                    @Kurs1     = KURS1,   @Kurs2   = KURS2,   @KMonFt  = KMON,
                 -- @Vlefta    = VLERTOT,    
                 -- @Vlefta    = Case When @CashPgFull Then VLERTOT Else PAGESEARK End,
                    @Vlefta    = PAGESEARK,
                    @Shenim1   = KODFKL+';'       +IsNull(NRDSHOQ,'')+';'+IsNull(SHENIM1,''), 
                    @Shenim2   = 'Likujdim Ft nr '+IsNull(NRDSHOQ,'')+','+IsNull(SHENIM2,''),

                    @CreateArk = Case When @ArkeDokFt= 1 And 
                                           MODPG='CA' And 
                                           IsNull(KODARK,'')<>'' And
                                          (Exists (Select KOD 
                                                     From ARKAT
                                                    Where KOD=A.KODARK))
                                      Then 1 
                                      Else 0 End,

                    @NrRendorArk = NRRENDORAR
               From FJ A  
              Where NRRENDOR=@NrRendorFt

          else

          if @TipDokFt='FJT'   

             Select @KodARK    = KODARK,  @NrDokFt = NRDSHOQ, @DateDok = DATEDOK, @KodFKL = KODFKL,
                    @Kurs1     = KURS1,   @Kurs2   = KURS2,   @KMonFt  = KMON,
                 -- @Vlefta    = VLERTOT,    
                 -- @Vlefta    = Case When @CashPgFull Then VLERTOT Else PAGESEARK End,
                    @Vlefta    = PAGESEARK,
                    @Shenim1   = KODFKL+';'       +IsNull(NRDSHOQ,'')+';'+IsNull(SHENIM1,''), 
                    @Shenim2   = 'Likujdim Ft nr '+IsNull(NRDSHOQ,'')+','+IsNull(SHENIM2,''),

                    @CreateArk = Case When @ArkeDokFt= 1 And 
                                           MODPG='CA' And 
                                           IsNull(KODARK,'')<>'' And
                                          (Exists (Select KOD 
                                                     From ARKAT
                                                    Where KOD=A.KODARK))
                                      Then 1 
                                      Else 0 End,

                    @NrRendorArk = NRRENDORAR
               From FJT A  
              Where NRRENDOR=@NrRendorFt

          else

             Select @KodARK    = KODARK,  @NrDokFt = NRDSHOQ, @DateDok = DATEDOK, @KodFKL = KODFKL,
                    @Kurs1     = KURS1,   @Kurs2   = KURS2,   @KMonFt  = KMON,    
                 -- @Vlefta    = VLERTOT,
                 -- @Vlefta    = Case When @CashPgFull Then VLERTOT Else PAGESEARK End,
                    @Vlefta    = PAGESEARK,
                    @Shenim1   = KODFKL+';'        +IsNull(NRDSHOQ,'')+';'+IsNull(SHENIM1,''), 
                    @Shenim2   ='Likujdim Ft nr '  +IsNull(NRDSHOQ,'')+','+IsNull(SHENIM2,''),
                    @CreateArk = Case When @ArkeDokFt= 1 And 
                                           MODPG='CA' And 
                                           IsNull(KODARK,'')<>'' And
                                          (Exists (Select KOD 
                                                     From ARKAT
                                                    Where KOD=A.KODARK))
                                      Then 1 
                                      Else 0 End,
                    @NrRendorArk = NRRENDORAR
               From FF A  
              Where NRRENDOR=@NrRendorFt;
            

          if IsNull(@KodArk,'')=''

             Return;


         Set @CreateArk = IsNull(@CreateArk,0);
         Set @IDMStatus = 'S';

          if IsNull(@NrRendorArk,0)<>0
             begin 

               Select @NrID       = NRRENDOR,
                      @NrRendorFk = NRDFK,

                   -- @NumDok     = NUMDOK, 
                   -- Te korigjohet ne se ndryshon KOD ose Datedok jashte Vitit ...!
                      @NumDok     = Case When @KodARK<>KODAB Or Year(DATEDOK)<>Year(@DateDok)
                                         Then 0 
                                         Else NUMDOK End,

                      @Vlere      = VLERA
                 From ARKA 
                Where NRRENDOR=@NrRendorArk;

                  Set @NrID = IsNull(@NrID,0);

                   if @NrID>0
                      begin

                       Set @IDMStatus = 'M';

                        if IsNull(@NrRendorFk,0) > 0
                           Exec dbo.LM_DELFK @NrRendorFk;

                      Exec dbo.Isd_GjenerimDitarOne 'ARKA', -1, @NrID;

                        if @CreateArk=0
                           begin
                               Exec dbo.Isd_AppendTransLog 'ARKA', @NrID, @Vlere, 'F', @Perdorues, @LgJob;

                             Delete 
                               From ARKA 
                              Where NRRENDOR = @NrID;

                                 if @TipDokFt='FJ'   
                                    Update FJ 
                                       Set NRRENDORAR=0,KODARK='' 
                                     Where NRRENDOR = @NrRendorFt
                                 else
                                 if @TipDokFt='FJT'   
                                    Update FJT 
                                       Set NRRENDORAR=0,KODARK='' 
                                     Where NRRENDOR = @NrRendorFt
                                 else
                                    Update FF 
                                       Set NRRENDORAR=0,KODARK='' 
                                     Where NRRENDOR = @NrRendorFt;
                           end;
                      end;
             end;


          if @CreateArk=0 or @Vlefta=0
             Return;

         Set @VleftaMV  = @Vlefta

      Select @TipDokArk = 'MP', 
             @TipKLL    = 'F', 
             @TregDK    = 'K', 
             @Db        = 0,
             @Kr        =     @Vlefta,
             @DbKrMv    = 0 - @Vlefta; 
          -- @NewIDAr   = 0

         if  @TipDokFt ='FJ' Or @TipDokFt ='FJT'
             Select @TipDokArk = 'MA', 
                    @TipKLL    = 'S',     
                    @TregDK    = 'D', 
                    @Db        = @Vlefta,     
                    @Kr        = 0,           
                    @DbKrMv    = @Vlefta;

          if @KMonFt<>''
             Select @VleftaMV = Round((@VleftaMV*@Kurs2)/@Kurs1,2),
                    @DbKrMV   = Round((@DbKrMV  *@Kurs2)/@Kurs1,2);

         Set @NrMax = IsNull(@NumDok,0); --@PNrDokArk; 

          if @NrMax <= 0
             begin
               Select @NrMax=Max(IsNull(NUMDOK,0))+1
                 From ARKA 
                Where KODAB=@KodARK AND TIPDOK=@TipDokArk AND Year(DATEDOK)=Year(@DateDok) 
             end;

      Select @NrRendorRF  = NRRENDOR, 
             @LlogariLM   = LLOGARI, 
             @KMonARK     = KMON,
             @PershkrimLM = (Select PERSHKRIM From LLOGARI B Where B.KOD=A.LLOGARI)
        From ARKAT A  
       Where KOD=@KodARK;

      -- Set @NewIDAr = @NrID;
      -- Set @NrID = IsNull(@NrID,0);

          if @NrID<=0
             begin
	           Insert  Into ARKA
                      (KODAB)
               Values (@KodARK);
                  Set  @NrID = @@IDENTITY; 
                  Set  @NrID = IsNull(@NrID,0);
               -- Set  @NewIDAr = @NrID; 
             end;

          if @TipDokFt='FJ'
             Update FJ
                Set NRRENDORAR = @NrId, 
                    KODARK     = Case When @NrId<=0 Then '' Else @KodArk End
              Where NRRENDOR   = @NrRendorFt
          else
          if @TipDokFt='FJT'
             Update FJT
                Set NRRENDORAR = @NrId, 
                    KODARK     = Case When @NrId<=0 Then '' Else @KodArk End
              Where NRRENDOR   = @NrRendorFt
          else
             Update FF
                Set NRRENDORAR = @NrId, 
                    KODARK     = Case When @NrId<=0 Then '' Else @KodArk End
              Where NRRENDOR   = @NrRendorFt;


          if @NrID<=0

               Return;



      Update ARKA  
	     Set NRRENDORAB  = @NrRendorRF,  
             KODAB       = @KodARK,   
             LLOGARI     = @LlogariLM,  
             TIPDOK      = @TipDokArk,  
             KMON        = @KMonARK,        
             NUMDOK      = @NrMax,  
             FRAKSDOK    = 0, 
             DATEDOK     = @DateDok,
             VLERA       = @Vlefta,       
             VLERAMV     = @VleftaMv, 
             KURS1       = @Kurs1,    
             KURS2       = @Kurs2,      
             SHENIM1     = @Shenim1,     
             SHENIM2     = @Shenim2, 
             NRDITAR     = 0,  
             NRSERI      = '',  
             FIRSTDOK    = 'A'+Cast(@NrMax As VarChar),
             KODNENDITAR = '', 
             NRDFK       = 0,   
             POSTIM      = 0,   
             LETER       = 0,   
             KLASIFIKIM  = '',
          -- USI,         
          -- USM,     
             TROW        = 0,     
             TAGNR       = 0
       Where NRRENDOR = @NrID;


--      Select @NrRendorRF,   @KodARK,   @LlogariLM, @TipDokArk,
--             @KMonARK,      @NrMax,    0,          @DateDok,
--             @Vlefta,       @VleftaMV, @Kurs1,     @Kurs2, 
--             @Shenim1,      @Shenim2,  0,          '',         'A'+Cast(@NrMax As VarChar),
--             '',            0,         0,          0,          '',
--             'A',           'A',       0,          0;
--
--      Select @RowCount=@@ROWCOUNT
--
--          if @RowCount<>0
--             Select @NewIDAr=@@IDENTITY  

--          if @TipDokFt='FJ'
--             Update FJ
--                Set NRRENDORAR = @NewIDAr
--              Where NRRENDOR   = @NrRendorFt
--          else
--          if @TipDokFt='FJT'
--             Update FJT
--                Set NRRENDORAR = @NewIDAr
--              Where NRRENDOR   = @NrRendorFt
--          else
--             Update FF
--                Set NRRENDORAR = @NewIDAr
--              Where NRRENDOR   = @NrRendorFt;
--
--          if @NewIDAr=0
--             Return;


  --  Rjeshtat ArkeScr    1.  ARKA
      Delete 
        From ARKASCR
       Where NRD=@NrID;

      Insert Into ARKASCR
            (NRD,        KODAF,      LLOGARI,    LLOGARIPK,    KOD, 
             TIPREF,     DATEDOKREF, NRDOKREF,   PERSHKRIM,    KOMENT, 
             DB,         KR,         DBKRMV,     KURS1,        KURS2,    KMON,
             TREGDK,     RRAB,       TIPKLL,     NRDITAR)

      Select @NrID,      @LlogariLM, @LlogariLM, @LlogariLM,   @LlogariLM+'....'+IsNull(@KMonARK,''), 
             '',         NULL,       0,          @PershkrimLM, @Shenim1,  
             @Db,        @Kr,        @DbKrMV,    @Kurs1,       @Kurs2,   @KMonARK,
             @TregDK,    'K',        'T',        0;

           
  --  Rjeshtat ArkeScr    2.  KLIENTI

          if @TregDK='D'
             begin
               Select @TregDK = 'K', 
                      @Kr     = @Db,  
                      @Db     = 0           
             end
          else
             begin
               Select @TregDK = 'D', 
                      @Db     = @Kr,  
                      @Kr     = 0
             end;

         Set @DbKrMv = 0 - @DbKrMv;

      Insert Into [ARKASCR]
            (NRD,        KODAF,      LLOGARI,   LLOGARIPK, KOD, 
             TIPREF,     DATEDOKREF, NRDOKREF,  PERSHKRIM, KOMENT, 
             DB,         KR,         DBKRMV,    KURS1,     KURS2,  KMON,
             TREGDK,     RRAB,       TIPKLL,    NRDITAR)
      Select @NrID,      @KodFKL,    @KodFKL,   @KodFKL,   @KodFKL+'.'+IsNull(@KMonFt,''), 
             @TipDokFt,  @DateDok,   @NrDokFt,  @Shenim1,  '',
             @Db,        @Kr,        @DbKrMV,   @Kurs1,    @Kurs2, @KMonFt,
             @TregDK,    '',         @TipKll,   0;

-- Ditaret
        Exec dbo.Isd_GjenerimDitarOne @PTableName='ARKA', @PSgn=0, @PNrRendor=@NrID;
     -- Exec dbo.Isd_GjenerimDitarOne @PTableName='ARKA', @PSgn=1, @PNrRendor=@NrID;  -- 20.09.2014 

        Exec dbo.Isd_AppendTransLog 'ARKA', @NrID, @Vlefta, @IDMStatus, @Perdorues, @LgJob;



     --   Kalimi ne LM 
     --   if @AutoPostLmAR=0 Or @TableTmpLm=''        
     --      Return;
     -- Exec [Isd_KalimLM] @PTip='A', @PNrRendor=@NrID, @PSQLFilter='', @PTableNameTmp=@TableTmpLm; 
GO
