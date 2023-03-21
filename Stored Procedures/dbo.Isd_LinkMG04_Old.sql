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


CREATE Procedure [dbo].[Isd_LinkMG04_Old]
(
  @PWhere1       Varchar(Max),
  @PWhere2       Varchar(Max),
  @PDistinct     Bit
 )

as

      Set NoCount Off


  Declare @Sql      nVarchar(Max),
          @SqlUn    nVarchar(Max),
          @Enter    nVarchar(10)

      Set @Enter  = Char(13)

      if  @PWhere1  = ''
          Set @PWhere1 = ' 1=1 '
--    if  @PWhere2  = ''
--        Set @PWhere2 = ' 1=1 '

      Exec (' use TempDb
              if Exists (SELECT Name FROM Sys.Tables Where [Name]=''#LinkMg'')
   	             Drop Table #LinkMg ')


    SELECT DOKUMENT  = Replicate(' ',10),
           TABLENAME = Replicate(' ',100),
           KMAG      = Replicate(' ',20),
           NRDOK,
           NRFRAKS,
           DATEDOK,
           KMAGRF,
           KMAGLNK,
           ARTIKUJ   = Replicate(' ',100),
           NRRENDOR  = Cast(0 as Int),
           CODEERROR = Cast(0 as Bit),
           MSGERROR  = Replicate(' ',100)
      INTO #LinkMg 
      FROM FH
     WHERE 1=2


--      Set @SqlUn    = '    
--
--    SELECT DOKUMENT=''TABLENAME'',KMAG,NRDOK,NRFRAKS,DATEDOK,KMAGRF,KMAGLNK,ARTIKUJ='''',
--           A.NRRENDOR,CODEERROR=01,
--           MSGERROR=''Magazine Panjohur''
--      FROM TABLENAME A 
--     WHERE '+@PWhere1+' And
--           (Not Exists (SELECT TOP 1 KOD FROM MAGAZINA WHERE MAGAZINA.KOD=A.KMAG)) 
--
--  UNION ALL
--
--    SELECT DOKUMENT=''TABLENAME'',KMAG,NRDOK,NRFRAKS,DATEDOK,KMAGRF,KMAGLNK,ARTIKUJ='''',
--           A.NRRENDOR,CODEERROR=02,
--           MSGERROR=''MagazineRef. Panjohur''
--      FROM TABLENAME A
--     WHERE ISNULL(KMAGRF,'''')<>'''' And 
--           '+@PWhere1+' And 
--           (Not Exists (SELECT TOP 1 KOD FROM MAGAZINA WHERE MAGAZINA.KOD=A.KMAGRF))  
--
--  
--
--    SELECT DOKUMENT=''TABLENAME'',KMAG,NRDOK,NRFRAKS,DATEDOK,KMAGRF,KMAGLNK,ARTIKUJ='''',
--           A.NRRENDOR,CODEERROR=03,
--           MSGERROR=''MagazineLnk. Panjohur''
--      FROM TABLENAME A LEFT JOIN MAGAZINA ON KMAGLNK=MAGAZINA.KOD 
--     WHERE ISNULL(KMAGLNK,'''')<>'''' And 
--           '+@PWhere1+' And 
--           (Not Exists (SELECT TOP 1 KOD FROM MAGAZINA WHERE MAGAZINA.KOD=A.KMAGLNK)) 
--
-- 
--
--    SELECT DOKUMENT=''TABLENAME'',KMAG,NRDOK,NRFRAKS,DATEDOK,KMAGRF,KMAGLNK,ARTIKUJ=KARTLLG,
--           A.NRRENDOR,CODEERROR=04,
--           MSGERROR=''Artikuj Panjohur''
--      FROM TABLENAME A INNER JOIN TABLENAMESCR B ON A.NRRENDOR=B.NRD 
--     WHERE '+@PWhere1+' And 
--           (Not Exists (SELECT TOP 1 KOD FROM ARTIKUJ WHERE ARTIKUJ.KOD=B.KARTLLG)) '
--
--      Set @Sql = Replace(@SqlUn,'TABLENAME','FD')+
--                 @Enter+' UNION ALL '+@Enter+
--                 Replace(@SqlUn,'TABLENAME','FH')+@Enter+'
--           ORDER BY CODEERROR,KMAG,NRDOK,NRFRAKS,DATEDOK,ARTIKUJ '+@Enter 
--
--    Print @Sql
--
--     Exec (@Sql)


-- Menyra me poshte shton errore sa te duash edhe pa union....

      Set @SqlUn    = '    

    SELECT DOKUMENT=''TABLENAME'',KMAG,NRDOK,NRFRAKS,DATEDOK,KMAGRF,KMAGLNK,ARTIKUJ='''',
           A.NRRENDOR,CODEERROR=01,
           MSGERROR=''Magazine Panjohur''
      FROM TABLENAME A 
     WHERE '+@PWhere1+' And
           (Not Exists (SELECT TOP 1 KOD FROM MAGAZINA WHERE MAGAZINA.KOD=A.KMAG)) 

 UNION ALL

    SELECT DOKUMENT=''TABLENAME'',KMAG,NRDOK,NRFRAKS,DATEDOK,KMAGRF,KMAGLNK,ARTIKUJ='''',
           A.NRRENDOR,CODEERROR=02,
           MSGERROR=''MagazineRef. Panjohur''
      FROM TABLENAME A
     WHERE ISNULL(KMAGRF,'''')<>'''' And 
           '+@PWhere1+' And 
           (Not Exists (SELECT TOP 1 KOD FROM MAGAZINA WHERE MAGAZINA.KOD=A.KMAGRF))  

 UNION ALL 

    SELECT DOKUMENT=''TABLENAME'',KMAG,NRDOK,NRFRAKS,DATEDOK,KMAGRF,KMAGLNK,ARTIKUJ='''',
           A.NRRENDOR,CODEERROR=03,
           MSGERROR=''MagazineLnk. Panjohur''
      FROM TABLENAME A LEFT JOIN MAGAZINA ON KMAGLNK=MAGAZINA.KOD 
     WHERE ISNULL(KMAGLNK,'''')<>'''' And 
           '+@PWhere1+' And 
           (Not Exists (SELECT TOP 1 KOD FROM MAGAZINA WHERE MAGAZINA.KOD=A.KMAGLNK)) 

 UNION ALL 

    SELECT DOKUMENT=''TABLENAME'',KMAG,NRDOK,NRFRAKS,DATEDOK,KMAGRF,KMAGLNK,ARTIKUJ=KARTLLG,
           A.NRRENDOR,CODEERROR=04,
           MSGERROR=''Artikuj Panjohur''
      FROM TABLENAME A INNER JOIN TABLENAMESCR B ON A.NRRENDOR=B.NRD 
     WHERE '+@PWhere1+' And 
           (Not Exists (SELECT TOP 1 KOD FROM ARTIKUJ WHERE ARTIKUJ.KOD=B.KARTLLG))  '

      Set @Sql = Replace(@SqlUn,'TABLENAME','FD')+
                 @Enter+' UNION ALL '+@Enter+
                 Replace(@SqlUn,'TABLENAME','FH')


      Set @Sql = '  
  
    INSERT INTO #LinkMG 
          (DOKUMENT,KMAG,NRDOK,NRFRAKS,DATEDOK,KMAGRF,KMAGLNK,ARTIKUJ,
           NRRENDOR,CODEERROR,MSGERROR)

    SELECT DOKUMENT,KMAG,NRDOK,NRFRAKS,DATEDOK,KMAGRF,KMAGLNK,ARTIKUJ,
           NRRENDOR,CODEERROR,MSGERROR
      FROM 

  ('+@Sql+'

   ) A 


  ORDER BY CODEERROR,KMAG,NRDOK,NRFRAKS,DATEDOK,ARTIKUJ '+@Enter 


    Print @Sql
     Exec (@Sql)
--
-- Shto dhe teste te tjera me kete strukture ....
--

  Select *
    From #LinkMg
Order By CODEERROR,KMAG,NRDOK,NRFRAKS,DATEDOK,ARTIKUJ

GO
