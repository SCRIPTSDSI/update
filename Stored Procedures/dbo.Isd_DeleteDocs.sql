SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--  Declare @PDb1      Varchar(30),
--          @PDbase     Varchar(50),  
--          @PTablesEx  Varchar(Max),
--          @PDate      Varchar(30),
--          @PInvers    Bit
--     Exec dbo.Isd_DeleteDocs @PDbase='EHW13', @PTablesEx='VSST,FKST', @PDate='01/06/2013', @PInvers=0


-- Per me te detajuar shiko Isd_DeleteDocs2


CREATE   Procedure [dbo].[Isd_DeleteDocs]
( 
  @PDbase     Varchar(50),  
  @PTablesEx  Varchar(Max),
  @PDate      Varchar(30),
  @PInvers    Bit,
  @PTrunc     Int
 )
as


-- Rasti @PTrunc = 1 ne Krijim Nd/je - Rasti Import vetem Referenca, ose kur duhet Fshirje te gjitha dokumentave

-- Rasti @PTrunc = 0- Pra punohet me Date perdoret ne Ndarje Nd/je, ose Fshirje me Date te dokumentave

   Set NoCount On

   Declare @Sql        Varchar(Max),
           @TablesList Varchar(Max),
           @TableName  Varchar(30),   
           @i          Int,
           @j          Int,
           @Not        Varchar(10)

       if  @PDBase<>''
           Set @PDBase = @PDBase+'..'

       Set @TablesList = ''
       Set @Not = ''

        if @PInvers=1
           Set @Not = 'NOT'
 
    Select @TablesList = @TablesList + ',' + TABLENAME 
      From CONFIG..TablesName 
     Where TableStr='DOC'

       Set @TablesList = dbo.Isd_ListFields2Lists(@TablesList, @TablesList, @PTablesEx) 

       Set @i = 1
       Set @j = Len(@TablesList)-Len(Replace(@TablesList,',',''))+1

	   while @i <= @j
		 begin
		   Set @TableName = LTrim(RTrim(dbo.Isd_StringInListStr(@TablesList,@i,',')))     
           Set @i = @i + 1

           if (@TableName<>'') And (IsNull(@PTrunc,0)=1)      -- Fshirje me Truncate per Shpejtesi
              begin
                if (dbo.Isd_TableExists(@TableName+'Scr')=1)
                   begin
  		             Set   @Sql = ' TRUNCATE TABLE '+@PDBase+@TableName+'SCR';
                     Print @Sql;
		             Exec (@Sql);
                   end;

  		        Set   @Sql = ' DELETE FROM '+@PDBase+@TableName;
                Print @Sql;
		        Exec (@Sql);
              end;


           if (@TableName<>'') And (IsNull(@PTrunc,0)=0)
              begin
  		        Set @Sql = ' 
			        DELETE 
				      FROM '+@PDBase+@TableName+'
				     WHERE '+@Not+' DATEDOK<=Dbo.DATEVALUE('''+@PDate+''') ';
		    --  Print @Sql;
		        Exec (@Sql);
              end;

         end

GO
