SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE       Procedure [dbo].[Isd_DocSaveLM]
( 
  @PTableName     Varchar(30),
  @PNrRendor      Int,
  @PPerdorues     Varchar(30),
  @PLgJob         Varchar(30),
  @PIDMStatus     Varchar(10),
  @PTableTmp      Varchar(30)
 )

As

-- Exec dbo.Isd_DocSaveLM 'ARKA',94428,'ADMIN','','M','##A001'

Begin  

-- Declare @PTableName     Varchar(30),
--         @PNrRendor      Int,
--         @PPerdorues     Varchar(30),
--         @PLgJob         Varchar(30),
--         @PIDMStatus     Varchar(10);

--     Set @PTableName   = 'ARKA';
--     Set @PNrRendor    = 94428; 
--     Set @PPerdorues   = 'ADMIN'
--     Set @PLgJob       = '1234567890'
--     Set @PIDMStatus   = 'M';



         Set NoCount On


     Declare @TableName      Varchar(30),
             @NrRendor       Int,
             @Perdorues      Varchar(30),
             @LgJob          Varchar(30),
             @IDMStatus      Varchar(10),
             @TableTmp       Varchar(30),
             @Transaksion    Varchar(20),

             @NrRendorFk     Int,
             @AutoPostLM     Bit,
             @Org            Varchar(5),
             @Vlere          Float;

         Set @Transaksion  = 'IFMDS';  -- Delete me F apo D, Insert me I apo S

         Set @TableName    = IsNull(@PTableName,'');
         Set @NrRendor     = IsNull(@PNrRendor,0);
         Set @Perdorues    = @PPerdorues;
         Set @LgJob        = @PLgJob;
         Set @IDMStatus    = IsNull(@PIDMStatus,'');
         Set @TableTmp     = IsNull(@PTableTmp,'');

          if CharIndex(','+@TableName+',',',ARKA,BANKA,VS,FK,VSST,FKST,')<=0 Or @NrRendor<=0 Or @IDMStatus=''
             Return;


         Set @AutoPostLM   = 0;

      Select @AutoPostLM   = Case When @TableName='ARKA'
                                       Then IsNull(AUTOPOSTLMAR,0)
                                  When @TableName='BANKA'
                                       Then IsNull(AUTOPOSTLMBA,0) 
                                  When @TableName='VS'
                                       Then IsNull(AUTOPOSTLMVS,0)
                                  Else 0 End
        From CONFIGLM;

         Set @AutoPostLM     = IsNull(@AutoPostLM,0);    

          if @AutoPostLM=1 And @TableTmp<>''
             begin
               if Object_Id('TempDB..'+@TableTmp) is not null
                  Exec ('DELETE FROM '+@TableTmp);
             end;



