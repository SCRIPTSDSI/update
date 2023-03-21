SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




--Exec [Dbo].[Isd_KodChangeKF] @PTip='LKL'

CREATE Procedure [dbo].[Isd_KodChangeKF]
(
@PTip Varchar(5)
)
As
Declare @TableUPD      Varchar(100),
        @TableList     Varchar(100),
        @TableDitar    Varchar(100),
        @TableLiber    Varchar(100),
        @TablesName    Varchar(200),
        @TablesNameScr Varchar(200),
        @TblName       Varchar(100),
        @Modul         Varchar(5),
        @SqlFilter00   Varchar(Max),
        @SqlFilter01   Varchar(Max)
        

      if  Exists (SELECT NAME FROM Sys.Objects Where Object_Id=Object_Id('#KODUPD'))
		  DROP TABLE #KODUPD

		SELECT A.KOD,A.KODNEW,A.TROW,A.TAGNR,TIPKLL
		  INTO #KODUPD
		  FROM KODCHANGE A 
         WHERE 1=2


      Set @TableUPD = '#KODUPD'
      Set @TablesNameScr  = 'ARKASCR,BANKASCR,VSSCR,VSSTSCR,'

      if  @PTip='LKL'
          begin
            Set @TableList  = 'KLIENT'		  
            Set @TableLiber = 'LKL'		  
            Set @TableDitar = 'DKL'
            Set @TablesName = 'FJ,OFK,ORK,FJT,SM,'
            Set @Modul      = 'S'
          end
      else
          begin
            Set @TableList  = 'FURNITOR'		  
            Set @TableLiber = 'LFU'		  
            Set @TableDitar = 'DFU'		  
            Set @TablesName = 'FF,ORF,'		  
            Set @Modul      = 'F'
          end

-- Dokumenta
        if @Modul='S' 
           begin
				INSERT INTO #KODUPD (KOD,KODNEW,TIPKLL,TROW,TAGNR)
                SELECT A.KOD,A.KODNEW,A.TIPKLL,A.TROW,A.TAGNR
				  FROM KODCHANGE A INNER JOIN KLIENT B ON A.KOD=B.KOD
				 WHERE A.TIPKLL=@PTip AND 
					  (ISNULL(A.KOD,'')<>'' AND ISNULL(A.KODNEW,'')<>'') AND
					  (A.KOD<>A.KODNEW) AND
					  (NOT (EXISTS (SELECT KOD FROM KLIENT B WHERE B.KOD=A.KODNEW)))
			  ORDER BY A.KOD 
           end
        else
           begin
				INSERT INTO #KODUPD (KOD,KODNEW,TIPKLL,TROW,TAGNR)
                SELECT A.KOD,A.KODNEW,A.TIPKLL,A.TROW,A.TAGNR
				  FROM KODCHANGE A INNER JOIN FURNITOR B ON A.KOD=B.KOD
				 WHERE A.TIPKLL=@PTip AND 
					  (ISNULL(A.KOD,'')<>'' AND ISNULL(A.KODNEW,'')<>'') AND
					  (A.KOD<>A.KODNEW) AND
					  (NOT (EXISTS (SELECT KOD FROM FURNITOR B WHERE B.KOD=A.KODNEW)))
			  ORDER BY A.KOD 
           end
 
       if IsNull((SELECT TOP 1 1 FROM #KODUPD),0)=0
          Return 

       Set @SqlFilter00 = '
			UPDATE A
			   SET A.KODFKL = B.KODNEW,
				   A.KOD    = Dbo.Isd_SegmentChange(A.KOD,B.KODNEW,0)
			  FROM FJ A INNER JOIN '+@TableUPD+' B ON A.KODFKL = B.KOD
             WHERE 1=1 '

       while CharIndex(',',@TablesName)>0
         begin
           Set   @TblName     = Left(@TablesName,CharIndex(',',@TablesName)-1)
           Set   @SqlFilter01 = Replace(@SQLFilter00,' FJ ',' '+@TblName+' ')
           Set   @TablesName  = Substring(@TablesName,CharIndex(',',@TablesName)+1,Len(@TablesName))
           Exec (@SqlFilter01)
         end 

-- Dogana
        Set @SqlFilter01 = 
             'UPDATE A 
                 SET KOD=B.KODNEW
                FROM DG A INNER JOIN '+@TableUPD+' B ON A.KOD = B.KOD 
               WHERE B.TIPKLL='''+@PTip+''' AND TIPFT='''+@Modul+''' '
        Exec (@SqlFilter01)


-- Liber
       Set @SqlFilter01 = 
             'UPDATE A 
                 SET A.SG1 = B.KODNEW ,
                     A.KOD = Dbo.Isd_SegmentChange(A.KOD,B.KODNEW,0)
                FROM '+@TableLiber+' A INNER JOIN '+@TableUPD+' B ON Dbo.Isd_SegmentFind(A.KOD,0,1)=B.KOD '
       Exec (@SqlFilter01)

-- Ditar
       Set @SqlFilter01 = 
             'UPDATE A 
                 SET A.KOD = Dbo.Isd_SegmentChange(A.KOD,B.KODNEW,0)
                FROM '+@TableDitar+' A INNER JOIN '+@TableUPD+' B ON Dbo.Isd_SegmentFind(A.KOD,0,1)=B.KOD '
       Exec (@SqlFilter01)

-- Lista
       Set @SqlFilter01 = 
             'UPDATE A 
                 SET KOD=B.KODNEW
                FROM '+@TableList+' A INNER JOIN '+@TableUPD+' B ON A.KOD = B.KOD '
       Exec (@SqlFilter01)

-- Kasa
       if @Modul='S'
          begin
            Set @SqlFilter01 = 
                  'UPDATE A 
                      SET KODKL=B.KODNEW
                     FROM KASE A INNER JOIN '+@TableUPD+' B ON A.KODKL = B.KOD '
            Exec (@SqlFilter01)
          end

-- Scr
       Set @TablesName     = @TablesNameScr
       Set @SqlFilter00 = '
			UPDATE A
			   SET A.LLOGARI   = B.KODNEW,
                   A.LLOGARIPK = B.KODNEW,
				   A.KODAF     = Dbo.Isd_SegmentChange(A.KODAF, B.KODNEW,0),
				   A.KOD       = Dbo.Isd_SegmentChange(A.KOD,   B.KODNEW,0)
			  FROM ARKASCR A INNER JOIN '+@TableUPD+' B ON A.LLOGARIPK = B.KOD
             WHERE A.TIPKLL='''+@Modul+''' '

       while CharIndex(',',@TablesName)>0
         begin
           Set   @TblName     = Left(@TablesName,CharIndex(',',@TablesName)-1)
           Set   @SqlFilter01 = Replace(@SQLFilter00,' ARKASCR ',' '+@TblName+' ')
           Set   @TablesName  = Substring(@TablesName,CharIndex(',',@TablesName)+1,Len(@TablesName))
           Exec (@SqlFilter01)
         end 





GO
