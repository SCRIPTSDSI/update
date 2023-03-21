SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   procedure [dbo].[Isd_ArtikujKtgAgjKl]
 (
   @pKMag        Varchar(30),              -- Nuk duhet
   @pTableTmp    Varchar(30),
   @pNrRendor    Int Output,
 --@pTipKll      Varchar(10),
   @pSMFK        Varchar(10),
   @pGjendje     Bit                       -- Nuk duhet
 )
AS

     DECLARE @Sql                Varchar(Max),
             @TableNameTmp       Varchar(60),
             @TableName          Varchar(60),
             @SMFK               Varchar(10),
             @NrRendor           Int;

         SET @TableNameTmp     = @pTableTmp;
         SET @NrRendor         = @pNrRendor;
         SET @SMFK             = @pSMFK;
         

   IF CHARINDEX(@PSMFK,'KS')>0
      BEGIN
        EXEC [dbo].[Isd_ArtikujKtgAgjKlPvt] @pKMag, @TableNameTmp, @NrRendor, 'K', @SMFK, @pGjendje;
      --RETURN;
      END;



/*

          IF CHARINDEX('_AGJ',@TableNameTmp)>0
             SET @TableNameTmp = SUBSTRING(@TableNameTmp,1,CHARINDEX('_AGJ',@TableNameTmp)-1);

          IF CHARINDEX(@PSMFK,'KS')>0
             BEGIN
               SET  @TableName = @TableNameTmp+'_AGJ';
               EXEC [dbo].[Isd_ArtikujKtgAgjPvt] @pKMag, @TableNameTmp, @NrRendor, 'K', @SMFK, @pGjendje;
               RETURN;
             END;


   IF @PSMFK='K' OR @PSMFK='TOT'
      BEGIN

           IF OBJECT_ID('TempDB..'+@TableNameTmp+'_TT') IS NOT NULL
              EXEC ('DROP TABLE ' +@TableNameTmp+'_TT');


          SET @Sql = '
       SELECT KOD,
              PERSHKRIM    = MAX(A.PERSHKRIM),
              NJESI        = MAX(A.NJESI),

              NRORDMK_SASI = SUM(A.NRORDMK),
              NRORDDQ_SASI = SUM(A.NRORDDQ),
              NRORDKL_SASI = SUM(A.NRORDKL),
              NRORD_SASI   = SUM(A.NRORDMK)+SUM(A.NRORDDQ)+SUM(A.NRORDKL),
              ORDERSCR     = 0,
              TROW         = CAST(0 As Bit),
              TAGNR        = 0,
              NRRENDOR     = 1

         INTO '+@TableNameTmp+'_TT

         FROM
     (
       SELECT KOD,PERSHKRIM,NJESI,
              NRORDMK = NRORD_SASI,
              NRORDDQ = 0,
              NRORDKL = 0
         FROM '+@TableNameTmp+'_AGJ
      ) A
     GROUP BY KOD
     ORDER BY KOD;
     
--     UPDATE A 
--        SET ORDERSCR=B.ORDERSCR 
--       FROM '+@TableNameTmp+'_TT A INNER JOIN OrderItemsSortScr B On A.KOD=B.KOD; ';

        EXEC (@Sql);
        
     -- RETURN;

      END;
*/
GO
