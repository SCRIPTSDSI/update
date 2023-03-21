SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Isd_KalimLM_CP]
	
  @PTable  Varchar(30),
  @PDt1    Varchar(20),
  @PDt2    Varchar(20)

AS

BEGIN

	     SET NOCOUNT ON

   RAISERROR (N'
_________________________________

   Cpostim dokumenta %s
_________________________________', 0, 1, @PTable) WITH NOWAIT;


     DECLARE @List1    Varchar(100),
             @List2    Varchar(20),
             @Org      Varchar(10),
             @Where    Varchar(100),
             @Sql      Varchar(MAX),
             @D1       Varchar(100),
             @D2       Varchar(100),
             @Table    Varchar(30),
             @i        Int;

         SET @Table = @PTable;
         SET @List1 = 'ARKA,BANKA,VS,FH,FD,FF,FJ,DG,AQ';
         SET @List2 = 'A,B,E,H,D,F,S,G,X';

         SET @i     = dbo.Isd_StringInListInd(@List1,@Table,',');
         SET @Org   = dbo.Isd_StringInListStr(@List2,@i,',');
         SET @D1    = '';
         SET @D2    = '';




          IF @Org=''
             RETURN;




          IF @PDt1<>''
             SET @D1 = 'DATEDOK>=dbo.DateValue('+QuoteName(@PDt1,'''')+')';
          IF @PDt2<>''
             SET @D2 = 'DATEDOK<=dbo.DateValue('+QuoteName(@PDt2,'''')+')';
             
          IF @D1<>'' AND @D2<>''
             SET @Where = @D1 + ' AND ' + @D2
          ELSE
             SET @Where = @D1 + @D2;

         SET @Org = QuoteName(@Org,'''');


         SET @Sql = '   

      UPDATE '+@Table+'  SET NRDFK=0  WHERE ISNULL(NRDFK,0)<>0 AND 1=2;

      DELETE  FROM FK  WHERE ORG='+@Org+' AND 1=2; ';

          IF @Where<>''
             SET @Sql = Replace(@Sql,'1=2',@Where);

    -- PRINT @Sql

   RAISERROR (N'  1.1  Fillim Cpostimi', 0, 1) WITH NOWAIT;

        EXEC (@Sql);

       PRINT       '  1.1  Fund Cpostimi';


   RAISERROR (N'  2.1  Fshirje NRD NULL', 0, 1) WITH NOWAIT;

      DELETE FROM FKSCR WHERE ISNULL(NRD,0)=0; 

       PRINT       '  2.2  Fund Fshirje NRD NULL';


   RAISERROR (N'
_________________________________

   Cpostim dokumenta %s
_________________________________', 0, 1, @Table) WITH NOWAIT

END
GO
