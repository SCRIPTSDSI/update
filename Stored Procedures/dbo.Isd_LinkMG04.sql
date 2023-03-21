SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- declare @PWhere1     Varchar(Max),
--         @PWhere2     Varchar(Max),
--         @PDistinct   Bit 
--     Set @PWhere1   = ' (  DATEDOK>=DBO.DATEVALUE(''01/01/2012'') And   DATEDOK<=DBO.DATEVALUE(''21/09/2012'')) '
--     Set @PWhere2   = ''
--     Set @PDistinct = 1
--    Exec dbo.Isd_LinkMG04 @PWhere1,@PWhere2,@PDistinct


CREATE Procedure [dbo].[Isd_LinkMG04]
(
  @PWhere1       Varchar(Max),
  @PWhere2       Varchar(Max), -- Nuk perdoret
  @PDistinct     Bit
 )

AS

         SET NOCOUNT ON


     DECLARE @Sql          nVarchar(MAX),
             @SqlUn        nVarchar(MAX);

          IF @PWhere1 = ''
             SET @PWhere1 = ' 1=1 ';

-- Menyra me poshte shton errore sa te duash edhe pa union....

      SET @SqlUn    = '    

      SELECT DOKUMENT  = ''TABLENAME'',
             KMAG,NRDOK,NRFRAKS,DATEDOK,KMAGRF,KMAGLNK,ARTIKUJ='''',KARTLLG='''',
             A.NRRENDOR,
             CODEERROR = 01,
             MSGERROR  = ''Magazine Panjohur''
        FROM TABLENAME A 
       WHERE '+@PWhere1+' And
            (Not Exists (SELECT NRRENDOR KOD FROM MAGAZINA WHERE MAGAZINA.KOD=A.KMAG)) 

   UNION ALL

      SELECT DOKUMENT  = ''TABLENAME'',
             KMAG,NRDOK,NRFRAKS,DATEDOK,KMAGRF,KMAGLNK,ARTIKUJ='''',KARTLLG='''',
             A.NRRENDOR,
             CODEERROR = 02,
             MSGERROR  = ''MagazineRef. Panjohur''
        FROM TABLENAME A
       WHERE ISNULL(KMAGRF,'''')<>'''' And 
             '+@PWhere1+' And 
            (Not Exists (SELECT TOP 1 KOD FROM MAGAZINA WHERE MAGAZINA.KOD=A.KMAGRF))  

   UNION ALL 

      SELECT DOKUMENT  = ''TABLENAME'',
             KMAG,NRDOK,NRFRAKS,DATEDOK,KMAGRF,KMAGLNK,ARTIKUJ='''',KARTLLG='''',
             A.NRRENDOR,
             CODEERROR = 03,
             MSGERROR  = ''MagazineLnk. Panjohur''
        FROM TABLENAME A 
       WHERE ISNULL(KMAGLNK,'''')<>'''' And 
             '+@PWhere1+' And 
            (Not Exists (SELECT TOP 1 KOD FROM MAGAZINA WHERE MAGAZINA.KOD=A.KMAGLNK)) 

   UNION ALL 

      SELECT DOKUMENT  = ''TABLENAME'',
             KMAG,NRDOK,NRFRAKS,DATEDOK,KMAGRF,KMAGLNK,ARTIKUJ=KARTLLG,KARTLLG,
             A.NRRENDOR,
             CODEERROR = 04,
             MSGERROR  = ''Artikuj Panjohur''
        FROM TABLENAME A INNER JOIN TABLENAMESCR B ON A.NRRENDOR=B.NRD 
       WHERE '+@PWhere1+' And 
            (Not Exists (SELECT TOP 1 KOD FROM ARTIKUJ WHERE ARTIKUJ.KOD=B.KARTLLG)) ';




      SET @Sql   = REPLACE(@SqlUn,'TABLENAME','FD')+'
 
   UNION ALL '   + REPLACE(@SqlUn,'TABLENAME','FH')+'
   
    ORDER BY CODEERROR,DOKUMENT,KMAG,NRDOK,NRFRAKS,DATEDOK,ARTIKUJ; ';

       PRINT @Sql;
       EXEC (@Sql);


GO
