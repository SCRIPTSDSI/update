SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Exec [Isd_GetKodArtikull] 'P100','AA',1,10,1 --@PCmim Output

CREATE        Function [dbo].[Isd_GetKodArtikullExtra]
( 
  @pKod        Varchar(60)
 )

RETURNS Varchar(60)
 
AS

BEGIN


-- Algoritem extra ....

      RETURN ISNULL(@pKod,'')
      
      
END

  
GO
