SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[FJ_INSERT_ARKA]
    (
      @PFJNRRENDOR AS INT ,
      @PKODAB AS VARCHAR(3) ,
      @PDATEDOK AS DATETIME
    )
AS 
    DECLARE @VNRRENDORAB AS INT ,
        @VLLOGARI AS VARCHAR(60) ,
        @VKMON AS VARCHAR(3) ,
        @VKURS1 AS FLOAT ,
        @VKURS2 AS FLOAT ,
        @VSHENIM1 AS VARCHAR(60) ,
        @VSHENIM2 AS VARCHAR(60) ,
        @VNUMDOK AS INT ,
        @VVLERA AS FLOAT ,
        @VVLERAMV AS FLOAT ,
        @FIRSTDOK AS VARCHAR(10) ,
        @VDATEDOK AS DATETIME ,
        @VNRDOK AS INT ,
        @VKODFKL AS VARCHAR(30) ;
           
   SET @VNUMDOK=    (SELECT ISNULL(MAX(NUMDOK),'')+1 FROM ARKA WHERE KODAB= @PKODAB)   
   SET @VNRRENDORAB=(SELECT NRRENDOR FROM ARKAT WHERE KOD= @PKODAB)
   SET @VLLOGARI=   (SELECT LLOGARI  FROM ARKAT WHERE KOD= @PKODAB)
   SET @VKMON=      ISNULL((SELECT @VKMON   FROM ARKAT WHERE KOD= @PKODAB),'')
   SET @VKURS1=     (SELECT KURS1  FROM MONEDHA WHERE KOD= @VKMON)
   SET @VKURS2=     (SELECT KURS2  FROM MONEDHA WHERE KOD= @VKMON)
   SET @VSHENIM1=   (SELECT SHENIM1 FROM FJ WHERE NRRENDOR= @PFJNRRENDOR)
   SET @VSHENIM2=   (SELECT SHENIM2 FROM FJ WHERE NRRENDOR= @PFJNRRENDOR)
   SET @VVLERA=     (SELECT VLERTOT FROM FJ WHERE NRRENDOR= @PFJNRRENDOR)
   SET @VVLERAMV=   (SELECT VLERTOT FROM FJ WHERE NRRENDOR= @PFJNRRENDOR)*@VKURS2/@VKURS1
   SET @FIRSTDOK=   'A'+CAST(@VNUMDOK AS VARCHAR)
   SET @VDATEDOK=   (SELECT ISNULL(DATEDOK,'') FROM FJ WHERE NRRENDOR=@PFJNRRENDOR)
   SET @VNRDOK=     (SELECT ISNULL(NRDOK,0) FROM FJ WHERE NRRENDOR=@PFJNRRENDOR)
   SET @VKODFKL=    (SELECT ISNULL(KODFKL,0) FROM FJ WHERE NRRENDOR=@PFJNRRENDOR)
   
   
   BEGIN TRAN T1
   --INSERT KOKA
 INSERT INTO ARKA
           ([KODNENDITAR]           ,[NRDFK]           ,[TIPDOK]
           ,[NRRENDORAB]            ,[KODAB]           ,[LLOGARI]
           ,[KMON]                  ,[NUMDOK]          ,[FRAKSDOK]
           ,[DATEDOK]               ,[VLERA]           ,[VLERAMV]
           ,[KURS1]                 ,[KURS2]           ,[SHENIM1]
           ,[SHENIM2]               ,[NRDITAR]         ,[NRSERI]
           ,[FIRSTDOK]              ,[POSTIM]          ,[LETER]
           ,[KLASIFIKIM]            ,[USI]             ,[USM]
           ,[TROW]                  ,[TAGNR])

 SELECT     ''                       ,0                 ,'MA'
           ,@VNRRENDORAB            ,@PKODAB           ,@VLLOGARI
           ,@VKMON                  ,@VNUMDOK          ,0
           ,@PDATEDOK               ,@VVLERA           ,@VVLERAMV
           ,@VKURS1                 ,@VKURS2           ,@VSHENIM1
           ,@VSHENIM2               ,0                 ,''
           ,@FIRSTDOK               ,0                 ,0
           ,''                      ,'A'               ,'A'
           ,0                       ,0
         
   DECLARE @VNRD AS INT ;
   SET @VNRD = @@IDENTITY
   EXEC UPDATE_DITARE 'A', 'ARKA', @VNRD
	   
   --LLOGARIA E ARKES
   INSERT INTO [ARKASCR]
           ([NRD]           ,[KODAF]           ,[KOD]                                ,[TIPREF]
           ,[DATEDOKREF]    ,[NRDOKREF]        ,[PERSHKRIM]                          ,[KOMENT]
           ,[LLOGARI]       ,[LLOGARIPK]       ,[DB]                                 ,[KR]
           ,[DBKRMV]        ,[KMON]            ,[KURS1]                              ,[KURS2]
           ,[TREGDK]        ,[RRAB]            ,[TIPKLL]                             ,[NRDITAR]
           )
    SELECT  @VNRD           ,@VLLOGARI         ,@VLLOGARI+'....'+ISNULL(@VKMON,'')   ,''
           ,NULL            ,0                 ,'LIKUJDIM I FATURES'                 ,@VSHENIM1
           ,@VLLOGARI       ,@VLLOGARI         ,@VVLERA                              ,0
           ,@VVLERA         ,@VKMON            ,@VKURS1                              ,@VKURS2
           ,'D'             ,'K'               ,'T'                                  ,0
           
           
   --KLIENTI      
      INSERT INTO [ARKASCR]
           ([NRD]           ,[KODAF]           ,[KOD]                                ,[TIPREF]
           ,[DATEDOKREF]    ,[NRDOKREF]        ,[PERSHKRIM]                          ,[KOMENT]
           ,[LLOGARI]       ,[LLOGARIPK]       ,[DB]                                 ,[KR]
           ,[DBKRMV]        ,[KMON]            ,[KURS1]                              ,[KURS2]
           ,[TREGDK]        ,[RRAB]            ,[TIPKLL]                             ,[NRDITAR]
           )
      SELECT  @VNRD           ,@VKODFKL          ,@VKODFKL+'.'+ISNULL(@VKMON,'')       ,'FJ'
             ,@VDATEDOK       ,@VNRDOK           ,@VSHENIM1                            ,''
             ,@VKODFKL        ,@VKODFKL          ,0                                    ,@VVLERA
             ,-@VVLERAMV      ,@VKMON            ,@VKURS1                              ,@VKURS2
             ,'K'             ,''                ,'S'                                  ,0
           
		 
  DECLARE @VNRDSCR AS INT ;
  SET @VNRDSCR = @@IDENTITY
  EXEC UPDATE_DITARE 'S', 'ARKA', @VNRDSCR
		 
     
     
  IF @@ERROR <> 0 
    BEGIN
        ROLLBACK TRAN T1 ;
            SELECT  'TRANSAKSIONI DESHTOI' ;
        END
  ELSE 
    BEGIN
        COMMIT TRAN T1 ;
            SELECT  'TRANSAKSIONI U MBYLL ME SUKSES' ;
    END
                         




--EXECUTE [FJ_INSERT_ARKA] 
--   1663
--  ,'A01'
--  ,'2010-10-14 00:00:00.000'
--GO
GO
