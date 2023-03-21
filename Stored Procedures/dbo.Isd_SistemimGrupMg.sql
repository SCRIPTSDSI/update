SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE         procedure [dbo].[Isd_SistemimGrupMg]
(
  @PTableMName    Varchar(30),
  @PTableDName    Varchar(30),
  @PKoment        Varchar(200),

  @PsWhere1       Varchar(Max),
  @PsWhere2       Varchar(Max),
  @PsWhere3       Varchar(Max)


--  @PDocument      Varchar(30), 
--  @PNdName        Varchar(30),
--  @PTableTmp      Varchar(30),
--  @PKoment        Varchar(200),
--  @PWhereKod      Varchar(Max),
--  @PWhereGj       Varchar(Max),
--  @PAppendRows    Bit,
--  @PInversVlere   Bit,
--  @PInversPozic   Bit,
--  @PAnalitikLM    Bit
)

AS


         SET NOCOUNT ON

--     DECLARE @PsWhere1      Varchar(Max),
--             @PsWhere2      Varchar(Max),
--             @PsWhere3      Varchar(Max),
--
--             @PTableMName   Varchar(30),
--             @PTableDName   Varchar(30),
--             @PArtMeLev     Bit;




     DECLARE @sSql          Varchar(Max),
             @TableMName    Varchar(30),
             @TableDName    Varchar(30),
             @Koment        Varchar(200),
             @sWhere1       Varchar(Max),
             @sWhere2       Varchar(Max),
             @sWhere3       Varchar(Max);

--             @Document      Varchar(30),
--             @NdName        Varchar(30),
--             @TableTmp      Varchar(30),
--             @AppendRows    Bit,
--             @InversVlere   Bit,
--             @InversPozic   Bit,
--             @AnalitikLM    Bit,
--             @WhereKod      Varchar(Max),
--             @WhereGj       Varchar(Max),
--             @sSql1         Varchar(Max)


         SET @TableMName  = @PTableMName;
         SET @TableDName  = @PTableDName;
         SET @Koment      = @PKoment;

         SET @sWhere1     = @PsWhere1;
         SET @sWhere2     = @PsWhere2;
         SET @sWhere3     = @PsWhere3;



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
              WHERE (2=2)
           GROUP BY B.KARTLLG

          UNION ALL 

             SELECT KARTLLG, SASI = 0-SUM(SASI), VLERAM = 0-SUM(VLERAM)
               FROM FD A INNER JOIN FDSCR B ON A.NRRENDOR=B.NRD
              WHERE (2=2)
           GROUP BY B.KARTLLG

         ) A
       GROUP BY A.KARTLLG
       ORDER BY A.KARTLLG;



      UPDATE '+@TableMName+' SET TAGNR=0 ;

      INSERT INTO '+@TableMName+'
            (KMAG,PERSHKRIM,NRDOK,NRFRAKS,SHENIM1,TAGNR)
      SELECT KOD,PERSHKRIM,0,0,''Sistemime mbylljeje'',TAGNR=101 
        FROM MAGAZINA 
       WHERE (1=1) 
    ORDER BY KOD; 
              

      INSERT INTO '+@TableDName+'
            (NRD,KMAG,KOD,SASIOLD,VLERAOLD,DATEDOK,ACTIV,SHENIM1)
      SELECT MAX(M.NRRENDOR),LEVIZJEHD.KMAG, KARTLLG,  
             GJENDJES = ROUND(SUM(SASIH -SASID),3), 
             GJENDJEV = ROUND(SUM(VLERAH-VLERAD),3),
             DBO.DATEVALUE('''+'01/01/2016'+'''), 1, 
             ''Sistemim dt '  +'01/01/2016'+''' 
        FROM ARTIKUJ INNER JOIN LEVIZJEHD ON ARTIKUJ.KOD=KARTLLG 
                     LEFT  JOIN SKEMELM   ON SKEMELM.KOD=ARTIKUJ.KODLM 
                     LEFT  JOIN '+@TableMName+' M ON LEVIZJEHD.KMAG=M.KMAG AND M.TAGNR=101 
       WHERE (2=2)   
              
    GROUP BY LEVIZJEHD.KMAG,KARTLLG  
      HAVING ABS(ROUND(SUM(SASIH -SASID),3))>=0.01 OR ABS(ROUND(SUM(VLERAH -VLERAD),3))>=0.01
    ORDER BY LEVIZJEHD.KMAG,KARTLLG; 


              
      UPDATE A 
         SET PERSHKRIM  = B.PERSHKRIM, 
             NJESI      = B.NJESI, 
             KOSTMES    = B.KOSTMES,
             CMIMART    = ROUND(B.KOSTMES,3),
             CMIMOLD    = CASE WHEN VLERAOLD*SASIOLD>0 
                               THEN ROUND(VLERAOLD/SASIOLD,3) 
                               ELSE ROUND(B.KOSTMES,3) 
                          END,
             CMIMNEW    = CASE WHEN VLERAOLD*SASIOLD>0 
                               THEN ROUND(VLERAOLD/SASIOLD,3) 
                               ELSE ROUND(B.KOSTMES,3) 
                          END,
             SASINEW    = SASIOLD,
             VLERANEW   = CASE WHEN ABS(ISNULL(SASIOLD,0))<0.01 THEN 0 ELSE VLERAOLD END,
             VLERADIF   = VLERAOLD - CASE WHEN ABS(ISNULL(SASIOLD,0))<0.01 THEN 0 ELSE VLERAOLD END,
             NRRENDKLLG = B.NRRENDOR, 
             CMB        = B.CMB, 
             CMSH       = B.CMSH,
             CMSH1      = B.CMSH1,
             CMSH2      = B.CMSH2,
             CMSH3      = B.CMSH3,
             CMSH4      = B.CMSH4,
             CMSH5      = B.CMSH5,
             CMSH6      = B.CMSH6,
             CMSH7      = B.CMSH7,
             CMSH8      = B.CMSH8,
             CMSH9      = B.CMSH9,
             CMSH10     = B.CMSH10,
             CMSH11     = B.CMSH11,
             CMSH12     = B.CMSH12,
             CMSH13     = B.CMSH13,
             CMSH14     = B.CMSH14,
             CMSH15     = B.CMSH15,
             CMSH16     = B.CMSH16,
             CMSH17     = B.CMSH17,
             CMSH18     = B.CMSH18,
             CMSH19     = B.CMSH19,
             BC         = B.BC,
             KLASIF     = B.KLASIF,
             TAG        = 0, 
             TROW       = 0 
        FROM '+@TableDName+' A LEFT JOIN ARTIKUJ B ON A.KOD=B.KOD 
                              LEFT JOIN '+@TableMName+' M ON A.NRD=M.NRRENDOR AND M.TAGNR=101; 
              

      UPDATE A 
         SET KOSTMESND = B.KOSTMESND
        FROM '+@TableDName+' A INNER JOIN #ARTIKUJCMIMMG B ON A.KOD=B.KOD;

      UPDATE '+@TableMName+' SET TAGNR=0 WHERE TAGNR=101; ';

       IF @sWhere1<>'' 
          SET @sSql = Replace(@sSql,'(1=1)',  @sWhere1);
       IF @sWhere2<>'' 
          SET @sSql = Replace(@sSql,'(2=2)',  @sWhere2);

    PRINT @sSql;


GO
