SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   procedure [dbo].[Isd_OrderItemsDisplayPvt]
 (
   @PKMag       Varchar(30),
   @PTableTmp   Varchar(30),
   @PNrRendor   Int Output,          -- pse Output ????
   @PTipKll     Varchar(10),
   @PSMFK       Varchar(10),
   @PGjendje    Bit                  -- Te hiqet sepse nuk perdoret ne program
 )
As

            SET NOCOUNT ON

        DECLARE @TableTmp     Varchar(30),
                @NrRendor     Int,
                @TipKll       Varchar(10),
                @SMFKProces   Varchar(10),
                @KMag         Varchar(30);

            SET @TableTmp   = @PTableTmp;
            SET @NrRendor   = @PNrRendor;
            SET @TipKll     = @PTipKll;
            SET @SMFKProces = @PSMFK;
            SET @KMag       = QUOTENAME(@PKMag,'''');


             IF ISNULL(@TableTmp,'')=''
                SET @TableTmp = '##A01'+@TipKll;



-- FILLIM:    AFISHIM,KONSULTIM ....    PIVOTIMI




   IF @SMFKProces='K'        
      BEGIN

     DECLARE @ListRef1     Varchar(Max),
             @ListRef2     Varchar(Max),
             @ListRef3     Varchar(Max),
             @ListRef4     Varchar(Max),
             @ListRef5     Varchar(Max),

             @ListRef21    Varchar(Max),    -- per sasi konvertuar
             @ListRef22    Varchar(Max),    -- per sasi konvertuar
             @ListRef31    Varchar(Max),
             @ListRef41    Varchar(Max),    -- per sasi konvertuar
             
             @Sql          Varchar(Max),
             @PWhere       Varchar(Max);

     --  SET @TableRefM  = 'MAGAZINA'     
     --  SET @DbName     = DB_NAME();
         SET @PWhere     = '';
         SET @ListRef1   = '';
         SET @ListRef2   = '';
         SET @ListRef3   = '';
         SET @ListRef4   = '';
         SET @ListRef5   = '';

         SET @ListRef21  = '';
         SET @ListRef22  = '';
         SET @ListRef31  = '';
         SET @ListRef41  = '';
         
      SELECT @ListRef1   = @ListRef1  + ',''' + A.KODAF + '''',
             @ListRef2   = @ListRef2  + ',['  + A.KODAF + ']',
             @ListRef22  = @ListRef22 + ',A.['+ A.KODAF + '_KONV]=ISNULL(B.['+A.KODAF+'_KONV],0)',
             @ListRef3   = @ListRef3  + ',['  + A.KODAF + ']=ISNULL(['+A.KODAF+'],0)',
             @ListRef4   = @ListRef4  + '+['  + A.KODAF + ']',
             @ListRef5   = @ListRef5  + '+ CASE WHEN ISNULL(['+A.KODAF+'],0)<>0 THEN 1 ELSE 0 END '
        FROM OrderItemsScr A --LEFT  JOIN DRHReference B ON A.KOD = B.KOD AND B.REFERENCE=@TableRefM AND B.KODUS=@User
       WHERE NRD=@NrRendor AND TIPKLL=@TipKll
    GROUP BY A.KODAF
    ORDER BY A.KODAF;


         SET @ListRef1   = ISNULL(@ListRef1,'');
         SET @ListRef2   = ISNULL(@ListRef2,'');
         SET @ListRef3   = ISNULL(@ListRef3,'');
         SET @ListRef4   = ISNULL(@ListRef4,'');
         SET @ListRef5   = ISNULL(@ListRef5,'');
         SET @ListRef21  = REPLACE(ISNULL(@ListRef2,''),']','_KONV]=CAST(0.0 AS FLOAT)');
         SET @ListRef41  = REPLACE(@ListRef4,']','_KONV]')
         
          IF ISNULL(@ListRef1,'')<>''
             BEGIN
               SET @ListRef1  =                  '('+SUBSTRING(@ListRef1, 2,Len(@ListRef1))+')';
               SET @ListRef2  =                  '('+SUBSTRING(@ListRef2, 2,Len(@ListRef2))+')';
               SET @ListRef3  =                      SUBSTRING(@ListRef3, 2,Len(@ListRef3));
               SET @ListRef4  = 'TOTAL_SASI   = '   +SUBSTRING(@ListRef4, 2,Len(@ListRef4));
               SET @ListRef5  = 'NRORD_SASI   = '   +SUBSTRING(@ListRef5, 2,Len(@ListRef5));
               SET @ListRef41 = 'TOTAL_SASI_KONV = '+SUBSTRING(@ListRef41,2,Len(@ListRef41));
             END;

          IF @ListRef1=''
             SET @ListRef1  = '(''NRRENDOR'')';
          IF @ListRef2=''
             SET @ListRef2  = '(NRRENDOR)';
        --IF @ListRef3=''
        --   SET @ListRef3  = 'NRD_1=0';
          IF @ListRef4=''
             SET @ListRef4  = 'TOTAL_SASI=0';
          IF @ListRef5=''
             SET @ListRef5  = 'NRORD_SASI=0';
          IF @ListRef41=''   
             SET @ListRef41 = 'TOTAL_SASI_KONV=0';
             
          IF OBJECT_ID('TempDB..'+@TableTmp) IS NOT NULL
             EXEC ('DROP TABLE '+@TableTmp);
               
  --     SET @ColumnsList = Replace(Replace(Replace(Replace(@ListRef2,'(',''),')',''),'[',''),']','')

          IF @ListRef3<>''
             BEGIN
               SET @ListRef3  = ','+@ListRef3;
               SET @ListRef31 = REPLACE(@ListRef3,']=','_KONV]=');
             END;
             
          IF @ListRef22<>''
             BEGIN
               SET @ListRef22 = SUBSTRING(@ListRef22,2,LEN(@ListRef22));   
             END;


         SET @Sql = '

         SELECT KOD,NRD '+@ListRef3  +  @ListRef21+'
           INTO #TMP1
           FROM

       ( SELECT B.NRD,
                B.KOD,
                B.KODAF,
                GJENDJE = ROUND(B.SASI,2)
           FROM OrderItems A INNER JOIN OrderItemsScr B ON A.NRRENDOR = B.NRD
          WHERE NRD='+CAST(@NrRendor As Varchar)+' AND B.TIPKLL='''+@TipKll+''' AND B.KODAF IN '+@ListRef1+'
        ) A

          Pivot

       (SUM(GJENDJE) For KODAF IN '+@ListRef2+') As Pv2;
       


--      Sasi konvertuar Fillim    (Njesi konvertim) 

         SELECT KOD,NRD '+@ListRef31+'
           INTO #TMP1_KONV
           FROM

       ( SELECT B.NRD,
                B.KOD,
                B.KODAF,
                GJENDJE = ROUND(B.SASIKONV,2)
           FROM OrderItems A INNER JOIN OrderItemsScr B ON A.NRRENDOR = B.NRD
          WHERE NRD='+CAST(@NrRendor As Varchar)+' AND B.TIPKLL='''+@TipKll+''' AND B.KODAF IN '+@ListRef1+'
        ) A

          Pivot

       (SUM(GJENDJE) For KODAF IN '+@ListRef2+') As Pv2;
       
             IF '''+@ListRef22+'''<>''''
                BEGIN
                  UPDATE A
                     SET '+CASE WHEN @ListRef22<>'' THEN @ListRef22 ELSE 'A.KOD=A.KOD' END+'
                    FROM #TMP1 A INNER JOIN #TMP1_KONV B ON A.KOD=B.KOD
                END; 
        
--      Sasi konvertuar Fund



         SELECT R.PERSHKRIM, 
                R.NJESI,
                A.*,
                '+@ListRef4 +',
                '+@ListRef41+',
                Gjendje_Sasi = CAST(0 As Float),
                Difer_Sasi   = CAST(0 As Float),
                NrOrd_Sasi   = CAST(0 As Float),
                OrderScr     = 0,
                TIPKLL       = ''K'',
                TROW         = CAST(0 As Bit),
                TAGNR        = 0,
                NRRENDOR     = 1
           INTO '+@TableTmp+'
           FROM #TMP1 A LEFT  JOIN ARTIKUJ R ON A.KOD=R.KOD
       ORDER BY A.KOD; 

           EXEC dbo.Isd_UpDateInicValues '''+@TableTmp+''',''N'','''',1;
           EXEC dbo.Isd_UpdateColumnsNulls '+@TableTmp+','''',''''; 

         UPDATE A 
            SET ORDERSCR=B.ORDERSCR 
           FROM '+@TableTmp+' A INNER JOIN OrderItemsSortScr B On A.KOD=B.KOD; 


            USE TEMPDB;  
           EXEC ['+DB_NAME()+']..Isd_UpdateColumnsDefault '''+@TableTmp+''',''NC'','''';  

         UPDATE '+@TableTmp+'
            SET '+@ListRef5+';



         SELECT * 
           FROM '+@TableTmp+' 
       ORDER BY KOD; 
';
    PRINT  @Sql;
       EXEC (@Sql);

      RETURN; 

    END;

-- FUND:      AFISHIM,KONSULTIM ....    PIVOTIMI


-- FILLIM:    REGJISTRIMI,FUTJA NE BAZE .... UNPIVOTIMI

  IF @SMFKProces = 'S'
     BEGIN

        DECLARE @FieldsEx      Varchar(Max),
                @Fields        Varchar(Max),
                @ListKode      Varchar(Max),
                @ListKodeKonv  Varchar(Max);

            SET @ListKode = '';
            SET @FieldsEx = 'PERSHKRIM,KOD,NJESI,NRRENDOR,NRD,TROW,TAGNR,TOTAL_SASI,GJENDJE_SASI,DIFER_SASI,NRORD_SASI,ORDERSCR,TIPKLL,USI,USM';

           EXEC dbo.Isd_spFieldsTable1  'TEMPDB', @TableTmp, @FieldsEx, '_KONV',@Fields Output;


             IF @TipKll='M' -- Makina
                BEGIN
                    SELECT @ListKode = @ListKode + ',' + ISNULL(KOD,'')
                      FROM MAGAZINA
                     WHERE ISNULL(KOD,'')<>'' -- AND ISNULL(TIPI,0)=3
                  ORDER BY KOD;
                END;

             IF @TipKll='D' -- Dyqan
                BEGIN
                    SELECT @ListKode = @ListKode + ',' + ISNULL(KOD,'')
                      FROM MAGAZINA
                     WHERE ISNULL(KOD,'')<>'' -- AND ISNULL(TIPI,0)=2   -- AND KLSF='D' ?? 
                  ORDER BY KOD;
                END;

             IF @TipKll='K' -- Klient
                BEGIN
                    SELECT @ListKode = @ListKode + ',' + ISNULL(KOD,'')
                      FROM KLIENT
                     WHERE ISNULL(KOD,'')<>'' AND CHARINDEX(','+KOD+',' , ','+@Fields+',')>0 
                  ORDER BY KOD;
                END;

             IF CHARINDEX(',',@ListKode)=1 
                SET @ListKode = Stuff(@ListKode,1,1,'');

            SET @ListKode     = dbo.Isd_ListFields2Lists(@Fields,@ListKode,'');
            SET @ListKode     ='(['+Replace(@ListKode,',','],[')+'])';
            SET @ListKodeKonv = Replace(@ListKode,']','_KONV]');
            
	       EXEC dbo.Isd_UpDateInicValues @TableTmp,'N','',1;


		    SET @Sql = '

         DELETE 
           FROM OrderItemsScr
          WHERE NRD='+CAST(@NrRendor As Varchar)+' AND TIPKLL='''+@TipKll+''';



--      Sasi

         INSERT INTO OrderItemsScr
               (NRD,KODAF,KOD,PERSHKRIM,NJESI,SASI,TIPKLL,ORDERSCR)
         SELECT '+CAST(@NrRendor AS VARCHAR)+',KODAF,KOD=unp.KOD,
                R1.PERSHKRIM,R1.NJESI,ISNULL(SASI,0),TIPKLL='''+@TipKll+''',ORDERSCR
           FROM 

               ( SELECT * 
                   FROM '+@TableTmp+') p

                UnPivot

               ( SASI FOR KODAF IN '+@ListKode+' 

                ) AS unp 
                          INNER JOIN Artikuj R1 On unp.KOD=R1.KOD

       ORDER BY KODAF,KOD;

--      Sasi Fund

--      Sasi konvertuar Fillim

         SELECT NRD='+CAST(@NrRendor AS VARCHAR)+',KODAF,KOD=unp.KOD,
                SASIKONV = ISNULL(SASIKONV,0)
           INTO #TMP2Scr     
           FROM 

               ( SELECT * 
                   FROM '+@TableTmp+') p

                UnPivot

               ( SASIKONV FOR KODAF IN '+@ListKodeKonv+' 

                ) AS unp 
                          INNER JOIN Artikuj R1 On unp.KOD=R1.KOD

       ORDER BY KODAF,KOD;       
       
         UPDATE #TMP2Scr
            SET KODAF = REPLACE(KODAF,''_KONV'','''');
          
         UPDATE A
            SET A.SASIKONV = B.SASIKONV
           FROM OrderItemsScr A INNER JOIN #TMP2Scr B ON A.KOD=B.KOD AND A.KODAF=B.KODAF 
          WHERE A.NRD='+CAST(@NrRendor As Varchar)+' AND A.TIPKLL='''+@TipKll+'''; 

--      Sasi konvertuar Fund
';

       -- PRINT  @Sql;
           EXEC (@Sql);

         RETURN;

     END;

-- FUND:      REGJISTRIMI,FUTJA NE BAZE .... UNPIVOTIMI



-- FILLIM:    UPDATE GJENDJE NGA NJE MAGAZINE

  IF @SMFKProces = 'U'
     BEGIN

            SET @Sql = '

             IF OBJECT_ID(''TempDB..#GjendjeArt'') IS NOT NULL
                DROP TABLE #GjendjeArt;

         SELECT KOD,
                GJENDJE = ROUND(SUM(ISNULL(SASI,0)),6)
           INTO #GjendjeArt
           FROM

      (
         SELECT KOD = B.KARTLLG,  SASI = SUM(  B.SASI)
           FROM FH A INNER JOIN FHSCR B ON A.NRRENDOR=B.NRD
                     INNER JOIN '+@TableTmp+' T ON B.KARTLLG=T.KOD
          WHERE A.KMAG='''+@PKMag+'''
       GROUP BY B.KARTLLG
      UNION ALL
         SELECT KOD = B.KARTLLG,  SASI = SUM(0-B.SASI)
           FROM FD A INNER JOIN FDSCR B ON A.NRRENDOR=B.NRD
                     INNER JOIN '+@TableTmp+' T ON B.KARTLLG=T.KOD
          WHERE A.KMAG='''+@PKMag+'''
       GROUP BY B.KARTLLG
       ) A

       GROUP BY KOD
       ORDER BY KOD;


         UPDATE A
            SET A.GJENDJE_SASI = ROUND(ISNULL(B.GJENDJE,0),2),
                A.DIFER_SASI   = ROUND(ISNULL(TOTAL_SASI,0) - ISNULL(B.GJENDJE,0),2)
           FROM '+@TableTmp+' A LEFT JOIN #GjendjeArt B On A.KOD=B.KOD 

             IF OBJECT_ID(''TempDB..#GjendjeArt'') IS NOT NULL
                DROP TABLE #GjendjeArt; ';

       -- PRINT  @Sql;
           EXEC (@Sql);

         RETURN;

     END;

-- Fund:      UPDATE Gjendje nga nje magazine

-- Krijimi i dokumentave ne Baze  --  U gjeneruar procedura dbo.Isd_CreateMgFromPorosi

GO
