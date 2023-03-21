SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






--Exec [Dbo].[Isd_KodChangeArtikuj]

CREATE Procedure [dbo].[Isd_KodChangeArtikuj]
As
Declare @TableName    Varchar(100),
        @SqlFilter00  Varchar(Max),
        @SqlFilter01  Varchar(Max)
        

--       Exec  ('USE TEMPDB
--              if Exists (SELECT NAME FROM Sys.Objects Where Object_Id=Object_Id(''#KODART''))
--				 DROP TABLE #KODART ')

      if Object_Id('#KODART') is not null
		 DROP TABLE #KODART
			  
      SELECT KOD,KODNEW,TROW,TAGNR
        INTO #KODART
        FROM KODCHANGE A
       WHERE TIPKLL='ART' AND 
            (ISNULL(KOD,'')<>'' AND ISNULL(KODNEW,'')<>'') AND
            (KOD<>KODNEW) AND
            (NOT (EXISTS (SELECT KOD FROM ARTIKUJ B WHERE B.KOD=A.KODNEW)))
    ORDER BY KOD

       if IsNull((SELECT TOP 1 1 FROM #KODART),0)=0
          Return 


       Set @TableName  = '#KODART'

       Set @SqlFilter00 = '
			UPDATE B
			   SET B.KARTLLG = C.KODNEW,
				   B.KODAF   = Dbo.Isd_SegmentChange(B.KODAF,C.KODNEW,0),
				   B.KOD     = A.KMAG  +''.''+
                               C.KODNEW+''.''+
                               Dbo.Isd_SegmentFind(B.KODAF,0,2)+''.''+
                               Dbo.Isd_SegmentFind(B.KODAF,0,3)+''.''
			  FROM FH A INNER JOIN FHSCR   B ON A.NRRENDOR = B.NRD
						INNER JOIN '+@TableName+' C ON B.KARTLLG  = C.KOD
              WHERE 1=1 '

-- Fh
       Set   @SqlFilter01 = @SqlFilter00
       Exec (@SqlFilter01)

-- Fd
       Set   @SqlFilter01 = Replace(@SQLFilter00,' FH',' FD')
       Exec (@SqlFilter01)

-- Fj
       Set   @SqlFilter01 = Replace(@SQLFilter00,' FH',' FJ')
       Set   @SqlFilter01 = Replace(@SQLFilter01,' 1=1 ',' TIPKLL=''K'' ')
       Exec (@SqlFilter01)

-- Ff
       Set   @SqlFilter01 = Replace(@SQLFilter00,' FH',' FF')
       Set   @SqlFilter01 = Replace(@SQLFilter01,' 1=1 ',' TIPKLL=''K'' ')
       Exec (@SqlFilter01)

-- OFK
       Set   @SqlFilter01 = Replace(@SQLFilter00,' FH',' OFK')
       Set   @SqlFilter01 = Replace(@SQLFilter01,' 1=1 ',' TIPKLL=''K'' ')
       Exec (@SqlFilter01)

-- ORK
       Set   @SqlFilter01 = Replace(@SQLFilter00,' FH',' ORK')
       Set   @SqlFilter01 = Replace(@SQLFilter01,' 1=1 ',' TIPKLL=''K'' ')
       Exec (@SqlFilter01)

-- ORF
       Set   @SqlFilter01 = Replace(@SQLFilter00,' FH',' ORF')
       Set   @SqlFilter01 = Replace(@SQLFilter01,' 1=1 ',' TIPKLL=''K'' ')
       Exec (@SqlFilter01)

-- SM
       Set   @SqlFilter01 = Replace(@SQLFilter00,' FH',' SM')
       Set   @SqlFilter01 = Replace(@SQLFilter01,' 1=1 ',' TIPKLL=''K'' ')
       Exec (@SqlFilter01)

-- FJT
       Set   @SqlFilter01 = Replace(@SQLFilter00,' FH',' FJT')
       Set   @SqlFilter01 = Replace(@SQLFilter01,' 1=1 ',' TIPKLL=''K'' ')
       Exec (@SqlFilter01)


-- ArtikujScr
       Set   @SqlFilter00 = '
			UPDATE A
			   SET A.KOD = B.KODNEW
			  FROM ARTIKUJSCR A INNER JOIN '+@TableName+' B ON A.KOD = B.KOD '
       Set   @SqlFilter01 = @SQLFilter00
       Exec (@SqlFilter01)

-- ArtikujSist
       Set   @SqlFilter01 = Replace(@SQLFilter00,' ARTIKUJSCR ',' ARTIKUJSIST ')
       Exec (@SqlFilter01)

-- ArtikujCM
       Set   @SqlFilter01 = Replace(@SQLFilter00,' ARTIKUJSCR ',' ARTIKUJCM ')
       Exec (@SqlFilter01)

-- ArtikujCMF
       Set   @SqlFilter01 = Replace(@SQLFilter00,' ARTIKUJSCR ',' ARTIKUJCMF ')
       Exec (@SqlFilter01)

-- ArtikujCMIME
       Set   @SqlFilter01 = Replace(@SQLFilter00,' ARTIKUJSCR ',' ARTIKUJCMIME ')
       Exec (@SqlFilter01)

-- Artikuj
       Set   @SqlFilter01 = Replace(@SQLFilter00,' ARTIKUJSCR ',' ARTIKUJ ')
       Exec (@SqlFilter01)

-- Klient Cmime
       Set   @SqlFilter01 = Replace(@SQLFilter00,' ARTIKUJSCR ',' KLIENTCM ')
       Exec (@SqlFilter01)

-- LMG
       Set   @SqlFilter01 = 
             'UPDATE A 
                 SET SG2=B.KODNEW ,
                     KOD=SG1+''.''+B.KODNEW+''.''+ISNULL(SG3,'''')+''.''+ISNULL(SG4,'''')+''.''
                FROM LMG A INNER JOIN '+@TableName+' B ON A.SG2 = B.KOD '
       Exec (@SqlFilter01)





GO
