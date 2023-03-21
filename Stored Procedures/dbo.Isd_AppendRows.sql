SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--  Declare @PDb1      VARCHAR(30),
--          @PDb2      VARCHAR(30),
--          @PTb1      VARCHAR(30),
--          @PTb2      VARCHAR(30),
--          @PWhere    VARCHAR(MAX),
--          @POrder    VARCHAR(MAX),
--          @PFieldsEx VARCHAR(MAX),
--          @PFieldUn  VARCHAR(30),
--          @PLinkRef  INT
--      SET @PDb1   = 'EHW13'
--      SET @PDB2   = 'EHW13R'
--      SET @PTb1   = 'KLIENT'
--      SET @PTb2   = 'KLIENT'
--      SET @PWhere = 'KOD>=''K'' AND KOD<=''K0zzzz'' '
--      SET @POrder = 'KOD'
--      SET @PFieldsEx = 'NRRENDOR,USI,USM',
--      SET @PFieldUn  = 'KOD'
--      SET @PLinkRef  = 0
--     EXEC dbo.Isd_AppendRows @PDb1=@PDb1, @PDB2=@PDb2, @PTb1=@PTb1, @PTb2=@PTb2, @PWhere=@PWhere, @POrder=@POrder, @PFieldsEx=@PFieldsEx,@PFieldUn=@PFieldUn,@PLinkRef=@PLinkRef

CREATE   Procedure [dbo].[Isd_AppendRows]
( 
  @PDb1              VARCHAR(90),  
  @PDb2              VARCHAR(90),  
  @PTb1              VARCHAR(90),  
  @PTb2              VARCHAR(90),
  @PWhere            VARCHAR(MAX),
  @POrder            VARCHAR(MAX),
  @PFieldsEx         VARCHAR(MAX),
  @PFieldUn          VARCHAR(20),
  @PLinkRef          INT           -- Import edhe/jo Referencat e Lidhura...
 )
 
AS

      SET NOCOUNT ON


  DECLARE @Sql         VARCHAR(MAX),
          @Fields1     VARCHAR(MAX),
          @Fields2     VARCHAR(MAX),
          @FlsEx       VARCHAR(MAX),
          @Db1         VARCHAR(90),
		  @Db2         VARCHAR(90),
		  @Tb1         VARCHAR(90),
		  @Tb2         VARCHAR(90),
          @FldUnique   VARCHAR(90),
          @FldOrder    VARCHAR(90),
          @ListDet     VARCHAR(MAX),
          @TableDet    VARCHAR(90),   
          @i           INT,
          @j           INT,
          @k           INT;

       IF @PDb1=''
          SET @PDb1 = Db_Name();
          
       IF @PDb2=''
          SET @PDb2 = Db_Name();


      SET @Sql       = '';
      SET @Fields1   = '';
      SET @Fields2   = '';
      SET @Db1       = @PDb1;
	  SET @Db2       = @PDb2;
	  SET @Tb1       = @PTb1;
	  SET @Tb2       = @PTb2;
      SET @FldOrder  = @POrder;
      SET @FldUnique = @PFieldUn;
      SET @FlsEx     = @PFieldsEx;
      
--    SET @FldUnique = 'KOD';
--    IF  @PFieldUn<>''
--        SET @FldUnique = @PFieldUn;

     

--    Pjesa Test    --

      IF  (@FldOrder<>'') AND (CHARINDEX(',',@FldOrder)=0) AND (dbo.Isd_FieldTableExists(@Tb1,@FldOrder)=0)
          SET @FldOrder  = '';

      IF  dbo.Isd_FieldTableExists(@Tb1,@FldUnique)=0
          SET @FldUnique = '';


--    Rasti me Detail duhet patjeter TAGNR
	  SET @k = dbo.Isd_StringInListInd('ARTIKUJ,KLIENT,LISTFIROM',@PTb1,',');
	  
      IF  (@k>0) AND (@PLinkRef>0)               -- Master Detail
          BEGIN

            SET @k = dbo.Isd_StringInListInd(@FlsEx,'TAGNR',',');
            IF  @k > 0
                SET @FlsEx = dbo.Isd_StringInListIns(@FlsEx,'',@k,',');

          END;

