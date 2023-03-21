SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   procedure [dbo].[Isd_UpdateNrFt]
(
  @PTableName Varchar(100),
  @PWhere     Varchar(Max),
  @PNrStart   Int,
  @PTest      Int,
  @POrderNew  Int
)
AS

--Exec dbo.Isd_UpdateNrFt 'FF','A.DATEDOK=Dbo.DATEVALUE(''01/05/2011'') ',0,1,0


	Declare @Sql       Varchar(Max),
            @SqlTest   Varchar(Max),
			@DName     Varchar(30),
            @Where     Varchar(Max),
            @Org       Varchar(2),
            @OrderNr   Varchar(50),
            @ListDok   Varchar(500),
            @PromptRef Varchar(20)

        Set @PromptRef   = 'Klient'
        Set @Where       = ''
        Set @OrderNr     = 'NrDok'
        if  @POrderNew   = 1
            Set @OrderNr = 'NrDokNew'

    Set @ListDok = 'FF,ORF,FJ,ORK,OFK,FJT'
    if  dbo.Isd_StringInListExs(@ListDok, @PTableName)<=0
        Return

	if Upper(@PTableName)='FJ'
       begin	
	     Set @DName = 'DKL'
         Set @Org   = 'S'
       end

	else

	if Upper(@PTableName)='FF'
       begin
	     Set @DName = 'DFU'
         Set @Org   = 'F'
       end

    if  dbo.Isd_StringInListExs('FF,ORF',@PTableName)>0
        Set @PromptRef='Furnitor'
    

	if @PWhere<>''
	   Set @Where = ' Where '+@PWhere


-- Test Update

       Set @Sql = '

	  Update A
		 Set NRDOK = B.NrDokNew
		From '+@PTableName+' A Inner Join 
			(Select NRRENDOR,NrDokNew = '+Cast(@PNrStart As Varchar(10))+'+Row_Number() Over(Order By DATEDOK,KMAG,NRRENDOR)
			   From ' + @PTableName + ' A 
			 ' + 
			 @Where + '
			 ) B On A.NRRENDOR=B.NRRENDOR 
	   ' + 
      @Where

 

	 if dbo.Isd_StringInListExs('FF,FJ', @PTableName)>0
		Set @Sql = @Sql + '
   
	  UpDate B
		 Set B.NRDOK = A.NRDOK
		From ' + @PTableName + ' A Inner Join '+@DName+' B On A.NRDITAR=B.NRRENDOR 
	   ' + 
	  @Where + '
	   
	  UpDate B
		 Set B.NUMDOK = A.NRDOK
		From ' + @PTableName + ' A Inner Join FK B On 
			 A.NRDFK  = B.NRRENDOR And 
			 A.KODFKL = B.REFERDOK And 
			 B.TIPDOK = '''+@PTableName+'''   And
			 B.ORG    = '''+@Org+'''   
	  ' + 
	  @Where


-- Test string

    Set @SqlTest = '

	  Select Date    = A.DATEDOK,
             NrDok   = A.NRDOK,
             NrDokRi = B.NrDokNew,
			 '+@PromptRef+'=A.KODFKL,
             Shenim1 = A.SHENIM1,
             Shenim2 = A.SHENIM2,
             Vlera   = A.VLERTOT,
             Mon     = A.KMON,
             Serial  = A.NRSERIAL,
			 Nipt    = A.NIPT,
             A.NRDFK,
             A.NRRENDOR,
             TROW    = Cast(0 As Bit) 
		From '+@PTableName+' A Inner Join 
			(Select NRRENDOR,NrDokNew = '+Cast(@PNrStart As Varchar(10))+'+Row_Number() Over(Order By DATEDOK,KMAG,NRRENDOR)
			   From ' + @PTableName + ' A 
			 ' + 
		 @Where + '
			 ) B On A.NRRENDOR=B.NRRENDOR     
	  ' + 
	  @Where + '
	Order By A.DateDok,'+@OrderNr


Print @SqlTest

if @PTest=1
 --Print @SqlTest
   Exec (@SqlTest)
else
 --Print @Sql
   Exec (@Sql)

GO
