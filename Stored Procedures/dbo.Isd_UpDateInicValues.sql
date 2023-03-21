SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[Isd_UpDateInicValues]
( 
 @pTableName  Varchar(100),
 @pTypes      Varchar(30),
 @pListEx     Varchar(Max),
 @pOnlyNulls  Bit                  -- Vetem nulls
)
As



begin

          Set NOCOUNT ON


      Declare @Types         Varchar(500),
              @Sql           Varchar(Max),
              @FldsEx        Varchar(Max),
              @OnlyNulls Bit

          Set @Types       = @pTypes;
          Set @Sql         = ''; 
          Set @FldsEx      = @pListEx;
          Set @OnlyNulls   = IsNull(@pOnlyNulls,0);


-- TempDb

     if CharIndex('#',@pTableName)=1    
        begin
--                                                     --  Numeric

                 Set @Sql = '';
              Select @Sql = @Sql + Case When @OnlyNulls=1
                                        Then '
  Update ' + [Table] + ' Set [' + [Column] + '] = 0 Where ([' + [Column] + '] is Null); '
                                        Else '
  Update ' + [Table] + ' Set [' + [Column] + '] = 0 Where ([' + [Column] + '] is Null)  Or ([' + [Column] + ']<>0); '
                                        End
                From
          (
              Select [Table]      = QuoteName(@pTableName),
                     [Column]     = Cln.Name
                From TempDb.Sys.Columns Cln Inner Join TempDb.Sys.Tables Tbl On Tbl.[Object_Id]    = Cln.[Object_Id]
	                                        Inner Join TempDb.Sys.Types  Tpf On Cln.System_Type_Id = Tpf.User_Type_Id
               Where (CharIndex('N',@pTypes)>0)                          And
                     Tbl.[Object_Id] = Object_id('tempdb..'+@pTableName) And
                     Tbl.[Is_Ms_Shipped] = 0    And Cln.Is_Identity=0    And
                    (Tpf.Name like '%int%' or Tpf.Name like '%num%' or Tpf.Name in ('float','real','money','decimal')) And
                     CharIndex(','+Cln.Name+',',','+@FldsEx+',')=0
           ) A

--                                                      -- Text 
                 Set @Sql = IsNull(@Sql,'');
              Select @Sql = @Sql + Case When @OnlyNulls=1
                                        Then '
 Update ' + [Table] + ' Set [' + [Column] + '] = '''' Where ([' + [Column] + '] is Null); '
                                        Else '
 Update ' + [Table] + ' Set [' + [Column] + '] = '''' Where ([' + [Column] + '] is Null) Or ([' + [Column] + '] <> ''''); '
                                        End
                From
          (
              Select [Table]      = QuoteName(@pTableName),
                     [Column]     = Cln.Name
                From TempDB.Sys.Columns Cln Inner Join TempDb.Sys.Tables Tbl On Tbl.[Object_Id]    = Cln.[Object_Id]
	                                        Inner Join TempDb.Sys.Types  Tpf On Cln.System_Type_Id = Tpf.User_Type_Id
               Where (CharIndex('C',@pTypes)>0)                          And 
                     Tbl.[Object_Id] = Object_id('tempdb..'+@pTableName) And
                     Tbl.[Is_Ms_Shipped] = 0    And Cln.Is_Identity=0    And
                    (Tpf.Name like '%text' or Tpf.Name like '%char')     And
                     CharIndex(','+Cln.Name+',',','+@FldsEx+',')=0
           ) A

           -- Print @Sql
              Exec (@Sql)

       end;


-- jo TempDb

     if CharIndex('#',@pTableName)<>1
        begin
--                                                     --  Numeric
                 Set @Sql = '';
              Select @Sql = @Sql + Case When @OnlyNulls=1
                                        Then '
 Update ' + [Table] + ' Set [' + [Column] + '] = 0 Where ([' + [Column] + '] is Null); '
                                        Else '
 Update ' + [Table] + ' Set [' + [Column] + '] = 0 Where ([' + [Column] + '] is Null)  Or ([' + [Column] + ']<>0); '
                                        End
                From
          (
              Select [Table]      = QuoteName(Object_Name(Tbl.[Object_Id])),
                     [Column]     = Cln.Name
                From Sys.Columns Cln Inner Join Sys.Tables Tbl ON Tbl.[Object_Id]    = Cln.[Object_Id]
	                                 Inner Join Sys.Types  Tpf ON Cln.System_Type_Id = Tpf.User_Type_Id
               Where (CharIndex('N',@pTypes)>0) And
                     Tbl.Name = @pTableName     And
                     Tbl.[Is_Ms_Shipped] = 0    And Cln.Is_Identity=0 And
                    (Tpf.Name like '%int%' or Tpf.Name like '%num%' or Tpf.Name in ('float','real','money','decimal')) And
                     CharIndex(','+Cln.Name+',',','+@FldsEx+',')=0
           ) A
          

--                                                     --  Text
                 Set @Sql = IsNull(@Sql,'');
              Select @Sql = @Sql + Case When @OnlyNulls=1
                                        Then '
 Update ' + [Table] + ' Set [' + [Column] + '] = '''' Where ([' + [Column] + '] is Null); '
                                        Else '
 Update ' + [Table] + ' Set [' + [Column] + '] = '''' Where ([' + [Column] + '] is Null) Or ([' + [Column] + '] <> ''''); '
                                        End
                From
          (
              Select [Table]      = QuoteName(Object_Name(Tbl.[Object_Id])),
                     [Column]     = Cln.Name
                From Sys.Columns Cln Inner Join Sys.Tables Tbl ON Tbl.[Object_Id]    = Cln.[Object_Id]
	                                 Inner Join Sys.Types  Tpf ON Cln.System_Type_Id = Tpf.User_Type_Id
               Where (CharIndex('C',@pTypes)>0) And 
                     Tbl.Name = @pTableName     And
                     Tbl.[Is_Ms_Shipped] = 0    And Cln.Is_Identity=0 And
                    (Tpf.Name like '%text' or Tpf.Name like '%char') And
                     CharIndex(','+Cln.Name+',',','+@FldsEx+',')=0
           ) A

           -- Print @Sql
              Exec (@Sql);

        end;

