SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE         procedure [dbo].[Isd_AQAMDisplay2Metodes]
(

  @pDateEnd        Varchar(20),                      
  @pDateDok        Varchar(20),
  @pShenim1        Varchar(150),
  @pShenim2        Varchar(150),
  @pWhere          Varchar(Max),
  @pOper           Varchar(20),
  @pDepKart        Int,                 
  @pListKart       Int,
  @pModelAM        Int,                 
  @pUser           Varchar(30),
  @pTableTmp       Varchar(30),
  
  @pDisplayGroup   Int,
  @pSipasKartel    Int
)

AS

--      EXEC dbo.Isd_AQAMDisplay2Metodes '31/12/2022','31/12/2018','Amortizim vjetor','Amortizim makineri','R1.KOD>=''X'' AND R1.KOD<=''X010000zz''','',0,0,0,'ADMIN','',  0,1
--      EXEC dbo.Isd_AQAMDisplay2Metodes '31/12/2022','31/12/2018','Amortizim vjetor','Amortizim makineri','R1.KOD>=''X'' AND R1.KOD<=''X010000zz''','',0,0,0,'ADMIN','',  0,2


         SET NOCOUNT ON;

     DECLARE @DateEnd         Varchar(20),                      
             @DateDok         Varchar(20),
             @Shenim1         Varchar(150),
             @Shenim2         Varchar(150),
             @Where           Varchar(Max),
             @DepKart         Int,                 
             @ListKart        Int,
             @User            Varchar(30),
             @DisplayGroup    Int,
             @SipasKartel     Int,
             
             @Table1Name      Varchar(50),
             @Table2Name      Varchar(50),
             @sSql1           nVarchar(MAX);

         SET @DateEnd       = @pDateEnd;
         SET @DateDok       = @pDateDok;
         SET @Shenim1       = @pShenim1;
         SET @Shenim2       = @pShenim2;
         SET @Where         = @pWhere;
         SET @DepKart       = @pDepKart;                 
         SET @ListKart      = @pListKart;
         SET @User          = @pUser;
         SET @DisplayGroup  = @pDisplayGroup;
         SET @SipasKartel   = @pSipasKartel;

         SET @Table1Name    = '##AQTmpAM1';
         SET @Table2Name    = '##AQTmpAM2';
        
         IF  @SipasKartel=1
             BEGIN                   -- Gjenerimi i @Table1Name dhe @Table2Name perkatesishte sipas metodave
               EXEC dbo.Isd_AQAMDisplay @DateEnd,@DateDok,@Shenim1,@Shenim2,@Where,'NOTDISPL',@DepKart,@ListKart,0,@User,@Table1Name;  
               EXEC dbo.Isd_AQAMDisplay @DateEnd,@DateDok,@Shenim1,@Shenim2,@Where,'NOTDISPL',@DepKart,@ListKart,1,@User,@Table2Name;  
             END;



-- Rasti @SipasKartel=1 ben krijim te tabelave dhe njekohesisht afishim te pikes 1.         

-- 1. Afishim diferenca per cdo kartele (Analitik sipak kartelave:      @pSipasKartel=1)

         SET @sSql1 = '
         
      SELECT Kod           = A.KOD, 
             Pershkrim     = MAX(R1.PERSHKRIM),
             VleraAM1      = SUM(A.VleraAM1),
             VleraAM2      = SUM(A.VleraAM2),
             DiferenceAM12 = SUM(A.VleraAM1) - SUM(A.VleraAM2),
             DiferenceAM21 = SUM(A.VleraAM2) - SUM(A.VleraAM1),
             Kategori      = MAX(R1.KATEGORI), PershkrimKtg  = MAX(R2.PERSHKRIM),
