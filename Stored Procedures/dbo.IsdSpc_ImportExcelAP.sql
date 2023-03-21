SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- Exec dbo.IsdSpc_ImportExcelAP 'T1','T2',0,0,0
-- Exec dbo.IsdSpc_ImportExcelAP 'T1','T2',1,1,1

CREATE          procedure [dbo].[IsdSpc_ImportExcelAP]
(
 @pTable1    Varchar(30),
 @pTable2    Varchar(30),
 @pImportArt Bit,
 @pImportKl  Bit,
 @pTest      Int
)
AS

--   Vetetm per AP

--   Declare @pTable1    Varchar(30),
--           @pTable2    Varchar(30),
--           @pTest      Int;
--       Set @pTable1 = 'T1';
--       Set @pTable2 = 'T2';
--       Set @pTest   = 0;


-- Nga Exceli vijne dy tabela (dy TabSheet)

-- T1=@pTable1      Ka listen e Artikujve dhe kollona me emrin e ofertes

-- KOD,  PERSHKRIM,        OF001, OF002, OF003, OF004........ OF105
-- A001  Ferrote Mercedezi   100    120,    90,    98,           88
-- A002  Bielle motori      1000   1200,    90,    92,           78
-- A003  Xhunto Fiati         90     91,    87,    85,           82
-- A004  Aromatik             10     12,     9,     8,            7


-- T2=@pTable2      Ka listen e klienteve qe perfitojne ofertat

-- KOD      PERSHKRIM      OF001, OF002, OF003, OF004........ OF105
-- K00001	Klienti K001			+			  +		        +
-- K00002	Klienti K002	 +		+	   +		       	    +	
-- K00003	Klienti K003		    +			  +			   
-- K00004	Klienti K004	 +			   +			        +

-- Keto tabela konvertohen ne A_A_1001 dhe A_A_1002 (ne trajte UNPIVOT) dhe keto OSE tESTOHEN OSE kalojne ne Baze ...


         SET NOCOUNT ON;


     DECLARE @sFields1      Varchar(Max),
             @sFields2      Varchar(Max),
             @sSql          Varchar(Max),
             @sTable1       Varchar(30),
             @sTable2       Varchar(30),
             @ImportArt     Bit,
             @ImportKl      Bit,
             @Test          Int;
--           @TimeDi        Varchar(20),
--           @TimeEn        Varchar(20),
--           @TimeSt        DateTime,
--           @TimeSt0       DateTime,
--           @TimeSt1       Varchar(20)

         SET @sTable1     = @pTable1;
         SET @sTable2     = @pTable2;
         SET @ImportArt   = @pImportArt;
         SET @ImportKl    = @pImportKl;
         SET @Test        = @pTest;

         SET @sFields1    = '';
         SET @sFields2    = '';
         SET @sSql        = '';

--       Set @TimeSt0     = GetDate();
--       Set @TimeSt      = @TimeSt0;
--       Set @TimeDi      = Convert(Varchar(10),@TimeSt,108)
--       Set @TimeSt1     = CONVERT(Varchar(10),@TimeSt,108);

         IF  OBJECT_ID(@sTable1)     IS NULL
             BEGIN
               RaisError('Gabim:  Nuk ka tabele per Liste Artikuj cmime [%s] ..!', 0, 1,@sTable1) With NoWait;
               RETURN;
             END;

         IF  OBJECT_ID(@sTable2)     IS NULL
             BEGIN
               RaisError ('Gabim:  Nuk ka tabele per Liste Klient [%s] ..!', 0, 1,@sTable2) With NoWait
               RETURN;
             END;
     
         IF  OBJECT_ID('A_A_1001')   IS NOT NULL
             BEGIN
               DROP TABLE A_A_1001
             END;
         IF  OBJECT_ID('A_A_1002')   IS NOT NULL
             BEGIN
               DROP TABLE A_A_1002
             END;


/*         IF  OBJECT_ID('A_A_1001_O') IS NOT NULL  -- vetem Kode oferta per Artikuj (pas modifikimit 25.10.2016 nuk duhet)
             BEGIN
               DROP TABLE A_A_1001_O
             END;
         IF  OBJECT_ID('A_A_1002_O') IS NOT NULL  -- vetem Kode oferta per Klient (pas modifikimit 25.10.2016 nuk duhet)
             BEGIN
               DROP TABLE A_A_1002_O
             END;
*/             


