SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO













CREATE  VIEW [dbo].[Isd_AQGjendjeAktivi] 

AS

-- SELECT * FROM Isd_AQGjendjeAktivi WHERE KOD='X01000003';   Select KARTLLG,KODOPER,DATEOPER,VLERAAM,VLERABS from LevizjeAQAll Where KARTLLG='X01000003'


                                                                            -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020


      SELECT TOP 100 PERCENT 
             A.KARTLLG,
             A.KATEGORI,
             A.PERSHKRIM,
             A.VLEREHISTORIKE,
             A.AMORTIZIMTOTAL,
             A.VLEREMBETUR,
             CALCULVLEREMIN1     = CASE WHEN R2.APLVLEREMINAM =0 THEN ROUND((A.VLEREMBETUR*R2.PERQINDMINAM/100),0)
                                        WHEN R2.APLVLEREMINAM =1 THEN ROUND(R2.VLEREMINAM,0)
                                        ELSE
                                             CASE WHEN ROUND(A.VLEREMBETUR*R2.PERQINDMINAM/100,0)>ROUND(R2.VLEREMINAM,0)
                                                  THEN ROUND(A.VLEREMBETUR*R2.PERQINDMINAM/100,0)
                                                  ELSE ROUND(R2.VLEREMINAM,0)
                                             END
                                   END,
             CALCULVLEREMIN2     = CASE WHEN R2.APLVLEREMINAM2=0 THEN ROUND((A.VLEREMBETUR*R2.PERQINDMINAM2/100),0)
                                        WHEN R2.APLVLEREMINAM2=1 THEN ROUND(R2.VLEREMINAM2,0)
                                        ELSE
                                             CASE WHEN ROUND(A.VLEREMBETUR*R2.PERQINDMINAM2/100,0)>ROUND(R2.VLEREMINAM2,0)
                                                  THEN ROUND(A.VLEREMBETUR*R2.PERQINDMINAM2/100,0)
                                                  ELSE ROUND(R2.VLEREMINAM2,0)
                                             END
                                   END,
             VLEREPERAMORTIZIM1  = ISNULL(VLEREMBETUR,0)
                                   -
                                   CASE WHEN R2.APLVLEREMINAM =0 THEN ROUND((A.VLEREMBETUR*R2.PERQINDMINAM/100),0)
                                        WHEN R2.APLVLEREMINAM =1 THEN ROUND(R2.VLEREMINAM,0)
                                        ELSE
                                           CASE WHEN ROUND(A.VLEREMBETUR*R2.PERQINDMINAM/100,0)>ROUND(R2.VLEREMINAM,0)
                                                THEN ROUND(A.VLEREMBETUR*R2.PERQINDMINAM/100,0)
                                                ELSE ROUND(R2.VLEREMINAM,0)
                                           END
                                   END,
             VLEREPERAMORTIZIM2  = ISNULL(VLEREMBETUR,0)
                                   -
                                   CASE WHEN R2.APLVLEREMINAM2=0 THEN ROUND((A.VLEREMBETUR*R2.PERQINDMINAM2/100),0)
                                        WHEN R2.APLVLEREMINAM2=1 THEN ROUND(R2.VLEREMINAM2,0)
                                        ELSE
                                             CASE WHEN ROUND(A.VLEREMBETUR*R2.PERQINDMINAM2/100,0)>ROUND(R2.VLEREMINAM2,0)
                                                  THEN ROUND(A.VLEREMBETUR*R2.PERQINDMINAM2/100,0)
                                                  ELSE ROUND(R2.VLEREMINAM2,0)
                                             END
                                   END,
             CREGJISTRUAR        = CAST(CASE WHEN ISNULL(NRCregjistrim,0)>0 THEN 1 ELSE 0 END AS BIT)
             
        FROM
        
           ( 
           
             SELECT A.KARTLLG,
                    KATEGORI              = MAX(R1.Kategori),
                    PERSHKRIM             = MAX(R1.PERSHKRIM),
                    
                    VLEREHISTORIKE        = SUM(CASE WHEN A.KODOPER IN ('CE')                          THEN  ISNULL(ISNULL(CE.VLERAFATMV,A.VLERABS),0)
                                                     WHEN A.KODOPER IN ('BL','RK','RV','SI','ST')      THEN  ISNULL(A.VLERABS,0)  -- 'SR',
                                                     WHEN A.KODOPER IN ('CR')                          THEN -ISNULL(A.VLERABS,0)  -- 'JP',
                                                     ELSE                                                    0
                                                END),
                                         
                    AMORTIZIMTOTAL        = SUM(CASE WHEN A.KODOPER IN ('CE','AM',          'SI','ST') THEN  1
                                                     WHEN A.KODOPER IN ('CR')                          THEN -1  -- 'JP',
                                                     ELSE                                                    0
                                                END * ISNULL(A.VLERAAM,0)),

                    VLEREMBETUR           = SUM(CASE WHEN A.KODOPER IN ('CE')                          THEN  ISNULL(ISNULL(CE.VLERAFATMV,A.VLERABS),0)
                                                     WHEN A.KODOPER IN ('BL','RK','RV','SI','ST')      THEN  ISNULL(A.VLERABS,0)  -- 'SR',
                                                     WHEN A.KODOPER IN ('CR')                          THEN -ISNULL(A.VLERABS,0)  -- 'JP',
                                                     ELSE                                                    0
                                                END) 
                                            -    
                                            SUM(CASE WHEN A.KODOPER IN ('CE','AM',          'SI','ST') THEN  1
                                                     WHEN A.KODOPER IN ('CR')                          THEN -1  -- 'JP',
                                                     ELSE                                                    0
                                                END * ISNULL(A.VLERAAM,0)),
                                                 
                    NrCRegjistrim         = SUM(CASE WHEN A.KODOPER='CR'                               THEN 1 
                                                     ELSE 0 
                                                END)
                    
               FROM LevizjeAQALL A LEFT  JOIN AQKartela  R1 ON A.KartLlg   = R1.Kod
                                   LEFT  JOIN AQCelje    CE ON A.KartLlg   = CE.KartLlg
       
       --     WHERE A.KOD='ZPROVE02' 
           GROUP BY A.KartLlg
           
             ) A       
             
                    LEFT  JOIN AQKATEGORI R2 ON A.Kategori = R2.Kod

          
    ORDER BY A.KartLlg   
    
    




GO
