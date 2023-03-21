SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE          procedure [dbo].[Isd_TestFtNrFt]
(
  @PTable     Varchar(20),
  @PField     Varchar(20),
  @PWhere1    Varchar(Max),
  @PWhere2    Varchar(Max)
)

As


--     Set @PTable   = 'FF'
--     Set @PWhere1  = ' KODFKL=''F1101'' '
--     Set @PWhere2  = 'NRFT>=0 AND NRFT<=2'
--     Set @PField   = 'NIPT'  -- 'KODFKL'

-- Exec [dbo].[Isd_TestFtNrFt] @PTable='FF', @PField='NIPT', @PWhere1=' KODFKL=''F1101'' ',@PWhere2='NRFT>=1 AND NRFT<=2'  

 Declare @Sql        Varchar(Max)

Set @Sql = '   

  SELECT Faturuar=B.NRFT, KOMENT=A.'+@PField+'+'' faturuar ''+Cast(B.NRFT As Varchar)+'' here'',
         A.NRDOK,A.DATEDOK,KOD=A.KODFKL,Monedhe=A.KMON,A.NIPT,A.SHENIM1,A.SHENIM2,A.SHENIM3,A.SHENIM4,A.VLERTOT,A.KMAG,A.NRDMAG,A.FRDMAG,A.DTDMAG,A.NRRENDOR,A.TAGNR,A.TROW 
    FROM '+@PTable+' A INNER JOIN 
        (SELECT NRFT=COUNT(*),KODLINK='+@PField+' 
           FROM '+@PTable+' A 
          WHERE 1=1
       GROUP BY '+@PField+') B ON A.'+@PField+'=B.KODLINK
          LEFT JOIN KLIENT C ON A.KODFKL=C.KOD
   WHERE 1=1 AND 2=2
ORDER BY A.'+@PField+',A.DATEDOK,A.NRDOK '	

if (@PWhere1<>'') and (@PWhere1<>'''')
   begin
     Set @Sql = Replace(@Sql,'1=1',@PWhere1)
   end;

if @PWhere2<>''
   begin
     Set @Sql = Replace(@Sql,'2=2',@PWhere2)
   end

--Print @Sql

Exec (@Sql)

GO
