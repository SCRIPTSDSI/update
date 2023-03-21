SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE  PROCEDURE [dbo].[zzTransportDataFinance] 
(
 @pGrupi        Varchar(60),
 @pKodDep       Varchar(60),
 @pKodList      Varchar(60),
 @pKMon         Varchar(20),
 @pLlgDepList   Varchar(20),
 @pNrRendor     Int
)

AS
 
-- EXEC dbo.zzTransportDataFinance 'ROUTE','','','EUR','LGLS',0

         SET NOCOUNT ON;
   

     DECLARE @sList          Varchar(Max),
             @sGrupi         Varchar(50),
             @KodDep         Varchar(60),
             @KodList        Varchar(60),
             @sKMon          Varchar(20),
             @sLlgDepList    Varchar(20),
             @NrRendor       Int;
             
         SET @sList        = '';
         SET @sGrupi       = @pGrupi;
         SET @KodDep       = @pKodDep;
         SET @KodList      = @pKodList;
         SET @sKMon        = @pKMon;
         SET @sLlgDepList  = @pLlgDepList;
         SET @NrRendor     = ISNULL(@pNrRendor,0);


--       SET @sKMon        = 'EUR';
      SELECT @sKMon        = ISNULL(KOD,'') FROM MONEDHA WHERE ISNULL(KOD1,'')='EUR'; -- Pershin te dy rastet kur Mon baze eshte Lek ose Euro por shpenzimet i mbajne ne Euro.
         SET @sKMon        = ISNULL(@sKMon,'');
         

          IF OBJECT_ID('TEMPDB..#TblKodLlogari')     IS NOT NULL
             DROP TABLE #TblKodLlogari;
          IF OBJECT_ID('TEMPDB..#TblGjendjeLlogari') IS NOT NULL
             DROP TABLE #TblGjendjeLlogari;
                      
                      
          IF @NrRendor > 0             -- Vetem nje resht
             BEGIN
                  
               SELECT @sList = ISNULL(A.LISTELLOGARI ,'') 
                 FROM zzTransportListeShpenzime A
                WHERE GRUPI=@sGrupi AND NRRENDOR=@NrRendor;  
                         
             END
                      
          ELSE
             BEGIN
                     
               SELECT @sList = @sList+','+ISNULL(A.LISTELLOGARI ,'') 
                 FROM zzTransportListeShpenzime A
                WHERE GRUPI=@sGrupi;  
                      
             END;
                      
                      
           WHILE CHARINDEX(',,',@sList)>0
             BEGIN
               SET @sList = REPLACE(@sList,',,',',')
             END;
   
           IF SUBSTRING(@sList,1,1)=','
              SET @sList = SUBSTRING(@sList,2,LEN(@sList));
      
      

      
-- Krijohet tabele temporare me kode llogari qe egzistojne tek tabela LLOGARI

      SELECT Kod=A.Splitet                             
        INTO #TblKodLlogari 
        FROM dbo.Split(@sList,',') A
       WHERE EXISTS (SELECT * FROM LLOGARI B WHERE A.Splitet=B.KOD)
    ORDER BY 1;
             


-- Tabele gjendje per cdo llogari

--      SELECT A.KOD, A.LLOGARIPK, A.DB, A.KR, A.DBKRMV, A.KMON,
--             DEP  = dbo.Isd_SegmentFind(A.KOD,0,2),
--             LIST = dbo.Isd_SegmentFind(A.KOD,0,3)
--        INTO #TblGjendjeLlogari
--        FROM FKSCR A INNER JOIN #TblKodLlogari B ON A.LLOGARIPK=B.Kod
----     WHERE KMON=@sKMon
--    ORDER BY A.LLOGARIPK;


