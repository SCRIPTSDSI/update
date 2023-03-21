SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE     procedure [dbo].[QFurnitor]
(
  @PKod Varchar(50)
 )

AS

      SELECT A.KOD, 
             A.PERSHKRIM,
             A.NIPT,
             A.KODFISKAL,
             A.KMON,
             A.AFAT, 
             A.MODPG, 
             A.RAJON,
             A.KLASIFIKIM1,
             A.KLASIFIKIM2,
             A.VENDNDODHJE,
             A.GRUP,
             A.NOTACTIV,
             A.KOMENTACTIV,
             A.KOMENT,
             A.BLOCKDTKP,
             A.BLOCKDTKS,
             DTAF             = A.AFAT,
             KLASAKF          = A.GRUP,
             ISDOKSHOQ        = CAST(0 AS BIT),
             PERQZBR          = Cast(0 AS FLOAT),
             AGJENTSHITJE     = '',
             A.PRODUCTMANAGER,
             KATEGORI         = '',
             RRETHI           = B.PERSHKRIM,
             A.ISDOCFISCAL,
             A.NRRENDOR

        FROM FURNITOR A LEFT JOIN VENDNDODHJE B ON A.VENDNDODHJE=B.KOD
       WHERE A.KOD=@PKod






GO
