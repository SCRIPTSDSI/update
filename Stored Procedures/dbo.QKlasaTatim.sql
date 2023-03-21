SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE     procedure [dbo].[QKlasaTatim]
(
  @pKod Varchar(50)
 )

As

    SELECT A.NRRENDOR, 
           A.KOD, A.PERSHKRIM,	A.PERQINDJE, A.LLOGARIDB, A.LLOGARIKR, A.TIP, 
	       A.KODTVSHFIC, A.KODTVSHEIC, A.NOTACTIV

      FROM KLASATATIM A 
                 
     WHERE A.KOD=@pKod






GO
