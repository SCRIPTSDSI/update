SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--  Declare @PDb1      Varchar(30),
--          @PDbase     Varchar(50),  
--          @PTablesEx  Varchar(Max),
--          @PDate      Varchar(30),
--          @PInvers    Bit
--     EXEC dbo.Isd_DeleteDocs @PDbase='EHW13', @PTablesEx='VSST,FKST', @PDate='01/06/2013', @PInvers=0, @PTrunc=1

CREATE   Procedure [dbo].[Isd_DeleteDocs2]
( 
  @PDbase     Varchar(50),  
  @PTablesEx  Varchar(Max),
  @PDate      Varchar(30),
  @PInvers    Bit,
  @PTrunc     Int
 )

AS

-- Rasti @PTrunc = 1 ne Krijim Nd/je - Rasti Import vetem Referenca, ose kur duhet Fshirje te gjitha dokumentave
-- Rasti @PTrunc = 0- Pra punohet me Date perdoret ne Ndarje Nd/je, ose Fshirje me Date te dokumentave

         SET NOCOUNT ON

     Declare @Sql          Varchar(Max),
             @TablesList   Varchar(Max),
             @TableName    Varchar(30),   
             @TableScr     Varchar(30),
             @sDbName      Varchar(30),
             @i            Int,
             @j            Int,
             @Not          Varchar(10),
             @sDitar       Varchar(30),
             @sLiber       Varchar(30),
             @sTableExtra  Varchar(30);


         SET @sDbName = DB_Name();

         IF  @PDBase<>''
             BEGIN
               SET @sDbName = @PDBase;
               SET @PDBase  = @PDBase+'..';
             END;
       
         SET @TablesList = ''
         SET @Not        = ''

         IF  @PInvers=1
             SET @Not = 'NOT'
 
      SELECT @TablesList = @TablesList + ',' + TABLENAME 
        From CONFIG..TablesName 
       Where TableStr = 'DOC'

         SET @TablesList = dbo.Isd_ListFields2Lists(@TablesList, @TablesList, @PTablesEx) 

         SET @i = 1
         SET @j = Len(@TablesList)-Len(Replace(@TablesList,',',''))+1

	   WHILE @i <= @j
		 BEGIN
		   SET @TableName = LTrim(RTrim(dbo.Isd_StringInListStr(@TablesList,@i,',')))     
           SET @i = @i + 1

           IF (@TableName<>'') And (IsNull(@PTrunc,0)=1)      -- Fshirje me Truncate per Shpejtesi

              BEGIN

                SET @TableScr = @TableName+'SCR';

                IF dbo.Isd_TableExists(@TableScr)=1
                   BEGIN
                     RAISERROR (N'  Delete te dhena tek tabela  %s  /  %s   (Trunc)', 0, 1, @TableScr, @sDbName) WITH NOWAIT     -- Print @Sql;
  		                   SET  @Sql = ' TRUNCATE TABLE ' + @PDBase + @TableScr;
		                  EXEC (@Sql);
                   END;

                RAISERROR      (N'  Delete te dhena tek tabela  %s  /  %s', 0, 1, @TableName, @sDbName) WITH NOWAIT    -- Print @Sql;
  		              SET       @Sql = ' DELETE FROM ' + @PDBase + @TableName;
		             EXEC      (@Sql);

              END;


           IF (@TableName<>'') And (IsNull(@PTrunc,0)=0)
              BEGIN

                 RAISERROR (N'  Delete te dhena tek tabela  %s  /  %s', 0, 1, @TableName, @sDbName) WITH NOWAIT 	   --  Print @Sql;
  		               SET  @Sql = ' DELETE FROM ' + @PDBase + @TableName+' WHERE '+@Not+' DATEDOK<=Dbo.DATEVALUE(''' + @PDate + ''') ';
		              EXEC (@Sql);
              END;




           SET @sTableExtra = ''; 
           SET @sDitar = '';
           SET @sLiber = '';

           IF  @TableName='ARKA'
               BEGIN
                 SET @sDitar = 'DAR';
                 SET @sLiber = 'LAR';
               END;
           IF  @TableName='BANKA'
               BEGIN
                 SET @sDitar = 'DBA'
                 SET @sLiber = 'LBA';
               END;
           IF  @TableName='FJ'
               BEGIN
                 SET @sDitar = 'DKL'
                 SET @sLiber = 'LKL';
                 SET @sTableExtra = 'FJSHOQERUES';
               END;
           IF  @TableName='FF'
               BEGIN
                 SET @sDitar = 'DFU'
                 SET @sLiber = 'LFU';
               END;
           IF  @TableName='FD'
               BEGIN
                 SET @sDitar = ''
                 SET @sLiber = 'LMG';
                 SET @sTableExtra = 'MGSHOQERUES';
               END;
           IF  @TableName='FK'
               BEGIN
                 SET @sDitar = ''
                 SET @sLiber = 'LM';
               END;


-- Ditar
           IF (@sDitar<>'') And (IsNull(@PTrunc,0)=1)
              BEGIN
                 RAISERROR (N'  Delete te dhena tek tabela  %s  /  %s   (Trunc)', 0, 1, @sDitar, @sDbName) WITH NOWAIT 	           --  Print @Sql;
  		               SET  @Sql = ' TRUNCATE TABLE ' + @PDBase + @sDitar;
		              EXEC (@Sql);
              END;
           IF (@sDitar<>'') And (IsNull(@PTrunc,0)=0)
              BEGIN
                 RAISERROR (N'  Delete te dhena tek tabela  %s  /  %s', 0, 1, @sDitar, @sDbName) WITH NOWAIT 	                   --  Print @Sql;
  		               SET  @Sql = ' DELETE FROM ' + @PDBase + @sDitar+' WHERE '+@Not+' DATEDOK<=Dbo.DATEVALUE(''' + @PDate + ''') ';
		              EXEC (@Sql);
              END;

-- Liber
           IF (@sLiber<>'') And (IsNull(@PTrunc,0)=1)
              BEGIN
                 RAISERROR (N'  Delete te dhena tek tabela  %s  /  %s   (Trunc)', 0, 1, @sLiber, @sDbName) WITH NOWAIT 	           --  Print @Sql;
  		               SET  @Sql = ' TRUNCATE TABLE ' + @PDBase + @sLiber;
		              EXEC (@Sql);
              END;
           IF (@sLiber<>'') And (IsNull(@PTrunc,0)=0)
              BEGIN
                 RAISERROR (N'  Delete te dhena tek tabela  %s  /  %s', 0, 1, @sLiber, @sDbName) WITH NOWAIT 	                   --  Print @Sql;
  		               SET  @Sql = ' DELETE FROM ' + @PDBase + @sLiber;
		              EXEC (@Sql);
              END;

-- Table te tjera 
           IF (@sTableExtra<>'') And (IsNull(@PTrunc,0)=1)
              BEGIN
                 RAISERROR (N'  Delete te dhena tek tabela  %s  /  %s   (Trunc)', 0, 1, @sTableExtra, @sDbName) WITH NOWAIT 	   --  Print @Sql;
  		               SET  @Sql = ' TRUNCATE TABLE ' + @PDBase + @sTableExtra;
		              EXEC (@Sql);
              END;
           IF (@sTableExtra<>'') And (IsNull(@PTrunc,0)=0)
              BEGIN
                 RAISERROR (N'  Delete te dhena tek tabela  %s  /  %s', 0, 1, @sTableExtra, @sDbName) WITH NOWAIT 	               --  Print @Sql;
  		               SET  @Sql = ' DELETE FROM ' + @PDBase + @sTableExtra+' WHERE '+@Not+' DATEDOK<=Dbo.DATEVALUE(''' + @PDate + ''') ';
		              EXEC (@Sql);
              END;

           PRINT '';

         END

-- Te tjera

         SET @TablesList = 'DRHUSER,DRHUSER,DITARVEPRIME';
         SET @i = 1;
         SET @j = Len(@TablesList)-Len(Replace(@TablesList,',',''))+1;

	   WHILE @i <= @j
		 BEGIN
		   SET @TableName = LTrim(RTrim(dbo.Isd_StringInListStr(@TablesList,@i,',')))     
           SET @i = @i + 1

           IF (@TableName<>'') 
              BEGIN
                RAISERROR (N'  Delete te dhena tek tabela  %s  /  %s', 0, 1, @TableName, @sDbName) WITH NOWAIT    -- Print @Sql;
  		              SET  @Sql = ' TRUNCATE TABLE ' + @PDBase + @TableName;
		             EXEC (@Sql);
              END
         END;


/*
-- Kontroll

    SELECT t.NAME AS TableName,
           i.name as indexName,
           p.[Rows],
           sum(a.total_pages) as TotalPages, 
           sum(a.used_pages) as UsedPages, 
           sum(a.data_pages) as DataPages,
          (sum(a.total_pages) * 8) / 1024 as TotalSpaceMB, 
          (sum(a.used_pages) * 8) / 1024 as UsedSpaceMB, 
          (sum(a.data_pages) * 8) / 1024 as DataSpaceMB

      FROM sys.tables t  INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
                         INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
                         INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id

     WHERE t.NAME NOT LIKE 'dt%' AND 
           i.OBJECT_ID > 255 AND   
           i.index_id <= 1

  GROUP BY t.NAME, i.object_id, i.index_id, i.name, p.[Rows]
  ORDER BY object_name(i.object_id); 
*/
GO
