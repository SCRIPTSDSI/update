SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE         procedure [dbo].[Isd_DitarSistemim]
(
  @pTableName     Varchar(30),
  @pDocument      Varchar(30), 
  @pNdName        Varchar(30),
  @pTableTmp      Varchar(30),
  @pKoment        Varchar(200),
  @pWhereKod      Varchar(MAX),
  @pWhereGj       Varchar(MAX),
  @pAppendRows    Bit,
  @pInversVlere   Bit,
  @pInversPozic   Bit,
  @pAnalitikLM    Bit--,  @pKlientAgjent  Bit
)

As

-- EXEC dbo.Isd_DitarSistemim 'VS','S','EHW14','#AAAAA','Sistemim','','',1,0,0,1

         SET NOCOUNT ON;

     DECLARE @sSql            Varchar(MAX),
             @TableName       Varchar(30),
             @Document        Varchar(30),
             @NdName          Varchar(30),
             @TableTmp        Varchar(30),
             @Koment          Varchar(200),
             @AppendRows      Bit,
             @InversVlere     Bit,
             @InversPozic     Bit,
             @AnalitikLM      Bit,
          -- @KlientAgjent    Bit,
             @WhereKod        Varchar(MAX),
             @WhereGj         Varchar(MAX),
             @sSql1           Varchar(MAX);

         SET @TableName     = @pTableName;
         SET @Document      = @pDocument;
         SET @TableTmp      = @pTableTmp;
         SET @Koment        = @pKoment;
         SET @WhereKod      = @pWhereKod;
         SET @WhereGj       = @pWhereGj;
         SET @AppendRows    = @pAppendRows;
         SET @InversVlere   = @pInversVlere;
         SET @InversPozic   = @pInversPozic;
         SET @AnalitikLM    = @pAnalitikLM;
      -- SET @KlientAgjent  = @pKlientAgjent;

         SET @NdName        = @pNdName;
         IF  @NdName<>''
             SET @NdName   = @NdName+'..';

         IF  @Document='L'
             SET @Document = 'T';


-- Rasti Ditaret S,F,A,B

         SET @sSql1 = '

      SELECT A.KOD,A.KMON,
             KODAF       = CASE WHEN CHARINDEX(''.'',A.KOD)>0
                                THEN SUBSTRING(A.KOD,1,CHARINDEX(''.'',A.KOD)-1)
                                ELSE A.KOD
                           END,
             KODREF      = CASE WHEN CHARINDEX(''.'',A.KOD)>0
                                THEN SUBSTRING(A.KOD,1,CHARINDEX(''.'',A.KOD)-1)
                                ELSE A.KOD
                           END,
             GJENDJE     = ROUND(SUM(CASE WHEN A.TREGDK=''D'' THEN A.VLEFTA   ELSE 0-A.VLEFTA   END),3),
             GJENDJEMV   = ROUND(SUM(CASE WHEN A.TREGDK=''D'' THEN A.VLEFTAMV ELSE 0-A.VLEFTAMV END),3),
             PERSHKRIM   = MAX(R1.PERSHKRIM)

        FROM DKL A LEFT JOIN KLIENT R1 ON R1.KOD = CASE WHEN CHARINDEX(''.'',A.KOD)>0
                                                        THEN SUBSTRING(A.KOD,1,CHARINDEX(''.'',A.KOD)-1)
                                                        ELSE A.KOD
                                                   END
       WHERE (1=1)
    GROUP BY A.KMON,A.KOD ';



