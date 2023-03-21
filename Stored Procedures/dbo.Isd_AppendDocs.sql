SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   Procedure [dbo].[Isd_AppendDocs]
( 
  @PDb1       VARCHAR(90),  
  @PDb2       VARCHAR(90),  
  @PTb1       VARCHAR(90),  
  @PTb2       VARCHAR(90),
  @PWhere     VARCHAR(MAX),
  @POrder     VARCHAR(MAX),
  @PFieldsEx  VARCHAR(MAX)
 )
 
AS

        SET NOCOUNT ON
--  DECLARE @PDb1      VARCHAR(90),
--          @PDb2      VARCHAR(90),
--          @PTb1      VARCHAR(90),
--          @PTb2      VARCHAR(90),
--          @PWhere    VARCHAR(MAX),
--          @POrder    VARCHAR(MAX),
--          @PFieldsEx VARCHAR(MAX)
--      SET @PDb1   = 'EHW13'
--      SET @PDB2   = 'EHW13R'
--      SET @PTb1   = 'FD'
--      SET @PTb2   = 'FD'
--      SET @PWhere = 'KMAG=''AT'' '
--      SET @POrder = 'KMAG,DATEDOK,NRDOK'
--      SET @PFieldsEx = 'NRRENDOR,USI,USM'
--     EXEC dbo.Isd_AppendDocs @PDb1=@PDb1, @PDB2=@PDb2, @PTb1=@PTb1, @PTb2=@PTb2, @PWhere=@PWhere, @POrder=@POrder, @PFieldsEx=@PFieldsEx

  DECLARE @Sql        VARCHAR(MAX),
          @Flds1      VARCHAR(MAX),
          @Flds2      VARCHAR(MAX),
          @FldsScr1   VARCHAR(MAX),
          @FldsScr2   VARCHAR(MAX),
          @FlsEx      VARCHAR(MAX),
          @Order1     VARCHAR(MAX),
          @Order2     VARCHAR(MAX),
          @Db1        VARCHAR(90),
		  @Db2        VARCHAR(90),
		  @Tb1        VARCHAR(90),
		  @Tb2        VARCHAR(90),
		  @TbScr1     VARCHAR(90),
		  @TbScr2     VARCHAR(90),
          @ListDet    VARCHAR(MAX),
          @TableDet   VARCHAR(90),   
          @i          INT,
          @j          INT,
          @k          INT,
          @Tip        VARCHAR(10);

      SET @Sql      = '';
      SET @Flds1    = '';
      SET @Flds2    = '';
      SET @FldsScr1 = '';
      SET @FldsScr2 = '';
      SET @Db1      = @PDb1;
	  SET @Db2      = @PDb2;
	  SET @Tb1      = @PTb1;
	  SET @Tb2      = @PTb2;
	  SET @TbScr1   = @PTb1+'Scr';
	  SET @TbScr2   = @PTb2+'Scr';
      SET @FlsEx    = @PFieldsEx;
      SET @Order1   = '';

     EXEC dbo.Isd_spFields2Tables @PDb1=@Db1, @PDB2=@Db2, @PTb1=@Tb1,    @PTb2=@Tb2,    @PFieldsEx=@FlsEx, @PFields=@Flds1    Output;
       IF @Flds1=''
          RETURN;
          
     EXEC dbo.Isd_spFields2Tables @PDb1=@Db1, @PDB2=@Db2, @PTb1=@TbSCr1, @PTb2=@TbScr2, @PFieldsEx=@FlsEx, @PFields=@FldsScr1 Output;
       IF @FldsScr1=''
          RETURN;

       IF @PDb1<>''
          BEGIN
            SET @Tb1    = @PDb1+'..'+@PTb1;   
            SET @TbScr1 = @PDb1+'..'+@PTb1+'SCR';
          END
       IF @PDb2<>''
          BEGIN
            SET @Tb2    = @PDb2+'..'+@PTb2;
            SET @TbScr2 = @PDb2+'..'+@PTb2+'SCR';
          END

      SET @Flds2    = @Flds1;
      SET @FldsScr2 = @FldsScr1;


      SET @Flds1    = ','+@Flds1+','
      SET @Flds1    = REPLACE(@Flds1,',TAGNR,',      ',A.NRRENDOR,');
      SET @Flds1    = REPLACE(@Flds1,',NRDITAR,',    ',0,');
      SET @Flds1    = REPLACE(@Flds1,',NRDITARSHL,', ',0,');
      SET @Flds1    = REPLACE(@Flds1,',NRDITAR,',    ',0,');
      SET @Flds1    = REPLACE(@Flds1,',NRDFK,',      ',0,');

      SET @Flds1    = SUBSTRING(@Flds1,2,LEN(@Flds1));
      SET @Flds1    = SUBSTRING(@Flds1,1,LEN(@Flds1)-1);


      SET @FldsScr1 = ',A.'+REPLACE(@FldsScr1,',',',A.')+',';
      SET @FldsScr1 = REPLACE(@FldsScr1,',A.NRD,',        ',B.NRRENDOR,');
      SET @FldsScr1 = REPLACE(@FldsScr1,',A.NRDITAR,',    ',0,');
      SET @FldsScr1 = REPLACE(@FldsScr1,',A.NRDITARSHL,', ',0,');
      SET @FldsScr1 = REPLACE(@FldsScr1,',A.NRDITAR,',    ',0,');
      SET @FldsScr1 = REPLACE(@FldsScr1,',A.NRDFK,',      ',0,');

      SET @FldsScr1 = SUBSTRING(@FldsScr1,2,LEN(@FldsScr1));
      SET @FldsScr1 = SUBSTRING(@FldsScr1,1,LEN(@FldsScr1)-1);


      IF  @POrder<>''
          BEGIN
            SET @Order1 = ' ORDER BY '+@POrder;
          END
      ELSE
      IF  @PTb1='ARKA' 
          BEGIN
            SET @Order1 = ' ORDER BY KODAB,DATEDOK, TIPDOK, NUMDOK ';
          END
      ELSE
      IF  @PTb1='BANKA'
          BEGIN
            SET @Order1 = ' ORDER BY KODAB,DATEDOK, NUMDOK ';
          END
      ELSE
      IF  @PTb1='FK' Or @PTb1='VS'
         BEGIN
            SET @Order1 = ' ORDER BY DATEDOK,NRDOK ';
         END
      ELSE
      IF  @PTb1='FKST' Or @PTb1='VSST'
         BEGIN
            SET @Order1 = ' ORDER BY NRDOK ';
         END
      ELSE
      IF  @PTb1='FH' Or @PTb1='FD'
          BEGIN
            SET @Order1 = ' ORDER BY NRMAG,DATEDOK,NRDOK,NRFRAKS ';
          END
      ELSE
      IF  dbo.Isd_StringInListInd('FJ,FF,FJT,OFK,ORK,ORF,SM,SMBAK',@PTb1,',')>0
          BEGIN
            SET @Order1 = ' ORDER BY DATEDOK, NRDOK ';
          END;


      SET @Sql = ' 

      UPDATE '+@Tb2+' SET TAGNR=0 WHERE ISNULL(TAGNR,0)<>0;

      INSERT INTO '+@Tb2+'
            ('+@Flds2+')
      SELECT '+@Flds1+'
        FROM '+@Tb1+' A
       WHERE 1=1 AND 
            (NOT (EXISTS (SELECT 1 
                            FROM '+@Tb2+' A1
                           WHERE 3=3 AND A1.NRDOK=A.NRDOK AND YEAR(A1.DATEDOK)=YEAR(A.DATEDOK) AND 4=4 )))
