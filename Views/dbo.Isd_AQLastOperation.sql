SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO







CREATE  VIEW [dbo].[Isd_AQLastOperation] 

AS

-- SELECT * FROM Isd_AQLastOperation WHERE KOD='X01000003';   Select KARTLLG,KODOPER,DATEOPER,VLERAAM,VLERABS from LevizjeAQAll Where KARTLLG='X01000003'

      SELECT TOP 100 PERCENT
             A.KOD,A.PERSHKRIM,
      
             LASTDTAMORTIZ         = A01.DATEOPER_AM,
             LASTVLEREAMORTIZ      = (  SELECT SUM(ISNULL(L.VLERAAM,0)) 
                                          FROM LevizjeAQAll L 
                                         WHERE L.KARTLLG=A.KOD AND (ISNULL(L.KODOPER,'') IN ('AM','CE')) AND L.DATEOPER=A01.DATEOPER_AM  ), 

             FIRSTDTBLERJE         = A02.DATEOPER_BL,
             FIRSTVLEREBLERJE      = (  SELECT SUM(ISNULL(L.VLERABS,0)) 
                                          FROM LevizjeAQAll L 
                                         WHERE L.KARTLLG=A.KOD AND (ISNULL(L.KODOPER,'')='BL')           AND L.DATEOPER=A02.DATEOPER_BL  ),
             FIRSTVLEREFATBLERJE   = (  SELECT SUM(ISNULL(L.VLERAFAT,0)) 
                                          FROM LevizjeAQAll L 
                                         WHERE L.KARTLLG=A.KOD AND (ISNULL(L.KODOPER,'')='BL')           AND L.DATEOPER=A02.DATEOPER_BL  ),
             FIRSTMONBLERJE        = (  SELECT MAX(ISNULL(L.KMON,'')) 
                                          FROM LevizjeAQAll L 
                                         WHERE L.KARTLLG=A.KOD AND (ISNULL(L.KODOPER,'')='BL')           AND L.DATEOPER=A02.DATEOPER_BL  ), 
             

             FIRSTDTCELJE          = A03.DATEOPER_CE,
             FIRSTVLERECELJE       = (  SELECT SUM(ISNULL(L.VLERABS,0)) 
                                          FROM LevizjeAQAll L 
                                         WHERE L.KARTLLG=A.KOD AND (ISNULL(L.KODOPER,'')='CE')           AND L.DATEOPER=A03.DATEOPER_CE  ),
             FIRSTVLEREAMCELJE     = (  SELECT SUM(ISNULL(L.VLERAAM,0)) 
                                          FROM LevizjeAQAll L 
                                         WHERE L.KARTLLG=A.KOD AND (ISNULL(L.KODOPER,'')='CE')           AND L.DATEOPER=A03.DATEOPER_CE  ),

             LASTDTMIREMBAJ        = A04.DATEOPER_MM,
             LASTVLEREMIREMBAJ     = (  SELECT SUM(ISNULL(L.VLERABS,0))                               -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
                                          FROM LevizjeAQAll L                      
                                         WHERE L.KARTLLG=A.KOD AND (ISNULL(L.KODOPER,'')='RK')           AND L.DATEOPER=A04.DATEOPER_MM  ),
                                             
             LASTDTRIVLER          = A041.DATEOPER_RV,
             LASTVLERERIVLER       = (  SELECT SUM(ISNULL(L.VLERABS,0)) 
                                          FROM LevizjeAQAll L 
                                         WHERE L.KARTLLG=A.KOD AND (ISNULL(L.KODOPER,'')='RV')           AND L.DATEOPER=A041.DATEOPER_RV  ),
                                             
             LASTDTSHERBIM         = A05.DATEOPER_SR,
             LASTVLERESHERBIM      = (  SELECT SUM(ISNULL(L.VLERABS,0)) 
                                          FROM LevizjeAQAll L 
                                         WHERE L.KARTLLG=A.KOD AND (ISNULL(L.KODOPER,'')='SR')           AND L.DATEOPER=A05.DATEOPER_SR  ), 
                                              
             LASTDTSHITJE          = A06.DATEOPER_SH,
             LASTVLERESHITJE       = (  SELECT SUM(ISNULL(L.VLERABS,0)) 
                                          FROM LevizjeAQAll L 
                                         WHERE L.KARTLLG=A.KOD AND (ISNULL(L.KODOPER,'')='SH')           AND L.DATEOPER=A06.DATEOPER_SH  ), 
             LASTVLEREFATSHITJE    = (  SELECT SUM(ISNULL(L.VLERAFAT,0)) 
                                          FROM LevizjeAQAll L 
                                         WHERE L.KARTLLG=A.KOD AND (ISNULL(L.KODOPER,'')='SH')           AND L.DATEOPER=A06.DATEOPER_SH  ),
             LASTMONSHITJE         = (  SELECT MAX(ISNULL(L.KMON,'')) 
                                          FROM LevizjeAQAll L 
                                         WHERE L.KARTLLG=A.KOD AND (ISNULL(L.KODOPER,'')='SH')           AND L.DATEOPER=A06.DATEOPER_SH  ), 

             LASTDTJASHTEPERD      = (  SELECT MIN(L.DATEOPER) 
                                          FROM LevizjeAQAll L 
                                         WHERE L.KARTLLG=A.KOD AND (ISNULL(L.KODOPER,'')='JP')  ),
             LASTDTCREGJISTRIM     = (  SELECT MIN(L.DATEOPER) 
                                          FROM LevizjeAQAll L 
                                         WHERE L.KARTLLG=A.KOD AND (ISNULL(L.KODOPER,'')='CR')  ),
             CREGJISTRUAR          = CASE WHEN EXISTS (SELECT * FROM LevizjeAQAll L WHERE L.KARTLLG=A.KOD AND (ISNULL(L.KODOPER,'')='CR') ) 
                                          THEN CAST(1 AS BIT)
                                          ELSE CAST(0 AS BIT)
                                     END,
                                          
             LASTDTPERDORUES       = A09.DATEOPER_PR,
             LASTKODPERDORUES      = (  SELECT MAX(ISNULL(L.KODPRONESI,''))
                                          FROM LevizjeAQALL L
                                         WHERE L.KARTLLG=A.KOD AND L.DATEOPER=A09.DATEOPER_PR   ),
             LASTPERSHKRPERDORUES  = (  SELECT MAX(ISNULL(L.PERSHKRIMPRONESI,'')) 
                                          FROM LevizjeAQALL L
                                         WHERE L.KARTLLG=A.KOD AND L.DATEOPER=A09.DATEOPER_PR AND (ISNULL(L.KODPRONESI,'')<>''  OR ISNULL(L.PERSHKRIMPRONESI,'')<>'')  ),                                   
                                             
             LASTDTLOCATION        = A10.DATEOPER_LC,
             LASTKODLOCATION       = (  SELECT MAX(ISNULL(L.KODLOCATION,''))
                                          FROM LevizjeAQALL L
                                         WHERE L.KARTLLG=A.KOD AND L.DATEOPER=A10.DATEOPER_LC   ),
             LASTPERSHKRLOCATION   = (  SELECT MAX(ISNULL(L.PERSHKRIMLOCATION,'')) 
                                          FROM LevizjeAQALL L
                                         WHERE L.KARTLLG=A.KOD AND L.DATEOPER=A10.DATEOPER_LC AND L.NRRENDORSCR=A10.NRRENDORSCR_LC  ),
                                         
             TOTALVLEREASSET       = (  SELECT L.VLEREHISTORIKE   FROM dbo.Isd_AQGjendjeAktivi L WHERE L.KARTLLG=A.Kod),
             TOTALVLEREAMORTIZ     = (  SELECT L.AMORTIZIMTOTAL   FROM dbo.Isd_AQGjendjeAktivi L WHERE L.KARTLLG=A.Kod),
             TOTALVLEREMBETUR      = (  SELECT L.VLEREMBETUR      FROM dbo.Isd_AQGjendjeAktivi L WHERE L.KARTLLG=A.Kod),
             CALCULVLEREMIN1       = (  SELECT CALCULVLEREMIN1    FROM dbo.Isd_AQGjendjeAktivi L WHERE L.KARTLLG=A.Kod),
             CALCULVLEREMIN2       = (  SELECT CALCULVLEREMIN2    FROM dbo.Isd_AQGjendjeAktivi L WHERE L.KARTLLG=A.Kod),
             VLEREPERAMORTIZIM1    = (  SELECT VLEREPERAMORTIZIM1 FROM dbo.Isd_AQGjendjeAktivi L WHERE L.KARTLLG=A.Kod),
             VLEREPERAMORTIZIM2    = (  SELECT VLEREPERAMORTIZIM2 FROM dbo.Isd_AQGjendjeAktivi L WHERE L.KARTLLG=A.Kod),
             