--           Rasti Ditar LM 

         IF  @Document='T'            
             BEGIN

         --  Analitik: @AnalitikLM=1 athere referoju LM per pershkrimin

                SET @sSql1 = '

             SELECT B.KOD,
                    B.KMON,                                              -- Kujdes rastet kur B.LLOGARI e mbushur keq prandaj nisemi nga fusha KOD
                    KODAF       = dbo.Isd_SegmentsToKodAF(B.KOD),        -- B.LLOGARI, 
                    KODREF      = CASE WHEN CHARINDEX(''.'',B.KOD)>0
                                       THEN SUBSTRING(B.KOD,1,CHARINDEX(''.'',B.KOD)-1)
                                       ELSE B.KOD
                                  END,
                    GJENDJE     = ROUND(SUM(B.DB - B.KR),3),
                    GJENDJEMV   = ROUND(SUM(B.DBKRMV),3),
                    PERSHKRIM   = MAX(R1.PERSHKRIM)

               FROM FK A INNER JOIN FKSCR B ON A.NRRENDOR=B.NRD  
                         LEFT  JOIN LM R1   ON B.KOD=R1.KOD
              WHERE (1=1)
           GROUP BY B.KMON,B.KOD,B.LLOGARI ';


               IF @AnalitikLM=0       --       Jo Analitik, @AnalitikLM=0 athere referoju Llogari (Plan kontabel)

                  BEGIN

                    SET @sSql1 = '

             SELECT KOD         = B.LLOGARIPK+''....''+ISNULL(B.KMON,''''),
                    KMON        = ISNULL(B.KMON,''''),
                    KODAF       = B.LLOGARIPK,
                    KODREF      = B.LLOGARIPK,
                    GJENDJE     = ROUND(SUM(B.DB - B.KR),3),
                    GJENDJEMV   = ROUND(SUM(B.DBKRMV),3),
                    PERSHKRIM   = MAX(R1.PERSHKRIM)

               FROM FK A INNER JOIN FKSCR   B  ON A.NRRENDOR=B.NRD  
                         LEFT  JOIN LLOGARI R1 ON B.LLOGARIPK=R1.KOD
              WHERE (1=1)
           GROUP BY ISNULL(B.KMON,''''),B.LLOGARIPK';

                  END;

             END;





         SET @sSql = '

          IF OBJECT_ID(''TEMPDB..#DITARTMP'') IS NOT NULL
             BEGIN
               DROP TABLE #DITARTMP;
             END;


      SELECT A.KOD,
             A.KODAF,
             LLOGARIPK   = CASE WHEN CHARINDEX(''.'',A.KODAF)>0
                                THEN SUBSTRING(A.KODAF,1,CHARINDEX(''.'',A.KODAF)-1)
                                ELSE A.KODAF
                           END,
             LLOGARI     = A.KODAF,
             A.KMON,
             A.PERSHKRIM,
             KOMENT      = '''+@Koment+''',
             TIPKLL      = '''+@Document+''',
             DB          = 1*CASE WHEN GJENDJE>=0 THEN   GJENDJE ELSE 0   END,
             KR          = 1*CASE WHEN GJENDJE< 0 THEN 0-GJENDJE ELSE 0   END,
             DBKRMV      = 1*GJENDJEMV,
             TREGDK      = CASE WHEN GJENDJE>=0 THEN ''D''     ELSE ''K'' END,

             KURS1       = 1,
             KURS2       = CASE WHEN ISNULL(A.KMON,'''')='''' THEN CAST(1 AS FLOAT)
                                WHEN GJENDJE*GJENDJEMV>0  THEN ROUND(GJENDJEMV/GJENDJE,4) 
                                ELSE CAST(1 AS FLOAT)
                           END,
             ORDERSCR    = 0,
             NRDITAR     = 0

        INTO #DITARTMP

        FROM 

           ( '+@sSql1+ '


     )    A  

       WHERE (2=2) AND (GJENDJE<>0 OR GJENDJEMV<>0)   -- (ABS(GJENDJE)>0   AND ABS(GJENDJE)<=1) OR (ABS(GJENDJEMV)>0 AND ABS(GJENDJEMV)<=1)



          IF 1='+CAST(@InversPozic AS Varchar)+'
             BEGIN

               UPDATE #DITARTMP
                  SET KR = DB, DB = KR, DBKRMV = 0-DBKRMV,
                      TREGDK = CASE WHEN TREGDK=''D'' THEN ''K'' ELSE ''D'' END

             END;


          IF 0='+CAST(@AppendRows AS Varchar)+'
             BEGIN
               DELETE FROM '+@TableTmp+';      -- RRAB<>''K''  Kujdes Pyet @TableName=''ARKA''
             END;


      INSERT INTO '+@TableTmp+'
            (KOD,KODAF,LLOGARI,LLOGARIPK,KMON,PERSHKRIM,KOMENT,TIPKLL,DB,KR,DBKRMV,TREGDK,KURS1,KURS2,ORDERSCR)
      SELECT KOD,KODAF,LLOGARI,LLOGARIPK,KMON,PERSHKRIM,KOMENT,TIPKLL,DB,KR,DBKRMV,TREGDK,KURS1,KURS2,ORDERSCR
        FROM #DITARTMP
    ORDER BY KMON,KOD 


          IF OBJECT_ID(''TEMPDB..#DITARTMP'') IS NOT NULL
             BEGIN
               DROP TABLE #DITARTMP;
             END; ';


-- 1. Interpretimi sipas dokumenti destinacion(ku behet importi)

          IF @TableName='ARKA' Or @TableName='BANKA'
             BEGIN
               SET @sSql = Replace(@sSql,'DELETE FROM '+@TableTmp,'DELETE FROM '+@TableTmp+' WHERE RRAB<>''K'' ')
             END
          ELSE
          IF @TableName='FK'   Or @TableName='FKST'
             BEGIN
               SET @sSql = Replace(@sSql,'KOD,KODAF,LLOGARI,','KOD,LLOGARI,');
               SET @sSql = Replace(@sSql,'TIPKLL,','');
             END;

-- 2. Aplikimi i Filterave

          IF @WhereKod<>''
             BEGIN
               SET @sSql = Replace(@sSql,'(1=1)',@WhereKod);
             END;
          IF @WhereGj<>''
             BEGIN
               SET @sSql = Replace(@sSql,'(2=2)',@WhereGj);
             END;

          IF @InversVlere=1
             BEGIN
               SET @sSql = Replace(@sSql,' 1*',' -1*')
             END;

-- 3. Lidhje me Ditarin qe importohet

          IF @Document = 'S'
             BEGIN
               SET @sSql = Replace(@sSql,'KLIENT',@NdName+'KLIENT');
               SET @sSql = Replace(@sSql,'DKL',   @NdName+'DKL');
             END;
          IF @Document = 'F'
             BEGIN
               SET @sSql = Replace(@sSql,'KLIENT',@NdName+'FURNITOR');
               SET @sSql = Replace(@sSql,'DKL',   @NdName+'DFU');
             END;
          IF @Document = 'A'
             BEGIN
               SET @sSql = Replace(@sSql,'KLIENT',@NdName+'ARKAT');
               SET @sSql = Replace(@sSql,'DKL',   @NdName+'DAR');
             END;
          IF @Document = 'B'
             BEGIN
               SET @sSql = Replace(@sSql,'KLIENT',@NdName+'BANKAT');
               SET @sSql = Replace(@sSql,'DKL',   @NdName+'DBA');
             END;
          IF @Document = 'T'
             BEGIN
               SET @sSql = Replace(@sSql,' JOIN LLOGARI ',' JOIN '+@NdName+'LLOGARI ');
               SET @sSql = Replace(@sSql,' FKSCR ',  ' '+@NdName+'FKSCR ');
               SET @sSql = Replace(@sSql,' FK ',     ' '+@NdName+'FK ');
               SET @sSql = Replace(@sSql,' LM ',     ' '+@NdName+'LM ');
             END;


       PRINT @sSql;
       EXEC (@sSql);

 
GO
