SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   FUNCTION [dbo].[Isd_ListTablesDR]
( 
  @PListExcept Varchar(Max),
  @PTableStr   Varchar(10)
 )
Returns Varchar(Max)

AS

Begin

if dbo.Isd_StringInListExs('DOC,REF', @PTableStr)=0   -- Document ose Reference
   Return ''

Declare @Result     Varchar(Max),
        @ListTables Varchar(Max)

    Set @Result     = ''
    Set @ListTables = dbo.Isd_ListTables('',@PListExcept)
    

      Select @Result =  @Result +','+[TableName]
        From CONFIG..TablesName A
       Where TableStr=@PTableStr And  -- 'REF' Or 'DOC'
            (dbo.Isd_StringInListExs(@ListTables, [TableName])=1) And
            (dbo.Isd_StringInListExs(@PListExcept,[TableName])=0)
    Order By A.NrOrder

  
  if CharIndex(',',@Result)=1 
     Set @Result = Stuff(@Result,1,1,'')


  Return @Result


End

GO
