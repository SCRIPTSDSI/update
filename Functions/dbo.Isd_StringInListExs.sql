SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   FUNCTION [dbo].[Isd_StringInListExs]
( 
  @PList   NVarchar(4000),
  @PString Varchar(50)
  )
Returns Bit
AS
begin
-- Dikur quhej Isd_StringInList dhe funksioni me emer Isd_StringInList te fshihet...

  Declare @Result Bit

      Set @Result = 0
      
       if Exists(Select * 
                   From dbo.Split(@PList,',')
                  Where Splitet=@PString)
          Set @Result = 1

   Return @Result

end


GO
