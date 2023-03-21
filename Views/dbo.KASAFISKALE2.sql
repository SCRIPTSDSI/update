SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



--SELECT 
CREATE view [dbo].[KASAFISKALE2] 
AS
select TOP 100 PERCENT scr.sasi,
cmshzb0=ROUND(scr.VLERABS/SCR.SASI,2),
left(REPLACE(rEPLACE(REPLACE(replace(replace(replace(replace(replace(REPLACE(REPLACE(scr.pershkrim,'''',''),'.',''),'”',' '),'“',' '),';',' '),'’',' '), '`', ''), '&', ''), '''', ''), '!', ''),20) as artikulli,
0 as zbritjeart,
scr.perqtvsh,
sm.vlerzbr as zbritjefat,
kodkase = CASE WHEN A.TATIM=1 THEN '1' ELSE '9' END,
CONVERT(NVARCHAR(20),SM.NRRENDOR) AS NRRENDOR
from FJSCR AS SCR with (nolock)
INNER JOIN FJ SM with (nolock) ON SM.NRRENDOR = SCR.NRD
INNER JOIN ARTIKUJ AS A with (nolock) ON A.KOD = SCR.KARTLLG
WHERE SM.NRRENDOR = 3312
ORDER BY SCR.SASI



GO
