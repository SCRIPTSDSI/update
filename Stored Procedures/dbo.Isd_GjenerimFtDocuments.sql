SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE        Procedure [dbo].[Isd_GjenerimFtDocuments]
( 
  @pUser           Varchar(20),
  @pLgJob          Varchar(30),     
  @pTableName      Varchar(30),
  @pTmpName        Varchar(30),
  @pPershkrimScr   Varchar(200),
  @pdbOrigjine     Varchar(30),
  @pAplikoScr      Bit
 )

AS
-- EXEC dbo.Isd_GjenerimFtDocuments 'ADMIN','47531351','FJ','#TableImport', '','', 0

         SET NOCOUNT ON

     Declare @ListFields     Varchar(Max),
             @ListFieldsEx   Varchar(Max),
             @ListFields2    Varchar(Max),
             @TranNumber     Varchar(30),
             @Sql            Varchar(Max),
             @TableName      Varchar(30),
             @TmpName        Varchar(30),
             @PershkrimScr   Varchar(200),
             @dbOrigjine     Varchar(30),
             @AplikoScr      Bit,
             @User           Varchar(20),
             @LgJob          Varchar(30),
             @Tip            Varchar(5);


         SET @TableName    = @pTableName;
         SET @TmpName      = @pTmpName;
         SET @PershkrimScr = @pPershkrimScr;
         SET @dbOrigjine   = @pdbOrigjine;
         SET @AplikoScr    = @pAplikoScr;
         SET @User         = @pUser;
         SET @LgJob        = @pLgJob;
         SET @TranNumber   = Dbo.Isd_RandomNumberChars(1);

         IF  @dbOrigjine<>''
             SET @dbOrigjine = @dbOrigjine+'..';

         SET @Tip          = '';

         IF  Charindex(','+@TableName+',',',FJ,FJT,ORK,OFK,SM,')>0
             SET @Tip = 'S'
         ELSE
         IF  Charindex(','+@TableName+',',',FF,ORF,')>0
             SET @Tip = 'F';

         SET @Sql          = '

      UPDATE A
         SET NRDFK         = 0,
             NRDITAR       = 0,
             POSTIM        = 0,
             LETER         = 0,
             TAGLM         = 0,
             TAG           = 0,
             TROW          = 0,

             USI           = '''+@User+''',
             USM           = '''+@User+''',
             TAGNR         = NRRENDOR,
             TAGRND        = '''+@TranNumber+''',
             DATECREATE    = GETDATE(),
             DATEEDIT      = GETDATE()
        FROM '+@TmpName+' A; ';

        EXEC (@Sql);


         SET @ListFieldsEx = '
             ,NRRENDOR,NRDFK,NRDITAR,NRRENDDMG,NRRENDORFJT,FIRSTDOK,NRDITARSHL,NRDITARPRMC,
              NRRENDORAQ,NRRENDKF,NRFRAKSKF,NRDFTEXTRA,NRRENDOROF,NRRENDOROR,NRRENDORORGFJ,NRRENDORAMB,NRRENDORAR,NRFATST,DTFATST,EXTIMPID,EXTIMPKOMENT,EXTEXP,EXTEXPKOMENT,NRLINKAPL1,';

      SELECT @ListFields = dbo.Isd_ListFieldsTable(@TableName,@ListFieldsEx);

      SELECT @Sql = '   
      INSERT INTO '+@TableName+' 
            ('+@ListFields+') 
      SELECT '+@ListFields+'
        FROM '+@TmpName+'
       WHERE ZGJEDHUR=1
    ORDER BY DATEDOK,NRDOK;

      UPDATE A
         SET A.FIRSTDOK = '''+@Tip+'''+CAST(A.NRRENDOR AS VARCHAR) 
        FROM '+@TableName+' A 
       WHERE A.TAGRND='''+@TranNumber+'''; ';

      EXEC (@Sql);


      SELECT @ListFields  = dbo.Isd_ListFieldsTable(@TableName+'SCR','NRRENDOR,NRD')
         SET @ListFields2 = dbo.Isd_ListFieldsAlias(@ListFields,'A');
         SET @ListFields  = @ListFields +',NRD';
         SET @ListFields2 = @ListFields2+',NRD=B.NRRENDOR';

          IF @AplikoScr=1
             BEGIN
               SET @ListFields2 = REPLACE(@ListFields2,'A.PERSHKRIM,','PERSHKRIM='''+@PershkrimScr+''',');
             END;

      SELECT @Sql = '

      INSERT INTO '+@TableName+'SCR 
            ('+@ListFields+') 
      SELECT '+@ListFields2+'
        FROM '+@dbOrigjine+@TableName+'Scr A INNER JOIN '+@TableName+' B ON A.NRD=B.TAGNR
       WHERE B.TAGRND='''+@TranNumber+'''
    ORDER BY A.NRD,A.NRRENDOR; 


--  
     DECLARE @sListNr    Varchar(Max),
             @Nr1        Int,
             @Ind1       Int,
             @NrRendor   Int,
             @sNrRendor  Varchar(30);

         SET @sListNr  = '''';

      SELECT @sListNr  = @sListNr + Cast(NRRENDOR AS Varchar(30))+'',''
        FROM '+@TableName+'
       WHERE TAGRND='''+@TranNumber+'''
    ORDER BY NRRENDOR;

 	     SET @Nr1   = Len(@sListNr)-Len(Replace(@sListNr,'','',''''))+1;
	     SET @Ind1  = 1;

	   while @Ind1 <= @Nr1 
	 	 BEGIN
            SET @sNrRendor = LTrim(RTrim(dbo.Isd_StringInListStr(@sListNr,@Ind1,'','')));
            IF  @sNrRendor<>''''
                BEGIN
                  SET  @NrRendor = CAST(@sNrRendor As BigInt);
                  EXEC dbo.Isd_DocSave'+@TableName+' @NrRendor,''S'',1,'''','''+@User+''','''+@LgJob+''';
                END;

            SET @Ind1 = @Ind1 + 1;

         END;

--
      UPDATE '+@TableName+'
         SET TAGRND = ''''
       WHERE TAGRND = '''+@TranNumber+'''; ';

       EXEC (@Sql);


GO
