SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   procedure [dbo].[Isd_TestExec]
(
  @PDateKp          Varchar(20),
  @PDateKs          Varchar(20),
  @pModuls          Varchar(50),
  @pTestVlere       Float,
  @pTestTableName   Varchar(20)
)

AS

--   DECLARE @pDisplay Int;
--       SET @pDisplay = 0;

--        IF OBJECT_ID('TempDB..#TestDok') IS NOT NULL
--           DROP TABLE #TestDok);
  
--    SELECT Dok      = REPLICATE('',20),  Test = REPLICATE('',30), ErrorDok = REPLICATE('',100), ErrorMsg = LEFT('*****    TEST    *****'+REPLICATE('',100),100),
--           ErrorRef = LEFT(' '+CAST(GetDate() AS Varchar) +REPLICATE('',100),100), TableName = REPLICATE('',100), ErrorOrder = REPLICATE('',100), ErrorRowNr = CAST(-1 AS BIGINT), NrRendor = 0
--      INTO #TestDok;

--      EXEC dbo.Isd_TestExec '01/01/2010','31/12/2012','ARKA', 0.01,'#TestDok'
--      EXEC dbo.Isd_TestExec '01/01/2010','31/12/2012','BANKA',0.01,'#TestDok'
--      EXEC dbo.Isd_TestExec '01/01/2010','31/12/2012','REF',  0.01,'#TestDok'

-- --  Afishimi:		Te gjitha = 0, Analitik + Erroret = 1, Permbledhes + Erroret = 2

--	   SELECT *
--		 FROM
--		(    SELECT *, NrError=(SELECT COUNT(ErrorRowNr) 
--							      FROM #TestDok B
--							     WHERE LEFT(B.ErrorOrder,LEN(A.ErrorOrder))=A.ErrorOrder AND ErrorRowNr>=1)
--			   FROM #TestDok A ) C
--		WHERE (@PDisplay=0) OR (@PDisplay=1 AND NrError>=1) OR	(@PDisplay=2 AND NrError>=1  AND ErrorRowNr=-1 AND ErrorMsg<>'') 
--	 ORDER BY ErrorOrder,TableName,ErrorRowNr;


-- Kjo procedure vlen kur do qe te hidhen nje ose te gjitha pa afishuar te dhenat.
-- Per rastin e te gjithave shiko Isd_TestExecute

         SET NoCount ON;


     DECLARE @TestTip             Varchar(1000),
             @DateKp              Varchar(20),
             @DateKs              Varchar(20),
             @Moduls              Varchar(50),
             @TestVlere           Float,
             @TestTableName       Varchar(20);
   
         SET @DateKp            = @pDateKp;
         SET @DateKs            = @pDateKs;
         SET @Moduls            = @pModuls;
         SET @TestVlere         = @pTestVlere;
         SET @TestTableName     = @pTestTableName;
         IF  @TestTableName=''
             SET @TestTableName = '#TestDok';

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
GO
