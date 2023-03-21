SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE         procedure [dbo].[Isd_SistemimMgDisplay]
(
  @PTableMName    Varchar(30),
  @PTableDName    Varchar(30),
--@PFieldName     Varchar(30),
  @PsWhere1       Varchar(Max),
  @PsWhere2       Varchar(Max),
  @PModDisplay    Varchar(20),
  @PTotalNd       Int
)

As

--  Display te dhena model List
--  EXEC dbo.Isd_SistemimMgDisplay 'ARTIKUJSISTM','ARTIKUJSIST', '','','AFLIST',0

--  Display te dhena model Pivot
--  EXEC dbo.Isd_SistemimMgDisplay 'ARTIKUJSISTM','ARTIKUJSIST', '','','AFPIVOT',0



         SET NOCOUNT ON



     DECLARE @sSql          Varchar(Max),
--           @sSql1         Varchar(Max),
             @TableMName    Varchar(30),
             @TableDName    Varchar(30),
--           @FieldName     Varchar(30),
             @sWhere1       Varchar(Max),
             @sWhere2       Varchar(Max),
             @ModDisplay    Varchar(20),
             @TotalNd       Int;


         SET @TableMName  = @PTableMName;
         SET @TableDName  = @PTableDName;
--       SET @FieldName   = @PFieldName;

         SET @sWhere1     = @PsWhere1;
         SET @sWhere2     = @PsWhere2;
         SET @ModDisplay  = @PModDisplay;
         SET @TotalNd     = @PTotalNd;

         SET @sSql        = '';
--       SET @sSql1       = '';



         IF  @ModDisplay = 'AFLIS'       -- Per AFLIST  eshte Procedure1
             GOTO Procedure1;            -- Per AFPIVOT eshte Procedure2 (me vone)
                                         
         IF  @ModDisplay = 'AFPIVOT'  
             GOTO Procedure2;