'+
    @Order1+
          '

      INSERT INTO '+@TbScr2+'
            ('+@FldsScr2+')
      SELECT '+@FldsScr1+'
        FROM '+@TbScr1+' A Inner Join '+@Tb2+' B On A.NRD=B.TAGNR
       WHERE 1=1 
    ORDER BY B.NRRENDOR,A.NRD,A.NRRENDOR;';


  IF @PTb1='ARKA' Or @PTb1='BANKA'
     BEGIN
       SET @Sql = REPLACE(@Sql,'A1.NRDOK=A.NRDOK','A1.NUMDOK=A.NUMDOK');
       SET @Sql = REPLACE(@Sql,'NRDOK,','NUMDOK,');
       SET @Sql = REPLACE(@Sql,'3=3',  'A1.KODAB=A.KODAB');
       IF  @PTb1='ARKA' 
           SET @Sql = REPLACE(@Sql,'4=4','A1.TIPDOK=A.TIPDOK');
     END;


  IF @PTb1='FH' Or @PTb1='FD'
     BEGIN
       SET @Sql = REPLACE(@Sql,'3=3','A1.KMAG=A.KMAG');
       SET @Sql = REPLACE(@Sql,'4=4','A1.NRFRAKS=A.NRFRAKS');
     END;


  IF @PWhere<>''
    SET @Sql = REPLACE(@Sql,'1=1',@PWhere);

  PRINT @Sql;
  EXEC (@Sql);


  IF @PTb1='FH' Or @PTb1='FD'
     BEGIN

         SET   @Sql = '

         USE '+@PDb2+' 

      UPDATE A
         SET A.NRMAG=R.NRRENDOR
        FROM '+@PTb2+' A INNER JOIN MAGAZINA R On A.KMAG=R.KOD 
       WHERE ISNULL(A.TAGNR,0)<>0 AND A.NRMAG<>R.NRRENDOR ;

      UPDATE A
         SET A.NRRENDKLLG=R.NRRENDOR
        FROM '+@PTb2+'Scr A INNER JOIN '+@PTb2+' B On A.NRD=A.NRRENDOR 
                            INNER JOIN ARTIKUJ   R On A.KARTLLG=R.KOD 
       WHERE ISNULL(B.TAGNR,0)<>0 AND A.NRRENDKLLG<>R.NRRENDOR; ';

       PRINT @Sql;
       EXEC (@Sql);
     END;

  IF dbo.Isd_StringInListInd('FJ,FF,FJT,OFK,ORK,ORF',@PTb1,',')>0
     BEGIN

         SET   @Sql = '

         USE '+@PDb2+' 

      UPDATE A
         SET A.NRMAG=A.NRRENDOR
        FROM '+@PTb2+' A INNER JOIN MAGAZINA R On A.KMAG=R.KOD 
       WHERE ISNULL(A.TAGNR,0)<>0 AND A.NRMAG<>R.NRRENDOR; 

      UPDATE A
         SET A.NRRENDKLLG=R.NRRENDOR
        FROM '+@PTb2+'Scr A INNER JOIN '+@PTb2+' B On A.NRD=A.NRRENDOR 
                            INNER JOIN ARTIKUJ   R On A.KARTLLG=R.KOD 
       WHERE ISNULL(B.TAGNR,0)<>0 AND A.TIPKLL=''K'' AND A.NRRENDKLLG<>R.NRRENDOR; 

      UPDATE A
         SET A.NRRENDKLLG=R.NRRENDOR
        FROM '+@PTb2+'Scr A INNER JOIN '+@PTb2+' B On A.NRD=A.NRRENDOR 
                            INNER JOIN LLOGARI   R On A.KARTLLG=R.KOD 
       WHERE ISNULL(B.TAGNR,0)<>0 AND A.TIPKLL=''L'' AND A.NRRENDKLLG<>R.NRRENDOR; 

      UPDATE A
         SET A.NRRENDKLLG=R.NRRENDOR
        FROM '+@PTb2+'Scr A INNER JOIN '+@PTb2+' B On A.NRD=A.NRRENDOR 
                            INNER JOIN SHERBIM   R On A.KARTLLG=R.KOD 
       WHERE ISNULL(B.TAGNR,0)<>0 AND A.TIPKLL=''R'' AND A.NRRENDKLLG<>R.NRRENDOR;

      UPDATE A
         SET A.NRRENDKLLG=R.NRRENDOR
        FROM '+@PTb2+'Scr A INNER JOIN '+@PTb2+' B On A.NRD=A.NRRENDOR 
                            INNER JOIN KLIENT    R On A.KARTLLG=R.KOD 
       WHERE ISNULL(B.TAGNR,0)<>0 AND A.TIPKLL=''S'' AND A.NRRENDKLLG<>R.NRRENDOR; '

       PRINT @Sql;
       EXEC (@Sql);
     END;


  IF @PTb1='ARKA' Or @PTb1='BANKA'
     BEGIN

         SET   @Sql = '

         USE '+@PDb2+' 

      UPDATE A
         SET A.NRRENDORAB=R.NRRENDOR
        FROM '+@PTb2+' A INNER JOIN ARKAT  R On A.KODAB=R.KOD 
       WHERE '''+@PTb2+'''=''ARKA'' AND ISNULL(A.TAGNR,0)<>0 AND A.NRRENDORAB<>R.NRRENDOR; 

      UPDATE A
         SET A.NRRENDORAB=R.NRRENDOR
        FROM '+@PTb2+' A INNER JOIN BANKAT R On A.KODAB=R.KOD 
       WHERE '''+@PTb2+'''=''BANKA'' AND ISNULL(A.TAGNR,0)<>0 AND A.NRRENDORAB<>R.NRRENDOR; '

       PRINT @Sql;
       EXEC (@Sql);

     END;


