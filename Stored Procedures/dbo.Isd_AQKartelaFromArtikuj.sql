SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- EXEC [Isd_AQKartelaFromArtikuj] 1;

CREATE Procedure [dbo].[Isd_AQKartelaFromArtikuj]
 (
  @pNrRendor Int
  )
AS

         SET NOCOUNT ON

     DECLARE @NrRendor          Int;

         SET @NrRendor        = ISNULL(@pNrRendor,0);


         IF  @NrRendor=0
             BEGIN
               SELECT PERSHKRIM='NUK KA';
               RETURN;
             END;
             

      SELECT TOP 1 
          -- KOD              = A.KOD, 
             PERSHKRIM        = A.PERSHKRIM,
             KLASIF1          = A.KLASIF,
             KLASIF2          = A.KLASIF2,
             KLASIF3          = A.KLASIF3,
             KLASIF4          = A.KLASIF4,
             KLASIF5          = A.KLASIF5,
             KLASIF6          = A.KLASIF6,
             NJESI            = A.NJESI,
             
             PERSHKRIMSH      = A.PERSHKRIMSH,
             BC               = A.BC,
             DEP              = A.DEP,
             LIST             = A.LIST,
             KODLM            = A.KODLM,
             FURNITOR         = A.FURNKOD
        FROM ARTIKUJ A
       WHERE NRRENDOR=@NrRendor;
      


GO
