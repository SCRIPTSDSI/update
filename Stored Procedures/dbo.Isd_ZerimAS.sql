SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--  Declare @PDate       Varchar(20), @PLlogari    Varchar(50), @PKoment     Varchar(500), @PWhere      Varchar(Max),
--          @PIndex      Int,         @POper       Int,         @PNrDok      Int,          @PNrRendor   Int;

--      Set @PDate     = dbo.DateValue('01/06/2013');
--      Set @PLlogari  = '121';
--      Set @PKoment   = 'AAAA';
--      Set @PWhere    = ' LLOGARI.KOD>=''6'' AND LLOGARI.KOD<''8'' ';
--   Select @PIndex=0, @POper=0, @PNrDok=0, @PNrRendor=0;
-- Exec dbo.Isd_ZerimAS @PDate=@PDate,@PLlogari=@PLlogari,@PKoment=@PKoment,@PWhere=@PWhere,@PIndex=@PIndex,@POper=@POper,@PNrDok=@PNrDok Output,@PNrRendor=@PNrRendor Output;

CREATE   Procedure [dbo].[Isd_ZerimAS]
( 
  @pDate       Varchar(20),
  @pLlogari    Varchar(50),
  @pKoment     Varchar(200),
  @pWhere      Varchar(Max),
  @pIndex      Int,
  @pOrder      Varchar(10),              -- 'ML'  Monedhe-llogari,   'LM'  Llogari-monedhe,  'GM'  Grup-monedhe
  @pOper       Int,
  @pNrDok      Int Output,
  @pNrRendor   Int Output
 )
 
