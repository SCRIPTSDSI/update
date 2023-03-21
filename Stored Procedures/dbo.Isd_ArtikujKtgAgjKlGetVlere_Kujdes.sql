SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- EXEC Isd_ArtikujKtgAgjKlGetVlere 'A0002','001','D001',1200,1440,null
 
                                 
CREATE procedure [dbo].[Isd_ArtikujKtgAgjKlGetVlere_Kujdes]
(
   @pKodArtikull    Varchar(50),
   @pKodAgjent      VarChar(50),
   @pKodKlient      VarChar(50), 
   
   @pVleraPaTvsh    Float,
   @pVleraMeTvsh    Float,
   @pDateDok        Varchar(20)
)
AS





--         *****   KJO PROCEDURE NUK DUHET ME SEPSE MODIFIKIMI I KOEFICENTEVE DHE VLERAVE BEHET TEK ISD_DOCSAVEFJ   *****        -- 

--           Ne se do te duhej te perdoret ne program atehere perpara BeforePost (ose RegjistrimSCR) perdor store procedure Isd_ArtikujKtgAgjKlGetVlere
--           Shiko ne program proceduren SysF5Sql.GetVleraArtikujKtgAgjKl(pTable,pDataSet);




-- Testet e nevojeshme:

-- 1. Fusha ARTIKUJ.NOTACTIV           = False 
-- 2. Fusha ARTIKUJ.KATEGORI           <>''       (Te jete percaktuar me reference 'Kategori Artikuj')
-- 3. Fusha ARTIKUJ.APLKATEGORIAGJ     = True     (Apliko per agjente)
-- 4. Fusha ARTIKUJ.APLKATEGORIKL      = True     (Apliko per Klient)

-- 5. Fusha ARTIKUJKTG.NOTACTIV        = False 

-- 6. Fusha AGJENTSHITJE.APLARTIKUJKTG = True     (Aplikohen per agjentin bonuse sipas kategori artikuj te shitur)
-- 7. Fusha KLIENT.APLARTIKUJKTG       = True     (Aplikohen per klientin bonuse sipas kategori artikuj te shitur)


     DECLARE @KodArtikull     Varchar(50),
             @KodKlient       Varchar(50),
             @KodAgjent       Varchar(50),
             @KodKategoriA    Varchar(50),
             @KodKategoriK    Varchar(50),
             @KoeficentAgj    Float,
             @VleraAgj        Float,
             @KoeficentKL     Float,
             @VleraKL         Float;

         SET @KodArtikull   = ISNULL(@pKodArtikull,'');
         SET @KodKlient     = ISNULL(@pKodKlient,'');
         SET @KodAgjent     = ISNULL(@pKodAgjent,'');
         
      SELECT @KodKategoriA  = CASE WHEN ISNULL(A.APLKATEGORIAGJ,0)= 0 THEN '' ELSE ISNULL(A.KATEGORI,'') END,
             @KodKategoriK  = CASE WHEN ISNULL(A.APLKATEGORIKL,0) = 0 THEN '' ELSE ISNULL(A.KATEGORI,'') END
        FROM ARTIKUJ A INNER JOIN ARTIKUJKTG B ON ISNULL(A.KATEGORI,'')=B.KOD
       WHERE A.KOD=@KodArtikull AND ISNULL(B.NOTACTIV,0)=0; 


         SET @KodKategoriA  = ISNULL(@KodKategoriA,'');
         SET @KodKategoriK  = ISNULL(@KodKategoriK,'');

       
         IF (@KodKategoriA<>'') AND (NOT EXISTS (SELECT KOD FROM AGJENTSHITJE WHERE KOD=@KodAgjent AND ISNULL(APLARTIKUJKTG,0)=1) )
             SET @KodKategoriA = '';
       
         IF (@KodKategoriK<>'') AND (NOT EXISTS (SELECT KOD FROM KLIENT       WHERE KOD=@KodKlient AND ISNULL(APLARTIKUJKTG,0)=1) )    
             SET @KodKategoriK = '';
             
       
                    
         IF  @KodKategoriA='' AND @KodKategoriK=''
             BEGIN
             
               SELECT KoeficentAgj = 0, VleraAgj = 0, KoeficentKL = 0, VleraKL = 0;
               
               RETURN;
               
             END;
             
        
      SELECT @KoeficentAgj  = MAX(ISNULL(B.VLEFTE,0))
        FROM ArtikujKtgAgj A INNER JOIN ArtikujKtgAgjScr B ON A.NRRENDOR=B.NRD
       WHERE B.KOD=@pKodAgjent AND KODAF=@KodKategoriA AND ISNULL(A.ACTIV,0)=0; -- Ndoshta @pDateDok brenda [Datat Fillim - date fund] 

      SELECT @KoeficentKL   = MAX(ISNULL(B.VLEFTE,0))
        FROM ArtikujKtgKL  A INNER JOIN ArtikujKtgKLScr  B ON A.NRRENDOR=B.NRD
       WHERE B.KOD=@pKodKlient AND KODAF=@KodKategoriK AND ISNULL(A.ACTIV,0)=0; -- Ndoshta @pDateDok brenda [Datat Fillim - date fund]

         SET @KoeficentAgj  = ISNULL(@KoeficentAgj,0);
         SET @KoeficentKL   = ISNULL(@KoeficentKL, 0);


      SELECT KoeficentAgj   = @KoeficentAgj,  VleraAgj  = ROUND(@KoeficentAgj*@pVleraPaTvsh,2), 
             KoeficentKL    = @KoeficentKL,   VleraKL   = ROUND(@KoeficentKL *@pVleraPaTvsh,2);












GO