Procedure1:                              -- AFLIST


         SET @sSQL =  '

          IF OBJECT_ID(''TEMPDB..#TOTALND'') IS NOT NULL
             DROP TABLE #TOTALND;

      SELECT VLERAOLDND = ROUND(SUM(ISNULL(B.VLERAOLD,0)),3),
             VLERANEWND = ROUND(SUM(ISNULL(B.VLERANEW,0)),3),
             VLERADIFND = ROUND(SUM(ISNULL(B.VLERADIF,0)),3)
        INTO #TOTALND
        FROM '+@TableMName+' A INNER JOIN '+@TableDName+' B ON A.NRRENDOR=B.NRD
       WHERE ISNULL(A.STATUSST,0)=0 AND (1=1)
--  GROUP BY B.KOD
--  ORDER BY KMAG,B.KOD


      SELECT KOD        = MAX(B.KOD),
             KMAG       = SPACE(10),
             PERSHKRIM  = MAX(B.PERSHKRIM),
             NJESI      = MAX(B.NJESI),
             SASIOLD    = ROUND(SUM(ISNULL(B.SASIOLD,0)),3),
             VLERAOLD   = ROUND(SUM(ISNULL(B.VLERAOLD,0)),3),
             CMIMOLD    = ROUND(CASE WHEN ROUND(SUM(ISNULL(B.VLERAOLD,0)),3) * ROUND(SUM(ISNULL(B.SASIOLD,0)),3)>0
                                     THEN ROUND(SUM(ISNULL(B.VLERAOLD,0)),3) / ROUND(SUM(ISNULL(B.SASIOLD,0)),3)
                                     ELSE 0
                                END,3), 
             SASINEW    = ROUND(SUM(ISNULL(B.SASINEW,0)),3),
             VLERANEW   = ROUND(SUM(ISNULL(B.VLERANEW,0)),3),
             CMIMNEW    = ROUND(CASE WHEN ROUND(SUM(ISNULL(B.VLERANEW,0)),3) * ROUND(SUM(ISNULL(B.SASINEW,0)),3)>0
                                     THEN ROUND(SUM(ISNULL(B.VLERANEW,0)),3) / ROUND(SUM(ISNULL(B.SASINEW,0)),3)
                                     ELSE 0
                                END,3),
             KOSTMES    = MAX(B.KOSTMES),
             KOSTMESMG  = CAST(0.0 AS FLOAT),
             KOSTMESND  = MAX(B.KOSTMESND),
             VLERADIF   = SUM(ISNULL(B.VLERADIF,0)),
             VLERAOLDND = MAX(T1.VLERAOLDND),
             VLERANEWND = MAX(T1.VLERANEWND),
             VLERADIFND = MAX(T1.VLERADIFND),
             PROMPT     = CASE WHEN '+CAST(@TotalNd AS VARCHAR)+'=0 THEN ''Total ''+B.KOD ELSE '''' END,
             TROW       = CAST(CASE WHEN '+CAST(@TotalNd AS VARCHAR)+'=0 THEN 1 ELSE 0 END AS BIT)

        FROM '+@TableMName+' A INNER JOIN '+@TableDName+' B ON A.NRRENDOR=B.NRD
                               LEFT  JOIN MAGAZINA R2       ON A.KMAG=R2.KOD  , #TOTALND T1
       WHERE ISNULL(A.STATUSST,0)=0 AND (1=1) 
    GROUP BY B.KOD
--  ORDER BY KMAG,B.KOD

   UNION ALL

      SELECT B.KOD,
             A.KMAG,
             PERSHKRIM  = B.PERSHKRIM,
             NJESI      = B.NJESI,
             SASIOLD    = ROUND(ISNULL(B.SASIOLD,0),3),
             VLERAOLD   = ROUND(ISNULL(B.VLERAOLD,0),3),
             CMIMOLD    = CMIMOLD, 
             SASINEW    = ROUND(ISNULL(B.SASINEW,0),3),
             VLERANEW   = ROUND(ISNULL(B.VLERANEW,0),3),
             CMIMNEW    = CMIMNEW,
             KOSTMES    = B.KOSTMES,
             KOSTMESMG  = B.KOSTMESMG,
             KOSTMESND  = B.KOSTMESND,
             VLERADIF   = ISNULL(B.VLERADIF,0),
             VLERAOLDND = T1.VLERAOLDND,
             VLERANEWND = T1.VLERANEWND,
             VLERADIFND = T1.VLERADIFND,
             PROMPT     = '''',
             TROW       = CAST(0 AS BIT)

        FROM '+@TableMName+' A INNER JOIN '+@TableDName+' B ON A.NRRENDOR=B.NRD, #TOTALND T1
       WHERE ISNULL(A.STATUSST,0)=0 AND (1=1) AND (5=5)
--  GROUP BY A.KMAG,B.KOD

    ORDER BY KOD,KMAG;   ';

        GOTO Procedure9;



Procedure2:

        GOTO Procedure9;




Procedure9:



       IF @sWhere1<>'' 
          SET @sSql = REPLACE(@sSql,'(1=1)',  @sWhere1);
       IF @sWhere2<>''
          SET @sSql = REPLACE(@sSql,'(2=2)',  @sWhere2);


       IF @TotalNd>=1
          SET @sSql = REPLACE(@sSql,'(5=5)','(5=6)');

       IF @TotalNd =2
          BEGIN
            SET @sSql = REPLACE(@sSql,'GROUP BY B.KOD','GROUP BY A.KMAG');
            SET @sSql = REPLACE(@sSql,'SPACE(10)','A.KMAG');
            SET @sSql = REPLACE(@sSql,'MAX(B.KOD)','''''');
            SET @sSql = REPLACE(@sSql,'MAX(B.PERSHKRIM)','MAX(R2.PERSHKRIM)');
            SET @sSql = REPLACE(@sSql,'MAX(B.NJESI)','''''');
          END
          

    PRINT @sSql;
    EXEC (@sSql);

GO