/*           Keto fusha llogariten ne nje View me vete: Isd_AQGjendjeAktivi 24.08.2020                -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
             TOTALVLEREASSET       = (  SELECT SUM(CASE WHEN L.KODOPER IN ('CE')                          THEN  ISNULL(ISNULL(CE.VLERAFATMV,L.VLERABS),0)
                                                        WHEN L.KODOPER IN ('BL','RK','RV','SI','ST')      THEN  ISNULL(L.VLERABS,0)  -- 'SR',
                                                        WHEN L.KODOPER IN ('CR')                          THEN -ISNULL(L.VLERABS,0)  -- 'JP',
                                                        ELSE                                                    0
                                                   END) 
                                          FROM LevizjeAQALL L LEFT  JOIN AQCelje      CE ON L.KARTLLG=CE.KARTLLG
                                         WHERE L.KARTLLG=A.KOD AND CHARINDEX(','+UPPER(ISNULL(L.KODOPER,''))+',',',BL,RK,CE,RV,SI,ST,CR,')>0),
                                         
             TOTALVLEREAMORTIZ     = (  SELECT SUM(CASE WHEN L.KODOPER IN ('CE','AM',          'SI','ST') THEN  1
                                                        WHEN L.KODOPER IN ('CR')                          THEN -1  -- 'JP',
                                                        ELSE                                                    0
                                                   END * ISNULL(L.VLERAAM,0)) 
                                          FROM LevizjeAQALL L LEFT  JOIN AQCelje      CE ON L.KARTLLG=CE.KARTLLG
                                         WHERE L.KARTLLG=A.KOD AND CHARINDEX(','+UPPER(ISNULL(L.KODOPER,''))+',',',AM,CE,CR,')>0),


             TOTALVLEREMBETUR      = (  SELECT SUM(CASE WHEN L.KODOPER IN ('CE')                          THEN  ISNULL(ISNULL(CE.VLERAFATMV,L.VLERABS),0)
                                                        WHEN L.KODOPER IN ('BL','RK','RV','SI','ST')      THEN  ISNULL(L.VLERABS,0)  -- 'SR',
                                                        WHEN L.KODOPER IN ('CR')                          THEN -ISNULL(L.VLERABS,0)  -- 'JP',
                                                        ELSE                                                    0
                                                   END) 
                                          FROM LevizjeAQALL L LEFT  JOIN AQCelje      CE ON L.KARTLLG=CE.KARTLLG
                                         WHERE L.KARTLLG=A.KOD AND CHARINDEX(','+UPPER(ISNULL(L.KODOPER,''))+',',',BL,RK,CE,RV,SI,ST,CR,')>0)
                                     -    
                                     (  SELECT SUM(CASE WHEN L.KODOPER IN ('CE','AM',          'SI','ST') THEN  1
                                                        WHEN L.KODOPER IN ('CR')                          THEN -1  -- 'JP',
                                                        ELSE                                                    0
                                                   END * ISNULL(L.VLERAAM,0)) 
                                          FROM LevizjeAQALL L LEFT  JOIN AQCelje      CE ON L.KARTLLG=CE.KARTLLG
                                         WHERE L.KARTLLG=A.KOD AND CHARINDEX(','+UPPER(ISNULL(L.KODOPER,''))+',',',AM,CE,CR,')>0), */
                                         
                                                                                                      -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
             TOTALVLEREMIREMBAJ    = (  SELECT SUM(ISNULL(L.VLERABS,0)) FROM LevizjeAQALL L WHERE L.KARTLLG=A.KOD AND UPPER(ISNULL(L.KODOPER,''))='RK'  ),
             TOTALVLERESHERBIM     = (  SELECT SUM(ISNULL(L.VLERAAM,0)) FROM LevizjeAQALL L WHERE L.KARTLLG=A.KOD AND UPPER(ISNULL(L.KODOPER,''))='SR'  ),
             NRVEPRIME             = (  SELECT COUNT(*)                 FROM LevizjeAQAll L WHERE L.KARTLLG=A.KOD AND ISNULL(L.KODOPER,'') IN ('AM','CE','BL'))
                                         

        FROM AQKartela A -- LEFT JOIN AQKATEGORI R5 ON A.KATEGORI=R5.KOD
        
                         LEFT JOIN
             (   SELECT W1.KARTLLG, DATEOPER_AM=MAX(W1.DATEOPER)       -- mos perdor MAX(CASE WHEN ISNULL(W1.DATEOPER,0)=0 THEN W1.DATEDOK ELSE W1.DATEOPER END)
                   FROM LevizjeAQAll W1
                  WHERE (ISNULL(W1.KODOPER,'') IN ('AM','CE')) AND
                        W1.DATEOPER=(SELECT MAX(B.DATEOPER) FROM LevizjeAQAll B WHERE B.KARTLLG=W1.KARTLLG AND (ISNULL(B.KODOPER,'') IN ('AM','CE')) )
               GROUP BY W1.KARTLLG   ) A01 ON A.KOD=A01.KARTLLG   
               
                        LEFT JOIN
             (   SELECT W1.KARTLLG, DATEOPER_BL=MAX(W1.DATEOPER)
                   FROM LevizjeAQAll W1
                  WHERE (ISNULL(W1.KODOPER,'')='BL') AND
                        W1.DATEOPER=(SELECT MAX(B.DATEOPER) FROM LevizjeAQAll B WHERE B.KARTLLG=W1.KARTLLG AND (ISNULL(B.KODOPER,'')='BL') )
               GROUP BY W1.KARTLLG   ) A02 ON A.KOD=A02.KARTLLG   

                        LEFT JOIN
             (   SELECT W1.KARTLLG, DATEOPER_CE=MAX(W1.DATEOPER)
                   FROM LevizjeAQAll W1
                  WHERE (ISNULL(W1.KODOPER,'')='CE') AND
                        W1.DATEOPER=(SELECT MAX(B.DATEOPER) FROM LevizjeAQAll B WHERE B.KARTLLG=W1.KARTLLG AND (ISNULL(B.KODOPER,'')='CE') )
               GROUP BY W1.KARTLLG   ) A03 ON A.KOD=A03.KARTLLG   

                        LEFT JOIN
             (   SELECT W1.KARTLLG, DATEOPER_MM=MAX(W1.DATEOPER)
                   FROM LevizjeAQAll W1
                  WHERE (ISNULL(W1.KODOPER,'')='RK') AND                                              -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
                        W1.DATEOPER=(SELECT MAX(B.DATEOPER) FROM LevizjeAQAll B WHERE B.KARTLLG=W1.KARTLLG AND (ISNULL(B.KODOPER,'')='RK') )
               GROUP BY W1.KARTLLG   ) A04 ON A.KOD=A04.KARTLLG   

                        LEFT JOIN
             (   SELECT W1.KARTLLG, DATEOPER_RV=MAX(W1.DATEOPER)
                   FROM LevizjeAQAll W1
                  WHERE (ISNULL(W1.KODOPER,'')='RV') AND
                        W1.DATEOPER=(SELECT MAX(B.DATEOPER) FROM LevizjeAQAll B WHERE B.KARTLLG=W1.KARTLLG AND (ISNULL(B.KODOPER,'')='RV') )
               GROUP BY W1.KARTLLG   ) A041 ON A.KOD=A041.KARTLLG   

                        LEFT JOIN
             (   SELECT W1.KARTLLG, DATEOPER_SR=MAX(W1.DATEOPER)
                   FROM LevizjeAQAll W1
                  WHERE (ISNULL(W1.KODOPER,'')='SR') AND
                        W1.DATEOPER=(SELECT MAX(B.DATEOPER) FROM LevizjeAQAll B WHERE B.KARTLLG=W1.KARTLLG AND (ISNULL(B.KODOPER,'')='SR') )
               GROUP BY W1.KARTLLG   ) A05 ON A.KOD=A05.KARTLLG   

                        LEFT JOIN
             (   SELECT W1.KARTLLG, DATEOPER_SH=MIN(W1.DATEOPER)
                   FROM LevizjeAQAll W1
                  WHERE (ISNULL(W1.KODOPER,'')='SH') AND
                        W1.DATEOPER=(SELECT MAX(B.DATEOPER) FROM LevizjeAQAll B WHERE B.KARTLLG=W1.KARTLLG AND (ISNULL(B.KODOPER,'')='SH') )
               GROUP BY W1.KARTLLG   ) A06 ON A.KOD=A06.KARTLLG   

                        LEFT JOIN
             (   SELECT W1.KARTLLG, DATEOPER_PR=MAX(W1.DATEOPER)
                   FROM LevizjeAQAll W1
                  WHERE (ISNULL(W1.KODPRONESI,'')<>'' OR ISNULL(W1.PERSHKRIMPRONESI,'')<>'')  
               GROUP BY W1.KARTLLG   ) A09 ON A.KOD=A09.KARTLLG   

                        LEFT JOIN
             (   SELECT W1.KARTLLG, DATEOPER_LC=MAX(W1.DATEOPER),NRRENDORSCR_LC=MAX(W1.NRRENDORSCR)
                   FROM LevizjeAQAll W1
                  WHERE (ISNULL(W1.KODLOCATION,'')<>'' OR ISNULL(W1.PERSHKRIMLOCATION,'')<>'')  
               GROUP BY W1.KARTLLG   ) A10 ON A.KOD=A10.KARTLLG   
               
--     WHERE A.KOD='ZPROVE02' 
    ORDER BY A.KOD   
    
    





GO
