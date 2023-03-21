SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE     Procedure [dbo].[Isd_ListCmimePreferenc]
(
  @PKodArtKp  Varchar(100),
  @PKodArtKs  Varchar(100),
  @PKodKFKp   Varchar(10),
  @PKodKFKs   Varchar(10),
  @PDtKp      Varchar(20),
  @PDtKs      Varchar(20),
  @PKodOfKp   Varchar(30),
  @PKodOfKs   Varchar(30),
  @PActive    Bit,
  @PRound     Int,
  @PUser      Varchar(30)
)

AS

--Exec dbo.Isd_ListCmimePreferenc 'P100','P100','D002','D002','01/01/2014','31/12/2014','A','zz',0,2,'ADMIN'
 
  Declare @User        VarChar(30),
          @TableRefK   VarChar(50),
          @TableRefA   VarChar(50)

      Set @TableRefK = 'KLIENT';
      Set @TableRefA = 'ARTIKUJ';
      Set @User      = @PUser;

  Declare @KodArtKp    Varchar(30),
          @KodArtKs    Varchar(30),
          @KodKFKp     Varchar(30),
          @KodKFKs     Varchar(30),
          @DtKp        Varchar(20),
          @DtKs        Varchar(20),
          @KodOfKp     Varchar(30),
          @KodOfKs     Varchar(30),
          @Active      Bit,
          @Round       Int;

      Set @KodArtKp  = @PKodArtKp
      Set @KodArtKs  = @PKodArtKs
      Set @KodKFKp   = @PKodKFKp
      Set @KodKFKs   = @PKodKFKs
      Set @DtKp      = @PDtKp
      Set @DtKs      = @PDtKs
      Set @KodOfKp   = @PKodOfKp
      Set @KodOfKs   = @PKodOfKs
      Set @Active    = @PActive
      Set @Round     = @PRound;

      if @Round<=-1
         begin
           Select @Round = Cmim From Decimals Where TableName='FJ';
         end;
     Set @Round = IsNull(@Round,2);

--   SELECT KOD          = C.KOD,
--          PERSHKRIM    = C.PERSHKRIM,
--          D.CMIM,
--          D.SASI,
--          KLIKOD       = B.KOD,
--          KLIPERSHKRIM = B.PERSHKRIM,
--          OFEKOD       = A.KOD,
--          OFEPERSHKRIM = A.PERSHKRIM,
--          A.ACTIV,
--          DATEFILLIM   = A.DATESTART,
--          DATEFUND     = A.DATEEND,
--          TRow         = Cast(0 As Bit),
--          TagNr        = 0  
--     FROM KlientCmim A INNER JOIN KlientCmimKl  B  ON A.NRRENDOR =B.NRD
--                       INNER JOIN KlientCmimArt C  ON A.NRRENDOR =C.NRD
--                       INNER JOIN KlientCmimCm  D  ON C.NRRENDOR =D.NRD
--                    -- INNER JOIN Klient        R1 ON R1.KOD=B.KOD
--                    -- INNER JOIN Artikuj       R2 ON R2.KOD=C.KOD
--                    -- INNER JOIN DRHReference  RK ON B.KOD=RK.KOD AND RK.REFERENCE=@TableRefK AND RK.KODUS=@User
--                    -- INNER JOIN DRHReference  RA ON C.KOD=RA.KOD AND RA.REFERENCE=@TableRefA AND RA.KODUS=@User
--    WHERE (B.KOD>=@KodKFKp  And B.KOD<=@KodKFKs) And
--          (C.KOD>=@KodArtKp And C.KOD<=@KodArtKs)  And 
--          (A.DATESTART>=DBO.DATEVALUE(@DtKp)) AND (A.DATESTART<=DBO.DATEVALUE(@DtKs)) And
--          (A.KOD>=@KodOfKp AND A.KOD<=@KodOfKs) And (CAST(ISNULL(ACTIV,0) As Int) >= CAST(@Active As Int))
-- ORDER BY A.DATESTART DESC,A.KOD,A.NRRENDOR,1,2
--


    Select --A.*, K.* 
           KOD          = A.KOD,
           PERSHKRIM    = A.PERSHKRIM,
           CMIM         = Round(A.CMSH,@Round),
           KLIKOD       = K.KOD,
           KLIPERSHKRIM = K.PERSHKRIM,
           ACTIV        = A.ACTIV,
           A.KODKL,
           A.PERSHKRIMKL,
           A.NRD,
           NRRENDOR     = K.NRRENDOR,
           TagNr        = 0,
           TRow         = Cast(0 As Bit)
      From KlientCM A INNER JOIN KLIENT K On A.NRD=K.NRRENDOR
    WHERE (K.KOD>=@KodKFKp  And K.KOD<=@KodKFKs) And
          (A.KOD>=@KodArtKp And A.KOD<=@KodArtKs) 
       -- (A.DATESTART>=DBO.DATEVALUE(@DtKp)) AND (A.DATESTART<=DBO.DATEVALUE(@DtKs)) And
       -- (A.KOD>=@KodOfKp AND A.KOD<=@KodOfKs) And 
       -- (CAST(ISNULL(ACTIV,0) As Int) >= CAST(@Active As Int))
  Order By A.KOD,K.KOD


GO
