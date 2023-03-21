SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Exec [Isd_ImportCeljeFK] 'EHW13', '26.07.2019', '01/08/2019', '', 'T', 1, 1, 0

CREATE      Procedure [dbo].[Isd_ImportCeljeFK]
( 
  @pdbOrigjine   Varchar(50),
  @pDateCls      Varchar(20),
  @pDateDoc      Varchar(20),
  @pWhere        Varchar(Max),
  @pModul        Varchar(10),
  @pZerim67      Int,
  @pZerimAS      Int,
  @pAnalitik     Int
 )
 
AS

         SET NOCOUNT ON;


--        IF DB_NAME() = @pdbOrigjine  -- Genti konstatim
--           RETURN                    -- Print 'Asgje'


     DECLARE @sdbOrigjine   Varchar(50),
             @sDateCls      Varchar(20),
             @sDateDoc      Varchar(20),
             @sWhere        Varchar(Max),
             @Analitik      Int,
             @Prompt        Varchar(150),
             @ListFields    Varchar(Max),
             @Sql           Varchar(Max),
             @LlgCelje      Varchar(30),
             @VlereDIF      Float,
             @NrD           Int;
          

          IF CHARINDEX(@pModul,'T')=0
             RETURN;

         SET @sdbOrigjine = @pdbOrigjine; 
         SET @sDateCls    = @pDateCls;
         SET @sDateDoc    = @pDateDoc;
         SET @sWhere      = @pWhere;
         SET @Analitik    = @pAnalitik;
         SET @Prompt      = 'Gjendje llogari: '+@sDateCls;



          IF OBJECT_ID('TEMPDB..#CELJEMLM') IS NOT NULL 
             DROP TABLE #CELJEMLM; 

      SELECT * INTO #CELJEMLM FROM VSSCR WHERE 1>2; 
   


         SET @Sql = ' 
                    INSERT INTO #CELJEMLM 
                          (KMON, KOD, DB, DBKRMV,PERSHKRIM) 
                    SELECT KMON = ISNULL(B.KMON,''''),
                           KOD  = B.KOD, 
                           VL   = SUM(B.DB - B.KR), 
                           VLMV = SUM(B.DBKRMV),
                           PRS  = MAX(B.PERSHKRIM) 
                      FROM '+@sdbOrigjine+'..FK A INNER JOIN '+@sdbOrigjine+'..FKSCR B On A.NRRENDOR=B.NRD
                                                  LEFT  JOIN LLOGARI C On B.LLOGARIPK=C.KOD
                     WHERE 1=1 
                  GROUP BY ISNULL(B.KMON,''''), B.KOD  
                    HAVING ABS(SUM(B.DB-B.KR))>=0.01 OR ABS(SUM(B.DBKRMV))>=0.01 
                  ORDER BY ISNULL(B.KMON,''''), B.KOD;';


          IF @sWhere<>''
             BEGIN
             
               SET @sWhere = REPLACE(@sWhere,'FK.',     'A.')
               SET @sWhere = REPLACE(@sWhere,'FKSCR.',  'B.')
               SET @sWhere = REPLACE(@sWhere,'LLOGARI.','C.')
               SET @Sql    = REPLACE(@Sql,'1=1',@sWhere)
               
             END
             
          ELSE
          
             BEGIN
             
            -- Genti Rasti kur vjen bosh dhe nuk i vinte kufizime.
               SET @sWhere = 'DATEDOK<=DBO.DATEVALUE('+QuoteName(@sDateCls,'''')+')'
               SET @Sql    = REPLACE(@Sql,'1=1',@sWhere) 
               
             END;
             
          IF @Analitik=0
             BEGIN
               SET @Sql = REPLACE(@Sql,'= B.KOD,','= B.LLOGARIPK+''....''+ISNULL(B.KMON,''''),');
               SET @Sql = REPLACE(@Sql,' B.KOD',' B.LLOGARIPK');
               SET @Sql = REPLACE(@Sql,'B.PERSHKRIM,','C.PERSHKRIM');
             END;

        EXEC (@Sql);



      UPDATE #CELJEMLM
         SET KOD    = dbo.Isd_SegmentsToKodLM(KOD,KMON,1),
             DB     = ROUND(CASE WHEN DB>=0 THEN DB   ELSE 0   END,3),
             KR     = ROUND(CASE WHEN DB< 0 THEN 0-DB ELSE 0   END,3), 
             DBKRMV = ROUND(DBKRMV,3),
             TREGDK =       CASE WHEN DB>=0 THEN 'D'  ELSE 'K' END;



      UPDATE #CELJEMLM
         SET KODAF      = dbo.Isd_SegmentsToKodAF(KOD), 
             LLOGARI    = KOD, -- dbo.Isd_SegmentFind(KOD,0,1), 
             LLOGARIPK  = Dbo.Isd_SegmentFind(KOD,0,1), 
             KOMENT     = @Prompt, 
             KURS1      = 1,
             KURS2      = CASE WHEN KMON=''
                               THEN 1
                               ELSE ROUND(CASE WHEN TREGDK='D'
                                               THEN CASE WHEN DB = 0 THEN 1 ELSE     DBKRMV/DB END 
                                               ELSE CASE WHEN KR = 0 THEN 1 ELSE 0 - DBKRMV/KR END 
                                          END,3)
                          END,
             NRDITAR    = 0,
             TIPREF     = '',
             NRDOKREF   = '',
             OPERLLOJ   = '',
             OPERNR     = '',
             OPERAPL    = '',
             OPERORD    = 0,
             OPERNRFAT  = '',
             FADESTIN   = '',
             FAART      = '',
             ORDERSCR   = 0,
             TIPKLL     = @pModul, 
             TROW       = 0,
             TAGNR      = 0;


-- Zerimi Ardhura/Shpenzim (Klasa 6/7)

         SET @VlereDIF  = 0;

          IF @pZerim67=1
             BEGIN
             
                  SET @VlereDIF  = ( SELECT SUM(ISNULL(DBKRMV,0)) FROM #CELJEMLM WHERE KOD>='6' AND KOD<'8' );
                  
               DELETE 
                 FROM #CELJEMLM 
                WHERE KOD>='6' AND KOD<'8';

                  SET @VlereDIF  = ROUND(ISNULL(@VlereDIF,0),2);
                  
             END;

          IF @pZerimAS=1
             BEGIN
                  SET @VlereDIF  = @VlereDIF + ISNULL((SELECT SUM(ISNULL(A.DBKRMV,0)) 
                                                         FROM #CELJEMLM A INNER JOIN LLOGARI B On A.LLOGARIPK=B.KOD
                                                        WHERE B.KLASA='5' Or B.KLASA='6'),0)
               DELETE A
                 FROM #CELJEMLM A INNER JOIN LLOGARI B On A.LLOGARIPK=B.KOD
                WHERE B.KLASA='5' Or B.KLASA='6'

                  SET @VlereDIF  = ROUND(ISNULL(@VlereDIF,0),2)
             END;



          IF ABS(@VlereDIF)>=0.01
             BEGIN
               -- SET @VlereDIF = 0 - @VlereDIF 
                  SET @LlgCelje = ISNULL((SELECT CASE WHEN @VlereDIF>0 THEN LLOGHUMBJE ELSE LLOGFITIM END FROM CONFIGLM),'');
               INSERT INTO #CELJEMLM (TAGNR) VALUES (0)
                  SET @NrD = @@IDENTITY

		       UPDATE #CELJEMLM
			      SET DB        = CASE WHEN @VlereDIF>=0 THEN   @VlereDIF ELSE 0   END, 
				      KR        = CASE WHEN @VlereDIF< 0 THEN 0-@VlereDIF ELSE 0   END, 
                      DBKRMV    = @VlereDIF,
				      TREGDK    = CASE WHEN @VlereDIF>=0 THEN   'D'       ELSE 'K' END,
				      KOD       = @LlgCelje+'....',
				      KODAF     = @LlgCelje,
				      LLOGARI   = @LlgCelje,
				      LLOGARIPK = @LlgCelje,
				      PERSHKRIM = (SELECT PERSHKRIM FROM LLOGARI WHERE KOD=@LlgCelje), 
				      KOMENT    = 'Zerim Ar/Shpz - '+@Prompt, 
                      KMON      = '',
				      KURS1     = 1,
				      KURS2     = 1,
				      NRDITAR   = 0,
                      TIPREF    = '',
                      NRDOKREF  = '',
                      OPERLLOJ  = '',
                      OPERNR    = '',
                      OPERAPL   = '',
                      OPERORD   = 0,
                      OPERNRFAT = '',
                      FADESTIN  = '',
                      FAART     = '',
                      ORDERSCR  = 0,
				      TIPKLL    = @pModul, 
				      TROW      = 0,
				      TAGNR     = 0
                WHERE NRRENDOR = @NrD
             END;


-- Fund Zerimi Ardhura/Shpenzim (Klasa 6/7)



         SET @VlereDIF = ISNULL((SELECT ROUND(SUM(DBKRMV),3) FROM #CELJEMLM),0);

          IF ABS(@VlereDIF)>=0.01
             BEGIN

               SET    @LlgCelje = IsNull((SELECT LLOGCEL FROM CONFIGLM),'')
               SET    @VlereDIF = 0 - @VlereDIF 

               INSERT INTO #CELJEMLM (TAGNR) VALUES (0)
               SET    @NrD = @@IDENTITY

		       UPDATE #CELJEMLM
			      SET DB        = CASE WHEN @VlereDIF>=0 THEN   @VlereDIF ELSE 0   END, 
				      KR        = CASE WHEN @VlereDIF< 0 THEN 0-@VlereDIF ELSE 0   END, 
                      DBKRMV    = @VlereDIF,
				      TREGDK    = CASE WHEN @VlereDIF>=0 THEN   'D'       ELSE 'K' END,
				      KOD       = @LlgCelje+'....',
				      KODAF     = @LlgCelje,
				      LLOGARI   = @LlgCelje,
				      LLOGARIPK = @LlgCelje,
				      PERSHKRIM = (SELECT PERSHKRIM FROM LLOGARI WHERE KOD=@LlgCelje), 
				      KOMENT    = 'Llg. mbyllje - '+@Prompt, 
                      KMON      = '',
				      KURS1     = 1,
				      KURS2     = 1,
				      NRDITAR   = 0,
                      TIPREF    = '',
                      NRDOKREF  = '',
                      OPERLLOJ  = '',
                      OPERNR    = '',
                      OPERAPL   = '',
                      OPERORD   = 0,
                      OPERNRFAT = '',
                      FADESTIN  = '',
                      FAART     = '',
                      ORDERSCR  = 0,
				      TIPKLL    = @pModul, 
				      TROW      = 0,
				      TAGNR     = 0
                WHERE NRRENDOR = @NrD

             END;


      UPDATE VS SET TAGNR=0 WHERE TAGNR<>0;


      INSERT INTO VS (TAGNR) VALUES (0)
         SET @NrD = @@IDENTITY

      UPDATE VS 
         SET NRDOK       = ISNULL((SELECT MAX(ISNULL(B.NRDOK,0)) 
                                     FROM VS B 
                                    WHERE YEAR(B.DATEDOK)=YEAR(DBO.DATEVALUE(@sDateDoc))),0) + 1,
             KODNENDITAR = '', 
             DATEDOK     = DBO.DATEVALUE(@sDateDoc),
             PERSHKRIM1  = @Prompt, 
             PERSHKRIM2  = '',
             KLASIFIKIM  = '',
             DST         = 'CE',
             KMON        = '',
             KURS1       = 1,
             KURS2       = 1,
             NRDFK       = 0,
             FIRSTDOK    = 'E'+CAST(CAST(NRRENDOR AS BIGINT) AS VARCHAR),
             POSTIM      = 0,
             LETER       = 0,
             USI         = 'A', 
             USM         = 'A',
             TROW        = 0, 
             TAGNR       = 0 
       WHERE NRRENDOR = @NrD;

      UPDATE #CELJEMLM 
         SET NRD   = @NrD,
             KURS2 = CASE WHEN KURS2<=0 THEN 1 ELSE KURS2 END;


      SELECT @ListFields = dbo.Isd_ListFieldsTable('VSSCR','NRRENDOR');

      SELECT @Sql = '   
      
     INSERT INTO VSSCR 
           ('+@ListFields+') 
     SELECT '+@ListFields+'
       FROM #CELJEMLM 
   ORDER BY NRRENDOR;';

      EXEC (@Sql);



         IF OBJECT_ID('TEMPDB..#CELJELM') IS NOT NULL
            DROP TABLE #CELJEMLM; 


       EXEC dbo.Isd_GjenerimDitarOne 'VS',0,@NrD;
    -- EXEC dbo.Isd_GjenerimDitarOne 'VS',1,@NrD  -- 20.09.2014

GO