--    Fund Pjesa Test    --




      SET @Fields1 = '';

     EXEC dbo.Isd_spFields2Tables @PDb1=@PDb1, @PDB2=@PDb2, @PTb1=@PTb1, @PTb2=@PTb2, @PFieldsEx=@FlsEx, @PFields=@Fields1 Output;

       IF @Fields1=''
          BEGIN
            PRINT 'Asnje rekord nuk u shtua ..!';
            RETURN;
          END;

      SET @Fields2 = @Fields1;

       IF @PDb1<>''
          SET @Tb1 = @PDb1+'..'+@PTb1;
             
       IF @PDb2<>''
          SET @Tb2 = @PDb2+'..'+@PTb2;

       IF @PTb1='NIPT'
          SET @FldUnique = 'NIPT';

       SET @ListDet = '';
	   SET @k       = dbo.Isd_StringInListInd('ARTIKUJ,KLIENT,LISTFIROM',@PTb1,',');
	   
       IF  (@k > 0) AND (@PLinkRef > 0)                        -- Master Detail
           BEGIN

             IF  @k = 1
                 SET @ListDet = 'ARTIKUJSCR,ARTIKUJBCSCR'  -- Lista e detajeve
             ELSE

             IF  @k = 2
                 SET @ListDet = 'KLIENTCM'
             ELSE

             IF  @k = 3
                 SET @ListDet = 'LISTFIROD';

             SET @i       = dbo.Isd_StringInListInd(@Fields2,'TAGNR',',');
             SET @Fields2 = dbo.Isd_StringInListIns(@Fields2,'NRRENDOR',@i,',');

           END;

       IF @FldUnique<>''
          BEGIN
          
		    SET @Sql = ' 
		  
	          INSERT INTO '+@Tb2+'
			        ('+@Fields1+')
	          SELECT '+@Fields2+'
		        FROM '+@Tb1+' A
		       WHERE 1=1 AND (NOT (EXISTS (SELECT '+@FldUnique+' 
							                 FROM '+@Tb2+' B 
							                WHERE A.'+@FldUnique+'=B.'+@FldUnique+') ) )  ';
          END

       ELSE
          BEGIN
          
		     SET @Sql = ' 
		  
	          INSERT INTO '+@Tb2+'
			        ('+@Fields1+')
	          SELECT '+@Fields2+'
		        FROM '+@Tb1+' A
		       WHERE 1=1 ';
		  END;



       IF @PWhere<>''
          SET @Sql = REPLACE(@Sql, '1=1', @PWhere);

       IF @FldOrder<>''
          SET @Sql = @Sql + '
     ORDER BY '+@FldOrder;

  PRINT @Sql;
  EXEC (@Sql);



-- Master Detail

  IF @ListDet<>''        
     BEGIN

       SET @i = 1;
       SET @j = LEN(@ListDet)-LEN(REPLACE(@ListDet,',',''))+1;
       
	   WHILE @i <= @j
		 BEGIN
		 
		 
		   SET @TableDet = LTrim(RTrim(dbo.Isd_StringInListStr(@ListDet,@i,',')));     
           SET @i = @i + 1;

		   IF @PDb1<>''
			  SET @Tb1 = @PDb1+'..'+@TableDet;
		   IF @PDb2<>''
			  SET @Tb2 = @PDb2+'..'+@TableDet;
		   SET @Fields1 = '';

		   EXEC dbo.Isd_spFields2Tables @PDb1=@PDb1, @PDB2=@PDb2, @PTb1=@TableDet, @PTb2=@TableDet, @PFieldsEx=@FlsEx, @PFields=@Fields1 Output;

		   SET @Fields2 = 'A.'+REPLACE(@Fields1, ',',',A.');
		   SET @k       = dbo.Isd_StringInListInd(@Fields2,'A.NRD',',');
		   SET @Fields2 = dbo.Isd_StringInListIns(@Fields2,'B.NRRENDOR',@k,',');

		   SET @Sql = ' 

			   INSERT INTO '+@Tb2+'
					 ('+@Fields1+')
			   SELECT '+@Fields2+'
				 FROM '+@Tb1+' A INNER JOIN '+@PDb2+'..'+@PTb1+' B ON A.NRD=B.TAGNR
				WHERE 1=1; ';

		   PRINT @Sql;
		   EXEC (@Sql);
         END

	   SET   @Sql = ' 
			   UPDATE '+@PDb2+'..'+@PTb1+' SET TAGNR=0 WHERE ISNULL(TAGNR,0)>0	';

	   EXEC (@Sql);

     END

GO
