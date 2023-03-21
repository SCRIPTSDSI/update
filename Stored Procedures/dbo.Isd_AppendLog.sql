SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Exec [Isd_AppendLog] @PUser='ADMIN', @PNrRendor=1, @PTip='FJ', @PMaster='FJ', @PNrdok=100, @PNrFraks=0, @PDateDok='27.01.2012', @PVlere=1000, @POperacion='D', @POperacionDok='SH', @PLgJob='11111'

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
--  Select  @PNrRendor= 1, @PTip='FJ', @PMaster='FJ', @PNrdok=100, @PNrFraks =0, @PDateDok='27.01.2012', @PVlere=1000, @POperacion='D', @POperacionDok='SH', @PUser='ADMIN', @PLgJob='11111'


CREATE        Procedure [dbo].[Isd_AppendLog]
  ( 
    @PUser              VARCHAR(20),
    @PNrRendor          INT,
    @PTip               VARCHAR(30),
    @PMaster            VARCHAR(30),
    @PNrdok             INT,
    @PNrFraks           INT,
    @PDateDok           VARCHAR(20),
    @PVlere             FLOAT,
    @POperacion         VARCHAR(10),
    @POperacionDok      VARCHAR(10),
    @PLgJob             VARCHAR(30)     
  )

AS


        SET NOCOUNT ON

    DECLARE @DateTime   DATETIME,
            @Time       VARCHAR(50),
            @Date       VARCHAR(50),
            @LgJob      VARCHAR(30);

        SET @LgJob    = @PLgJob;

      INSERT INTO DITARVEPRIME 
            (NRRENDORDOK,TIP,[MASTER],NRDOK,NRFRAKS,VLERE,
             OPERACION,
             KODUSER,
             DATEDOK,
             DATEMOD,
             DATETIMEMOD,
             ORA,
             OPERACIONDOK,
             LGJOB,
             PCNAME,
             PCIP,
             TAGNR,TROW) 

     SELECT  @PNrRendor,LEFT(@PTip,10),@PMaster,@PNrDok,@PNrFraks,@PVlere,
             @POperacion,
             @PUser,
             Dbo.DateValue(@PDateDok),
             Dbo.DateValue(CONVERT(VARCHAR(10),GETDATE(),104)),
             GETDATE(),
             RIGHT('00'  + CAST(DATEPART(HH, GETDATE()) AS VARCHAR),2)+':'+
             RIGHT('00'  + CAST(DATEPART(MI, GETDATE()) AS VARCHAR),2)+':'+
             RIGHT('00'  + CAST(DATEPART(SS, GETDATE()) AS VARCHAR),2)+'.'+
             RIGHT('000' + CAST(DATEPART(MS, GETDATE()) AS VARCHAR(3)),3),
             @POperacionDok,
             @LgJob,
             HOST_NAME(),
            (SELECT TOP 1 CLIENT_NET_ADDRESS FROM MASTER.SYS.DM_EXEC_CONNECTIONS WHERE SESSION_ID = @@SPID),
             0,0;
             
GO
