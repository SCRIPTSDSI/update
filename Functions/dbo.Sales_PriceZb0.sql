SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Function [dbo].[Sales_PriceZb0]
(   
  @Artikull    Varchar(60),    
  @Barkod      Varchar(60),    
  @Klient      Varchar(60),    
  @Date        DateTime,
  @Sasi        Float,
  @Kurs1       Float,
  @Kurs2       Float 
)
 
RETURNS Float AS

BEGIN


     DECLARE @Cmim        Float,
             @Klasa       Varchar(10),
             @CmshTvsh    Bit,
             @Tvsh        Float,
			 @Round		  INT;

		 SET @ROUND= (SELECT TOP 1 CMIM  FROM DECIMALS  WHERE MODUL IN ('S','F')  AND TABLENAME='FJ')
         
		 SET @Cmim = dbo.Sales_Price(@Artikull, @Barkod, @Klient, @Date, @Sasi, @Kurs1, @Kurs2);

         SET @CmshTvsh  = ISNULL(( SELECT TOP 1 CMSHTVSH FROM CONFIGMG ), 0)
         SET @Tvsh      = ISNULL(( SELECT Perqindje FROM ARTIKUJ A INNER JOIN KLASATATIM T on A.KODTVSH = T.kod WHERE A.Kod = @Artikull ), 0)


          IF @Cmim>0
             BEGIN
               RETURN CASE WHEN @CmshTvsh = 1 THEN ROUND(@Cmim*100/(100 + @Tvsh),@ROUND) ELSE ROUND(@Cmim,@ROUND) END;
             END;     
       


         SET @Klasa = ( SELECT GRUP FROM Klient WHERE KOD=@Klient );

         SET @Cmim  = ISNULL(@Cmim,(SELECT CMIM = CASE @KLASA WHEN 'A' THEN Cmsh
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


    RETURN CASE WHEN @CmshTvsh = 1 THEN ROUND(@Cmim*100/(100 + @Tvsh),@ROUND) ELSE ROUND(@Cmim,@ROUND) END;

	  
END
GO
