SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   procedure [dbo].[Isd_UpdateNrAB]
(
  @PTableName Varchar(100),
  @PWhere     Varchar(Max),
  @PNrStart   Int,
  @PTest      Int,
  @POrderNew  Int
)
AS

--Exec dbo.Isd_UpdateNrAB 'BANKA','A.DATEDOK<=Dbo.DATEVALUE(''01/05/2011'') And A.KODAB=''B01'' ',0,1,1


	Declare @Sql       Varchar(Max),
            @SqlTest   Varchar(Max),
			@DName     Varchar(30),
            @Where     Varchar(Max),
            @Org       Varchar(2),
            @OrderNr   Varchar(50),
            @PromptDok Varchar(20)

        Set @Where    = ''
        Set @OrderNr  = 'NumDok'
        if  @POrderNew=1
            Set @OrderNr = 'NrDokNew'

    if  Dbo.Isd_StringInListExs('ARKA,BANKA',@PTableName)<=0
        Return

        Set @PromptDok = 'Arke'
        Set @DName     = 'DAR'
        Set @Org       = 'A'

	if Upper(@PTableName)='BANKA'
       begin
         Set @PromptDok = 'Banke'
	     Set @DName     = 'DBA'
         Set @Org       = 'B'
       end

	if @PWhere<>''
	   Set @Where = ' Where '+@PWhere


    Set @Sql = '

  Update A
     Set NumDok = B.NrDokNew
    From '+@PTableName+' A Inner Join 
        (Select NRRENDOR,NrDokNew = '+Cast(@PNrStart As Varchar(10))+'+Row_Number() Over(Partition By KODAB,TIPDOK Order By DATEDOK,NRRENDOR)
           From ' + @PTableName + ' A 
         ' + 
         @Where + '
         ) B On A.NRRENDOR=B.NRRENDOR 
  ' + 
 @Where + '
   
  UpDate B
     Set B.NRDOK=A.NUMDOK
    From ' + @PTableName + ' A Inner Join '+@DName+' B On A.NRDITAR=B.NRRENDOR 
  ' + 
 @Where + '
   
  UpDate B
     Set B.NUMDOK=A.NUMDOK
    From ' + @PTableName + ' A Inner Join FK B On 
         A.NRDFK  = B.NRRENDOR And 
         A.KODAB  = B.REFERDOK And 
         A.TIPDOK = B.TIPDOK   And
         B.ORG    = '''+@Org+'''   
  ' + 
 @Where + '

  UpDate B
     Set B.NRDOK=A.NUMDOK
    From '+@PTableName+' 
                 A Inner Join '+@PTableName+'SCR A1 On A.NRRENDOR=A1.NRD
                   Inner Join DFU      B  On A1.NRDITAR=B.NRRENDOR 
   Where 1=1 AND A1.TIPKLL=''F''

  UpDate B
     Set B.NRDOK=A.NUMDOK
    From '+@PTableName+' 
                 A Inner Join '+@PTableName+'SCR A1 On A.NRRENDOR=A1.NRD
                   Inner Join DKL B  On A1.NRDITAR=B.NRRENDOR 
   Where 1=1 AND A1.TIPKLL=''S'' '


	if   @PWhere<>''
         Set @Sql = Replace(@Sql,'1=1',@PWhere)


    Set  @SqlTest = '

  Select '+@PromptDok+'=A.KODAB,
         Date     = A.DATEDOK,
         Dokument = A.TIPDOK,
         NrDok    = A.NUMDOK,
         Fraks    = A.FRAKSDOK,
         NrDokRi  = B.NrDokNew,
         Shenim1  = A.SHENIM1,
         Shenim2  = A.SHENIM2,
         Vlera    = A.VLERA,
         Mon      = A.KMON,
         Seri     = A.NRSERI,
         A.NRDFK,
         A.NRRENDOR,
         TROW     = Cast(0 As Bit)
    From '+@PTableName+' A Inner Join 
        (Select NRRENDOR,NrDokNew = '+Cast(@PNrStart As Varchar(10))+'+Row_Number() Over(Partition By KODAB,TIPDOK Order By DATEDOK,NRRENDOR)
           From ' + @PTableName + ' A 
         ' + 
     @Where + '
         ) B On A.NRRENDOR=B.NRRENDOR     
  ' + 
  @Where + '
Order By A.KodAB,A.TipDok,A.DateDok,'+@OrderNr


   Print @Sql


if @PTest=1
 --Print @SqlTest
   Exec (@SqlTest)
else
 --Print @Sql
   Exec (@Sql)




GO
