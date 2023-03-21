SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*DECLARE @pMeNiptNrSeri    Int,
          @pPaNiptNrSeri    Int,
          @pMeNiptNrKufiP   Int,
          @pMeNiptNrKufiS   Int,
          @pPaNiptNrKufiP   Int,
          @pPaNiptNrKufiS   Int; 
      
          Exec dbo.Isd_ERZGetNrSeriFature @pMeNiptNrSeri  Output,@pPaNiptNrSeri  Output,
                                          @pMeNiptNrKufiP Output,@pMeNiptNrKufiS Output,
                                          @pPaNiptNrKufiP Output,@pPaNiptNrKufiS Output, 'ADMIN',1;*/
CREATE Procedure [dbo].[Isd_ERZGetNrSeriFature]
(
  @pMeNiptNrSeri    Int Output,
  @pPaNiptNrSeri    Int Output,
  @pMeNiptNrKufiP   Int Output,
  @pMeNiptNrKufiS   Int Output,
  @pPaNiptNrKufiP   Int Output,
  @pPaNiptNrKufiS   Int Output, 
  @pPerdorues       Varchar(30),
  @pDisplay         Int
 )

As



     DECLARE @Perdorues       Varchar(60),
             @MeNiptNrSeri    Int,
             @PaNiptNrSeri    Int,
             @MeNiptNrKufiP   Int,
             @MeNiptNrKufiS   Int,
             @PaNiptNrKufiP   Int,
             @PaNiptNrKufiS   Int,
             @Display         Int;
             
         SET @Perdorues     = ISNULL(@pPerdorues,'');
         SET @Display       = ISNULL(@pDisplay,0);

      SELECT TOP 1                                                 -- Seri fature per dokumentat me Nipt
             @MeNiptNrKufiP = NRKUFIP, 
             @MeNiptNRKUFIS = NRKUFIS 
        FROM DRHUser 
       WHERE MODUL='F' AND TIPDOK='FF' AND KODUS=@Perdorues;
      
                                                                   -- Seri fature per dokumentat me Nipt 
      SELECT @PaNiptNrKufiP = ISNULL(ERZNRKUFIP,0),
             @PaNiptNrKufiS = ISNULL(ERZNRKUFIS,0) 
        FROM CONFIGMG
      
         SET @MeNiptNrKufiP = ISNULL(@MeNiptNrKufiP,0);
         SET @MeNiptNRKUFIS = ISNULL(@MeNiptNRKUFIS,0);
         SET @PaNiptNrKufiP = ISNULL(@PaNiptNrKufiP,0);
         SET @PaNiptNrKufiS = ISNULL(@PaNiptNrKufiS,0);
         
         
      SELECT @MeNiptNrSeri  = ISNULL(MAX(ISNULL(A.NRDOK,0)),@MeNiptNrKufiP)
        FROM FF A
       WHERE A.NRDOK>=@MeNiptNrKufiP AND A.NRDOK<=@MeNiptNrKufiS;

      SELECT @PaNiptNrSeri  = ISNULL(MAX(ISNULL(A.NRDOK,0)),@PaNiptNrKufiP)
        FROM FF A
       WHERE A.NRDOK>=@PaNiptNrKufiP AND A.NRDOK<=@PaNiptNrKufiS;
       

        SET @pMeNiptNrSeri  = ISNULL(@MeNiptNrSeri,@MeNiptNrKufiP);
        SET @pPaNiptNrSeri  = ISNULL(@PaNiptNrSeri,@PaNiptNrKufiP);
        SET @pMeNiptNrKufiP = ISNULL(@MeNiptNrKufiP,0);
        SET @pMeNiptNrKufiS = ISNULL(@MeNiptNrKufiS,0);
        SET @pPaNiptNrKufiP = ISNULL(@PaNiptNrKufiP,0);
        SET @pPaNiptNrKufiS = ISNULL(@PaNiptNrKufiS,0);


--       IF @MeNiptNrSeri=@MeNiptNrKufiS
--          SET @MeNiptNrSeri = -1;
            
--       IF @PaNiptNrSeri=@PaNiptNrKufiS
--          SET @PaNiptNrSeri = -1;

         IF @Display=1
            BEGIN
              SELECT MeNiptNrSeri = @MeNiptNrSeri,  MeNiptNrKufiP = @MeNiptNrKufiP, MeNiptNrKufiS = @MeNiptNrKufiS,
                     PaNiptNrSeri = @PaNiptNrSeri,  PaNiptNrKufiP = @PaNiptNrKufiP, PaNiptNrKufiS = @PaNiptNrKufiS;
            END;
GO
