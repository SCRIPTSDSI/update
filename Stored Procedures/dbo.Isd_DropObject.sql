SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[Isd_DropObject]
( 
 @pObjectName  Varchar(100)
)
As

Begin

  Declare @ObjectType Varchar(Max),
          @DropType   Varchar(Max) 

      Set @ObjectType = ''
      Set @DropType   = ''


   Select @ObjectType=[type] 
     From Sys.Objects 
    Where [Name] = @pObjectName And Schema_Id=1

 
  If @ObjectType IN ('PC', 'P')
     Select @DropType = 'PROCEDURE'

  If @ObjectType IN ('FN', 'FS', 'FT', 'IF', 'TF')
     Select @DropType = 'FUNCTION'
    
  If @ObjectType = 'AF'
     Select @DropType = 'AGGREGATE'
    
  If @ObjectType = 'U'
     Select @DropType = 'TABLE'
    
  If @ObjectType = 'V'
     Select @DropType = 'VIEW'
 
  If @DropType <> ''
     Exec ('DROP '+ @DropType + ' [' + @pObjectName + ']')

End
GO
