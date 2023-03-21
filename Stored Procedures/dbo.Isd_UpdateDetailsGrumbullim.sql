SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE   Procedure [dbo].[Isd_UpdateDetailsGrumbullim]
( 

  @pTable            VARCHAR(60),
  @pKlaseCm          VARCHAR(10),
  @pWhere            VARCHAR(MAX),
  @pNrRendor         Int,
  @pNiptActiv        Int,                                 -- Fermeret me Nipt, pa Nipt, te gjithe. Perdoret ne testin 5
  @pProces           Int  
  
  )
 
AS

-- EXEC [dbo].[Isd_UpdateDetailsGrumbullim] 'GrumbullimScr','A','A.NRD=2',0, 0,1;   -- Cmime
-- EXEC [dbo].[Isd_UpdateDetailsGrumbullim] 'AAAA',         '', '',       0, 0,2;   -- Relacion agjent-Fermer
-- EXEC [dbo].[Isd_UpdateDetailsGrumbullim] 'AAAA',         '', '',       0, 0,3;   -- Date kontrate
-- EXEC [dbo].[Isd_UpdateDetailsGrumbullim] '',             '', '',       0, 0,4;   -- Teste agjentblerje furnitor
-- EXEC [dbo].[Isd_UpdateDetailsGrumbullim] 'GrumbullimScr','', 'A.NRD=2',0, 2,5;   -- Teste grumbullimi

--    Kjo procedure kryen tre funksione

-- 1. Rifresh cmime blerje nga furnitoret sipas produkteve
-- 2. Rifresh kode furnitore dhe agjente sipas skemes ne relacionin [AgjentBlerjeFurnitor-AgjentBlerjeFurnitorScr]
-- 3. Rifresh date kontrate me furnitoret sipas datave ne skemen ne relacionin [AgjentBlerjeFurnitor-AgjentBlerjeFurnitorScr]
-- 4. Testim te dhena per dublikime, kontrate etj tek Agjent blerje-furnitor
-- 5. Testim te dhena tek Grumbullimi

         SET NOCOUNT ON;
      
     DECLARE @sTable      Varchar(30),
             @sKlaseCm    Varchar(10),
             @i           Int,
             @NrRendor    Int, 
             @sNrRendor   Varchar(30),
			 @NiptActiv   Int,
             @sWhere1     Varchar(MAX),
			 @sWhere2     Varchar(500),
             @sSql        nVarchar(MAX);
          
         SET @sTable    = @pTable;
         SET @sKlaseCm  = @pKlaseCm;
         SET @sWhere1   = @pWhere;
         SET @NrRendor  = ISNULL(@pNrRendor,0);
         SET @sNrRendor = CAST(CAST(@NrRendor AS BIGINT) AS VARCHAR(30));
         SET @NiptActiv = ISNULL(@pNiptActiv,0);
         
          IF @pProces=2
             GOTO UPDATEAgjent
             
          ELSE   
          
          IF @pProces=3
             GOTO UPDATEAfat

          ELSE   
          
          IF @pProces=4
             GOTO TESTDhena1
             
          ELSE   
          
          IF @pProces=5
             GOTO TESTDhena2;
             
             
             
             
              
UPDATECmime:

         SET @i = CHARINDEX(@sKlaseCm,'ABCDEFGHIJKLMNOPQRST');
         SET @i = CASE WHEN @i<=0 THEN 1 ELSE @i END;

      
          IF OBJECT_ID('TEMPDB..#TmpCmime1') IS NOT NULL
             DROP TABLE #TmpCmime1;
      
          IF OBJECT_ID('TEMPDB..#TmpCmime2') IS NOT NULL
             DROP TABLE #TmpCmime2;


--           Update cmime ka prioritet: Ne fillim te gjitha sipas klases, pastaj ato qe kane cmime preferenciale     

