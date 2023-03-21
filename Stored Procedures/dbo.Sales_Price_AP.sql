SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [dbo].[Sales_Price_AP]
(   
  @Artikull    Varchar(20),    
  @Barkod      Varchar(20),    
  @Klient      Varchar(20),    
  @Date        Datetime,
  @Sasi        Float,
  @Kurs1       Float,
  @Kurs2       Float,
  @Cmim        Float Output
)

AS

BEGIN

/*   DECLARE @Cmim   Float,           
             @Date   DateTime;     
         SET @Cmim = 0.0;     
         SET @Date = dbo.DateValue('20/10/2018');    
        EXEC dbo.Sales_Price_AP 'PRV0002','','K00001',@Date,200,1,1,@Cmim Output;  
      SELECT CMSH = @Cmim;           */

         SET NOCOUNT ON;

     DECLARE @PCName       Varchar(500);                -- Per AP
          -- @PCIP         Varchar(500),                -- Per AP, pse duhet
          -- @Koeficent    Float;
           

         SET @PCName     = HOST_NAME();
         
--    SELECT TOP 1 @PCIP = CLIENT_NET_ADDRESS FROM MASTER.SYS.DM_EXEC_CONNECTIONS WHERE SESSION_ID = @@SPID;
-- Duhet si sintakse per ta perdorur ndonjehere ????

      
     DECLARE @LP           Varchar(100),
             @KP           Varchar(100),
             @PPL          VARCHAR(100),
             @Ret          Int,
             @Klasa        VARCHAR(3);
             
         SET @LP         = CASE WHEN LEFT(@PCName,2)='FR' THEN 'FFF'
                                WHEN LEFT(@PCName,2)='EL' THEN 'EEE'
                                WHEN LEFT(@PCName,2)='TR' THEN 'TTT'
                                ELSE                           'PPP' 
                           END;
                                 
        EXEC [CheckLinkedServer] @LP ,@Ret OUTPUT;
                  
                          
          IF @Ret = 0
             BEGIN
         
                   SET @Sasi       = ABS(@Sasi);
                   
                SELECT TOP 1 @Cmim = (Cmim / CASE WHEN ISNULL(Koeficent1,0)=0 THEN 1 ELSE ISNULL(Koeficent1,0) END )  --/@Kurs2
                
                  FROM 
                      (
                        SELECT D.NrRendor, Klient = C.Kod, Sasi, Artikull = B.Kod, A.DateStart, A.DateEnd, Cmim , A.Koeficent1
                          FROM KlientCmim A   INNER JOIN KlientCmimArt B ON A.NRRENDOR=B.NRD
                                              INNER JOIN KlientCmimKl  C ON A.NRRENDOR=C.NRD
                                              INNER JOIN KlientCmimCm  D ON B.NRRENDOR=D.NRD
                     UNION ALL 
                        SELECT TOP 1 D.NrRendor, Klient = C.Kod, Sasi = 0, Artikull = B.Kod, A.DateStart, A.DateEnd, Cmim , A.Koeficent1
                          FROM KlientCmim A   INNER JOIN KlientCmimArt B ON A.NRRENDOR=B.NRD
                                              INNER JOIN KlientCmimKl  C ON A.NRRENDOR=C.NRD
                                              INNER JOIN KlientCmimCm  D ON B.NRRENDOR=D.NRD
                         WHERE (A.DATESTART<=@Date AND A.DATEEND>=@Date) AND (C.KOD=@Klient) AND (B.KOD=@Artikull)
                      ORDER BY Sasi
                                                                
                        ) A

                 WHERE (A.DATESTART<=@Date AND A.DATEEND>=@Date) AND (Klient=@Klient)  AND (Artikull=@Artikull)
              ORDER BY Cmim  ASC;
              
              
                
                    SET @Klasa = ( SELECT GRUP FROM Klient WHERE KOD=@Klient );
                    SET @Cmim  = ISNULL(@Cmim, (SELECT CMIM = CASE @KLASA WHEN 'A' THEN Cmsh
                                                                          WHEN 'B' THEN Cmsh1
                                                                          WHEN 'C' THEN Cmsh2
                                                                          WHEN 'D' THEN Cmsh3
                                                                          WHEN 'E' THEN Cmsh4
                                                                          WHEN 'F' THEN Cmsh5
                                                                          WHEN 'G' THEN Cmsh6
                                                                          WHEN 'H' THEN Cmsh7
                                                                          WHEN 'I' THEN Cmsh8
                                                                          WHEN 'J' THEN Cmsh9
                                                                          WHEN 'K' THEN Cmsh10
                                                                          WHEN 'L' THEN Cmsh11
                                                                          WHEN 'M' THEN Cmsh12
                                                                          WHEN 'N' THEN Cmsh13
                                                                          WHEN 'O' THEN Cmsh14
                                                                          WHEN 'P' THEN Cmsh15
                                                                          WHEN 'Q' THEN Cmsh16
                                                                          WHEN 'R' THEN Cmsh17
                                                                          WHEN 'S' THEN Cmsh18
                                                                          WHEN 'T' THEN Cmsh19
                                                                          ELSE Cmsh
                                                              END
                                                  FROM ARTIKUJ 
                                                 WHERE KOD = @Artikull));--/@Kurs2) --
             END
            
       ELSE
       
             BEGIN      --------------------------------------
                                
                
                  EXEC PPP.A2021.dbo.[Sales_Price_sp] 'M25586','','K10626',@Date,1,1,140,@cmim OUTPUT;  
             -- OPTION (KEEPFIXED PLAN)
             -- SELECT @CMIM;
              
