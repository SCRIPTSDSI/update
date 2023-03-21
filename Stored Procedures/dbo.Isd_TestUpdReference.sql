SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   procedure [dbo].[Isd_TestUpdReference]
(
  @pTNames     Varchar(1000),
  @pTestVlere  Float,
  @pOperacion  Varchar(100),
  @TestTable   Varchar(30)
)
AS

-- EXEC dbo.[Isd_TestUpdReference] 'ARKAT,BANKAT',0.01,'REFDBL',''

-- 1.  Fshirje Referenca te dublikuara....


         SET NoCount ON;
     
     DECLARE @Ind1          Int,
             @Nr1           Int,
             @TblList       Varchar(MAX),
             @SQLFilter00   Varchar(MAX),
             @SQLFilter01   Varchar(MAX),
             @ListTables    Varchar(MAX),
             @TName         Varchar(50);

         SET @ListTables  = dbo.Isd_ListTables('','');

		 IF  dbo.Isd_ListFields2Lists(@POperacion,'ALL,REFDBL','')<>''
		     BEGIN 

		 	   SET   @TblList    = dbo.Isd_ListTablesDR('','REF');
		 	   SET   @Nr1        = LEN(@TblList)-LEN(REPLACE(@TblList,',',''))+1;
		 	   SET   @SqlFilter00 = '
			 	     DELETE A
				 	   FROM ARTIKUJ A
					  WHERE (SELECT COUNT(*)        FROM ARTIKUJ B WHERE UPPER(LTRIM(RTRIM(B.KOD)))=UPPER(LTRIM(RTRIM(A.KOD))))>1 AND
					 	    (SELECT MAX(B.NRRENDOR) FROM ARTIKUJ B WHERE UPPER(LTRIM(RTRIM(B.KOD)))=UPPER(LTRIM(RTRIM(A.KOD))))>A.NRRENDOR ';

			   SET   @Ind1  = 1;

			   WHILE @Ind1 <= @Nr1
			 	 BEGIN

				     SET @TName = LTRIM(RTRIM(dbo.Isd_StringInListStr(@TblList,@Ind1,',')));     
				     SET @TName = LTRIM(RTRIM(REPLACE(@TName,' ','')));  

				     IF  dbo.Isd_StringInListExs(@ListTables,@TName)>0 
					     BEGIN
                           PRINT @TName;
						   SET   @SqlFilter01 = REPLACE(@SQLFilter00,'ARTIKUJ',@TName);
						   EXEC (@SqlFilter01);  
					     END

				     SET @Ind1 = @Ind1 + 1;

				 END;

		     END;

GO