-- Ndertimi i tabelave per Artikujt (A_A_1001), dhe Klientet (A_A_1002)

      SELECT @sFields1 = @sFields1 + ';
      SELECT A.KOD,OFERTE='''+[NAME]+''',CMIM=A.'+[NAME]+'
        FROM '+@sTable1+' A'
        FROM Sys.Columns
       WHERE OBJECT_ID=OBJECT_ID(@sTable1) AND (NOT [NAME] IN ('KOD','PERSHKRIM'))


      SELECT @sFields2 = @sFields2 + ';
      SELECT A.KOD,OFERTE='''+[NAME]+'''--,AKTIV=A.'+[NAME]+'
        FROM '+@sTable2+' A
       WHERE '+[NAME]+'=''+'' '
        FROM Sys.Columns
       WHERE OBJECT_ID=OBJECT_ID(@sTable2) AND (NOT [NAME] IN ('KOD','PERSHKRIM'))


         IF  (@ImportArt=0 AND @ImportKL=0) OR (@sFields1='' AND @sFields2='')
             BEGIN
               RaisError ('Gabim:  Nuk ka te dhena per modifikim cmime oferte ..!', 0, 1) With NoWait
               SELECT MSGERROR='', NRERROR=0 WHERE 1=2;
               RETURN;
             END;


         IF  @sFields1<>''
             BEGIN

               SET @sFields1 = SUBSTRING(@sFields1,2,LEN(@sFields1));
               SET @sFields1 = REPLACE(@sFields1,';','
  UNION ALL');

               SET @sFields1 = '

     SELECT A.*, NRD=B.NRRENDOR
       INTO A_A_1001
       FROM 
  ( '+@sFields1+'

       )  A INNER JOIN KlientCmim B ON A.OFERTE=B.KOD

   ORDER BY A.KOD,B.NRRENDOR;';

             END;

         IF  @sFields2<>''
             BEGIN

               SET @sFields2 = SUBSTRING(@sFields2,2,LEN(@sFields2));
               SET @sFields2 = REPLACE(@sFields2,';','
  UNION ALL');

               SET @sFields2 = '

     SELECT A.*, NRD=B.NRRENDOR
       INTO A_A_1002
       FROM 
  ( '+@sFields2+'

       )  A INNER JOIN KlientCmim B  ON A.OFERTE=B.KOD

   ORDER BY A.KOD,B.NRRENDOR;';

             END;


         IF  @sFields1<>'' AND @ImportArt=1 
             BEGIN
               EXEC  (@sFields1);
             END;
             
         IF  @sFields2<>'' AND @ImportKl=1
             BEGIN
               EXEC  (@sFields2);
             END;
           
         IF  @sFields1='' OR @ImportArt=0 
             BEGIN
               SELECT KOD=SPACE(60),OFERTE=SPACE(60),NRD=0,CMIM=0.00 
                 INTO A_A_1001 
                WHERE 1=2;
             END

         IF  @sFields2='' OR @ImportKl=0
             BEGIN
               SELECT KOD=SPACE(60),OFERTE=SPACE(60),NRD=0 
                 INTO A_A_1002 
                WHERE 1=2;
             END




-- 1.	   Procedure TEST

       IF  @Test=1
       
           BEGIN

                SELECT DISTINCT MSGERROR='Oferte gabim:  '    +ISNULL(OFERTE,''),NRERROR=1
                  FROM A_A_1001 A
                 WHERE NOT EXISTS (SELECT * FROM KlientCmim B WHERE A.OFERTE=B.KOD)
                 
             UNION ALL
             
                SELECT DISTINCT MSGERROR='Artikull panjohur:  '+ISNULL(A.KOD,''),NRERROR=2
                  FROM A_A_1001 A
                 WHERE @ImportArt=1 AND (NOT EXISTS (SELECT * FROM ARTIKUJ B WHERE A.KOD=B.KOD))
                 
             UNION ALL
             
                SELECT DISTINCT MSGERROR='Klient panjohur:  '  +ISNULL(A.KOD,''),NRERROR=3
                  FROM A_A_1002 A
                 WHERE @ImportKl=1 AND (NOT EXISTS (SELECT * FROM KLIENT B WHERE A.KOD=B.KOD))
                 
             UNION ALL 
             
                SELECT DISTINCT MSGERROR='Cmim gabim:  '+CAST(A.CMIM AS VARCHAR)+'   [Oferte,Art]=('+ISNULL(A.OFERTE,'')+','+ISNULL(A.KOD,'')+')',NRERROR=4
                  FROM A_A_1001 A
                 WHERE @ImportArt=1 AND (CAST(A.CMIM AS FLOAT)<=0)
                 
              ORDER BY NRERROR,MSGERROR


             RETURN;


           END;




-- Fund Procedure TEST 



-- * * * * * * * * * * * * * * * * * * * * * * * --
-- 2.	Procedura      IMPORTI      ne te dhenat e Ndermarrjes


-- 2.1	 Fshihen te vjetrat ne dbFin   ....


-- u futen variablat @FldsOfertArt dhe @FldsOfertKl perdoren per fshirje te shpejte .....

     DECLARE @FldsOfertArt VARCHAR(Max),
             @FldsOfertKl  VARCHAR(Max);
            
         SET @FldsOfertArt = ''
         SET @FldsOfertKl  = '';
         
      SELECT @FldsOfertArt=@FldsOfertArt+','+[Name]
        FROM SYS.COLUMNS
       WHERE Object_Id=Object_Id('T1') And (Not ([Name]) in ('KOD','PERSHKRIM'));
    
      SELECT @FldsOfertKl=@FldsOfertKl+','+[Name]
        FROM SYS.COLUMNS
       WHERE Object_Id=Object_Id('T2') And (Not ([Name]) in ('KOD','PERSHKRIM'));
    
          IF SUBSTRING(@FldsOfertArt,1,1)=','
             SET @FldsOfertArt = SUBSTRING(@FldsOfertArt,2,LEN(@FldsOfertArt));
          IF SUBSTRING(@FldsOfertKl,1,1)=','
             SET @FldsOfertKl  = SUBSTRING(@FldsOfertKl, 2,LEN(@FldsOfertKl));
        




      IF @ImportArt=1
      
         BEGIN

-- e re : dt 25.10.2016     Modifikohen vetem ato te ofertes te tjerat jo .......(Kerkese AP) dt 25.10.2016

         DELETE D               -- SELECT D.*,A.KOD
           FROM KlientCmim  A INNER JOIN KlientCmimArt B  ON A.NRRENDOR=B.NRD 
                              INNER JOIN T1               ON B.KOD=T1.KOD 
                              INNER JOIN KlientCmimCm  D  ON B.NRRENDOR=D.NRD 
          WHERE CharIndex(','+A.KOD+',',','+@FldsOfertArt+',')>0
         SELECT TOP 10 * FROM KlientCmimCm;

         DELETE B               -- SELECT B.*
           FROM KlientCmim  A INNER JOIN KlientCmimArt B ON A.NRRENDOR=B.NRD 
                              INNER JOIN T1              ON B.KOD=T1.KOD 
          WHERE CharIndex(','+A.KOD+',',','+@FldsOfertArt+',')>0
         SELECT TOP 10 * FROM KlientCmimArt;

           
         --DELETE D               --         SELECT D.*
         --  FROM KlientCmim  A INNER JOIN A_A_1001      C ON A.KOD=C.OFERTE
         --                     INNER JOIN KlientCmimArt B ON A.NRRENDOR=B.NRD AND C.KOD=B.KOD
         --                     INNER JOIN KlientCmimCm  D ON B.NRRENDOR=D.NRD --ORDER BY KOD;
         --SELECT TOP 10 * FROM KlientCmimCm;

         --DELETE B               --         SELECT B.*
         --  FROM KlientCmim  A INNER JOIN A_A_1001      C ON A.KOD=C.OFERTE
         --                     INNER JOIN KlientCmimArt B ON A.NRRENDOR=B.NRD AND C.KOD=B.KOD --ORDER BY KOD;
         --SELECT TOP 10 * FROM KlientCmimArt;
           
-- fund e re : dt 25.10.2016


-- ishte para se te korigjohej deri 25.10.2016

        --   SELECT OFERTE 
        --     INTO A_A_1001_O 
        --     FROM A_A_1001 
        -- GROUP BY OFERTE 
        -- ORDER BY OFERTE;

        ---- SELECT B.* 
        --   DELETE B
        --     FROM KlientCmim   A INNER JOIN A_A_1001_O    C ON A.KOD=C.OFERTE
        --                         INNER JOIN KlientCmimArt B ON A.NRRENDOR=B.NRD;
        --   SELECT TOP 10 * FROM KlientCmimArt;

        ---- SELECT D.*
        --   DELETE D
        --     FROM KlientCmim   A INNER JOIN A_A_1001_O    C ON A.KOD=C.OFERTE
        --                         INNER JOIN KlientCmimArt B ON A.NRRENDOR=B.NRD
        --                         INNER JOIN KlientCmimCm  D ON B.NRRENDOR=D.NRD;
        --   SELECT TOP 10 * FROM KlientCmimCm;
        
-- fund ishte
           
         END;               



      IF @ImportKl=1
         BEGIN
         
-- e re : dt 25.10.2016     Modifikohen vetem ato te ofertes te tjerat jo .......(Kerkese AP) dt 25.10.2016
           DELETE B
             FROM KlientCmim   A INNER JOIN KlientCmimKL  B ON A.NRRENDOR=B.NRD
                                 INNER JOIN T2              ON B.KOD=T2.KOD 
            WHERE CharIndex(','+A.KOD+',',','+@FldsOfertKl+',')>0;
           SELECT TOP 10 * FROM KlientCmimKL;
         --  DELETE B
         --    FROM KlientCmim   A INNER JOIN A_A_1002      C ON A.KOD=C.OFERTE
         --                        INNER JOIN KlientCmimKL  B ON A.NRRENDOR=B.NRD AND C.KOD=B.KOD;
         --SELECT TOP 10 * FROM KlientCmimKL;
-- fund e re : dt 25.10.2016


-- ishte para se te korigjohej deri 25.10.2016

        --   SELECT OFERTE 
        --     INTO A_A_1002_O 
        --     FROM A_A_1002 
        -- GROUP BY OFERTE 
        -- ORDER BY OFERTE;

        ---- SELECT B.* 
        --   DELETE B
        --     FROM KlientCmim   A INNER JOIN A_A_1002_O    C ON A.KOD=C.OFERTE
        --                         INNER JOIN KlientCmimKL  B ON A.NRRENDOR=B.NRD;

        --   SELECT TOP 10 * FROM KlientCmimKL;
        
-- fund ishte
        
         END;



-- 2.2	 Kalim ne baze te ofertave te reja .....


      IF @ImportArt=1
         BEGIN
         
--           Set       @TimeSt = Getdate();
--           Set       @TimeDi = Convert(Varchar(10),Getdate(),108);
--           RaisError ('
--           Fillim Insertim oferta, tabela %s.  Fillimi %s.', 0, 1,'KlientCmimArt', @TimeDi) With NoWait

             INSERT INTO KlientCmimArt
                   (KOD,NRD,PERSHKRIM,NJESI,KLASIF,KLASIF2,KLASIF3,KLASIF4,
                    CMSH,  CMSH1,  CMSH2,  CMSH3, CMSH4, CMSH5, CMSH6, CMSH7, CMSH8, CMSH9,
                    CMSH10,CMSH11, CMSH12, CMSH13,CMSH14,CMSH15,CMSH16,CMSH17,CMSH18,CMSH19)
             SELECT A.KOD,A.NRD,B.PERSHKRIM,B.NJESI,B.KLASIF,B.KLASIF2,B.KLASIF3,B.KLASIF4,
                    B.CMSH,  B.CMSH1,  B.CMSH2,  B.CMSH3, B.CMSH4, B.CMSH5, B.CMSH6, B.CMSH7, B.CMSH8, B.CMSH9,
                    B.CMSH10,B.CMSH11, B.CMSH12, B.CMSH13,B.CMSH14,B.CMSH15,B.CMSH16,B.CMSH17,B.CMSH18,B.CMSH19
               FROM A_A_1001 A INNER JOIN ARTIKUJ B ON A.KOD=B.KOD
           ORDER BY A.NRD,A.KOD;

             SELECT TOP 10 * FROM KlientCmimArt;

--              Set @TimeDi = Convert(Varchar(10),DateAdd(Second,DATEDIFF(Second,@TimeSt,GetDate()),'2001-01-01 00:00:00'),108)
--           RaisError ('
--           Fund   Insertim oferta, tabela %s.  Koha %s.', 0, 1,'KlientCmimArt',@TimeDi) With NoWait

--           Set       @TimeSt = Getdate();
--           Set       @TimeDi = Convert(Varchar(10),Getdate(),108);
--           RaisError ('
--           Fillim Insertim oferta, tabela %s.  Fillimi %s.  ', 0, 1,'KlientCmimCM',@TimeDi) With NoWait

             INSERT INTO KlientCmimCm
                   (KOD,NRD,SASI,CMIM)
             SELECT A.KOD,A.NRRENDOR,SASI=0,B.CMIM
               FROM KlientCmimArt A INNER JOIN A_A_1001 B ON A.NRD=B.NRD AND A.KOD=B.KOD
           ORDER BY A.NRRENDOR,A.KOD,B.CMIM DESC;

             SELECT TOP 10 * FROM KlientCmimCm;

--              Set @TimeDi = Convert(Varchar(10),DateAdd(Second,DATEDIFF(Second,@TimeSt,GetDate()),'2001-01-01 00:00:00'),108)
--           RaisError ('
--           Fund   Insertim oferta, tabela %s.  Koha %s.', 0, 1,'KlientCmimCM',@TimeDi) With NoWait
         END;
 

      IF @ImportKl=1
         BEGIN
        
--           Set       @TimeSt = Getdate();
--           Set       @TimeDi = Convert(Varchar(10),Getdate(),108);
--           RaisError ('
--           Fillim Insertim oferta, tabela %s.  Fillimi %s.', 0, 1,'KlientCmimKL',@TimeDi) With NoWait
             
             INSERT INTO KlientCmimKL
                   (KOD,NRD,PERSHKRIM,NIPT,PERFAQESUES,ADRESA1,ADRESA2,
                    KLASIFIKIM1,KLASIFIKIM2,KLASIFIKIM3,GRUP,KATEGORI,VENDNDODHJE,RAJON,AGJENTSHITJE)
             SELECT A.KOD,A.NRD,B.PERSHKRIM,B.NIPT,B.PERFAQESUES,B.ADRESA1,B.ADRESA2,
                    B.KLASIFIKIM1,B.KLASIFIKIM2,B.KLASIFIKIM3,B.GRUP,B.KATEGORI,B.VENDNDODHJE,B.RAJON,B.AGJENTSHITJE
               FROM A_A_1002 A INNER JOIN KLIENT B ON A.KOD=B.KOD
           ORDER BY A.NRD,A.KOD;

             SELECT TOP 10 * FROM KlientCmimKL;

--              Set @TimeDi = Convert(Varchar(10),DateAdd(Second,DATEDIFF(Second,@TimeSt,GetDate()),'2001-01-01 00:00:00'),108)
--           RaisError ('
--           Fund   Insertim oferta, tabela %s.  Koha %s.', 0, 1,'KlientCmimKL') With NoWait
         END;

         
-- Fund IMPORTI ne te dhenat e Ndermarrjes         

-- * * * * * * * * * * * * * * * * * * * * * * * --



-- 3.  Fshirje te tabelave Temporare

         IF  OBJECT_ID('A_A_1001')   IS NOT NULL
             BEGIN
               DROP TABLE A_A_1001
             END;
         IF  OBJECT_ID('A_A_1002')   IS NOT NULL
             BEGIN
               DROP TABLE A_A_1002
             END;
/*       IF  OBJECT_ID('A_A_1001_O') IS NOT NULL  -- (pas modifikimit 25.10.2016 nuk duhet)
             BEGIN
               DROP TABLE A_A_1001_O
             END;
         IF  OBJECT_ID('A_A_1002_O') IS NOT NULL  -- (pas modifikimit 25.10.2016 nuk duhet)
             BEGIN
               DROP TABLE A_A_1002_O
             END;
*/

--    Set @TimeEn = Convert(Varchar(10),Getdate(),108)
--    Set @TimeDi = Convert(Varchar(10),DateAdd(Second,DATEDIFF(Second,@TimeSt0,GetDate()),'2001-01-01 00:00:00'),108)
--    RaisError (N'
-- Fund insertim oferta.  Fillimi %s.  Fundi %s.  Koha %s.
--_______________________________________________________________________________', 0, 1,@TimeSt1,@TimeEn,@TimeDi) With NoWait


GO
