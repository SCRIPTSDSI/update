SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Function [dbo].[sales_price]
(   
  @Artikull    Varchar(60),    
  @Barkod      Varchar(60),    
  @Klient      Varchar(60),    
  @Date        Datetime,
  @Sasi        Float,
  @Kurs1       Float,
  @Kurs2       Float 
)
 
RETURNS FLOAT AS

BEGIN


--     Sa here modifikohet ky funksion te modifikohet edhe funksioni tjeter Sales_Price1
--     qe jane gati identike vetem per pjesen e pare ...

--     Ky funksion perdoret ne ndertim dokumenti fature ...

     DECLARE @Cmim         Float,
             @CmimSasiMax  Float,
             @SasiMax      Float;
             
         SET @Sasi       = ABS(@Sasi);




-- 0.     -- Rasti Multibarkod


     DECLARE @MultiBc      Bit;
     
         SET @MultiBc    = ( SELECT ISNULL(MULTIBC,0) FROM CONFIGMG );


          IF @MultiBc=1
	         SET @Cmim   = ( SELECT B.CMSH 
	                           FROM ARTIKUJ A INNER JOIN ArtikujBCScr B ON A.NRRENDOR=B.NRD
				              WHERE A.KOD=@Artikull AND B.BC=@Barkod );


				            
-- 0.1.   -- Rasti kur @Sasi eshet me e madhe se Sasi maksimale ndarje per cmimet.

          IF ISNULL(@Cmim,0)=0
             BEGIN
             
               SELECT @CmimSasiMax = D.CMIM, @SasiMax = D.SASI 
                 FROM KlientCmim A INNER JOIN KlientCmimArt B ON A.NRRENDOR=B.NRD
                                   INNER JOIN KlientCmimKl  C ON A.NRRENDOR=C.NRD
                                   INNER JOIN KlientCmimCm  D ON B.NRRENDOR=D.NRD
               WHERE (A.DATESTART<=@Date AND A.DATEEND>=@Date) AND (C.KOD=@Klient) AND (B.KOD=@Artikull) AND
                      SASI = (SELECT SASI=MAX(SASI) FROM KlientCmimCm R1 WHERE ISNULL(R1.NRD,0)=D.NRD);

                   IF (ISNULL(@CmimSasiMax,0)>0) AND (@Sasi>=ISNULL(@SasiMax,0))
                      BEGIN
                        SET @Cmim = @CmimSasiMax
			          END;
			 
			 END;
			 

				            
-- 1.     -- Rasti kur i referehote listes se Cmimeve me formen e DevExpress-it

                       
      SELECT @Cmim = ISNULL(@Cmim,(SELECT MIN(Cmimi)  
        FROM Csh_Lista    
       WHERE (  ( Date_Fillimi <= @Date    AND ISNULL(Date_Mbarimi, '2900-01-01 00:00:00.000')>=@Date AND Tip_Shitje IN ('AK', 'GK') ) 
                 OR 
                ( Kod_Shitje    = @Klient  AND Date_Fillimi<=@Date AND ISNULL(Date_Mbarimi, '2900-01-01 00:00:00.000') > = @Date)      
                 OR 
                ( Kod_Shitje    = ( SELECT Grup FROM KLIENT WHERE Kod=@Klient ) AND Tip_Shitje    = 'GK' AND 
                  Date_Fillimi<=@Date AND ISNULL(Date_Mbarimi, '2900-01-01 00:00:00.000') > = @Date) 
              ) 
               AND Kod = @Artikull 
              ) ); 
               
               
            
-- 2.     -- Cmimi i artikullit sipas ofertimeve ne baze klient, sasi shitje

    
      SELECT @Cmim = ISNULL(@Cmim, ( SELECT TOP 1 Cmim
        FROM 

      (

             SELECT D.NrRendor, Klient = C.Kod, Sasi,     Artikull = B.Kod, A.DateStart, A.DateEnd, Cmim 
               FROM KlientCmim A INNER JOIN KlientCmimArt B ON A.NRRENDOR=B.NRD
                                 INNER JOIN KlientCmimKl  C ON A.NRRENDOR=C.NRD
                                 INNER JOIN KlientCmimCm  D ON B.NRRENDOR=D.NRD

          UNION ALL 

             SELECT TOP 1 
                    D.NrRendor, Klient = C.Kod, Sasi , Artikull = B.Kod, A.DateStart, A.DateEnd, Cmim 
               FROM KlientCmim A INNER JOIN KlientCmimArt B ON A.NRRENDOR=B.NRD
                                 INNER JOIN KlientCmimKl  C ON A.NRRENDOR=C.NRD
                                 INNER JOIN KlientCmimCm  D ON B.NRRENDOR=D.NRD
              WHERE (A.DATESTART<=@Date AND A.DATEEND>=@Date) AND (C.KOD=@Klient) AND (B.KOD=@Artikull)
           Order By Sasi

         ) A

       WHERE (A.DATESTART<=@Date AND A.DATEEND>=@Date) AND (Klient=@Klient) AND (Artikull=@Artikull) AND (Sasi-@Sasi>= 0) -- AND ISNULL(A.ACTIV,0)=1
       
    Order By A.Sasi-@Sasi));
 


-- 3.     -- Cmimi sipas Cmimeve preferenciale sipas klienteve


         SET @Cmim = ISNULL(@Cmim, ( SELECT TOP 1 CMSH 
                                       FROM KLIENTCM A INNER JOIN KLIENT B ON A.NRD=B.NRRENDOR 
								      WHERE B.KOD=@Klient AND A.KOD=@Artikull 
								     ) );
								    


-- 4.     -- Cmim sipas klasese se cmimeve te artikujve referuar klases se klientit


     DECLARE @Klasa   Varchar(3);
     
         SET @Klasa = ( SELECT GRUP FROM Klient WHERE KOD=@Klient );

         SET @Cmim  = ISNULL(@Cmim,(SELECT CMIM = CASE @Klasa WHEN 'A' THEN Cmsh
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
                                                              ELSE          Cmsh
                                                  END
                                      FROM ARTIKUJ 
                                     WHERE KOD=@Artikull)); 

    RETURN @Cmim

END

GO
