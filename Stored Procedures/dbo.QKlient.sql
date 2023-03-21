SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE     procedure [dbo].[QKlient]
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
             A.OKFJSHOQ,
             A.PERQDSCN,
             A.AGJENTSHITJE,
             A.KATEGORI,
             A.RAJON,
             A.ADRESA1,
             A.ADRESA2,
             A.KLASIFIKIM1,
             A.KLASIFIKIM2,
             A.TELEFON1,
             A.TELEFON2,
             A.VENDNDODHJE,
             A.GRUP,
             A.KMAG,
             A.APLFIRO,
             A.NOTACTIV,
             A.KOMENTACTIV,
             A.KOMENT,
             A.EMAIL,
             A.APLKREDILIM,
             A.KREDI,
             A.AFAT,
             A.BLOCKDT,
             A.BLOCKDTKP,
             A.BLOCKDTKS,
             DTAF             = A.AFAT,
             KLASAKF          = A.GRUP,
             ISDOKSHOQ        = A.OKFJSHOQ,
             PERQZBR          = A.PERQDSCN,
             RRETHI           = R1.PERSHKRIM,
--           AGJENTSHITJELINK = R2.KODMASTER,  -- nuk ka nevoje ne dokument por ne fund tek Doc_Save kontrollohet
             A.ISDOCFISCAL,
             A.NRRENDOR

        FROM KLIENT A LEFT JOIN VENDNDODHJE  R1 ON A.VENDNDODHJE =R1.KOD
                   -- LEFT JOIN AGJENTSHITJE R2 ON A.AGJENTSHITJE=R2.KOD

       WHERE A.KOD=@PKod






GO