-- 1.A       Update cmimet sipas klases se artikullt (furnitorit apo magazines).

      SELECT CM01 = MAX(CASE WHEN T.KOD=Pr.ArtField01 THEN T.Cmim ELSE 0 END),
             CM02 = MAX(CASE WHEN T.KOD=Pr.ArtField02 THEN T.Cmim ELSE 0 END),
             CM03 = MAX(CASE WHEN T.KOD=Pr.ArtField03 THEN T.Cmim ELSE 0 END),
             CM04 = MAX(CASE WHEN T.KOD=Pr.ArtField04 THEN T.Cmim ELSE 0 END)
        INTO #TmpCmime1     
        FROM 

           (     
             SELECT Art.Kod, 
                    Cmim = CASE WHEN @i=1  THEN Art.CMB
                                WHEN @i=2  THEN CM.CMBL2
                                WHEN @i=3  THEN CM.CMBL3
                                WHEN @i=4  THEN CM.CMBL4
                                WHEN @i=5  THEN CM.CMBL5
                                WHEN @i=6  THEN CM.CMBL6
                                WHEN @i=7  THEN CM.CMBL7
                                WHEN @i=8  THEN CM.CMBL8
                                WHEN @i=9  THEN CM.CMBL9
                                WHEN @i=10 THEN CM.CMBL10
                                WHEN @i=11 THEN CM.CMBL11
                                WHEN @i=12 THEN CM.CMBL12
                                WHEN @i=13 THEN CM.CMBL13
                                WHEN @i=14 THEN CM.CMBL14
                                WHEN @i=15 THEN CM.CMBL15
                                WHEN @i=16 THEN CM.CMBL16
                                WHEN @i=17 THEN CM.CMBL17
                                WHEN @i=18 THEN CM.CMBL18
                                WHEN @i=19 THEN CM.CMBL19
                                WHEN @i=20 THEN CM.CMBL20
                                ELSE            Art.CMB 
                           END
               FROM Artikuj Art INNER JOIN ArtikujCmBl Cm ON Art.NrRendor=Cm.NRD,    GrumbullimPrompts Pr
              WHERE Art.Kod=Pr.ArtField01 OR Art.Kod=Pr.ArtField02 
                    
              ) T,  GrumbullimPrompts Pr; 


         SET @sSql = '
         
      UPDATE A                                                               -- SELECT A.*,B.* 
         SET CMIM01 = B.CM01,CMIM02=B.CM02,CMIM03=B.CM03,CMIM04=B.CM04       
        FROM '+@sTable+' A, #TmpCmime1 B
       WHERE 1=1       -- AND A.NRD=2;
--  ORDER BY A.Nrd,A.KODAGJ; ';

          IF @sWhere1<>''
             SET @sSql = REPLACE(@sSql,'1=1',@sWhere1);
             
        EXEC (@sSql);
        
        
        
          
-- 1.B       Sipas kod furnitorit tek cmimet preferenciale tek lista e artikujve te lidhur me furnitorin

      SELECT Cm.NRD, 
             CM01 = MAX(CASE WHEN Cm.KOD=Pr.ArtField01 THEN Cm.CMIMBS ELSE 0 END),
             CM02 = MAX(CASE WHEN Cm.KOD=Pr.ArtField02 THEN Cm.CMIMBS ELSE 0 END),
             CM03 = MAX(CASE WHEN Cm.KOD=Pr.ArtField03 THEN Cm.CMIMBS ELSE 0 END),
             CM04 = MAX(CASE WHEN Cm.KOD=Pr.ArtField04 THEN Cm.CMIMBS ELSE 0 END) 
        INTO #TmpCmime2     
        FROM FurnitorCmim Cm, GrumbullimPrompts Pr 
    GROUP BY Cm.NRD;



         SET @sSql = '
         
      UPDATE A
         SET CMIM01=T.CM01, CMIM02=T.CM02, CMIM03=T.CM03, CMIM04=T.CM04       -- SELECT * 
        FROM '+@sTable+  ' A INNER JOIN Furnitor   F ON A.KODAF=F.KOD
                             INNER JOIN #TmpCmime2 T ON F.NRRENDOR=T.NRD
       WHERE 1=1         
--  ORDER BY A.Nrd,A.KODAGJ; ';

          IF @sWhere1<>''
             SET @sSql = REPLACE(@sSql,'1=1',@sWhere1);

        EXEC (@sSql);
        
        
  
          IF OBJECT_ID('TEMPDB..#TmpCmime1') IS NOT NULL
             DROP TABLE #TmpCmime1;

          IF OBJECT_ID('TEMPDB..#TmpCmime2') IS NOT NULL
             DROP TABLE #TmpCmime2;


         GOTO FUND;





UPDATEAgjent:

-- 2.        Ndryshon KodAgjent sipas skemes tek tabelat [AgjentBlerjeFurnitor] - [AgjentBlerjeFurnitorScr]


         SET @sSql = '

