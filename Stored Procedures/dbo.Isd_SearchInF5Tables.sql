SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE PROC [dbo].[Isd_SearchInF5Tables]
(
      @Documents    As VarChar(100),
      @StringSearch As VarChar(250),
      @Filters      As NVarChar(100)
)
As
-- Exec Dbo.Isd_SearchInF5Tables 'DG ,AR ,BA ,','BLERJE','A'
-- Exec Dbo.Isd_SearchInF5Tables '*DB','BLERJE','A' -- Te gjithe DB

--
-- -- Parameters
--    Declare @Documents    As VarChar(100)
--    Declare @StringSearch As VarChar(250)
--    Set @Documents    = 'A' --'ABETHDFS'            
--    Set @StringSearch = 'DUKA'
-- -- Fund Parametra

Begin
--DROP TABLE #SearchTmp

CREATE TABLE #SearchTmp (NRRENDOR int,
                         TABELA   NVarChar(100), 
                         KOLONA   NVarChar(370), 
                         VLERA    NVarChar(3630),
                         POZICION VarChar(10))

Declare @ListTables  NVarchar(1000)
Declare @OrgDocs     VarChar(100)
Declare @SQLText     NVarChar(Max)
Declare @Where       VarChar(200)
Declare @VDoc        VarChar(100)
Declare @VOrg        VarChar(3)
Declare @ListSearch  NVarChar(Max)
Declare @i           Int
Declare @Tabela      VarChar(100)

Set @ListSearch = ''
Set @OrgDocs    = 'AR ,BA ,VS ,FK ,FH ,FD ,FF ,FJ ,DG ,VSS,FKS,ORK,ORF,OFK,FJT'
Set @ListTables = 'ARKA ,BANKA,VS   ,FK   ,FH   ,FD   ,FF   ,FJ   ,DG   ,VSST ,FKST ,ORK  ,ORF  ,OFK  ,FJT  ,'

-- Gjenerimi i Listes se Tabelave per Kerkim....
Set   @VDoc = @Documents

Set @i = 0
While Len(@VDoc)>0
  Begin
    Set @VOrg = SubString(@VDoc,1,3)
    if Len(@VDoc)<=3
       Set @VDoc = ''
    else
       Set @VDoc = SubString(@VDoc,5,Len(@VDoc))

    Set @i          = ((CharIndex(@VOrg,@OrgDocs)+3)/4)
    Set @Tabela     = LTrim(RTrim(SubString(@ListTables,(6*@i)-5,5)))
    Set @ListSearch = @ListSearch + ','+@Tabela + ',' + @Tabela  + 'Scr'
  End 

Set   @ListSearch = Upper(@ListSearch)


--Print @ListSearch
--Print @StringSearch

if  @Documents='*DB'
    Begin
      Set   @ListSearch = dbo.AllTables()
      Print @ListSearch
    --Print @StringSearch
      Exec  KerkoTeGjitha @StringSearch, @ListSearch, 'BASE TABLE', '#SearchTmp'
      Set @SQLText = 
'  SELECT  DOKUMENT=TABELA,ORG='''',MASTER='''',DATEDOK=CAST(NULL AS DATETIME),
           SHENIM1='''',SHENIM2='''',
           NUMDOK=0,NRFRAKS=0,TIPDOK='''',
           KMON='''',VLERA=0,VLERAMV=0,REFERENCE='''',KMAG='''',
           NRORD=1,
           KERKIMI =VLERA, FUSHA=KOLONA, POZICION,NRRENDOR,
           SHENIM  =''''
     FROM  #SearchTmp
 ORDER BY DOKUMENT,FUSHA
'
      Exec (@SQLText)
    --Exec ('SELECT * FROM #SearchTmp ')
      Return
    End

Exec KerkoTeGjitha @StringSearch, @ListSearch, 'BASE TABLE', '#SearchTmp'
Set @Where   = ''

Set @SQLText =
' --SELECT * FROM #SearchTmp


   SELECT  DOKUMENT=''ARKA'',ORG=''A'',MASTER=B.KODAB,B.DATEDOK,
           B.SHENIM1,B.SHENIM2,
           B.NUMDOK,NRFRAKS=0,B.TIPDOK,
           B.KMON,B.VLERA,B.VLERAMV,REFERENCE=B.KODAB,KMAG='''',
           NRORD=1,
           KERKIMI =A.VLERA, FUSHA=A.KOLONA, A.POZICION,A.NRRENDOR,
           SHENIM  =Case When POZICION=''M'' Then ''Ne Dokument'' Else ''Ne Detaje'' End
     FROM  #SearchTmp A INNER JOIN ARKA B ON A.NRRENDOR=B.NRRENDOR 
    WHERE  (CHARINDEX(''[ARKA]'',   A.TABELA)<>0 OR CHARINDEX(''[ARKASCR]'',A.TABELA)<>0) AND 
           1=11

