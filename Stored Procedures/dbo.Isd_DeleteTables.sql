SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE     procedure [dbo].[Isd_DeleteTables]
(
  @pDataBase      Varchar(100),
  @pTablesList    Varchar(3000),
  @pTableExcept   Varchar(3000)
 )

AS

-- Tables pa constrain

-- te plotesohet edhe ListExcept ....


         SET NOCOUNT ON;

     DECLARE @sSql          nVarchar(Max),
             @sSql1         nVarchar(Max),
             @sSql2         nVarchar(Max),
             @i             Int,
             @k             Int,
             @DataBase      Varchar(100),
             @TablesList    Varchar(3000),
             @ListNames     Varchar(3000),
             @TableExcept   Varchar(3000),
             @TableName     Varchar(40),
             @sSqlEx        Varchar(200);


         SET @TablesList  = @PTablesList; 
         SET @TableExcept = @pTableExcept;   -- te futet ne algoritem....
         SET @DataBase    = @pDataBase;
         SET @sSqlEx      = '';

         IF  @TablesList='' OR @DataBase=''
             RETURN;



         SET @TableExcept = RTRIM(LTRIM(@TableExcept));

         IF (@TableExcept<>'') AND SUBSTRING(@TableExcept,1,1)<>','
             SET @TableExcept = ','+@TableExcept;
             
         IF (@TableExcept<>'') AND SUBSTRING(@TableExcept,LEN(@TableExcept),1)<>','
             SET @TableExcept = @TableExcept+',';


          IF @TablesList = '*'
             BEGIN
               SET     @ListNames = '';
               SET     @sSql = ' USE    '+@DataBase+';
                                 SELECT @ListNames=@ListNames+'',''+[NAME] FROM SYS.TABLES WHERE TYPE=''U'';';
         
               EXECUTE SP_EXECUTESQL @sSql, N'@ListNames VARCHAR(3000) OUT', @ListNames OUTPUT;
               SET     @TablesList = @ListNames;
             END;
             
         SET @TablesList = RTRIM(LTRIM(@TablesList));
         IF  SUBSTRING(@TablesList,1,1)=','
             SET @TablesList = SUBSTRING(@TablesList,2,LEN(@TablesList));

         SET   @sSql = ' 
         
         USE  '+@DataBase+'
         
          IF  EXISTS ( SELECT [NAME]  FROM SYS.TABLES  WHERE OBJECT_ID = OBJECT_ID(''_TABLENAME_'') )
              BEGIN
                DROP TABLE _TABLENAME_ ;
              END; ';


         SET @i = 1;
         SET @k = LEN(@TablesList) - LEN(REPLACE(@TablesList,',','')) + 1;

       WHILE @i <= @k
          BEGIN

            SET  @TableName = REPLACE(dbo.Isd_StringInListStr(@TablesList,@i,','),' ','');
            IF  (@TableName<>'') AND CHARINDEX(','+@TableName+',',@TableExcept)=0
                BEGIN
                  SET   @sSql1     = REPLACE(@sSql,'_TABLENAME_',@TableName);
            
                --PRINT @sSql1
                  EXEC (@sSql1);
                END; 

            SET @i = @i + 1;

          END;

GO
