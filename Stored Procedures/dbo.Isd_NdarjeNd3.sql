SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [dbo].[Isd_NdarjeNd3]
 (
  @PDateKp   Varchar(20)
 )
As

    Set NoCount On;

RaisError (N'

---------------------------------------
3      -      FILLIM Isd_NdarjeNd3 !
    -----------------------------------

',0,1) with NoWait;

       Declare @Sql       Varchar(Max),
               @DtMin     Varchar(30),
               @DtMax     Varchar(30);

           Set @DtMin = dbo.Isd_DateMinMaxSql(0);
           Set @DtMax = dbo.Isd_DateMinMaxSql(1);

     RaisError (N'3.1    -      Fillim Delete Rows ..! ',0,1) with NoWait;
     Exec      dbo.Isd_DeleteDocs '','VSST,FKST',@PDateKp,1,0;

     RaisError (N'3.2    -      Fillim Ditare per Arka ..! ',0,1) with NoWait;
     Exec      dbo.Isd_GjenerimDitar @DtMin, @DtMax, 'A','1';

     RaisError (N'3.3    -      Fillim Ditare per Banka ..! ',0,1) with NoWait;
     Exec      dbo.Isd_GjenerimDitar @DtMin, @DtMax, 'B','1';

     RaisError (N'3.4    -      Fillim Ditare per FF ..! ',0,1) with NoWait;
     Exec      dbo.Isd_GjenerimDitar @DtMin, @DtMax, 'F','1';

     RaisError (N'3.5    -      Fillim Ditare per FJ ..! ',0,1) with NoWait;
     Exec      dbo.Isd_GjenerimDitar @DtMin, @DtMax, 'S','1';

     Set       @Sql = ' DBCC ShrinkDataBase ('+Db_Name()+')'
     Exec     (@Sql);

RaisError (N'

    -----------------------------------
3      -      FUND   Isd_NdarjeNd3 !
---------------------------------------

',0,1) with NoWait;
GO
