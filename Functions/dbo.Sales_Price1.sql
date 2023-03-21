SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Function [dbo].[Sales_Price1]
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


--     Sduhet te modifikohet ky funksion sepse gjithmone modifikohet sipas funksionit tjeter Sales_Price 
--     qe jane gati identike vetem per pjesen e pare ...
--     ndryshimi vetem per pjesen e fundit kur @Cmim is null

--     Ky funksion duhet per raportin per cmimet e shitjes


-- 0.

     DECLARE @Cmim   Float;

         SET @Sasi = ABS(@Sasi);

      SELECT @Cmim = MIN(Cmimi)  
        FROM Csh_Lista    
       WHERE ( ( Date_Fillimi <= @Date    AND ISNULL(Date_Mbarimi, '2900-01-01 00:00:00.000')>=@Date AND Tip_Shitje IN ('AK', 'GK') ) OR 
               ( Kod_Shitje    = @Klient  AND Date_Fillimi<=@Date AND ISNULL(Date_Mbarimi, '2900-01-01 00:00:00.000') > = @Date)      OR 
               ( Kod_Shitje    = ( SELECT Grup FROM KLIENT WHERE Kod=@Klient ) AND 
                 Tip_Shitje    = 'GK' AND Date_Fillimi<=@Date AND ISNULL(Date_Mbarimi, '2900-01-01 00:00:00.000') > = @Date
                 )
               ) AND Kod = @Artikull; 
--------


-- 1.

      SELECT TOP 1 @Cmim = Cmim
        FROM 

      (

             SELECT D.NrRendor, Klient = C.Kod, Sasi,     Artikull = B.Kod, A.DateStart, A.DateEnd, Cmim 
               FROM KlientCmim A INNER JOIN KlientCmimArt B ON A.NRRENDOR=B.NRD
                                 INNER JOIN KlientCmimKl  C ON A.NRRENDOR=C.NRD
                                 INNER JOIN KlientCmimCm  D ON B.NRRENDOR=D.NRD

          UNION All 

             SELECT TOP 1 
                    D.NrRendor, Klient = C.Kod, Sasi = 0, Artikull = B.Kod, A.DateStart, A.DateEnd, Cmim 
               FROM KlientCmim A INNER JOIN KlientCmimArt B ON A.NRRENDOR=B.NRD
                                 INNER JOIN KlientCmimKl  C ON A.NRRENDOR=C.NRD
                                 INNER JOIN KlientCmimCm  D ON B.NRRENDOR=D.NRD
              WHERE (A.DATESTART<=@Date AND A.DATEEND>=@Date) AND (C.KOD=@Klient) AND (B.KOD=@Artikull)
           Order By Sasi

         ) A

       WHERE (A.DATESTART<=@Date AND A.DATEEND>=@Date) AND (Klient=@Klient) AND (Artikull=@Artikull) AND (@Sasi-Sasi >= 0) -- AND ISNULL(A.ACTIV,0)=1
    Order By @Sasi - A.Sasi;   


-- 2.

         SET @Cmim = ISNULL(@Cmim, ( SELECT TOP 1 CMSH 
                                      FROM KLIENTCM A INNER JOIN KLIENT B ON A.NRD=B.NRRENDOR 
								    WHERE B.KOD=@Klient AND A.KOD=@Artikull 
								    ) );


-- 3.

--   DECLARE @Klasa   Varchar(3);
--   
--       SET @Klasa = ( SELECT GRUP FROM Klient WHERE KOD=@Klient );

--       SET @Cmim  = ISNULL(@Cmim,(SELECT CMIM = CASE @Klasa WHEN 'A' THEN Cmsh
--                                                            WHEN 'B' THEN Cmsh1
--                                                            WHEN 'C' THEN Cmsh2
--                                                            WHEN 'D' THEN Cmsh3
--                                                            WHEN 'E' THEN Cmsh4
--                                                            WHEN 'F' THEN Cmsh5
--                                                            WHEN 'G' THEN Cmsh6
--                                                            WHEN 'H' THEN Cmsh7
--                                                            WHEN 'I' THEN Cmsh8
--                                                            WHEN 'J' THEN Cmsh9
--                                                            WHEN 'K' THEN Cmsh10
--                                                            WHEN 'L' THEN Cmsh11
--                                                            WHEN 'M' THEN Cmsh12
--                                                            WHEN 'N' THEN Cmsh13
--                                                            WHEN 'O' THEN Cmsh14
--                                                            WHEN 'P' THEN Cmsh15
--                                                            WHEN 'Q' THEN Cmsh16
--                                                            WHEN 'R' THEN Cmsh17
--                                                            WHEN 'S' THEN Cmsh18
--                                                            WHEN 'T' THEN Cmsh19
--                                                            ELSE          Cmsh
--                                                END
--                                    FROM ARTIKUJ 
--                                   WHERE KOD=@Artikull)); 

    RETURN ISNULL(@Cmim,0)
    
END
GO
