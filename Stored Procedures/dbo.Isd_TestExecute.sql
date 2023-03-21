SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   procedure [dbo].[Isd_TestExecute]
(
  @pDateKp          Varchar(20),
  @pDateKs          Varchar(20),
  @pModuls          Varchar(50),
  @pTestVlere       Float,
  @pDisplay         Int
)
AS

--       EXEC dbo.Isd_TestExecute '01/01/2010','31/12/2012','FJ',0.01,1

-- Kjo procedure vlen kur do qe te hidhen te gjitha pernjeheresh
-- Hedhja nga programi behet jo per kete procedure por per Isd_TestExec

         SET NoCount ON;

     DECLARE @TestTableName      Varchar(50),
             @DateKp             Varchar(20),
             @DateKs             Varchar(20),
             @Moduls             Varchar(50),
             @TestVlere          Float,
             @Display            Int,
             @TestTip            Varchar(1000);
   

         SET @DateKp           = @pDateKp;
         SET @DateKs           = @pDateKs;
         SET @Moduls           = @pModuls;
         SET @TestVlere        = @pTestVlere;
         SET @Display          = @pDisplay;
         SET @TestTableName    = '#TestDok';

         IF  OBJECT_ID('TempDB..#TestDok') IS NOT NULL
             DROP TABLE #TestDok;
   
      SELECT Dok=REPLICATE('',20), Test=REPLICATE('',30), ErrorDok=REPLICATE('',100), ErrorMsg=LEFT('*****    TEST    *****'+REPLICATE('',100),100),
             ErrorRef=LEFT(' '+CAST(GetDate() AS Varchar) +REPLICATE('',100),100), TableName=REPLICATE('',100), ErrorOrder=REPLICATE('',100), ErrorRowNr=CAST(-1 AS BIGINT), 
             NrRendor=0
        INTO #TestDok;
    -- WHERE 1=2

--
         SET @TestTip = dbo.Isd_ListFields2Lists(@Moduls,'ALL,BL,FF','');
         IF  @TestTip<>''
             EXEC dbo.Isd_TestDokFF     @DateKp,@DateKs,@TestTip,@TestVlere,@TestTableName;

--
         SET @TestTip = dbo.Isd_ListFields2Lists(@Moduls,'ALL,SH,FJ','');
         IF  @TestTip<>''
             EXEC dbo.Isd_TestDokFJ     @DateKp,@DateKs,@TestTip,@TestVlere,@TestTableName;

--
         SET @TestTip = dbo.Isd_ListFields2Lists('ALL,MG,FH,FD',@Moduls,'');
         IF  @TestTip<>''
             EXEC dbo.Isd_TestDokMG     @DateKp,@DateKs,@TestTip,@TestVlere,@TestTableName;

--
         SET @TestTip = dbo.Isd_ListFields2Lists('ALL,LM,ARKA,BANKA,VS,FK,VSST,FKST',@Moduls,'');
         IF  @TestTip<>''
             EXEC dbo.Isd_TestDokLM     @DateKp,@DateKs,@TestTip,@TestVlere,@TestTableName;

--
         SET @TestTip = dbo.Isd_ListFields2Lists(@Moduls,'ALL,BL,DG','');
         IF  @TestTip<>''
             EXEC dbo.Isd_TestDokDG     @DateKp,@DateKs,@TestTip,@TestVlere,@TestTableName;

--
         SET @TestTip = dbo.Isd_ListFields2Lists(@Moduls,'ALL,SH,FJT','');
         IF  @TestTip<>''
             EXEC dbo.Isd_TestDokFJT    @DateKp,@DateKs,@TestTip,@TestVlere,@TestTableName;

--
         SET @TestTip = dbo.Isd_ListFields2Lists(@Moduls,'ALL,SH,OFK','');
         IF  @TestTip<>''
             EXEC dbo.Isd_TestDokOFK    @DateKp,@DateKs,@TestTip,@TestVlere,@TestTableName;

--
         SET @TestTip = dbo.Isd_ListFields2Lists(@Moduls,'ALL,SH,ORK','');
         IF  @TestTip<>''
             EXEC dbo.Isd_TestDokORK    @DateKp,@DateKs,@TestTip,@TestVlere,@TestTableName;

--
         SET @TestTip = dbo.Isd_ListFields2Lists(@Moduls,'ALL,BL,ORF','');
         IF  @TestTip<>''
             EXEC dbo.Isd_TestDokORF    @DateKp,@DateKs,@TestTip,@TestVlere,@TestTableName;

--
         SET @TestTip = dbo.Isd_ListFields2Lists(@Moduls,'ALL,AQ','');
         IF  @TestTip<>''
             EXEC dbo.Isd_TestDokAQ     @DateKp,@DateKs,@TestTip,@TestVlere,@TestTableName;

--
         SET @TestTip = dbo.Isd_ListFields2Lists(@Moduls,'ALL,REF','');
         IF  @TestTip<>''
             EXEC dbo.Isd_TestReference @TestTip,@TestTableName;

--
         SET @TestTip = dbo.Isd_ListFields2Lists(@Moduls,'ALL,LIB','');
         IF  @TestTip<>''
             EXEC dbo.Isd_TestLibra     @TestTip,@TestTableName;

--
         IF  dbo.Isd_ListFields2Lists(@Moduls,'ALL,UPD','')>''
             EXEC dbo.Isd_TestUpdFields '';

-- Afishimi: Te gjitha = 0,  Analitik + Erroret = 1, Permbledhes + Erroret = 2

	   SELECT *
		 FROM
			(SELECT *, NrError = ( SELECT COUNT(ErrorRowNr) 
							         FROM #TestDok B
							        WHERE LEFT(B.ErrorOrder,LEN(A.ErrorOrder))=A.ErrorOrder AND ErrorRowNr>=1)
			   FROM #TestDok A ) C

		WHERE (@Display=0) OR 
              (@Display=1 AND NrError>=1) OR
              (@Display=2 AND NrError>=1  AND ErrorRowNr=-1 AND ErrorMsg<>'') 
	 ORDER BY ErrorOrder,TableName,ErrorRowNr;
GO
