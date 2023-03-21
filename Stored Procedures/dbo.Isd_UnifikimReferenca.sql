SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   Procedure [dbo].[Isd_UnifikimReferenca]

As  

--    Procedura hidhet nga ImportSql ....



        SET NOCOUNT ON

-- 1. Mbushja e TablesName nga X_ImpExp

      INSERT INTO CONFIG..TABLESNAME
            (TABLESTR,NRORDER,KOD,PERSHKRIM,TABLENAME,MODUL,TIP,ORG,STRUCTURE)
      SELECT TABLESTR    = 'REF',
             NRORDER     = '00'+CAST((SELECT MAX(CAST(NRORDER AS INT))+1 FROM CONFIG..TABLESNAME WHERE TABLESTR='REF') AS VARCHAR),
             KOD         = A.FNAME,
             PERSHKRIM   = REPLACE(A.PERSHKRIM,' ',''),
             TABLENAME   = A.FNAME,
             MODUL       = CASE WHEN CHARINDEX(','+A.FNAME+',',',USERS,')>0 THEN 'L' ELSE 'S' END,
             TIP         = '',
             ORG         = CASE WHEN CHARINDEX(','+A.FNAME+',',',USERS,')>0 THEN '' ELSE 'F' END,
             STRUCTURE   = 'RF'
        FROM CONFIG..X_IMPEXP A -- FULL OUTER JOIN CONFIG..X_IMPEXP B ON B.FNAME=A.TABLENAME 
       WHERE A.TIPEXP='R' AND A.IMPORT=1 AND (NOT EXISTS (SELECT * FROM CONFIG..TABLESNAME B WHERE TABLESTR='REF' AND B.TABLENAME=A.FNAME))
    ORDER BY A.FNAME;



-- 2. Mbushja e X_ImpExp nga TablesName
 
      --IF NOT EXISTS (SELECT * FROM X_IMPEXP WHERE FORDER='R0000')
      --   BEGIN
      --     INSERT INTO CONFIG..X_IMPEXP
      --           (FORDER,MODUL,TIPEXP,TIPROW,TIPDOK,FNAME,PERSHKRIM,IMPORT,EXPORT,NDARES)
      --     SELECT FORDER      = 'R0000',
      --            MODUL       = 'T',
      --            TIPEXP      = 'R',
      --            TIPROW      = 'T',
      --            TIPDOK      = '',
      --            FNAME       = '',
      --            PERSHKRIM   = 'Referenca',
      --            IMPORT      = 0,
      --            EXPORT      = 0,
      --            NDARES      = 1
      --   END;

      INSERT INTO CONFIG..X_IMPEXP
            (FORDER,MODUL,TIPEXP,TIPROW,TIPDOK,FNAME,PERSHKRIM,IMPORT,EXPORT,NDARES)
      SELECT FORDER      = CASE WHEN CHARINDEX(','+A.TABLENAME+',',',NENDITAR,,USERS,')>0 THEN 'A01' ELSE 'A00' END+'51',
             MODUL       = CASE WHEN CHARINDEX(','+A.TABLENAME+',',',NENDITAR,,USERS,')>0 THEN 'T'   ELSE 'X' END,
             TIPEXP      = 'R',
             TIPROW      = 'R',
             TIPDOK      = '',
             FNAME       = A.TABLENAME,
             PERSHKRIM   = '    '+A.PERSHKRIM,
             IMPORT      = 1,
             EXPORT      = 0,
             NDARES      = 0
        FROM CONFIG..TABLESNAME A 
       WHERE A.STRUCTURE='RF'  AND (NOT EXISTS (SELECT * FROM CONFIG..X_IMPEXP B WHERE TIPEXP='R' AND B.FNAME=A.TABLENAME))
    ORDER BY KOD;

GO
