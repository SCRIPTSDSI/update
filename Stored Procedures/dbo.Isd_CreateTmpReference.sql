SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- Exec [Isd_CreateTmpReference]
--                      @PLinkServerName = 'DBORG',
--                      @PLinkServer     = 'ISDPC',
--                      @PLinkServerDb   = 'EHW13',
--                      @PTableName      = 'ARTIKUJ',
--                      @PTableTmpName   = '##ARTIKUJ1234567',
--                      @PWhere          = ''


CREATE        procedure [dbo].[Isd_CreateTmpReference]

-- Me LinkedServer dhe perdoret tek Importi

(
  @PLinkServerName    As Varchar(30),  
  @PLinkServer        As Varchar(30),  
  @PLinkServerDb      As Varchar(30),  
  @PTableName         As Varchar(30),  
  @PTableTmpName      As Varchar(30),  -- Random
  @PWhere             As Varchar(1000)
 )

As


--									P E R G A T I T J E   T E   S T R U K T U R A V E

Declare @TableName       Varchar(50),
        @Sql             Varchar(Max),
        @Thonjez         Varchar(5),
        @TableTmpName    Varchar(50),
        @Where           Varchar(1000)

    Set @TableName     = IsNull(@PTableName,'');
    Set @Thonjez       = QuoteName('','''')
    Set @Where         = '';
    if  @PWhere<>''
        Set @Where     = @PWhere;

Declare @LinkServerName      Varchar(50),
        @LinkServer          Varchar(50),
        @LinkServerCatalog   Varchar(50),
        @LinkServerTable     VarChar(300)

    Set @LinkServerTable   = ''
    Set @LinkServerName    = QuoteName(@PLinkServerName,'''')
    Set @LinkServer        = QuoteName(@PLinkServer, '''')
    Set @LinkServerCatalog = QuoteName(@PLinkServerDb,'''')

     if @LinkServerName<>'' 
        begin
          Set  @LinkServerTable       = @PLinkServerName+'.'+@PLinkServerDb+'.DBO.'
          Exec(' SP_DROPSERVER        '+@LinkServerName+',"Droplogins"')
          Exec(' SP_ADDLINKEDSERVER   '+@LinkServerName+','+@Thonjez+',"SQLOLEDB",'+@LinkServer+','+@Thonjez+','+@Thonjez+','+@LinkServerCatalog)
          Exec(' SP_ADDLINKEDSRVLOGIN '+@LinkServerName+',False,null,"sa",'+@Thonjez)
        end;
   
--										F A Z A    E S T R U K T U R A V E 

    Set NoCount Off

    Set @TableTmpName    = @PTableTmpName;
    Set @LinkServerTable = @LinkServerTable+@TableName;

    if  Object_Id('TempDB..'+@TableTmpName) is not null
        Exec ('Drop Table '+@TableTmpName);

    Set @Sql = '
          SELECT *
            INTO '+ @TableTmpName+'
            FROM '+ @LinkServerTable+
        '  WHERE 1=1 ';
    if @Where<>''
       Set @Sql = Replace(@Sql,'1=1',@Where);

    Print @Sql
    Exec(@Sql);

 -- Exec(' SP_DROPSERVER        '+@LinkServerName+',"Droplogins"');

--							F U N D I  I  P E R G A T I T J E   T E   S T R U K T U R A V E

/*
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber,
           ERROR_SEVERITY() AS ErrorSeverity,
           ERROR_STATE() AS ErrorState,
           ERROR_PROCEDURE() AS ErrorProcedure,
           ERROR_MESSAGE() AS ErrorMessage,
           ERROR_LINE() AS ErrorLine
    --SELECT ErrorVar = @@ERROR,  RowCountVar = @@ROWCOUNT
END CATCH
*/

    Set NoCount On

GO
