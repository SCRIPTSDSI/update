SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



--Declare @PWhere Varchar(Max);
--    Set @PWhere = '(KODFKL>=''A'' AND KODFKL<=''z'') AND (DATEDOK>=DBO.DATEVALUE(''01/01/2013'')) AND (DATEDOK<=DBO.DATEVALUE(''31/01/2013''))';
--Exec [Isd_ReportLShFt] @PWhere=@PWhere,@PUser ='ADMIN',@PFormatRp=1
-- E pa futur akoma ....

CREATE Procedure [dbo].[Isd_ReportLShFt]
(
  @PWhere     Varchar(Max),
  @PUser      Varchar(50),
  @PFormatRp  Int
 )
as


-- Fut edhe Isd_ReportLShLM Per ne Liber te Madh

       Set NoCount On


  Declare @User      VarChar(30),
          @TableRefK VarChar(50),
          @TableD    VarChar(30),
          @DtUser    VarChar(20),
          @TableLink VarChar(50),
          @FormatRp  Int;

      Set @TableRefK = 'KLIENT'
      Set @TableD    = 'FJ'
    --Set @User      = '101USER101'
      Set @User      = @PUser
      Set @DtUser    = Dbo.DRHDateKP(@User,@TableD)
      Set @TableLink = 'FJ'

    --Set @FormatRp  = 1;
      Set @FormatRp  = @PFormatRp;



  Declare @Nipt        Varchar(20),
          @Pershkrim   Varchar(100),
          @StepError   Float,
          @Sql         Varchar(Max)

   Select @Nipt      = NIPT,
          @Pershkrim = PERSHKRIM,
          @StepError = IsNull(STEPERRORLSH,1)
     FROM CONFND;
	      

       if Object_Id('TempDB..#LiberTmp') is not null
          DROP TABLE #LiberTmp;
       if Object_Id('TempDB..#LiberFtTmp') is not null
          DROP TABLE #LiberFtTmp;

   


   SELECT NRRENDOR=0
     INTO #LiberFtTmp
     FROM FJ
    WHERE 1=2 


  Set @Sql = '   

   INSERT INTO #LiberFtTmp
         (NRRENDOR)
   SELECT NRRENDOR
     FROM FJ A
    WHERE 1=1 
 ORDER BY NRRENDOR '

       if @Sql<>''
          Set @Sql = Replace(@Sql,'1=1',@PWhere);
   --Print @Sql
     Exec (@Sql)

   CREATE INDEX IdLiberFtTmp ON #LiberFtTmp(NRRENDOR);


   SELECT A.NIPT,
          A.KODFISKAL,
          A.SHENIM1,
          A.NRSERIAL,
          A.RRETHI,
          A.DATEDOK,
          MUAJ           = MONTH(DATEDOK),
          VIT            = YEAR(DATEDOK),
          PERIUDHE       = CAST(MONTH(DATEDOK) AS VARCHAR)+CAST(YEAR(DATEDOK) AS VARCHAR),
          A.NRRENDOR,
          R3.PERSHKRIM,
          A.KLASIFIKIM,

          H_TOTPATVSH    = CASE WHEN ISDG=0    AND VLTVSH=0    THEN VLPATVSH           ELSE 0 END,
          I_VLTOTEXP     = CASE WHEN ISDG=1                    THEN VLPATVSH           ELSE 0 END,
        --I_VLTOTEXP     = CASE WHEN ISDG=1    AND VLTVSH=0    THEN VLERTOT            ELSE 0 END,

          J_FATMETVSH20  = CASE WHEN ISDG=0    AND VLTVSH<>0 AND PERQTVSH=20 THEN VLPATVSH - VLERZBR ELSE 0 END,
          K_VLTVSH20     = CASE WHEN ISDG=0    AND VLTVSH<>0 AND PERQTVSH=20 THEN VLTVSH             ELSE 0 END,

          J_FATMETVSH10  = CASE WHEN ISDG=0    AND VLTVSH<>0 AND PERQTVSH=10 THEN VLPATVSH - VLERZBR ELSE 0 END,
          K_VLTVSH10     = CASE WHEN ISDG=0    AND VLTVSH<>0 AND PERQTVSH=10 THEN VLTVSH             ELSE 0 END,

          G_TOTAL        = VLPATVSH - VLERZBR + VLTVSH,
          G_TOTALTVSH    = VLTVSH,

          A.ISDG,
          A.LIBERNR,
          A.LIBERDT,
          NIPTND         = @Nipt,
          PERSHKRIMND    = @Pershkrim,
          PERQTVSH,
          MASTERGROUP    = '',
          MASTERTABLE    = @TableLink,
          MASTERFIELD    = 'NRRENDOR',
          MASTERNR       = A.NRRENDOR

     INTO #LiberTmp

     FROM
  (
   SELECT NIPT           = MAX(ISNULL(A.NIPT,'')),
          KODFISKAL      = MAX(ISNULL(A.KODFISKAL,'')),
          SHENIM1        = MAX(CASE WHEN ISNULL(R1.EMERTIMLB,'')='' THEN ISNULL(A.SHENIM1,'') ELSE R1.EMERTIMLB END),
          KODFKL         = MAX(ISNULL(A.KODFKL,'')),
          KMON           = MAX(ISNULL(A.KMON,'')),
          NRSERIAL       = MAX(ISNULL(A.NRSERIAL,'')),
          RRETHI         = MAX(ISNULL(A.RRETHI,'')),
          KMAG           = MAX(ISNULL(A.KMAG,'')),
          DATEDOK        = MAX(ISNULL(A.DATEDOK,'')),
          NRDOK          = MAX(ISNULL(A.NRDOK,'')),
          A.NRRENDOR,
          KLASIFIKIM     = MAX(ISNULL(KLASIFIKIM,'')),
          ISDG           = MAX(CASE WHEN ISNULL(A.ISDG,0)=1 THEN 1 ELSE 0 END),
          NRDOKDG        = MAX(ISNULL(A.NRDOKDG,'')),
          DTDOKDG        = MAX(A.DTDOKDG),
          DTDSHOQ        = MAX(A.DTDSHOQ),
          NRDSHOQ        = MAX(ISNULL(A.NRDSHOQ,'')),
          ISDOKSHOQ      = MAX(CASE WHEN ISNULL(A.ISDOKSHOQ,0)=1 THEN 1 ELSE 0 END),
          VLPATVSH       = ROUND(SUM((ISNULL(B.VLPATVSH,0)*ISNULL(KURS2,1))/ISNULL(KURS1,1)),2),
          VLTVSH         = ROUND(SUM((ISNULL(B.VLTVSH,0)  *ISNULL(KURS2,1))/ISNULL(KURS1,1)),2),
          VLERZBR        = 0,
        --VLERTOT        = ROUND(SUM((ISNULL(B.VLERABS,0) *KURS2)/KURS1),2),
          PERQTVSH       = CASE WHEN ROUND((CASE WHEN ISNULL(B.VLPATVSH,0)<>0 THEN ISNULL(B.VLTVSH,0)/B.VLPATVSH*100 ELSE 0 END),0)<=5 THEN 0  -- 20
                                WHEN ROUND((CASE WHEN ISNULL(B.VLPATVSH,0)<>0 THEN ISNULL(B.VLTVSH,0)/B.VLPATVSH*100 ELSE 0 END),0)>15 THEN 20
                                ELSE 10 END,
          LIBERNR        = MAX(CASE WHEN ISNULL(ISDG,0)=1 THEN ISNULL(NRDOKDG,'') ELSE ISNULL(NRDSHOQ,'') END),
          LIBERDT        = MAX(CASE WHEN ISNULL(ISDG,0)=1 THEN ISNULL(DTDOKDG,0)  ELSE ISNULL(DTDSHOQ,0) END)
     FROM FJ A INNER JOIN #LiberFtTmp A1  ON A.NRRENDOR=A1.NRRENDOR
               INNER JOIN FJSCR B         ON A.NRRENDOR=B.NRD
               LEFT  JOIN KLIENT R1       ON A.KODFKL=R1.KOD AND A.DATEDOK>=DBO.DATEVALUE(@DtUser)
               INNER JOIN DRHReference R2 ON R1.KOD=R2.KOD   AND R2.REFERENCE=@TableRefK AND R2.KODUS=@User
--  WHERE 1=1
 GROUP BY A.NRRENDOR, CASE WHEN ROUND((CASE WHEN ISNULL(B.VLPATVSH,0)<>0 THEN ISNULL(B.VLTVSH,0)/B.VLPATVSH*100 ELSE 0 END),0)<=5 THEN 0  -- 20
                           WHEN ROUND((CASE WHEN ISNULL(B.VLPATVSH,0)<>0 THEN ISNULL(B.VLTVSH,0)/B.VLPATVSH*100 ELSE 0 END),0)>15 THEN 20
                           ELSE 10 END
        ) A
              LEFT  JOIN TIPDOK R3       ON CAST(MONTH(A.DATEDOK) AS VARCHAR)=R3.KOD

    WHERE R3.TIPDOK='Z'

 ORDER BY A.LIBERDT,RIGHT('00000000000000000000'+LIBERNR,20)


       if @FormatRp<>0

		      begin
          --Print 'A'
            SELECT NIPT           = MAX(A.NIPT),
                   KODFISKAL      = MAX(A.KODFISKAL),
                   SHENIM1        = MAX(A.SHENIM1),
                   NRSERIAL       = MAX(A.NRSERIAL),
                   RRETHI         = MAX(A.RRETHI),
                   DATEDOK        = MAX(A.DATEDOK),
                   MUAJ           = MAX(A.MUAJ),
                   VIT            = MAX(A.VIT),
                   PERIUDHE       = MAX(A.PERIUDHE),
                   A.NRRENDOR,
                   PERSHKRIM      = MAX(A.PERSHKRIM),
                   KLASIFIKIM     = MAX(A.KLASIFIKIM),

                   H_TOTPATVSH    = SUM(A.H_TOTPATVSH),
                   I_VLTOTEXP     = SUM(A.I_VLTOTEXP),

                   J_FATMETVSH20  = SUM(A.J_FATMETVSH20),
                   K_VLTVSH20     = SUM(A.K_VLTVSH20),

                   J_FATMETVSH10  = SUM(A.J_FATMETVSH10),
                   K_VLTVSH10     = SUM(A.K_VLTVSH10),

                   G_TOTAL        = SUM(A.G_TOTAL),

                -- Export dhe TVSH !?
                   ERROR_EXP      = CASE WHEN MAX(A.ISDG)=1  AND ROUND(SUM(A.G_TOTALTVSH),2)<>0
                                         THEN 1
                                         ELSE 0 END,
                -- ??
                   ERROR_20       = CASE WHEN (ROUND(SUM(A.K_VLTVSH20),2)<>0    AND ROUND(SUM(A.J_FATMETVSH20),2)=0) OR
                                              (ROUND(SUM(A.J_FATMETVSH20),2)<>0 AND ROUND(SUM(A.K_VLTVSH20),2)=0)
                                         THEN 1
                                         WHEN ABS(CASE WHEN ROUND(100*SUM(A.K_VLTVSH20)*SUM(A.J_FATMETVSH20),2)<>0
                                                       THEN ROUND(100*SUM(A.K_VLTVSH20)/SUM(A.J_FATMETVSH20),2) - 20
                                                       ELSE 0 END)>=@StepError
                                         THEN 1
                                         ELSE 0 END,
                -- ??
                   ERROR_10       = CASE WHEN (ROUND(SUM(A.K_VLTVSH10),2)<>0    AND ROUND(SUM(A.J_FATMETVSH10),2)=0) OR
                                              (ROUND(SUM(A.J_FATMETVSH10),2)<>0 AND ROUND(SUM(A.K_VLTVSH10),2)=0)
                                         THEN 1
                                         WHEN ABS(CASE WHEN ROUND(100*SUM(A.K_VLTVSH10)*SUM(A.J_FATMETVSH10),2)<>0
                                                       THEN ROUND(100*SUM(A.K_VLTVSH10)/SUM(A.J_FATMETVSH10),2) - 10
                                                       ELSE 0 END)>=@StepError
                                         THEN 1
                                         ELSE 0 END,

                -- Error Rishperndarje
                   ERROR_TOT      = CASE WHEN ABS( SUM(A.G_TOTAL - (A.H_TOTPATVSH  +A.I_VLTOTEXP +
                                                                    A.J_FATMETVSH20+A.K_VLTVSH20 +
                                                                    A.J_FATMETVSH10+A.K_VLTVSH10)) ) >= 2
                                         THEN 1
                                         ELSE 0 END,

                -- Error Rishperndarje TVSH
                   ERROR_TVSH     = CASE WHEN ABS( SUM(A.G_TOTALTVSH - (A.K_VLTVSH20 + A.K_VLTVSH10)) ) >= 2
                                         THEN 1
                                         ELSE 0 END,

                   LIBERNR        = MAX(A.LIBERNR),
                   LIBERDT        = MAX(A.LIBERDT),
                   NIPTND         = MAX(A.NIPTND),
                   PERSHKRIMND    = MAX(A.PERSHKRIMND),
                   MASTERGROUP    = '',
                   MASTERTABLE    = @TableLink,
                   MASTERFIELD    = 'NRRENDOR',
                   MASTERNR       = A.NRRENDOR

              FROM #LiberTmp A
          GROUP BY A.NRRENDOR
          ORDER BY MAX(LIBERDT),RIGHT('00000000000000000000'+MAX(LIBERNR),20)

		      end;



       if @FormatRp=0
          begin

            SELECT *,
                -- Export dhe TVSH !?
                   ERROR_EXP      = CASE WHEN A.ISDG=1  AND ROUND(A.G_TOTALTVSH,2)<>0
                                         THEN 1
                                         ELSE 0 END,
                -- ??
                   ERROR_20       = CASE WHEN (ROUND(A.K_VLTVSH20,2)<>0    AND ROUND(A.J_FATMETVSH20,2)=0) OR
                                              (ROUND(A.J_FATMETVSH20,2)<>0 AND ROUND(A.K_VLTVSH20,2)=0)
                                         THEN 1
                                         WHEN ABS(CASE WHEN ROUND(100*A.K_VLTVSH20*A.J_FATMETVSH20,2)<>0
                                                       THEN ROUND(100*A.K_VLTVSH20/A.J_FATMETVSH20,2) - 20
                                                       ELSE 0 END)>=@StepError
                                         THEN 1
                                         ELSE 0 END,
                -- ??
                   ERROR_10       = CASE WHEN (ROUND(A.K_VLTVSH10,2)<>0    AND ROUND(A.J_FATMETVSH10,2)=0) OR
                                              (ROUND(A.J_FATMETVSH10,2)<>0 AND ROUND(A.K_VLTVSH10,2)=0)
                                         THEN 1
                                         WHEN ABS(CASE WHEN ROUND(100*A.K_VLTVSH10*A.J_FATMETVSH10,2)<>0
                                                       THEN ROUND(100*A.K_VLTVSH10/A.J_FATMETVSH10,2) - 10
                                                       ELSE 0 END)>=@StepError
                                         THEN 1
                                         ELSE 0 END,

                 -- Error Rishperndarje
                   ERROR_TOT      = CASE WHEN ABS( A.G_TOTAL - (A.H_TOTPATVSH  +A.I_VLTOTEXP +
                                                                A.J_FATMETVSH20+A.K_VLTVSH20 +
                                                                A.J_FATMETVSH10+A.K_VLTVSH10) ) >= 2
                                         THEN 1
                                         ELSE 0 END,

                 -- Error Rishperndarje TVSH
                   ERROR_TVSH     = CASE WHEN ABS( A.G_TOTALTVSH - (A.K_VLTVSH20 + A.K_VLTVSH10) ) >= 2
                                         THEN 1
                                         ELSE 0 END

              FROM #LiberTmp A
          ORDER BY LIBERDT,RIGHT('00000000000000000000'+LIBERNR,20),PERQTVSH

          end;


       if Object_Id('TempDB..#LiberTmp') is not null
          DROP TABLE #LiberTmp;

   --DROP INDEX IdLiberFtTmp ON #LiberFtTmp;
       if Object_Id('TempDB..#LiberFtTmp') is not null
          DROP TABLE #LiberFtTmp;



GO
