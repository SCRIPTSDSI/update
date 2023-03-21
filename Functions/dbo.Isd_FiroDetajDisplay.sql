SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   FUNCTION [dbo].[Isd_FiroDetajDisplay]
(
  @pFiro    VARCHAR(10)
)

  RETURNS   VARCHAR(50)

AS

BEGIN

-- SELECT A = dbo.Isd_DisplayPromptFiro ('B')

     DECLARE @sFiro        VARCHAR(10),
             @Result       VARCHAR(50);
 
         SET @sFiro      = @pFiro;      
         SET @Result     = '';   

      SELECT @Result = CASE @sFiro WHEN 'A' THEN CASE WHEN ISNULL(FIRAPROMPT,'') = '' THEN 'Firo klasa - A' ELSE FIRAPROMPT END                                       
                                   WHEN 'B' THEN CASE WHEN ISNULL(FIRBPROMPT,'') = '' THEN 'Firo klasa - B' ELSE FIRBPROMPT END
                                   WHEN 'C' THEN CASE WHEN ISNULL(FIRCPROMPT,'') = '' THEN 'Firo klasa - C' ELSE FIRCPROMPT END                                        
                                   WHEN 'D' THEN CASE WHEN ISNULL(FIRDPROMPT,'') = '' THEN 'Firo klasa - D' ELSE FIRDPROMPT END                                         
                                   WHEN 'E' THEN CASE WHEN ISNULL(FIREPROMPT,'') = '' THEN 'Firo klasa - E' ELSE FIREPROMPT END                                         
                                   WHEN 'F' THEN CASE WHEN ISNULL(FIRFPROMPT,'') = '' THEN 'Firo klasa - F' ELSE FIRFPROMPT END                                        
                                   WHEN 'G' THEN CASE WHEN ISNULL(FIRGPROMPT,'') = '' THEN 'Firo klasa - G' ELSE FIRGPROMPT END                                        
                                   WHEN 'H' THEN CASE WHEN ISNULL(FIRHPROMPT,'') = '' THEN 'Firo klasa - H' ELSE FIRHPROMPT END                                        
                                   WHEN 'I' THEN CASE WHEN ISNULL(FIRIPROMPT,'') = '' THEN 'Firo klasa - I' ELSE FIRIPROMPT END                                        
                                   WHEN 'J' THEN CASE WHEN ISNULL(FIRJPROMPT,'') = '' THEN 'Firo klasa - J' ELSE FIRJPROMPT END                                        
                                   ELSE ''
                          END
        FROM CONFIGMG

     RETURN @Result

END
GO
