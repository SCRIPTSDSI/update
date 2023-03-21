SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--Select dbo.Isd_ExistObject('KalimLM')

CREATE Function [dbo].[Isd_ExistObject] 
(
 @pObject Varchar(100) 
)

Returns Bit

As

Begin


  Declare @Result   Bit
      Set @Result = 0

       If Exists ( Select *
                     From dbo.SysObjects
                    Where id = Object_Id(@PObject))
          Set @Result = 1

  Return @Result

End
GO
