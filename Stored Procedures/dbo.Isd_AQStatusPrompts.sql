SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO




-- EXEC dbo.Isd_AQStatusPrompts 'ZPROVE08'




CREATE  PROCEDURE [dbo].[Isd_AQStatusPrompts] 
(
 @pKod    Varchar(60)
)

AS
 

     DECLARE @sKod           Varchar(60);
     
         SET @sKod         = @pKod;
         

      SELECT TOP 100 PERCENT
             AQBLERJE       = 'dt '+CONVERT(VARCHAR,FIRSTDTBLERJE,104)+',   '+
                              CASE WHEN ROUND(FIRSTVLEREBLERJE,0)<>0 THEN 'vlefte ' ELSE '' END+
                              REPLACE(CONVERT(VARCHAR,CAST(ROUND(FIRSTVLEREBLERJE,0)  AS MONEY),1),'.00','')+' '+
                             
                              CASE WHEN ROUND(FIRSTVLEREFATBLERJE,0)<>0 
                                   THEN ' - vlefte fat '+REPLACE(CONVERT(VARCHAR,CAST(ROUND(FIRSTVLEREFATBLERJE,0)  AS MONEY),1),'.00','')+' '+
                                                         ISNULL((SELECT TOP 1 ISNULL(KMON,'') FROM LevizjeAQAll B WHERE A.KOD=B.KARTLLG AND B.KODOPER='BL'),'') 
                                   ELSE '' 
                              END,
                       
             AQPERDORUES    =           ISNULL(LASTKODPERDORUES,'')+
                              CASE WHEN ISNULL(LASTKODPERDORUES,'')<>'' AND ISNULL(LASTPERSHKRPERDORUES,'')<>'' THEN ' ' ELSE '' END + ISNULL(LASTPERSHKRPERDORUES,'')+
                              CASE WHEN ISNULL(LASTDTPERDORUES,0)=0     THEN ''  ELSE ', dt '+ CONVERT(VARCHAR,LASTDTPERDORUES, 104) END,
                                                 
             AQLOCATION     = ISNULL(LASTKODLOCATION,'') +
                              CASE WHEN ISNULL(LASTKODLOCATION,'')<>''  AND ISNULL(LASTPERSHKRLOCATION,'')<>''  THEN ' '   ELSE '' END + ISNULL(LASTPERSHKRLOCATION,'')+
                              CASE WHEN ISNULL(LASTDTLOCATION,0)=0      THEN ''    ELSE ', dt '+CONVERT(VARCHAR,LASTDTLOCATION,  104) END,
                                                   
             AQSTATUS       = CASE WHEN ISNULL(LASTDTSHITJE,0)<>0      
                                        THEN 'Shitur dt '+CONVERT(VARCHAR,LASTDTSHITJE,104)+',   '+
                                                          CASE WHEN ROUND(LASTVLERESHITJE,0)<>0 THEN 'vlefte ' ELSE '' END+
                                                          REPLACE(CONVERT(VARCHAR,CAST(ROUND(LASTVLERESHITJE,0)  AS MONEY),1),'.00','')+' '+
                             
                                                          CASE WHEN ROUND(LASTVLEREFATSHITJE,0)<>0 
                                                               THEN ' - vlefte fat '+REPLACE(CONVERT(VARCHAR,CAST(ROUND(LASTVLEREFATSHITJE,0)  AS MONEY),1),'.00','')+' '+
                                                                   ISNULL((SELECT TOP 1 ISNULL(KMON,'') FROM LevizjeAQAll B WHERE A.KOD=B.KARTLLG AND B.KODOPER='SH'),'') 
                                                               ELSE '' 
                                                          END
             
                                   WHEN ISNULL(LASTDTSHITJE,0)<>0      THEN 'Shitur '+CONVERT(VARCHAR,LASTDTSHITJE,104)+',   '+
                                        REPLACE(CONVERT(VARCHAR,CAST(ROUND(LASTVLERESHITJE,0)  AS MONEY),1),'.00','')+' '+
                                        ISNULL((SELECT TOP 1 ISNULL(KMON,'') FROM LevizjeAQAll B WHERE A.KOD=B.KARTLLG AND B.KODOPER='SH'),'')
                                 
                                   WHEN ISNULL(LASTDTJASHTEPERD,0)<>0  THEN 'Jashte perdorimit ' +CONVERT(VARCHAR,LASTDTJASHTEPERD,104)
                                   WHEN ISNULL(LASTDTCREGJISTRIM,0)<>0 THEN 'Cregjistruar '      +CONVERT(VARCHAR,LASTDTCREGJISTRIM,104)
                                   ELSE ''
                              END,
                              
             AQBlockPrompt  = CASE WHEN ISNULL(A.LASTDTCREGJISTRIM,0)<>0 OR ISNULL(A.CREGJISTRUAR,0)=1 THEN 'Cregjistruar'
                                   WHEN ISNULL(A.LASTDTJASHTEPERD,0)<>0                                THEN 'Jashte perdorimit '  
                                   WHEN ISNULL(A.LASTDTSHITJE,0)<>0                                    THEN 'Shitur'
                                   ELSE '' 
                              END,
                              
             AQSHITJE       = 'dt '+CONVERT(VARCHAR,A.LASTDTSHITJE,104)+',   '+
                              CASE WHEN ROUND(A.LASTVLERESHITJE,0)<>0 THEN 'vlefte ' ELSE '' END +
                              REPLACE(CONVERT(VARCHAR,CAST(ROUND(A.LASTVLERESHITJE,0)  AS MONEY),1),'.00','')+' '+
                             
                              CASE WHEN ROUND(A.LASTVLEREFATSHITJE,0)<>0 
                                   THEN ' - vlefte fat '+REPLACE(CONVERT(VARCHAR,CAST(ROUND(A.LASTVLEREFATSHITJE,0)  AS MONEY),1),'.00','')+' '+
                                                         ISNULL((SELECT TOP 1 ISNULL(B.KMON,'') FROM LevizjeAQAll B WHERE A.KOD=B.KARTLLG AND B.KODOPER='SH'),'') 
                                   ELSE '' 
                              END,
                              
             AQVleftePrompt = CASE WHEN ISNULL(NRVEPRIME,0)<=0                                         THEN ''
                                   WHEN ABS(ISNULL(TOTALVLEREASSET-TOTALVLEREAMORTIZ,0))<=1 
                                        OR 
                                        ABS(ISNULL(TOTALVLEREMBETUR,0)-ISNULL(CALCULVLEREMIN1,0))<=1   THEN 'Aktivi amortizuar plotesisht'
                                   WHEN ISNULL(VLEREPERAMORTIZIM1,0)<=ISNULL(CALCULVLEREMIN1,0)        THEN 'Aktivi me gjendje nen minimale '  
                                   ELSE '' 
                              END,
                              
             CREGJISTRUAR   = ISNULL(A.CREGJISTRUAR,0)
             
        FROM dbo.Isd_AQLastOperation A 
        
       WHERE KOD=@sKod  

GO
