SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE   procedure [dbo].[Z_DeleteRecords]  -- Per perdorim Kolaudimi

AS


     Declare @i         Int,
             @j         Int,
             @NrDel     Varchar(30),
             @ListTbl   Varchar(Max),
             @sTable    Varchar(30),
             @Date      Varchar(30),
             @sSql      nVarchar(Max);

 
         Set NoCount On;


         Set @ListTbl = 'ARKA,BANKA,FK,VS,DG,FH,FD,FJ,FF,DKL,DFU,DAR,DBA';
         Set @i = 1;
         Set @j = Len(@ListTbl) - Len(Replace(@ListTbl,',','')) + 1;
         Set @Date = '01/02/2014';




   RaisError (N'
*****     1.  Fshirje rekorde tek tablelat per date >= %s     ***** 

',0,1,@Date) with NoWait;




       while @i<=@j
         begin
           Set @sTable = Upper([dbo].[Isd_StringInListStr](@ListTbl,@i,''));
           if  @sTable<>''
               begin
                 Set   @sSql  = ' DELETE FROM '+@sTable+' WHERE DATEDOK>=dbo.DateValue('''+@Date+''')';
                 Exec (@sSql);
                 Set   @NrDel = Cast(@@ROWCOUNT as Varchar(20));
                 RaisError (N' %s  -  Fshirje %s rekorde per date >= %s',0,1,@sTable, @NrDel, @Date) with NoWait;
               end;
           Set @i = @i + 1;
         end;



  Set @sTable = DB_Name();


   RaisError (N'

*****     2.  Shrink datbase %s    ***** ',0,1,@sTable) with NoWait;

--dbcc ShrinkDatabase 'CONFIG'
Set @sSql = 'DBCC SHRINKDATABASE ('''+DB_Name()+''') --WITH NO_INFOMSGS '
Exec (@sSql)

GO
