SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE     procedure [dbo].[QSherbim]
(
  @PKod Varchar(50)
 )

As

SELECT A.NRRENDOR, A.KOD, A.PERSHKRIM, 
       A.NJESI, CMSH, A.CMSH1, A.CMSH2, A.CMSH3, A.CMSH4, A.CMSH5, A.CMSH6,A.CMSH7,A.CMSH8,A.CMSH9, 
       A.TATIM, A.BC,
       A.KODTVSH,
       PERQTVSH = B.PERQINDJE,
       TATIM
  FROM SHERBIM A LEFT JOIN KLASATATIM B ON A.KODTVSH=B.KOD
 WHERE A.KOD=@PKod






GO