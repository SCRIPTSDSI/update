SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   procedure [dbo].[Isd_TestUpdFK]
(
  @pDateKp          Varchar(20),
  @pDateKs          Varchar(20),
  @pDocNames        Varchar(1000),
  @pTestVlere       Float,
  @pOperacion       Varchar(100),
  @TestTable        Varchar(30)
)
AS


--       EXEC dbo.[Isd_TestUpdFK] '01/01/2010','31/12/2012','ALL',0.01,'ALL',''
--       @pOperacion = 'NRDNULL,NOTSCR,FKORG,NOTDOC,FKDIF'

-- 1.    Rrjeshta FK me NRD NULL
-- 2.    FK me origjine te panjohur
-- 3.    Fshirje e FK pa rrjeshta
-- 11.   Fshirje FK te pa lidhura me dokumenta....
-- 12.   UPDATE NRDFK tek Tabelat e dokumentave per keto te fshira....
-- 13.   UPDATE Diferenca ne kontabilizim 
-- 14.   Fshirje Referenca te dublikuara....


     DECLARE @DateKp            DateTime,
             @DateKs            DateTime,
             @DocNames          Varchar(1000),
             @Operacion         Varchar(100),
             @TablesDocList     Varchar(MAX),
             @OrgList           Varchar(1000),
             @SQLFilter00       Varchar(MAX),
             @SQLFilter01       Varchar(MAX),
             @ListTables        Varchar(MAX),
             @TableName         Varchar(50),
             @DiferenceDK       Float,
             @Ind1              Int,
             @Nr1               Int,
             @Org               Varchar(10);
         --  @Tip               Varchar(20),
             

         SET @DateKp          = dbo.DateValue(@pDateKp);
         SET @DateKs          = dbo.DateValue(@pDateKs);
         SET @DocNames        = @pDocNames;
         SET @Operacion       = @pOperacion;
         SET @DiferenceDK     = @pTestVlere;
          IF @DiferenceDK<=0
             SET @DiferenceDK = 0.01;

         SET @ListTables      = dbo.Isd_ListTables('','');
         SET @Operacion       = 'NRDNULL,NOTSCR,FKORG,NOTDOC,FKDIF';

         SET @TablesDocList   = 'ARKA,BANKA,VS,FH,FF,DG,FD,FJ,AQ';
         SET @OrgList         = 'A,B,E,H,F,G,D,S,X';
         SET @Nr1             = LEN(@TablesDocList)-LEN(REPLACE(@TablesDocList,',',''))+1;



          IF OBJECT_ID('TempDB..#TempFKUPD') IS NOT NULL
             DROP TABLE #TempFKUPD; 
 
          IF OBJECT_ID('TempDB..#TempFKDif') IS NOT NULL
             DROP TABLE #TempFKDif;


      SELECT NRRENDOR,ORG
        INTO #TempFKUPD
        FROM FK
       WHERE DateDok>=@DateKp AND DateDok<=@DateKs;



-- 1.        Rrjeshta FK me NRD NULL

          IF dbo.Isd_ListFields2Lists(@Operacion,'ALL,NRDNULL','')<>''
             BEGIN
	           DELETE FROM FKSCR WHERE ISNULL(NRD,0)=0;
             END;



-- 2.        FK me origjine te panjohur

          IF dbo.Isd_ListFields2Lists(@Operacion,'ALL,FKORG','')<>''
             BEGIN
               DELETE FROM FK    WHERE ISNULL(ORG,'')='';
             END;



-- 3.        Fshirje e FK pa rrjeshta

          IF dbo.Isd_ListFields2Lists(@Operacion,'ALL,NOTSCR','')<>''
             BEGIN
               DELETE FROM FK WHERE NOT EXISTS (SELECT TOP 1 NRD FROM FKSCR WHERE FK.NRRENDOR=FKSCR.NRD);
             END;



