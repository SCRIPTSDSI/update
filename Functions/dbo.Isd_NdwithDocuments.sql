SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[Isd_NdwithDocuments]
(
)
Returns Bit

As

Begin

	Declare @Result Bit;
        Set @Result = 0;

         if Exists (Select NRRENDOR From Fk)    or
            Exists (Select NRRENDOR From Arka)  or
            Exists (Select NRRENDOR From Banka) or
            Exists (Select NRRENDOR From VS)    or
            Exists (Select NRRENDOR From FH)    or           
            Exists (Select NRRENDOR From FD)    or
            Exists (Select NRRENDOR From FF)    or
            Exists (Select NRRENDOR From FJ)    or
            Exists (Select NRRENDOR From DG)    or
            Exists (Select NRRENDOR From ORK)   or
            Exists (Select NRRENDOR From ORF)   or
            Exists (Select NRRENDOR From OFK)   or
            Exists (Select NRRENDOR From FJT)

            Set @Result = 1;

	 Return @Result

End

GO
