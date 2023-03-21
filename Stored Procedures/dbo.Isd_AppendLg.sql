SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Exec [Isd_AppendLg] 
--          @PUser         ='ADMIN',
--          @PNrRendor     = 1,
--          @PTip          ='FJ',
--          @PMaster       ='FJ',
--          @PNrdok        =100,
--          @PNrFraks      =0,
--          @PDateDok      ='27.01.2012',
--          @PVlere        =1000,
--          @POperacion    ='D',
--          @POperacionDok ='SH',
--          @PLgJob        ='11111'
       

CREATE        Procedure [dbo].[Isd_AppendLg]
  ( 
    @PUser         Varchar(20),
    @PNrRendor     Int,
    @PTip          Varchar(30),
    @PMaster       Varchar(30),
    @PNrdok        Int,
    @PNrFraks      Int,
    @PDateDok      Varchar(20),
    @PVlere        Float,
    @POperacion    Varchar(10),
    @POperacionDok Varchar(10),
    @PLgJob        Varchar(30)
  )
as
Set NoCount Off


--  Declare @PNrRendor     Int,
--          @PTip          Varchar(30),
--          @PMaster       Varchar(30),
--          @PNrdok        Int,
--          @PNrFraks      Int,
--          @PDateDok      Varchar(20),
--          @PVlere        Float,
--          @POperacion    Varchar(10),
--          @POperacionDok Varchar(10),
--          @PUser         Varchar(20),
--          @PLgJob        Varchar(30)

--  Select  @PNrRendor     = 1,
--          @PTip          ='FJ',
--          @PMaster       ='FJ',
--          @PNrdok        =100,
--          @PNrFraks      =0,
--          @PDateDok      ='27.01.2012',
--          @PVlere        =1000,
--          @POperacion    ='D',
--          @POperacionDok ='SH',
--          @PUser         ='ADMIN'
--          @PLgJob        ='11111'

Declare @DateTime DateTime,
        @Time     Varchar(50),
        @Date     Varchar(50),
        @LgJob    Varchar(50)

if @PLgJob is Null
   Set @LgJob = IsNull(@PLgJob,'')
Return
INSERT INTO  DITARVEPRIME 
            (NRRENDORDOK,TIP,MASTER,NRDOK,NRFRAKS,VLERE,
             OPERACION,KODUSER,
             DATEDOK,
             DATEMOD,
             DATETIMEMOD,
             ORA,
             OPERACIONDOK,
             LGJOB,
             PCNAME,
             PCIP) 
     SELECT  @PNrRendor,Left(@PTip,2),@PMaster,@PNrDok,@PNrFraks,@PVlere,
             @POperacion,@PUser,
             Dbo.DateValue(@PDateDok),
             Dbo.DateValue(Convert(Varchar(10),GetDate(),104)),
             GETDATE(),
             RIGHT('00' +CAST(DATEPART(hh, GetDate()) AS VARCHAR),2)+':'+
             RIGHT('00' +CAST(DATEPART(mi, GetDate()) AS VARCHAR),2)+':'+
             RIGHT('00' +CAST(DATEPART(ss, GetDate()) AS VARCHAR),2)+'.'+
             RIGHT('000'+CAST(DATEPART(ms, GetDate()) AS VARCHAR(3)),3),
             @POperacionDok,
             @LgJob,
             HOST_NAME(),
            (SELECT TOP 1 client_net_address
               FROM MASTER.sys.dm_exec_connections
              WHERE Session_id = @@SPID)
             
GO
