SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   procedure [dbo].[Isd_OrderItemsDisplayImport]
 (
   @pTableTmp       VARCHAR(30),
   @pWhere          VARCHAR(MAX),
   @pTipKll         VARCHAR(10),
   @pNrRendor       INT,

   @pDeleteRows     Int,
   @pZerimSasi      Int,
   @pOper           VARCHAR(10)
 
 )
 
AS

-- EXEC [Isd_OrderItemsDisplayImport] '','DATEDOK>=DBO.DATEVALUE(''01.01.2017'') AND DATEDOK<=DBO.DATEVALUE(''31.12.2017'')','',0,0,0,'D';
-- EXEC [Isd_OrderItemsDisplayImport] '##Pvt_51019748_MK','DATEDOK>=DBO.DATEVALUE(''01.01.2017'') AND DATEDOK<=DBO.DATEVALUE(''31.12.2017'')','M',9,0,0,'A';

              SET NOCOUNT ON;
              
          DECLARE @sSql         nVARCHAR(MAX),
                  @sWhere	    nVARCHAR(MAX),
                  @sTipKll      VARCHAR(10),
                  @sTableTmp    VARCHAR(50),
                  @NrRendor     INT,
                  @DeleteRows   Int,
                  @ZerimSasi    Int,
                  @sOper        Varchar(10);
      
              SET @sTableTmp  = @pTableTmp;
              SET @sWhere     = @pWhere;
              SET @sTipKll    = @pTipKll;
              SET @NrRendor   = @pNrRendor;
              SET @DeleteRows = @pDeleteRows;
              SET @ZerimSasi  = @pZerimSasi;
              SET @sOper      = @pOper;


-- Procedura ka dy funksione:

--     1.  Afishon kandidatet per tu shtuar (Reshta dhe kollona)   -  Rasti @sOper = 'D'

--     2.  Shton ne tabelen temporare (te pivotuar) artikujt e rinj dhe kollonat e reja duke azhurnuar dhe sasine  -  Rasti @sOper='A' append


