SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   FUNCTION [dbo].[Isd_FieldTableExists]
( @PTableName Varchar(50),
  @PFieldName Varchar(50)
 )
Returns Int

As

Begin

  Declare @Result   Int 
      Set @Result = 0
 
 if CharIndex('#',@PTableName)>0 or CharIndex('TempDB..',@PTableName)>0
    begin
      if  CharIndex('TempDB..',@PTableName)<=0 
          Set @PTableName = 'TempDB..'+@PTableName
      if Exists (Select Name
                   From TempDB.Sys.Columns
                  Where Object_Id = Object_Id(@PTableName) And (Name=@PFieldName))
         Set @Result = 1
    end
 else
    begin
      if Exists (Select Name
                   From Sys.Columns
                  Where Object_Id = Object_Id(@PTableName) And (Name=@PFieldName))
         Set @Result = 1
    end

  Return @Result

end



GO
