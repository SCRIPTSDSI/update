SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--Declare @Db1     Varchar(30),
--		  @Db2     Varchar(30),
--		  @Tb1     Varchar(30),
--		  @Tb2     Varchar(30),
--        @FlsEx   Varchar(Max)
--        @Fields  Varchar(Max)
--	  Set @Db1   = 'EHW13'
--	  Set @DB2   = 'CONFIG'
--	  Set @Tb1   = 'ARTIKUJ'
--	  Set @Tb2   = 'LLOGARI'
--    Set @FlsEx = 'NRRENDOR,USI,USM'
--   Exec dbo.Isd_spFields2Tables @PDb1=@Db1, @PDB2=@Db2, @PTb1=@Tb1, @PTb2=@Tb2, @PFieldsEx=@FlsEx, @PFields=@Fields Output
--  Print @Fields

CREATE     Procedure [dbo].[Isd_spFields2Tables]
( 
  @PDb1      Varchar(50),
  @PDb2      Varchar(50),
  @PTb1      Varchar(50),
  @PTb2      Varchar(50),
  @PFieldsEx Varchar(Max),
  @PFields   Varchar(Max) Output
 )
as

Set NoCount On


  Declare @Sql      Varchar(Max),
          @Fields   Varchar(Max)
      Set @Sql    = ''
      Set @Fields = ''

       if @PDb1=@PDb2 And @PTb1=@PTb2
          begin
            Declare @Db1      Varchar(50),
                    @Tb1      Varchar(50),
                    @FieldsEx Varchar(Max)

                Set @Db1      = @PDb1
                Set @Tb1      = @PTb1
                Set @FieldsEx = @PFieldsEx

               Exec dbo.Isd_spFieldsTable @Db1, @Tb1, @FieldsEx, @Fields Output
                Set @PFields = @Fields;

            Return;

          end;


   Select @Sql = @Sql + 
 '  Union

   Select 
          ShName    = ''['+D.Name+'].''+Sh.Name+''.''+O.Name,
          DbName    = '''+D.Name+''',
          TableName = O.name,
          FieldName = C.name,
          ColumnId  = C.Column_id
     From ['+d.name+'].Sys.columns C          
          Inner join ['+d.name+'].Sys.Objects  O  On C.Object_id=O.Object_id
          Inner Join ['+d.name+'].Sys.Schemas  Sh On O.Schema_id=Sh.Schema_id
    Where (O.Name='''+@PTb1+''' And '''+D.Name+'''='''+@PDb1+''') Or 
          (O.Name='''+@PTb2+''' And '''+D.Name+'''='''+@PDb2+''') '
     From Sys.DataBases D
    Where D.Name=@PDb1 Or D.Name=@PDb2

   Select @Sql = Right(@Sql,Len(@Sql)-10)--+' Order By 1,3'
--Print @Sql

   Select FieldName=Cast(Replicate(' ',30) As Varchar),ColumnId=0
     Into #ListFields
    Where 1=2

   Select @Sql = '
   Insert Into #ListFields (FieldName,ColumnId)
  
   Select FieldName,Min(ColumnId)
     From 
        ( 
         '+ @Sql +'
        ) A 
 Group By FieldName
   Having Count(*)>1
 Order By 2 '


    Exec (@Sql)

   Select @Fields = @Fields+','+A.FieldName 
     From #ListFields A
    Where (IsNull(A.FieldName,'')<>'') And
          (dbo.Isd_StringInListExs(@PFieldsEx,A.FieldName)=0)

--Print 'A'
--
  Print @Sql


       if @Fields<>''
          Set @Fields = Substring(@Fields,2,Len(@Fields))

      Set @PFields=@Fields

GO
