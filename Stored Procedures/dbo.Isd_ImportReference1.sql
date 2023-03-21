SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





-- Exec [Isd_ImportReference1] @PTableOrg  = 'Ehw13..Klient ',
--                             @PTableDst  = 'Ehw13S..Klient',
--                             @PTableRef  = '##RFTable100',
--                             @PDisplay   = 0,
--                             @PWhere     = ''

CREATE         Procedure [dbo].[Isd_ImportReference1]
(
 @PTableOrg   Varchar(50),
 @PTableDst   Varchar(50),
 @PTableRef   Varchar(50),
 @PDisplay    Int,
 @PWhere      Varchar(Max)
 )
As


     Set NoCount Off


 Declare @TableOrg    Varchar(50),
         @TableDst    Varchar(50),
         @TableRef    Varchar(50),
         @Sql         Varchar(Max),
         @Display     Varchar(10)


    Set  @TableOrg  = '#TableRefOrg'
    Set  @TableDst  = '#TableRefDst'
    Set  @TableRef   = @PTableRef
    Set  @Display   = Cast(@PDisplay As Varchar);


     if  @TableRef=''
         Set @TableRef   = 'TableRef'


    Set  @Sql = '

           if Object_Id(''TempDB..'+@TableOrg+''') is not null
              DROP TABLE ' + @TableOrg +';

           if Object_Id(''TempDB..'+@TableDst+''') is not null
              DROP TABLE ' + @TableDst +';

           if Object_Id(''TempDB..'+@TableRef+''') is not null
              DROP TABLE ' + @TableRef + '; 

	   Select *,
			  EgzistRef=''  ''
		 Into '+@TableRef+'
		 From '+@PTableOrg+' 
	    Where 101=101
     Order By Kod; 


	   Select Kod,NrRendor
		 Into '+@TableOrg+'
		 From '+@PTableOrg+' 
	 Order By Kod;

	   Select Kod,NrRendor
		 Into '+@TableDst+'
		 From '+@PTableDst+' 
	 Order By Kod;


	   Update '+@TableRef+'
		  Set TRow = 0;

	   Update A
		  Set A.TRow      = 0,
			  A.EgzistRef = ''E''
		 From '+@TableRef+' A Inner Join '+@TableDst+' B On A.Kod=B.Kod; 

           if Object_Id(''TempDB..'+@TableOrg+''') is not null
              DROP TABLE ' + @TableOrg +';

           if Object_Id(''TempDB..'+@TableDst+''') is not null
              DROP TABLE ' + @TableDst +';

           if '+@Display+'=2
              Delete From '+@TableRef+' Where IsNull(EgzistRef,'''')='''';
           if '+@Display+'=1
              Delete From '+@TableRef+' Where IsNull(EgzistRef,'''')=''E'';


       Select * 
         From '+@TableRef+' 
     Order By Kod 
';

    if   @PWhere<>''
         Set @Sql = Replace(@Sql,'101=101',@PWhere);


   Print @Sql;
    Exec(@Sql);

  


GO
