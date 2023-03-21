SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   FUNCTION [dbo].[Isd_ListFields2Lists]
( @PList1  NVarchar(Max),
  @PList2  NVarchar(Max),
  @PListEx NVarchar(Max)
  )
Returns Varchar(Max)
AS
begin

  Declare @Result    Varchar(Max),
          @List1     NVarchar(Max),
          @Name      Varchar(Max)

      Set @Result  = ''
      Set @Name    = ''
      Set @List1   = @PList1

    while Len(@List1)>0
          begin
            if CharIndex(',',@List1)>=1
               begin
                 Set @Name  = Substring(@List1,1,CharIndex(',',@List1)-1)
                 Set @List1 = Substring(@List1,  CharIndex(',',@List1)+1,Len(@List1))
               end
            else 
            if @List1<>'' 
               begin
                 Set @Name  = @List1
                 Set @List1 = '' 
               end

            if  dbo.Isd_StringInListExs(@PList2,@Name)=1 and dbo.Isd_StringInListExs(@PListEx,@Name)=0
                Set @Result = @Result + ','+@Name

          end

  if CharIndex(',',@Result)=1 
     Set @Result = Stuff(@Result,1,1,'')

  Return @Result

end


GO
