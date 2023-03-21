SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[Isd_DateFormatDMY]
 (
   @PDate    Datetime,
   @PFormat  Varchar(20)
  )

Returns Varchar(20)

AS
        -- Select A=dbo.Isd_DateFormatDMY(dbo.DateValue('02/03/2014'),'D_M_YY')
Begin    	  
	Declare @Result Varchar(20)

   if CharIndex(','+@PFormat+',',',DD_MM_YYYY,DD_MM_YY,D_M_YY,')=0
      Set @PFormat = 'DD_MM_YYYY';


   if @PFormat='DD_MM_YYYY'
      Set @Result = Substring(Convert(Char(10),@PDate,101),4,2) + '/' +
                    Substring(Convert(Char(10),@PDate,101),1,2) + '/' +
                    Substring(Convert(Char(10),@PDate,101),7,4);

   if @PFormat='DD_MM_YY'
      Set @Result = Substring(Convert(Char(8),@PDate,1),4,2) + '/' +
                    Substring(Convert(Char(8),@PDate,1),1,2) + '/' +
                    Substring(Convert(Char(8),@PDate,1),7,2);

   if @PFormat='D_M_YY'
      Set @Result = Convert(Varchar(8),Convert(Varchar(2),day(@PDate))   + '/' +
                                       Convert(Varchar(2),month(@PDate)) + '/' +
                                 Right(Convert(Varchar(4),year(@PDate)),2));

	Return @Result

End
GO
