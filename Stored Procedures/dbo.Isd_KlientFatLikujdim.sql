SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   procedure [dbo].[Isd_KlientFatLikujdim]
(
  @PKod         Varchar(60),
  @PDateKp      Varchar(20),
  @PDateKs      Varchar(20),
  @PModel       Varchar(10)
)
As

--   Exec [dbo].[Isd_KlientFatLikujdim] 'K99999','01/01/2014','02/07/2014','DTAFAT'

     Declare @Kod         Varchar(60),
             @DtKp        Varchar(20),
             @DtKs        Varchar(20),
             @Model       Varchar(10)
 
         Set @Kod       = @PKod;    
         Set @DtKp      = @PDateKp; 
         Set @DtKs      = @PDateKs; 
         Set @Model     = @PModel;  


      Select NRRENDOR,
             KOD,
             EMERTIM,
             VLEFTE,
             VLEFTEMV,
             DETYRIM,
             DETYRIMMV,
             KMON,
             TIPDOK,
             NRDOK,
             DATEDOK,
             A.NRFAT,
             A.DTFAT,
             A.DTPAGESE,
          -- DTLIKUJDIM = A.DTFAT + A.DITEVON,
             DTVONESE   = Abs(DateDiff(D,DBO.DATEVALUE(@DtKs),DTPAGESE)),
             TROW       = Cast(0 As Bit),
             TAGNR      = 0

        From 

      ( 

         Select NRRENDOR    = Max(A.NRRENDOR),
                KOD         = B.KOD,
                EMERTIM     = Max(A.PERSHKRIM), 
                VLEFTE      = Max(A.VLEFTA), 
                VLEFTEMV    = Max(A.VLEFTAMV),
                DETYRIM     = Max(A.VLEFTA)   - Sum(IsNull(C.VLEFTAMV,0)/A.KURS2),
                DETYRIMMV   = Max(A.VLEFTAMV) - Sum(IsNull(C.VLEFTAMV,0)),
                KMON        = A.KMON,
                TIPDOK      = Max(A.TIPDOK),
                NRDOK       = Max(A.NRDOK),
                DATEDOK     = Max(A.DATEDOK),
                A.NRFAT,
                A.DTFAT,
                DTPAGESE    = Case When @Model='DTAFAT'
                                   Then A.DTFAT + Max(IsNull(D.DTAF,IsNull(B.AFAT,0)))
                                   Else Max(A.DATEDOK)
                                   End
             -- DITEVON     = Max(IsNull(D.DTAF,IsNull(B.AFAT,0))),
             -- TREGDK      = Max(A.TREGDK)
           From DKL A LEFT  JOIN KLIENT B On  B.KOD=LEFT(A.KOD,CharIndex ( '.' , A.KOD )-1)
                      LEFT  JOIN DKL    C On  (A.NRFAT  =C.NRFAT) AND 
                                             (A.DTFAT  =C.DTFAT) AND 
                                             (C.DATEDOK<=DBO.DATEVALUE(@DtKs)) AND
                                             (LEFT(A.KOD,CharIndex ( '.' , A.KOD )-1)=LEFT(C.KOD,CharIndex ( '.' , C.KOD )-1)) AND 

                                             (A.NRRENDOR<>C.NRRENDOR) AND 
                                             (A.TREGDK='D') AND 
                                              A.TIPDOK IN ('FJ','SP')

                      LEFT JOIN FJ      D On  A.NRRENDOR=D.NRDITAR
          Where A.TREGDK='D' AND LEFT(A.KOD,CharIndex ( '.' , A.KOD )-1)=@Kod
       Group By B.KOD,A.KMON,A.NRFAT,A.DTFAT
         Having Abs(Max(A.VLEFTAMV)-Sum(IsNull(C.VLEFTAMV,0)))>0.01

      ) A 


       Where (DATEDOK>=DBO.DATEVALUE(@DtKp) AND DATEDOK<=DBO.DATEVALUE(@DtKs)) AND 
             (-DateDiff(D,DBO.DATEVALUE(@DtKs),DTPAGESE)>0)

    Order By KMON,KOD,DATEDOK,NRRENDOR;



 
 
 
 
 
 
GO
