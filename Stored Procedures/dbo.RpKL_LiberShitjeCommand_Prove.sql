SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









CREATE   procedure [dbo].[RpKL_LiberShitjeCommand_Prove]


AS


     Declare @User        VarChar(30),
             @TableRefK   VarChar(50),
             @TableD      VarChar(30),
             @DtUser      VarChar(20),
             @TableLink   VarChar(50);

         Set @TableRefK = 'KLIENT'
         Set @TableD    = 'FJ'
         Set @User      = '101USER101'
         Set @DtUser    = Dbo.DRHDateKP(@User,@TableD)
         Set @TableLink = 'FJ'

     Declare @Nipt        Varchar(20),
             @Pershkrim   Varchar(100),
             @ErrorMsg    Varchar(50),
             @StepError   Float,
             @Round       Int;

         Set @Round     = 0+0+0+2
         Set @ErrorMsg  = '';

      Select @Nipt      = NIPT,
             @Pershkrim = PERSHKRIM
          -- @StepError = IsNull(STEPERRORLSH,1)
        From CONFND;

         SET @StepError = 6;


          if Object_Id('TempDB..#LiberTmp') is not null
             Drop Table #LiberTmp;

      SELECT A.NIPT,
             A.KODFISKAL,
             A.SHENIM1,
             A.NRSERIAL,
             A.RRETHI,
             A.DATEDOK,
             MUAJ           = MONTH(DATEDOK),
             VIT            = YEAR(DATEDOK),
             A.KLASIFIKIM,

             E_TOTAL        = CASE WHEN ABS(ROUND(E_TOTALDOK -
                                                 (EE_PERJASHTUAR + F_SHERBIM   + G_EXPORT    + GJ_FURNIZIM)    -
                                                 (H_SHITJEVEND   + J_SHITJEAGJ + L_SHITJEANG + M_SHITJEBKQ) -
                                                 (I_TVSHVEND     + K_TVSHAGJ   + LL_TVSHANG  + N_TVSHBKQ),0))>@StepError
                                THEN E_TOTALDOK
                                ELSE              EE_PERJASHTUAR + F_SHERBIM   + G_EXPORT    + GJ_FURNIZIM  +
                                                  H_SHITJEVEND   + J_SHITJEAGJ + L_SHITJEANG + M_SHITJEBKQ  +
                                                  I_TVSHVEND     + K_TVSHAGJ   + LL_TVSHANG  + N_TVSHBKQ
                                END,

             EE_PERJASHTUAR,
             F_SHERBIM,
             G_EXPORT,
             GJ_FURNIZIM,

          -- 20%    Pjesa e VLPATVSH
             H_SHITJEVEND,
             J_SHITJEAGJ,
             L_SHITJEANG,
             M_SHITJEBKQ,

          -- 20%    Pjesa e VLTVSH
             I_TVSHVEND,
             K_TVSHAGJ,
             LL_TVSHANG,
             N_TVSHBKQ,

          -- Errore
             X_MSGERROR1 = CASE WHEN ABS(ROUND(E_TOTALDOK -
                                              (EE_PERJASHTUAR + F_SHERBIM   + G_EXPORT    + GJ_FURNIZIM) -
                                              (H_SHITJEVEND   + J_SHITJEAGJ + L_SHITJEANG + M_SHITJEBKQ) -
                                              (I_TVSHVEND     + K_TVSHAGJ   + LL_TVSHANG  + N_TVSHBKQ),0))>@StepError
                                THEN 'ERROR FATURE'
                                ELSE ''
                                END,
             X_VLERROR1  =               ROUND(E_TOTALDOK -
                                              (EE_PERJASHTUAR + F_SHERBIM   + G_EXPORT    + GJ_FURNIZIM) -
                                              (H_SHITJEVEND   + J_SHITJEAGJ + L_SHITJEANG + M_SHITJEBKQ) -
                                              (I_TVSHVEND     + K_TVSHAGJ   + LL_TVSHANG  + N_TVSHBKQ), 0),

          -- Me konkret testo edhe vlerat 20 ose 0
             X_MSGERROR2  = CASE WHEN (EE_PERJASHTVSH<>0)
                                      THEN 'Sh.perjashtuar'
                                 WHEN (G_EXPORTTVSH<>0)
                                      THEN 'Export'
                                 WHEN (H_SHITJEVEND<>0 AND I_TVSHVEND=0) OR (H_SHITJEVEND=0 AND I_TVSHVEND<>0)
                                      THEN 'Sh.Vendi'
                                 WHEN (J_SHITJEAGJ<>0  AND K_TVSHAGJ=0)  OR (J_SHITJEAGJ=0  AND K_TVSHAGJ<>0)
                                      THEN 'Sh.Agjent'
                                 WHEN (L_SHITJEANG<>0  AND LL_TVSHANG=0) OR (L_SHITJEANG=0  AND LL_TVSHANG<>0)
                                      THEN 'Sh.Autngarkese'
                                 WHEN (M_SHITJEBKQ<>0  AND N_TVSHBKQ=0)  OR (M_SHITJEBKQ=0  AND N_TVSHBKQ<>0)
                                      THEN 'Borxh keq'
                                 ELSE '' END,

             A.ISDG,
             A.NRRENDOR,
             A.NRDFK,
             A.LIBERNR,
             A.LIBERDT,

             NIPTND         = @Nipt,
             PERSHKRIMND    = @Pershkrim,
             MASTERGROUP    = '',
             MASTERTABLE    = @TableLink,
             MASTERFIELD    = 'NRRENDOR',
             MASTERNR       = A.NRRENDOR

        INTO #LiberTmp

        FROM
     (
      SELECT NIPT           = MAX(ISNULL(A.NIPT,'')),
             KODFISKAL      = MAX(ISNULL(A.KODFISKAL,'')),
             SHENIM1        = MAX(CASE WHEN ISNULL(R1.EMERTIMLB,'')=''
                                       THEN ISNULL(A.SHENIM1,'')
                                       ELSE R1.EMERTIMLB
                                       END),
             NRSERIAL       = MAX(ISNULL(A.NRSERIAL,'')),
             RRETHI         = MAX(ISNULL(A.RRETHI,'')),
             DATEDOK        = MAX(ISNULL(A.DATEDOK,'')),
             KLASIFIKIM     = MAX(ISNULL(A.KLASIFIKIM,'')),
             A.NRRENDOR,
             NRDFK          = MAX(ISNULL(A.NRDFK,0)),
             ISDG           = MAX(CASE WHEN ISNULL(A.ISDG,0)=1
                                       THEN 1
                                       ELSE 0
                                       END),

             E_TOTALDOK     = ROUND(CAST(SUM(((B.VLTVSH + B.VLPATVSH)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)) AS REAL),@Round),

             EE_PERJASHTUAR = ROUND(CAST(SUM(CASE WHEN ISNULL(B.APLTVSH,0)=0 AND
                                                       CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SEXP,SAGJ,SANG,SBKQ,')<=0
                                                  THEN (ISNULL(B.VLPATVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                                  ELSE 0 END) AS REAL),  @Round),

             F_SHERBIM      = ROUND(CAST(SUM(CASE WHEN CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SEXP,')>0 AND
                                                  ISNULL(B.TIPKLL,'')<>'K'
                                               -- ISNULL(B.VLTVSH,0)=0
                                                  THEN (ISNULL(B.VLPATVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                                  ELSE 0 END) AS REAL),  @Round),
             G_EXPORT       = ROUND(CAST(SUM(CASE WHEN CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SEXP,')>0 AND
                                                       ISNULL(B.TIPKLL,'')='K'
                                                    -- ISNULL(B.VLTVSH,0)=0
                                                  THEN (ISNULL(B.VLPATVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                                  ELSE 0 END) AS REAL),  @Round),

             GJ_FURNIZIM    = ROUND(CAST(SUM(CASE WHEN ISNULL(B.APLTVSH,0)=1 AND
                                                       CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SEXP,SAGJ,SANG,SBKQ,')<=0 AND
                                                    -- ISNULL(B.TIPKLL,'')<>'K' AND
                                                       ISNULL(B.VLTVSH,0)=0
                                                  THEN (ISNULL(B.VLPATVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                                  ELSE 0 END) AS REAL),  @Round),
          -- Per Error
             EE_PERJASHTVSH = ROUND(CAST(SUM(CASE WHEN ISNULL(B.APLTVSH,0)=0 AND
                                                       CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SEXP,SAGJ,SANG,SBKQ,')<=0
                                                  THEN (ISNULL(B.VLTVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                                  ELSE 0 END) AS REAL),  @Round),
             G_EXPORTTVSH   = ROUND(CAST(SUM(CASE WHEN CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SEXP,')>0
                                                  THEN (ISNULL(B.VLTVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                                  ELSE 0 END) AS REAL), @Round),

         -- 20%    Pjesa e VLPATVSH
             H_SHITJEVEND   = ROUND(CAST(SUM(CASE WHEN ISNULL(B.VLTVSH,0)<>0 AND ISNULL(B.APLTVSH,0)=1 AND
                                                       CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SEXP,SAGJ,SANG,SBKQ,')<=0
                                                  THEN (ISNULL(B.VLPATVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                                  ELSE 0 END) AS REAL), @Round),

             J_SHITJEAGJ    = ROUND(CAST(SUM(CASE WHEN CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SAGJ,')>0
                                                  THEN (ISNULL(B.VLPATVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                                  ELSE 0 END) AS REAL), @Round),
             L_SHITJEANG    = ROUND(CAST(SUM(CASE WHEN CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SANG,')>0
                                                  THEN (ISNULL(B.VLPATVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                                  ELSE 0 END) AS REAL), @Round),
             M_SHITJEBKQ    = ROUND(SUM(CASE WHEN CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SBKQ,')>0
                                             THEN (ISNULL(B.VLPATVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                             ELSE 0 END),@Round),

          -- 20%    Pjesa e VLTVSH
             I_TVSHVEND     = ROUND(CAST(SUM(CASE WHEN CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SEXP,SAGJ,SANG,SBKQ,')<=0
                                                  THEN (ISNULL(B.VLTVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                                  ELSE 0 END) AS REAL), @Round),
             K_TVSHAGJ      = ROUND(CAST(SUM(CASE WHEN CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SAGJ,')>0
                                                  THEN (ISNULL(B.VLTVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                                  ELSE 0 END) AS REAL), @Round),
             LL_TVSHANG     = ROUND(CAST(SUM(CASE WHEN CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SANG,')>0
                                                  THEN (ISNULL(B.VLTVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                                  ELSE 0 END) AS REAL), @Round),
             N_TVSHBKQ      = ROUND(CAST(SUM(CASE WHEN CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SBKQ,')>0
                                                  THEN (ISNULL(B.VLTVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                                  ELSE 0 END) AS REAL), @Round),


/*
  -- Probleme me perafrimin 05.05.2015
             E_TOTALDOK     = ROUND(SUM(((B.VLTVSH + B.VLPATVSH)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)),@Round),

             EE_PERJASHTUAR = ROUND(SUM(CASE WHEN ISNULL(B.APLTVSH,0)=0 AND
                                                  CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SEXP,SAGJ,SANG,SBKQ,')<=0
                                             THEN (ISNULL(B.VLPATVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                             ELSE 0 END),@Round),

             F_SHERBIM      = ROUND(SUM(CASE WHEN CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SEXP,')>0 AND
                                                  ISNULL(B.TIPKLL,'')<>'K'
                                               -- ISNULL(B.VLTVSH,0)=0
                                             THEN (ISNULL(B.VLPATVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                             ELSE 0 END),@Round),
             G_EXPORT       = ROUND(SUM(CASE WHEN CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SEXP,')>0 AND
                                                  ISNULL(B.TIPKLL,'')='K'
                                               -- ISNULL(B.VLTVSH,0)=0
                                             THEN (ISNULL(B.VLPATVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                             ELSE 0 END),@Round),

             GJ_FURNIZIM    = ROUND(SUM(CASE WHEN ISNULL(B.APLTVSH,0)=1 AND
                                                  CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SEXP,SAGJ,SANG,SBKQ,')<=0 AND
                                               -- ISNULL(B.TIPKLL,'')<>'K' AND
                                                  ISNULL(B.VLTVSH,0)=0
                                             THEN (ISNULL(B.VLPATVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                             ELSE 0 END),@Round),
          -- Per Error
             EE_PERJASHTVSH = ROUND(SUM(CASE WHEN ISNULL(B.APLTVSH,0)=0 AND
                                                  CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SEXP,SAGJ,SANG,SBKQ,')<=0
                                             THEN (ISNULL(B.VLTVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                             ELSE 0 END),@Round),
             G_EXPORTTVSH   = ROUND(SUM(CASE WHEN CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SEXP,')>0
                                             THEN (ISNULL(B.VLTVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                             ELSE 0 END),@Round),

         -- 20%    Pjesa e VLPATVSH
             H_SHITJEVEND   = ROUND(SUM(CASE WHEN ISNULL(B.VLTVSH,0)<>0 AND ISNULL(B.APLTVSH,0)=1 AND
                                                  CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SEXP,SAGJ,SANG,SBKQ,')<=0
                                             THEN (ISNULL(B.VLPATVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                             ELSE 0 END),@Round),

             J_SHITJEAGJ    = ROUND(SUM(CASE WHEN CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SAGJ,')>0
                                             THEN (ISNULL(B.VLPATVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                             ELSE 0 END),@Round),
             L_SHITJEANG    = ROUND(SUM(CASE WHEN CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SANG,')>0
                                             THEN (ISNULL(B.VLPATVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                             ELSE 0 END),@Round),
             M_SHITJEBKQ    = ROUND(SUM(CASE WHEN CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SBKQ,')>0
                                             THEN (ISNULL(B.VLPATVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                             ELSE 0 END),@Round),

          -- 20%    Pjesa e VLTVSH
             I_TVSHVEND     = ROUND(SUM(CASE WHEN CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SEXP,SAGJ,SANG,SBKQ,')<=0
                                             THEN (ISNULL(B.VLTVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                             ELSE 0 END),@Round),
             K_TVSHAGJ      = ROUND(SUM(CASE WHEN CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SAGJ,')>0
                                             THEN (ISNULL(B.VLTVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                             ELSE 0 END),@Round),
             LL_TVSHANG     = ROUND(SUM(CASE WHEN CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SANG,')>0
                                             THEN (ISNULL(B.VLTVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                             ELSE 0 END),@Round),
             N_TVSHBKQ      = ROUND(SUM(CASE WHEN CHARINDEX(','+ISNULL(A.KLASETVSH,'SVND')+',',',SBKQ,')>0
                                             THEN (ISNULL(B.VLTVSH,0)*ISNULL(A.KURS2,1))/ISNULL(A.KURS1,1)
                                             ELSE 0 END),@Round),
*/
             VLERZBR        = CAST(0 AS REAL),
             LIBERNR        = MAX(CASE WHEN ISNULL(ISDG,0)=1
                                       THEN NRDOKDG
                                       ELSE NRDSHOQ
                                       END),
             LIBERDT        = MAX(CASE WHEN ISNULL(ISDG,0)=1
                                       THEN DTDOKDG
                                       ELSE DTDSHOQ
                                       END)
        FROM FJ A INNER JOIN FJSCR B         ON A.NRRENDOR=B.NRD
                  LEFT  JOIN KLIENT R1       ON A.KODFKL=R1.KOD AND A.DATEDOK>=DBO.DATEVALUE(@DtUser)
                  INNER JOIN DRHReference R2 ON R1.KOD=R2.KOD   AND R2.REFERENCE=@TableRefK AND R2.KODUS=@User
       WHERE 1=1

    GROUP BY A.NRRENDOR

           ) A


          if Exists (SELECT 1
                       FROM #LiberTMP
                      WHERE X_MSGERROR1<>'' OR X_MSGERROR2<>'')
             Set @ErrorMsg = 'Te dhenat me probleme';

      SELECT A.*,
             ERRORVL  = CASE WHEN ABS(X_VLERROR1)<=@StepError THEN '' ELSE CAST(X_VLERROR1 AS VARCHAR) END,
             ERRORMSG = @ErrorMsg,
             PERIUDHE = Right('00'+CAST(MUAJ AS VARCHAR),2)+' - '+CAST(VIT AS VARCHAR),
             B.PERSHKRIM
        FROM #LiberTmp  A LEFT JOIN CONFIG..TIPDOK B ON A.MUAJ=B.KOD AND B.TIPDOK='Z'
       WHERE (3=3)
    ORDER BY LIBERDT,RIGHT('00000000000000000000'+LIBERNR,20)


          if Object_Id('TempDB..#LiberTmp') is not null
             DROP TABLE #LiberTmp;
GO