/*
                  EXEC [Sales_Price_sp] 
                
                SELECT TOP 1 @Cmim = Cmim
                  FROM 
                  (
                        SELECT D.NrRendor, Klient = C.Kod, Sasi, Artikull = B.Kod, A.DateStart, A.DateEnd, Cmim 
                          FROM PPP.A2021.dbo.KlientCmim A Inner Join PPP.A2021.dbo.KlientCmimArt B ON A.NRRENDOR=B.NRD
                                                          Inner Join PPP.A2021.dbo.KlientCmimKl  C ON A.NRRENDOR=C.NRD
                                                          Inner Join PPP.A2021.dbo.KlientCmimCm  D ON B.NRRENDOR=D.NRD
                     UNION ALL 
                        SELECT TOP 1 D.NrRendor, Klient = C.Kod, Sasi = 0, Artikull = B.Kod, A.DateStart, A.DateEnd, Cmim 
                          FROM PPP.A2021.dbo.KlientCmim   A INNER JOIN PPP.A2021.dbo.KlientCmimArt B ON A.NRRENDOR=B.NRD
                                                            INNER JOIN PPP.A2021.dbo.KlientCmimKl  C ON A.NRRENDOR=C.NRD
                                                            INNER JOIN PPP.A2021.dbo.KlientCmimCm  D ON B.NRRENDOR=D.NRD
                         WHERE (A.DATESTART<=@Date AND A.DATEEND>=@Date) AND (C.KOD=@Klient) AND (B.KOD=@Artikull)  ORDER BY Sasi
                     ) A
                 WHERE (A.DATESTART<=@Date AND A.DATEEND>=@Date) AN D (Klient=@Klient) AND (Artikull=@Artikull)
                ORDER BY Cmim  ASC
                
               OPTION (KEEPFIXED PLAN)
               
                SET @Klasa=(SELECT A.GRUP FROM PPP.A2021.dbo.Klient A WHERE A.KOD=@Klient )
                SET @Cmim = ISNULL(@Cmim, (SELECT CMIM=CASE @KLASA 
                                                   WHEN 'A' THEN Cmsh
                                                   WHEN 'B' THEN Cmsh1
                                                   WHEN 'C' THEN Cmsh2
                                                   WHEN 'D' THEN Cmsh3
                                                   WHEN 'E' THEN Cmsh4
                                                   WHEN 'F' THEN Cmsh5
                                                   WHEN 'G' THEN Cmsh6
                                                   
                                                   ELSE NULL
                                                END
                           FROM PPP.A2021.dbo.ARTIKUJ 
                           WHERE KOD=@Artikull)) 
                SET @Cmim = ISNULL(@Cmim, (SELECT CMIM=CASE @KLASA 
                                                   WHEN 'H' THEN Cmsh7
                                                   WHEN 'I' THEN Cmsh8
                                                   WHEN 'J' THEN Cmsh9
                                                   WHEN 'K' THEN Cmsh10
                                                   WHEN 'L' THEN Cmsh11
                                                   WHEN 'M' THEN Cmsh12
                                                   WHEN 'N' THEN Cmsh13
                                                   WHEN 'O' THEN Cmsh14
                                                   WHEN 'P' THEN Cmsh15
                                                   
                                                   ELSE NULL
                                                END
                           FROM PPP.A2021.dbo.ARTIKUJ 
                           WHERE KOD=@Artikull ))  
                           
                SET @Cmim = ISNULL(@Cmim, (SELECT CMIM=CASE @KLASA 
                                                   WHEN 'Q' THEN Cmsh16
                                                   WHEN 'R' THEN Cmsh17
                                                   WHEN 'S' THEN Cmsh18
                                                   WHEN 'T' THEN Cmsh19
                                                   
                                                   ELSE Cmsh
                                                END
                           FROM PPP.A2021.dbo.ARTIKUJ 
                           WHERE KOD=@Artikull
                             ))         
                                           
                                                    
       */
                   SET @Cmim = ROUND(@Cmim/1.2,3);
             END
                
         
         
      RETURN @Cmim;
  
END
 
GO