-- Ndryshim KodAgjente sipas furnitoreve

      UPDATE A
         SET A.KodAgj=T.KodAgj, A.PershkrimAgj=R.Pershkrim, A.NIPTActiv=ISNULL(T.NIPTActiv,0),A.NotDocumentFat=ISNULL(T.NotDocumentFat,0)
        FROM '+@sTable+' A INNER JOIN 
                                   (
                                       SELECT KodAgj=A.Kod, KodFu=B.KodAF, NIPTActiv=ISNULL(B.NIPTActiv,0),NotDocumentFat=ISNULL(B.NotDocumentFat,0)
                                         FROM AgjentBlerjeFurnitor A INNER JOIN AgjentBlerjeFurnitorScr B ON A.NrRendor=B.Nrd

                                      ) T              ON T.KodFu=A.KodAF
                                  
                           INNER JOIN AgjentBlerje R ON R.Kod=T.KodAgj
       WHERE 1=1; 
       
       
-- Shtim furnitoret qe mungojne

      INSERT INTO '+@sTable+'
            (NRD,KOD,KODAF,PERSHKRIM,KODAGJ,PERSHKRIMAGJ,NIPTACTIV,NotDocumentFat,CMIM01,CMIM02,CMIM03,CMIM04,NrOrder,KodOrder,OrderScr,GetSasi)

      SELECT Nrd='+@sNrRendor+', Kod=B.KodAF, B.KodAF, B.Pershkrim, KodAgj=A.Kod, PershkrimAgj=A.Pershkrim, NiptActiv=ISNULL(B.NIPTActiv,0),
             NotDocumentFat=ISNULL(B.NotDocumentFat,0),
             CM01=0.0,CM02=0.0,CM03=0.0,CM04=0.0,B.NrOrder,KodOrder,NrOrder,GetSasi=0
        FROM AgjentBlerjeFurnitor A INNER JOIN AgjentBlerjeFurnitorScr B ON A.NrRendor=B.Nrd
       WHERE 1=1 AND
             (NOT EXISTS (SELECT 1 FROM '+@sTable+' TF WHERE TF.KODAF=B.KODAF)); ';
       
          IF @sWhere1<>''
             SET @sSql = REPLACE(@sSql,'1=1',@sWhere1);

        EXEC (@sSql);  -- PRINT @sSql;
        
  
        GOTO FUND;
        
        
        
        
        
UPDATEAfat:

-- 3.        Update Date fillim dhe Date perfundim kontrate me fermerin


         SET @sSql = '

      UPDATE A                                                               -- SELECT A.*,B.* 
         SET A.DATESTART=B.DATESTART, A.DATEEND=B.DATEEND, A.DAYDIFF=DATEDIFF(DAY,GetDate(),B.DATEEND)
        FROM '+@sTable+' A   INNER JOIN AgjentBlerjeFurnitorScr B ON A.KODAF=B.KODAF
       WHERE 1=1       -- AND A.NRD=2;
--  ORDER BY A.NRD,A.KODAF; ';

          IF @sWhere1<>''
             SET @sSql = REPLACE(@sSql,'1=1',@sWhere1);
             
        EXEC (@sSql);
        
        
        GOTO FUND;
        




TESTDhena1:         

