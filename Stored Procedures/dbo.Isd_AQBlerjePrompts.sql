SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO




-- EXEC dbo.Isd_AQBlerjePrompts 'X01000001',0;




CREATE  PROCEDURE [dbo].[Isd_AQBlerjePrompts] 
(
 @pKod          Varchar(60),
 @pMirembajtje  Int
)

AS
 

     DECLARE @sKod            Varchar(60),
             @iMirembajtje    Int;
     
         SET @sKod          = @pKod;  
         SET @iMirembajtje  = @pMirembajtje;
         
      SELECT
             AQBLERJE       = CASE WHEN ISNULL(FIRSTDTBLERJE,0)<>0     THEN 'Blerje dt '+CONVERT(VARCHAR,FIRSTDTBLERJE,104)
                                   WHEN ISNULL(FIRSTDTCELJE,0) <>0     THEN 'Celje dt ' +CONVERT(VARCHAR,FIRSTDTCELJE, 104)
                                   ELSE                                     'Aktivi pa veprim Blerje/Celje.'
                              END,
                       
             AQPROMPT       = CASE WHEN ISNULL(@iMirembajtje,0)=1                               THEN 'Veprimi: Mirembajtje/Sherbim'
                                   WHEN ISNULL(FIRSTDTBLERJE,0)<>0 OR ISNULL(FIRSTDTCELJE,0)<>0 THEN 'Veprimi: Riparim kapital ' 
                                   ELSE                                                              'Veprimi: Blerje aktivi'
                              END,
                                                 
             AQBlockPrompt  = CASE WHEN ISNULL(LASTDTCREGJISTRIM,0)<>0 THEN 'Kujdes: Aktivi i Cregjistruar'
                                   WHEN ISNULL(LASTDTJASHTEPERD,0)<>0  THEN 'Kujdes: Aktivi i Jashte perdorimit '  
                                   WHEN ISNULL(LASTDTSHITJE,0)<>0      THEN 'Kujdes: Aktivi i Shitur'
                                   ELSE '' 
                              END
                              
        FROM dbo.Isd_AQLastOperation A 
        
       WHERE KOD=@sKod   
GO
