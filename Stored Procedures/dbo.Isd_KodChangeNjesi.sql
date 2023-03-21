SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






--Exec [Dbo].[Isd_KodChangeNjesi]

CREATE Procedure [dbo].[Isd_KodChangeNjesi]

As

     Declare @TableName    Varchar(100),
             @SqlFilter00  Varchar(Max),
             @SqlFilter01  Varchar(Max);
        

--      Exec ('USE TEMPDB
--              if Exists (SELECT NAME FROM Sys.Objects Where Object_Id=Object_Id(''#KODNJESI''))
--				   DROP TABLE #KODNJESI ')

          if Object_Id('#KODNJESI') is not null
		     DROP TABLE #KODNJESI;
			  
      SELECT KOD,KODNEW,TROW,TAGNR
        INTO #KODNJESI
        FROM KODCHANGE A
       WHERE TIPKLL='NJ ' AND 
            (ISNULL(KOD,'')<>'' AND ISNULL(KODNEW,'')<>'') AND
            (KOD<>KODNEW) AND
            (NOT (EXISTS (SELECT KOD FROM NJESI B WHERE B.KOD=A.KODNEW)))
    ORDER BY KOD;

--          if IsNull((SELECT TOP 1 1 FROM #KODNJESI),0)=0
--             Return ;


       Set @TableName  = '#KODNJESI'

       Set @SqlFilter00 = '
			UPDATE B
			   SET B.NJESI = C.KODNEW
			  FROM FHSCR B INNER JOIN '+@TableName+' C ON B.NJESI = C.KOD
             WHERE 1=1 

			UPDATE B
			   SET B.NJESINV = C.KODNEW
			  FROM FHSCR B INNER JOIN '+@TableName+' C ON B.NJESINV = C.KOD
             WHERE 1=1 ';


-- Fh
       Set   @SqlFilter01 = @SqlFilter00
       Exec (@SqlFilter01);

-- Print @SqlFilter01;

-- Fd
       Set   @SqlFilter01 = Replace(@SQLFilter00,' FHSCR',' FDSCR');
       Exec (@SqlFilter01);

-- Fj
       Set   @SqlFilter01 = Replace(@SQLFilter00,' FHSCR',' FJSCR');
       Exec (@SqlFilter01);

-- Ff
       Set   @SqlFilter01 = Replace(@SQLFilter00,' FHSCR',' FFSCR')
       Exec (@SqlFilter01);

-- OFK
       Set   @SqlFilter01 = Replace(@SQLFilter00,' FHSCR',' OFKSCR')
       Exec (@SqlFilter01);

-- ORK
       Set   @SqlFilter01 = Replace(@SQLFilter00,' FHSCR',' ORKSCR')
       Exec (@SqlFilter01);

-- ORF
       Set   @SqlFilter01 = Replace(@SQLFilter00,' FHSCR',' ORFSCR')
       Exec (@SqlFilter01);

-- SM
       Set   @SqlFilter01 = Replace(@SQLFilter00,' FHSCR',' SMSCR')
       Exec (@SqlFilter01);

-- FJT
       Set   @SqlFilter01 = Replace(@SQLFilter00,' FHSCR',' FJTSCR')
       Exec (@SqlFilter01);

-- SMBAK
       Set   @SqlFilter01 = Replace(@SQLFilter00,' FHSCR',' SMBAKSCR')
       Exec (@SqlFilter01);



       Set   @SqlFilter00 = '
			UPDATE A
			   SET A.NJESI = B.KODNEW
			  FROM ARTIKUJ A INNER JOIN '+@TableName+' B ON A.NJESI = B.KOD 
             WHERE 1=1 ';
-- Artikuj
       Set   @SqlFilter01 = @SQLFilter00;
       Exec (@SqlFilter01);

-- DG
       Set   @SqlFilter01 = Replace(@SQLFilter00,' ARTIKUJ ',' DGSCR ')
       Exec (@SqlFilter01);


-- ArtikujCM
       Set   @SqlFilter01 = Replace(@SQLFilter00,' FHSCR ',' ARTIKUJCM ')
       Exec (@SqlFilter01);


-- ArtikujKFScr
       Set   @SqlFilter01 = Replace(@SQLFilter00,' ARTIKUJ ',' ARTIKUJKFSCR ')
       Exec (@SqlFilter01);

-- OrderItemsScr
       Set   @SqlFilter01 = Replace(@SQLFilter00,' ARTIKUJ ',' ORDERITEMSSCR ')
       Exec (@SqlFilter01);

-- ArtikujScr
       Set   @SqlFilter01 = Replace(@SQLFilter00,' ARTIKUJ ',' ARTIKUJSCR ')
       Exec (@SqlFilter01);

-- ArtikujSist
       Set   @SqlFilter01 = Replace(@SQLFilter00,' ARTIKUJ ',' ARTIKUJSIST ')
       Exec (@SqlFilter01);

-- CSH_Lista
       Set   @SqlFilter01 = Replace(@SQLFilter00,' ARTIKUJ ',' CSH_LISTA ')
       Exec (@SqlFilter01);

-- CSH_Lista_LogS
       Set   @SqlFilter01 = Replace(@SQLFilter00,' ARTIKUJ ',' CSH_LISTA_LOGS ')
       Exec (@SqlFilter01);

-- CSH_Promocion_Scr
       Set   @SqlFilter01 = Replace(@SQLFilter00,' ARTIKUJ ',' CSH_PROMOCION_SCR ')
       Exec (@SqlFilter01);

-- KlientCm
       Set   @SqlFilter01 = Replace(@SQLFilter00,' ARTIKUJ ',' KLIENTCM ')
       Exec (@SqlFilter01);

-- KlientCmimArt
       Set   @SqlFilter01 = Replace(@SQLFilter00,' ARTIKUJ ',' KLIENTCMIMART ')
       Exec (@SqlFilter01);

-- OrderItemsSortScr
       Set   @SqlFilter01 = Replace(@SQLFilter00,' ARTIKUJ ',' ORDERITEMSSORTSCR ')
       Exec (@SqlFilter01);

-- Sherbim
       Set   @SqlFilter01 = Replace(@SQLFilter00,' ARTIKUJ ',' SHERBIM ')
       Exec (@SqlFilter01);




       Set   @SqlFilter00 = '
			UPDATE A
			   SET A.NJESIKONV = B.KODNEW
			  FROM ARTIKUJ A INNER JOIN '+@TableName+' B ON A.NJESIKONV = B.KOD 
             WHERE 1=1 ';

-- ConfigMG
       Set   @SqlFilter01 = Replace(@SQLFilter00,' ARTIKUJ ',' CONFIGMG ')
       Exec (@SqlFilter01);




       Set   @SqlFilter00 = '
			UPDATE A
			   SET A.NJESB  = B.KODNEW
			  FROM ARTIKUJ A INNER JOIN '+@TableName+' B ON A.NJESB  = B.KOD 
             WHERE 1=1 

			UPDATE A
			   SET A.NJESSH = B.KODNEW
			  FROM ARTIKUJ A INNER JOIN '+@TableName+' B ON A.NJESSH = B.KOD 
             WHERE 1=1 ';

-- Artikuj
       Set   @SqlFilter01 = @SQLFilter00
       Exec (@SqlFilter01);





       Set   @SqlFilter00 = '
			UPDATE A
			   SET A.KOD  = B.KODNEW
			  FROM NJESI A INNER JOIN '+@TableName+' B ON A.KOD = B.KOD 
             WHERE 1=1 ';

-- Njesi
       Set   @SqlFilter01 = @SQLFilter00
       Exec (@SqlFilter01);



GO
