SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Exec dbo.[Isd_spListFieldsTable] @PDb='CONFIG', @PTb='ARTIKUJ', @PFieldsEx='NRRENDOR,TAGNR,USI,USM,TROW', @POrder=0

CREATE     Procedure [dbo].[Isd_spListFieldsTable]
( 
  @PDb        Varchar(50),
  @PTb        Varchar(50),
  @PFieldsEx  Varchar(Max),
  @POrder     Int
 )

As

--Declare @PDb         Varchar(30),
--        @PTb         Varchar(30),
--        @PFieldsEx   Varchar(Max)
--
--    Set @PDb       = 'EHW13'
--    Set @PTb       = 'ARTIKUJ'
--    Set @PFieldsEx = 'NRRENDOR,USI,USM'


      Set NoCount On


       if Object_Id('TempDb..#ListFields') is not null
          Drop Table #ListFields


  Declare @Sql      Varchar(Max),
          @Fields   Varchar(Max),
          @Order    Int;

      Set @Sql    = ''
      Set @Fields = ''
      Set @Order  = 0;

      if  IsNull(@POrder,0)<>0
          Set @Order = @POrder;


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


--Print @Order

  Select * 
    From #ListFields A
   Where (IsNull(A.FieldName,'')<>'') And
         (dbo.Isd_StringInListExs(@PFieldsEx,A.FieldName)=0)
 Order By Case When @Order=0 Then FieldName Else Right('0000'+Cast(ColumnID As Varchar),5) End;


GO
