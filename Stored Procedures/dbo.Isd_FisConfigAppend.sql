SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE    procedure [dbo].[Isd_FisConfigAppend]
(
  @pGrup     Varchar(50),
  @pKod      Varchar(50),
  @pGrupNew  Varchar(50),
  @pKodNew   Varchar(50),
  @pUser     Varchar(50)
 )

As


-- EXEC dbo.Isd_FisConfigAppend 'FIS','FISFJINSERT','FIS','FISSMINSERT','ADMIN'


     DECLARE @sGrup        Varchar(50),
             @sKod         Varchar(50),
			 @sGrupNew     Varchar(50),
             @sKodNew      Varchar(50),
			 @sUser        Varchar(50);

         SET @sGrup      = @pGrup;
		 SET @sKod       = @pKod;
		 SET @sGrupNew   = @pGrupNew;
		 SET @sKodNew    = @pKodNew;
		 SET @sUser      = @pUser;


      INSERT INTO FISCONFIG
	        (GRUP,  KOD,        KODORDER,FUSHA,VLERA,PERSHKRIM,SHENIM1,SHENIM2,KLASIFIKIM1,USI,   USM) 
      SELECT @sGrupNew,@sKodNew,KODORDER,FUSHA,VLERA,PERSHKRIM,SHENIM1,SHENIM2,KLASIFIKIM1,@sUser,@sUser 
        FROM FisConfig
       WHERE GRUP=@sGrup AND KOD=@sKod
    ORDER BY GRUP,KOD,KODORDER;

GO
