SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
                                                           
                                                   
CREATE Procedure [dbo].[Isd_GetDataDokShoqerimi]                                 
(
 @pNrRendor  Int
)
As          
	 
	 DECLARE @NrRendor Int;
	     SET @NrRendor = @pNrRendor; --1723098

     DECLARE @KMag      Varchar(30),
             @KMagLnk   Varchar(30);

      SELECT @KMag    = KMAG, @KMagLnk=KMAGLNK
	    FROM FD
       WHERE NRRENDOR=@pNrRendor;

--  PRINT @KMag;	Print @KMagLnk

      SELECT SHENIM1       = ISNULL(A.SHENIM1,''),
	         SHENIM2       = ISNULL(A.SHENIM2,''),
			 SHENIM3       = ISNULL(A.SHENIM3,''),
			 StartPoint    = A.FISOBJECT,
			 DestinSHENIM1 = ISNULL(B.SHENIM1,''),
			 DestinSHENIM2 = ISNULL(B.SHENIM2,''),
			 DestinSHENIM3 = ISNULL(B.SHENIM3,''),
			 DestinPoint   = B.FISOBJECT 
		FROM MAGAZINA A, MAGAZINA B
	   WHERE A.KOD=@KMag AND B.KOD=@KMagLnk
GO