UNION ALL

   SELECT  DOKUMENT=''BANKA'',ORG=''B'',MASTER=B.KODAB,B.DATEDOK,
           B.SHENIM1,B.SHENIM2,
           B.NUMDOK,NRFRAKS=0,B.TIPDOK,
           B.KMON,B.VLERA,B.VLERAMV,REFERENCE=B.KODAB,KMAG='''',
           NRORD=2,
           KERKIMI =A.VLERA, FUSHA=A.KOLONA, A.POZICION,A.NRRENDOR,
           SHENIM  =Case When POZICION=''M'' Then ''Ne Dokument'' Else ''Ne Detaje'' End
     FROM  #SearchTmp A INNER JOIN BANKA B ON A.NRRENDOR=B.NRRENDOR 
    WHERE  (CHARINDEX(''[BANKA]'',   A.TABELA)<>0 OR CHARINDEX(''[BANKASCR]'',A.TABELA)<>0) AND 
           1=12

UNION ALL

   SELECT  DOKUMENT=''FK'',ORG=''T'',MASTER='''',B.DATEDOK,
           SHENIM1=B.PERSHKRIM1, SHENIM2=B.PERSHKRIM2,
           B.NUMDOK,NRFRAKS=0,B.TIPDOK,
           KMON='''',VLERA=0,VLERAMV=0,REFERENCE=B.REFERDOK,ISNULL(B.KMAG,''''),
           NRORD=3,
           KERKIMI =A.VLERA, FUSHA=A.KOLONA, A.POZICION,A.NRRENDOR,
           SHENIM  =Case When POZICION=''M'' Then ''Ne Dokument'' Else ''Ne Detaje'' End
     FROM  #SearchTmp A INNER JOIN FK B ON A.NRRENDOR=B.NRRENDOR 
    WHERE  (CHARINDEX(''[FK]'',   A.TABELA)<>0 OR CHARINDEX(''[FKSCR]'',A.TABELA)<>0) AND 
           1=13

UNION ALL

    SELECT DOKUMENT=''VS'',ORG=''E'',MASTER='''',B.DATEDOK,
           SHENIM1=B.PERSHKRIM1, SHENIM2=B.PERSHKRIM2,
           NUMDOK =B.NRDOK, NRFRAKS=0, TIPDOK=''VS'',
           KMON='''',VLERA=0,VLERAMV=0,REFERENCE='''',KMAG='''',
           NRORD=4,
           KERKIMI =A.VLERA, FUSHA=A.KOLONA, A.POZICION,A.NRRENDOR,
           SHENIM  =Case When POZICION=''M'' Then ''Ne Dokument'' Else ''Ne Detaje'' End
     FROM  #SearchTmp A INNER JOIN VS B ON A.NRRENDOR=B.NRRENDOR 
    WHERE  (CHARINDEX(''[VS]'',   A.TABELA)<>0 OR CHARINDEX(''[VSSCR]'',A.TABELA)<>0) AND 
           1=14

