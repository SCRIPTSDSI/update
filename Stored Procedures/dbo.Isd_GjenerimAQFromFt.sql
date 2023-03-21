SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- EXEC dbo.Isd_GjenerimAqFromFt 'FF',76156,'',''


CREATE         Procedure [dbo].[Isd_GjenerimAQFromFt]
(
  @pTableName     Varchar(30),
  @pNrRendor      Int,
  @pUser          Varchar(20),
  @pLgJob         Varchar(30)
 )

AS


         SET NOCOUNT ON


     DECLARE @NrRendor       Int,
             @TableName      Varchar(30),
             @Perdorues      Varchar(30),
             @LgJob          Varchar(30),
             @IDMStatus      Varchar(5),

             @LlojDok        Varchar(10),
             @KodOper        Varchar(10),
             @TipFat         Varchar(10),
             @NrDMag         Int,
             @NrRendorAq     Int,
             @NrDokAq        Int,
             @NRDFkAq        Int,
             @NewID          Int,
             @RowCount       Int,
             @Vlere          Float,
             @Kurs1          Float,
             @Kurs2          Float,
             @NewAq          Bit,
             @sSql           nVarchar(MAX);

         SET @NrRendor     = @PNrRendor;
         SET @TableName    = UPPER(@pTableName);
         SET @Perdorues    = @PUser;
         SET @LgJob        = @PLgJob;


          IF CHARINDEX(','+@TableName+',',',FF,FJ,')=0
             RETURN;
             

      SELECT @NewAq=0, @NewId=0, @NRDFkAQ=0, @NrDokAq = 0

          IF @TableName='FF'
             BEGIN
               SET    @KodOper      = 'BL';
               SET    @TipFat       = 'F';
               SELECT @NrRendorAq   = ISNULL(NRRENDORAQ,0), 
                      @Kurs1        = ISNULL(KURS1,1),
                      @Kurs2        = ISNULL(KURS2,1),
                      @LlojDok      = LLOJDOK
                 FROM FF 
                WHERE NRRENDOR = @NrRendor; --AND (NRMAG<>0) AND (NRDMAG<>0) 

             END
             
          ELSE
             BEGIN
               SET    @KodOper      = 'SH';
               SET    @TipFat       = 'S';
               SELECT @NrRendorAq   = ISNULL(NRRENDORAQ,0), 
                      @Kurs1        = ISNULL(KURS1,1),
                      @Kurs2        = ISNULL(KURS2,1),
                      @LlojDok      = LLOJDOK
                 FROM FJ 
                WHERE NRRENDOR = @NrRendor; --AND (NRMAG<>0) AND (NRDMAG<>0) 

             END;   



          IF @NrRendorAq>0
             BEGIN
               DECLARE @ChangeDoc Bit,
                       @ChangeScr Bit;

--                EXEC dbo.Isd_ChangeAqFromFt @TableName, '', @NrRendor, @ChangeDoc Out, @ChangeScr Out -- SELECT @ChangeDoc , @ChangeScr

                    IF @ChangeDoc=0 And @ChangeScr=0
                       BEGIN
                         RETURN;
                       END;

                    IF @ChangeDoc=1 And @ChangeScr=0
                       BEGIN
                         EXEC   dbo.Isd_UpdateAqFromFt @TableName,@NrRendor,@Perdorues,@LgJob
                         RETURN;
                       END;
             END;

-- Vazhdon ndertimin e dokumentit Aktiv ...

          IF @NrRendorAq>0
             BEGIN
               SELECT @NewID        = NRRENDOR, 
                      @NrDokAq      = NRDOK,
                      @NRDFkAq      = ISNULL(NRDFK,0),
                      @Vlere        = (SELECT SUM(VLERAM) From AQSCR Where NRD=@NrRendorAq)
                 From AQ A
                Where NRRENDOR=@NrRendorAq;

             END;

          IF @NRDFkAq>0
             BEGIN
               EXEC   Dbo.LM_DELFK @NRDFkAQ
               
               UPDATE AQ  SET NRDFK=0 Where NRRENDOR=@NrRendorAq;
             END;

