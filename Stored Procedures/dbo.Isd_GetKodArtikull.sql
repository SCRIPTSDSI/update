SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Exec [Isd_GetKodArtikull] 'P100','AA',1,2,10 

CREATE        Procedure [dbo].[Isd_GetKodArtikull]
( 
  @pKod        Varchar(30),
  @pKodStart   Varchar(30),
  @pModel      Int,
  @pFormat     Int,   -- @Format vetem kur @Model=1
  @pKodLength  Int
  
 )
 
As


-- @pModel = 0 - Asgje
--         = 1 - Sipas struktures se parapercaktuar
--         = 2 - Sipas ndonje algoritmi extra qe percaktohet tek funksioni: dbo.Isd_GetKodArtikullExtra

-- per rastin @pModul=1 percaktohen disa formate: 
--            Shembull: Per grupin 'FG' te artikujve (@pKodStart='FG') numuri i radhes eshte 754 atehere :
--                      @pFormat=0     @KodNew = 'BR'+'000754'
--                      @pFormat=1     @KodNew = 'BR'+'754000'
--                      @pFormat=2     @KodNew = 'BR'+'754'


         SET NOCOUNT ON;

     Declare @Kod         Varchar(30),
             @KodStart    Varchar(20),
             @Model       Int,
             @Format      Int,
             @Length      Int,

             @iStart      Int,
             @KodNew      Varchar(30);

        SET  @Kod       = ISNULL(@pKod,''); 
        SET  @KodStart  = ISNULL(@pKodStart,'');
        SET  @Model     = @pModel;
        SET  @Format    = @pFormat;
        SET  @Length    = @pKodLength;
        
        SET  @iStart    = Len(@KodStart)+1;
        

        SET  @KodNew = @pKod;                   -- @Model=0


        IF   @Model=1

             BEGIN
             
               SELECT @KodNew = CONVERT(VARCHAR, MAX(ISNULL(SUBSTRING(KOD,@iStart,LEN(KOD)),0))+1)
                 FROM ARTIKUJ 
                WHERE LEFT(KOD,LEN(@KodStart))=@KodStart AND ISNUMERIC(SUBSTRING(KOD,@iStart,LEN(KOD)))=1;
                
                  SET @KodNew=ISNULL(@KodNew,'1');
                
                
                   IF @Format=0
                      BEGIN
                        SET @KodNew = REPLICATE('0',@Length)+@KodNew;
                        SET @KodNew = @KodStart + RIGHT(@KodNew ,@Length-@iStart+1);
                      END
                 ELSE
                   IF @Format=1
                      BEGIN
                        SET @KodNew = @KodNew + REPLICATE('0',@Length);
                        SET @KodNew = @KodStart + LEFT(@KodNew ,@Length-@iStart+1);
                      END
                 ELSE
                      BEGIN
                        SET @KodNew = @KodStart+@KodNew;
                      END
             END

        ELSE      

        IF   @Model=2

             BEGIN
                           
               SET @KodNew = dbo.Isd_GetKodArtikullExtra(@Kod);

             END;      


      SELECT KOD = CASE WHEN ISNULL(@KodNew,'')='' THEN '' ELSE @KodNew END;


   
GO
