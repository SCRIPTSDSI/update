SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   FUNCTION [dbo].[Isd_DateToGjendje]
(
 @PDate Varchar(20)
)
Returns Varchar(10) 

As

Begin

	Declare @Date     Varchar(20),
            @Result   Varchar(10);

	    Set @Date   = @PDate;
        Set @Result = 'B';

     Select @Result = GJENDJE 
       From PERIUDHE 
      Where (DATA <= DBO.DATEVALUE(@Date))  And (DATA1>=DBO.DATEVALUE(@Date)) And 
            (GJENDJE In ('H','B','M','F'));

        Set @Result = IsNull(@Result,'B');

	Return (@Result)

End
GO
