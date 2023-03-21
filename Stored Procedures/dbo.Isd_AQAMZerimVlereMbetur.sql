SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE        procedure [dbo].[Isd_AQAMZerimVlereMbetur]  
(                                               
  @pDateOper        Varchar(20),
  @pWhere           Varchar(Max),
  @pModelAM         Int,         
  @pKoment          Varchar(200),  -- duhen Shenim1=Pershkrim,Shenim2=Koment
  @pDep             Varchar(30),
  @pList            Varchar(30),
  @pDepRef          Int,
  @pListRef         Int,
  @pOnlyAmortizuar  Int,   
  @pOper            Varchar(10),
  @pTableTmp        Varchar(30),
  @pUser            Varchar(30)  -- A duhet ???
  
)

AS   
          -- EXEC dbo.Isd_AQAMZerimVlereMbetur '31/12/2022','R1.KOD=''X03000014''',1,'Kalim ne shpenzim te vleftes se amortizimit te mbetur','','',0,0,1,'A','#AA','ADMIN';


         SET NOCOUNT ON


          IF OBJECT_ID('TempDB..#AQKartela') IS NOT NULL
             DROP TABLE #AQKartela;
        
        
     DECLARE @sDateOper        Varchar(20),
             @sWhere           nVarchar(Max),
             @ModelAM          Int,             
             @sKoment          Varchar(200),
             @sDep             Varchar(30),
             @sList            Varchar(30),
             @iDepRef          Int,
             @iListRef         Int,
             @sTableTmp        Varchar(30),
             @OnlyAmortizuar   Int,
             @sOper            Varchar(10),
             @NrRendor         BigInt,
             @DateDok          DateTime,
             @sSql             nVarchar(Max),
             @TotalVlere       Float;
             
         SET @sDateOper      = @pDateOper; 
         SET @sWhere         = @pWhere; 
         SET @ModelAM        = @pModelAM
         SET @sKoment        = @pKoment;
         SET @sDep           = @pDep;
         SET @sList          = @pList;
         SET @iDepRef        = ISNULL(@pDepRef,0);
         SET @iListRef       = ISNULL(@pListRef,0);
         SET @sTableTmp      = @pTableTmp;
         SET @sOper          = ISNULL(@pOper,'DISPROW');
         SET @OnlyAmortizuar = @pOnlyAmortizuar;
         SET @DateDok        = dbo.DateValue(@sDateOper);


      SELECT KARTLLG, VLEREHISTORIKE=VLERABS, AMORTIZIMTOTAL=VLERABS, VLEREMBETUR=VLERABS, KOD
        INTO #AQKartela
        FROM AQSCR 
       WHERE 1=2; 


         SET @sSql          = '
         
      INSERT INTO #AQKartela
      SELECT A.KARTLLG, A.VLEREHISTORIKE,A.AMORTIZIMTOTAL,A.VLEREMBETUR, KOD = A.KARTLLG+''....''
        FROM Isd_AQGjendjeAktivi A INNER JOIN AQKARTELA R1 ON A.KARTLLG=R1.KOD
       WHERE ISNULL(CREGJISTRUAR,0)=0 AND ISNULL(VLEREMBETUR,0)>0  AND
             (1=1) AND 
             (2=2) ;';

        IF   @pOnlyAmortizuar=1
             SET @sSql = REPLACE(@sSql,'1=1','ISNULL(VLEREPERAMORTIZIM1,0)<=ISNULL(CALCULVLEREMIN1,0)')

        IF   @ModelAM=2         -- Zerim sipas Amortizim modeli 2
             SET @sSql = Replace(@sSql,'1,0)','2,0)');
             
        IF   @sWhere<>''
             SET @sSql = Replace(@sSql,'2=2',@sWhere);

        EXEC (@sSql);



-- Update Kod me Dep/Liste nga Referencat ose me parameter


        IF   @iDepRef=1                     -- Ne se Departamenti meret nga Referenca atehere @sDep =''
             SET @sDep  = '';
             
        IF   @iListRef=1                    -- Ne se Lista        meret nga Referenca atehere @sList=''
             SET @sList = '';

        IF   @sDep<>''  AND (NOT EXISTS (SELECT KOD FROM DEPARTAMENT WHERE KOD=@sDep))
             SET @sDep  = '';
            
        IF   @sList<>'' AND (NOT EXISTS (SELECT KOD FROM LISTE       WHERE KOD=@sList))
             SET @sList = '';
           