-- Gr        Grup          = MAX(R1.GRUP),     PershkrimGrup = MAX(R3.PERSHKRIM),
             TRow          = CAST(0 As BIT),
             TagNr         = 0
             
        FROM 
            (
                SELECT KOD      = ISNULL(T1.KOD,''''), 
                       VleraAM1 = SUM(CASE WHEN ISNULL(T1.SeqNum,0)<>0 AND ISNULL(T1.TipRow,'''')<>''D'' THEN ISNULL(T1.VLERAAM,0) ELSE 0 END),
                       VleraAM2 = 0
                  FROM ##AAK1 T1 
              GROUP BY ISNULL(T1.KOD,'''')

             UNION ALL
   
                SELECT KOD      = ISNULL(T2.KOD,''''), 
                       VleraAM1 = 0,
                       VleraAM2 = SUM(CASE WHEN ISNULL(T2.SeqNum,0)<>0 AND ISNULL(T2.TipRow,'''')<>''D'' THEN ISNULL(T2.VLERAAM,0) ELSE 0 END)
                  FROM ##AAK2 T2 
              GROUP BY ISNULL(T2.KOD,'''') 
    
                     ) A INNER JOIN AQKARTELA  R1 ON A.KOD=R1.KOD
                         INNER JOIN AQKATEGORI R2 ON R1.KATEGORI=R2.KOD
-- Gr                    LEFT  JOIN AQGRUP     R3 ON R1.GRUP=R3.KOD
             
    GROUP BY A.KOD             
    ORDER BY Kategori,Kod;';


         SET @sSql1 = REPLACE(REPLACE(@sSql1,'##AAK1',@Table1Name),'##AAK2',@Table2Name);

          IF @DisplayGroup=1
             SET @sSql1 = REPLACE(REPLACE(@sSql1,' BY Kategori',' BY Grup,Kategori'),'-- Gr','     ');
             
          IF @SipasKartel=1
             BEGIN
             --PRINT @sSql1;
               EXEC (@sSql1);
               
               RETURN;
             END;     



-- Futen ne te njejten View grupimet sipas kategori dhe sipas llogari amortizimi dhe ne program ndahen sipas fushes TipRow

-- 2. Afishim diferenca grupuar sipas kategorive (Permbledhes sipas kategorive) :     @pSipasKartel=2

         SET @sSql1 = '
     DECLARE @TotalAM1 Float,
             @TotalAM2 Float;
             
      SELECT @TotalAM1          = SUM(CASE WHEN T1.SeqNum<>0 AND T1.TipRow<>''D'' THEN ISNULL(T1.VLERAAM,0) ELSE 0 END) 
        FROM ##AAK1 T1;
      SELECT @TotalAM2          = SUM(CASE WHEN T2.SeqNum<>0 AND T2.TipRow<>''D'' THEN ISNULL(T2.VLERAAM,0) ELSE 0 END) 
        FROM ##AAK2 T2;
         
      SELECT A.Kod,
             Pershkrim          = MAX(A.PERSHKRIMKTG),
-- Gr        Grup               = MAX(A.GRUP),    PershkrimGrup = MAX(A.PERSHKRIMGRUP),
             VleraAM1           = SUM(A.VLERAAM1),
             VleraAM2           = SUM(A.VLERAAM2),
             DiferenceAM12      = SUM(A.VLERAAM1-A.VLERAAM2),
             DiferenceAM21      = SUM(A.VLERAAM2-A.VLERAAM1),
             
             TotalAM1           = @TotalAM1,
             TotalAM2           = @TotalAM2,
             TotalDiferenceAM12 = @TotalAM1 - @TotalAM2,
             TotalDiferenceAM21 = @TotalAM2 - @TotalAM1,
             TipRow             = ''KTG'',
             TRow               = CAST(0 AS BIT),
             TagNr              = 0                 
             
        FROM 
            (
                SELECT Kod           = A.KOD,    
                       PershkrimKtg  = MAX(A.PERSHKRIM),
-- Gr                  Grup          = MAX(R1.GRUP),    PershkrimGrup = MAX(R2.PERSHKRIM),
                       VleraAM1      = SUM(CASE WHEN T1.SeqNum<>0 AND T1.TipRow<>''D'' THEN ISNULL(T1.VLERAAM,0) ELSE 0 END),
                       VleraAM2      = 0 
                  FROM AQKATEGORI A INNER JOIN AQKARTELA R1 ON A.KOD=R1.KATEGORI
-- Gr                               INNER JOIN AQGRUP    R2 ON R1.GRUP=R2.KOD                  
                                    INNER JOIN ##AAK1    T1 ON R1.KOD=T1.KOD 
              GROUP BY A.Kod     
    
             UNION ALL    

                SELECT Kod           = A.KOD,    
                       PershkrimKtg  = MAX(A.PERSHKRIM),
-- Gr                  Grup          = MAX(R1.GRUP),    PershkrimGrup = MAX(R2.PERSHKRIM),
                       VleraAM1      = 0,
                       VleraAM2      = SUM(CASE WHEN T2.SeqNum<>0 AND T2.TipRow<>''D'' THEN ISNULL(T2.VLERAAM,0) ELSE 0 END)
                  FROM AQKATEGORI A INNER JOIN AQKARTELA R1 ON A.KOD=R1.KATEGORI
-- Gr                               INNER JOIN AQGRUP    R2 ON R1.GRUP=R2.KOD                  
                                    INNER JOIN ##AAK2    T2 ON R1.KOD=T2.KOD 
              GROUP BY A.Kod 
               
             ) A
             
    GROUP BY A.Kod
--  ORDER BY A.Kod; ';
 


-- 3. Afishim diferenca grupuar sipas skeme kontabilizimi (Permbledhes sipas llogari amortizimi) :     @pSipasKartel=2

         SET @sSql1 = @sSql1 + '
         
   UNION ALL      
   
      SELECT A.Kod,
             Pershkrim          = MAX(A.PERSHKRIMLLG),
             VleraAM1           = SUM(A.VLERAAM1),
             VleraAM2           = SUM(A.VLERAAM2),
             DiferenceAM12      = SUM(A.VLERAAM1-A.VLERAAM2),
             DiferenceAM21      = SUM(A.VLERAAM2-A.VLERAAM1),
             
             TotalAM1           = @TotalAM1,
             TotalAM2           = @TotalAM2,
             TotalDiferenceAM12 = @TotalAM1 - @TotalAM2,
             TotalDiferenceAM21 = @TotalAM2 - @TotalAM1,
             TipRow             = ''LLG'',                 
             TRow               = CAST(0 AS BIT),
             TagNr              = 0                 
             
        FROM 
            (
                SELECT Kod           = ISNULL(R2.LLOGAM,''''),    
                       PershkrimLlg  = MAX(R3.PERSHKRIM),
                       VleraAM1      = SUM(CASE WHEN T1.SeqNum<>0 AND T1.TipRow<>''D'' THEN ISNULL(T1.VLERAAM,0) ELSE 0 END),
                       VleraAM2      = 0                 
                  FROM ##AAK1 T1    INNER JOIN AQKARTELA R1 ON T1.KOD=R1.KOD
                                    LEFT  JOIN AQSKEMELM R2 ON R1.KODLM=R2.KOD                  
                                    LEFT  JOIN LLOGARI   R3 ON R2.LLOGAM=R3.KOD 
              GROUP BY ISNULL(R2.LLOGAM,'''')     
    
             UNION ALL    

                SELECT Kod           = ISNULL(R2.LLOGAM,''''),    
                       PershkrimLlg  = MAX(R3.PERSHKRIM),
                       VleraAM1      = 0,
                       VleraAM2      = SUM(CASE WHEN T2.SeqNum<>0 AND T2.TipRow<>''D'' THEN ISNULL(T2.VLERAAM,0) ELSE 0 END)
                  FROM ##AAK2 T2    INNER JOIN AQKARTELA R1 ON T2.KOD=R1.KOD
                                    LEFT  JOIN AQSKEMELM R2 ON R1.KODLM=R2.KOD                  
                                    LEFT  JOIN LLOGARI   R3 ON R2.LLOGAM=R3.KOD 
              GROUP BY ISNULL(R2.LLOGAM,'''') 
               
             ) A
             
    GROUP BY A.Kod
    
    
    ORDER BY TipRow,Kod; ';
 

         SET @sSql1 = REPLACE(REPLACE(@sSql1,'##AAK1',@Table1Name),'##AAK2',@Table2Name);
         
          IF @DisplayGroup=1
             SET @sSql1 = REPLACE(REPLACE(@sSql1,' BY A.Kategori',' BY A.Grup,A.Kategori'),'-- Gr','     ');
             
          IF @SipasKartel=2
             BEGIN
             --PRINT @sSql1;
               EXEC (@sSql1);
            
               RETURN;
             END;  
GO