UNION ALL

   SELECT  DOKUMENT=''FKST'',ORG=''FKST'',MASTER='''',B.DATEDOK,
           SHENIM1=B.PERSHKRIM1, SHENIM2=B.PERSHKRIM2,
           B.NUMDOK,NRFRAKS=0,B.TIPDOK,
           KMON='''',VLERA=0,VLERAMV=0,REFERENCE=B.REFERDOK,ISNULL(B.KMAG,''''),
           NRORD=51,
           KERKIMI =A.VLERA, FUSHA=A.KOLONA, A.POZICION,A.NRRENDOR,
           SHENIM  =Case When POZICION=''M'' Then ''Ne Dokument'' Else ''Ne Detaje'' End
     FROM  #SearchTmp A INNER JOIN FKST B ON A.NRRENDOR=B.NRRENDOR 
    WHERE  (CHARINDEX(''[FKST]'',   A.TABELA)<>0 OR CHARINDEX(''[FKSTSCR]'',A.TABELA)<>0) AND 
           1=51

UNION ALL

    SELECT DOKUMENT=''VSST'',ORG=''VSST'',MASTER='''',B.DATEDOK,
           SHENIM1=B.PERSHKRIM1, SHENIM2=B.PERSHKRIM2,
           NUMDOK =B.NRDOK, NRFRAKS=0, TIPDOK=''VSST'',
           KMON='''',VLERA=0,VLERAMV=0,REFERENCE='''',KMAG='''',
           NRORD=52,
           KERKIMI =A.VLERA, FUSHA=A.KOLONA, A.POZICION,A.NRRENDOR,
           SHENIM  =Case When POZICION=''M'' Then ''Ne Dokument'' Else ''Ne Detaje'' End
     FROM  #SearchTmp A INNER JOIN VSST B ON A.NRRENDOR=B.NRRENDOR 
    WHERE  (CHARINDEX(''[VSST]'',   A.TABELA)<>0 OR CHARINDEX(''[VSSTSCR]'',A.TABELA)<>0) AND 
           1=52


-- Magazinat dhe Faturimet

UNION ALL

    SELECT DOKUMENT=''FH'',ORG=''H'',MASTER=B.KMAG,B.DATEDOK,
           B.SHENIM1, B.SHENIM2,
           NUMDOK =B.NRDOK, B.NRFRAKS, TIPDOK=''FH'',
           KMON='''',VLERA=0,VLERAMV=0,REFERENCE='''',B.KMAG,
           NRORD=21,
           KERKIMI =A.VLERA, FUSHA=A.KOLONA, A.POZICION,A.NRRENDOR,
           SHENIM  =Case When POZICION=''M'' Then ''Ne Dokument'' Else ''Ne Detaje'' End
     FROM  #SearchTmp A INNER JOIN FH B ON A.NRRENDOR=B.NRRENDOR 
    WHERE  (CHARINDEX(''[FH]'',   A.TABELA)<>0 OR CHARINDEX(''[FHSCR]'',A.TABELA)<>0) AND 
           1=21

UNION ALL

    SELECT DOKUMENT=''FD'',ORG=''D'',MASTER=B.KMAG,B.DATEDOK,
           B.SHENIM1, B.SHENIM2,
           NUMDOK =B.NRDOK, B.NRFRAKS, TIPDOK=''FD'',
           KMON='''',VLERA=0,VLERAMV=0,REFERENCE='''',B.KMAG,
           NRORD=22,
           KERKIMI =A.VLERA, FUSHA=A.KOLONA, A.POZICION,A.NRRENDOR,
           SHENIM  =Case When POZICION=''M'' Then ''Ne Dokument'' Else ''Ne Detaje'' End
     FROM  #SearchTmp A INNER JOIN FD B ON A.NRRENDOR=B.NRRENDOR 
    WHERE  (CHARINDEX(''[FD]'',   A.TABELA)<>0 OR CHARINDEX(''[FDSCR]'',A.TABELA)<>0) AND 
           1=22

UNION ALL

    SELECT DOKUMENT=''FF'',ORG=''F'',MASTER='''',B.DATEDOK,
           B.SHENIM1, B.SHENIM2,
           NUMDOK =B.NRDOK, B.NRFRAKS, TIPDOK=''FF'',
           B.KMON,VLERA=VLERTOT,VLERAMV=ROUND(VLERTOT*KURS2/KURS1,2),REFERENCE=B.KODFKL,B.KMAG,
           NRORD=31,
           KERKIMI =A.VLERA, FUSHA=A.KOLONA, A.POZICION,A.NRRENDOR,
           SHENIM  =Case When POZICION=''M'' Then ''Ne Dokument'' Else ''Ne Detaje'' End
     FROM  #SearchTmp A INNER JOIN FF B ON A.NRRENDOR=B.NRRENDOR 
    WHERE  (CHARINDEX(''[FF]'',   A.TABELA)<>0 OR CHARINDEX(''[FFSCR]'',A.TABELA)<>0) AND 
           1=31

UNION ALL

   SELECT  DOKUMENT=''DG'',ORG=''G'',MASTER='''',B.DATEDOK,
           B.SHENIM1, B.SHENIM2,
           NUMDOK =B.NRDOK, B.NRFRAKS, TIPDOK=''DG'',
           B.KMON,VLERA=0,VLERAMV=0,REFERENCE=B.KOD,KMAG='''',
           NRORD=32,
           KERKIMI =A.VLERA, FUSHA=A.KOLONA, A.POZICION,A.NRRENDOR,
           SHENIM  =Case When POZICION=''M'' Then ''Ne Dokument'' Else ''Ne Detaje'' End
     FROM  #SearchTmp A INNER JOIN DG B ON A.NRRENDOR=B.NRRENDOR 
    WHERE  (CHARINDEX(''[DG]'',   A.TABELA)<>0 OR CHARINDEX(''[DGSCR]'',A.TABELA)<>0) AND 
           1=32