-- 4.        Test te dhena tek relacioni AgjentBlerje-Furnitor


      SELECT KodAgj=A.Kod,KodFu=B.KodAF,Nr=COUNT(*),[Error]='Relacioni i perseritur '+CAST(COUNT(*) AS Varchar)+' here.',KodError='AGJFUR',
          -- TRow=CAST(CASE WHEN Row_Number() OVER(ORDER BY A.Kod, B.KodAF)=1 THEN 1 ELSE 0 END AS BIT),TagNr=0,NrRendor=Row_Number() OVER(ORDER BY A.Kod, B.KodAF)  
             DSGNROW = CASE WHEN Row_Number() OVER(ORDER BY A.Kod, B.KodAF)=1 THEN 'CI' ELSE '' END    
        FROM AgjentBlerjeFurnitor A INNER JOIN AgjentBlerjeFurnitorScr B ON A.NrRendor=B.Nrd
    GROUP BY A.Kod, B.KodAF
      HAVING COUNT(*)>1 
      
   UNION ALL
   
      SELECT KodAgj=A.Kod,KodFu='',     Nr=COUNT(*),[Error]='Agjent i perseritur '+CAST(COUNT(*) AS Varchar)+' here.',   KodError='AGJ01',
          -- TRow=CAST(CASE WHEN Row_Number() OVER(ORDER BY A.Kod)=1 THEN 1 ELSE 0 END AS BIT),TagNr=0,NrRendor=Row_Number() OVER(ORDER BY A.Kod)
             DSGNROW = CASE WHEN Row_Number() OVER(ORDER BY A.Kod)=1 THEN 'CI' ELSE '' END     
        FROM AgjentBlerjeFurnitor A 
    GROUP BY A.Kod
      HAVING COUNT(*)>1
      
   UNION ALL
   
      SELECT KodAgj='',   KodFu=B.KodAF,Nr=COUNT(*),[Error]='Furnitor i perseritur '+CAST(COUNT(*) AS Varchar)+' here.', KodError='FUR01',
          -- TRow=CAST(CASE WHEN Row_Number() OVER(ORDER BY B.KodAF)=1 THEN 1 ELSE 0 END AS BIT),TagNr=0,NrRendor=Row_Number() OVER(ORDER BY B.KodAF) 
             DSGNROW = CASE WHEN Row_Number() OVER(ORDER BY B.KodAF)=1 THEN 'CI' ELSE '' END    
        FROM AgjentBlerjeFurnitorScr B
    GROUP BY B.KodAF
      HAVING COUNT(*)>1

   UNION ALL

      SELECT KodAgj=A.Kod,KodFu=B.KodAF,Nr=0,
             [Error]='Furnitor pa kontrate '+
                     CASE WHEN (B.DATESTART IS NULL) OR (B.DATEEND IS NULL)
                          THEN ''
                          ELSE CONVERT(Varchar(20),B.DATESTART,04)+' - '+CONVERT(Varchar(20),B.DATEEND,04)+',  '+ 
                               CONVERT(Varchar(10),DATEDIFF(DAY,GetDate(),B.DATEEND))+' dite'
                     END,
             KodError='FUR02',
          -- TRow=CAST(CASE WHEN Row_Number() OVER(ORDER BY B.KodAF)=1 THEN 1 ELSE 0 END AS BIT),TagNr=0,NrRendor=Row_Number() OVER(ORDER BY A.Kod,B.KodAF),
             DSGNROW = CASE WHEN Row_Number() OVER(ORDER BY B.KodAF)=1 THEN 'CI' ELSE '' END    
        FROM AgjentBlerjeFurnitor A INNER JOIN AgjentBlerjeFurnitorScr B ON A.NRRENDOR=B.NRD
       WHERE DATEDIFF(DAY,GetDate(),B.DATEEND)<0

    ORDER BY KodError,KodAgj,KodFu 


        GOTO FUND;





TESTDhena2:         

-- 5.        Test te dhena tek grumbullimi - Furnitor pa kontrate


         SET @sSql = '
     DECLARE @sError   nVarchar(MAX);
         SET @sError = '''';
             
      SELECT @sError = @sError+''/''+A.KodAF+'' ''+CONVERT(Varchar(10),DATEDIFF(DAY,GetDate(),A.DATEEND))+'' dite ''
        FROM '+@sTable+' A 
       WHERE 1=1 
	         AND (2=2) AND	(ISNULL(A.SASI01_GR,0)<>0 OR ISNULL(A.SASI02_GR,0)<>0 OR ISNULL(A.SASI03_GR,0)<>0) 
			 AND 
	         DATEDIFF(DAY,GetDate(),A.DATEEND)<0
    ORDER BY KodAF;
    
      SELECT MsgError=LEFT(ISNULL(@sError,''''),200); ';

    
	     SET @sWhere2 = '';

	      IF @NiptActiv=1
			 SET @sWhere2 = 'ISNULL(A.NIPTACTIV,0)=1'
		  ELSE
		  IF @NiptActiv=0
		     SET @sWhere2 = 'ISNULL(A.NIPTACTIV,0)=0';
	
          IF @sWhere2<>''
		     SET @sSql = Replace(@sSql,'2=2',@sWhere2);

	      IF @sWhere1<>''
             SET @sSql = REPLACE(@sSql,'1=1',@sWhere1);
             
        EXEC (@sSql);   PRINT @sSql;
 
 
        GOTO FUND;




FUND:
GO
