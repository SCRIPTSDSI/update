SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE     procedure [dbo].[Isd_AlterTables]
(
  @PDataBase    Varchar(40),
  @PTablesList  Varchar(2000),
  @PFieldsList  Varchar(2000),
  @PFieldType   Varchar(40),
  @PFieldDef    Varchar(40),
  @PFieldValue  Varchar(100)
 )

As

         Set NoCount on;


     Declare @sSql       nVarchar(Max),
             @sSql1      nVarchar(Max),
             @sSql2      nVarchar(Max),
             @i          Int,
             @j          Int,
             @k          Int,
             @l          Int,
             @DataBase   Varchar(100),
             @TablesList Varchar(2000),
             @FieldsList Varchar(2000),
             @TableName  Varchar(40),
             @FieldName  Varchar(40),
             @FieldType  Varchar(40),
             @FieldDef   Varchar(40),
             @FieldValue Varchar(100),
             @sSqlEx     Varchar(200);


         Set @TablesList = @PTablesList; 
         Set @FieldsList = @PFieldsList;
         Set @FieldType  = @PFieldType;
         Set @FieldDef   = @PFieldDef;
         Set @FieldValue = @PFieldValue;
         Set @DataBase   = '';
         Set @sSqlEx     = '';

          if @TablesList='' And @FieldsList=''
             Return;


          if @PDataBase<>''
             Set @DataBase = '
          USE '+@PDataBase+';';

          if (@FieldValue<>'') 
             Set @sSqlEx = '
                Exec (''UPDATE _TABLENAME_ SET _FIELDNAME_ = '+@FieldValue+''');';


         set @sSql = ''+@DataBase+'
           if not Exists (Select [Name]
                            From Sys.Columns
                           Where Object_Id = Object_Id(''_TABLENAME_'') And ([Name]=''_FIELDNAME_''))
              begin
                ALTER TABLE _TABLENAME_ ADD _FIELDNAME_ _FIELDTYPE_ _FIELDDEF_;
                Print ''Shtim fusha _FIELDNAME_ ne _TABLENAME_: _FIELDTYPE_ _FIELDDEF_''; '+@sSqlEx+'
              end; ';

         Set @sSql = Replace(@sSql,'_FIELDTYPE_',@FieldType);
         Set @sSql = Replace(@sSql,'_FIELDDEF_', @FieldDef);



         Set @i = 1;
         Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;



       while @i <= @k

          begin
            Set @TableName = Replace(dbo.Isd_StringInListStr(@TablesList,@i,','),' ','');
            Set @sSql1     = Replace(@sSql,'_TABLENAME_',@TableName);

            Set @j = 1;
            Set @l = Len(@FieldsList) - Len(Replace(@FieldsList,',',''))+1;

            while @j <= @l

              begin 
                Set   @FieldName = Replace(dbo.Isd_StringInListStr(@FieldsList,@j,','),' ','');
                if    @TableName<>'' And @FieldName<>''
                      begin
                        Set   @sSql2  = Replace(@sSql1,'_FIELDNAME_',@FieldName);
                      --Print @sSql2
                        Exec (@sSql2);
                      end;

                Set   @j = @j + 1;

              end; 

            Set @i = @i + 1;

          end;

GO
