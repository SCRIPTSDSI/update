SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE View [dbo].[DRHReferenceKL] As
--SELECT * FROM DRHUSER
--SELECT * FROM DRHUSERKUFI WHERE MODUL='S'
--
-- Dokumenta
--   Select A.*,
--          KufiP=Cast(Convert(VarChar(10),GetDate()-5,101) As DateTime),
--          KufiS=Cast(Convert(Varchar(10),GetDate(),101) As DateTime)
--    From FJ A Inner Join DRHReference  B On A.KODFKL=B.KOD
--   Where B.Modul='S' And B.KodUs='USERONE'
--Order By B.KodUs,B.Modul,B.TipDok

-- Referenca
--   Select A.*,
--    From KLIENT A Inner Join DRHReference  B On A.KOD=B.KOD
--   Where B.Modul='S' And B.KodUs='USERONE'
--Order By B.KodUs,B.Modul,B.TipDok
--
  --Klient
  SELECT KODUS=A.USERN, B.KOD, MODUL='S', TIPDOK='',REFERDOK=''  
    FROM DRH..USERS A, KLIENT B 
   WHERE Not Exists (SELECT 1 
                       FROM DRHUSERKUFI C
                      WHERE C.KODUS=A.USERN AND MODUL='S' AND (B.KOD>=C.KUFIP AND B.KOD<=C.KUFIS ))

  UNION ALL --Furnitor
  SELECT KODUS=A.USERN, B.KOD, MODUL='F', TIPDOK='',REFERDOK=''  
    FROM DRH..USERS A, FURNITOR B 
   WHERE Not Exists (SELECT 1 
                       FROM DRHUSERKUFI C
                      WHERE C.KODUS=A.USERN AND MODUL='F' AND (B.KOD>=C.KUFIP AND B.KOD<=C.KUFIS ))

  UNION ALL --Artikuj
  SELECT KODUS=A.USERN, B.KOD, MODUL='M', TIPDOK='',REFERDOK='' 
    FROM DRH..USERS A, ARTIKUJ B 
   WHERE Not Exists (SELECT 1 
                       FROM DRHUSERKUFI C
                      WHERE C.KODUS=A.USERN AND MODUL='M' AND (B.KOD>=C.KUFIP AND B.KOD<=C.KUFIS ))

  UNION ALL --Llogari
  SELECT KODUS=A.USERN, B.KOD, MODUL='L', TIPDOK='',REFERDOK='' 
    FROM DRH..USERS A, LLOGARI B 
   WHERE Not Exists (SELECT 1 
                       FROM DRHUSERKUFI C
                      WHERE C.KODUS=A.USERN AND MODUL='L' AND (B.KOD>=C.KUFIP AND B.KOD<=C.KUFIS ))
GO