-- Master Detail - Te dhena te Lidhura me Dokumentin
  SET @ListDet = ''
  SET @k       = dbo.Isd_StringInListInd('FJ,FD',@PTb1,',')
  
  IF  @k > 0               
      BEGIN
      
        IF  @k = 1
            SET @ListDet = 'FJSHOQERUES,FJPG'
        ELSE
        IF  @k = 2
            SET @ListDet = 'MGSHOQERUES';

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
		    SET @FldsScr1 = '';

		    EXEC dbo.Isd_spFields2Tables @PDb1=@PDb1, @PDB2=@PDb2, @PTb1=@TableDet, @PTb2=@TableDet, @PFieldsEx=@FlsEx, @PFields=@FldsScr1 Output;
		    
		    SET @FldsScr2 = 'A.'+REPLACE(@FldsScr1, ',',',A.');
		    SET @k        = dbo.Isd_StringInListInd(@FldsScr2,'A.NRD',',');
		    SET @FldsScr2 = dbo.Isd_StringInListIns(@FldsScr2,'B.NRRENDOR',@k,',');

		    SET @Sql = ' 
			   INSERT INTO '+@Tb2+'
					 ('+@FldsScr1+')
			   SELECT '+@FldsScr2+'
				 FROM '+@Tb1+' A INNER JOIN '+@PDb2+'..'+@PTb1+' B ON A.NRD=B.TAGNR
				WHERE 1=1 
             ORDER BY B.NRRENDOR,A.NRD;'

		    PRINT @Sql;
		    EXEC (@Sql);

          END;

     END;

  SET   @Sql = ' UPDATE '+@Tb2+' SET TAGNR=0 WHERE ISNULL(TAGNR,0)<>0 ';
  EXEC (@Sql);

