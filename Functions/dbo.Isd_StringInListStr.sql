SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   FUNCTION [dbo].[Isd_StringInListStr]
( 
  @PList      NVarchar(4000),
  @PIndex     Int,
  @PDelimiter Varchar(10)  
  )
Returns NVarchar(4000)
AS
begin


   Declare @Result   NVarchar(4000),
           @Ind1     Int,
           @Ind2     Int,
           @Ind      Int,
 
           @StrList  NVarchar(4000)

       Set @Result = ''

       Set @Ind    = 0
        if @PDelimiter=''
           Set @PDelimiter = ','
       Set @StrList = @PDelimiter + @PList + @PDelimiter

  while (@StrList<>'') and (@StrList<>@PDelimiter)
     begin
       Set @Ind   = @Ind + 1
       Set @Ind1  = CharIndex(@PDelimiter,@StrList,0)
       Set @Ind2  = CharIndex(@PDelimiter,@StrList,@Ind1+1)
       if  @Ind2  = 0
           Set @Ind2 = Len(@StrList)

       if  @PIndex = @Ind
           begin
             Set @Result = Substring(@StrList,@Ind1+1,@Ind2-@Ind1-1)
             Break
           end

       Set @StrList = Substring(@StrList,@Ind2,Len(@StrList))

     end

   Return @Result

end


GO
