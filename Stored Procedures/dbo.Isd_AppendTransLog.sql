SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE       Procedure [dbo].[Isd_AppendTransLog]
( 
  @PTableName     Varchar(60),
  @PNrRendor      Int,
  @PVlere         Float,
  @POperacion     Varchar(10),
  @PUser          Varchar(20),
  @PLgJob         Varchar(30)
 )
As

     -- Exec dbo.Isd_AppendTransLog 'ARKA',84703,0,'M','ADMIN','74199938'

         Set NoCount On

     Declare @User           Varchar(20),
             @NrRendor       Int,
             @TableName      Varchar(60),
             @Vlere          Float,
             @Operacion      Varchar(10),
             @OperacionDok   Varchar(10),
             @LgJob          Varchar(30),
             @Sql            Varchar(Max);

         Set @User         = @PUser 
         Set @NrRendor     = @PNrRendor 
         Set @TableName    = @PTableName 
         Set @Vlere        = @PVlere
         Set @Operacion    = @POperacion
         Set @LgJob        = @PLgJob;

     Declare @Tip            Varchar(30),
             @Master         Varchar(30),
             @NrID           Int,
             @Nrdok          Int,
             @NrFraks        Int,
             @DateDok        Varchar(20);

         Set @Tip          = @TableName;


          if CharIndex(','+@TableName+',',',FJ,FJT,ORK,OFK,SM,FF,ORF,')>0
             begin
          --
               if @TableName='FJ'
                  SELECT @NrID         = NRRENDOR,
                         @Master       = KODFKL,
                         @Nrdok        = NRDOK,
                         @NrFraks      = 0,
                         @DateDok      = Convert(Varchar,DATEDOK,104),
                         @Vlere        = VLERTOT,
                         @OperacionDok = KMAG
                    FROM FJ
                   WHERE NRRENDOR = @NrRendor;

               if @TableName='FJT'
                  SELECT @NrID         = NRRENDOR,
                         @Master       = KODFKL,
                         @Nrdok        = NRDOK,
                         @NrFraks      = 0,
                         @DateDok      = Convert(Varchar,DATEDOK,104),
                         @Vlere        = VLERTOT,
                         @OperacionDok = KMAG
                    FROM FJT
                   WHERE NRRENDOR = @NrRendor;

               if @TableName='ORK'
                  SELECT @NrID         = NRRENDOR,
                         @Master       = KODFKL,
                         @Nrdok        = NRDOK,
                         @NrFraks      = 0,
                         @DateDok      = Convert(Varchar,DATEDOK,104),
                         @Vlere        = VLERTOT,
                         @OperacionDok = KMAG
                    FROM ORK
                   WHERE NRRENDOR = @NrRendor;

               if @TableName='OFK'
                  SELECT @NrID         = NRRENDOR,
                         @Master       = KODFKL,
                         @Nrdok        = NRDOK,
                         @NrFraks      = 0,
                         @DateDok      = Convert(Varchar,DATEDOK,104),
                         @Vlere        = VLERTOT,
                         @OperacionDok = KMAG
                    FROM OFK
                   WHERE NRRENDOR = @NrRendor;

               if @TableName='SM'
                  SELECT @NrID         = NRRENDOR,
                         @Master       = KODFKL,
                         @Nrdok        = NRDOK,
                         @NrFraks      = 0,
                         @DateDok      = Convert(Varchar,DATEDOK,104),
                         @Vlere        = VLERTOT,
                         @OperacionDok = KMAG
                    FROM SM
                   WHERE NRRENDOR = @NrRendor;
          --
               if @TableName='FF'
                  SELECT @NrID         = NRRENDOR,
                         @Master       = KODFKL,
                         @Nrdok        = NRDOK,
                         @NrFraks      = 0,
                         @DateDok      = Convert(Varchar,DATEDOK,104),
                         @Vlere        = VLERTOT,
                         @OperacionDok = KMAG
                    FROM FF
                   WHERE NRRENDOR = @NrRendor;

               if @TableName='ORF'
                  SELECT @NrID         = NRRENDOR,
                         @Master       = KODFKL,
                         @Nrdok        = NRDOK,
                         @NrFraks      = 0,
                         @DateDok      = Convert(Varchar,DATEDOK,104),
                         @Vlere        = VLERTOT,
                         @OperacionDok = KMAG
                    FROM ORF
                   WHERE NRRENDOR = @NrRendor;
          --
             end;


          if CharIndex(','+@TableName+',',',ARKA,BANKA,')>0
             begin
               Set @Tip = Substring(@TableName,1,2);

               if  @TableName='ARKA'  
                   SELECT @NrID         = NRRENDOR,
                          @Master       = IsNull(TIPDOK,'')+': '+IsNull(KODAB,''),
                          @Nrdok        = NUMDOK,
                          @NrFraks      = 0,
                          @DateDok      = Convert(Varchar,DATEDOK,104),
                          @Vlere        = VLERA,
                          @OperacionDok = TIPDOK
                     FROM ARKA
                    WHERE NRRENDOR = @NrRendor;

               if  @TableName='BANKA'  
                   SELECT @NrID         = NRRENDOR,
                          @Master       = IsNull(TIPDOK,'')+': '+IsNull(KODAB,''),
                          @Nrdok        = NUMDOK,
                          @NrFraks      = 0,
                          @DateDok      = Convert(Varchar,DATEDOK,104),
                          @Vlere        = VLERA,
                          @OperacionDok = TIPDOK
                     FROM BANKA
                    WHERE NRRENDOR = @NrRendor;
             end;

          if CharIndex(','+@TableName+',',',FH,FD,')>0
             begin

               if @TableName='FH'
                  SELECT @NrID         = A.NRRENDOR,
                         @Master       = A.KMAG,
                         @Nrdok        = A.NRDOK,
                         @NrFraks      = A.NRFRAKS,
                         @DateDok      = Convert(Varchar,A.DATEDOK,104),
                      -- @Vlere        = @Vlere,
                         @OperacionDok = DST
                    FROM FH A
                   WHERE NRRENDOR = @NrRendor;

               if @TableName='FD'
                  SELECT @NrID         = A.NRRENDOR,
                         @Master       = A.KMAG,
                         @Nrdok        = A.NRDOK,
                         @NrFraks      = A.NRFRAKS,
                         @DateDok      = Convert(Varchar,A.DATEDOK,104),
                      -- @Vlere        = @Vlere,
                         @OperacionDok = A.DST
                    FROM FD A
                   WHERE A.NRRENDOR = @NrRendor;
             end;


          if @TableName='DG'  
             begin
                  SELECT @NrID         = A.NRRENDOR,
                         @Master       = A.KOD,
                         @Nrdok        = A.NRDOK,
                         @NrFraks      = 0,
                         @DateDok      = Convert(Varchar,A.DATEDOK,104),
                      -- @Vlere        = @Vlere,
                         @OperacionDok = A.NIPT
                    FROM DG A
                   WHERE A.NRRENDOR = @NrRendor;
             end;


          if @TableName='AQ'
             begin  
                  SELECT @NrID         = A.NRRENDOR,
                         @Master       = @TableName,
                         @Nrdok        = MAX(ISNULL(A.NRDOK,0)),
                         @NrFraks      = MAX(A.NRFRAKS),
                         @DateDok      = CONVERT(VARCHAR,MAX(A.DATEDOK),104),
                         @Vlere        = SUM(ISNULL(CASE WHEN A.DST='AM' THEN B.VLERAAM ELSE B.VLERABS END,0)),
                         @OperacionDok = MAX(A.DST)
                    FROM AQ A Inner Join AQSCR B On A.NRRENDOR=B.NRD
                   WHERE A.NRRENDOR = @NrRendor
                GROUP BY A.NRRENDOR;
             end;   


          if CharIndex(','+@TableName+',',',FK,VS,FKST,VSST,')>0
             begin

               if @TableName='VS'  
                  SELECT @NrID         = A.NRRENDOR,
                         @Master       = @TableName,
                         @Nrdok        = A.NRDOK,
                         @NrFraks      = 0,
                         @DateDok      = Convert(Varchar,A.DATEDOK,104),
                      -- @Vlere        = @Vlere,
                         @OperacionDok = @TableName
                    FROM VS A
                   WHERE A.NRRENDOR = @NrRendor;

               if @TableName='FK'  
                  SELECT @NrID         = A.NRRENDOR,
                         @Master       = @TableName+': '+
                                         IsNull(A.TIPDOK,'')+' nr '+
                                         Cast(Cast(A.NUMDOK As BigInt) As Varchar)+
                                         Case When A.ORG='T' Or IsNull(A.REFERDOK,'')=''
                                              Then ''
                                              Else ' /'+A.REFERDOK+'/' End,
                         @Nrdok        = A.NRDOK,
                         @NrFraks      = 0,
                         @DateDok      = Convert(Varchar,A.DATEDOK,104),
                      -- @Vlere        = @Vlere,
                         @OperacionDok = @TableName
                    FROM FK A 
                   WHERE A.NRRENDOR = @NrRendor;
                  
               if @TableName='VSST'  
                  SELECT @NrID         = A.NRRENDOR,
                         @Master       = @TableName,
                         @Nrdok        = Max(IsNull(A.NRDOK,0)),
                         @NrFraks      = 0,
                         @DateDok      = Convert(Varchar,Max(A.DATEDOK),104),
                         @Vlere        = Sum(IsNull(B.DB,0)),
                         @OperacionDok = @TableName
                    FROM VSST A Inner Join VSSTSCR B On A.NRRENDOR=B.NRD
                   WHERE A.NRRENDOR = @NrRendor
                GROUP BY A.NRRENDOR;

               if @TableName='FKST'  
                  SELECT @NrID         = A.NRRENDOR,
                         @Master       = @TableName,
                         @Nrdok        = Max(IsNull(A.NRDOK,0)),
                         @NrFraks      = 0,
                         @DateDok      = Convert(Varchar,Max(A.DATEDOK),104),
                         @Vlere        = Sum(IsNull(B.DB,0)),
                         @OperacionDok = @TableName
                    FROM FKST A Inner Join FKSTSCR B On A.NRRENDOR=B.NRD
                   WHERE A.NRRENDOR = @NrRendor
                GROUP BY A.NRRENDOR;
     
             end;

--Print @TableName;
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

          if IsNull(@NrID,0)>0 Or (CharIndex(','+@TableName+',',',RIVLMG,')>0)
             Exec dbo.Isd_AppendLog @User,      @NrID,         @Tip,     @Master,       
                                    @Nrdok,     @NrFraks,      @DateDok, @Vlere,
                                    @Operacion, @OperacionDok, @LgJob; 




GO