-- Kujdes Ilir
--        IF @NrMag<>0 or @NrDMag<>0
--           BEGIN
               IF ( @TableName='FF' AND (EXISTS ( SELECT *                                    -- Ndryshuar me 15.09.2020 kur u fut prekja e asetit nga resht llogari ose sherbim
                                                    FROM FFSCR                                -- Ne keto raste KODAQ<>'' 
                                                   WHERE NRD=@NrRendor AND (TIPKLL='X' OR ISNULL(KODAQ,'')<>'') --AND ISNULL(NOTMAG,0)=0
                                                    )) )    
                    OR 
                    
                  ( @TableName='FJ' AND (EXISTS ( SELECT * 
                                                    FROM FJSCR 
                                                   WHERE NRD=@NrRendor AND (TIPKLL='X' OR ISNULL(KODAQ,'')<>'') --AND ISNULL(NOTMAG,0)=0
                                                    )) )
                                                    
                   SET @NewAq =1;
                   
             /*IF ( @TableName='FF' AND (EXISTS ( SELECT *                                    -- Ishte perpara 15.09.2020
                                                    FROM FFSCR 
                                                   WHERE NRD=@NrRendor AND TIPKLL='X' --AND ISNULL(NOTMAG,0)=0
                                                    )) )    OR 
                  ( @TableName='FJ' AND (EXISTS ( SELECT * 
                                                    FROM FJSCR 
                                                   WHERE NRD=@NrRendor AND TIPKLL='X' --AND ISNULL(NOTMAG,0)=0
                                                    )) )
                                                    
                   SET @NewAq =1;*/
