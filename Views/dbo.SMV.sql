SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO











CREATE   VIEW [dbo].[SMV]
AS
SELECT TOP 100 PERCENT SM.Nrdok,SM.Kase,SM.KMAG AS [Kod Magazine],SM.SHENIM1 AS Magaina,SM.TIMED AS Data,SCR.KODAF AS [Kod Artikull],
SCR.PERSHKRIM AS ARTIKULLI,SCR.Sasi,SCR.Njesi,SCR.Cmimm as Cmim,SCR.VLERABS as Vlera,SM.VLERTOT as [Vlera Totale],
convert(nvarchar(30),SM.NRRENDOR)+'SM' as NRRENDOR,convert(nvarchar(30),SCR.NRD)+'SM' as NRD,SM.Kase as kasa,karte,pike,0 as Mbyllur
,scr.cmshzb0,scr.sasi*(scr.cmshzb0-scr.cmimm) as zbritjeart,sm.vlerzbr as zbritjefat,scr.perqtvsh,KL.KODKASE as kodkase,sm.klientid as nrkarta,sm.fic,
Fiskalizim = case when isnull(fic,'')='' then '' else SM.FIC end,[E-Fature] = case when isnull(SM.eic,'')='' then '' else SM.EIC end  ,
[Status] = SM.STATUS,FatureTatimore = Case when isnull(isfj,0)=1 then 'po' else '' end,
KaPdf = case when isnull(sm.fiscpdf,'')='' then '' else 'po' end
FROM dbo.SM AS SM
RIGHT JOIN dbo.SMSCR AS SCR ON SCR.NRD = SM.NRRENDOR
INNER JOIN dbo.ARTIKUJ AS A ON A.NRRENDOR = SCR.NRRENDKLLG
INNER JOIN dbo.KLASATVSH AS KL ON KL.KOD = A.KODTVSH




UNION ALL

SELECT TOP 100 PERCENT SM.Nrdok,SM.Kase,SM.KMAG AS [Kod Magazine],SM.SHENIM1 AS Magaina,SM.TIMED AS Data,SCR.KODAF AS [Kod Artikull],
SCR.PERSHKRIM AS ARTIKULLI,SCR.Sasi,SCR.Njesi,SCR.Cmimm as Cmim,SCR.VLERABS as Vlera,SM.VLERTOT as [Vlera Totale],
convert(nvarchar(30),SM.NRRENDOR)+'SM' as NRRENDOR,convert(nvarchar(30),SCR.NRD)+'SM' as NRD,SM.Kase as kasa,karte,pike,0 as Mbyllur
,scr.cmshzb0,scr.sasi*(scr.cmshzb0-scr.cmimm) as zbritjeart,sm.vlerzbr as zbritjefat,scr.perqtvsh,KL.KODKASE as kodkase,sm.klientid as nrkarta,sm.fic,
Fiskalizim = case when isnull(fic,'')='' then '' else SM.FIC end,[E-Fature] = case when isnull(SM.eic,'')='' then '' else SM.EIC end  ,
[Status] = SM.STATUS,FatureTatimore = Case when isnull(isfj,0)=1 then 'po' else '' end,
KaPdf = case when isnull(sm.fiscpdf,'')='' then '' else 'po' end
FROM dbo.SMbak AS SM
RIGHT JOIN dbo.SMbakSCR AS SCR ON SCR.NRD = SM.NRRENDOR
INNER JOIN dbo.ARTIKUJ AS A ON A.NRRENDOR = SCR.NRRENDKLLG
INNER JOIN dbo.KLASATVSH AS KL ON KL.KOD = A.KODTVSH

--UNION ALL
--SELECT TOP 100 PERCENT F.NRDOK,'K01' AS KASE,M.KOD AS [KOD MAGAZINE],M.PERSHKRIM AS MAGAINA
--,F.DATEDOK AS DATA,FS.KARTLLG AS [KOD ARTIKULL],FS.PERSHKRIM AS ARTIKULLI,FS.SASI,FS.NJESI,FS.CMIMM AS CMIM,
--FS.SASI*FS.CMIMM AS VLERA,F.VLERTOT AS [VLERA TOTALE],CONVERT(VARCHAR(20),F.NRRENDOR) +'FJ' AS NRRENDOR,
--CONVERT(VARCHAR(20),F.NRRENDOR) +'FJ' AS NRD,'K01' AS KASA,0 AS KARTE,0 AS PIKE,1 AS MBYLLUR,FS.CMSHZB0,
--FS.sasi*(FS.cmshzb0-FS.cmimm) AS ZBRITJEART,F.VLERZBR AS ZBRITJEFAT,FS.PERQTVSH,KT.KODKASE,NULL AS NRKARTA
--FROM FJ AS F
--INNER JOIN FJSCR AS FS ON FS.NRD=F.NRRENDOR
--INNER JOIN POSKONFIGMAG AS P ON P.KMAG =(SELECT TOP 1 KMAG FROM POSKONFIGMAG)
--INNER JOIN MAGAZINA M ON M.KOD = P.KMAG
----INNER JOIN KASE K ON K.KMAG = M.KOD
--INNER JOIN ARTIKUJ A ON A.KOD = FS.KARTLLG
--INNER JOIN KLASATVSH AS KT ON KT.KOD = A.KODTVSH
ORDER BY DATA DESC


















GO