-- 1. Update Kod me Dep/Liste nga Referencat

        IF   @iDepRef=1 AND @iListRef=1
             BEGIN
               UPDATE A
                  SET A.KOD = A.KARTLLG+'.'+ISNULL(R1.DEP,'')+'.'+ISNULL(R1.LIST,'')+'..'
                 FROM #AQKartela A INNER JOIN AQKARTELA R1 ON A.KARTLLG=R1.KOD
             END  
             
        ELSE 
              
        IF   @iDepRef=1 AND @iListRef=0
             BEGIN
               UPDATE A
                  SET A.KOD = A.KARTLLG+'.'+ISNULL(R1.DEP,'')+'...'
                 FROM #AQKartela A INNER JOIN AQKARTELA R1 ON A.KARTLLG=R1.KOD
             END
             
        ELSE        

        IF   @iDepRef=0 AND @iListRef=1
             BEGIN
               UPDATE A
                  SET A.KOD = A.KARTLLG+'..'+ISNULL(R1.LIST,'')+'..'
                 FROM #AQKartela A INNER JOIN AQKARTELA R1 ON A.KARTLLG=R1.KOD
             END;
                 

-- 2. Update Kod me Dep/Liste me parametra njesoj per te gjitha aktivet 

        IF   @sDep<>'' AND @sList<>''
             BEGIN
               UPDATE #AQKartela SET KOD = KARTLLG+'.'+@sDep+'.'+@sList+'..'
             END
             
        ELSE 
           
        IF   @sDep<>''  
             BEGIN
               UPDATE #AQKartela SET KOD = dbo.Isd_SegmentNewInsert(KOD,@sDep,2)
             END
             
        ELSE 
           
        IF   @sList<>''  
             BEGIN
               UPDATE #AQKartela SET KOD = dbo.Isd_SegmentNewInsert(KOD,@sList,3)
             END;

          IF @sOper='DISPROW'               -- Vetem Afishim kartela
             BEGIN
                 SELECT @TotalVlere=SUM(ROUND(A.VLEREMBETUR,2)) 
                   FROM #AQKartela A INNER JOIN AQKARTELA  R1 ON A.KARTLLG=R1.KOD
                                     LEFT  JOIN AQKATEGORI R2 ON R1.KATEGORI=R2.KOD;
                                     
                 SELECT KOD                = A.KARTLLG,
                        PERSHKRIM          = R1.PERSHKRIM,
                        KOMENT             = @sKoment,      
                        VLEREHISTORIKE     = ROUND(A.VLEREHISTORIKE,2), -- @TotalVlere
                        AMORTIZIMAKUMULUAR = ROUND(A.AMORTIZIMTOTAL,2), -- @TotalVlere
                        VLEREMBETUR        = ROUND(A.VLEREHISTORIKE,2)-ROUND(A.AMORTIZIMTOTAL,2),
                        DATEOVEPRIMI       = dbo.DateValue(@sDateOper),  
                        VEPRIMI            = dbo.Isd_AQOperDetailDisplay('CR'),
                        KATEGORI           = R1.KATEGORI,
                        GRUP               = R1.GRUP,
                        KODLM              = R1.KODLM

                   FROM #AQKartela A INNER JOIN AQKARTELA  R1 ON A.KARTLLG=R1.KOD
                                     LEFT  JOIN AQKATEGORI R2 ON R1.KATEGORI=R2.KOD
               ORDER BY A.KARTLLG;

                   GOTO FUND;
               
             END;
             


          IF @sOper='GJENROW'               -- Create ne Scr (Modifikim dokumenti AQ)
             BEGIN
             
               SET @sDateOper = QuoteName(@sDateOper,''''); 

               SET @sSql = '

                 DELETE FROM '+@sTableTmp+';
      
                 INSERT INTO '+@sTableTmp+'
      
                      ( KOD, KODAF, KARTLLG, PERSHKRIM, KOMENT,  VLERABS, VLERAAM, KODOPER, DATEOPER,
                        NORMEAM, BC, NJESI, SASI, NJESINV, KMON, KURS1, KURS2,  TIPKLL, NRRENDKLLG )
        
                 SELECT KOD            = A.KOD,
                        KODAF          = dbo.Isd_SegmentsToKodAF(A.KOD),
                        KARTLLG        = A.KARTLLG,
                        PERSHKRIM      = R1.PERSHKRIM,
                        KOMENT         = '''+@sKoment+''',      
                        VLERABS        = ROUND(A.VLEREHISTORIKE,2),
                        VLERAAM        = ROUND(A.AMORTIZIMTOTAL,2),
                        KODOPER        = ''CR'',
                        DATEOPER       = dbo.DateValue('+@sDateOper+'),
                     -- PROMPTOPER     = dbo.Isd_AQOperDetailDisplay(''CR''),

                        NORMEAM        = R2.NORMEAM,
                        BC             = R1.BC,
                        NJESI          = R1.NJESI,
                        SASI           = 1,
                        NJESINV        = R1.NJESI,
                        KMON           = '''',
                        KURS1          = 1,
                        KURS2          = 1,
                        TIPKLL         = ''X'',
                        NRRENDKLLG     = R1.NRRENDOR
             
--                 INTO '+@sTableTmp+'
        
                   FROM #AQKartela A INNER JOIN AQKARTELA  R1 ON A.KARTLLG=R1.KOD
                                     LEFT  JOIN AQKATEGORI R2 ON R1.KATEGORI=R2.KOD
               ORDER BY A.KARTLLG;  ';
        
                   EXEC (@sSql);
        
        
                   IF   dbo.Isd_FieldTableExists('#AQSCR','PROMPTOPER')=1
                        EXEC ('UPDATE '+@sTableTmp+' SET PROMPTOPER=dbo.Isd_AQOperDetailDisplay(KODOPER);');
               -- EXEC ('SELECT * FROM '+@sTableTmp);
            
                   GOTO FUND;
            
             END;
    
          IF @sOper='GJENDOK'               -- Create nje dokument AQ me qellim CRegjistrimin
             BEGIN
             
                 INSERT  INTO AQ
                        (DATEDOK)
                 VALUES (@DateDok);

                    SET @NrRendor     = @@IDENTITY;

                 UPDATE AQ
                    SET NRDOK         = (SELECT ISNULL(MAX(NRDOK),0)+1 FROM AQ WHERE YEAR(@DateDok)=YEAR(DATEDOK)),
                        DATEDOK       = @DateDok,
                        DST           = 'CR',
                        NRFRAKS       = 0,
                        NRMAG         = 0,
                        KMAG          = '',
                        TIP           = 'X',
                        SHENIM1       = @pKoment,
                        SHENIM2       = '', --@Shenim2,
                        SHENIM3       = '',
                        SHENIM4       = '',
                        KMON          = '',
                        KURS1         = 1,
                        KURS2         = 1,
                        DOK_JB        = 0,
                        NRDFK         = 0,
                        USI           = @pUser,
                        USM           = @pUser
                  WHERE NRRENDOR      = @NrRendor;


                 INSERT INTO AQSCR
                       (NRD,KOD,KODAF,KARTLLG,PERSHKRIM,DATEOPER,KODOPER,VLERABS,VLERAAM,KOMENT,
                        BC,NORMEAM,SASI,CMIMBS,NJESI,NJESINV,KOEFSHB,KMON,KURS1,KURS2,TIPKLL,NRRENDKLLG)
                 SELECT @NrRendor,
                        KOD           = A.KOD,
                        KODAF         = dbo.Isd_SegmentsToKodAF(A.KOD),
                        A.KARTLLG,
                        PERSHKRIM     = R1.PERSHKRIM,
                        DATEOPER      = @DateDok,
                        KODOPER       = 'CR',
                        VLERABS       = ROUND(A.VLEREHISTORIKE,2),                                    
                        VLERAAM       = ROUND(A.AMORTIZIMTOTAL,2),
                        KOMENT        = @sKoment,

                        BC            = R1.BC,
                        NORMEAM       = R2.NORMEAM,
                        SASI          = 1,
                        CMIMBS        = A.VLEREMBETUR,
                        NJESI         = R1.NJESI,
                        NJESINV       = R1.NJESI,
                        KOEFSHB       = 1,
                        KMON          = '',
                        KURS1         = 1,
                        KURS2         = 1,
                        TIPKLL        = 'X',
                        NRRENDKLLG    = R1.NRRENDOR
             
                   FROM #AQKartela A INNER JOIN AQKARTELA  R1 ON A.KARTLLG=R1.KOD
                                     LEFT  JOIN AQKATEGORI R2 ON R1.KATEGORI=R2.KOD
    
                  WHERE A.VLEREMBETUR>0  -- ??
               ORDER BY A.KARTLLG;

           -- RAISERROR (N'C. ****     FUND Krijimi i dokumentit CR per cregjistrimin dhe kalimi i ketij ne databaze te Nd/jes     **** ', 0, 1) WITH NOWAIT; PRINT CHAR(13)+CHAR(13);
             
             END;
    
    
    
    FUND:
    
       IF OBJECT_ID('TEMPDB..#AQKartela')    IS NOT NULL
          DROP TABLE #AQKartela;
GO