--           END;

          IF @NewAq=0   
             BEGIN

               IF @NrRendorAq>0
                  BEGIN

                    EXEC   dbo.Isd_AppendTransLog 'AQ', @NrRendorAq, @Vlere,'D',@Perdorues,@LgJob;
                    DELETE FROM AQ WHERE NRRENDOR=@NrRendorAq 

                    IF @TableName='FF' 
                       UPDATE FF SET NRRENDORAQ=0 WHERE NRRENDOR=@NrRendor
                    ELSE
                       UPDATE FJ SET NRRENDORAQ=0 WHERE NRRENDOR=@NrRendor;

                  END;

               RETURN;

             END;


         SET @IDMStatus = 'M';

          IF @NewID<=0         -- Print @NewID;
             BEGIN            
                   SET  @NewID = 0;

                INSERT  Into AQ 
                       (NRRENDORFAT)
                VALUES (@NrRendor);

                   SET  @RowCount=@@ROWCOUNT;

                    IF  @RowCount<>0
                        SELECT @NewID=@@IDENTITY;  

                   SET  @IDMStatus='S';
             END;
        

          IF @NrRendorAq<>@NewID
             BEGIN
               IF  @TableName='FF'
                   BEGIN 
                     UPDATE FF SET NRRENDORAQ=@NewID WHERE NRRENDOR=@NrRendor
                   END  
               ELSE
                   BEGIN
                     UPDATE FJ SET NRRENDORAQ=@NewID WHERE NRRENDOR=@NrRendor
                   END;
                       
               SET @NrRendorAq = @NewID;
             END;

          IF @NrRendorAq<=0
             RETURN;


       IF @NrRendorAq>0
          BEGIN
            DELETE FROM AQSCR WHERE NRD = @NrRendorAq
          END;
          
       IF @TableName='FF'
          BEGIN
          
            UPDATE A
                 SET A.NRMAG        = B.NRMAG,
                     A.KMAG         = B.KMAG,
                     A.NRDOK        = CASE WHEN ISNULL(@NrDokAq,0)>0 
                                           THEN @NrDokAq 
                                           ELSE (SELECT MAX(ISNULL(Q.NRDOK,0))+1 FROM AQ Q WHERE YEAR(Q.DATEDOK)=YEAR(B.DATEDOK))
                                      END,
                     A.DATEDOK      = B.DATEDOK,
                     A.NRFRAKS      = 0,
                     A.SHENIM1      = B.SHENIM1,
                     A.SHENIM2      = B.SHENIM2,
                     A.SHENIM3      = B.SHENIM3,
                     A.SHENIM4      = B.SHENIM4,
                     A.DOK_JB       = 1,
                     A.GRUP         = '',
                     A.KTH          = B.KTH,
                     A.NRRENDORFAT  = B.NRRENDOR,
                     A.TIPFAT       = @TipFat,
                     A.DST          = @KodOper, -- Rastet Kthim,Stornim ????  
                     A.TIP          = '',  
                     A.USI          = B.USI,
                     A.USM          = B.USM,
                     A.POSTIM       = 0,
                     A.LETER        = 0,  
                     A.FIRSTDOK     = B.FIRSTDOK,
                     A.NRDFK        = 0,
                     A.DATEEDIT     = GETDATE()
                FROM AQ A INNER JOIN FF B On A.NRRENDOR=B.NRRENDORAQ
               WHERE A.NRRENDOR=@NrRendorAq AND B.NRRENDOR=@NrRendor;


              INSERT INTO AQSCR 
                    (NRD, KOD, KODAF, KARTLLG, PERSHKRIM, NRRENDKLLG, NJESI,
                     SASI,NORMEAM,VLERAAM,
                     CMIMM,VLERAM,CMIMOR,VLERAOR,CMIMBS,VLERABS,CMIMSH,VLERASH,VLERAFT, VLERAFAT,VLERAFATMV,VLERAEXTMV,
                     DATEOPER,KODOPER,KODFKL,PERSHKRIMFKL,KODPRONESI,PERSHKRIMPRONESI,KODLOCATION,PERSHKRIMLOCATION, 
                     KOEFSHB, NJESINV, BC, KOMENT, KMON,KURS1,KURS2,TIPKLL, STATROW,ORDERSCR)
              SELECT @NrRendorAq, 

                                                                                               -- Ndryshuar me 15.09.2020 kur u fut prekja e asetit nga resht llogari ose sherbim
                     KOD            = CASE WHEN A.TIPKLL='X' THEN dbo.Isd_SegmentNewInsert(A.KOD,'',5)                                                           -- Aseti me mon baze
                                           WHEN A.TIPKLL='L' THEN dbo.Isd_SegmentNewInsert(dbo.Isd_SegmentNewInsert(A.KOD,'',5),ISNULL(A.KODAQ,''),1)            -- Aseti pa mon baze
                                           WHEN A.TIPKLL='K' THEN ISNULL(A.KODAQ,'')+'.'+Dbo.Isd_SegmentFind(A.KOD,0,3)+'.'+Dbo.Isd_SegmentFind(A.KOD,0,4)+'..'  -- Aset+Dep+List
                                           ELSE                   ISNULL(A.KODAQ,'')+'....'                                                                      -- RSF
                                      END, 
                     KODAF          = CASE WHEN A.TIPKLL='X'               THEN A.KODAF
                                           WHEN CHARINDEX(A.TIPKLL,'LK')>0 THEN dbo.Isd_SegmentNewInsert(A.KODAF,ISNULL(A.KODAQ,''),1)
                                           ELSE                                 A.KODAQ
                                      END, 
                     KARTLLG        = CASE WHEN A.TIPKLL='X' THEN A.KARTLLG
                                           ELSE                   A.KODAQ
                                      END,
                     PERSHKRIM      = CASE WHEN A.TIPKLL='X' THEN A.PERSHKRIM
                                           ELSE                  (SELECT R1.PERSHKRIM FROM AQKARTELA R1 WHERE R1.KOD=A.KODAQ)
                                      END, 
                     NRRENDKLLG     = CASE WHEN A.TIPKLL='X' THEN A.NRRENDKLLG
                                           ELSE                  (SELECT R1.NRRENDOR  FROM AQKARTELA R1 WHERE R1.KOD=A.KODAQ)
                                      END, 
                     NJESI          = CASE WHEN A.TIPKLL='X' THEN A.NJESI
                                           ELSE                  (SELECT R1.NJESI     FROM AQKARTELA R1 WHERE R1.KOD=A.KODAQ)
                                      END,

                                                                                               -- Ishte perpara 15.09.2020 
                  -- KOD            = Dbo.Isd_SegmentNewInsert(A.KOD,'',5), A.KODAF, A.KARTLLG, A.PERSHKRIM, A.NRRENDKLLG, A.NJESI,
                  
                  
                     A.SASI,
                     NORMEAM        = 0,
                     VLERAAM        = 0,
                       
                     CMIMM          = ROUND((A.CMIMBS * @Kurs2)/@Kurs1,3), 
                     VLERAM         = ROUND((A.VLPATVSH*@Kurs2)/@Kurs1,3), 
                     CMIMOR         = ROUND((A.CMIMBS * @Kurs2)/@Kurs1,3), 
                     VLERAOR        = ROUND((A.VLPATVSH*@Kurs2)/@Kurs1,3),
                     CMIMBS         = ROUND((A.CMIMBS * @Kurs2)/@Kurs1,3), 
                     VLERABS        = ROUND((A.VLPATVSH*@Kurs2)/@Kurs1,3),
                     CMIMSH         = ROUND((A.CMIMBS * @Kurs2)/@Kurs1,3),
                     VLERASH        = ROUND((A.VLPATVSH*@Kurs2)/@Kurs1,3),
                     VLERAFT        = ROUND((A.VLPATVSH*@Kurs2)/@Kurs1,3),
                     
                     VLERAFAT       = A.VLPATVSH,
                     VLERAFATMV     = ROUND((A.VLPATVSH*@Kurs2)/@Kurs1,3), 
                     VLERAEXTMV     = 0,
                      
                     B.DATEDOK,
                     
                     
                  -- Me algoritmin me poshte nuk ka nevoje qe te meret nga FFSCR.KODOPER   
                  -- @KodOper,          
                  
                                                              -- e re pas 11.09.2020 per te dalluar blerjen nga riparim kapital .... 
                                                              -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
                     KODOPER        = CASE WHEN ISNULL(A.KODAQ,'')<>''
                                                THEN 'SR'
                                           WHEN EXISTS ( SELECT * FROM AQSCR S2 WHERE S2.KARTLLG=A.KARTLLG AND S2.KODOPER IN ('CE','BL') AND S2.NRRENDOR<>A.NRRENDOR ) --AND ISNULL(S2.DATEOPER,S1.DATEDOK)<A.DATEDOK )
                     
                                   /*      WHEN EXISTS ( SELECT S2.NRRENDOR    -- e re pas 26.02.2020 per te dalluar blerjen nga riparim kapital .... 
                                                           FROM AQSCR S2 
                                                          WHERE S2.KARTLLG=A.KARTLLG) -- AND ISNULL(S2.DATEOPER,S1.DATEDOK)<B.DATEDOK ) -- ??

                                           WHEN EXISTS ( SELECT S2.NRRENDOR    -- e re pas 26.04.2019 per te mos pasur disa blerje ....
                                                           FROM AQ S1 INNER JOIN AQSCR S2 ON S1.NRRENDOR=S2.NRD 
                                                          WHERE S2.KARTLLG=A.KARTLLG  AND ISNULL(S2.DATEOPER,S1.DATEDOK)<A.DATEDOK ) -- ?? */

                                                THEN 'RK'
                                           ELSE 
                                                     'BL'
                                      END,     
                     
                     B.KODFKL,B.SHENIM1,KODPRONESI,PERSHKRIMPRONESI,KODLOCATION,PERSHKRIMLOCATION, 
                     A.KOEFSHB, 
                     
                                                                                               -- Ndryshuar me 15.09.2020 kur u fut prekja e asetit nga resht llogari ose sherbim
                     NJESINV        = CASE WHEN A.TIPKLL='X' THEN A.NJESINV
                                           ELSE                  (SELECT R1.NJESI     FROM AQKARTELA R1 WHERE R1.KOD=A.KODAQ)
                                      END, 
                     BC             = CASE WHEN A.TIPKLL='X' THEN A.BC
                                           ELSE                  (SELECT R1.BC        FROM AQKARTELA R1 WHERE R1.KOD=A.KODAQ)
                                      END, 
                  -- A.NJESINV, A.BC,                                                          -- Ishte perpara 15.09.2020 
                  
                  
                     A.KOMENT, B.KMON,@Kurs1,@Kurs2,TIPKLL='X',STATROW='',ORDERSCR=0
                     
                FROM FFSCR A INNER JOIN FF B ON A.NRD=B.NRRENDOR
                
               WHERE (A.NRD=@NrRendor) AND (A.TIPKLL='X' OR ISNULL(A.KODAQ,'')<>'')            -- Ndryshuar me 15.09.2020 kur u fut prekja e asetit nga resht llogari ose sherbim
