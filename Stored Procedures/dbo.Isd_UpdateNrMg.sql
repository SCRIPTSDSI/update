SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   procedure [dbo].[Isd_UpdateNrMg]
(
  @PTableName Varchar(100),
  @PWhere     Varchar(Max),
  @PNrStart   Int,
  @PTest      Int,
  @POrderNew  Int
)
AS

--Exec dbo.Isd_UpdateNrMg 'FD','A.DATEDOK>=Dbo.DATEVALUE(''01/03/2011'') And A.KMAG=''PG1'' ',0,1,1


	Declare @Sql      Varchar(Max),
            @SqlTest  Varchar(Max),
            @Where    Varchar(Max),
			@FtName   Varchar(30),
            @Org      Varchar(2),
            @OrderNr  Varchar(50),
            @PromtDst Varchar(10)

        Set @Where    = ''
        Set @OrderNr  = 'NrDok'
        if  @POrderNew=1
            Set @OrderNr = 'NrDokNew'

	if CharIndex(Upper(@PTableName),'FH') >0
       begin
	     Set @FtName   = 'FF'
         Set @Org      = 'H'
         Set @PromtDst = 'Origj'
       end

	else

	if CharIndex(Upper(@PTableName),'FD')>0
       begin
	     Set @FtName   = 'FJ'
         Set @Org      = 'D'
         Set @PromtDst = 'Dest'
       end

	else
	   Return


	if @PWhere<>''
	   Set @Where = ' Where '+@PWhere



    Set @Sql = '

  Update A
     Set NrDok = B.NrDokNew
    From '+@PTableName+' A Inner Join 
        (Select NRRENDOR,NrDokNew = '+Cast(@PNrStart As Varchar(10))+'+Row_Number() Over(Partition By A.KMAG Order By A.DATEDOK,NRRENDOR)
           From ' + @PTableName + ' A 
         ' + 
         @Where + '
         ) B On A.NRRENDOR=B.NRRENDOR 
  ' + 
  @Where + '
   
  UpDate B
     Set B.NRDMAG = A.NRDOK
    From ' + @PTableName + ' A Inner Join '+@FtName+' B On A.NRRENDOR=B.NRRENDDMG 
  ' + 
 @Where + '
   
  UpDate B
     Set B.NUMDOK = A.NRDOK
    From ' + @PTableName + ' A Inner Join FK B On 
         A.NRDFK  = B.NRRENDOR And 
         A.KMag   = B.KMag And 
         B.TIPDOK = '''+@PTableName+''' And 
         B.ORG    = '''+@Org+'''
  ' + 
 @Where




    Set @SqlTest = '

  Select Magazina  = A.KMAG,
         Dokument  = '''+@PTableName+''',
         Date      = A.DATEDOK,
         NrDok     = A.NRDOK,
         Fraks     = A.NRFRAKS,
         NrDokRi   = B.NrDokNew,
         Fature    = Case When A.DOK_JB=1 Then ''+'' Else '''' End,
         Shenim1   = A.SHENIM1,'+@PromtDst+'=A.DST,
         Shenim2   = A.SHENIM2,
         MagLink   = A.KMAGLNK,
         NrLink    = A.NRDOKLNK,
         FraksLink = A.NRFRAKSLNK,
         A.NRDFK,
         A.NRRENDOR,
         TROW      = Cast(0 As Bit) 
    From '+@PTableName+' A Inner Join 
        (Select NRRENDOR,NrDokNew = '+Cast(@PNrStart As Varchar(10))+'+Row_Number() Over(Partition By KMAG Order By DATEDOK,NRRENDOR)
           From ' + @PTableName + ' A 
         ' + 
     @Where + '
         ) B On A.NRRENDOR=B.NRRENDOR     
  ' + 
  @Where + '
Order By A.KMag,A.DateDok,'+@OrderNr
  

if @PTest=1
 --Print @SqlTest  
   Exec (@SqlTest)
else
 --Print @Sql
   Exec (@Sql)

GO
