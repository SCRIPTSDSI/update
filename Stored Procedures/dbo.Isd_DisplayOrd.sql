SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   procedure [dbo].[Isd_DisplayOrd]
 (
   @PKMag      Varchar(30),
   @PTableTmp  Varchar(30),
   @PNrRendor  Int Output,
 --@PTipKll    Varchar(10),
   @PSMFK      Varchar(10),
   @PGjendje   Bit    -- Te hiqet sepse nuk perdoret ne program
 )
As

     Declare @Sql            Varchar(Max),
             @TableNameTmp   Varchar(60),
             @TableName      Varchar(60)

         Set @TableNameTmp = @PTableTmp;

          if CharIndex('_MK',@TableNameTmp)>0
             Set @TableNameTmp = Substring(@TableNameTmp,1,CharIndex('_MK',@TableNameTmp)-1);


   if CharIndex(@PSMFK,'KSU')>0
      begin

         Set @TableName = @TableNameTmp+'_MK';
        Exec [dbo].[Isd_DisplayOrdPvt] @PKMag, @TableName, @PNrRendor, 'M', @PSMFK, @PGjendje;

         Set @TableName = @TableNameTmp+'_DQ';
        Exec [dbo].[Isd_DisplayOrdPvt] @PKMag, @TableName, @PNrRendor, 'D', @PSMFK, @PGjendje;


         Set @TableName = @TableNameTmp+'_KL';
        Exec [dbo].[Isd_DisplayOrdPvt] @PKMag, @TableName, @PNrRendor, 'K', @PSMFK, @PGjendje;

      --Return;
      end;

   if @PSMFK='K' OR @PSMFK='TOT'
      begin

          if Object_Id('TempDB..'+@TableNameTmp+'_TT') is not null
             Exec ('DROP TABLE ' +@TableNameTmp+'_TT');


        Set @Sql = '
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
              TROW         = Cast(0 As Bit),
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

        Exec (@Sql);
        Return;

      end;
GO
