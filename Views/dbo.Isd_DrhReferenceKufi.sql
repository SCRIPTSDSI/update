SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO




CREATE   VIEW [dbo].[Isd_DrhReferenceKufi] 

AS

-- SELECT * FROM Isd_DrhReferenceKufi WHERE PERDORUES='ADMIN' AND REFERENCE>='ARTIKUJ' AND REFERENCE<='ARTIKUJ' ORDER BY PERDORUES,NR      

--     DECLARE @sPerdorues      Varchar(40),
--             @sReferenceKp    Varchar(50),
--             @sReferenceKs    Varchar(50);
     
--         SET @sPerdorues    = 'ADMIN';
--         SET @sReferenceKp  = 'FURNITOR';
--         SET @sReferenceKs  = 'FURNITOR';
         
      SELECT NR             = ROW_NUMBER() OVER( PARTITION BY A.KODUS,MODUL,REFERENCE ORDER BY A.KODUS,MODUL,REFERENCE,KUFIP,KUFIS),
             PERDORUES      = A.KODUS,
             MODUL,
             REFERENCE,
             NGA            = A.KUFIP,
             DERI           = A.KUFIS,
             Grupimi        = CASE WHEN MODUL='F'   THEN 'Blerje' 
                                   WHEN MODUL='S'   THEN 'Shitje'
                                   WHEN MODUL='M'   THEN 'Magazina' 
                                   WHEN MODUL='A'   THEN 'Arka'
                                   WHEN MODUL='B'   THEN 'Banka'
                                   WHEN MODUL='L'   THEN 'Kontabiliteti'
                                   WHEN MODUL='X'   THEN 'Aktivet'
                                   WHEN MODUL='REF' THEN 'Referenca'
                                   WHEN MODUL='L'   THEN 'Referenca ne LM'
                                   ELSE                  'Panjohur'
                              END,
--           PromptDokument = B.PERSHKRIM, -- tek dbo.Isd_TipDocuments
             A.NRRENDOR,
             A.TROW,
             A.TAGNR
        FROM DRHUSERKUFI A --LEFT JOIN Isd_TipDocuments B ON ISNULL(A.TIPDOK,'')=ISNULL(B.KOD,'')
--     WHERE KODUS=@sPerdorues AND REFERENCE>=@sReferenceKp AND REFERENCE<=@sReferenceKs
--  ORDER BY KODUS,NR    --,MODUL,REFERENCE,KUFIP,KUFIS;
  
--  SELECT * FROM DRHUSERKUFI
--Select DISTINCT TIPDOK From Isd_TipDocuments
GO
