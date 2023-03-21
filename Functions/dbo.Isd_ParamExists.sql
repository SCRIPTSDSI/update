SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   FUNCTION [dbo].[Isd_ParamExists]
(
 @PObjectName Varchar(100),
 @PParamName  Varchar(30)
)
Returns Bit 

As

Begin

	Declare @Result  Bit

        Set @Result = 0

         if Exists ( Select Parameter_Name 
                       from Information_Schema.PARAMETERS
                      where SPECIFIC_NAME = @PObjectName And Parameter_Name=@PParamName And Parameter_Name<>'')
            Set @Result = 1

	Return @Result

End
GO
