SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   FUNCTION [dbo].[Isd_TableExists]
( 
 @PTableName  Varchar(100)
 )
Returns Bit
AS
begin

Declare @Result Bit 
--      @IsTemp Bit
        

    Set @Result = 0
--  Set @IsTemp = 0
    
-- if CharIndex('#',@PTableName)>0 or CharIndex('TempDB..',@PTableName)>0
--    begin
--      Set @IsTemp=1
--      if CharIndex('TempDB..',@PTableName)<=0 
--         Set @PTableName='TempDB..'+@PTableName
--    end
--
 if CharIndex('#',@PTableName)>0 or CharIndex('TempDB..',@PTableName)>0
    begin
      if CharIndex('TempDB..',@PTableName)<=0 
         Set @PTableName='TempDB..'+@PTableName
      if Exists (Select [Name]
                   From TempDB.Sys.Columns
                  Where Object_Id = Object_Id(@PTableName)) 
         Set @Result = 1
    end
 else
    begin
      if Exists (Select [Name]
                   FROM Sys.Columns
                  Where Object_Id = Object_Id(@PTableName))
         Set @Result = 1 
    end

-- if CharIndex('#',@PTableName)>0 or CharIndex('TempDB..',@PTableName)>0
--    begin
--      Set @IsTemp=1
--      if CharIndex('TempDB..',@PTableName)<=0 
--         Set @PTableName='TempDB..'+@PTableName
--    end
--
-- if @IsTemp=1
--    begin
--      if Exists (Select [Name]
--                   From TempDB.Sys.Columns
--                  Where Object_Id = Object_Id(@PTableName)) 
--         Set @Result = 1
--    end
-- else
--    begin
--      if Exists (Select [Name]
--                   FROM Sys.Columns
--                  Where Object_Id = Object_Id(@PTableName))
--         Set @Result = 1 
--    end


  Return @Result

end


GO
