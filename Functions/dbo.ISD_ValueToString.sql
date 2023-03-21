SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   FUNCTION [dbo].[ISD_ValueToString]
(@PValue AS Float)
Returns Varchar(1024)
AS
begin
  Declare @Result      Varchar(1024),
          @StrVlera    Varchar(1024),
          @Lidhez      Varchar(10),
          @Vlera       Float,
          @IntVlera    Int,
          @i           Int,
          @Str         Varchar(20)

  if @PValue=0
     Set @Result = 'zero'
  else
     begin
       Set @Result = ''
       Set @Lidhez = ''
       Set @i      = 1

       Select @Vlera  = Abs(@PValue), @IntVlera = Floor(Abs(@PValue))

       Select @StrVlera = LTrim(RTrim(Cast(@IntVlera As Varchar)))
       Select @StrVlera = Substring('000000000000000',1,15-Len(@StrVlera))+@StrVlera;

	  while @i <= 5 
		begin 
          Select @Str = Case When @i=1 Then  'bilion'
                             When @i=2 Then  'miliard'
                             When @i=3 Then  'milion'
                             When @i=4 Then  'mije'
                             else '' End
		  if  Substring(@StrVlera, 3*@i-2,3)<>'000' 
			  begin 
			    Set @Result  = @Result + @Lidhez + 
                               Dbo.ISD_Value3CharToString(Substring(@StrVlera,3*@i-2,3)) + ' '+
                               @Str
			    if  @Result<>''
				    Set @Lidhez=' e '
			  end
		  Set @i = @i + 1
		end

      if @Vlera-@IntVlera>0
         begin
           Set @Lidhez = ''
           if  @Result<>''
               Set @Lidhez=' e '
           Set @Result = @Result + @Lidhez + Substring(Cast(@Vlera-@IntVlera As Varchar),3,10)+' te qindat';
         end

     end
    
  if @PValue<0
     Set @Result = 'minus '+@Result

  Return @Result
end




GO
