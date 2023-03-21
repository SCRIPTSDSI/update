SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE         procedure [dbo].[Isd_SistemimMgUpdate]
(
  @PTableMName    Varchar(30),
  @PTableDName    Varchar(30),
  @PFieldName     Varchar(30),
  @PsWhere1       Varchar(Max),
  @PsWhere2       Varchar(Max),
  @PModUpdate     Varchar(20)
)

As

--  Update sipas Kosto nd/je
--  EXEC dbo.Isd_SistemimMgUpdate 'ARTIKUJSISTM','ARTIKUJSIST','KOSTMESND', 'LEFT(KARTLLG,1)=''P'' ','M.TAGNR=101','KOSTMESND'

--  Update sipas KostMes ne magazine
--  EXEC dbo.Isd_SistemimMgUpdate 'ARTIKUJSISTM','ARTIKUJSIST','KOSTMESMG',  'LEFT(KARTLLG,1)=''P'' ','M.TAGNR=101','KOSTMESMG'

--  Update sipas KostMes ne reference
--  EXEC dbo.Isd_SistemimMgUpdate 'ARTIKUJSISTM','ARTIKUJSIST','KOSTMES',   'LEFT(KARTLLG,1)=''P'' ','M.TAGNR=101','KOSTMESREF'


         SET NOCOUNT ON



     DECLARE @sSql          Varchar(Max),
             @sSql1         Varchar(Max),
             @TableMName    Varchar(30),
             @TableDName    Varchar(30),
             @FieldName     Varchar(30),
             @sWhere1       Varchar(Max),
             @sWhere2       Varchar(Max),
             @ModUpdate     Varchar(20);


         SET @TableMName  = @PTableMName;
         SET @TableDName  = @PTableDName;
         SET @FieldName   = @PFieldName;

         SET @sWhere1     = @PsWhere1;
         SET @sWhere2     = @PsWhere2;
         SET @ModUpdate   = @PModUpdate;

         SET @sSql        = '';
         SET @sSql1       = '';



         IF  @ModUpdate = 'KOSTMESMG'   -- Per KOSTMESND eshte Procedure1
             GOTO Procedure2;           -- Per KOSTMESMG eshte Procedure2
                                        -- Per KOSTMES   eshte Procedure3
         IF  @ModUpdate = 'KOSTMESREF'  
             GOTO Procedure3;


