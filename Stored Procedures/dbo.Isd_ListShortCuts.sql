SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [dbo].[Isd_ListShortCuts]

AS


     DECLARE @sString VARCHAR(2000)


         SET @sString  = '
00, ,,Komanda Ndertim dokumenta,1,D|
01, Ctrl + N,,    Shtim,0,D|
02, Ctrl + D,,    Fshirje,0,D|
04, F2,,    Modifikim,0,D|
03, Ctrl + W, Ctrl + End,    Regjistrim,0,D|
05, F3,,    Afishim Reference,0,D|
06, F5,,    Refresh,0,D|
07, Ctrl + F,,    Kerkim,0,D|
08, Esc,,    Largim,0,D|
09, Page Up,,    Reshti Para,0,D|
10, Page Down,,    Reshti Pasardhes,0,D|
11, Ctrl + Page up,,    Reshti Pare,0,D|
12, Ctrl + Page Down,,    Reshti Fundit,0,D|


40, ,,Komanda Raportim te dhena,1,D|
41, F3,,    Zgjedhje filter nga lista,0,C|
42, Ctrl-F3,,    Zgjedhje filter nga menu,0,C|
43, F4,,    Alternim: Liste raporte <-> Filter,0,C|
44, F9,,    Afishim raport,0,C|


50, ,,Funksione te tjera,1,C|
51, Shift+Ctrl+F10,,    Instance tjeter F5,0,C|
51, Shift+Ctrl+F5,,    Kontroll Actions,0,C|

60, ,,Programe jashte F5,1,C|
62, Shift+Ctrl+C,,    Kalkulator,0,C|
63, Shift+Ctrl+I,,    Internet explorer,0,C|
64, Shift+Ctrl+G,,    Google Chrome,0,C|
65, Shift+Ctrl+E,,    Explorer,0,C|
66, Shift+Ctrl+W,,    Ms-Word,0,C|
67, Shift+Ctrl+L,,    Ms-Excel,0,C|';



         SET @sString  = REPLACE(REPLACE(@sString,CHAR(13),''),CHAR(10),'');


      SELECT NrOrder   = F1,
             ShortCut1 = F2,
             ShortCut2 = F3,
             Komanda   = CAST(F4 AS VARCHAR(40)),
             Funksioni = CAST(F2 + CASE WHEN ISNULL(F3,'')<>'' THEN ' / '+F3 ELSE '' END AS VARCHAR(35)),
             TRow      = CAST(F5 AS BIT),
             StatusCmd = F6
        FROM

           (
             SELECT SPLITET,
                    F1 = dbo.Isd_StringInListStr(SPLITET,1,','),
                    F2 = dbo.Isd_StringInListStr(SPLITET,2,','),
                    F3 = dbo.Isd_StringInListStr(SPLITET,3,','),
                    F4 = dbo.Isd_StringInListStr(SPLITET,4,','),
                    F5 = dbo.Isd_StringInListStr(SPLITET,5,','),
                    F6 = dbo.Isd_StringInListStr(SPLITET,6,',')
               FROM DBO.SPLIT (@SSTRING,'|')

                     ) A

  ORDER BY NrOrder;




GO
