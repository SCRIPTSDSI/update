SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE      Procedure [dbo].[Isd_TestDocSasiMgRow]
( 
  @pKod           Varchar(60),
  @pKMag          Varchar(60),
  @pDateDok       Varchar(60), -- aktivizoje datedok sepse edhte gati .......
  @pDtSkadence    Varchar(20),
  @pSeri          Varchar(60),
  @pTableTmp      Varchar(60),
  @pTipDok        Varchar(20),
  @pSasiNew       Float,
  @pNrRendorMg    Int,  -- Ne rastin e faturave eshte NrRendDMG e dokumentit magazines (rasti faturave), ne rastin FH/FD eshte NrRendor i dokumentit
  @pNrRendorRow   Int,
  @pTestSkadence  Bit
 )

AS
     
BEGIN  

         SET NOCOUNT ON;

-- EXEC dbo.Isd_TestDocSasiMgRow 'Z300','PG1','07/04/2019','02/05/2024','','#FDSCR','D',10,1366492,12562852,1


     DECLARE @Kod            Varchar(60),
             @KMag           Varchar(60),
             @DtSkadence     Varchar(20),
             @Seri           Varchar(60),
             @TableTmp       Varchar(60),
             @TipDok         Varchar(20),
             @Nrd            Int,
             @NrdFh          Int,
             @NrdFd          Int,
             @NrRendor       Int,
             @SasiNew        Float,
             @TestSkadence   Bit,
             
             @SasiH          Real, 
             @SasiD          Real,
             @SasiDok        Real,
             @sSql          nVarchar(MAX);
             
         SET @Kod          = @pKod;    
         SET @KMag         = @pKMag;
         SET @DtSkadence   = @pDtSkadence;
         SET @Seri         = @pSeri;
         SET @TableTmp     = @pTableTmp;
         SET @TipDok       = CASE WHEN ISNULL(@pTipDok,'')='SM'  THEN 'S'  ELSE @pTipDok END;
         SET @Nrd          = @pNrRendorMg;
         SET @NrRendor     = @pNrRendorRow;
         SET @TestSkadence = @pTestSkadence;
         SET @NrdFh        = CASE WHEN CHARINDEX(@TipDok,'SD')>0 THEN 0    ELSE @Nrd     END;
         SET @NrdFd        = CASE WHEN CHARINDEX(@TipDok,'SD')>0 THEN @Nrd ELSE 0        END;
         SET @SasiNew      = ISNULL(@pSasiNew,0)                                         -- CASE WHEN CHARINDEX(@TipDok,'SD')>0 THEN -1 ELSE 1 END;
         SET @SasiDok      = 0;
         SET @SasiH        = 0;
         SET @SasiD        = 0;
             

          IF @TestSkadence=1
             BEGIN

               SELECT @SasiH = ISNULL(SUM(SASI),0)                                       -- Gjendja tek dokumentat FH,FD (pa dokumentin konkret me NRD=@pNrRendorDok)
                 FROM FH A INNER JOIN FHSCR B ON A.NRRENDOR=B.NRD 
                WHERE A.KMAG=@KMag AND B.KARTLLG=@Kod AND B.NRD<>@NrdFh AND              -- DATEDOK<=dbo.DateValue(@pDateDok) AND
                      ISNULL(B.DTSKADENCE,dbo.DateValue('30/12/1899'))=dbo.DateValue(@DtSkadence) AND ISNULL(B.SERI,'')=@Seri;
             
               SELECT @SasiD = ISNULL(SUM(SASI),0) 
                 FROM FD A INNER JOIN FDSCR B ON A.NRRENDOR=B.NRD 
                WHERE A.KMAG=@KMag AND B.KARTLLG=@Kod AND B.NRD<>@NrdFd AND              -- DATEDOK<=dbo.DateValue(@pDateDok) AND
                      ISNUll(B.DTSKADENCE,dbo.DateValue('30/12/1899'))=dbo.DateValue(@DtSkadence) AND ISNULL(B.SERI,'')=@Seri;
             
                                                                                         -- Gjendja tek dokumentat konkret, pa reshtin konkret me NrRendor=pNrRendorRow
                  SET @sSql = N'
            
               SELECT @SasiDok = SUM(SASI) 
                 FROM '+@TableTmp+' 
                WHERE KARTLLG='''+@Kod+''' AND NRRENDOR<>'+CAST(CAST(@NrRendor AS BIGINT) AS VARCHAR)+' AND ISNULL(STATROW,'''')<>''*'' AND
                      ISNUlL(DTSKADENCE,dbo.DateValue(''30/12/1899''))=dbo.DateValue('''+@DtSkadence+''') AND ISNULL(SERI,'''')='''+@Seri+'''; ';

             END;
             
          IF @TestSkadence<>1
             BEGIN

               SELECT @SasiH = ISNULL(SUM(SASI),0)                                       -- Gjendja tek dokumentat FH,FD (pa dokumentin konkret me NRD=@pNrRendorDok)
                 FROM FH A INNER JOIN FHSCR B ON A.NRRENDOR=B.NRD 
                WHERE A.KMAG=@KMag AND B.KARTLLG=@Kod AND B.NRD<>@NrdFh;                 -- AND DATEDOK<=dbo.DateValue(@pDateDok)
             
               SELECT @SasiD = ISNULL(SUM(SASI),0) 
                 FROM FD A INNER JOIN FDSCR B ON A.NRRENDOR=B.NRD 
                WHERE A.KMAG=@KMag AND B.KARTLLG=@Kod AND B.NRD<>@NrdFd;                 -- AND DATEDOK<=dbo.DateValue(@pDateDok)
             
                                                                                         -- Gjendja tek dokumentat konkret, pa reshtin konkret me NrRendor=pNrRendorRow
                  SET @sSql = N'
            
               SELECT @SasiDok = SUM(SASI) 
                 FROM '+@TableTmp+' 
                WHERE KARTLLG='''+@Kod+''' AND NRRENDOR<>'+CAST(CAST(@NrRendor AS BIGINT) AS VARCHAR)+' AND ISNULL(STATROW,'''')<>''*'';';

             END;


     EXECUTE SP_EXECUTESQL @sSql, N'@SasiDok Real OUT',@SasiDok OUTPUT;

         SET @SasiDok = ISNULL(@SasiDok,0) * CASE WHEN CHARINDEX(@TipDok,'SD')>0 THEN -1 ELSE 1 END;
         
      SELECT GJENDJEMG    = dbo.Isd_FloatRound(ISNULL(@SasiH,0) - ISNULL(@SasiD,0),3),
             GJENDJEMGNEW = dbo.Isd_FloatRound(ISNULL(@SasiH,0) - ISNULL(@SasiD,0) + @SasiDok + @SasiNew,3)
--           SASIH=ISNULL(@SasiH,0), SASID=ISNULL(@SasiD,0), SASIDOK=@SasiDok, SASINEW=@SasiNew, TIPDOK=@TipDok;  -- Keto fusha ndihmojne ne kolaudim edhe brenda ne soft.      

--           @SasiNew eshte vlera e re e reshtit konkret qe vjen nga programi (akoma nuk eshte bere post)

        
  -- PRINT @sSql; PRINT @SasiH; PRINT @SasiD; PRINT @SasiDok; PRINT @SasiNew;
      -- SELECT * FROM #FJSCR
      -- SELECT SUM(SASI) 
      --   FROM #FJSCR 
      --  WHERE KARTLLG='Z300' AND NRRENDOR<>12562852 AND 
      --        ISNUll(DTSKADENCE,dbo.DateValue('30/12/1899'))=dbo.DateValue('02/05/2024') AND ISNULL(SERI,'')='';         
END;      
GO