--    SELECT A.KOD, A.LLOGARIPK, A.DB, A.KR, A.DBKRMV, A.KMON,                                 -- Shpenzime tek Liber i madh nga Dokumentat
--           DEP  = dbo.Isd_SegmentFind(A.KOD,0,2),
--           LIST = dbo.Isd_SegmentFind(A.KOD,0,3)
--      INTO #TblGjendjeLlogari
--      FROM FKSCR     A INNER JOIN #TblKodLlogari B ON A.LLOGARIPK=B.Kod
--                       INNER JOIN FK M ON A.NRD=M.NRRENDOR
--     WHERE (NOT (M.ORG IN ('S','F','A','B','E'))) AND A.KMON=@sKMon
       
-- UNION ALL
   
	  SELECT A.KOD, A.LLOGARIPK, A.DB, A.KR, A.DBKRMV, A.KMON,                                 -- Shpenzime tek Liber i madh Direkte
             DEP  = dbo.Isd_SegmentFind(A.KOD,0,2),
             LIST = dbo.Isd_SegmentFind(A.KOD,0,3)
        INTO #TblGjendjeLlogari             
        FROM FKSCR     A INNER JOIN #TblKodLlogari B ON A.LLOGARIPK=B.Kod
                         INNER JOIN FK M ON A.NRD=M.NRRENDOR
       WHERE M.ORG='T' AND A.KMON=@sKMon

   UNION ALL
      SELECT A.KOD, A.LLOGARIPK, A.DB, A.KR, A.DBKRMV, A.KMON,                                 -- Shpenzime tek Arka
             DEP  = dbo.Isd_SegmentFind(A.KOD,0,2),
             LIST = dbo.Isd_SegmentFind(A.KOD,0,3)
        FROM ARKASCR   A INNER JOIN #TblKodLlogari B ON A.LLOGARIPK=B.Kod
       WHERE A.TIPKLL='T' AND A.KMON=@sKMon
       
   UNION ALL
      SELECT A.KOD, A.LLOGARIPK, A.DB, A.KR, A.DBKRMV, A.KMON,                                 -- Shpenzime tek Banka
             DEP  = dbo.Isd_SegmentFind(A.KOD,0,2),
             LIST = dbo.Isd_SegmentFind(A.KOD,0,3)
        FROM BANKASCR  A INNER JOIN #TblKodLlogari B ON A.LLOGARIPK=B.Kod
       WHERE A.TIPKLL='T' AND A.KMON=@sKMon
       
   UNION ALL
      SELECT A.KOD, A.LLOGARIPK, A.DB, A.KR, A.DBKRMV, A.KMON,                                 -- Shpenzime tek Ndermodularet
             DEP  = dbo.Isd_SegmentFind(A.KOD,0,2),
             LIST = dbo.Isd_SegmentFind(A.KOD,0,3)
        FROM VSSCR     A INNER JOIN #TblKodLlogari B ON A.LLOGARIPK=B.Kod
       WHERE A.TIPKLL='T' AND A.KMON=@sKMon

   UNION ALL
      SELECT A.KOD, LLOGARIPK=A.KARTLLG, DB=A.VLERABS, KR=0,                                   -- Shpenzim tek fature blerje
             DBKRMV=CASE WHEN M.KURS1*M.KURS2>0 THEN (A.VLERABS*M.KURS2)/M.KURS1 ELSE A.VLERABS END, M.KMON,
             DEP  = dbo.Isd_SegmentFind(A.KOD,0,2),
             LIST = dbo.Isd_SegmentFind(A.KOD,0,3)
        FROM FFSCR     A INNER JOIN #TblKodLlogari B ON A.LLOGARIPK=B.Kod
                         INNER JOIN FF M ON A.NRD=M.NRRENDOR
       WHERE A.TIPKLL='L' AND M.KMON=@sKMon

