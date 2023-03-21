SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--Declare @Db      Varchar(30),
--		  @Tb      Varchar(30),
--        @FlsEx   Varchar(Max),
--        @Fields  Varchar(Max)
--	  Set @Db    = 'EHW13'
--	  Set @Tb    = 'ARTIKUJ'
--    Set @FlsEx = 'NRRENDOR,USI,USM'
--   Exec dbo.[Isd_spFieldsTable] @PDb=@Db, @PTb=@Tb, @PFieldsEx=@FlsEx, @PFields=@Fields Output
--  Print @Fields

CREATE     Procedure [dbo].[Isd_spFieldsTable]
( 
  @PDb        Varchar(50),
  @PTb        Varchar(50),
  @PFieldsEx  Varchar(Max),
  @PFields    Varchar(Max) Output
 )
as

--Declare @PDb         Varchar(30),
--        @PTb         Varchar(30),
--        @PFieldsEx   Varchar(Max),
--        @PFields     Varchar(Max)
--
--    Set @PDb       = 'EHW13'
--    Set @PTb       = 'ARTIKUJ'
--    Set @PFieldsEx = 'NRRENDOR,USI,USM'
--    Set @PFields   = ''

Set NoCount On


  Declare @Sql      Varchar(Max),
          @Fields   Varchar(Max)
      Set @Sql    = ''
      Set @Fields = ''


   Select @Sql = @Sql + 
 '  
   Select 
          ShName    = ''['+D.Name+'].''+Sh.Name+''.''+O.Name,
          DbName    = '''+D.Name+''',
          TableName = O.name,
          FieldName = C.name,
          ColumnId  = C.Column_id
     From ['+d.name+'].Sys.columns C          
          Inner join ['+d.name+'].Sys.Objects  O  On C.Object_id=O.Object_id
          Inner Join ['+d.name+'].Sys.Schemas  Sh On O.Schema_id=Sh.Schema_id
    Where O.Name='''+@PTb+''' 
'
     From Sys.DataBases D
    Where D.Name=@PDb 

   Select FieldName=Cast(Replicate(' ',30) As Varchar),ColumnId=0
     Into #ListFields
    Where 1=2

   Select @Sql = '

   Insert Into #ListFields (FieldName,ColumnId)
  
   Select FieldName, ColumnId
     From 
        ( 
         '+@Sql+'
        ) A 
 Order By ColumnId'

    Exec (@Sql)

   Select @Fields = @Fields+','+A.FieldName 
     From #ListFields A
    Where (IsNull(A.FieldName,'')<>'') And
          (dbo.Isd_StringInListExs(@PFieldsEx,A.FieldName)=0)

       if @Fields<>''
          Set @Fields = Substring(@Fields,2,Len(@Fields))

      Set @PFields=@Fields

GO
