SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE   Procedure [dbo].[Isd_ExistsRowsInTables]
(
  @PDataBase    Varchar(50),
  @PList        Varchar(2000),
  @PExistRows   Bit    Output
)

As

Begin

--  Declare @PDataBase    Varchar(50),
--          @PList        Varchar(2000),
--          @PExistRows   Bit;

--      Set @PDataBase  = 'EHW13'
--      Set @PList      = 'FHSCR,FFSCR,FJSCR'
--      Set @PExistRows = 0;

--     Exec dbo.Isd_ExistsRowsinTables @PDataBase=@PDataBase, @PList=@PList, @PExistRows=@PExistRows  Output;
--    Print @PExistRows

  Set NoCount On

  Declare @ExistRows    Bit,
          @Sql          Varchar(500),
          @List         Varchar(500),
          @TableName    Varchar(50),
          @i            Int,
          @j            Int;

      Set @ExistRows  = 0;
      Set @List       = @PList; 



       if @PDataBase = ''
          Set @PDataBase = Db_Name()

       if IsNull(db_id(@PDataBase),0)<=0
          begin
            Print 'Database me kete emer '''+@PDataBase+''' nuk egziston !'
            Set   @PExistRows = @ExistRows;
            Return;
          end;

   --     Drop  Table #TblExistsRows
        Select  ExistsRows = Cast(0 As Bit)
          Into #TblExistsRows 
         Where 1=2

           Set @i = 1
           Set @j = Len(@List)-Len(Replace(@List,',',''))+1

      while (@i <= @j) And (@ExistRows=0)
        begin 

		     Set @TableName = LTrim(RTrim(dbo.Isd_StringInListStr(@List,@i,','))); 
             Set @Sql =  ' 

                use '+@PDataBase+'

                 if Object_Id('''+@TableName+''') is not null
                    begin
                      INSERT INTO #TblExistsRows 
                            (ExistsRows)
                      SELECT Top 1 1 
                        FROM '+@PDataBase+'..'+@TableName+'
                    end; ';

           Print @Sql;
              if @TableName<>''
                 Exec (@Sql);

          Select  @ExistRows = IsNull(ExistsRows,0)
            From  #TblExistsRows;

             Set @i = @i + 1;
        end;

    Drop Table #TblExistsRows;

      Set @PExistRows = @ExistRows;

End
GO
