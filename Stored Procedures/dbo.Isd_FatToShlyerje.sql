SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- Declare  @PKod        VARCHAR(60), 
--          @PNrDok      VARCHAR(30), 
--          @PDateDok    VARCHAR(20), 
--          @PTip        VARCHAR(20), 
--          @PTipKll     VARCHAR(5),
--          @PKMon       VARCHAR(10),
--          @PLikujdim   Bit,

--          @PTableName  VARCHAR(50), 
--          @PPershkrim  VARCHAR(200),
--          @POrg        VARCHAR(10), 
--          @PNrRendor   BigInt
--
--          SELECT @PKod='FA100',@PNrDok='701',@PDateDok='10/01/2013',@PTip='FF',@PTipKll='F',@PLikujdim=0 
--
--     Exec dbo.Isd_FatToShlyerje2 
--          @PKod,@PNrDok,@PDateDok,@PTip,@PTipKll,@PKMon,@PLikujdim, 
--          @PTableName Output,
--          @PPershkrim Output, 
--          @POrg       Output, 
--          @PNrRendor  Output, 
--            
--
--   SELECT NRRENDOR=@PNrRendor,ORG=@POrg,TABLENAME=@PTableName, PERSHKRIM=@PPershkrim 

-- Afishohet ose fature ose likujdimi i saj ....


CREATE        Procedure [dbo].[Isd_FatToShlyerje]
(
  @pKod          VARCHAR(60),
  @pNrDok        VARCHAR(30),
  @pDateDok      VARCHAR(20),
  @pTip          VARCHAR(10),
  @pTipKll       VARCHAR(5),
  @pKMon         VARCHAR(10),
  @pLikujdim     BIT,

  @pTableName    VARCHAR(30)  OUTPUT,
  @pPershkrim    VARCHAR(150) OUTPUT,
  @pOrg          VARCHAR(10)  OUTPUT,
  @pNrRendor     BIGINT       OUTPUT
 )

As

          SET NOCOUNT OFF

      DECLARE @Kod          VARCHAR(60),
              @NrDok        VARCHAR(30),
              @DateDok      VARCHAR(20),
              @Tip          VARCHAR(10),
              @TipKll       VARCHAR(5),
              @KMon         VARCHAR(10),
              @Likujdim     BIT;

          SET @Kod        = ISNULL(@pKod,'');
          SET @NrDok      = ISNULL(@pNrDok,'');
          SET @DateDok    = ISNULL(@pDateDok,'');
          SET @Tip        = ISNULL(@pTip,'');
          SET @TipKll     = ISNULL(@pTipKll,'');
          SET @KMon       = ISNULL(@pKMon,'');
          SET @Likujdim   = ISNULL(@pLikujdim,0);



      DECLARE @NrDitar       BIGINT,          -- @TipKll        VARCHAR(5),
              @DitarName     VARCHAR(50),
              @TregDK        VARCHAR(5),
              @TipFat        VARCHAR(10),
              @TableName     VARCHAR(50), 
              @Pershkrim     VARCHAR(150), 
              @Org           VARCHAR(5), 
              @NrRendor      INT;

        -- if @PTip='FJ'
        --    SET @TipKLL='S'
        -- else
        --    SET @TipKLL='F';


       IF @TipKll = 'F'

          BEGIN

               SET @TipFat = 'FF'

               SET @TregDK = 'K';
                IF @Likujdim=1
                   SET @TregDK = 'D'

            SELECT @NrDitar=NRRENDOR,  @DitarName='DFU'
              FROM DFU A
             WHERE CASE WHEN            CHARINDEX('.',A.KOD)<>0 
                        THEN LEFT(A.KOD,CHARINDEX('.',A.KOD)-1) 
                        ELSE A.KOD 
                   END      = @Kod                         AND 

                   NrFat    = @NrDok                       AND 

                   DTFat    = Dbo.DateValue(@DateDok)      AND 

                  (TipFat   = @Tip Or TipFat=@TipFat Or ISNULL(TipFat,'')='') AND  

                   TREGDK   = @TregDK;

          END;



       IF @TipKll='S'

          BEGIN

               SET @TipFat = 'FJ'                                                   -- 06.08.2016

               SET @TregDK = 'D'
                IF @Likujdim=1
                   SET @TregDK = 'K';

            SELECT @NrDitar=NRRENDOR,  @DitarName='DKL'
              FROM DKL A
             WHERE CASE WHEN            CHARINDEX('.',A.KOD)<>0 
                        THEN LEFT(A.KOD,CHARINDEX('.',A.KOD)-1) 
                        ELSE A.KOD 
                   END      = @Kod                         AND 

                   NrFat    = @NrDok                       AND 

                   DTFat    = Dbo.DateValue(@DateDok)      AND 

                  (TipFat   = @Tip Or TipFat=@TipFat Or IsNull(TipFat,'')='') AND  

                   TREGDK   = @TregDK;

           END;



     EXEC Isd_NrDitarToNrRendor @DitarName, @NrDitar, @TableName OUTPUT, @Pershkrim OUTPUT, @Org OUTPUT, @NrRendor OUTPUT;

   SELECT @PTableName = @TableName, @PPershkrim = @Pershkrim, @POrg = @Org, @PNrRendor  = @NrRendor;

   SELECT DITARNAME = @DitarName,   NRDITAR = @NrDitar,   TABLENAME = @PTableName,   PERSHKRIM = @PPershkrim, 
          ORG = @POrg,              NRRENDOR = @PNrRendor;

--Print @PTipKll
--Print @PKod
--Print @PTip
--Print @PKMon
--Print @PDateDok
--Print @PLikujdim
--
--Print @TipFat
--Print @TregDK
--Print @NrDitar

--Print @NrDitar
--Print @PTableName
--Print @POrg
--Print @PNrRendor


GO