--

   Declare @DtMin     VARCHAR(30),
           @DtMax     VARCHAR(30);
       SET @DtMin = dbo.Isd_DateMinMaxSql(0);
       SET @DtMax = dbo.Isd_DateMinMaxSql(1);


-- Ditaret
  SET @i = dbo.Isd_StringInListInd('FJ,FF,ARKA,BANKA',@PTb1,',');
  
  IF  @i > 0
      BEGIN
      
        SET @Tip = dbo.Isd_StringInListStr('S,F,A,B',@i,',');
        SET @Sql = '

        USE '+@PDb2+'

        EXEC dbo.Isd_GjenerimDitar @PDateKp = '''+@DtMin+''', 
                                   @PDateKs = '''+@DtMax+''', 
                                   @PTip    = ''A'', 
                                   @PForce  = ''0''; 
        EXEC dbo.Isd_GjenerimDitar @PDateKp = '''+@DtMin+''', 
                                   @PDateKs = '''+@DtMax+''', 
                                   @PTip    = ''B'', 
                                   @PForce  = ''0''; 
        EXEC dbo.Isd_GjenerimDitar @PDateKp = '''+@DtMin+''', 
                                   @PDateKs = '''+@DtMax+''', 
                                   @PTip    = ''S'', 
                                   @PForce  = ''0''; 
        EXEC dbo.Isd_GjenerimDitar @PDateKp = '''+@DtMin+''', 
                                   @PDateKs = '''+@DtMax+''', 
                                   @PTip    = ''F'', 
                                   @PForce  = ''0''; ';
        PRINT @Sql;
        EXEC (@Sql);

     END

  
GO
