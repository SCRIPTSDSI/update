SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   procedure [dbo].[Isd_OrderItemsDisplayImport_ParaKonv]
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

--     Afishon kandidatet per tu shtuar (Reshta dhe kollona)   -  Rasti @sOper = 'D'

--     Shton ne tabelen temporare (te pivotuar) artikujt e rinj dhe kollonat e reja duke azhurnuar dhe sasine  -  Rasti @sOper='A' append


-- Afishimi i dokumentave porosi te krijuara(Tabelat ORK,ORKSCR), per import tek OrderItems,OrderItemsScr

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
             A.DATEDOK,
             A.NRDOK,
             A.KMAG,
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
    
    
            IF    @pWhere<>''
                  SET  @sSql = REPLACE(@sSql,'1=1',@pWhere);

        -- PRINT  @sSql;
            EXEC (@sSql);
       
          RETURN;
       END;
       
       
       
       
       
       
       
       
    IF @sOper = 'A' -- Shtim artikuj,Shtim kollona tek tabela Tmp dhe UPDATE Sasi me sasite nga dokumentat porosi
       BEGIN
       

               IF OBJECT_ID('TEMPDB..#NewOrders') IS NOT NULL     -- Ndertohet Lista e Artikujve Porosi (Sasi + (Makine,Dyqan,Klient))
                  DROP TABLE #NewOrders;


          DECLARE @sColumns      nVARCHAR(MAX),
                  @sColumnName   VARCHAR(50),
                  @sFields       VARCHAR(MAX),
                  @FieldsEx      VARCHAR(MAX),
                  @i             INT,
                  @j             INT;
             
             
              SET @NrRendor    = @pNrRendor;
               
           SELECT KODAF        = SPACE(60),
                  KOD          = SPACE(100),
                  PERSHKRIM    = SPACE(250),
                  NJESI        = SPACE(10),
                  TIPKLL       = Space(10),
                  SASI         = CAST(0.00 AS FLOAT)
             INTO #NewOrders 
            WHERE 1=2;
          
          
              SET @sSql = '
              
      INSERT INTO #NewOrders
            (KODAF, KOD, SASI, PERSHKRIM, NJESI,TIPKLL)
      SELECT KODAF       = CASE WHEN R2.TIPI=2 OR R2.TIPI=3 THEN A.KMAG ELSE A.KODFKL END,
             KOD         = B.KARTLLG,
             SASI        = ROUND(SUM(SASI),2),
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
    ORDER BY KODAF,KOD;';
    
             SET  @sSql = REPLACE(@sSql,'1=1',@pWhere);
            EXEC (@sSql);

 -- SELECT * FROM #NewOrders


               -- 1.  RESHTAT:             *   ARTIKUJT E RINJ   *
               
       
              IF  @DeleteRows=1         -- 1.1 DELETE ROWS tek tabela Tmp pivotuar
                  BEGIN
                    EXEC (' DELETE FROM '+@sTableTmp+';');
                  END;


                                        -- 1.2 SHTIM  ROWS tek tabela Tmp pivotuar
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
    
--         PRINT  @sSql;
            EXEC (@sSql);
       
       
       
       
               -- 2   KOLLONAT:            *   KOLLONAT E REJA (Magazinat ose Klientet)   *

                                        -- 2.1 Stringu me KOLLONAT E REJA (@sColumns)

              SET @sColumns   = N'';

           SELECT @sColumns   = @sColumns+N',' + KODAF 
             FROM #NewOrders
         GROUP BY KODAF
         ORDER BY KODAF;    

              SET @sColumns = ISNULL(STUFF(ISNULL(@sColumns,''), 1, 1, N''),'');
     --     PRINT @sColumns;

              SET @i = 1;
              SET @j = LEN(@sColumns)-LEN(REPLACE(@sColumns,',',''))+1;
         
         
         
         
         IF ISNULL(@sColumns,'')=''
            RETURN;



    
                                        -- 2.2 Tek Kollonat: SHTOHEN ATO qe mungojne dhe azhurnohet sasia 


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
                SET @sColumns    = ISNULL(SUBSTRING(@sColumns, CHARINDEX(',',@sColumns)+1,LEN(@sColumns)),'')




                                        -- 2.3 Shtim i nje KOLLONE TE RE (Testohet ne se egziston)

                IF  @sColumnName<>''
                    BEGIN 
                    
                      IF  NOT EXISTS (SELECT [NAME] FROM TEMPDB.SYS.COLUMNS A WHERE A.OBJECT_ID=OBJECT_ID('TEMPDB..'+@sTableTmp) AND [NAME]=@sColumnName)
                          BEGIN
                            EXEC (' ALTER TABLE '+@sTableTmp+' ADD '+@sColumnName+' FLOAT NULL;');       -- PRINT 'Nuk Egziston '+@sColumnName;
                          END;
               



