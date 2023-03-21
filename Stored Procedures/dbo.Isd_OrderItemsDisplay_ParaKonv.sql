SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   procedure [dbo].[Isd_OrderItemsDisplay_ParaKonv]
 (
   @PKMag      Varchar(30),
   @PTableTmp  Varchar(30),
   @PNrRendor  Int Output,
 --@PTipKll    Varchar(10),
   @PSMFK      Varchar(10),
   @PGjendje   Bit    -- Te hiqet sepse nuk perdoret ne program
 )
As

     DECLARE @Sql            Varchar(Max),
             @TableNameTmp   Varchar(60),
             @TableName      Varchar(60)

         SET @TableNameTmp = @PTableTmp;

          IF CHARINDEX('_MK',@TableNameTmp)>0
             SET @TableNameTmp = SUBSTRING(@TableNameTmp,1,CHARINDEX('_MK',@TableNameTmp)-1);


   IF CHARINDEX(@PSMFK,'KSU')>0
      BEGIN

         SET @TableName = @TableNameTmp+'_MK';
        EXEC [dbo].[Isd_OrderItemsDisplayPvt] @PKMag, @TableName, @PNrRendor, 'M', @PSMFK, @PGjendje;

         SET @TableName = @TableNameTmp+'_DQ';
        EXEC [dbo].[Isd_OrderItemsDisplayPvt] @PKMag, @TableName, @PNrRendor, 'D', @PSMFK, @PGjendje;


         SET @TableName = @TableNameTmp+'_KL';
        EXEC [dbo].[Isd_OrderItemsDisplayPvt] @PKMag, @TableName, @PNrRendor, 'K', @PSMFK, @PGjendje;

      --RETURN;
      END;

   IF @PSMFK='K' OR @PSMFK='TOT'
      BEGIN

          IF OBJECT_ID('TempDB..'+@TableNameTmp+'_TT') IS NOT NULL
             EXEC ('DROP TABLE ' +@TableNameTmp+'_TT');


        SET @Sql = '
       SELECT KOD,
              PERSHKRIM    = MAX(A.PERSHKRIM),
              NJESI        = MAX(A.NJESI),
              TOTALMK_SASI = SUM(A.TOTALMK),
              TOTALDQ_SASI = SUM(A.TOTALDQ),
              TOTALKL_SASI = SUM(A.TOTALKL),
              TOTAL_SASI   = SUM(A.TOTALMK)+SUM(A.TOTALDQ)+SUM(A.TOTALKL),
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
              TOTALMK = TOTAL_SASI,
              TOTALDQ = 0,
              TOTALKL = 0,
              NRORDMK = NRORD_SASI,
              NRORDDQ = 0,
              NRORDKL = 0
         FROM '+@TableNameTmp+'_MK
    UNION ALL
       SELECT KOD,PERSHKRIM,NJESI,
              TOTALMK = 0,
              TOTALDQ = TOTAL_SASI,
              TOTALKL = 0,
              NRORDMK = 0,
              NRORDDQ = NRORD_SASI,
              NRORDKL = 0
         FROM '+@TableNameTmp+'_DQ
    UNION ALL
       SELECT KOD,PERSHKRIM,NJESI,
              TOTALMK = 0,
              TOTALDQ = 0,
              TOTALKL = TOTAL_SASI,
              NRORDMK = 0,
              NRORDDQ = 0,
              NRORDKL = NRORD_SASI
         FROM '+@TableNameTmp+'_KL
      ) A
     GROUP BY KOD
     ORDER BY KOD ';

        EXEC (@Sql);
        RETURN;

      END;

GO
