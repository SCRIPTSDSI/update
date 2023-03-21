SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   FUNCTION [dbo].[Isd_ListFieldsUpdate]
( 
  @PList1   NVarchar(Max),
  @PAlias1  Varchar(30),
  @PAlias2  Varchar(30)
 )

Returns Varchar(Max)

AS

Begin

  Declare @Result   Varchar(Max),
          @List1    NVarchar(Max),
          @Alias1   Varchar(20),
          @Alias2   Varchar(20),
          @Name     Varchar(Max);

      Set @Result = ''
      Set @Name   = ''
      Set @List1  = @PList1
      Set @Alias1 = @PAlias1
      Set @Alias2 = @PAlias2;

    while Len(@List1)>0
          begin
            if CharIndex(',',@List1)>=1
               begin
                 Set @Name  = Substring(@List1,1,CharIndex(',',@List1)-1);
                 Set @List1 = Substring(@List1,  CharIndex(',',@List1)+1,Len(@List1));
               end
            else 

            if @List1<>'' 
               begin
                 Set @Name  = @List1
                 Set @List1 = '' 
               end

            Set @Result = @Result + 
',
        '
                                  +@Alias1+'.'+LTrim(RTrim(@Name))+'='+@Alias2+'.'+LTrim(RTrim(@Name));

          end;

  if CharIndex(',',@Result)=1 
     Set @Result = Stuff(@Result,1,1,'');

  Return @Result;

End
GO
