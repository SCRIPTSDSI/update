SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   FUNCTION [dbo].[Isd_KrediLimFature]
(
  @PKod         Varchar(60),
  @PNrDitar     Int,
  @PVlefetFat   Float,
  @PDateKp      Varchar(20),
  @PDateKs      Varchar(20),
  @PModel       Varchar(10)
)

  Returns Varchar(300)

As

Begin

-- Select A=dbo.Isd_OkKrediLimFature ('K99999', 567704, 119, '01/01/2014','02/07/2014','DTAFAT')

-- Fatura pa likujduar ne rastin Pikezim

     Declare @User         VarChar(30),
             @Kod          Varchar(60),
             @DtKp         Varchar(20),
             @DtKs         Varchar(20),
             @Model        Varchar(10)
 
         Set @Kod        = @PKod;      
         Set @DtKp       = @PDateKp;   
         Set @DtKs       = @PDateKs;   
         Set @Model      = @PModel;    


     Declare @Kredi        Float,
             @KrediApl     Bit,
             @Gjendje      Float,
             @MsgBlock     Varchar(30),
             @Result       Varchar(200),
             @NrRows       Int;
          
         Set @Result     = ''
      SELECT @KrediApl   = IsNull(APLKREDILIM,0),
             @Kredi      = IsNull(KREDI,0),
          -- @ModBlock   = IsNull(KREDIMODBLOCK,0),
             @MsgBlock   = CASE WHEN ISNULL(APLKREDILIM,0)=1 AND ISNULL(KREDIOVERBLOCK,0)=1
                                THEN 'BLOCK'
                                ELSE '' END
        FROM KLIENT 
       WHERE KOD=@PKod;

          if IsNull(@KrediApl,0)=0
             Return @Result;


      Select @Gjendje   = Sum(DETYRIMMV),
             @NrRows    = Count(*) 

        From 

      ( 
             -- Dy raste: Krahesimi me DTAFAT (datedok + Afatin) ose DTDOK (datedok /+Afatin)
         Select DETYRIMMV   = Max(A.VLEFTAMV) - Sum(IsNull(C.VLEFTAMV,0)),
                DATEDOK     = Max(A.DATEDOK),
                DTPAGESE    = Case When @Model='DTAFAT'  
                                   Then A.DTFAT + Max(IsNull(D.DTAF,0)) -- Then A.DTFAT + Max(IsNull(D.DTAF,IsNull(B.AFAT,0)))
                                   Else Max(A.DATEDOK)                  -- Else Max(A.DATEDOK+IsNull(D.DTAF,0))
                                   End
           From DKL A LEFT  JOIN KLIENT B On  B.KOD=LEFT(A.KOD,CharIndex ( '.' , A.KOD )-1)
                      LEFT  JOIN DKL    C On (A.NRFAT   = C.NRFAT) AND 
                                             (A.DTFAT   = C.DTFAT) AND 
                                             (C.DATEDOK<= DBO.DATEVALUE(@DtKs)) AND
                                             (LEFT(A.KOD,CharIndex ( '.' , A.KOD )-1)=LEFT(C.KOD,CharIndex ( '.' , C.KOD )-1)) AND 

                                             (A.NRRENDOR<>C.NRRENDOR) AND (C.NRRENDOR<>@PNrDitar) AND
                                             (A.TREGDK='D') AND 
                                             (A.TIPDOK IN ('FJ','SP'))

                      LEFT JOIN FJ      D On  A.NRRENDOR=D.NRDITAR
          Where A.NRRENDOR<>@PNrDitar AND 
                A.TREGDK='D' AND LEFT(A.KOD,CharIndex ( '.' , A.KOD )-1)=@Kod
       Group By B.KOD,A.KMON,A.NRFAT,A.DTFAT
         Having Abs(Max(A.VLEFTAMV)-Sum(IsNull(C.VLEFTAMV,0)))>0.01

      ) A 

       Where (DATEDOK>=DBO.DATEVALUE(@DtKp) AND DATEDOK<=DBO.DATEVALUE(@DtKs)) AND 
             (-DateDiff(D,DBO.DATEVALUE(@DtKs),DTPAGESE)>0)

        if  @Gjendje + @PVlefetFat > @Kredi       -- @Gjendje + @PVlefetFat - @VlefteOld > @Kredi
            Set @Result = 'Kujdes: Detyrim i vjeter + Vlere_fature > [Kredia_lejuar / Maturim_sipas_afatit] !!  '+IsNull(@MsgBlock,'')+
                          '( '+Cast(@Gjendje    As Varchar)+'+'+  -- Cast(@Gjendje-@VlefteOld As Varchar)+'+'+
                               Cast(@PVlefetFat As Varchar)+'>'+
                               Cast(@Kredi      As Varchar)+' /  '+
                               Cast(@NrRows     As Varchar)+' fatura pa likujduar ..! )';

-- Shenimet edhe per rastin kur punon vetem me date fature pa kredi limite
--            Set @Result = 'Kujdes: Detyrim i vjeter + Vlere fature > Kredia e lejuar !!  '+IsNull(@MsgBlock,'')+
--                          '( '+Cast(@Gjendje    As Varchar)+'+'+  -- Cast(@Gjendje-@VlefteOld As Varchar)+'+'+
--                               Cast(@PVlefetFat As Varchar)+'>'+
--                               Cast(@Kredi      As Varchar)+' -  '+
--                               Cast(@NrRows     As Varchar)+' fatura pa likujduar ..! )';

     Return @Result

End
GO
