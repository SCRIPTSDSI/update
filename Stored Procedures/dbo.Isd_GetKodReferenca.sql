SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--     Exec dbo.Isd_GetKodReferenca 'F1108','F1108','MG','',''

CREATE   Procedure [dbo].[Isd_GetKodReferenca]
( 
  @pKodKp        Varchar(60),  
  @pKodKs        Varchar(60),
  @pModul        Varchar(10),
  @pTableName    Varchar(50),
  @pUser         Varchar(50)  
 )
AS

-- 1. Percakton modulet(referencat) ku ndodhet ky kod

-- 2. Stringu qe jep keto module jepet ne radhen e percaktuar tek ConfigMg fusha PRIORITYKODSCRMG (edhe per LM ketu jepet fusha PRIORITYKODSCRLM)
--    por te aktivizohet me vone (shiko shenimet gjate procedures dhe sidomos ne fund)

-- 3. Interpretimi behet ne program sipas kesaj radhe nga kjo procedure (fusha MODULS)

         SET NOCOUNT ON


     DECLARE @sKodKp       Varchar(60),
             @sKodKs       Varchar(60),
             @sModul       Varchar(10),
             @sTableName   Varchar(50),
             @sUser        Varchar(50),
             @sPriority    Varchar(20);

         SET @sKodKp     = @pKodKp;      
         SET @sKodKs     = @pKodKs;      
         SET @sModul     = @pModul;
         SET @sTableName = @pTableName;  -- Mund te interpretohet dhe sipas Tabeles ...!
         SET @sUser      = @pUser;       -- Lidhi me user ....




          IF @sModul='MG'

             BEGIN
                SET @sPriority = 'KLRSFX'
             -- SET @sPriority = (SELECT ISNULL(PRIORITYKODSCRMG,'') FROM CONFIGMG)        
             END

          ELSE

             BEGIN
                SET @sPriority = 'LSFAB'
             -- SET @sPriority = (SELECT ISNULL(PRIORITYKODSCRLM,'') FROM CONFIGMG);
             END;



      -- Variabli @sPriority percakton Orderin e Moduleve per te cilat do te pyese programi
      --  funksioni Isd_TestPriorityKod: Heq te tepert fut ato qe mungojne 

      -- SET @sPriority = dbo.Isd_TestPriorityKod(@sPriority,@sModul);   
      -- Aktivizimi me vone, pasi te aktivizohet Test prioriteti (shiko komente me poshte )



          IF OBJECT_ID('TEMPDB..#KODREFLM') IS NOT NULL
             DROP TABLE #KODREFLM;
          IF OBJECT_ID('TEMPDB..#KODREFMG') IS NOT NULL
             DROP TABLE #KODREFMG;


          IF @sModul='LM'
             BEGIN

                  SELECT KOD,TIPA
                    INTO #KODREFLM
                    FROM 
                 (
                  SELECT KOD,TIPA='L' FROM LLOGARI  WHERE KOD>=@sKodKp AND KOD<=@sKodKs AND ISNULL(POZIC,0)=1
               UNION ALL 
                  SELECT KOD,TIPA='A' FROM ARKAT    WHERE KOD>=@sKodKp AND KOD<=@sKodKs
               UNION ALL 
                  SELECT KOD,TIPA='B' FROM BANKAT   WHERE KOD>=@sKodKp AND KOD<=@sKodKs
               UNION ALL 
                  SELECT KOD,TIPA='S' FROM KLIENT   WHERE KOD>=@sKodKp AND KOD<=@sKodKs
               UNION ALL 
                  SELECT KOD,TIPA='F' FROM FURNITOR WHERE KOD>=@sKodKp AND KOD<=@sKodKs
                  ) A

                ORDER BY KOD,TIPA


                  SELECT A.KOD, 
                         MODULS = STUFF( ( SELECT '' + B.TIPA FROM #KODREFLM B WHERE B.KOD = A.KOD ORDER BY CHARINDEX(TIPA,@sPriority) FOR XML PATH('') ), 1, 0, '') 
                    FROM #KODREFLM AS A
                GROUP BY A.KOD;

             END;

          IF @sModul='MG'
             BEGIN

                  SELECT KOD,TIPA
                    INTO #KODREFMG
                    FROM 
                 (
                  SELECT KOD,TIPA='K' FROM ARTIKUJ   WHERE KOD>=@sKodKp AND KOD<=@sKodKs
               UNION ALL 
                  SELECT KOD,TIPA='L' FROM LLOGARI   WHERE KOD>=@sKodKp AND KOD<=@sKodKs AND ISNULL(POZIC,0)=1
               UNION ALL 
                  SELECT KOD,TIPA='R' FROM SHERBIM   WHERE KOD>=@sKodKp AND KOD<=@sKodKs
               UNION ALL 
                  SELECT KOD,TIPA='S' FROM KLIENT    WHERE KOD>=@sKodKp AND KOD<=@sKodKs
               UNION ALL 
                  SELECT KOD,TIPA='F' FROM FURNITOR  WHERE KOD>=@sKodKp AND KOD<=@sKodKs
               UNION ALL 
                  SELECT KOD,TIPA='X' FROM AQKARTELA WHERE KOD>=@sKodKp AND KOD<=@sKodKs
                  ) A

                ORDER BY KOD,TIPA


                  SELECT A.KOD, 
                         MODULS = STUFF( ( SELECT '' + B.TIPA FROM #KODREFMG B WHERE B.KOD = A.KOD ORDER BY CHARINDEX(TIPA,@sPriority) FOR XML PATH('') ), 1, 0, '') 
                    FROM #KODREFMG AS A
                GROUP BY A.KOD;

             END


/*
      SELECT A.KOD, 
             MODULS = STUFF( ( SELECT '' + B.TIPA FROM #KODREF B WHERE B.KOD = A.KOD ORDER BY CHARINDEX(TIPA,@sPriority) FOR XML PATH('') ), 1, 0, '') 
--           MODULS = STUFF(
--                           ( SELECT ',' + B.TIPA
--                               FROM #KODREF B
--                              WHERE B.KOD = A.KOD
--                            FOR XML PATH('')
--                            ), 1, 1, '')
        FROM #KODREF AS A
    GROUP BY A.KOD;
*/


          IF OBJECT_ID('TEMPDB..#KODREFLM') IS NOT NULL
             DROP TABLE #KODREFLM;
          IF OBJECT_ID('TEMPDB..#KODREFMG') IS NOT NULL
             DROP TABLE #KODREFMG;








-- **************** KOMENT PER PRIORITETET (radha e kerkimit )**************** --

/*
  Ne se do te perdoren prioritet per kodet sipas moduleve shiko keto komente:

  Pjesa e prioritetit u la per me vone

  1.	Per kete duhen: Fushat ne CONFIGMG - PRIORITYKODSCRMG,PRIORITYKODSCRLM Varchar(20)
 


  2.	Pra tek StoredProcedure [dbo].[Isd_xStartNewVersion] fut    

   if dbo.Isd_FieldTableExists('CONFIGMG','PRIORITYKODSCRLM')=0
      begin
        ALTER TABLE CONFIGMG ADD PRIORITYKODSCRLM varchar (30) NULL
        Print 'Shtim fusha PRIORITYKODSCRLM ne CONFIGMG: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('CONFIGMG','PRIORITYKODSCRMG')=0
      begin
        ALTER TABLE CONFIGMG ADD PRIORITYKODSCRMG varchar (30) NULL
        Print 'Shtim fusha PRIORITYKODSCRMG ne CONFIGMG: Varchar(30)'
      end


  3.	Shto funksionin dbo.Isd_TestPriorityKod (shiko ne fund te komentuar)




*/



-- Funksioni dbo.Isd_TestPriorityKod

/*


ALTER   FUNCTION [dbo].[Isd_TestPriorityKod]
(
  @pPriority    Varchar(20),
  @pModul       Varchar(10)
)

RETURNS Varchar(20)
AS

BEGIN

-- SELECT [dbo].[Isd_TestPriorityKod]('AFSSRRRR','MG')
-- Funksioni perdoret kur mund te jene mbushur keq fushat PRIORITYKODSCRLM,PRIORITYKODSCRMG tek CONFIGMG
-- Funksioni heq te tepertat,perseritjet dhe fut ato qe mungojne 

   DECLARE @sPriority   Varchar(20),
           @sModul      Varchar(10),

           @i           Int,
           @Result      Varchar(20),
           @sString     Varchar(10),
           @sListModuls Varchar(10);

       SET @sPriority = @pPriority;
       SET @sModul    = @pModul;

        IF @sModul='MG'
           SET @sListModuls = 'KLRSF'
        ELSE
        IF @sModul='LM'
           SET @sListModuls = 'LSFAB';



-- Hiq ato qe sjane ne @sListModul
       SET @i = 1;

        WHILE @i <= LEN(@sPriority)
           BEGIN

             SET @sString = SUBSTRING(@sPriority,@i,1)

             IF  (@i<=LEN(@sPriority)) AND (CHARINDEX(@sString, @sListModuls)=0) 
                 BEGIN
                   SET @sPriority = Replace(@sPriority,@sString,'')
                 END
             ELSE
                 BEGIN
                   SET @i = @i + 1
                 END

           END


-- Hiq dublikimet 
       SET @i = 1;

        WHILE @i <= LEN(@sPriority)
           BEGIN

             SET @sString = SUBSTRING(@sPriority,@i,1)

             IF  (@i<LEN(@sPriority)) AND (CHARINDEX(@sString, @sPriority,@i+1)>0) 
                 BEGIN
                   SET @sPriority = Substring(@sPriority,1,@i)+Replace(Substring(@sPriority,@i+1,Len(@sPriority)),@sString,'')
                 END

             SET @i = @i + 1;                   

           END



       SET @Result = @sPriority;


-- Plotesoje me ato qe mungojne (sipas @sListModuls)....
       SET @i = 1;

        WHILE @i <= LEN(@sListModuls)
           BEGIN

             SET @sString = SUBSTRING(@sListModuls,@i,1)
             IF  CHARINDEX(@sString, @sPriority)=0 
                 BEGIN
                   SET @Result = @Result + @sString
                 END

             SET @i = @i + 1;                   

           END


/*
        WHILE @i <= LEN(@sPriority)
           BEGIN

             SET @sString = SUBSTRING(@sPriority,@i,1)
             IF  CHARINDEX(@sString, @sListModuls)>0 AND CHARINDEX(@sString, @Result)=0
                 BEGIN
                   SET @Result = @Result + @sString
                 END

             SET @i = @i + 1;                   

           END
*/


  RETURN (@Result)

END


*/
GO
