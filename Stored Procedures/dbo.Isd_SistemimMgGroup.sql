SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE         procedure [dbo].[Isd_SistemimMgGroup]
(
  @PTableMName    Varchar(30),
  @PTableDName    Varchar(30),
  @PDate          Varchar(20),
  @PQKosto        Varchar(60),
  @PKoment        Varchar(200),

  @PsWhere1       Varchar(Max),
  @PsWhere2       Varchar(Max),
  @PsWhere3       Varchar(Max),
  @PZerimVlere    Bit,
  @PNotMagZero    Bit,
  @PDeleteOld     Bit

)

As

-- EXEC dbo.Isd_SistemimMgGroup 'ARTIKUJSISTM','ARTIKUJSIST','31/12/2015','6051','Sistemim magazine','','','',0,0,1

         SET NOCOUNT ON



     DECLARE @sSql           Varchar(Max),
             @TableMName     Varchar(30),
             @TableDName     Varchar(30),
             @Date           Varchar(20),
             @QKosto         Varchar(60),
             @Koment         Varchar(200),
             @sWhere1        Varchar(Max),
             @sWhere2        Varchar(Max),
             @sWhere3        Varchar(Max),
             @NotMagZero     Bit,
             @ZerimVlere     Bit,
             @DeleteOld      Bit,
             @sWhereE        Varchar(Max),
             @TranNumber     Varchar(30);


         SET @TableMName   = @PTableMName;
         SET @TableDName   = @PTableDName;
         SET @Date         = @PDate;
         SET @QKosto       = @PQKosto;
         SET @Koment       = @PKoment;

         SET @sWhere1      = @PsWhere1;
         SET @sWhere2      = @PsWhere2;
         SET @sWhere3      = @PsWhere3;
         SET @NotMagZero   = @PNotMagZero;
         SET @ZerimVlere   = @PZerimVlere;
         SET @DeleteOld    = @PDeleteOld;

         SET @sWhereE      = QuoteName(@sWhere3,'''');

         Set @TranNumber   = dbo.Isd_RandomNumberChars(1);



         SET @sSQL =  '

          IF 1='+CAST(@DeleteOld AS VARCHAR)+'
             BEGIN
               DELETE FROM '+@TableDName+';
               DELETE FROM '+@TableMName+';
             END;


      UPDATE '+@TableMName+' SET TRANNUMBER=0 ;

      INSERT INTO '+@TableMName+'
            (KMAG,PERSHKRIM,NRDOK,NRFRAKS,SHENIM1,DATEDOK,QKOSTO,STATUSST,TRANNUMBER)
      SELECT KOD, PERSHKRIM, 0, 0, '''+@Koment+''', DBO.DATEVALUE('''+@Date+'''),
             QKOSTO='''+@QKosto+''', STATUSST=0, TRANNUMBER='''+@TranNumber+'''
        FROM MAGAZINA 
       WHERE (1=1) 
    ORDER BY KOD; 


      INSERT INTO '+@TableDName+'
            (NRD,KMAG,KOD,SASIOLD,VLERAOLD,ACTIV)   -- ,DATEDOK,SHENIM1
      SELECT MAX(M.NRRENDOR),LEVIZJEHD.KMAG, KARTLLG,  
             GJENDJES = ROUND(SUM(SASIH -SASID),3), 
             GJENDJEV = ROUND(SUM(VLERAH-VLERAD),3),1
--           DBO.DATEVALUE('''+@Date+'''), 
--           ''Sistemim dt '  +@Date+''' 
        FROM ARTIKUJ INNER JOIN LEVIZJEHD ON ARTIKUJ.KOD=KARTLLG 
                     INNER JOIN '+@TableMName+' M ON LEVIZJEHD.KMAG=M.KMAG AND M.TRANNUMBER='''+@TranNumber+''' 
                     LEFT  JOIN SKEMELM   ON SKEMELM.KOD=ARTIKUJ.KODLM 
       WHERE (2=2)   
              
    GROUP BY LEVIZJEHD.KMAG,KARTLLG  
      HAVING ABS(ROUND(SUM(SASIH -SASID),3))>=0.01 OR ABS(ROUND(SUM(VLERAH -VLERAD),3))>=0.01
    ORDER BY LEVIZJEHD.KMAG,KARTLLG; 


          IF 1='+CAST(@PNotMagZero AS VARCHAR)+'
             BEGIN
               DELETE 
                 FROM '+@TableMName+'  
                WHERE (TRANNUMBER='''+@TranNumber+''') AND 
                      (NOT EXISTS (SELECT NRRENDOR FROM '+@TableDName+' B WHERE '+@TableMName+'.NRRENDOR=B.NRD))
             END;

              
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
             VLERANEW   = CASE WHEN 1='+CAST(@ZerimVlere AS VARCHAR)+'
                               THEN CASE WHEN ABS(ISNULL(SASIOLD,0))<0.01 THEN 0 ELSE VLERAOLD END
                               ELSE VLERAOLD
                          END,
             VLERADIF   = CASE WHEN 1='+CAST(@ZerimVlere AS VARCHAR)+'
                               THEN 0
                               ELSE VLERAOLD - CASE WHEN ABS(ISNULL(SASIOLD,0))<0.01 THEN 0 ELSE VLERAOLD END
                          END,
             KOSTMESMG  = CASE WHEN VLERAOLD*SASIOLD>0 
                               THEN ROUND(VLERAOLD/SASIOLD,3) 
                               ELSE ROUND(B.KOSTMES,3) 
                          END,
             NRRENDKLLG = B.NRRENDOR, 
--             CMB        = B.CMB, 
--             CMSH       = B.CMSH,
--             CMSH1      = B.CMSH1,
--             CMSH2      = B.CMSH2,
--             CMSH3      = B.CMSH3,
--             CMSH4      = B.CMSH4,
--             CMSH5      = B.CMSH5,
--             CMSH6      = B.CMSH6,
--             CMSH7      = B.CMSH7,
--             CMSH8      = B.CMSH8,
--             CMSH9      = B.CMSH9,
--             CMSH10     = B.CMSH10,
--             CMSH11     = B.CMSH11,
--             CMSH12     = B.CMSH12,
--             CMSH13     = B.CMSH13,
--             CMSH14     = B.CMSH14,
--             CMSH15     = B.CMSH15,
--             CMSH16     = B.CMSH16,
--             CMSH17     = B.CMSH17,
--             CMSH18     = B.CMSH18,
--             CMSH19     = B.CMSH19,
             BC         = B.BC,
             KLASIF     = B.KLASIF,
             TAG        = 0, 
             TROW       = 0 
        FROM '+@TableDName+' A LEFT JOIN ARTIKUJ B ON A.KOD=B.KOD 
                               LEFT JOIN '+@TableMName+' M ON A.NRD=M.NRRENDOR AND M.TRANNUMBER='''+@TranNumber+'''; 

             

    EXEC dbo.Isd_SistemimMgUpdate '''+@TableMName+''','''+@TableDName+''',''KOSTMESND'','+@sWhereE+',''M.TRANNUMBER='+@TranNumber+''',''KOSTMESND'';
--  EXEC dbo.Isd_SistemimMgUpdate '''+@TableMName+''','''+@TableDName+''',''KOSTMES'','  +@sWhereE+',''M.TRANNUMBER='+@TranNumber+''',''KOSTREF''
--  EXEC dbo.Isd_SistemimMgUpdate '''+@TableMName+''','''+@TableDName+''',''KOSTMESMG'','+@sWhereE+',''M.TRANNUMBER='+@TranNumber+''',''KOSTMESREF''
--  Perdoren nga brenda programit ....



      UPDATE '+@TableMName+' SET TRANNUMBER='''' WHERE TRANNUMBER='''+@TranNumber+'''; ';

       IF @sWhere1<>'' 
          SET @sSql = REPLACE(@sSql,'(1=1)',  @sWhere1);
       IF @sWhere2<>'' 
          SET @sSql = REPLACE(@sSql,'(2=2)',  @sWhere2);

    PRINT @sSql;
    EXEC (@sSql);
GO
