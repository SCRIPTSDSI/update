SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





--
-- Exec Ehw_F5_Palm_Zer
--                      @PDBaseFinName = 'EHW09',
--                      @PServer       = 'F5Palm',
--                      @PPathAdress   = 'E:\MobSell\F5PalmIbd.mdb',
--                      @PDBaseImpName = 'EHWIMPPALM',
--                      @PDeriDtKp     = '22/09/2009', 
--                      @PDeriDtKs     = '22/09/2009',
--                      @PShrink       = 0


CREATE   procedure [dbo].[Ehw_F5_Palm_Zer]
  (
  @PDBaseFinName    As Varchar(20),
  @PServer          As Varchar(100),
  @PPathAdress      As Varchar(150),
  @PDBaseImpName    As Varchar(20),
  @PDeriDtKp        As Varchar(20),
  @PDeriDtKs        As Varchar(20),
  @PShrink          As Int
  )
as

Set @PDeriDtKp       = QuoteName(@PDeriDtKp,'''')
Set @PDeriDtKs       = QuoteName(@PDeriDtKs,'''')

Declare @VDbFin        Varchar(30)
Declare @VDbImp        Varchar(30)
Set @VDbFin          = @PDBaseFinName+'..' --'EHW09..'
Set @VDbImp          = @PDBaseImpName+'..' --'EHWIMPPALM..'

--									L I N K   S E R V E R   M E   F I L E   A C C E S S
Declare @VServer       Varchar(50)
Declare @QServer       Varchar(50)
Declare @VPathAdress   Varchar(150)
Set @QServer         = @PServer
Set @VServer         = QuoteName(@QServer,'''')
Set @VPathAdress     = QuoteName(@PPathAdress,'''')

Exec('SP_DROPSERVER '+@VServer+',"Droplogins"')
Exec('SP_ADDLINKEDSERVER '+@VServer+',"Access 2000","Microsoft.Jet.OLEDB.4.0",'+@VPathAdress)
Exec('SP_ADDLINKEDSRVLOGIN '+@VServer+',False,"sa","Admin",null')
Set @VServer  = Case When @QServer<>'' Then @QServer+'...' Else @QServer End
--									F U N D  L I N K   S E R V E R



--									Z E R I M I   I   S T R U K T U R A V E
Declare @VTbName       Varchar(30)
Declare @VTbNameO      Varchar(30)
Declare @VTbNameD      Varchar(30)
Declare @TableRef      Varchar(30)

Set @VTbName         = 'ARKA'
Set @VTbNameD        = @VDbImp+@VTbName
Print '1'
Exec('DELETE B FROM '+ @VTbNameD+' A INNER JOIN '+ @VTbNameD+'SCR B ON A.NRRENDOR=B.NRD 
       WHERE ISNULL(A.STATUS,0)<>0 AND (A.DATEDOK>=DBO.DATEVALUE('+@PDeriDtKp+') AND A.DATEDOK<=DBO.DATEVALUE('+@PDeriDtKs+'))')
Exec('DELETE FROM '  + @VTbNameD+'            
       WHERE ISNULL(STATUS,0)<>0 AND DATEDOK>=DBO.DATEVALUE('+@PDeriDtKp+') AND DATEDOK<=DBO.DATEVALUE('+@PDeriDtKs+')')
--
Exec('DELETE FROM '  + @VServer+'KLIENTPAGESA 
       WHERE ISNULL(STATUS,0)<>0 AND DATEDOK>=DBO.DATEVALUE('+@PDeriDtKp+') AND DATEDOK<=DBO.DATEVALUE('+@PDeriDtKs+')')

Set @VTbName         = 'FH'
Set @VTbNameD        = @VDbImp+@VTbName
Exec('DELETE B FROM '+ @VTbNameD+' A INNER JOIN '+ @VTbNameD+'SCR B ON A.NRRENDOR=B.NRD 
       WHERE ISNULL(A.STATUS,0)<>0 AND (A.DATEDOK>=DBO.DATEVALUE('+@PDeriDtKp+') AND A.DATEDOK<=DBO.DATEVALUE('+@PDeriDtKs+'))')
Exec('DELETE FROM '  + @VTbNameD+'            
       WHERE ISNULL(STATUS,0)<>0 AND DATEDOK>=DBO.DATEVALUE('+@PDeriDtKp+') AND DATEDOK<=DBO.DATEVALUE('+@PDeriDtKs+')')
--
Exec('DELETE FROM '  + @VServer+'MGIMPF5 
       WHERE ISNULL(STATUS,0)<>0 AND DATEDOK>=DBO.DATEVALUE('+@PDeriDtKp+') AND DATEDOK<=DBO.DATEVALUE('+@PDeriDtKs+')')



Set @VTbName         = 'FD'
Set @VTbNameD        = @VDbImp+@VTbName
Exec('DELETE B FROM '+ @VTbNameD+' A INNER JOIN '+ @VTbNameD+'SCR B ON A.NRRENDOR=B.NRD 
       WHERE ISNULL(A.STATUS,0)<>0 AND (A.DATEDOK>=DBO.DATEVALUE('+@PDeriDtKp+') AND A.DATEDOK<=DBO.DATEVALUE('+@PDeriDtKs+'))')
Exec('DELETE FROM '  + @VTbNameD+'            
       WHERE ISNULL(STATUS,0)<>0 AND DATEDOK>=DBO.DATEVALUE('+@PDeriDtKp+') AND DATEDOK<=DBO.DATEVALUE('+@PDeriDtKs+')')



Set @VTbName         = 'FJ'
Set @VTbNameD        = @VDbImp+@VTbName
Exec('DELETE B FROM '+ @VTbNameD+' A INNER JOIN '+ @VTbNameD+'SCR B ON A.NRRENDOR=B.NRD 
       WHERE ISNULL(A.STATUS,0)<>0 AND (A.DATEDOK>=DBO.DATEVALUE('+@PDeriDtKp+') AND A.DATEDOK<=DBO.DATEVALUE('+@PDeriDtKs+'))')
Exec('DELETE FROM '  + @VTbNameD+'            
       WHERE ISNULL(STATUS,0)<>0 AND DATEDOK>=DBO.DATEVALUE('+@PDeriDtKp+') AND DATEDOK<=DBO.DATEVALUE('+@PDeriDtKs+')')
--
Exec('DELETE FROM '  + @VServer+'FJIMPF5 
       WHERE ISNULL(STATUS,0)<>0 AND DATEDOK>=DBO.DATEVALUE('+@PDeriDtKp+') AND DATEDOK<=DBO.DATEVALUE('+@PDeriDtKs+')')

--							F U N D I  I  Z E R I M I T   T E   S T R U K T U R A V E
if @PShrink=1
   Exec('DBCC SHRINKDATABASE ('+@PDBaseImpName+')')






GO
