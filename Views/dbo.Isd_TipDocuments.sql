SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[Isd_TipDocuments] 
AS
      SELECT KOD='MA',PERSHKRIM='Mandat Arketimi',ORG='A', NRRENDOR=0, TROW=CAST(0 AS BIT),ORD='A01'
   UNION ALL
      SELECT KOD='MP',PERSHKRIM='Mandat Pagese',  ORG='A', NRRENDOR=0, TROW=CAST(0 AS BIT),ORD='A02'
   UNION ALL
      SELECT KOD='XJ',PERSHKRIM='Xhirim Jone ',   ORG='B', NRRENDOR=0, TROW=CAST(0 AS BIT),ORD='B01'
   UNION ALL
      SELECT KOD='CJ',PERSHKRIM='Ceku Jone',      ORG='B', NRRENDOR=0, TROW=CAST(0 AS BIT),ORD='B02'
   UNION ALL
      SELECT KOD='KR',PERSHKRIM='Kreditim Banke', ORG='B', NRRENDOR=0, TROW=CAST(0 AS BIT),ORD='B03'
   UNION ALL
      SELECT KOD='XK',PERSHKRIM='Xhirim Klienti ',ORG='B', NRRENDOR=0, TROW=CAST(0 AS BIT),ORD='B04'
   UNION ALL
      SELECT KOD='AB',PERSHKRIM='Arketim Banke',  ORG='B', NRRENDOR=0, TROW=CAST(0 AS BIT),ORD='B05'
   UNION ALL
      SELECT KOD='DB',PERSHKRIM='Debitim Banke',  ORG='B', NRRENDOR=0, TROW=CAST(0 AS BIT),ORD='B06'
   UNION ALL
      SELECT KOD='FF',PERSHKRIM='Fature Blerje',  ORG='F', NRRENDOR=0, TROW=CAST(0 AS BIT),ORD='C01'
   UNION ALL
      SELECT KOD='FJ',PERSHKRIM='Fature Shitje',  ORG='S', NRRENDOR=0, TROW=CAST(0 AS BIT),ORD='C02'
   UNION ALL
      SELECT KOD='FH',PERSHKRIM='Hyrje Magazine', ORG='H', NRRENDOR=0, TROW=CAST(0 AS BIT),ORD='C03'
   UNION ALL
      SELECT KOD='FD',PERSHKRIM='Dalje Magazine', ORG='D', NRRENDOR=0, TROW=CAST(0 AS BIT),ORD='C04'
   UNION ALL
      SELECT KOD='DG',PERSHKRIM='Dogane',         ORG='G', NRRENDOR=0, TROW=CAST(0 AS BIT),ORD='C05'
   UNION ALL
      SELECT KOD='VS',PERSHKRIM='Nd/Modulare',    ORG='E', NRRENDOR=0, TROW=CAST(0 AS BIT),ORD='D01'
   UNION ALL
      SELECT KOD='DP',PERSHKRIM='Kontabilizim',   ORG='T', NRRENDOR=0, TROW=CAST(0 AS BIT),ORD='D02'
   UNION ALL
      SELECT KOD='AQ',PERSHKRIM='Aktivet',        ORG='X', NRRENDOR=0, TROW=CAST(0 AS BIT),ORD='X01'
-- UNION ALL
--    SELECT KOD,     PERSHKRIM,                  NRRENDOR=0, TROW=CAST(0 AS BIT),ORD=ISNULL(NRORD,'') 
--      FROM CONFIG..TIPDOK 
--     WHERE TIPDOK='AQ' AND KOD<>'AQ'




-- SELECT DISTINCT
--         KOD       = TIPDOK,
--         ORG,
--         PERSHKRIM = ISNULL(ORG,'')+
--                     ' - ' +
--                     CASE WHEN ORG='A' THEN 'dokument Arke'
--                          WHEN ORG='B' THEN 'dokument Banke'
--                          WHEN ORG='H' THEN 'dokument FH'
--                          WHEN ORG='D' THEN 'dokument FD'
--                          WHEN ORG='F' THEN 'dokument Blerje'
--                          WHEN ORG='S' THEN 'dokument Shitje'
--                          WHEN ORG='G' THEN 'dokument Dogane'
--                          WHEN ORG='E' THEN 'dokument Nd/modulare'
--                          WHEN ORG='T' THEN 'dokument Kontabilizimi'
--                          WHEN ORG='X' THEN 'dokument Aktive'
--                          WHEN ORG<>'' THEN ' '
--                     END,
--         NRRENDOR  = 0,
--         TROW      = 0,
--         KODMASTER = '',
--         TIPMASTER = ''
--    FROM FK  
--ORDER BY ORG,TIPDOK
 



GO