Procedure1:                            -- KOSTMESND


         SET @sSQL =  '

          IF OBJECT_ID(''TEMPDB..#ARTIKUJCMIMMG'') IS NOT NULL
             DROP TABLE #ARTIKUJCMIMMG;

      SELECT KOD       = KARTLLG,
             SASI      = ROUND(SUM(SASI),2),
             VLERAM    = ROUND(SUM(VLERAM),3),
             KOSTMESND = ROUND(CASE WHEN ROUND(SUM(VLERAM),3) * ROUND(SUM(SASI),3)>0
                                    THEN ROUND(SUM(VLERAM),3) / ROUND(SUM(SASI),3)
                                    ELSE 0
                               END,3)
        INTO #ARTIKUJCMIMMG

        FROM 

       ( 
             SELECT KARTLLG, SASI =   SUM(SASI), VLERAM =   SUM(VLERAM)
               FROM FH A INNER JOIN FHSCR B ON A.NRRENDOR=B.NRD
              WHERE (1=1)
           GROUP BY B.KARTLLG

          UNION ALL 

             SELECT KARTLLG, SASI = 0-SUM(SASI), VLERAM = 0-SUM(VLERAM)
               FROM FD A INNER JOIN FDSCR B ON A.NRRENDOR=B.NRD
              WHERE (1=1)
           GROUP BY B.KARTLLG

         ) A
       GROUP BY A.KARTLLG
       ORDER BY A.KARTLLG;  

';


       IF @TableMName<>''
          BEGIN
            SET @sSql1 = '

              UPDATE A 
                 SET '+@FieldName+' = B.KOSTMESND
                FROM '+@TableMName+' M INNER JOIN '+@TableDName+' A ON M.NRRENDOR=A.NRD 
                                       INNER JOIN #ARTIKUJCMIMMG  B ON A.KOD=B.KOD
               WHERE (2=2);';
          END;

       IF @TableMName=''
          BEGIN
            SET @sSql1 = '

              UPDATE A 
                 SET '+@FieldName+' = B.KOSTMESND
                FROM '+@TableMName+' A INNER JOIN #ARTIKUJCMIMMG  B ON A.KOD=B.KOD
               WHERE (2=2);';
          END;

     GOTO Procedure9; 

    

Procedure2:                            -- KOSTMESMG


         SET @sSQL =  '

          IF OBJECT_ID(''TEMPDB..#ARTIKUJCMIMMG'') IS NOT NULL
             DROP TABLE #ARTIKUJCMIMMG;

      SELECT KOD       = KARTLLG,
             SASI      = ROUND(SUM(SASI),2),
             VLERAM    = ROUND(SUM(VLERAM),3),
             KOSTMESND = ROUND(CASE WHEN ROUND(SUM(VLERAM),3) * ROUND(SUM(SASI),3)>0
                                    THEN ROUND(SUM(VLERAM),3) / ROUND(SUM(SASI),3)
                                    ELSE 0
                               END,3),
             KMAG
        INTO #ARTIKUJCMIMMG

        FROM 

       ( 
             SELECT KARTLLG, SASI =   SUM(SASI), VLERAM =   SUM(VLERAM), A.KMAG
               FROM FH A INNER JOIN FHSCR B ON A.NRRENDOR=B.NRD
              WHERE (1=1)
           GROUP BY A.KMAG,B.KARTLLG

          UNION ALL 

             SELECT KARTLLG, SASI = 0-SUM(SASI), VLERAM = 0-SUM(VLERAM), A.KMAG
               FROM FD A INNER JOIN FDSCR B ON A.NRRENDOR=B.NRD
              WHERE (1=1)
           GROUP BY A.KMAG,B.KARTLLG

         ) A
       GROUP BY A.KMAG,A.KARTLLG
       ORDER BY A.KMAG,A.KARTLLG;  

';


       IF @TableMName<>''
          BEGIN
            SET @sSql1 = '

              UPDATE A 
                 SET '+@FieldName+' = B.KOSTMESND
                FROM '+@TableMName+' M INNER JOIN '+@TableDName+' A ON M.NRRENDOR=A.NRD 
                                       INNER JOIN #ARTIKUJCMIMMG  B ON A.KOD=B.KOD AND M.KMAG=B.KMAG
               WHERE (2=2);';
          END;

       IF @TableMName=''
          BEGIN
            SET @sSql1 = '

              UPDATE A 
                 SET '+@FieldName+' = B.KOSTMESND
                FROM '+@TableMName+' A INNER JOIN #ARTIKUJCMIMMG  B ON A.KOD=B.KOD AND A.KMAG=B.KMAG       -- ??????
               WHERE (2=2);';
          END;


     GOTO Procedure9; 




Procedure3:                            -- KOSTMESREF
   


       IF @TableMName<>''
          BEGIN
            SET @sSql1 = '

              UPDATE A 
                 SET '+@FieldName+' = B.KOSTMES
                FROM '+@TableMName+' M INNER JOIN '+@TableDName+' A ON M.NRRENDOR=A.NRD 
                                       INNER JOIN ARTIKUJ  B ON A.KOD=B.KOD
               WHERE (2=2);';
          END;

       IF @TableMName=''
          BEGIN
            SET @sSql1 = '

              UPDATE A 
                 SET '+@FieldName+' = B.KOSTMES
                FROM '+@TableMName+' A INNER JOIN ARTIKUJ  B ON A.KOD=B.KOD
               WHERE (2=2);';
          END;





Procedure9:



      SET @sSql = @sSql + @sSql1;

       IF @sWhere1<>'' 
          SET @sSql = REPLACE(@sSql,'(1=1)',  @sWhere1);
       IF @sWhere2<>''
          SET @sSql = REPLACE(@sSql,'(2=2)',  @sWhere2);


      SET @sSql = @sSql + '

          IF OBJECT_ID(''TEMPDB..#ARTIKUJCMIMMG'') IS NOT NULL
             DROP TABLE #ARTIKUJCMIMMG;';

    PRINT @sSql;
    EXEC (@sSql);

GO
