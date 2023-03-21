SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE Procedure [dbo].[Isd_DisplayListFields]
(
  @PTableName Varchar(100)
 )
as

       Set NoCount Off

Declare @TableName   Varchar(100)
    Set @TableName = @PTableName --'ARKASCR'

 Select DataBaseName,
        TableName,
        FieldName,
        FieldType,
        FieldLength,
        FieldOrdinal,

        FieldPrompt  = Case When A1.NrRendor <>0 Then A1.FieldPrompt Else Lower(A1.FieldName) End,
        FieldWidth   = Case When A1.NrRendor <>0 
                            Then A1.FieldWidth  
                            Else Case When FieldType in ('int','bigint','smallint','tinyint','float','real',
                                                         'money','numeric','decimal')         Then 60
                                      When FieldType in ('varchar','nvarchar','text','ntext') Then 100
                                      When FieldType in ('datetime','smalldatetime')          Then 70
                                      When FieldType in ('bit','char','nchar')                Then 40
                                      Else A1.FieldLength
                                      End
                            End,
        FieldInGrid,
        FieldVisible,
        FieldKodList,
        FieldSqlList,
        A1.NrRendor
        Into #AAAAAAAA

  From 
 
(Select 
        DataBaseName = A.Table_Catalog,
        TableName    = @TableName,
        FieldName    = A.Column_Name,
        FieldType    = A.Data_Type,
        FieldLength  = A.Character_Maximum_Length,
        FieldOrdinal = A.Ordinal_Position,

        NrRendor     = IsNull(B.NrRendor,0),
        FieldPrompt  = B.Prompt,
        FieldWidth   = B.Width,
        FieldInGrid  = IsNull(B.InGrid,0),
        FieldVisible = IsNull(B.Visible,0),
        FieldKodList = IsNull(B.KodList,''),
        FieldSqlList = IsNull(B.SqListe,'')

   From INFORMATION_SCHEMA.COLUMNS A Left Join TBLSF B On A.Table_Name=B.TableName And A.Column_Name=B.FieldName
  Where TABLE_NAME=@TableName ) A1 

Select * From #AAAAAAAA
GO
