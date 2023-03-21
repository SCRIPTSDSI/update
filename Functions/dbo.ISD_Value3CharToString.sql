SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




Create   FUNCTION [dbo].[ISD_Value3CharToString]
  (@PValue As Varchar(1024))
   Returns Varchar(1024)
AS
begin

  Declare @Result      Varchar(1024),
          @Njeqind     Varchar(20),
          @Dhjete      Varchar(20),
          @NrWords     Varchar(100),
          @Lidhez      Varchar(10),
          @i           Int
  Set @Result  = ''
  Set @Lidhez  = ''
  Set @Dhjete  = ''
  Set @NrWords = 'nje    ,dy     ,tre    ,kater  ,pese   ,gjashte,shtate ,tete   ,nente  '

  Set @PValue = Right('000'+@PValue,3)

  if (Substring(@PValue,1,1)<>'') and (Substring(@PValue,1,1)<>'0')
     begin
       Set @i      = Cast(Substring(@PValue,1,1) as Int)
       Set @Result = LTrim(RTrim(Substring(@NrWords,8*@i-7,7)))+'qind'
       Set @Lidhez = 'e'
     end

  if Substring(@PValue,2,1)<>'0'
     begin
       Select @Dhjete = Case When Substring(@PValue,2,2)>='11' and Substring(@PValue,2,2)<='19' 
                             Then 'mbedhjete'
                             else 'dhjete' end
       if Substring(@PValue,2,2)<='10' or Substring(@PValue,2,2)>='20'
          begin
            Select @i      = Cast(Substring(@PValue,2,1) as Int)
            Select @Result = @Result + @Lidhez + 
                             Case When Substring(@PValue,2,2)='10' 
                                  Then ''
                                  else LTrim(RTrim(Substring(@NrWords,8*@i-7,7))) End + 
                             @Dhjete
            Set @Dhjete = ''
          end
     end

  if Substring(@PValue,3,1)<>'0'
     begin
       Select @i      = Cast(Substring(@PValue,3,1) as Int)
       Select @Result = @Result + @Lidhez + +LTrim(RTrim(Substring(@NrWords,8*@i-7,7)))+@Dhjete
     end

  Set @Result =Replace(@Result, 'dydhjet',    'njezet')
  Set @Result =Replace(@Result, 'tredhjet',   'tridhjet')
  Set @Result =Replace(@Result, 'katerdhjet', 'dyzet')

  Return @Result
end


GO