end

/*

-- TempDb

     if CharIndex('#',@pTableName)=1    
        begin     
  
          if CharIndex('N',@pTypes)>0   -- Numeric
             begin  

               Set @Sql = ''
            Select @Sql = @Sql + Case When @OnlyNulls=1
                                      Then '
                   Update ' + Table_name + ' Set [' + Column_name + '] = 0 Where ([' + Column_name + '] is Null); '
                                      Else '
                   Update ' + Table_name + ' Set [' + Column_name + '] = 0 Where ([' + Column_name + '] is Null) Or ([' + Column_name + ']<>0); '
                                      End
              From TempDb.Information_Schema.Columns
             Where Table_name = @pTableName And 
                  (Data_Type like '%int%' or Data_Type like '%num%' or Data_Type in ('float','real','money','decimal')) And
                   CharIndex(','+Column_Name+',',','+@pListEx+',')=0
             Print @Sql
              Exec (@Sql)

             end;

          if CharIndex('C',@pTypes)>0   -- Text 
             begin  

               Set @Sql = ''
            Select @Sql = @Sql + Case When @OnlyNulls=1
                                      Then '
                   Update ' + Table_name + ' Set [' + Column_name + '] = '''' Where ([' + Column_name + '] is Null); '
                                      Else '
                   Update ' + Table_name + ' Set [' + Column_name + '] = '''' Where ([' + Column_name + '] is Null) Or ([' + Column_name + '] <> ''''); '
                                      End
              From TempDb.Information_Schema.Columns
             Where Table_name = @pTableName And 
                  (Data_Type like '%text' or Data_Type like '%char') And
                   CharIndex(','+Column_Name+',',','+@pListEx+',')=0
             Print @Sql
              Exec (@Sql)

             end;

       end;


-- jo TempDb

     if CharIndex('#',@pTableName)<>1
        begin

          if CharIndex('N',@pTypes)>0   -- Numeric
             begin

               Set @Sql = ''
            Select @Sql = @Sql + Case When @OnlyNulls=1
                                      Then '
                   Update ' + Table_name + ' Set [' + Column_name + '] = 0 Where ([' + Column_name + '] is Null); '
                                      Else '
                   Update ' + Table_name + ' Set [' + Column_name + '] = 0 Where ([' + Column_name + '] is Null)  Or ([' + Column_name + ']<>0); '
                                      End
              From Information_Schema.Columns
             Where Table_Name = @pTableName And 
                  (Data_Type like '%int%' or Data_Type like '%num%' or Data_Type in ('float','real','money','decimal')) And
                   CharIndex(','+Column_Name+',',','+@pListEx+',')=0 
             Print @Sql
              Exec (@Sql);

             end;

          if CharIndex('C',@pTypes)>0   -- Text
             begin

               Set @Sql = ''
            Select @Sql = @Sql + Case When @OnlyNulls=1
                                      Then '
                   Update ' + Table_name + ' Set [' + Column_name + '] = '''' Where ([' + Column_name + '] is Null); '
                                      Else '
                   Update ' + Table_name + ' Set [' + Column_name + '] = '''' Where ([' + Column_name + '] is Null) Or ([' + Column_name + '] <> ''''); '
                                      End
              From Information_Schema.Columns
             Where Table_Name = @pTableName And 
                  (Data_Type like '%text' or Data_Type like '%char') And
                   CharIndex(','+Column_Name+',',','+@pListEx+',')=0
             Print @Sql
              Exec (@Sql);

             end;
        end;
*/
GO