UNION ALL

    SELECT DOKUMENT=''ORF'',ORG=''ORF'',MASTER='''',B.DATEDOK,
           B.SHENIM1, B.SHENIM2,
           NUMDOK =B.NRDOK, B.NRFRAKS, TIPDOK=''ORF'',
           B.KMON,VLERA=VLERTOT,VLERAMV=ROUND(VLERTOT*KURS2/KURS1,2),REFERENCE=B.KODFKL,B.KMAG,
           NRORD=33,
           KERKIMI =A.VLERA, FUSHA=A.KOLONA, A.POZICION,A.NRRENDOR,
           SHENIM  =Case When POZICION=''M'' Then ''Ne Dokument'' Else ''Ne Detaje'' End
     FROM  #SearchTmp A INNER JOIN ORF B ON A.NRRENDOR=B.NRRENDOR 
    WHERE  (CHARINDEX(''[ORF]'',   A.TABELA)<>0 OR CHARINDEX(''[ORFSCR]'',A.TABELA)<>0) AND 
           1=33

UNION ALL

    SELECT DOKUMENT=''FJ'',ORG=''S'',MASTER='''',B.DATEDOK,
           B.SHENIM1, B.SHENIM2,
           NUMDOK =B.NRDOK, B.NRFRAKS, TIPDOK=''FJ'',
           B.KMON,VLERA=VLERTOT,VLERAMV=ROUND(VLERTOT*KURS2/KURS1,2),REFERENCE=B.KODFKL,B.KMAG,
           NRORD=41,
           KERKIMI =A.VLERA, FUSHA=A.KOLONA, A.POZICION,A.NRRENDOR,
           SHENIM  =Case When POZICION=''M'' Then ''Ne Dokument'' Else ''Ne Detaje'' End
     FROM  #SearchTmp A INNER JOIN FJ B ON A.NRRENDOR=B.NRRENDOR 
    WHERE  (CHARINDEX(''[FJ]'',   A.TABELA)<>0 OR CHARINDEX(''[FJSCR]'',A.TABELA)<>0) AND 
           1=41

UNION ALL

    SELECT DOKUMENT=''OFK'',ORG=''OFK'',MASTER='''',B.DATEDOK,
           B.SHENIM1, B.SHENIM2,
           NUMDOK =B.NRDOK, B.NRFRAKS, TIPDOK=''OFK'',
           B.KMON,VLERA=VLERTOT,VLERAMV=ROUND(VLERTOT*KURS2/KURS1,2),REFERENCE=B.KODFKL,B.KMAG,
           NRORD=42,
           KERKIMI =A.VLERA, FUSHA=A.KOLONA, A.POZICION,A.NRRENDOR,
           SHENIM  =Case When POZICION=''M'' Then ''Ne Dokument'' Else ''Ne Detaje'' End
     FROM  #SearchTmp A INNER JOIN OFK B ON A.NRRENDOR=B.NRRENDOR 
    WHERE  (CHARINDEX(''[OFK]'',   A.TABELA)<>0 OR CHARINDEX(''[OFKSCR]'',A.TABELA)<>0) AND 
           1=42

UNION ALL

    SELECT DOKUMENT=''ORK'',ORG=''ORK'',MASTER='''',B.DATEDOK,
           B.SHENIM1, B.SHENIM2,
           NUMDOK =B.NRDOK, B.NRFRAKS, TIPDOK=''ORK'',
           B.KMON,VLERA=VLERTOT,VLERAMV=ROUND(VLERTOT*KURS2/KURS1,2),REFERENCE=B.KODFKL,B.KMAG,
           NRORD=43,
           KERKIMI =A.VLERA, FUSHA=A.KOLONA, A.POZICION,A.NRRENDOR,
           SHENIM  =Case When POZICION=''M'' Then ''Ne Dokument'' Else ''Ne Detaje'' End
     FROM  #SearchTmp A INNER JOIN ORK B ON A.NRRENDOR=B.NRRENDOR 
    WHERE  (CHARINDEX(''[ORK]'',   A.TABELA)<>0 OR CHARINDEX(''[ORKSCR]'',A.TABELA)<>0) AND 
           1=43

