SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- Exec dbo.Isd_TestSasiMg 0.01, 0.03, 0, '01/01/2017', '31/12/2017', 'KMAG=''PG1'''

CREATE        Procedure [dbo].[Isd_TestSasiMg]
( 
  @PLimitSasi   Float,
  @PLimitVlere  Float,
  @PGlobal      Int,
  @PDateKp      Varchar(20),
  @PDateKs      Varchar(20),
  @PWhere       Varchar(Max)
 )
As

-- Ne se nuk duhen vlerat atehere  perdor @PLimitVlere = 999999999 
-- ose kur do vetem vlerat jo sasi perdor @LimitSasi   = 999999999

        Set NoCount On

     Declare @LimitSasi    Float,
             @LimitVlere   Float,
             @Global       Int,
             @sWhere       nVarchar(Max),
             @sSql         nVarchar(Max),
             @sDateKp      Varchar(20),
             @sDateKs      Varchar(20),
             @DateKp       DateTime,
             @DateKs       DateTime;


         Set @LimitSasi  = @PLimitSasi;
         Set @LimitVlere = @PLimitVlere;
         Set @Global     = @PGlobal;
         Set @sWhere     = @PWhere;

         Set @sDateKp    = @PDateKp;
         Set @sDateKs    = @PDateKs;

          if Object_Id('TEMPDB..#LEVHD') is not null
             DROP TABLE #LEVHD;

      SELECT DATEDOK,
             KMAG,
             KARTLLG = Space(60),
             SASI    = CAST(0 As Float),
             VLERAM  = CAST(0 As Float),
             NR      = Cast(0 As Int)
        INTO #LEVHD
        FROM FH 
       WHERE 1=2;


          if @sDateKp = ''
             Set @sDateKp = Convert(Varchar,IsNull((Select Min(DATEDOK) From LevizjeHD),GetDate()),103);
         Set @DateKp = dbo.DateValue(@sDateKp);


          if @sDateKs = ''
             Set @sDateKs = Convert(Varchar,IsNull((Select Max(DATEDOK) From LevizjeHD),GetDate()),103);
         Set @DateKs = dbo.DateValue(@sDateKs);
         
         

--Print @sDateKp;

    Set @sSql = '

      INSERT INTO #LEVHD

      SELECT DATEDOK,
             KMAG,
             KARTLLG,
             SASI   = ROUND(SUM(SASI),2),
             VLERAM = ROUND(SUM(VLERAM),2),
             NR     = Row_Number() Over (Partition By KMAG,KARTLLG Order By KMAG,KARTLLG,DATEDOK)
        
        FROM
  (
      SELECT DATEDOK,
             KARTLLG,
             KMAG   = CASE WHEN '+Cast(@Global As Varchar)+'=1 THEN '''' ELSE KMAG END,
             SASI   = SUM(SASI),
             VLERAM = SUM(VLERAM)
        FROM FH A INNER JOIN FHSCR   B ON A.NRRENDOR=B.NRD
                  LEFT  JOIN ARTIKUJ C ON B.KARTLLG=C.KOD
                  LEFT  JOIN SKEMELM D ON C.KODLM=D.KOD
       WHERE (1=1) 
    GROUP BY CASE WHEN '+Cast(@Global As Varchar)+'=1 THEN '''' ELSE KMAG END, KARTLLG,DATEDOK
      HAVING ABS(SUM(SASI))>='+Cast(@LimitSasi As Varchar)+' OR ABS(SUM(VLERAM))>='+Cast(@LimitVlere As Varchar)+'

   UNION ALL 

      SELECT DATEDOK,
             KARTLLG,
             KMAG   = CASE WHEN '+Cast(@Global As Varchar)+'=1 THEN '''' ELSE KMAG END,
             SASI   = SUM(0-SASI),
             VLERAM = SUM(0-VLERAM)
        FROM FD A INNER JOIN FDSCR   B ON A.NRRENDOR=B.NRD
                  LEFT  JOIN ARTIKUJ C ON B.KARTLLG=C.KOD
                  LEFT  JOIN SKEMELM D ON C.KODLM=D.KOD
       WHERE (1=1) 
    GROUP BY CASE WHEN '+Cast(@Global As Varchar)+'=1 THEN '''' ELSE KMAG END,KARTLLG,DATEDOK
      HAVING ABS(SUM(SASI))>='+Cast(@LimitSasi As Varchar)+' OR ABS(SUM(VLERAM))>='+Cast(@LimitVlere As Varchar)+'
    ) A 

    GROUP BY KMAG,KARTLLG,DATEDOK
      HAVING ABS(ROUND(SUM(SASI),2))>='+Cast(@LimitSasi As Varchar)+' OR ABS(ROUND(SUM(VLERAM),2))>='+Cast(@LimitVlere As Varchar)+'
    ORDER BY KMAG,KARTLLG,DATEDOK ';

          if @sDateKs<>''
             BEGIN
               if @sWhere<>''
                  BEGIN
                    SET @sWhere = @sWhere + ' AND (A.DATEDOK<=dbo.DateValue('''+@sDateKs+''')) ';
                  END
               else
                  BEGIN
                    SET @sWhere =               ' (A.DATEDOK<=dbo.DateValue('''+@sDateKs+''')) ';
                  END;
             END;
             
          if @sWhere<>''
             Set @sSql = Replace(@sSql,'(1=1)',@sWhere);

     --Print @sSql;      
       Exec (@sSql);

  -- Select * From #LEVHD Order By kmag,KARTLLG,DATEDOK

      SELECT A.KMAG,
             A.KOD,
             R.PERSHKRIM,
             A.DATEDOK,
--           A.DATESASI,
             SASI,
             VLERA    = A.VLERAM,
             R.NJESI,
             NRRENDOR = 0,
             TAGNR    = 0,
             TROW     = CAST(0 As Bit)
        FROM
      (
             SELECT KMAG,
                    KOD      = KARTLLG,
                    DATEDOK,
                    SASI     = ROUND(( SELECT SUM(SASI) 
                                         FROM #LEVHD B 
                                        WHERE B.KMAG=A.KMAG AND B.KARTLLG=A.KARTLLG AND B.NR<=A.NR
                                     GROUP BY B.KMAG,B.KARTLLG),2),
                    VLERAM   = ROUND(( SELECT SUM(VLERAM)
                                         FROM #LEVHD B
                                        WHERE B.KMAG=A.KMAG AND B.KARTLLG=A.KARTLLG AND B.NR<=A.NR
                                     GROUP BY B.KMAG,B.KARTLLG),2)--,
--                  DATESASI = (       SELECT MIN(DATEDOK)
--                                       FROM #LEVHD B
--                                      WHERE B.KMAG=A.KMAG AND B.KARTLLG=A.KARTLLG AND B.NR>A.NR AND B.SASI>=0
--                                   GROUP BY B.KMAG,B.KARTLLG)               
               FROM #LEVHD A
        
        )  A    
        
              LEFT JOIN ARTIKUJ R ON A.KOD=R.KOD
      
       WHERE (ABS(SASI)>=@LimitSasi  OR  ABS(VLERAM)>=@LimitVlere) And 
             (A.SASI<0               OR  A.VLERAM<0)               And
             (A.DATEDOK>=@DateKp    AND  A.DATEDOK<=@DateKs)
             
    ORDER BY A.KMAG,A.KOD,A.DATEDOK;
GO
