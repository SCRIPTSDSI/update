SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE       Procedure [dbo].[Isd_AppendTransLogGr]
( 
  @PTableName     Varchar(60),
  @PNrRendor      Int,
  @PWhere         Varchar(Max),
  @PKoment        Varchar(200),
  @PVlere         Float,
  @POperacion     Varchar(10),
  @PUser          Varchar(20),
  @PLgJob         Varchar(30)
 )
As

     -- Exec dbo.Isd_AppendTransLogGr 'ARKA',84703,'DATEDOK<=dbo.DATEVALUE(''03/01/2014'')','Veprim automatik ne grup ...',0,'F','ADMIN','74199938'

         Set NoCount On

     Declare @TableName      Varchar(60),
             @NrRendor       Int,
             @Where          Varchar(Max),
             @Koment         Varchar(200),
          -- @Vlere          Float,
             @Operacion      Varchar(10),
             @User           Varchar(20),
             @LgJob          Varchar(30),

             @OperacionDok   Varchar(10),
             @sSql          nVarchar(Max);

         Set @NrRendor     = @PNrRendor 
         Set @TableName    = @PTableName 
         Set @Where        = @PWhere
         Set @Koment       = @PKoment
      -- Set @Vlere        = @PVlere
         Set @Operacion    = @POperacion
         Set @User         = @PUser 
         Set @LgJob        = @PLgJob;
     
     Declare @Tip            Varchar(30);