AS  



        SET NOCOUNT ON;



        IF  EXISTS (SELECT [Name] FROM TempDb.Sys.Objects WHERE [Name]='#ZerimAS' and [Type]='U')
            DROP TABLE #ZerimAS;
            
            

      SELECT KOD       = Replicate(' ',60),
             LLOGARI   = Replicate(' ',60),
             LLOGARIPK = Replicate(' ',60),
             PERSHKRIM = Replicate(' ',200),
             KOMENT    = Replicate(' ',60),
             DB        = Cast(0 As Float),
             KR        = Cast(0 As Float),
             DBKRMV    = Cast(0 As Float),
             TREGDK    = Replicate(' ',10),
             KMON      = Replicate(' ',10),
             KURS1     = Cast(1 As Float),
             KURS2     = Cast(1 As Float),
             ORDPOST   = 0,
             NRRENDOR  = 0,
             TROW      = CAST(0 As Bit)
        INTO #ZerimAS
       WHERE 1=2;


     Declare @Sql        Varchar(MAX),
             @Fields     Varchar(500),
             @Groups     Varchar(500),
             @sOrder     Varchar(10),
             @sOrder1    Varchar(200);


         SET @sOrder   = ISNULL(@pOrder,'ML');
         SET @sOrder1  = 'KMON,KOD';
         
         IF  @sOrder='LM'
             BEGIN
               SET @sOrder1 = 'KOD,KMON'
             END
         ELSE
         IF  @sOrder='GM'
             BEGIN
               SET @sOrder1 = 'SUBSTRING(KOD,1,1),KMON,KOD'
             END;  
             
                

         SET @Fields   = '';
         SET @Groups   = '';
         SET @Sql      = '


      SELECT KOD       = dbo.Isd_SegmentsToKodLM(MAX(FKSCR.KOD),'''',0),
             LLOGARI   = dbo.Isd_SegmentsToKodAF(MAX(FKSCR.KOD)),
             LLOGARIPK = Dbo.Isd_SegmentFind(MAX(FKSCR.KOD),0,1),
             PERSHKRIM = MAX(LM.PERSHKRIM),
             KOMENT    = '''+@PKoment+''',
             DB        = ROUND(CASE WHEN (ISNULL(SUM(DB-KR),0)<=0) THEN 0-ISNULL(SUM(DB-KR),0) ELSE 0 END,3),
             KR        = ROUND(CASE WHEN (ISNULL(SUM(DB-KR),0)>=0) THEN   ISNULL(SUM(DB-KR),0) ELSE 0 END,3),
             DBKRMV    = ROUND(0-ISNULL(SUM(DBKRMV),0),3),
             TREGDK    = CASE WHEN ROUND(0-ISNULL(SUM(DBKRMV),0),3)>=0 THEN ''D'' ELSE ''K'' END,
             KMON      = MAX(FKSCR.KMON),
             KURS1     = ISNULL(MAX(MONEDHA.KURS1),1),
             KURS2     = ISNULL(MAX(MONEDHA.KURS2),1),
             ORDPOST   = 0,
             NRRENDOR  = 0,
             TROW      = CAST(0 AS BIT)
        FROM FK LEFT JOIN FKSCR   ON FK.NRRENDOR=FKSCR.NRD
                LEFT JOIN LM      ON FKSCR.KOD=LM.KOD
                LEFT JOIN MONEDHA ON FKSCR.KMON=MONEDHA.KOD
                LEFT JOIN LLOGARI ON FKSCR.LLOGARIPK=LLOGARI.KOD
       WHERE (1=1)
    GROUP BY FKSCR.KOD
      HAVING (ABS(SUM(DB-KR))>=0.01) OR (ABS(SUM(DBKRMV))>=0.01)

   UNION ALL

      SELECT KOD       = dbo.Isd_SegmentsToKodLM(''DIF'','''',1),
             LLOGARI   = dbo.Isd_SegmentsToKodAF(''DIF''),
             LLOGARIPK = '''+@PLlogari+''',
             PERSHKRIM = '''+@PKoment +''',
             KOMENT    = '''+@PKoment +''',
             DB        = ROUND(CASE WHEN ISNULL(SUM(DBKRMV),0)>=0 THEN   ISNULL(SUM(DBKRMV),0) ELSE 0 END,3),
             KR        = ROUND(CASE WHEN ISNULL(SUM(DBKRMV),0) <0 THEN 0-ISNULL(SUM(DBKRMV),0) ELSE 0 END,3),
             DBKRMV    = ROUND(ISNULL(SUM(DBKRMV),0),3),
             TREGDK    = CASE WHEN ROUND(0-ISNULL(SUM(DBKRMV),0),3)>=0 THEN ''D'' ELSE ''K'' END,
             KMON      = '''',
             KURS1     = 1,
             KURS2     = 1,
             ORDPOST   = 1,
             NRRENDOR  = 0,
             TROW      = CAST(1 AS BIT)
        FROM FK LEFT JOIN FKSCR   ON FK.NRRENDOR=FKSCR.NRD
                LEFT JOIN LM      ON FKSCR.KOD=LM.KOD
                LEFT JOIN LLOGARI ON FKSCR.LLOGARIPK=LLOGARI.KOD
       WHERE (1=1)
    GROUP BY KMON
      HAVING ABS(SUM(DB-KR))>=0.01 OR ABS(SUM(DBKRMV))>=0.01 ';
--  ORDER BY TROW, KMON, KOD '


          IF @PIndex = 1 
             BEGIN
               SET @Fields =    '+''.''+ISNULL(LM.SG2,'''') ';
               SET @Groups = ' GROUP BY ISNULL(LM.SG2,'''') ';
             END;

          IF @PIndex = 2 
             BEGIN
               SET @Fields =    '+''.''+ISNULL(LM.SG2,'''')+''.''+ISNULL(LM.SG3,'''') ';
               SET @Groups = ' GROUP BY ISNULL(LM.SG2,''''),ISNULL(LM.SG3,'''') ';
             END;

          IF @PIndex = 3 
             BEGIN
               SET @Fields =    '+''.''+ISNULL(LM.SG2,'''')+''.''+ISNULL(LM.SG3,'''')+''.''+ISNULL(LM.SG4,'''') ';
               SET @Groups = ' GROUP BY ISNULL(LM.SG2,''''),ISNULL(LM.SG3,''''),ISNULL(LM.SG4,'''') ';
             END;
             
          SET @Fields = ''''+@PLlogari+''''+@Fields;


          SET @Sql = REPLACE (@Sql,'''DIF''',      @Fields);
          SET @Sql = REPLACE (@Sql,'GROUP BY KMON',@Groups);
          IF  @PWhere<>''''
              SET @Sql = REPLACE (@Sql,'(1=1)',    @PWhere);

          SET @Sql = '

    INSERT INTO #ZerimAS 
          (KOD,LLOGARI,LLOGARIPK,PERSHKRIM,KOMENT,DB,KR,DBKRMV,TREGDK,KMON,KURS1,KURS2,ORDPOST,TROW,NRRENDOR)
    SELECT KOD,LLOGARI,LLOGARIPK,PERSHKRIM,KOMENT,
           DB     = CAST(ROUND(DB,3)     AS REAL),
           KR     = CAST(ROUND(KR,3)     AS REAL),
           DBKRMV = CAST(ROUND(DBKRMV,3) AS REAL),
           TREGDK,KMON,KURS1,KURS2,ORDPOST,TROW,NRRENDOR
      FROM 
          ('+@Sql+'
          ) A ';

       PRINT  @Sql;
        EXEC (@Sql);



-- U Shtua me vone por te kontrollohet per saktesi 27.7.2019

      UPDATE #ZerimAS SET DB=ROUND(CAST(DB AS REAL),3),KR=ROUND(CAST(KR AS REAL),3),DBKRMV=ROUND(CAST(DBKRMV AS REAL),3);
  

    IF @POper=0
    
       BEGIN             -- Fillim Diaplay
       
          SET  @Sql = ' 
          SELECT KOD,LLOGARI,LLOGARIPK,PERSHKRIM,KOMENT,
                 DB     = ROUND(CAST(DB     AS REAL),3),
                 KR     = ROUND(CAST(KR     AS REAL),3),
                 DBKRMV = ROUND(CAST(DBKRMV AS REAL),3),
                 TREGDK,KMON,KURS1,KURS2,ORDPOST,TROW,NRRENDOR 
            FROM #ZerimAS 
        ORDER BY TROW, ' + @sOrder1+'; '
          PRINT @Sql;
         EXEC (@Sql);
         
         RETURN          -- Fund Display

       END;



-- Kalimi ne Baze

            SET @PNrDok = ISNULL(( SELECT MAX(ISNULL(B.NRDOK,0)) 
                                     FROM FK B 
                                    WHERE B.ORG='T' And YEAR(B.DATEDOK)=YEAR(DBO.DATEVALUE(@PDate))),0) + 1;

        DECLARE @NrD INT;

         INSERT INTO FK
               (NRDOK,DATEDOK,PERSHKRIM1,PERSHKRIM2,NUMDOK,TIPDOK,ORG,DST, REFERDOK)

         SELECT NRDOK      = @PNrDok,
                DATEDOK    = DBO.DATEVALUE(@PDate),
                PERSHKRIM1 = @PKoment,
                PERSHKRIM2 = '', 
                NUMDOK     = @PNrDok,
                TIPDOK     = 'DP',
                ORG        = 'T',
                DST        = 'AS',
                REFERDOK   = 'Mbyllje'
--              USI        = 'A'   
--              USM        = 'A'
            SET @NrD = @@IDENTITY

         UPDATE FK
            SET NRDFK       = @NrD,
              --NUMDOK      = NRDOK,
              --@PNrDok     = NRDOK,
                KODNENDITAR = '',
                KMAG        = '',
                KLASIFIKIM  = '',
                KMON        = '',
                KURS1       = 1,
                KURS2       = 1,
                POSTIM      = 0,
                LETER       = 0,
                TROW        = 0,
                TAGNR       = 0,
                FIRSTDOK    = ''
          WHERE NRRENDOR    = @NrD;


         INSERT INTO FKSCR 
               (NRD, KOD,LLOGARI,LLOGARIPK,PERSHKRIM,KOMENT,DB,KR,DBKRMV,TREGDK,KMON,KURS1,KURS2,
                FAKLS,FADESTIN,FAART,KODREF,TIPKLLREF,ORDPOST,ORDERSCR,TROW,TAGNR,TAG)
         SELECT @NrD,KOD,LLOGARI,LLOGARIPK,PERSHKRIM,KOMENT,
                DB     = ROUND(CAST(DB     AS REAL),3),
                KR     = ROUND(CAST(KR     AS REAL),3),
                DBKRMV = ROUND(CAST(DBKRMV AS REAL),3),
                TREGDK,KMON,KURS1,KURS2,
                '','','','','',0,0,0,0,0
           FROM #ZerimAS
       ORDER BY TROW, KMON, KOD; 


            Set @PNrRendor = @NrD;


--PRINT @Nrd
GO
