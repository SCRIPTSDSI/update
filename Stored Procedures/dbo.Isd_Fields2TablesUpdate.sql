SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--Declare @PDb1        Varchar(30),
--        @PDb2        Varchar(30),
--        @PTable1     Varchar(30),
--        @PTable2     Varchar(30),
--        @PFieldsEx   Varchar(Max),
--        @FieldsUpd   Varchar(Max),
--        @PWhere      Varchar(Max)
--
--	  Set @PDb1      = 'TEMPDB'
--	  Set @PDb2      = 'EHW13'
--	  Set @PTable1   = '##RFReady96656358'
--	  Set @PTable2   = 'ARTIKUJ'
--    Set @FieldsUpd = 'KLASIF,KLASIF2'
--    Set @PFieldsEx = 'NRRENDOR,USI,USM'
--    Set @PWhere    = 'IsNull(A.EgzistRef,'''')=''E'' ';

--   Exec dbo.Isd_Fields2TablesUpdate @PDb1       = @PDb1, 
--                                    @PDb2       = @PDb2, 
--                                    @PTable1    = @PTable1, 
--                                    @PTable2    = @PTable2, 
--                                    @PFieldsUpd = @PFieldsUpd,
--                                    @PFieldsEx  = @PFieldsEx,
--                                    @PWhere     = @PWhere


CREATE     Procedure [dbo].[Isd_Fields2TablesUpdate]
( 
  @PDb1        Varchar(50),
  @PDb2        Varchar(50),
  @PTable1     Varchar(50),
  @PTable2     Varchar(50),
  @PFieldsUpd  Varchar(Max),
  @PFieldsEx   Varchar(Max),
  @PWhere      Varchar(Max)
 )
as

        --Set NoCount On


    Declare @UpdFields  Varchar(Max),
            @List1      Varchar(Max),
            @Sql        nVarchar(Max),
            @Db1Name    Varchar(30),
            @Db2Name    Varchar(30),
            @T1Name     Varchar(30),
            @T2Name     Varchar(30),
            @Tbl1Name   Varchar(50),
            @Tbl2Name   Varchar(50),
            @FieldsUpd  Varchar(Max),
            @FieldsEx   Varchar(Max);

        Set @Db1Name   = @PDb1;
        Set @Db2Name   = @PDb2;
        Set @T1Name    = @PTable1
        Set @T2Name    = @PTable2;
        Set @Tbl1Name  = @Db1Name+'..'+@T1Name 
        Set @Tbl2Name  = @Db2Name+'..'+@T2Name
        Set @FieldsEx  = @PFieldsEx
        Set @FieldsUpd = @PFieldsUpd; 
        Set @UpdFields = '';

        if  dbo.Isd_StringInListInd(@FieldsEx,'NRRENDOR',',')<=0
            begin
              if @FieldsEx=''
                 Set @FieldsEx = 'NRRENDOR'
              else
                 Set @FieldsEx = @FieldsEx+',NRRENDOR';
            end;

       Exec dbo.Isd_spFields2Tables @Db1Name,@Db2Name,@T1Name,@T2Name,@FieldsEx,@UpdFields Output

         if @FieldsUpd<>'' and CharIndex('*',@FieldsUpd)=0
            Set @UpdFields = [dbo].[Isd_ListFields2Lists](@UpdFields,@FieldsUpd,'');

     Select @UpdFields=[dbo].[Isd_ListFieldsUpdate](@UpdFields,'B','A');



        Set @Sql = '

            UPDATE B
               SET ' + @UpdFields  + '
              FROM ' + @Tbl1Name + ' A INNER JOIN ' + @Tbl2Name + ' B ON A.KOD=B.KOD 
             WHERE 1=1 ';        


         if CharIndex(','+@Tbl1Name+',',',CONFND,CONFIGMG,CONFIGLM,')>0 And
            CharIndex(','+@Tbl2Name+',',',CONFND,CONFIGMG,CONFIGLM,')>0
            begin

              Set @Sql = '

            UPDATE B 
               SET ' + @UpdFields  + '
              FROM ' + @Tbl1Name + ' A, ' + @Tbl2Name + ' B 
             WHERE 1=1 '; 

            end;

         if @PWhere<>''
            Set @Sql = Replace(@Sql,'1=1',@PWhere);

      Print  @Sql
       Exec (@Sql);

/*
        Set @Sql = '
       SELECT '+@FieldsUpd+'
         FROM '+@Tbl1Name+' ORDER BY KOD 
       SELECT '+@FieldsUpd+'
         FROM '+@Tbl2Name+' ORDER BY KOD ';
      Exec (@Sql); 
  
*/
GO
