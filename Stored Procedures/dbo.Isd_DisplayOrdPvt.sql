SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   procedure [dbo].[Isd_DisplayOrdPvt]
 (
   @PKMag      Varchar(30),
   @PTableTmp  Varchar(30),
   @PNrRendor  Int Output,
   @PTipKll    Varchar(10),
   @PSMFK      Varchar(10),
   @PGjendje   Bit    -- Te hiqet sepse nuk perdoret ne program
 )
As

            Set NOCOUNT ON

        Declare @TableTmp     Varchar(30),
                @NrRendor     Int,
                @TipKll       Varchar(10),
                @KMag         Varchar(30);

            Set @TableTmp   = @PTableTmp;
            Set @NrRendor   = @PNrRendor;
            Set @TipKll     = @PTipKll
            Set @KMag       = QuoteName(@PKMag,'''');


             if IsNull(@TableTmp,'')=''
                Set @TableTmp = '##A01'+@TipKll;

-- Fillim:    Afishim,Konsultim ....    Pivotimi




   if @PSMFK='K'        
      begin

     Declare @ListRef1     Varchar(Max),
             @ListRef2     Varchar(Max),
             @ListRef3     Varchar(Max),
             @ListRef4     Varchar(Max),
             @ListRef5     Varchar(Max),
             @Sql          Varchar(Max),
             @PWhere       Varchar(Max);

     --  Set @TableRefM  = 'MAGAZINA'     
     --  Set @DbName     = DB_Name();
         Set @PWhere     = '';
         Set @ListRef1   = '';
         Set @ListRef2   = '';
         Set @ListRef3   = '';
         Set @ListRef4   = '';
         Set @ListRef5   = '';
         
      SELECT @ListRef1   = @ListRef1 + ',''' + A.KODAF + '''',
             @ListRef2   = @ListRef2 + ',['  + A.KODAF + ']',
             @ListRef3   = @ListRef3 + ',['  + A.KODAF + ']=ISNULL(['+A.KODAF+'],0)',
             @ListRef4   = @ListRef4 + '+['  + A.KODAF + ']',
             @ListRef5   = @ListRef5 + '+ CASE WHEN ISNULL(['+A.KODAF+'],0)<>0 THEN 1 ELSE 0 END '
        FROM ArtikujOrdScr A --LEFT  JOIN DRHReference B ON A.KOD = B.KOD AND B.REFERENCE=@TableRefM AND B.KODUS=@User
       WHERE NRD=@NrRendor AND TIPKLL=@TipKll
    GROUP BY A.KODAF
    ORDER BY A.KODAF;


         Set @ListRef1 = IsNull(@ListRef1,'');
         Set @ListRef2 = IsNull(@ListRef2,'');
         Set @ListRef3 = IsNull(@ListRef3,'');
         Set @ListRef4 = IsNull(@ListRef4,'');
         Set @ListRef5 = IsNull(@ListRef5,'');

          if IsNull(@ListRef1,'')<>''
             begin
               Set @ListRef1 =              '(' +Substring(@ListRef1,2,Len(@ListRef1))+')'
               Set @ListRef2 =              '(' +Substring(@ListRef2,2,Len(@ListRef2))+')'
               Set @ListRef3 =                   Substring(@ListRef3,2,Len(@ListRef3))
               Set @ListRef4 = 'TOTAL_SASI   = '+Substring(@ListRef4,2,Len(@ListRef4))
               Set @ListRef5 = 'NrOrd_Sasi   = '+Substring(@ListRef5,2,Len(@ListRef5))
             end;

          if @ListRef1=''
             Set @ListRef1 = '(''NRRENDOR'')';
          if @ListRef2=''
             Set @ListRef2 = '(NRRENDOR)';
        --if @ListRef3=''
        --   Set @ListRef3 = 'NRD_1=0';
          if @ListRef4=''
             Set @ListRef4 = 'TOTAL_SASI=0';
          if @ListRef5=''
             Set @ListRef5 = 'NrOrd_Sasi=0';

          if Object_Id('TempDB..'+@TableTmp) is not null
             Exec ('DROP TABLE '+@TableTmp);
               
  --     Set @ColumnsList = Replace(Replace(Replace(Replace(@ListRef2,'(',''),')',''),'[',''),']','')

          if @ListRef3<>''
             Set @ListRef3 = ','+@ListRef3;

         Set @Sql = '

         SELECT KOD,NRD '+@ListRef3+'
           INTO #TMP1
           FROM

       ( SELECT B.NRD,
                B.KOD,
                B.KODAF,
                GJENDJE = ROUND(B.SASI,2)
           FROM ARTIKUJORD A INNER JOIN ARTIKUJORDSCR B ON A.NRRENDOR = B.NRD
          WHERE NRD='+Cast(@NrRendor As Varchar)+' AND B.TIPKLL='''+@TipKll+''' AND B.KODAF IN '+@ListRef1+'
        ) A

          Pivot

       (SUM(GJENDJE) For KODAF IN '+@ListRef2+') As Pv2 

         SELECT R.PERSHKRIM, 
                R.NJESI,
                A.*,
                '+@ListRef4+',
                Gjendje_Sasi = Cast(0 As Float),
                Difer_Sasi   = Cast(0 As Float),
                NrOrd_Sasi   = Cast(0 As Float),
                OrderScr     = 0,
                TIPKLL       = ''K'',
                TROW         = Cast(0 As Bit),
                TAGNR        = 0,
                NRRENDOR     = 1
           INTO '+@TableTmp+'
           FROM #TMP1 A LEFT  JOIN ARTIKUJ R ON A.KOD=R.KOD
       ORDER BY A.KOD 

           Exec dbo.Isd_UpDateInicValues '''+@TableTmp+''',''N'','''',1;
           Exec dbo.Isd_UpdateColumnsNulls '+@TableTmp+','''',''''; 

            use TempDb;  
           Exec ['+Db_Name()+']..Isd_UpdateColumnsDefault '''+@TableTmp+''',''NC'','''';  

         UPDATE '+@TableTmp+'
            SET '+@ListRef5+'

         SELECT * 
           FROM '+@TableTmp+' 
       ORDER BY KOD 
';
      Print @Sql
       Exec (@Sql);

      Return; 

    end;

-- Fund:      Afishim,Konsultim ....    Pivotimi


-- Fillim:    Regjistrimi,futja ne Baze .... Unpivotimi

  if  @PSMFK = 'S'
      begin

        Declare @FieldsEx   Varchar(Max),
                @Fields     Varchar(Max),
                @ListKode   Varchar(Max);

            Set @ListKode = '';
            Set @FieldsEx = 'PERSHKRIM,KOD,NJESI,NRRENDOR,NRD,TROW,TAGNR,TOTAL_SASI,GJENDJE_SASI,DIFER_SASI,NRORD_SASI,USI,USM';

           Exec dbo.Isd_spFieldsTable  'TEMPDB', @TableTmp, @FieldsEx, @Fields Output;


   if @TipKll='M' -- Makina
      begin
         Select @ListKode = @ListKode + ',' + ISNULL(KOD,'')
           From MAGAZINA
          Where IsNull(KOD,'')<>''
       Order By KOD;
      end;

   if @TipKll='D' -- Dyqan
      begin
         Select @ListKode = @ListKode + ',' + ISNULL(KOD,'')
           From KLIENT
          Where IsNull(KOD,'')<>'' -- AND KLSF='D' ??
       Order By KOD;
      end;

   if @TipKll='K' -- Klient
      begin
         Select @ListKode = @ListKode + ',' + ISNULL(KOD,'')
           From KLIENT
          Where IsNull(KOD,'')<>'' -- AND KLSF='K' ??
       Order By KOD;
      end;

             if CharIndex(',',@ListKode)=1 
                Set @ListKode = Stuff(@ListKode,1,1,'');

            Set @ListKode = dbo.Isd_ListFields2Lists(@Fields,@ListKode,'');
            Set @ListKode ='(['+Replace(@ListKode,',','],[')+'])';

	       Exec dbo.Isd_UpDateInicValues @TableTmp,'N','',1;

		    Set @Sql = '

         DELETE 
           FROM ARTIKUJORDSCR
          WHERE NRD='+Cast(@NrRendor As Varchar)+' AND TIPKLL='''+@TipKll+'''

         INSERT INTO ARTIKUJORDSCR
               (NRD,KODAF,KOD,PERSHKRIM,NJESI,SASI,TIPKLL,ORDERSCR)
         SELECT '+Cast(@NrRendor As Varchar)+',KODAF,KOD=unp.KOD,
                R1.PERSHKRIM,R1.NJESI,ISNULL(SASI,0),TIPKLL='''+@TipKll+''',ORDERSCR
           FROM 

               ( SELECT * 
                   FROM '+@TableTmp+') p

                UnPivot

               ( SASI FOR KODAF IN '+@ListKode+' 

                ) AS unp 
                          Inner Join Artikuj R1 On unp.KOD=R1.KOD

       ORDER BY KODAF,KOD ';

          Print  @Sql;
           Exec (@Sql);

         Return;

    end;

-- Fund:      Regjistrimi,futja ne Baze .... Unpivotimi



-- Fillim:    Update Gjendje nga nje magazine

  if  @PSMFK = 'U'
      begin

            Set @Sql = '

             if Object_Id(''TempDB..#GjendjeArt'') is not null
                DROP TABLE #GjendjeArt;

         SELECT KOD,
                GJENDJE = SUM(ISNULL(SASI,0))
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
            SET A.GJENDJE_SASI = IsNull(B.GJENDJE,0),
                A.DIFER_SASI   = IsNull(TOTAL_SASI,0) - IsNull(B.GJENDJE,0)
           FROM '+@TableTmp+' A LEFT JOIN #GjendjeArt B On A.KOD=B.KOD 

             if Object_Id(''TempDB..#GjendjeArt'') is not null
                DROP TABLE #GjendjeArt; ';
          Print  @Sql;
           Exec (@Sql);

         Return;

      end;

-- Fund:      Update Gjendje nga nje magazine

-- Krijimi i dokumentave ne Baze  --  U gjeneruar procedura dbo.Isd_CreateMgFromPorosi
GO