--           @Master         Varchar(30),
--           @NrID           Int,
--           @Nrdok          Int,
--           @NrFraks        Int,
--           @DateDok        Varchar(20);

         Set @Tip          = @TableName;
          if @Operacion='D'
             Set @Operacion = 'F';

          if Object_Id('TempDb..#TblLog') is not null
             Drop Table #TblLog;

      Select NrID         = Cast(NRRENDOR As BigInt),
             KodMaster    = KODFKL,
             Nrdok        = NRDOK,
             NrFraks      = 0,
             DateDok      = DATEDOK,
             Vlere        = VLERTOT,
             OperacionDok = KMAG
        Into #TblLog
        From FJ
       Where 1=2;


          if CharIndex(','+@TableName+',',',FJ,FJT,ORK,OFK,SM,FF,ORF,')>0
             begin
               Set   @sSql = '
                 INSERT INTO #TblLog
                       (NrID, KodMaster, Nrdok, NrFraks, DateDok, Vlere, OperacionDok)
                 SELECT NRRENDOR,KODFKL,NRDOK,0,DATEDOK,VLERTOT,KMAG
                   FROM '+@TableName+'
                  WHERE 1 = 2; ';
             end;


          if CharIndex(','+@TableName+',',',FH,FD,')>0
             begin
               Set @sSql = '
                 INSERT INTO #TblLog
                       (NrID, KodMaster, Nrdok, NrFraks, DateDok, Vlere, OperacionDok)
                 SELECT NRRENDOR,KMAG,NRDOK,NRFRAKS,DATEDOK,0,DST
                   FROM '+@TableName+' 
                  WHERE 1 = 2; ';
             end;


          if @TableName='DG'  
             begin
               Set @sSql = '
                 INSERT INTO #TblLog
                       (NrID, KodMaster, Nrdok, NrFraks, DateDok, Vlere, OperacionDok)
                 SELECT NRRENDOR,KOD,NRDOK,0,DATEDOK,0,NIPT
                   FROM DG
                  WHERE 1 = 2; '
             end;


          if CharIndex(','+@TableName+',',',ARKA,BANKA,')>0
             begin
               Set @Tip = Substring(@TableName,1,2);
               Set @sSql = '  
                 INSERT INTO #TblLog
                       (NrID, KodMaster, Nrdok, NrFraks, DateDok, Vlere, OperacionDok)
                 SELECT NRRENDOR,IsNull(TIPDOK,'''')+'': ''+IsNull(KODAB,''''),
                        NUMDOK,0,DATEDOK,VLERA,TIPDOK
                   FROM '+@TableName+'
                  WHERE 1 = 2; '
             end;


          if CharIndex(','+@TableName+',',',FK,VS,FKST,VSST,')>0
             begin

               if @TableName='VS'  
                  begin
                    Set @sSql = '
                 INSERT INTO #TblLog
                       (NrID, KodMaster, Nrdok, NrFraks, DateDok, Vlere, OperacionDok)
                 SELECT NRRENDOR,'''+@TableName+''',NRDOK,DATEDOK,0,'''+@TableName+'''
                    FROM VS 
                   WHERE 1 = 2; '
                  end;


               if @TableName='FK'  
                  begin
                    Set @sSql = '
                 INSERT INTO #TblLog
                       (NrID, KodMaster, Nrdok, NrFraks, DateDok, Vlere, OperacionDok)

                 SELECT NRRENDOR,'''+@TableName+'''+'': ''+
                                     IsNull(TIPDOK,'''')+'' nr ''+
                                     Cast(Cast(NUMDOK As BigInt) As Varchar)+
                                     Case When ORG=''T'' Or IsNull(REFERDOK,'''')=''''
                                              Then ''''
                                              Else '' /''+REFERDOK+''/'' End,
                        NRDOK,0,DATEDOK,0,'''+@TableName+'''
                   FROM FK  
                  WHERE 1 = 2; '
                  end;


               if @TableName='VSST' Or @TableName='FKST'
                  begin
                    Set @sSql = '
                 INSERT INTO #TblLog
                       (NrID, KodMaster, Nrdok, NrFraks, DateDok, Vlere, OperacionDok)

                 SELECT A.NRRENDOR,'''+@TableName+''',Max(IsNull(A.NRDOK,0)),0,Max(A.DATEDOK),
                        Sum(IsNull(B.DB,0)),'''+@TableName+'''
                   FROM VSST A Inner Join VSSTSCR B On A.NRRENDOR=B.NRD
                  WHERE 1 = 2
               GROUP BY A.NRRENDOR; '
                  end;

             end;

/*   -- A Duhen ..?

          if CharIndex(','+@TableName+',',',ARTIKUJKF,KLIENTCMIM,RIVLMG,')>0
             begin
               if @TableName='ARTIKUJKF'  
                  SELECT @NrID         = A.NRRENDOR,
                         @Master       = A.KMAG+'/'+A.KOD,
                         @Nrdok        = 0,
                         @NrFraks      = 0,
                         @DateDok      = Convert(Varchar,GetDate(),104),
                         @Vlere        = 0,
                         @OperacionDok = @TableName
                    FROM ARTIKUJKF A 
                   WHERE A.NRRENDOR = @NrRendor;

               if @TableName='KLIENTCMIM'  
                  SELECT @NrID         = A.NRRENDOR,
                         @Master       = A.KOD,
                         @Nrdok        = 0,
                         @NrFraks      = 0,
                         @DateDok      = Convert(Varchar,A.DATESTART,104),
                         @Vlere        = 0,
                         @OperacionDok = @TableName
                    FROM KLIENTCMIM A 
                   WHERE A.NRRENDOR = @NrRendor;

               if @TableName='RIVLMG'  
                  SELECT @NrID         = @NrRendor,
                         @Master       = 'RivleresimMg',
                         @Nrdok        = 0,
                         @NrFraks      = 0,
                         @DateDok      = Convert(Varchar,GetDate(),104),
                         @Vlere        = 0,
                         @OperacionDok = @TableName;
             end;
*/

          if @sSql=''
             Return;


          if @Where<>''
             Set   @sSql = Replace(@sSql,'1 = 2',@Where);

--     Print @sSql;
       Exec (@sSql);


      Insert Into  DITARVEPRIME 
            (NRRENDORDOK,TIP,[MASTER],NRDOK,NRFRAKS,VLERE,
             OPERACION,
             KODUSER,
             DATEDOK,
             DATEMOD,
             DATETIMEMOD,
             ORA,
             OPERACIONDOK,
             KOMENT,
             LGJOB,
             PCNAME,
             PCIP,
             TAGNR,TROW) 

     Select  NrID,Left(@Tip,10),KODMASTER,NRDOK,NRFRAKS,VLERE,
             @Operacion,
             @User,
             DATEDOK,
             Dbo.DateValue(Convert(Varchar(10),GetDate(),104)),
             GetDate(),
             Right('00'  + Cast(DatePart(hh, GetDate()) As Varchar),2)+':'+
             Right('00'  + Cast(DatePart(mi, GetDate()) As Varchar),2)+':'+
             Right('00'  + Cast(DatePart(ss, GetDate()) As Varchar),2)+'.'+
             Right('000' + Cast(DatePart(ms, GetDate()) As Varchar(3)),3),
             OPERACIONDOK,@Koment,
             @LgJob,
             Host_Name(),
            (Select Top 1 Client_Net_Address
               From MASTER.Sys.Dm_Exec_Connections
              Where Session_Id = @@SPID),
             0,0
        From #TblLog
  --Order By NRRENDOR;



/*
      Insert Into  DITARVEPRIME 
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

     Select  @PNrRendor,Left(@PTip,10),@PMaster,@PNrDok,@PNrFraks,@PVlere,
             @POperacion,
             @PUser,
             Dbo.DateValue(@PDateDok),
             Dbo.DateValue(Convert(Varchar(10),GetDate(),104)),
             GetDate(),
             Right('00'  + Cast(DatePart(hh, GetDate()) As Varchar),2)+':'+
             Right('00'  + Cast(DatePart(mi, GetDate()) As Varchar),2)+':'+
             Right('00'  + Cast(DatePart(ss, GetDate()) As Varchar),2)+'.'+
             Right('000' + Cast(DatePart(ms, GetDate()) As Varchar(3)),3),
             @POperacionDok,
             @LgJob,
             Host_Name(),
            (Select Top 1 Client_Net_Address
               From MASTER.Sys.Dm_Exec_Connections
              Where Session_Id = @@SPID),0,0;

          if IsNull(@NrID,0)>0 Or (CharIndex(','+@TableName+',',',RIVLMG,')>0)
             Exec dbo.Isd_AppendLog @User,      @NrID,         @Tip,     @Master,       
                                    @Nrdok,     @NrFraks,      @DateDok, @Vlere,
                                    @Operacion, @OperacionDok, @LgJob; 

*/






--     if Pos(TableName,',FJ,FF,FJT,ORK,ORF,OFK,SM,')
--        AppendLog(Connection,
--                FieldByName('NRRENDOR').AsInteger,
--                PTableName,
--                FieldByName('KODFKL').AsString,
--                FieldByName('NRDOK').AsInteger,
--                0,
--                FieldByName('DATEDOK').AsDateTime,
--                FieldByName('VLERTOT').AsFloat,
--                PIEDStatus,
--                FieldByName('KMAG').AsString)


--      if Pos(TableName,',ARKA,BANKA,')<>0 then
--         AppendLog(Connection,
--                FieldByName('NRRENDOR').AsInteger,
--                Copy(PTableName,1,2),
--                FieldByName('TIPDOK').AsString+': '+FieldByName('KODAB').AsString,
--                FieldByName('NUMDOK').AsInteger,
--                0,
--                FieldByName('DATEDOK').AsDateTime,
--                FieldByName('VLERA').AsFloat,
--                PIEDStatus,
--                FieldByName('TIPDOK').AsString)


--      if Pos(TableName,',FH,FD,')<>0 then
--         AppendLog(Connection,
--                FieldByName('NRRENDOR').AsInteger,
--                PTableName,
--                FieldByName('KMAG').AsString,
--                FieldByName('NRDOK').AsInteger,
--                FieldByName('NRFRAKS').AsInteger,
--                FieldByName('DATEDOK').AsDateTime,
--                @PVlere,
--                PIEDStatus,
--                FieldByName('DST').AsString)


--      if PTableName='DG' then
--         AppendLog(Connection,
--                FieldByName('NRRENDOR').AsInteger,
--                PTableName,
--                FieldByName('KOD').AsString,
--                FieldByName('NRDOK').AsInteger,
--                0,
--                FieldByName('DATEDOK').AsDateTime,
--                PVlefte,
--                PIEDStatus,
--                FieldByName('NIPT').AsString);


--      if PTableName='VS' then
--         AppendLog(Connection,
--                FieldByName('NRRENDOR').AsInteger,
--                PTableName,
--                PTableName,
--                FieldByName('NRDOK').AsInteger,
--                0,
--                FieldByName('DATEDOK').AsDateTime,
--                PVlefte,
--                PIEDStatus,
--                PTableName)



GO
