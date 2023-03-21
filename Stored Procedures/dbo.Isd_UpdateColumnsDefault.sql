SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[Isd_UpdateColumnsDefault]
( 
 @pTableName    Varchar(100),
 @pTypes        Varchar(500),
 @pFldsEx       Varchar(Max)
)
As

Begin


           if @pTableName=''
              Return;


         Set NOCOUNT ON

      Declare @Types         Varchar(500),
              @Sql           Varchar(Max),
              @FldsEx        Varchar(Max);

          Set @Types       = @pTypes;
          Set @FldsEx      = @pFldsEx+',NRRENDOR,NRD';
          Set @Sql         = ''; 



 -- Rasti Table ne TempDb

         if CharIndex('#',@pTableName)=1
            begin

             Select @Sql = @Sql+' Alter Table ['+@PTableName+'] Add Constraint [DF_'+@PTableName+'_'+[Column_Name]+'] Default (('+DataType+')) For ['+[Column_Name]+'];
'
               From 
           (
              Select [Table_Name]  = Object_Name( Object_Id('tempdb..'+@pTableName),(Select Database_id From Sys.Databases Where Name = 'tempdb')),
                   --[Table_Name]  = QuoteName(@pTableName),
                     [Column_Name] = Cln.Name,
                     DataType = Case When (Tpf.Name like '%int%' or Tpf.Name like '%num%' or (Tpf.Name in ('float','real','money','decimal','bit')))
                                          Then '0'
                                     When (Tpf.Name like '%text' or Tpf.Name like '%char')
                                          Then ''''''
                                     else ''''
                                     End 
                From TempDB.Sys.Columns Cln Inner Join TempDb.Sys.Tables Tbl ON Tbl.[Object_Id]    = Cln.[Object_Id]
	                                        Inner Join TempDb.Sys.Types  Tpf ON Cln.System_Type_Id = Tpf.User_Type_Id

               Where Tbl.[Is_Ms_Shipped] = 0 And Cln.Is_Identity=0 And
                     Tbl.[Object_Id]=object_id('tempdb..'+@pTableName) And

                  ( (CharIndex('N',@Types)>0 And ( Tpf.Name like '%int%' or Tpf.Name like '%num%' Or Tpf.Name in ('float','real','money','decimal','bit')) ) Or
                    (CharIndex('C',@Types)>0 And ( Tpf.Name like '%text' or Tpf.Name like '%char'))
                   ) And
                     CharIndex(','+Cln.Name+',',','+@FldsEx+',')=0
             ) A

               Print @Sql
                Exec (@Sql);
            end;

End;


--         if CharIndex('#',@pTableName)=1
--            begin
--
--             Select @Sql = @Sql+' Alter Table '+@PTableName+' Add Constraint [DF_'+@PTableName+'_'+[Column_Name]+'] Default (('+DataType+')) For ['+[Column_Name]+'];
--'
--               From 
--           (
--             Select [Table_Name],[Column_Name],
--                    DataType = Case When (Data_Type like '%int%' or Data_Type like '%num%' or (Data_Type in ('float','real','money','decimal')))
--                                         Then '0'
--                                    When (Data_Type like '%text' or Data_Type like '%char')
--                                         Then ''''''
--                                    End 
--              From TempDB.Information_Schema.Columns
--
--             Where Table_Name = Object_Name( Object_Id('tempdb..'+@pTableName),(Select Database_id From Sys.Databases Where Name = 'tempdb')) And
--                  ( (( Data_Type like '%int%' or Data_Type like '%num%' Or Data_Type in ('float','real','money','decimal')) And 
--                       CharIndex('N',@Types)>0 ) Or
--
--                    (( Data_Type like '%text' or Data_Type like '%char') ) And CharIndex('C',@Types)>0 ) And
--
--                   CharIndex(','+Column_Name+',',','+@FldsEx+',')=0
--
--             ) A
--
--               Print @Sql
--                Exec (@Sql);
--            end;
GO
