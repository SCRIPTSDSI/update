SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   procedure [dbo].[Isd_ArtikujKtgAgjKlPvt]
 (
   @pKMag       Varchar(30),         -- Nuk duhet 
   @pTableTmp   Varchar(30),
   @pNrRendor   Int,                 
   @pTipKll     Varchar(10),
   @pSMFK       Varchar(10),
   @pGjendje    Bit                  -- Nuk duhet
 )
As

         SET NOCOUNT ON

     DECLARE @TableTmp            Varchar(30),
             @NrRendor            Int,
             @TipKll              Varchar(10),
             @SMFKProces          Varchar(10),
             @TableRefRow         Varchar(50),
             @TableData           Varchar(50),
             @AgjKl               Varchar(5),
             @ListKode            Varchar(MAX),
             @Sql                nVarchar(MAX);

         SET @TableTmp          = @pTableTmp;
         SET @NrRendor          = @pNrRendor;
         SET @TipKll            = @pTipKll;
         SET @SMFKProces        = @pSMFK;
      -- SET @KMag              = QUOTENAME(@pKMag,'''');   
         SET @ListKode          = '';

         SET @AgjKl             = 'AGJ';
         SET @TableRefRow       = 'AGJENTSHITJE';
         SET @TableData         = 'ARTIKUJKTGAGJ';
         IF  CHARINDEX('_AGJ',@TableTmp)=0
             BEGIN
               SET @AgjKl       = 'KLI';
               SET @TableRefRow = 'KLIENT';
               SET @TableData   = 'ARTIKUJKTGKL';
             END  

          IF ISNULL(@TableTmp,'')=''
             SET @TableTmp    = '##KTG'+@TableRefRow+'01'+@TipKll;



-- FILLIM:    AFISHIM,KONSULTIM            ....    PIVOTIMI


   IF @SMFKProces='K'        -- Konsultim
      BEGIN

     DECLARE @ListRef1          Varchar(MAX),
             @ListRef2          Varchar(MAX),
             @ListRef3          Varchar(MAX);
         --  @sWhere            Varchar(Max);

         SET @ListRef1        = '';
         SET @ListRef2        = '';
         SET @ListRef3        = '';

          IF @AgjKl='AGJ' 
             BEGIN
                 SELECT @ListRef1        = @ListRef1  + ',''' + A.KODAF + '''',
                        @ListRef2        = @ListRef2  + ',['  + A.KODAF + ']',
                        @ListRef3        = @ListRef3  + ',['  + A.KODAF + ']=ISNULL(['+A.KODAF+'],0)'
                   FROM ArtikujKtgAGJScr A --LEFT  JOIN DRHReference B ON A.KOD = B.KOD AND B.REFERENCE=@TableRefRow AND B.KODUS=@User
                  WHERE NRD=@NrRendor AND TIPKLL=@TipKll AND ISNULL(A.KODAF,'')<>''
               GROUP BY A.KODAF
               ORDER BY A.KODAF;
             END;

          IF @AgjKl='KLI' 
             BEGIN
                 SELECT @ListRef1        = @ListRef1  + ',''' + A.KODAF + '''',
                        @ListRef2        = @ListRef2  + ',['  + A.KODAF + ']',
                        @ListRef3        = @ListRef3  + ',['  + A.KODAF + ']=ISNULL(['+A.KODAF+'],0)'
                   FROM ArtikujKtgKLScr A --LEFT  JOIN DRHReference B ON A.KOD = B.KOD AND B.REFERENCE=@TableRefRow AND B.KODUS=@User
                  WHERE NRD=@NrRendor AND TIPKLL=@TipKll AND ISNULL(A.KODAF,'')<>''
               GROUP BY A.KODAF
               ORDER BY A.KODAF;
             END;



         SET @ListRef1        = ISNULL(@ListRef1,'');
         SET @ListRef2        = ISNULL(@ListRef2,'');
         SET @ListRef3        = ISNULL(@ListRef3,'');
         
          IF ISNULL(@ListRef1,'')<>''
             BEGIN
               SET @ListRef1  =  '('+SUBSTRING(@ListRef1, 2,Len(@ListRef1))+')';
               SET @ListRef2  =  '('+SUBSTRING(@ListRef2, 2,Len(@ListRef2))+')';
               SET @ListRef3  =      SUBSTRING(@ListRef3, 2,Len(@ListRef3));
             END;

          IF @ListRef1=''
             SET @ListRef1    = '('''')';
          IF @ListRef2=''
             SET @ListRef2    = '('''')';

              
          IF OBJECT_ID('TempDB..'+@TableTmp) IS NOT NULL
             EXEC ('DROP TABLE '+@TableTmp);
               

          IF @ListRef3<>''
             BEGIN
               SET @ListRef3  = ','+@ListRef3;
             END;
             


-- Rasti A.  Kur ska kolona (pivoti ska kuptim)

         IF  @ListRef3=''
             BEGIN
             
               SET @Sql = N'
               
                       SELECT B.NRD, B.KOD
                         INTO #TMP1
                         FROM '+@TableData+' A INNER JOIN '+@TableData+'Scr B ON A.NRRENDOR = B.NRD
                        WHERE NRD='+CAST(@NrRendor AS VARCHAR)+' AND B.TIPKLL='''+@TipKll+''' 
                     ORDER BY B.KOD; ';
       
             END;
             
             
             
-- Rasti B.  Me kolona (pivoti punon ok)
             
         IF  @ListRef3<>''
             BEGIN
               SET @Sql = N'

                      SELECT KOD, NRD '+@ListRef3 + '
                        INTO #TMP1
                        FROM

                            ( SELECT B.NRD, B.KOD, B.KODAF, GJENDJE  = ROUND(B.VLEFTE,2)
                                FROM '+@TableData+' A INNER JOIN '+@TableData+'Scr B ON A.NRRENDOR = B.NRD
                               WHERE NRD='+CAST(@NrRendor AS VARCHAR)+' AND B.TIPKLL='''+@TipKll+''' AND B.KODAF IN '+@ListRef1+'
                             ) A

                             PIVOT

                           ( SUM(GJENDJE) FOR KODAF IN '+@ListRef2+') AS Pv2; ';
       
             END;
       
       
       
         SET @Sql = @Sql + N'
            
                      SELECT R.PERSHKRIM, 
                             NJESI         = '''',
                             A.*,
                             ORDERSCR      = 0,
                             TIPKLL        = ''K'',
                             TROW          = CAST(0 AS BIT),
                             TAGNR         = 0,
                             NRRENDOR      = 1
                        INTO '+@TableTmp+'
                        FROM #TMP1 A LEFT  JOIN '+@TableRefRow+' R ON A.KOD=R.KOD
                    ORDER BY A.KOD; 

                        EXEC dbo.Isd_UpDateInicValues '''+@TableTmp+''',''N'','''',1;
                        EXEC dbo.Isd_UpdateColumnsNulls '+@TableTmp+','''',''''; 

                   -- UPDATE A 
                   --    SET ORDERSCR=B.ORDERSCR 
                   --   FROM '+@TableTmp+' A INNER JOIN OrderItemsSortScr B On A.KOD=B.KOD; 


                        USE TEMPDB;  
                       EXEC ['+DB_NAME()+']..Isd_UpdateColumnsDefault '''+@TableTmp+''',''NC'','''';  


                     SELECT * 
                       FROM '+@TableTmp+' 
                   ORDER BY KOD; ';

        EXEC (@Sql);

      RETURN; 

    END;


-- FUND:      AFISHIM,KONSULTIM            ....    PIVOTIMI




-- FILLIM:    REGJISTRIMI,FUTJA NE BAZE    ....    UNPIVOTIMI

  IF @SMFKProces = 'S'
     BEGIN

        DECLARE @FieldsEx      Varchar(MAX),
                @Fields        Varchar(MAX);

            SET @FieldsEx = 'PERSHKRIM,KOD,NJESI,NRRENDOR,NRD,TROW,TAGNR,ORDERSCR,TIPKLL,USI,USM';

           EXEC dbo.Isd_spFieldsTable1  'TEMPDB', @TableTmp, @FieldsEx, '_KONV',@Fields OUTPUT;

            SET @Fields = ISNULL(@Fields,'');
            
            SET @Sql = N'
            
                      SELECT @ListKode = @ListKode + '','' + ISNULL(A.KOD,'''')
                        FROM ARTIKUJKTG A 
                       WHERE CHARINDEX('',''+A.KOD+'','', '',''+'+QUOTENAME(@Fields,'''')+'+'','')>0 
                    ORDER BY A.KOD;';

        EXECUTE SP_EXECUTESQL @Sql, N'@ListKode VARCHAR(MAX) OUT',@ListKode OUTPUT;                

             IF CHARINDEX(',',@ListKode)=1 
                SET @ListKode = STUFF(@ListKode,1,1,'');
             IF @ListKode<>''
                SET @ListKode ='(['+REPLACE(@ListKode,',','],[')+'])';
            
	       EXEC dbo.Isd_UpDateInicValues @TableTmp,'N','',1;



--              Rasti A.  Kur ska kolona (ska kuptim unpivot-i)

            IF  @ListKode=''
                BEGIN
                  SET @Sql =  N'
                  
                      DELETE 
                        FROM '+@TableData+'Scr
                       WHERE NRD='+CAST(@NrRendor As Varchar)+' AND TIPKLL='''+@TipKll+''';
          
                      INSERT INTO '+@TableData+'Scr
                            (NRD,KODAF,KOD,PERSHKRIM,NJESI,VLEFTE,TIPKLL,ORDERSCR)
                      SELECT NRD='+CAST(@NrRendor As Varchar)+','''',KOD,PERSHKRIM,NJESI,0,TIPKLL='''+@TipKll+''',0 
                        FROM '+@TableTmp+'
                    ORDER BY KOD;';
           
                END;


--              Rasti B.  Kur ka kolona (unpivoti ok)

            IF  @ListKode<>''
                BEGIN
                  SET @Sql = N'

                      DELETE 
                        FROM '+@TableData+'Scr
                       WHERE NRD='+CAST(@NrRendor As Varchar)+' AND TIPKLL='''+@TipKll+''';


                      INSERT INTO '+@TableData+'Scr
                            (NRD,KODAF,KOD,PERSHKRIM,NJESI,VLEFTE,TIPKLL,ORDERSCR)
                      SELECT '+CAST(@NrRendor AS VARCHAR)+',KODAF,KOD=unp.KOD,
                             R1.PERSHKRIM,NJESI='''',ISNULL(VLEFTE,0),TIPKLL='''+@TipKll+''',ORDERSCR
                        FROM 

                            ( SELECT * 
                                FROM '+@TableTmp+') P

                             UNPIVOT

                            ( VLEFTE FOR KODAF IN '+@ListKode+' 

                             ) AS UNP 
                             
                                      INNER JOIN '+@TableRefRow+' R1 On unp.KOD=R1.KOD

                    ORDER BY KODAF,KOD;';

                END;

           EXEC (@Sql);

         RETURN;

     END;

-- FUND:      REGJISTRIMI,FUTJA NE BAZE    ....    UNPIVOTIMI


GO
