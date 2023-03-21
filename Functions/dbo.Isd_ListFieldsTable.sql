SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   FUNCTION [dbo].[Isd_ListFieldsTable]
( 
  @PTableName   Varchar(50),
  @PListExcept  Varchar(Max)
 )

RETURNS Varchar(Max)

AS

BEGIN


-- quhej me pare ListFieldsTable
-- 1.
-- Exec('  USE DBRP 
--         SELECT Dbo.ListFieldsTable(''RAPORT'',''NRRENDOR,KLASIF1,KLASIF2,KLASIF'')') 

-- 2.
--DECLARE @FF Varchar(Max)
--SET @FF = ''
--Print @FF
--
--DECLARE @ListFields Varchar(Max)
--    SET @ListFields = ''
--SELECT @ListFields=DBRP.dbo.ListFieldsTable('RAPORT','NRRENDOR,KLASIF1,KLASIF2,KLASIF')
--SELECT @ListFields=EHW10_D.dbo.ListFieldsTable('ARTIKUJ','NRRENDOR,KLASIF1,KLASIF2,KLASIF')
--Print @ListFields


-- FROM EHW10_D.Sys.Columns
--Where Object_Id = Object_Id(@DBName+@PTableName)
--Where Object_Id = Object_Id('EHW10_D..'+@PTableName)


     DECLARE @Result        Varchar(Max),
             @TableName     Varchar(50),
             @ListExcept    Varchar(Max);

         SET @Result      = ''
         SET @TableName   = IsNull(@pTableName,'');
         SET @ListExcept  = IsNull(@pListExcept,'');

         IF  CHARINDEX('DATECREATE',@ListExcept)=0
             SET @ListExcept = @ListExcept+',DATECREATE';
         IF  CHARINDEX('DATEEDIT',@ListExcept)=0
             SET @ListExcept = @ListExcept+',DATEEDIT';



         IF  @TableName=''
             BEGIN
               RETURN @Result;
             END;

            
         IF CHARINDEX('#',@TableName)>0 OR CHARINDEX('TempDB..',@TableName)>0
             BEGIN

               IF CHARINDEX('TempDB..',@TableName)<=0 
                  SET @TableName='TempDB..'+@TableName

               SELECT @Result =  @Result +','+[Name]
                 FROM TempDB.Sys.Columns
                WHERE Object_Id = Object_Id(@TableName) AND (dbo.Isd_StringInListExs(@ListExcept,[Name])=0)

             END

          ELSE

             BEGIN

               SELECT @Result =  @Result +','+[Name]
                 FROM Sys.Columns
                WHERE Object_Id = Object_Id(@TableName) AND (dbo.Isd_StringInListExs(@ListExcept,[Name])=0)

             END;
  
  IF CHARINDEX(',',@Result)=1 
     SET @Result = Stuff(@Result,1,1,'')

  RETURN @Result

END


GO
