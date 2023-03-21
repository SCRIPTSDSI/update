SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   FUNCTION [dbo].[Isd_StringInListInd]
( 
  @PList      NVarchar(4000),
  @PString    Varchar(50),
  @PDelimiter Varchar(10)  
  )
Returns Int
AS
begin


   Declare @Result   Int,
           @Ind1     Int,
           @Ind2     Int,
           @Ind      Int,
 
           @String   NVarchar(4000),
           @StrList  NVarchar(4000)

       Set @Result = 0

       Set @Ind    = 0
        if @PDelimiter=''
           Set @PDelimiter = ','
       Set @StrList = @PDelimiter + @PList + @PDelimiter

  while   (@StrList<>'') and (@StrList<>@PDelimiter)
     begin
       Set @Ind   = @Ind + 1
       Set @Ind1  = CharIndex(@PDelimiter,@StrList,0)
       Set @Ind2  = CharIndex(@PDelimiter,@StrList,@Ind1+1)
       if  @Ind2  = 0
           Set @Ind2 = Len(@StrList)

       Set @String = Substring(@StrList,@Ind1+1,@Ind2-@Ind1-1)
       if  @String = @PString
           begin
             Set @Result = @Ind
             Break
           end

       Set @StrList = Substring(@StrList,@Ind2,Len(@StrList))

     end

   Return @Result

end


GO
