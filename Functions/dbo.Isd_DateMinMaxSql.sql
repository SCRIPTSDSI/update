SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   FUNCTION [dbo].[Isd_DateMinMaxSql]
(
 @PMin Bit
)
Returns Varchar(30)

As


begin

  Declare @Result Varchar(30)

      Set @Result = '31/12/9999'

       if @PMin=0
          Set @Result = '01/01/1753'

   Return @Result 

end
GO
