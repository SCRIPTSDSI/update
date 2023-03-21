SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   FUNCTION [dbo].[Isd_StringInList]
( 
  @PString Varchar(50),
  @PList   NVarchar(4000)
  
  )
Returns Bit
AS
begin
-- U Riemerua Isd_StringInListExs dhe radha e parametrave

  Declare @Result Bit

      Set @Result = 0
      
       if Exists(Select * 
                   From dbo.Split(@PList,',')
                  Where Splitet=@PString)
          Set @Result = 1

   Return @Result

end


GO