-- 11.       Fshirje FK te pa lidhura me dokumenta....

  IF dbo.Isd_ListFields2Lists(@Operacion,'ALL,NOTDOC','')<>''
     BEGIN 

       SET   @SqlFilter00 = '
               DELETE A
                 FROM FK A INNER JOIN #TempFKUPD A1 ON A.NRRENDOR=A1.NRRENDOR
                WHERE A.ORG=''A'' AND (NOT EXISTS (SELECT B.NRDFK FROM ARKA B WHERE B.NRDFK=A.NRRENDOR)) ;';
                
       SET   @Ind1  = 1;
       
       WHILE @Ind1 <= @Nr1
          BEGIN
             SET @TableName = dbo.Isd_StringInListStr(@TablesDocList,@Ind1,',');
             SET @Org       = dbo.Isd_StringInListStr(@OrgList,@Ind1,','); 

             IF  dbo.Isd_StringInListExs(@ListTables,@TableName)>0 AND dbo.Isd_ListFields2Lists(@DocNames,'ALL,'+@TableName,'')<>''
                 BEGIN
                   SET   @SqlFilter01 = REPLACE(@SQLFilter00,'ARKA',@TableName);
                   SET   @SqlFilter01 = REPLACE(@SQLFilter01,'''A''',''''+@Org+'''');
                   EXEC (@SqlFilter01);
                 END;
             SET @Ind1 = @Ind1 + 1;
          END;

     END;



-- 12.       UPDATE NRDFK tek Tabelat e dokumentave per keto te fshira....

  IF dbo.Isd_ListFields2Lists(@Operacion,'ALL,'+@Operacion,'FKORG,NOTSCR,NOTDOC')<>''
     BEGIN
       SET @SqlFilter00 = '
               UPDATE ARKA 
                  SET NRDFK=0 
                WHERE 1=1 AND NRDFK<>0 AND (NOT EXISTS (SELECT NRRENDOR FROM #TempFKUPD B WHERE B.NRRENDOR=ARKA.NRDFK AND B.ORG=''A'')) ;'

       SET   @Ind1  = 1;
       
       WHILE @Ind1 <= @Nr1
          BEGIN
          
             SET @TableName = dbo.Isd_StringInListStr(@TablesDocList,@Ind1,',');     
             SET @Org       = dbo.Isd_StringInListStr(@OrgList,@Ind1,',');
 
             IF  dbo.Isd_StringInListExs(@ListTables,@TableName)>0 AND dbo.Isd_ListFields2Lists(@DocNames,'ALL,'+@TableName,'')<>''
                 BEGIN
                   SET   @SqlFilter01 = REPLACE(@SQLFilter00,'ARKA',@TableName);
                   SET   @SqlFilter01 = REPLACE(@SQLFilter01,'''A''',''''+@Org+'''');
                   EXEC (@SqlFilter01);
                 END;
                 
             SET @Ind1 = @Ind1 + 1;
             
          END;
     END;



-- 13.       UPDATE Diferenca ne kontabilizim tek rrjeshti i fundit ku futet kjo diference
--           Procedure per modifikim automatik te diferencave me te vogla ne vlefte se @DiferenceDK

  IF dbo.Isd_ListFields2Lists(@Operacion,'ALL,FKDIF','')<>''
     BEGIN
                                                                              -- SET @Tip = REPLACE(@OrgList,',','');
        SELECT * 
          INTO #TempFKDif 
          FROM
              ( SELECT A.NRRENDOR, 
                       NRRENDORSCR = MAX(B.NRRENDOR),
                       DIF         = Round(SUM(B.DBKRMV),3) 
                  FROM FK A INNER JOIN #TempFKUPD A1 ON A.NRRENDOR=A1.NRRENDOR
                            INNER JOIN FKSCR B       ON A.NRRENDOR=B.NRD 
                 WHERE 1=1 AND CHARINDEX(A.ORG, REPLACE(@OrgList,',','') )>0  -- CHARINDEX(A.ORG, @Tip)
              GROUP BY A.NRRENDOR 
                HAVING ABS(Round(SUM(B.DBKRMV),3))>0 AND ABS(Round(SUM(B.DBKRMV),3))<=@DiferenceDK
                )   AS TableDif;
                 

        UPDATE A 
           SET DBKRMV = DBKRMV - DIF, 
               DB     = CASE WHEN KMON='' AND TREGDK='D' AND DB<>0 THEN    DBKRMV-DIF  ELSE DB END,
               KR     = CASE WHEN KMON='' AND TREGDK='K' AND KR<>0 THEN 0-(DBKRMV-DIF) ELSE KR END 
          FROM FKSCR A INNER JOIN #TempFKDif B ON A.NRRENDOR=B.NRRENDORSCR; 

     END;


          IF OBJECT_ID('TempDB..#TempFKDif') IS NOT NULL
             DROP TABLE #TempFKDif; 

          IF OBJECT_ID('TempDB..#TempFKUPD') IS NOT NULL
             DROP TABLE #TempFKUPD;


GO
