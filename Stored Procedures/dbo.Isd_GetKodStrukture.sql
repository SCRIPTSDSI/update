SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Exec [Isd_GetKodStrukture] 'P100','ARTIKUJ',0,8,1,'AA',2,2,1 
-- Exec [Isd_GetKodStrukture] 'P100','ARTIKUJ',1,10,1,'AA',2,2,1
-- Exec  Isd_GetKodStrukture 'A0001','ARTIKUJ',1,6,1,'',2,2,0

CREATE        Procedure [dbo].[Isd_GetKodStrukture]
( 
  @pKod              Varchar(30),
  @pTableRef         Varchar(30),
  @pKodModel         Int,
  @pKodLength        Int,
  @pPrefixModel      Int,             --     0 - Prefix konstant,     1 - Prefix variable
  @pPrefixKonstant   Varchar(30),
  @pPrefixDinModel   Int,             --     0 - Gjithe pjesa Tekst,  1 - Pjesa tekst deri ne karakterin e pare numur,  2 - Prefix fix sipas gjatesiste @pPrefixDinLength
  @pPrefixDinLength  Int,
  @pKodFormat        Int              --     @pKodFormat vetem kur @pKodModel=1
--@pPerdorues        Varchar(30),
--@pDateEdit         Varchar(20),
--@pOper             Varchar(10)
 )
 
As

/*
  @pKodModel = 0 - Asgje
             = 1 - Sipas struktures se parapercaktuar
             = 2 - Sipas ndonje algoritmi extra qe percaktohet tek funksioni: dbo.Isd_GetKodArtikullExtra

 
  pPrefixModel = 0 kur ke Kod duhet me fillim konstant me vleren pPrefixKonstant,  
  pPrefixModel = 1 kur fillim variable sipas vleres se kodit nga user-i,pra me prefix te futur nga perdoruesi
  Ne rastin pPrefixModel = 1 :
            @pPrefixDinModel = 0 - Gjithe pjesa Tekst,  
            @pPrefixDinModel = 1 - Pjesa tekst deri ne karakterin e pare numur,  
            @pPrefixDinModel = 2 - Prefix fix sipas gjatesiste @pPrefixDinLength

  per rastin @pKodModul=1 percaktohen disa formate: 
            Shembull: Per grupin 'FG' te artikujve (@pPrefixKonstant='FG') numuri i radhes eshte 754 atehere(Start fix, jo variable) :
                      @pKodFormat=0     @KodNew = 'BR'+'000754'
                      @pKodFormat=1     @KodNew = 'BR'+'754000'
                      @pKodFormat=2     @KodNew = 'BR'+'754'
*/

         SET NOCOUNT ON;

     Declare @Kod                Varchar(30),
             @PrefixKonstant     Varchar(20),
             @PrefixModel        Int,
             @TableRef           Varchar(30),
             @KodModel           Int,
             @KodFormat          Int,
             @KodLength          Int,
             @PrefixDinModel     Int,
             @PrefixDinLength    Int,
             @iStart             Int,
             @KodNew             Varchar(30),
             @sSql              nVarchar(MAX);
             

        SET  @Kod              = ISNULL(@pKod,''); 
        SET  @PrefixKonstant   = ISNULL(@pPrefixKonstant,'');
        SET  @PrefixModel      = @pPrefixModel;
        SET  @KodModel         = @pKodModel;
        SET  @KodFormat        = @pKodFormat;
        SET  @KodLength        = @pKodLength;
        SET  @PrefixDinModel   = @pPrefixDinModel;
        SET  @PrefixDinLength  = @pPrefixDinLength;
        SET  @TableRef         = UPPER(@pTableRef);
        
/*   Declare @vString2 Varchar(50);
         Set @vString2 = 'oneeleven1';
      -- Use of PATINDEX
      SELECT PATINDEX('%[^A-Z]%',@vString2) AS 'Position of Numeric Character',
             SUBSTRING(@vString2,PATINDEX('%[^A-Z]%',@vString2),1) AS 'Numeric Character',
             CASE WHEN PATINDEX('%[^A-Z]%',@vString2)>0 THEN SUBSTRING(@vString2,1,PATINDEX('%[^A-Z]%',@vString2)-1) ELSE @vString2 END AS 'Left String',
             @vString2 AS 'Original Character'        */


        SET  @KodNew = @pKod;                   
        
        

