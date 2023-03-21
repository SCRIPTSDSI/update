SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   FUNCTION [dbo].[Isd_StringInListIns]
( 
  @PList      Varchar(Max),
  @PStrIns    Varchar(100),
  @PIndex     Int,
  @PDelimiter Varchar(10)  
)

  Returns NVarchar(4000)

AS
begin

-- Inserton ne Segmentin e i-te vleren @PStrIns


--Declare @PList    Varchar(100),
--        @PStrIns  Varchar(30),
--        @PIndex   Int
--Set @PList   ='123.35.26.256.EU'
--Set @PStrIns ='AAAAA'
--Set @PIndex  = 4

  Declare @Result  Varchar(Max)
  Declare @List    Varchar(Max)
  Declare @iOrd    Int
  Declare @At1     Int
  Declare @At2     Int
  Declare @InsPike Int
  
      Set @List    = @PList
      Set @Result  = LTrim(RTrim(Isnull(@List,'')))
      Set @iOrd    = -1
      Set @At1     = 0
      Set @At2     = 0
      Set @InsPike = 0
       if @PDelimiter=''
          Set @PDelimiter = '.'


  if Len(@List)-Len(Replace(@List,@PDelimiter,''))+1>=@PIndex 
  -- Nr i dhene me i vogel ose baras me nr e pikave+1

     begin
 	   if Substring(@List,Len(@List),1)<>@PDelimiter 
	 	  begin
		    Set @List    = @List + @PDelimiter
		    Set @InsPike = 1
		  end

	   if CharIndex(@PDelimiter,@List)>0
	 	  begin
		    Set @At1  = 0
		    Set @At2  = CharIndex(@PDelimiter,@List)
		    Set @iOrd = 1
		  end

	   While @iOrd<@PIndex
		 begin
		   if CharIndex(@PDelimiter,@List,@At1+1)>0
		 	  begin
			    Set @At1  = @At2 
				Set @At2  = CharIndex(@PDelimiter,@List,@At1+1) 
				Set @iOrd = @iOrd + 1
			  end
		   else
              Break
		 end

	   if @iOrd = @PIndex 
		  begin
		    if @At2<=@At1
		 	   Set @At2 = @At1+1
		    if @At1+1 > Len(@List) 
			   Set @Result = @List + @PStrIns
		    else
			   Set @Result = Stuff(@List, @At1+1, @At2-@At1-1, @PStrIns)
		  end 

	   if @InsPike=1
		  Set @Result = Stuff(@Result,Len(@Result),1,'')


     end

  Return (LTrim(RTrim(Isnull(@Result,''))))

End

GO
