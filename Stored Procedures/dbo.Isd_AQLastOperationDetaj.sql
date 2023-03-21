SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE          procedure [dbo].[Isd_AQLastOperationDetaj]
(
  @pKod            Varchar(60),
  @pAllDetails     Int
)

AS

-- Exec Isd_AQLastOperationDetaj 'X01000001',1
             
         SET NOCOUNT ON;


     DECLARE @sKod            Varchar(60),
             @iAllDetails     Int;

         SET @sKod          = @pKod;
         SET @iAllDetails   = @pAllDetails;



      SELECT DISTINCT Kod, Veprimi, Vlefta, Nr, TRow

        FROM Isd_AQLastOperation 

             Cross Apply   

                     ( SELECT Nr=1, TRow=CAST(1 AS BIT),Veprimi='Date blerje',                   Vlefta = CONVERT(VARCHAR(20),FIRSTDTBLERJE,   104)
             UNION ALL SELECT Nr=2, TRow=CAST(0 AS BIT),Veprimi='Vlefte blerje',                 Vlefte = REPLACE(CONVERT(VARCHAR,CAST(ROUND(FIRSTVLEREBLERJE,0)    AS MONEY),1),'.00','')
             UNION ALL SELECT Nr=3, TRow=CAST(1 AS BIT),Veprimi='Date amortizim fundit',         Vlefta = CONVERT(VARCHAR(20),LASTDTAMORTIZ,   104)  
             UNION ALL SELECT Nr=4, TRow=CAST(0 AS BIT),Veprimi='Vlefte amortizim fundit',       Vlefta = REPLACE(CONVERT(VARCHAR,CAST(ROUND(LASTVLEREAMORTIZ,0)    AS MONEY),1),'.00','')
             UNION ALL SELECT Nr=5, TRow=CAST(1 AS BIT),Veprimi='Date riparim kapital fundit',   Vlefte = CONVERT(VARCHAR(20),LASTDTMIREMBAJ,  104)
             UNION ALL SELECT Nr=6, TRow=CAST(0 AS BIT),Veprimi='Vlefte riparim kapital fundit', Vlefte = REPLACE(CONVERT(VARCHAR,CAST(ROUND(LASTVLEREMIREMBAJ,0)   AS MONEY),1),'.00','')
             UNION ALL SELECT Nr=7, TRow=CAST(1 AS BIT),Veprimi='Date rivleresim fundit',        Vlefte = CONVERT(VARCHAR(20),LASTDTRIVLER,  104)
             UNION ALL SELECT Nr=8, TRow=CAST(0 AS BIT),Veprimi='Vlefte rivleresim fundit',      Vlefte = REPLACE(CONVERT(VARCHAR,CAST(ROUND(LASTVLERERIVLER,0)     AS MONEY),1),'.00','')
             UNION ALL SELECT Nr=9, TRow=CAST(0 AS BIT),Veprimi='Date perdorim fundit',          Vlefte = CONVERT(VARCHAR(20),LASTDTPERDORUES, 104) 
             UNION ALL SELECT Nr=10,TRow=CAST(1 AS BIT),Veprimi='Perdorues fundit',              Vlefte = LASTKODPERDORUES
             UNION ALL SELECT Nr=11,TRow=CAST(0 AS BIT),Veprimi='Date vendndodhje fundit',       Vlefte = CONVERT(VARCHAR(20),LASTDTLOCATION,  104)
             UNION ALL SELECT Nr=12,TRow=CAST(1 AS BIT),Veprimi='Vendndodhje fundit',            Vlefte = LASTKODLOCATION
             UNION ALL SELECT Nr=13,TRow=CAST(1 AS BIT),Veprimi='Vlere historike ',              Vlefte = REPLACE(CONVERT(VARCHAR,CAST(ROUND(TOTALVLEREASSET,0)     AS MONEY),1),'.00','')
             UNION ALL SELECT Nr=14,TRow=CAST(0 AS BIT),Veprimi='Amortizim kumuluar',            Vlefte = REPLACE(CONVERT(VARCHAR,CAST(ROUND(TOTALVLEREAMORTIZ,0)   AS MONEY),1),'.00','')
             UNION ALL SELECT Nr=15,TRow=CAST(0 AS BIT),Veprimi='Vlere mbetur',                  Vlefte = REPLACE(CONVERT(VARCHAR,CAST(ROUND(TOTALVLEREASSET-TOTALVLEREAMORTIZ,0) AS MONEY),1),'.00','')
             
             UNION ALL SELECT Nr=16,TRow=CAST(0 AS BIT),Veprimi='Metoda 1',                      Vlefte = 'AM mbetur '   +REPLACE(CONVERT(VARCHAR,CAST(ROUND(CASE WHEN VLEREPERAMORTIZIM1<=0 THEN 0 ELSE VLEREPERAMORTIZIM1 END,0)  AS MONEY),1),'.00','')+ ' / '+
                                                                                                          'Kufi minimal '+REPLACE(CONVERT(VARCHAR,CAST(ROUND(CALCULVLEREMIN1,0)     AS MONEY),1),'.00','')+
                                                                                                          CASE WHEN ROUND(VLEREPERAMORTIZIM1,0)<=0 AND ROUND(TOTALVLEREASSET-TOTALVLEREAMORTIZ,0)>0 
                                                                                                               THEN ' / Vlefta '+REPLACE(CONVERT(VARCHAR,CAST(ROUND(TOTALVLEREASSET-TOTALVLEREAMORTIZ,0) AS MONEY),1),'.00','')+' duhet kaluar shpenzim'
                                                                                                               ELSE ''
                                                                                                          END     
                                                                                                      
             UNION ALL SELECT Nr=17,TRow=CAST(0 AS BIT),Veprimi='Metoda 2',                      Vlefte = 'AM mbetur '   +REPLACE(CONVERT(VARCHAR,CAST(ROUND(CASE WHEN VLEREPERAMORTIZIM2<=0 THEN 0 ELSE VLEREPERAMORTIZIM2 END,0)  AS MONEY),1),'.00','')+ ' / '+
                                                                                                          'Kufi minimal '+REPLACE(CONVERT(VARCHAR,CAST(ROUND(CALCULVLEREMIN2,0)     AS MONEY),1),'.00','')+
                                                                                                          CASE WHEN ROUND(VLEREPERAMORTIZIM2,0)<=0 AND ROUND(TOTALVLEREASSET-TOTALVLEREAMORTIZ,0)>0 
                                                                                                               THEN ' / Vlefta '+REPLACE(CONVERT(VARCHAR,CAST(ROUND(TOTALVLEREASSET-TOTALVLEREAMORTIZ,0) AS MONEY),1),'.00','')+' duhet kaluar shpenzim'
                                                                                                               ELSE ''
                                                                                                          END                                                                                                      
             
--           UNION ALL SELECT Nr=16,TRow=CAST(0 AS BIT),Veprimi='Amortizim mbetur / kufi 1',     Vlefte = REPLACE(CONVERT(VARCHAR,CAST(ROUND(VLEREPERAMORTIZIM1,0)  AS MONEY),1),'.00','')+ ' / '+
--                                                                                                        REPLACE(CONVERT(VARCHAR,CAST(ROUND(CALCULVLEREMIN1,0)     AS MONEY),1),'.00','')
--                                                                                                    
--           UNION ALL SELECT Nr=17,TRow=CAST(0 AS BIT),Veprimi='Amortizim mbetur / kufi 2',     Vlefte = REPLACE(CONVERT(VARCHAR,CAST(ROUND(VLEREPERAMORTIZIM2,0)  AS MONEY),1),'.00','')+ ' / '+
--                                                                                                        REPLACE(CONVERT(VARCHAR,CAST(ROUND(CALCULVLEREMIN2,0)     AS MONEY),1),'.00','')

             UNION ALL SELECT Nr=18,TRow=CAST(1 AS BIT),Veprimi='Date shitje',                   Vlefte = CONVERT(VARCHAR(20),LASTDTSHITJE,    104)
             UNION ALL SELECT Nr=19,TRow=CAST(0 AS BIT),Veprimi='Vlere shitje',                  Vlefte = REPLACE(CONVERT(VARCHAR,CAST(ROUND(LASTVLERESHITJE,0)     AS MONEY),1),'.00','')
             UNION ALL SELECT Nr=20,TRow=CAST(1 AS BIT),Veprimi='Date jashte perdorimi',         Vlefte = CONVERT(VARCHAR(20),LASTDTJASHTEPERD,104)
             UNION ALL SELECT Nr=21,TRow=CAST(1 AS BIT),Veprimi='Date cregjistrimi',             Vlefte = CONVERT(VARCHAR(20),LASTDTCREGJISTRIM,104)

                       ) C (Nr, Trow, Veprimi, Vlefta)

       WHERE Kod=@sKod AND (@iAllDetails=1 OR (NOT (VLEFTA IS NULL)))

    ORDER BY Nr;
      
GO