--      A.   @KodModel=0 ose @KodModel=2

        IF   @KodModel=2
             BEGIN
               SET @KodNew = dbo.Isd_GetKodArtikullExtra(@Kod);
               SELECT KOD = CASE WHEN ISNULL(@KodNew,'')='' THEN '' ELSE @KodNew END;
               
               RETURN;
             END
             
        ELSE 
            
        IF   @KodModel<>1
             BEGIN
               SELECT KOD = CASE WHEN ISNULL(@KodNew,'')='' THEN '' ELSE @KodNew END;
               
               RETURN;
             END;  





--      B.   @KodModel=1

        IF   @PrefixModel=1                               -- Me prefix te futur nga perdoruesi
             BEGIN
               IF  @PrefixDinModel=0                      -- 1.   i gjithe stringu si prefix
                   SET @PrefixKonstant = @KodNew
               ELSE
               IF  @PrefixDinModel=1                      -- 2.   Prefix meret pjesa nga fillimi deri tek numuri i pare
                   SET @PrefixKonstant = CASE WHEN PATINDEX('%[^a-z]%',@Kod)>0 
                                              THEN SUBSTRING(@Kod,1,PATINDEX('%[^a-z]%',@Kod)-1) 
                                              ELSE @Kod 
                                         END
               ELSE                                       -- 3.   Prefix pjesa left deri tek nr i karaktereve @PrefixDinLength
                   SET @PrefixKonstant = SUBSTRING(@KodNew,1,@PrefixDinLength)         
             END;
                                      


         SET @iStart  = LEN(@PrefixKonstant)+1;

          SET @sSql   = N'
            
       SELECT @KodNew = CONVERT(VARCHAR, MAX(ISNULL(SUBSTRING(KOD,iStart,LEN(KOD)),0))+1)
         FROM '+@TableRef+' 
        WHERE LEFT(KOD,LEN(PrefixKonstant))=PrefixKonstant AND ISNUMERIC(SUBSTRING(KOD,iStart,LEN(KOD)))=1 AND LEN(KOD) = CodeLen; ';
        
          SET @sSql   = REPLACE(@sSql,'iStart',        CAST(@iStart    AS VARCHAR));    
          SET @sSql   = REPLACE(@sSql,'PrefixKonstant',QUOTENAME(@PrefixKonstant,''''));
          SET @sSql   = REPLACE(@sSql,'CodeLen',       CAST(@KodLength AS VARCHAR));  

      EXECUTE SP_EXECUTESQL @sSql, N'@KodNew VARCHAR(MAX) OUT',@KodNew OUTPUT;    --      PRINT @sSql;  PRINT @KodNew 

         SET @KodNew  = ISNULL(@KodNew,'1');
         
                

          IF @KodFormat=0           -- Modeli: 'AR00005631': Prefiks='AR', Pjese tjeter: '00005631'  
          
             BEGIN
               SET @KodNew = REPLICATE('0',@KodLength)+@KodNew;
               IF (@KodLength-@iStart+1)>0
                   SET @KodNew = @PrefixKonstant + RIGHT(@KodNew ,@KodLength-@iStart+1);
             END
                      
          ELSE
                 
          IF @KodFormat=1           -- Modeli: 'AR56310000': Prefiks='AR', Pjese tjeter: '56310000' 
          
             BEGIN
               SET @KodNew = @KodNew + REPLICATE('0',@KodLength);
               IF (@KodLength-@iStart+1)>0
                   SET @KodNew = @PrefixKonstant + LEFT(@KodNew ,@KodLength-@iStart+1);
             END
                      
          ELSE
                 
             BEGIN                  -- Modeli: 'AR5631': Prefiks='AR', Pjese tjeter: '5631'  
               SET @KodNew = @PrefixKonstant+@KodNew;
             END



      SELECT KOD = CASE WHEN ISNULL(@KodNew,'')='' THEN '' ELSE @KodNew END;


  
  
 
GO