--             WHERE (A.NRD=@NrRendor) AND (A.TIPKLL='X')                                      -- Ishte perpara 15.09.2020  

            ORDER BY A.NRD,A.NRRENDOR;                        
            
          END;


       IF @TableName='FJ'
          BEGIN
          
            UPDATE A
                 SET A.NRMAG        = B.NRMAG,
                     A.KMAG         = B.KMAG,
                     A.NRDOK        = CASE WHEN ISNULL(@NrDokAq,0)>0 
                                           THEN @NrDokAq 
                                           ELSE (SELECT MAX(AQ.NRDOK)+1 FROM AQ WHERE YEAR(AQ.DATEDOK)=YEAR(B.DATEDOK))
                                      END,
                     A.DATEDOK      = B.DATEDOK,
                     A.NRFRAKS      = 0,
                     A.SHENIM1      = B.SHENIM1,
                     A.SHENIM2      = B.SHENIM2,
                     A.SHENIM3      = B.SHENIM3,
                     A.SHENIM4      = B.SHENIM4,
                     A.DOK_JB       = 1,
                     A.GRUP         = '',
                     A.KTH          = B.KTH,
                     A.NRRENDORFAT  = B.NRRENDOR,
                     A.TIPFAT       = @TipFat,
                     A.DST          = @KodOper,                  -- Rastet Kthim,Stornim ????  
                     A.TIP          = '',  
                     A.USI          = B.USI,
                     A.USM          = B.USM,
                     A.POSTIM       = 0,
                     A.LETER        = 0,  
                     A.FIRSTDOK     = B.FIRSTDOK,
                     A.NRDFK        = 0,
                     A.DATEEDIT     = GETDATE()
                     
                FROM AQ A INNER JOIN FJ B On A.NRRENDOR=B.NRRENDORAQ
                
               WHERE A.NRRENDOR=@NrRendorAq AND B.NRRENDOR=@NrRendor;


              INSERT INTO AQSCR 
                    (NRD,  KOD, KODAF, KARTLLG, PERSHKRIM, NRRENDKLLG, NJESI,
                     SASI,NORMEAM,VLERAAM, 
                     CMIMM,VLERAM,CMIMOR,VLERAOR,CMIMBS,VLERABS,CMIMSH,VLERASH,VLERAFT,VLERAFAT,VLERAFATMV, VLERAEXTMV, 
                     DATEOPER,KODOPER,KODFKL,PERSHKRIMFKL,
                     KOEFSHB, NJESINV,BC,KOMENT,KMON,KURS1,KURS2,TIPKLL,STATROW,ORDERSCR)
              SELECT @NrRendorAq,

                                                                                               -- Ndryshuar me 15.09.2020 kur u fut prekja e asetit nga resht llogari ose sherbim 
                     KOD            = CASE WHEN A.TIPKLL='X' THEN dbo.Isd_SegmentNewInsert(A.KOD,'',5)                                                           -- Aseti me mon baze
                                           WHEN A.TIPKLL='L' THEN dbo.Isd_SegmentNewInsert(dbo.Isd_SegmentNewInsert(A.KOD,'',5),ISNULL(A.KODAQ,''),1)            -- Aseti pa mon baze
                                           WHEN A.TIPKLL='K' THEN ISNULL(A.KODAQ,'')+'.'+Dbo.Isd_SegmentFind(A.KOD,0,3)+'.'+Dbo.Isd_SegmentFind(A.KOD,0,4)+'..'  -- Aset+Dep+List
                                           ELSE                   ISNULL(A.KODAQ,'')+'....'                                                                      -- RSF
                                      END, 
                     KODAF          = CASE WHEN A.TIPKLL='X'               THEN A.KODAF
                                           WHEN CHARINDEX(A.TIPKLL,'LK')>0 THEN dbo.Isd_SegmentNewInsert(A.KODAF,ISNULL(A.KODAQ,''),1)
                                           ELSE                                 A.KODAQ
                                      END, 
                     KARTLLG        = CASE WHEN A.TIPKLL='X' THEN A.KARTLLG
                                           ELSE                   A.KODAQ
                                      END,
                     PERSHKRIM      = CASE WHEN A.TIPKLL='X' THEN A.PERSHKRIM
                                           ELSE                  (SELECT R1.PERSHKRIM FROM AQKARTELA R1 WHERE R1.KOD=A.KODAQ)
                                      END, 
                     NRRENDKLLG     = CASE WHEN A.TIPKLL='X' THEN A.NRRENDKLLG
                                           ELSE                  (SELECT R1.NRRENDOR  FROM AQKARTELA R1 WHERE R1.KOD=A.KODAQ)
                                      END, 
                     NJESI          = CASE WHEN A.TIPKLL='X' THEN A.NJESI
                                           ELSE                  (SELECT R1.NJESI     FROM AQKARTELA R1 WHERE R1.KOD=A.KODAQ)
                                      END,
                                                                                               -- Ishte perpara 15.09.2020 
                  -- KOD            = Dbo.Isd_SegmentNewInsert(A.KOD,'',5), A.KODAF, A.KARTLLG, A.PERSHKRIM, A.NRRENDKLLG, A.NJESI,


                     A.SASI,
                     NORMEAM        = 0,
                     VLERAAM        = 0, 
                     
                     CMIMM          = ROUND((A.CMIMBS * @Kurs2)/@Kurs1,3), 
                     VLERAM         = 0,                                         -- ROUND((A.VLPATVSH*@Kurs2)/@Kurs1,3)
                     CMIMOR         = ROUND((A.CMIMBS * @Kurs2)/@Kurs1,3), 
                     VLERAOR        = ROUND((A.VLPATVSH*@Kurs2)/@Kurs1,3),
                     CMIMBS         = ROUND((A.CMIMBS * @Kurs2)/@Kurs1,3), 
                     VLERABS        = ROUND((A.VLPATVSH*@Kurs2)/@Kurs1,3),
                     CMIMSH         = ROUND((A.CMIMBS * @Kurs2)/@Kurs1,3),
                     VLERASH        = ROUND((A.VLPATVSH*@Kurs2)/@Kurs1,3),
                     VLERAFT        = ROUND((A.VLPATVSH*@Kurs2)/@Kurs1,3),
                     
                     VLERAFAT       = A.VLPATVSH,
                     VLERAFATMV     = ROUND((A.VLPATVSH*@Kurs2)/@Kurs1,3), 
                     VLERAEXTMV     = 0,
                     
                     B.DATEDOK,
                     KODOPER=@KodOper,
                     B.KODFKL,B.SHENIM1,  
                     A.KOEFSHB,
                     
                                                                                               -- Ndryshuar me 15.09.2020 kur u fut prekja e asetit nga resht llogari ose sherbim 
                     NJESINV        = CASE WHEN A.TIPKLL='X' THEN A.NJESINV
                                           ELSE                  (SELECT R1.NJESI     FROM AQKARTELA R1 WHERE R1.KOD=A.KODAQ)
                                      END, 
                     BC             = CASE WHEN A.TIPKLL='X' THEN A.BC
                                           ELSE                  (SELECT R1.BC        FROM AQKARTELA R1 WHERE R1.KOD=A.KODAQ)
                                      END, 
                  -- A.NJESINV, A.BC,                                                          -- Ishte perpara 15.09.2020 
                  

                     A.KOMENT,B.KMON,@Kurs1,@Kurs2,TIPKLL='X',STATROW='',ORDERSCR=0
                     
                FROM FJSCR A INNER JOIN FJ B ON A.NRD=B.NRRENDOR
                
               WHERE (A.NRD=@NrRendor) AND (A.TIPKLL='X' OR ISNULL(A.KODAQ,'')<>'')           -- Ndryshuar me 15.09.2020 kur u fut prekja e asetit nga resht llogari ose sherbim 
            -- WHERE (A.NRD=@NrRendor) AND (A.TIPKLL='X')                                      -- Ishte perpara 15.09.2020 

            ORDER BY A.NRD,A.NRRENDOR;
            
          END;


      SELECT @Vlere = SUM(ISNULL(VLERABS,0))
        FROM AQSCR A
       WHERE NRD=@NrRendorAq;  

        EXEC dbo.Isd_AppendTransLog 'AQ', @NrRendorAq, @Vlere, @IDMStatus, @Perdorues, @LgJob;
GO
