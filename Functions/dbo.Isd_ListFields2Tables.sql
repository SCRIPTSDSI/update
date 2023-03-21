SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   FUNCTION [dbo].[Isd_ListFields2Tables]
( 
  @PTable1  NVarchar(Max),
  @PTable2  NVarchar(Max),
  @PListEx  Varchar(Max)
  )
Returns Varchar(Max)
AS
begin

  Declare @Result   Varchar(Max),
          @List1    NVarchar(Max),
          @List2    NVarchar(Max)
          

      Set @List1  = dbo.Isd_ListFieldsTable(@PTable1,@PListEx)
      Set @List2  = dbo.Isd_ListFieldsTable(@PTable2,@PListEx)
      Set @Result = dbo.Isd_ListFields2Lists(@List1,@List2,@PListEx)

  Return @Result

end


GO
