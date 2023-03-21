SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE        procedure [dbo].[Isd_SistemimMgTest]
(
  @PTableMName    Varchar(30),
  @PTableDName    Varchar(30),
  @PModTest       Int
)

As

-- EXEC [dbo].[Isd_SistemimMgTest] 'SISTEMIMMG','SISTEMIMMGSCR',1

     DECLARE @sSql          Varchar(Max),
             @TableMName    Varchar(30),
             @TableDName    Varchar(30),
             @ModTest       Int;

         SET @TableMName = @PTableMName;
         SET @TableDName = @PTableDName;
         SET @ModTest    = @PModTest;


          IF OBJECT_ID('TEMPDB..#SISTMGTEST') IS NOT NULL
             DROP TABLE #SISTMGTEST;

      SELECT ERRORMSG = SHENIM1,
             ERRORKOD = SHENIM1,
             SHENIM   = SHENIM1,
             ERRORORD = CAST(0 AS INT),
             NRRENDOR = CAST(0 AS INT),
             TROW     = CAST(0 AS BIT)

        INTO #SISTMGTEST

        FROM ARTIKUJSISTM
       WHERE 1=2;

         SET @sSql = '

      INSERT INTO #SISTMGTEST
            (ERRORMSG,ERRORKOD,SHENIM,ERRORORD,NRRENDOR,TROW)

      SELECT ERRORMSG,ERRORKOD,SHENIM,ERRORORD,NRRENDOR,TROW
        FROM

     (
      SELECT ERRORMSG = ''Kod Magazine gabuar: ''+IsNull(A.KMAG,''''),
             ERRORKOD = A.KMAG,
             SHENIM   = ISNULL(A.KMAG,'''')+'' - ''+ISNULL(A.PERSHKRIM,'''')+CONVERT(VARCHAR,A.DATEDOK,104),
             ERRORORD = 1,
             A.NRRENDOR,
             TROW     = CAST(0 AS BIT)
        FROM '+@TableMName+' A LEFT JOIN MAGAZINA R1 ON A.KMAG=R1.KOD
       WHERE ISNULL(A.STATUSST,0)=0 AND ISNULL(R1.KOD,'''')=''''

   UNION ALL  
      SELECT ERRORMSG = ''Periudhe fiskale e pa hapur: ''+CONVERT(VARCHAR,A.DATEDOK,104),
             ERRORKOD = CONVERT(VARCHAR,A.DATEDOK,104),
             SHENIM   = ISNULL(A.KMAG,'''')+'' - ''+ISNULL(A.PERSHKRIM,'''')+CONVERT(VARCHAR,A.DATEDOK,104),
             ERRORORD = 2,
             A.NRRENDOR,
             TROW     = CAST(0 AS BIT)
        FROM '+@TableMName+' A LEFT JOIN ARTIKUJ R1 ON A.KMAG=R1.KOD
       WHERE ISNULL(A.STATUSST,0)=0 AND (SELECT ISNULL(GJENDJE,'''') FROM PERIUDHE WHERE A.DATEDOK>=DATA AND A.DATEDOK<=DATA1)<>''H''

   UNION ALL
      SELECT ERRORMSG = ''Nr dokumenti gabuar: ''+CAST(CAST(ISNULL(A.NRDOK,0) AS BIGINT) AS VARCHAR),
             ERRORKOD = CAST(CAST(ISNULL(A.NRDOK,0) AS BIGINT) AS VARCHAR),
             SHENIM   = ISNULL(A.KMAG,'''')+'' - ''+ISNULL(A.PERSHKRIM,'''')+CONVERT(VARCHAR,A.DATEDOK,104),
             ERRORORD = 3,
             A.NRRENDOR,
             TROW     = CAST(0 AS BIT)
        FROM SISTEMIMMG A 
       WHERE ISNULL(A.STATUSST,0)=0 AND ISNULL(A.NRDOK,0)<=0

   UNION ALL
      SELECT ERRORMSG = ''Nr dokumenti dublikuar: ''+
                        CAST(CAST(ISNULL(A.NRDOK,0) AS BIGINT) AS VARCHAR) + 
                        CASE WHEN ISNULL(A.NRFRAKS,0)>0 THEN ''.''+CAST(ISNULL(A.NRFRAKS,0) AS VARCHAR) ELSE '''' END,
             ERRORKOD = CAST(CAST(ISNULL(A.NRDOK,0) AS BIGINT) AS VARCHAR) + 
                        CASE WHEN ISNULL(A.NRFRAKS,0)>0 THEN ''.''+CAST(ISNULL(A.NRFRAKS,0) AS VARCHAR) ELSE '''' END,
             SHENIM   = ISNULL(A.KMAG,'''')+'' - ''+ISNULL(A.PERSHKRIM,'''')+CONVERT(VARCHAR,A.DATEDOK,104),
             ERRORORD = 4,
             A.NRRENDOR,
             TROW     = CAST(0 AS BIT)
        FROM SISTEMIMMG A INNER JOIN FH R1 ON ISNULL(A.KMAG,'''')=ISNULL(R1.KMAG,'''') AND 
                                              YEAR(A.DATEDOK)    =YEAR(R1.DATEDOK)   AND 
                                              ISNULL(A.NRDOK,0)  =ISNULL(R1.NRDOK,0) AND 
                                              ISNULL(A.NRFRAKS,0)=ISNULL(R1.NRFRAKS,0)
       WHERE ISNULL(A.STATUSST,0)=0 AND ISNULL(A.NRDOK,0)>0

   UNION ALL
      SELECT ERRORMSG = ''Qender Kosto gabim(llg): ''+ISNULL(A.QKOSTO,''''),
             ERRORKOD = dbo.Isd_SegmentFind(A.QKOSTO,0,1),
             SHENIM   = ISNULL(A.KMAG,'''')+'' - ''+ISNULL(A.PERSHKRIM,'''')+CONVERT(VARCHAR,A.DATEDOK,104),
             ERRORORD = 5,
             A.NRRENDOR,
             TROW     = CAST(0 AS BIT)
        FROM '+@TableMName+' A LEFT JOIN LLOGARI R1 ON dbo.Isd_SegmentFind(A.QKOSTO,0,1)=R1.KOD
       WHERE ISNULL(A.STATUSST,0)=0 AND dbo.Isd_SegmentFind(A.QKOSTO,0,1)<>'''' AND ISNULL(R1.KOD,'''')=''''

   UNION ALL
      SELECT ERRORMSG = ''Qender Kosto gabim(dep): ''+ISNULL(A.QKOSTO,''''),
             ERRORKOD = dbo.Isd_SegmentFind(A.QKOSTO,0,2),
             SHENIM   = ISNULL(A.KMAG,'''')+'' - ''+ISNULL(A.PERSHKRIM,'''')+CONVERT(VARCHAR,A.DATEDOK,104),
             ERRORORD = 6,
             A.NRRENDOR,
             TROW     = CAST(0 AS BIT)
        FROM '+@TableMName+' A LEFT JOIN DEPARTAMENT R1 ON dbo.Isd_SegmentFind(A.QKOSTO,0,2)=R1.KOD
       WHERE ISNULL(A.STATUSST,0)=0 AND dbo.Isd_SegmentFind(A.QKOSTO,0,2)<>'''' AND ISNULL(R1.KOD,'''')=''''

   UNION ALL
      SELECT ERRORMSG = ''Qender Kosto gabim(lis): ''+ISNULL(A.QKOSTO,''''),
             ERRORKOD = dbo.Isd_SegmentFind(A.QKOSTO,0,3),
             SHENIM   = ISNULL(A.KMAG,'''')+'' - ''+ISNULL(A.PERSHKRIM,'''')+CONVERT(VARCHAR,A.DATEDOK,104),
             ERRORORD = 7,
             A.NRRENDOR,
             TROW     = CAST(0 AS BIT)
        FROM '+@TableMName+' A LEFT JOIN LISTE R1 ON dbo.Isd_SegmentFind(A.QKOSTO,0,3)=R1.KOD
       WHERE ISNULL(A.STATUSST,0)=0 AND dbo.Isd_SegmentFind(A.QKOSTO,0,3)<>'''' AND ISNULL(R1.KOD,'''')=''''

   UNION ALL
      SELECT ERRORMSG = ''Artikull gabim: ''+ISNULL(B.KOD,''''),
             ERRORKOD = ISNULL(B.KOD,''''),
             SHENIM   = ISNULL(A.KMAG,'''')+'' - ''+ISNULL(A.PERSHKRIM,'''')+CONVERT(VARCHAR,A.DATEDOK,104),
             ERRORORD = 8,
             A.NRRENDOR,
             TROW     = CAST(0 AS BIT)
        FROM '+@TableMName+' A LEFT JOIN '+@TableDName+' B  ON A.NRRENDOR=B.NRD
                               LEFT JOIN ARTIKUJ         R1 ON ISNULL(B.KOD,'''')=R1.KOD
       WHERE ISNULL(A.STATUSST,0)=0 AND ISNULL(R1.KOD,'''')=''''

      ) A

    ORDER BY ERRORORD,ERRORKOD 


                SELECT * 
                  FROM #SISTMGTEST
              ORDER BY ERRORORD,ERRORKOD;  ';

--     PRINT @sSql;
       EXEC (@sSql);
GO
