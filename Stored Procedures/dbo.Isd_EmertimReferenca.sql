SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE          procedure [dbo].[Isd_EmertimReferenca]

(
  @pTableName      Varchar(50),
  @pTableRef       Varchar(50)
 )
 
AS

-- Gjen per cdo kod pershkrimin e parafert (pra ne superioret e kodit gjen ate qe egziston),
-- perdoret kur perdor kod si pjese kodi psh jo kod=605105 nga sql kthehet 605 dhe si emertim kodi duhet te mare ate te 605.
-- Pra ne raport marim 605 dhe pershkrimin e 605.
-- Perdoret tek raportet e liber te madh ku meret informacion (sidomos pivot) kod te permbledhura psh KOD=LEFT(KOD,2) 
-- apo te fitimi ku nuk meren kodet e departamenteve por e grupuar si kod=Left(Departament.Kod,2)
-- Ideja eshte qe ne kolona te Gridit pivot (para exportit ne excel) te mos punohet me kokat e kollones me kod, por te punohet me kokat e kollones me pershkrime.
-- Shiko ne kod: SysCmdInGrid.Pas


-- Shembull: Nderto @pTableName='#TMPREF':  SELECT KOD=LEFT(KOD,3) INTO #TMPREF FROM LLOGARI ORDER BY KOD; 
--      EXEC dbo.Isd_EmertimReferenca '#TMPREF','LLOGARI'

             
         SET NOCOUNT ON;


     DECLARE @sSql            nVarchar(MAX),
             @sTableRef        VARCHAR(30),
             @sTableName       VARCHAR(30);
    
         SET @sTableRef      = @pTableRef;
         SET @sTableName     = @pTableName;
        
          IF OBJECT_ID('TEMPDB..#TMPKOD') IS NOT NULL
             DROP TABLE #TMPKOD;        
            
         SET @sSql = '
      SELECT DISTINCT
             KOD             = A.KOD, 
             PERSHKRIM       = ISNULL((SELECT PERSHKRIM
                                         FROM '+@sTableRef+'
                                        WHERE KOD = (SELECT MAX(L2.KOD) FROM '+@sTableRef+' L2 WHERE CHARINDEX('',''+L2.KOD,'',''+A.KOD)>0 And L2.KOD<=A.KOD)),'''')

        FROM '+@sTableName+' A ';
   
      EXEC (@sSql);
      
               
GO
