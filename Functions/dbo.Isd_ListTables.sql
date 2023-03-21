SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   FUNCTION [dbo].[Isd_ListTables]
( 
  @pDbName       Varchar(50),
  @pListExcept   Varchar(Max)
 )

  Returns Varchar(Max)

AS

Begin

-- quhej me pare ListFieldsTable

-- Exec('SELECT Dbo.ListFieldsTable(''RAPORT'',''NRRENDOR,KLASIF1,KLASIF2,KLASIF'')') 


     Declare @Result    Varchar(Max);
         Set @Result  = '';
    
    
          if CharIndex('TempDB',@pDbName)>0
             begin

                 Select @Result =  @Result +','+[Name]
                   From TempDB.Sys.Objects A
                  Where A.Type='U' And (dbo.Isd_StringInListExs(@pListExcept,[Name])=0)
               Order By A.Name

             end

          else
             begin

                 Select @Result =  @Result +','+[Name]
                   From Sys.Objects A
                  Where A.Type='U' And (dbo.Isd_StringInListExs(@pListExcept,[Name])=0)
               Order By A.Name

             end;
    
  
          if CharIndex(',',@Result)=1 
             Set @Result = Stuff(@Result,1,1,'');


      Return @Result;


End


GO