-- 1.     FILLIM:  Afishimi i dokumentave porosi te krijuara(Tabelat ORK,ORKSCR), per import tek OrderItems,OrderItemsScr

    IF @sOper = 'D' -- Display,Afishim ku @sTipKll mund te jete nje nga 'M','D','K' ose kombinim i tyre psh 'MDK'
       BEGIN

              SET @sSql     = '
      SELECT *
        FROM
     (  
      SELECT B.NRRENDOR,
             B.NRD,
             KOD         = B.KARTLLG,
             B.PERSHKRIM,
             B.NJESI,
             B.SASI,
             B.SASIKONV,
             KODAF       = CASE WHEN R2.TIPI=2 OR R2.TIPI=3 THEN A.KMAG       ELSE A.KODFKL  END,
             EMERTIM     = CASE WHEN R2.TIPI=2 OR R2.TIPI=3 THEN R2.PERSHKRIM ELSE A.SHENIM1 END,
             TIPKLL      = CASE WHEN R2.TIPI=2 THEN ''D''
                                WHEN R2.TIPI=3 THEN ''M''
                                ELSE                ''K''
                           END,
             NJESIADM    = CASE WHEN R2.TIPI=2 THEN ''Dyqan''
                                WHEN R2.TIPI=3 THEN ''Makine''
                                ELSE                ''Klient''
                           END,           
             A.NRDOK,
             A.DATEDOK,
             A.KMAG,
             IMPORTUAR   = ISNULL(CREATEPIVOTORD,0),
             ORDERSCR    = 0,
             STATROW     = '''',     
             TROW        = CAST(0 AS BIT),
             TAGNR       = CAST(0 AS BIGINT)
        FROM ORK A INNER JOIN ORKSCR   B  ON A.NRRENDOR=B.NRD
                   INNER JOIN ARTIKUJ  R1 ON B.KARTLLG=R1.KOD
                   INNER JOIN MAGAZINA R2 ON A.KMAG=R2.KOD 
       WHERE (1=1)
       
       ) A  
       
       WHERE CHARINDEX(TIPKLL,'''+@sTipKll+''')>0
       
    ORDER BY DATEDOK,TIPKLL,KODAF,KOD;';
    
    
            IF    @sWhere<>''
                  SET  @sSql = REPLACE(@sSql,'1=1',@sWhere);

        -- PRINT  @sSql;
            EXEC (@sSql);
       
          RETURN;
          
       END;
       
-- 1.     FUND:    Afishimi i dokumentave
       
       
       
       
-- 2.     FILLIM:  Shtim artikuj(Reshta), Shtim kollona       
       
    IF @sOper = 'A' -- Shtim artikuj,Shtim kollona tek tabela Tmp dhe UPDATE Sasi me sasite nga dokumentat porosi
       BEGIN
       

               IF OBJECT_ID('TEMPDB..#NewOrders') IS NOT NULL     -- Ndertohet Lista e Artikujve Porosi (Sasi + (Makine,Dyqan,Klient))
                  DROP TABLE #NewOrders;
               IF OBJECT_ID('TEMPDB..#NewOrdersId') IS NOT NULL   -- Ndertohet Lista e Id per te zgjedhurat
                  DROP TABLE #NewOrdersId;


          DECLARE @sColumns      nVARCHAR(MAX),
                  @sColumnName   VARCHAR(50),
                  @sField        VARCHAR(50),
                  @sFields       VARCHAR(MAX),
                  @FieldsEx      VARCHAR(MAX),
                  @sFields1      VARCHAR(MAX),
                  @sFields2      VARCHAR(MAX),
                  @sFields3      VARCHAR(Max),
                  @i             INT,
                  @j             INT;
 
              SET @NrRendor    = @pNrRendor;
               
           SELECT KODAF        = SPACE(60),
                  KOD          = SPACE(100),
                  PERSHKRIM    = SPACE(250),
                  NJESI        = SPACE(10),
                  TIPKLL       = Space(10),
                  SASI         = CAST(0.00 AS FLOAT),
                  SASIKONV     = CAST(0.00 AS FLOAT)
             INTO #NewOrders 
            WHERE 1=2;
          
           SELECT NRRENDOR     = CAST(0 AS BIGINT)
             INTO #NewOrdersId 
            WHERE 1=2;
          
              SET @sSql = '
              
      INSERT INTO #NewOrders
            (KODAF, KOD, SASI, SASIKONV, PERSHKRIM, NJESI,TIPKLL)
      SELECT KODAF       = CASE WHEN R2.TIPI=2 OR R2.TIPI=3 THEN A.KMAG ELSE A.KODFKL END,
             KOD         = B.KARTLLG,
             SASI        = ROUND(SUM(SASI),2),
             SASIKONV    = ROUND(SUM(SASIKONV),2),
             PERSHKRIM   = MAX(B.PERSHKRIM),
             NJESI       = MAX(B.NJESI),
             TIPKLL      = CASE WHEN MAX(R2.TIPI)=2 THEN ''D''
                                WHEN MAX(R2.TIPI)=3 THEN ''M''
                                ELSE                     ''K''
                           END           
        FROM ORK A INNER JOIN ORKSCR   B  ON A.NRRENDOR=B.NRD
                   INNER JOIN ARTIKUJ  R1 ON B.KARTLLG=R1.KOD
                   INNER JOIN MAGAZINA R2 ON A.KMAG=R2.KOD 
       WHERE (1=1) 
    GROUP BY CASE WHEN R2.TIPI=2 OR R2.TIPI=3 THEN A.KMAG ELSE A.KODFKL END, B.KARTLLG   
      HAVING CASE WHEN MAX(R2.TIPI)=2 THEN ''D''
                  WHEN MAX(R2.TIPI)=3 THEN ''M''
                  ELSE                     ''K''
             END = '''+@sTipKll+'''
    ORDER BY KODAF,KOD;
    
    
      INSERT INTO #NewOrdersId
            (NRRENDOR)
      SELECT A.NRRENDOR              
        FROM ORK A INNER JOIN ORKSCR   B  ON A.NRRENDOR=B.NRD
                   INNER JOIN ARTIKUJ  R1 ON B.KARTLLG=R1.KOD
                   INNER JOIN MAGAZINA R2 ON A.KMAG=R2.KOD 
       WHERE (1=1) 
    GROUP BY A.NRRENDOR
      HAVING CASE WHEN MAX(R2.TIPI)=2 THEN ''D''
                  WHEN MAX(R2.TIPI)=3 THEN ''M''
                  ELSE                     ''K''
             END = '''+@sTipKll+'''
    ORDER BY NRRENDOR;';
    
         SET  @sSql = REPLACE(@sSql,'1=1',@pWhere);
        EXEC (@sSql);
   -- SELECT * FROM #NewOrders


-- 2.1.   FILLIM:  RESHTAT E REJA
               
       
          IF  @DeleteRows=1             -- 2.1.1 DELETE ROWS tek tabela Tmp pivotuar
              BEGIN
                EXEC (' DELETE FROM '+@sTableTmp+';');
              END;


                                        -- 2.1.2 SHTIM  ROWS tek tabela Tmp pivotuar
          SET @sSql = '
              
      INSERT INTO '+@sTableTmp+'
            (KOD,PERSHKRIM,NJESI)
      SELECT KOD,
             PERSHKRIM = MAX(PERSHKRIM),
             NJESI     = MAX(NJESI)
        FROM #NewOrders A
       WHERE (NOT EXISTS (SELECT * FROM '+@sTableTmp+' T1 WHERE T1.KOD=A.KOD))
    GROUP BY KOD   
    ORDER BY KOD;';
--     PRINT  @sSql;
        EXEC (@sSql);
       
-- 2.1.   FUND:  RESHTAT E REJA       
       
       
-- 2.2.   FILLIM:   KOLLONAT E REJA (Magazinat,Dyqanet ose Klientet)

-- 2.2.1 Stringu me KOLLONAT E REJA (@sColumns)

          SET @sColumns   = N'';

       SELECT @sColumns   = @sColumns+N',' + KODAF 
         FROM #NewOrders
     GROUP BY KODAF
     ORDER BY KODAF;    

          SET @sColumns = ISNULL(STUFF(ISNULL(@sColumns,''), 1, 1, N''),'');
     -- PRINT @sColumns;

          SET @i = 1;
          SET @j = LEN(@sColumns)-LEN(REPLACE(@sColumns,',',''))+1;
         
          IF  ISNULL(@sColumns,'')=''
              RETURN;



-- 2.2.2. Tek Kollonat: SHTOHEN ATO qe mungojne dhe azhurnohet sasia 

        WHILE @i<=@j --AND (@sColumns<>'')
          BEGIN
         
              IF  CHARINDEX(',',@sColumns)>0
                  BEGIN
                    SET @sColumnName = SUBSTRING(@sColumns,1,CHARINDEX(',',@sColumns)-1);
                  END
              ELSE
                  BEGIN
                    SET @sColumnName = @sColumns;
                    SET @sColumns    = '';
                  END;   
                    
              SET @sColumnName = ISNULL(@sColumnName,'');    
              SET @sColumns    = ISNULL(SUBSTRING(@sColumns, CHARINDEX(',',@sColumns)+1,LEN(@sColumns)),'');




-- 2.2.3 Shtim i nje KOLLONE TE RE (Testohet ne se egziston)

              IF  @sColumnName<>''
                  BEGIN 

                      IF  NOT EXISTS (SELECT [NAME] FROM TEMPDB.SYS.COLUMNS A WHERE A.OBJECT_ID=OBJECT_ID('TEMPDB..'+@sTableTmp) AND [NAME]=@sColumnName)
                          BEGIN
                            EXEC (' ALTER TABLE '+@sTableTmp+' ADD '+@sColumnName+'      FLOAT NULL;');   -- PRINT 'Nuk Egziston '+@sColumnName;
                          END;
               
                      IF  NOT EXISTS (SELECT [NAME] FROM TEMPDB.SYS.COLUMNS A WHERE A.OBJECT_ID=OBJECT_ID('TEMPDB..'+@sTableTmp) AND [NAME]=@sColumnName+'_KONV')
                          BEGIN
                            EXEC (' ALTER TABLE '+@sTableTmp+' ADD '+@sColumnName+'_KONV FLOAT NULL;');   -- PRINT 'Nuk Egziston '+@sColumnName;
                          END;


--                Pse duhet ??? 
-- 2.2.4. Vlefta e Kkollones behet ZERO kur @ZerimSasi=1, ose behet zero kur eshte null
                   -- IF  @ZerimSasi=1       
                   --     BEGIN
                   --       EXEC (' UPDATE '+@sTableTmp+' SET '+@sColumnName+'=0;');
                   --     END
                   -- ELSE
                   --     BEGIN
                   --       EXEC (' UPDATE '+@sTableTmp+' SET '+@sColumnName+'=ISNULL('+@sColumnName+',0);');
                   --     END;
                    
                   -- Pse duhet NRD ???
                     SET  @sSql = ' 
                          UPDATE '+@sTableTmp+' 
                             SET NRD = '+CAST(@NrRendor AS VARCHAR)+', TIPKLL = ''K'', '+@sColumnName+'=ISNULL('+@sColumnName+',0),'+@sColumnName+'_KONV=ISNULL('+@sColumnName+'_KONV,0);';
                    EXEC (@sSql);      
          


-- 2.2.5. Modifikohet Sasi e kollones sipas dokumentit Order
               
                     SET  @sSql = ' 
                          UPDATE A 
                             SET A.'+@sColumnName+'      = CASE WHEN '+CAST(@ZerimSasi AS Varchar)+'=1 
                                                                THEN ISNULL(B.SASI,0)
                                                                ELSE ISNULL(A.'+@sColumnName+',0)      + ISNULL(B.SASI,0) 
                                                           END,
                                 A.'+@sColumnName+'_KONV = CASE WHEN '+CAST(@ZerimSasi AS Varchar)+'=1 
                                                                THEN ISNULL(B.SASIKONV,0)
                                                                ELSE ISNULL(A.'+@sColumnName+'_KONV,0) + ISNULL(B.SASIKONV,0) 
                                                           END                       
                            FROM '+@sTableTmp+' A INNER JOIN #NewOrders B ON A.KOD=B.KOD AND B.KODAF='''+@sColumnName+''';';

                    EXEC (@sSql);
                  END
                   
             SET @i = @i + 1;
                
          END;

-- 2.2.   FUND:    KOLLONAT E REJA (Magazinat,Dyqanet ose Klientet)



-- 2.3.   FILLIM:  Azhurnimi i fushave totale kollona

         SET  @FieldsEx = 'PERSHKRIM,KOD,NJESI,NRRENDOR,NRD,TROW,TAGNR,TOTAL_SASI,TOTAL_SASI_KONV,GJENDJE_SASI,DIFER_SASI,NRORD_SASI,USI,USM,ORDERSCR,TIPKLL';

         SET  @sFields  = '';
        EXEC  dbo.Isd_spFieldsTable  'TEMPDB', @sTableTmp, @FieldsEx, @sFields OUTPUT;
         
         SET  @sFields1  = '';
         SET  @sFields2  = '';
         SET  @i = 1;
         SET  @j = LEN(@sFields) - LEN(REPLACE(@sFields,',',''))+1;
              
         WHILE @i<= @j
           BEGIN
              SET @sField = dbo.Isd_StringInListStr(@sFields,@i,',');
               IF @sField<>''
                  BEGIN
                    IF CHARINDEX('_KONV',@sField)=0
                       SET @sFields1 = @sFields1 + ',' + @sField
                    ELSE
                       SET @sFields2 = @sFields2 + ',' + @sField;   
                  END
              SET @i = @i + 1;    
           END;
           
          IF  SUBSTRING(@sFields1,1,1)=','
              SET @sFields1 = SUBSTRING(@sFields1,2,LEN(@sFields1));
          IF  SUBSTRING(@sFields2,1,1)=','            
              SET @sFields2 = SUBSTRING(@sFields2,2,LEN(@sFields2));
          SET @sFields3 = @sFields1;
          
          IF  @sFields1<>''
              SET @sFields1   = 'TOTAL_SASI = ISNULL('+REPLACE(@sFields1,',',',0)+ISNULL(')+',0)';
          IF  @sFields2<>''
              SET @sFields2   = 'TOTAL_SASI_KONV = ISNULL('+REPLACE(@sFields2,',',',0)+ISNULL(')+',0)';
          IF  @sFields1<>'' AND @sFields2<>''
              SET @sFields1   = @sFields1+',';        -- PRINT @sFields; PRINT @sFields1; PRINT @sFields2; PRINT @sFields3;

        EXEC (' 
             UPDATE '+@sTableTmp+' 
                SET '+@sFields1+'
                    '+@sFields2+';');
                       

             
         SET  @sFields3  = 'NRORD_SASI = CASE WHEN ISNULL('+REPLACE(@sFields3,',',',0)<>0 THEN 1 ELSE 0 END + CASE WHEN ISNULL(')+',0)<>0 THEN 1 ELSE 0 END ';
        EXEC (' UPDATE '+@sTableTmp+' SET '+@sFields3);


      UPDATE  B
         SET  CREATEPIVOTORD=1
        FROM  #NewOrdersId A INNER JOIN ORK B ON A.NRRENDOR=B.NRRENDOR;
         
          IF  OBJECT_ID('TEMPDB..#NewOrders')   IS NOT NULL
              DROP TABLE #NewOrders;
          IF  OBJECT_ID('TEMPDB..#NewOrdersId') IS NOT NULL
              DROP TABLE #NewOrdersId;


       END;
       
-- 2.3.   FUND:    Azhurnimi i fushave totale kollona


--2.      FUND:     Shtim artikuj,Shtim kollona Fund
GO
