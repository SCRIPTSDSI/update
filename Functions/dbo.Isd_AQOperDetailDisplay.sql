SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   FUNCTION [dbo].[Isd_AQOperDetailDisplay]
(
  @pOper    VARCHAR(10)
)

RETURNS     VARCHAR(50)

AS
   
BEGIN     -- SELECT A = dbo.Isd_AQOperDetajDisplay('AM')

     DECLARE @sOper        VARCHAR(10),
             @Result       VARCHAR(50);
 
         SET @sOper      = ISNULL(@pOper,'');
         SET @Result     = '';   

 
      SELECT @Result = ISNULL(@pOper,'')+' '+ISNULL(PERSHKRIM,'')
        FROM CONFIG..TIPDOK
       WHERE TIPDOK='AQ' AND KOD=@sOper


      RETURN ISNULL(@Result,'');


END
GO
