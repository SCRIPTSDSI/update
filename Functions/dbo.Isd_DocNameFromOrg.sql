SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   FUNCTION [dbo].[Isd_DocNameFromOrg]
( 
  @PTableOrg   Varchar(50),
  @PListExcept Varchar(Max)
 )
Returns Varchar(50)

AS

Begin

Declare @Result     Varchar(50),
        @ListTables Varchar(Max)

    Set @Result     = ''
    Set @ListTables = dbo.Isd_ListTables('',@PListExcept)
    
      Select Top 1 @Result = [TableName]
        From CONFIG..TablesName A
       Where TableStr='DOC' And  ORG=@PTableOrg And -- 'REF' Or 'DOC'
            (dbo.Isd_StringInListExs(@ListTables, [TableName])=1) And
            (dbo.Isd_StringInListExs(@PListExcept,[TableName])=0)
    Order By A.NrOrder

  Return @Result

End

GO
