SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



--Exec [Isd_KillConnection] @PDatabaseName='TempDB'

CREATE Procedure [dbo].[Isd_KillConnection]
 (
  @PDatabaseName Varchar(100)
  )
as


Set NoCount on

Declare @DatabaseName Varchar(100)
Declare @Query        Varchar(max)
    Set @Query      = ''

Set @DatabaseName = @PDatabaseName 
if Db_id(@DatabaseName) < 4   --'Master,Tempdb,MsDb,Model'
   Begin
   --Print 'E pamundur Abortimi i proceseve te databases sistem ...'
     Return
   End

Select @Query = Coalesce(@Query,',' )+'kill '+Convert(Varchar, Spid)+ '; '
  From Master..SysProcesses 
 Where DbId=Db_id(@DatabaseName) And Spid<>@@Spid And (Db_id(@DatabaseName) not in (1,2,3,4))

if Len(@query) > 0
   Begin
   --Print @query
	 Exec (@query)
   End
--sp_Who
--Print @@Spid
GO