--      Test per Kod-e, referenca, kurse etj.
        Exec dbo.Isd_DocSaveTestFields @TableName,@NrRendor,@IDMStatus;



          if @TableName='ARKA'
             begin

                  Set @Org          = 'A'

               Delete 
                 From ARKASCR
                Where NRD=@NrRendor And IsNull(KODAF,'')='';

               Select @NrRendorFk   = NRDFK,
                      @Vlere        = VLERA
                 From ARKA
                Where NRRENDOR = @NrRendor;

                 Exec dbo.Isd_GjenerimDitarOne @TableName, 0, @NrRendor;
              -- Exec dbo.Isd_GjenerimDitarOne @TableName, 1, @NrRendor;

                   if CharIndex(@IDMStatus,@Transaksion)>0  
                      Exec dbo.Isd_AppendTransLog   @TableName, @NrRendor, @Vlere,@IDMStatus,@Perdorues,@LgJob;

                   if @NrRendorFk>=1
                      begin
                        Delete 
                          From FK 
                         Where NrRendor=@NrRendorFk;

                        Update ARKA
                           Set NRDFK=0
                         Where NRRENDOR = @NrRendor;
                      end;
                   if @AutoPostLM=1
                      Exec [Isd_KalimLM] @Org, @NrRendor ,'',@TableTmp;
             end;


          if @TableName='BANKA'
             begin

                  Set @Org          = 'B'

               Delete 
                 From BANKASCR
                Where NRD=@NrRendor And IsNull(KODAF,'')='';

               Select @NrRendorFk   = NRDFK,
                      @Vlere        = VLERA
                 From BANKA
                Where NRRENDOR = @NrRendor;

                 Exec dbo.Isd_GjenerimDitarOne @TableName, 0, @NrRendor;
              -- Exec dbo.Isd_GjenerimDitarOne @TableName, 1, @NrRendor;

                   if CharIndex(@IDMStatus,@Transaksion)>0  
                      Exec dbo.Isd_AppendTransLog   @TableName, @NrRendor, @Vlere,@IDMStatus,@Perdorues,@LgJob;

                   if @NrRendorFk>=1
                      begin
                        Delete 
                          From FK 
                         Where NrRendor=@NrRendorFk;

                        Update BANKA
                           Set NRDFK=0
                         Where NRRENDOR = @NrRendor;
                      end;
                   if @AutoPostLM=1
                      Exec [Isd_KalimLM] @Org, @NrRendor ,'',@TableTmp;
             end;


          if @TableName='VS'
             begin

                  Set @Org          = 'E'

               Delete 
                 From VSSCR
                Where NRD=@NrRendor And IsNull(KODAF,'')='';

               Select @NrRendorFk   = Max(IsNull(A.NRDFK,0)),
                      @Vlere        = Sum(IsNull(B.DB,0))
                 From VS A Inner Join VSSCR B On A.NRRENDOR=B.NRD
                Where A.NRRENDOR = @NrRendor
             Group By A.NRRENDOR;

                 Exec dbo.Isd_GjenerimDitarOne @TableName, 0, @NrRendor;
              -- Exec dbo.Isd_GjenerimDitarOne @TableName, 1, @NrRendor;

                   if CharIndex(@IDMStatus,@Transaksion)>0  
                      Exec dbo.Isd_AppendTransLog   @TableName, @NrRendor, @Vlere,@IDMStatus,@Perdorues,@LgJob;

                   if @NrRendorFk>=1
                      begin
                        Delete 
                          From FK 
                         Where NrRendor=@NrRendorFk;

                        Update VS
                           Set NRDFK=0
                         Where NRRENDOR = @NrRendor;
                     end;
                  if @AutoPostLM=1
                     Exec [Isd_KalimLM] @Org, @NrRendor ,'',@TableTmp;
             end;

          if @TableName='FK'
             begin

                 Exec dbo.Isd_KrijimKodLM  @NrRendor,0;

               Delete 
                 From FKSCR
                Where NRD=@NrRendor And IsNull(LLOGARI,'')='';

               Select @Vlere        = Sum(IsNull(B.DB,0))
                 From FK A Inner Join FKSCR B On A.NRRENDOR=B.NRD
                Where A.NRRENDOR = @NrRendor
             Group By A.NRRENDOR;

                   if CharIndex(@IDMStatus,@Transaksion)>0  
                      Exec dbo.Isd_AppendTransLog   @TableName, @NrRendor, @Vlere,@IDMStatus,@Perdorues,@LgJob;

             end;


          if @TableName='VSST'
             begin

               Delete 
                 From VSSTSCR
                Where NRD=@NrRendor And IsNull(KODAF,'')='';

               Select @Vlere        = Sum(IsNull(B.DB,0))
                 From VSST A Inner Join VSSTSCR B On A.NRRENDOR=B.NRD
                Where A.NRRENDOR = @NrRendor
             Group By A.NRRENDOR;

                   if CharIndex(@IDMStatus,@Transaksion)>0  
                      Exec dbo.Isd_AppendTransLog   @TableName, @NrRendor, @Vlere,@IDMStatus,@Perdorues,@LgJob;

             end;


          if @TableName='FKST'
             begin

               Delete 
                 From FKSTSCR
                Where NRD=@NrRendor And IsNull(LLOGARI,'')='';

               Select @Vlere        = Sum(IsNull(B.DB,0))
                 From FKST A Inner Join FKSTSCR B On A.NRRENDOR=B.NRD
                Where A.NRRENDOR = @NrRendor
             Group By A.NRRENDOR;

                   if CharIndex(@IDMStatus,@Transaksion)>0  
                      Exec dbo.Isd_AppendTransLog   @TableName, @NrRendor, @Vlere,@IDMStatus,@Perdorues,@LgJob;

             end;


End;
GO
