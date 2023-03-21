SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE         procedure [dbo].[AQDetailGrupFormeDisplay]


AS

         SET NOCOUNT ON

-- Exec [dbo].[Isd_AQDetailGrupFormeDisplay] 



      SELECT Kod,Pershkrim,
             A.Grupi,
             A.Klasifikim1,A.Klasifikim2,
             A.ErrorGrup,
          -- A.Blokuar,
             A.ErrorTable,
             FormName,TableName,KodForme,
             NrOrder,Visible,NotActiv,Usi,Usm,DateCreate,DateEdit,Trow,TagNr,NrRendor
        FROM
         (      
             SELECT A.*,
                    ErrorGrup   = CASE WHEN ISNULL(A.FORMNAME,'')='' OR (NOT EXISTS (SELECT NRRENDOR FROM AQDetailForms B WHERE B.GRUPI=A.GRUPI))
                                       THEN '?' 
                                       ELSE '' 
                                  END ,
                    ErrorTable  = CASE WHEN (SELECT ISNULL(A.TABLENAME,'') 
                                               FROM Sys.Tables B
                                              WHERE B.NAME=A.TABLENAME)=A.TABLENAME 
                                       THEN '' 
                                       ELSE '?' 
                                  END
               FROM AQDetailGrupim A
              WHERE ISNULL(A.VISIBLE,0)=1 --AND ISNULL(A.NOTACTIV,0)=0 
              
              ) A
              
    ORDER BY CASE WHEN ISNULL(A.NOTACTIV,0)=1 THEN 'zz' ELSE '' END,
             CASE WHEN ISNULL(A.FORMNAME,'')='' OR ISNULL(A.TABLENAME,'')='' THEN 'zz'+ISNULL(A.NRORDER,'') ELSE '' END,
             ISNULL(A.NRORDER,'zz');
             
GO
