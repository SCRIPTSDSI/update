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
--    Exec dbo.Isd_LinkMG03 @PWhere1,@PWhere2,@PDistinct

CREATE Procedure [dbo].[Isd_LinkMG03_Old]
(
  @PWhere1       Varchar(Max),
  @PWhere2       Varchar(Max),
  @PDistinct     Bit
 )

as

  Declare @Sql      nVarchar(Max),
          @SqlUn    nVarchar(Max),
          @Distinct Varchar(20),
          @Enter    nVarchar(10)

      Set NoCount Off

      Set @Enter  = Char(13)
      Set @Distinct = ''

      if  @PWhere1  = ''
          Set @PWhere1 = ' 1=1 '
      if  @PWhere2  = ''
          Set @PWhere2 = ' 1=1 '

      if  @PDistinct=1
          Set @Distinct = 'DISTINCT'

      Set @SqlUn    = '

    SELECT '+@Distinct+' 
           DOKUMENT=''TABLENAME'',KMAG,NRDOK,NRFRAKS,DATEDOK,KMAGRF,SHENIM1,SHENIM2,DST,
           KARTLLG,SASI=ROUND(SASI,3),
           KMAGLNKD,NRDOKLNKD,NRFRAKSLNKD,DATEDOKLNKD,A.NRRENDOR,
           NRLINK   = NRCOUNT, CODEERROR = 00,
           MSGERROR = Case When ABS(FDFHLIDHJE04.SASI)>=0.01 Then ''Mosperputhje ne Sasi per Artikujt'' Else ''Mosperputhje Artikujt ne Lidhja'' End 
      FROM TABLENAME A INNER JOIN FDFHLIDHJE04 ON KMAGLNK=KMAGLNKD AND 
                                                  ISNULL(NRDOKLNK,0)=ISNULL(NRDOKLNKD,0) AND 
                                                  ISNULL(NRFRAKSLNK,0)=ISNULL(NRFRAKSLNKD,0) AND 
                                                  DATEDOKLNK=DATEDOKLNKD 
     WHERE ABS(FDFHLIDHJE04.SASI)>=0.01 AND '+@PWhere1


      Set @Sql = Replace(Replace(@SqlUn,'TABLENAME','FD'),'00','01')+
                 @Enter+' UNION ALL '+@Enter+
                 Replace(Replace(@SqlUn,'TABLENAME','FH'),'00','02')

      Set @Sql = @Sql + @Enter+' ORDER BY CODEERROR,KMAG,NRDOK,NRFRAKS,DATEDOK '+@Enter 


    Print @Sql

     Exec (@Sql)
GO