-- UNION ALL
--    SELECT A.KOD, LLOGARIPK=A.KARTLLG, DB=A.VLERABS, KR=0,                                   -- Tek FJ
--           DBKRMV = CASE WHEN M.KURS1*M.KURS2>0 THEN (A.VLERABS*M.KURS2)/M.KURS1 ELSE A.VLERABS END, M.KMON,
--           DEP  = dbo.Isd_SegmentFind(A.KOD,0,2),
--           LIST = dbo.Isd_SegmentFind(A.KOD,0,3)
--      FROM FJSCR A INNER JOIN #TblKodLlogari B ON A.LLOGARIPK=B.Kod
--                   INNER JOIN FF M ON A.NRD=M.NRRENDOR
--     WHERE A.TIPKLL='L' AND M.KMON=@sKMon

    ORDER BY A.LLOGARIPK;
    


       ALTER TABLE #TblKodLlogari ADD Gjendje Float NULL;

      IF @sLlgDepList='LGDPLS'                       -- Llogari analitike: Llogari.Departament.Liste 
         BEGIN
           UPDATE A
              SET Gjendje = ( SELECT SUM(ISNULL(DB,0)-ISNULL(KR,0)) 
                                FROM #TblGjendjeLlogari B 
                               WHERE B.LLOGARIPK=A.Kod AND DEP=@KodDep AND List=@KodList )
            FROM #TblKodLlogari A;
         END
         
      ELSE
      
      IF @sLlgDepList='LGLS'                         -- Llogari analitike: Llogari..Liste
         BEGIN
           UPDATE A
              SET Gjendje = ( SELECT SUM(ISNULL(DB,0)-ISNULL(KR,0)) 
                                FROM #TblGjendjeLlogari B 
                               WHERE B.LLOGARIPK=A.Kod AND List=@KodList )
            FROM #TblKodLlogari A;
         END

      ELSE

      IF @sLlgDepList='LGDP'                         -- Llogari analitike: Llogari.Departament..
         BEGIN
           UPDATE A
              SET Gjendje = ( SELECT SUM(ISNULL(DB,0)-ISNULL(KR,0)) 
                                FROM #TblGjendjeLlogari B 
                               WHERE B.LLOGARIPK=A.Kod AND DEP=@KodDep )
            FROM #TblKodLlogari A;
         END

      ELSE         

         BEGIN                                       -- Llogari analitike: Llogari...
           UPDATE A
              SET Gjendje = ( SELECT SUM(ISNULL(DB,0)-ISNULL(KR,0)) 
                                FROM #TblGjendjeLlogari B 
                               WHERE B.LLOGARIPK=A.Kod )
            FROM #TblKodLlogari A;
         END;



-- Update Gjendje tek tabela e llogarive shpenzim
    
          IF @NrRendor > 0             -- Rasti kur kerkohete vetem per nje resht
             BEGIN
               --SELECT *,Gjendje = (SELECT SUM(Gjendje) FROM #TblKodLlogari B WHERE CHARINDEX(','+B.Kod+',',','+A.LISTELLOGARI+',')>0)
                 UPDATE A
                    SET Gjendje = (SELECT SUM(ISNULL(Gjendje,0)) FROM #TblKodLlogari B WHERE CHARINDEX(','+B.Kod+',',','+A.LISTELLOGARI+',')>0)
                   FROM zzTransportListeShpenzime A
                  WHERE GRUPI=@sGrupi AND NrRendor=@NrRendor 
             END  
             
          ELSE
             BEGIN
                 UPDATE A
                    SET Gjendje = (SELECT SUM(ISNULL(Gjendje,0)) FROM #TblKodLlogari B WHERE CHARINDEX(','+B.Kod+',',','+A.LISTELLOGARI+',')>0)
                   FROM zzTransportListeShpenzime A
                  WHERE GRUPI=@sGrupi 

                 UPDATE A
                    SET Gjendje = (SELECT SUM(ISNULL(Gjendje,0)) FROM zzTransportListeShpenzime B WHERE (A.GRUPI=B.GRUPI) AND (ISNULL(B.FIELDTOTAL,0)<>1))
                   FROM zzTransportListeShpenzime A
                  WHERE GRUPI=@sGrupi AND ISNULL(A.FIELDTOTAL,0)=1

             END;
      
    
          IF OBJECT_ID('TEMPDB..#TblKodLlogari')     IS NOT NULL
             DROP TABLE #TblKodLlogari;
          IF OBJECT_ID('TEMPDB..#TblGjendjeLlogari') IS NOT NULL
             DROP TABLE #TblGjendjeLlogari;   
GO
