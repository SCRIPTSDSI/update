SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE        procedure [dbo].[Isd_AQStatistics]
(
  @pKod       VARCHAR(60),
  @pDateStart VARCHAR(20),           -- Shiko dhe function   Isd_AQTestDateOper
  @pDateEnd   VARCHAR(20),
  @pWhere     VARCHAR(MAX),
  @pUser      VARCHAR(30)
)

AS

     -- EXEC Isd_AQStatistics 'AS000001','31/12/2010','31/12/2019','','ADMIN';

         SET NOCOUNT ON


     DECLARE @sKod           VARCHAR(60);


         SET @sKod         = @pKod;
 
   -- SELECT B.* FROM AQ A INNER JOIN AQSCR B ON A.NRRENDOR=B.NRD WHERE KARTLLG=@sKod;

      SELECT DATEFIRSTCE   = MIN(CASE WHEN ISNULL(B.KODOPER,'') IN ('CE')            THEN  B.DATEOPER END),
      
             DATEFIRSTBL   = MIN(CASE WHEN ISNULL(B.KODOPER,'') IN ('BL','MM')       THEN  B.DATEOPER END),
             DATELASTBL    = MAX(CASE WHEN ISNULL(B.KODOPER,'') IN ('BL','MM')       THEN  B.DATEOPER END),
             DATEFIRSTPR   = MIN(CASE WHEN ISNULL(B.KODOPER,'') IN ('BL','MM','PR')  THEN  B.DATEOPER END),
             
             DATEFIRSTSH   = MIN(CASE WHEN ISNULL(B.KODOPER,'') IN ('SH','JP')       THEN  B.DATEOPER END),
             DATELASTSH    = MIN(CASE WHEN ISNULL(B.KODOPER,'') IN ('SH','JP')       THEN  B.DATEOPER END),
             DATEFIRSTAM   = MIN(CASE WHEN ISNULL(B.KODOPER,'')='AM'                 THEN  B.DATEOPER END),
             DATELASTAM    = MAX(CASE WHEN ISNULL(B.KODOPER,'')='AM'                 THEN  B.DATEOPER END),
             
             VLERA         = SUM(CASE WHEN B.KODOPER IN ('CE','BL','MM','SI','ST')   THEN  1
                                      WHEN B.KODOPER IN ('SH','JP')                  THEN -1
                                      ELSE                                                 0
                                 END * B.VLERABS),
             VLERAMV       = SUM(CASE WHEN B.KODOPER IN ('CE','BL','MM','SI','ST')   THEN  1
                                      WHEN B.KODOPER IN ('SH','JP')                  THEN -1
                                      ELSE                                                 0
                                 END * B.VLERABS * ISNULL(A.KURS2,1) / ISNULL(A.KURS1,1)),
             VLERAAM       = SUM(CASE WHEN B.KODOPER IN ('CE','AM','SI','ST')        THEN  1 ELSE 0 END * B.VLERAAM),
             VLERAAMMV     = SUM(CASE WHEN B.KODOPER IN ('CE','AM','SI','ST')        THEN  1 ELSE 0 END * B.VLERAAM * ISNULL(A.KURS2,1) / ISNULL(A.KURS1,1)),
             GJENDJE       = SUM(CASE WHEN B.KODOPER IN ('CE','BL','MM','SI','ST')   THEN  1
                                      WHEN B.KODOPER IN ('SH','JP')                  THEN -1
                                      ELSE                                                 0
                                 END * B.VLERABS)
                             -
                             SUM(CASE WHEN B.KODOPER IN ('CE','AM','SI','ST')        THEN  1 ELSE 0 END * B.VLERAAM),
             GJENDJEMV     = SUM(CASE WHEN B.KODOPER IN ('CE','BL','MM','SI','ST')   THEN  1
                                      WHEN B.KODOPER IN ('SH','JP')                  THEN -1
                                      ELSE                                                 0
                                 END * B.VLERABS * ISNULL(A.KURS2,1) / ISNULL(A.KURS1,1))
                             -
                             SUM(CASE WHEN B.KODOPER IN ('CE','AM','SI','ST')        THEN  1 ELSE 0 END * B.VLERAAM * ISNULL(A.KURS2,1) / ISNULL(A.KURS1,1))--B.*
        FROM AQ A INNER JOIN AQSCR B ON A.NRRENDOR=B.NRD
       WHERE KARTLLG=@sKod;
GO