--                Pse duhet ??? 
                                        -- 2.4 VLEFTA E KOLLONES BEHET ZERO kur @ZerimSasi=1, ose behet zero kur eshte null

                   -- IF  @ZerimSasi=1       
                   --     BEGIN
                   --       EXEC (' UPDATE '+@sTableTmp+' SET '+@sColumnName+'=0;');
                   --     END
                   -- ELSE
                   --     BEGIN
                   --       EXEC (' UPDATE '+@sTableTmp+' SET '+@sColumnName+'=ISNULL('+@sColumnName+',0);');
                   --     END;
                   
                   
                    
-- Pse duhet NRD ???

                       SET  @sSql = ' UPDATE '+@sTableTmp+' SET NRD = '+CAST(@NrRendor AS VARCHAR)+', TIPKLL = ''K'', '+@sColumnName+'=ISNULL('+@sColumnName+',0);';
                      EXEC (@sSql);      
          



                                        -- 2.5 MODIFIKOHET SASI E KOLLONES sipas dokumentit Order
               
                       SET  @sSql = ' 
                           UPDATE A 
                              SET A.'+@sColumnName+' = CASE WHEN '+CAST(@ZerimSasi AS Varchar)+'=1 
                                                            THEN ISNULL(B.SASI,100)
                                                            ELSE ISNULL(A.'+@sColumnName+',0)+ISNULL(B.SASI,100) 
                                                       END  
                             FROM '+@sTableTmp+' A INNER JOIN #NewOrders B ON A.KOD=B.KOD;';
                      EXEC (@sSql);
                   END
                   
                SET @i = @i + 1;
                
              END;




              --  AZHURNIMI I TOTAL KOLLONAVE

          SET  @FieldsEx  = 'PERSHKRIM,KOD,NJESI,NRRENDOR,NRD,TROW,TAGNR,TOTAL_SASI,GJENDJE_SASI,DIFER_SASI,NRORD_SASI,USI,USM,ORDERSCR,TIPKLL';

          SET  @sFields   = '';
         EXEC  dbo.Isd_spFieldsTable  'TEMPDB', @sTableTmp, @FieldsEx, @sFields OUTPUT;
          SET  @sFields   = 'TOTAL_SASI = '+'ISNULL('+Replace(@sFields,',',',0)+ISNULL(')+',0)';
         EXEC (' UPDATE '+@sTableTmp+' SET '+@sFields);
             
             
          SET  @sFields   = '';
         EXEC  dbo.Isd_spFieldsTable  'TEMPDB', @sTableTmp, @FieldsEx, @sFields OUTPUT;
          SET  @sFields   = 'NRORD_SASI = '+'CASE WHEN ISNULL('+Replace(@sFields,',',',0)<>0 THEN 1 ELSE 0 END + CASE WHEN ISNULL(')+',0)<>0 THEN 1 ELSE 0 END ';
         EXEC (' UPDATE '+@sTableTmp+' SET '+@sFields);


           IF OBJECT_ID('TEMPDB..#NewOrders') IS NOT NULL
              DROP TABLE #NewOrders;


       END;
       
GO