UNION ALL

    SELECT DOKUMENT=''FJT'',ORG=''FJT'',MASTER='''',B.DATEDOK,
           B.SHENIM1, B.SHENIM2,
           NUMDOK =B.NRDOK, B.NRFRAKS, TIPDOK=''ORK'',
           B.KMON,VLERA=VLERTOT,VLERAMV=ROUND(VLERTOT*KURS2/KURS1,2),REFERENCE=B.KODFKL,B.KMAG,
           NRORD=44,
           KERKIMI =A.VLERA, FUSHA=A.KOLONA, A.POZICION,A.NRRENDOR,
           SHENIM  =Case When POZICION=''M'' Then ''Ne Dokument'' Else ''Ne Detaje'' End
     FROM  #SearchTmp A INNER JOIN FJT B ON A.NRRENDOR=B.NRRENDOR 
    WHERE  (CHARINDEX(''[FJT]'',   A.TABELA)<>0 OR CHARINDEX(''[FJTSCR]'',A.TABELA)<>0) AND 
           1=44

UNION ALL

    SELECT DOKUMENT=''SM'',ORG=''SM'',MASTER='''',B.DATEDOK,
           B.SHENIM1, B.SHENIM2,
           NUMDOK =B.NRDOK, B.NRFRAKS, TIPDOK=''ORK'',
           B.KMON,VLERA=VLERTOT,VLERAMV=ROUND(VLERTOT*KURS2/KURS1,2),REFERENCE=B.KODFKL,B.KMAG,
           NRORD=45,
           KERKIMI =A.VLERA, FUSHA=A.KOLONA, A.POZICION,A.NRRENDOR,
           SHENIM  =Case When POZICION=''M'' Then ''Ne Dokument'' Else ''Ne Detaje'' End
     FROM  #SearchTmp A INNER JOIN SM B ON A.NRRENDOR=B.NRRENDOR 
    WHERE  (CHARINDEX(''[SM]'',   A.TABELA)<>0 OR CHARINDEX(''[SMSCR]'',A.TABELA)<>0) AND 
           1=45


ORDER BY NRORD,ORG,MASTER,DATEDOK,TIPDOK,NUMDOK,NRFRAKS

'

-- LM
 if CharIndex('AR ,',@Documents)>0
    Set @SQLText = Replace(@SQLText,'1=11','1=1')
 if CharIndex('BA ,',@Documents)>0
    Set @SQLText = Replace(@SQLText,'1=12','1=1')
 if CharIndex('FK ,',@Documents)>0
    Set @SQLText = Replace(@SQLText,'1=13','1=1')
 if CharIndex('VS ,',@Documents)>0
    Set @SQLText = Replace(@SQLText,'1=14','1=1')
 if CharIndex('FKS,',@Documents)>0
    Set @SQLText = Replace(@SQLText,'1=51','1=1')
 if CharIndex('VSS,',@Documents)>0
    Set @SQLText = Replace(@SQLText,'1=52','1=1')

-- Magazina
 if CharIndex('FH ,',@Documents)>0
    Set @SQLText = Replace(@SQLText,'1=21','1=1')
 if CharIndex('FD ,',@Documents)>0
    Set @SQLText = Replace(@SQLText,'1=22','1=1')

-- Blerja
 if CharIndex('FF ,',@Documents)>0
    Set @SQLText = Replace(@SQLText,'1=31','1=1')
 if CharIndex('DG ,',@Documents)>0
    Set @SQLText = Replace(@SQLText,'1=32','1=1')
 if CharIndex('ORF,',@Documents)>0
    Set @SQLText = Replace(@SQLText,'1=33','1=1')

-- Shitja
 if CharIndex('FJ ,',@Documents)>0
    Set @SQLText = Replace(@SQLText,'1=41','1=1')
 if CharIndex('OFK,',@Documents)>0
    Set @SQLText = Replace(@SQLText,'1=42','1=1')
 if CharIndex('ORK,',@Documents)>0
    Set @SQLText = Replace(@SQLText,'1=43','1=1')
 if CharIndex('FJT,',@Documents)>0
    Set @SQLText = Replace(@SQLText,'1=44','1=1')
 if CharIndex('SM ,',@Documents)>0
    Set @SQLText = Replace(@SQLText,'1=45','1=1')

 Exec (@SQLText)

End





GO
