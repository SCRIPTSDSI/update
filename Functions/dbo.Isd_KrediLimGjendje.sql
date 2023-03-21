SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   FUNCTION [dbo].[Isd_KrediLimGjendje]
(
  @PKod         Varchar(60),
  @PNrDitar     Int,
  @PVlefetFat   Float,
  @PDateKp      Varchar(20),
  @PDateKs      Varchar(20),
  @PModel       Varchar(10)
)
Returns Varchar(200)

As

Begin

    Declare @Kredi          Float,
            @KrediWarning   Float,
            @KrediApl       Bit,
            @Gjendje        Float,
        --  @VlefteOld      Float,
            @ModBlock       Int,
            @MsgBlock       Varchar(30),
            @Result         Varchar(200);
          
        Set @Result       = ''
     -- Set @VlefteOld    = 0
     

     SELECT @KrediApl     = IsNull(APLKREDILIM,0),
            @Kredi        = IsNull(KREDI,0),
            @KrediWarning = IsNull(KREDIWARNING,0),
            @ModBlock     = IsNull(KREDIMODBLOCK,0),
            @MsgBlock     = CASE WHEN ISNULL(APLKREDILIM,0)=1 AND ISNULL(KREDIOVERBLOCK,0)=1
                                 THEN 'BLOCK'
                                 ELSE '' END
       FROM KLIENT 
      WHERE KOD=@PKod;

         if IsNull(@KrediApl,0)=0
            Return @Result;


         if @ModBlock=1
            begin
         --   Rasti testi i Blokimit sipas Afateve te shlyerjes per cdo fature te klientit.

              Select @Result = dbo.Isd_KrediLimFature (@PKod,@PNrDitar,@PVlefetFat,@PDateKp,@PDateKs,@PModel);
              Return @Result;
            end;


-- Rasti testi i Blokimit sipas Gjendjes se detyrimit te klientit.

     SELECT @Gjendje    = Sum(Case When NRRENDOR<>@PNrDitar 
                                   Then Case When TREGDK='D' Then VLEFTAMV Else 0-VLEFTAMV End
                                   Else 0 End)
         -- @VlefteOld  = Sum(Case When NRRENDOR=@PNrDitar   Then VLEFTAMV Else 0 End)
       FROM DKL 
      WHERE Left( KOD, Case When CharIndex('.',KOD)<>0 
                            Then CharIndex('.',KOD)-1 
                            Else Len(KOD) End )=@PKod;

        Set @Kredi        = IsNull(@Kredi,0);
        Set @KrediWarning = IsNull(@KrediWarning,0);
        Set @Gjendje      = ISNULL(@Gjendje,0);

        if  @Gjendje + @PVlefetFat > @Kredi          -- @Gjendje + @PVlefetFat - @VlefteOld > @Kredi
            Set @Result = 'Kujdes: Detyrim i vjeter + Vlere fature > Kredia e lejuar ..!!  '+IsNull(@MsgBlock,'')+
                          '( '+Cast(@Gjendje      As Varchar)+'+'+  -- Cast(@Gjendje-@VlefteOld As Varchar)+'+'+
                               Cast(@PVlefetFat   As Varchar)+'>'+
                               Cast(@Kredi        As Varchar)+' ! )';

        if  (@Result='') And (@Gjendje + @PVlefetFat > @KrediWarning) And (@KrediWarning>0)  -- @Gjendje + @PVlefetFat - @VlefteOld > @KrediWarning
            Set @Result = 'Kujdes: Detyrim i vjeter + Vlere fature > Vlefte paralajmeruese ..!!  '+'Warning'+
                          '( '+Cast(@Gjendje      As Varchar)+'+'+  
                               Cast(@PVlefetFat   As Varchar)+'>'+
                               Cast(@KrediWarning As Varchar)+' ! )';

     Return @Result

End
GO
