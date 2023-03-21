SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[Isd_UpdateColumnsNulls]
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

          Set @Types       = ',Varchar,nVarchar,Char,nVarchar,Text,nText,';
          Set @Sql         = ''; 
          Set @FldsEx      = @pFldsEx;


         if CharIndex('#',@pTableName)<>1
            begin

              Select @Sql         = @Sql + ' Alter Table '+[Table]+' Alter Column ['+[Column]+'] '+[Type]+
                             Case When sLength<>-1 Then '('+Cast(Max_Length As Varchar)+')' Else '' End+' null;
'
                From
            (

              Select [Schema]     = QuoteName(Schema_Name(Tbl.[Schema_Id])),
                     [Table]      = QuoteName(Object_Name(Tbl.[Object_Id])),
                     [Column]     = Cln.Name,
                     [Type]       = Tpf.Name,
                     [Max_Length] = Cln.Max_Length,
                     [IsNull]     = Cln.Is_Nullable,
                     [sOrder]     = Tbl.[Name],
                     [sLength]    = Case When CharIndex(Tpf.Name, @Types) > 0 Then Cln.Max_Length Else -1 End

                From Sys.Columns Cln Inner Join Sys.Tables Tbl ON Tbl.[Object_Id]    = Cln.[Object_Id]
	                                 Inner Join Sys.Types  Tpf ON Cln.System_Type_Id = Tpf.User_Type_Id

               Where Tbl.[Is_Ms_Shipped] = 0 And Cln.Is_Identity=0 And
                     Object_Name(Tbl.[Object_Id])=@pTableName And
                     CharIndex(','+Cln.Name+',',','+@FldsEx+',')=0
             ) A

            Order By SOrder

            -- Print @Sql;
                Exec (@Sql)


            end;


 -- Rasti Table ne TempDb

         if CharIndex('#',@pTableName)=1
            begin

              Select @Sql         = @Sql + ' Alter Table '+[Table]+' Alter Column ['+[Column]+'] '+[Type]+
                                    Case When sLength<>-1 Then '('+Cast(Max_Length As Varchar)+')' Else '' End+' null;
'
                From
            (

              Select [Schema]     = QuoteName(Schema_Name(Tbl.[Schema_Id])),
                     [Table]      = QuoteName(@pTableName),
                     [Column]     = Cln.Name,
                     [Type]       = Tpf.Name,
                     [Max_Length] = Cln.Max_Length,
                     [IsNull]     = Cln.Is_Nullable,
                     [sOrder]     = Tbl.[Name],
                     [sLength]    = Case When CharIndex(Tpf.Name, @Types) > 0 Then Cln.Max_Length Else -1 End

                From TempDB.Sys.Columns Cln Inner Join TempDb.Sys.Tables Tbl ON Tbl.[Object_Id]    = Cln.[Object_Id]
	                                        Inner Join TempDb.Sys.Types  Tpf ON Cln.System_Type_Id = Tpf.User_Type_Id

               Where Tbl.[Is_Ms_Shipped] = 0 And Cln.Is_Identity=0 And
                     Tbl.[Object_Id]=object_id('tempdb..'+@pTableName) And
                     CharIndex(','+Cln.Name+',',','+@FldsEx+',')=0
             ) A

            Order By SOrder

              Print @Sql
                Exec (@Sql);
            end;

End;
GO
