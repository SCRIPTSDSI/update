SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- EXEC dbo.Isd_UpdateAqFromFt 'FF',76156,'',''


CREATE         Procedure [dbo].[Isd_UpdateAQFromFT]
(
  @pTableName     Varchar(20),
  @pNrRendor      Int,
  @pUser          Varchar(20),
  @pLgJob         Varchar(30)
 )

AS


         SET NOCOUNT ON


     DECLARE @NrRendor       Int,
             @TableName      Varchar(20),
             @Perdorues      Varchar(30),
             @LgJob          Varchar(30),

             @AqNew          Bit,
             @Vlere          Float,
             @NrRendorAq     Int,
             @NrDFkAq        Int,
             @Kurs1          Float,
             @Kurs2          Float;

         SET @NrRendor     = @PNrRendor;
         SET @Perdorues    = @PUser;
         SET @LgJob        = @PLgJob;
         SET @TableName    = UPPER(ISNULL(@pTableName,''));
         SET @NrDFkAq      = 0;
         SET @AqNew        = 0;

   --    SET @TableTmpLm   = @PTableTmpLm;
   -- SELECT @AutoPostLmAQ = ISNULL(AUTOPOSTLMSQ,0)  
   --   FROM CONFIGLM;



          IF CHARINDEX(','+@TableName+',',',FF,FJ,')=0
             RETURN;
             

          IF @TableName='FF'
             BEGIN
             
               SELECT @NrRendorAQ   = ISNULL(NRRENDORAQ,0), 
                      @KURS1        = ISNULL(KURS1,1),
                      @KURS2        = ISNULL(KURS2,1)
                 FROM FF A
                WHERE NRRENDOR = @NrRendor; 
                
                   IF EXISTS( SELECT * FROM FFSCR A WHERE NRRENDOR = @NrRendor AND (TIPKLL='X' OR ISNULL(KODAQ,'')<>''))
                      SET @AqNew = 1; 

             END
             
          ELSE
          
             BEGIN

               SELECT @NrRendorAQ   = ISNULL(NRRENDORAQ,0), 
                      @KURS1        = ISNULL(KURS1,1),
                      @KURS2        = ISNULL(KURS2,1)
                 FROM FJ A
                WHERE NRRENDOR = @NrRendor; 

                   IF EXISTS( SELECT * FROM FJSCR A WHERE NRRENDOR = @NrRendor AND (TIPKLL='X' OR ISNULL(KODAQ,'')<>''))
                      SET @AqNew = 1; 
                
             END;   


          IF @NrRendorAq<=0
             RETURN;
             
             

          IF @AqNew=0
             BEGIN
             --PRINT 'U fshi Aq nga UPDATE '
               EXEC  dbo.Isd_DocDeleteExt 'AQ', @NrRendorAq, @Perdorues, @LgJob, 1;
               RETURN;
             END;
             


     -- EXEC dbo.Isd_ChangeMgFromFt 'FF', @NrRendor, @ChangeDoc Out, @ChangeScr Out  
     -- ska nevoje sepse pyetet tek dbo.Isd_GjenerimAqFromFt
     --  IF @ChangeScr=1 or @ChangeDoc=0      -- Rasti @ChangeScr=1 Trajtohet tek Isd_GjenerimAqFromFt
     --     RETURN;
     



--             Print 'U Update Aq nga procedure UPDATE '

      SELECT @NrDFkAq      = MAX(ISNULL(NRDFK,0)),
             @Vlere        = SUM(CASE WHEN A.DST='AM' THEN ISNULL(B.VLERAAM,0) ELSE ISNULL(B.VLERABS,0) END)
        FROM AQ A INNER JOIN AQSCR B ON A.NRRENDOR=B.NRD
       WHERE A.NRRENDOR=@NrRendorAq;



          IF @NrDFkAq>0
             BEGIN
               EXEC   Dbo.LM_DELFK   @NrDFkAq;
               
               UPDATE AQ SET NRDFK=0 WHERE NRRENDOR=@NrRendorAq;
             END;


          IF @TableName='FF'
             BEGIN
             
               UPDATE A
                  SET A.DATEDOK      = B.DATEDOK,
                      A.KMAG         = B.KMAG,
                   -- A.NRDOK        = CASE WHEN ISNULL(A.NRDOK,0)>0 
                   --                       THEN A.NRDOK 
                   --                       ELSE (SELECT MAX(Q.NRDOK)+1 FROM AQ Q WHERE YEAR(Q.DATEDOK)=YEAR(B.DATEDOK))
                   --                  END,
                      A.NRFRAKS      = 0,
                      A.SHENIM1      = B.SHENIM1,
                      A.SHENIM2      = B.SHENIM2,
                      A.SHENIM3      = B.SHENIM3,
                      A.SHENIM4      = B.SHENIM4,
                      A.DOK_JB       = 1,
                      A.GRUP         = '',
                      A.KTH          = B.KTH,
                      A.DST          = 'BL',  
                      A.TIPFAT       = 'F',
                      A.USI          = B.USI,
                      A.USM          = B.USM,
                      A.FIRSTDOK     = B.FIRSTDOK,
                      A.NRRENDORFAT  = B.NRRENDOR,
                      A.DATEEDIT     = GETDATE()
                 FROM AQ A INNER JOIN FF B ON A.NRRENDOR=B.NRRENDORAQ
                WHERE A.NRRENDOR=@NrRendorAq AND B.NRRENDOR=@NrRendor;
                
             END

          ELSE
          
             BEGIN
             
               UPDATE A
                  SET A.DATEDOK      = B.DATEDOK,
                      A.KMAG         = B.KMAG,
                   -- A.NRDOK        = CASE WHEN ISNULL(A.NRDOK,0)>0 
                   --                       THEN A.NRDOK 
                   --                       ELSE (SELECT MAX(Q.NRDOK)+1 FROM AQ Q WHERE YEAR(Q.DATEDOK)=YEAR(B.DATEDOK))
                   --                  END,
                      A.NRFRAKS      = 0,
                      A.SHENIM1      = B.SHENIM1,
                      A.SHENIM2      = B.SHENIM2,
                      A.SHENIM3      = B.SHENIM3,
                      A.SHENIM4      = B.SHENIM4,
                      A.DOK_JB       = 1,
                      A.GRUP         = '',
                      A.KTH          = B.KTH,
                      A.DST          = 'SH',
                      A.TIPFAT       = 'S',  
                      A.USI          = B.USI,
                      A.USM          = B.USM,
                      A.FIRSTDOK     = B.FIRSTDOK,
                      A.NRRENDORFAT  = B.NRRENDOR,
                      A.DATEEDIT     = GETDATE()
                 FROM AQ A INNER JOIN FF B ON A.NRRENDOR=B.NRRENDORAQ
                WHERE A.NRRENDOR=@NrRendorAq AND B.NRRENDOR=@NrRendor;
                
             END;


-- Kujdes te futet....

--      EXEC dbo.Isd_AppendTransLog 'AQ', @NrRendorAq, @Vlere, 'M', @Perdorues, @LgJob;


GO
