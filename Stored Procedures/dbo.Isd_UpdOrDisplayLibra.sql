SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--     Exec dbo.Isd_UpdOrDisplayLibra 'LM', 0

CREATE   Procedure [dbo].[Isd_UpdOrDisplayLibra]
( 
  @pModul     Varchar(30),
  @pAdd       Int
 )
AS

-- Hidhet nga Raportet e LM si dhe Programi tek Test libra ...

         SET NOCOUNT ON


     DECLARE @AddRows     Int;

         SET @AddRows   = ISNULL(@pAdd,0);


          IF OBJECT_ID('TEMPDB..#TempLM') IS NOT NULL
             DROP TABLE #TempLM;

             
             SELECT A.*,
                    PERSHKRIM = Case When A.SG1<>'' 
									 Then       IsNull((Select Top 1 LTrim(RTrim(PERSHKRIM)) From LLOGARI     B Where B.KOD=A.SG1),'') 
									 Else '' 
                                End 
                                +
								Case When A.SG2<>'' 
									 Then ' / '+IsNull((Select Top 1 LTrim(RTrim(PERSHKRIM)) From DEPARTAMENT B Where B.KOD=A.SG2),'') 
									 Else '' 
                                End
                                +
								Case When A.SG3<>'' 
									 Then ' / '+IsNull((Select Top 1 LTrim(RTrim(PERSHKRIM)) From LISTE       B Where B.KOD=A.SG3),'') 
									 Else '' 
                                End
                                +
								Case When A.SG4<>'' 
									 Then ' / '+IsNull((Select Top 1 LTrim(RTrim(PERSHKRIM)) From MAGAZINA    B Where B.KOD=A.SG4),'') 
									 Else '' 
                                End
                                +
								Case When A.SG5<>'' 
									 Then ' / '+IsNull((Select Top 1 LTrim(RTrim(PERSHKRIM)) From MONEDHA     B Where B.KOD=A.SG5),'') 
									 Else '' 
                                End
               INTO #TempLM
               FROM 
				    (   SELECT KOD,KMON,
                               SG1 = dbo.Isd_SegmentFind(KOD,0,1),
                               SG2 = dbo.Isd_SegmentFind(KOD,0,2),
                               SG3 = dbo.Isd_SegmentFind(KOD,0,3),
                               SG4 = dbo.Isd_SegmentFind(KOD,0,4),
                               SG5 = dbo.Isd_SegmentFind(KOD,0,5)
                          FROM FKSCR A 
						 WHERE not (Exists (SELECT KOD FROM LM B WHERE A.KOD=B.KOD))
                      GROUP BY KOD,KMON
                      ) A
          ORDER BY KOD

             IF @AddRows=0
                BEGIN
                    SELECT KOD,PERSHKRIM,KMON,SG1,SG2,SG3,SG4,SG5 
                      FROM #TempLM 
                  ORDER BY KOD
                END
             ELSE
                BEGIN
                    INSERT INTO LM
                          (KOD,PERSHKRIM,KMON,SG1,SG2,SG3,SG4,SG5)
                    SELECT KOD,PERSHKRIM,KMON,SG1,SG2,SG3,SG4,SG5 
                      FROM #TempLM A
                     WHERE NOT (EXISTS (SELECT KOD FROM LM B WHERE A.KOD=B.KOD))
                  ORDER BY KOD
                END;
            
           

           IF OBJECT_ID('TEMPDB..#TempLM') IS NOT NULL
              DROP TABLE #TempLM;




----Select * From FKSCR Order By KOD
--SELECT * 
----DELETE 
--FROM LM WHERE ISNULL(SG5,'')<>'' 
--ORDER BY KOD
--Select DataLength(SG2) FROM #TempLM Order By 1 Desc
--use TempDB
--Select * From Sys.Columns Where Name='PERSHKRIM'
--Select * From LM ORDER BY NRRENDOR
GO
