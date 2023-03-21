SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE   Procedure [dbo].[Isd_ExistsDocNotLM]
(
  @PDataBase  Varchar(50),
  @PDate      Varchar(20),
  @PDocNotLM  Bit Output
)

As

Begin

--  Declare @PDataBase    Varchar(50),
--          @PDate        Varchar(20),
--          @PDocNotLM    Bit,
--      Set @PDataBase  = 'EHW13'
--      Set @PDocNotLM  = 0
--      Set @PDate      = ''
--     Exec dbo.Isd_ExistsDocNotLM  @PDataBase='EHW13', @PDate=@PDate, @PDocNotLM=@PDocNotLM  Output
--    Print @PDocNotLM

  --Drop Table #NotKalimLM
   Select NotKalimLM=0 
     Into #NotKalimLM 
    Where 1=2


  Set NoCount On

   if @PDataBase = ''
      Set @PDataBase = Db_Name()

   if IsNull(db_id(@PDataBase),0)<=0
      begin
        Print 'Database me kete emer '''+@PDataBase+''' nuk egziston !'
        Return
      end;


  Declare @NotKalimLM   Int,
          @Sql          Varchar(500),
          @Sql1         Varchar(500),
          @List         Varchar(500),
          @TableName    Varchar(50),
          @i            Int,
          @j            Int,
          @Where        Varchar(300);

      Set @NotKalimLM = 0
      Set @List       = 'ARKA,BANKA,VS,DG,FH,FD,FF,FJ' 
      Set @Where      = ''
      if  @PDate <> ''
          Set @Where  = ' AND DATEDOK<=Dbo.DATEVALUE('+QuoteName(@PDate,'''')+')';

      Set @Sql =  ' 
             INSERT INTO #NotKalimLM 
                   (NotKalimLM)
             SELECT Top 1 1 
               FROM '+@PDataBase+'..ARKA  
              WHERE IsNull(NRDFK,0)=0 AND 2=2 '+@Where; 
   
      Set   @i = 1;
      Set   @j = Len(@List)-Len(Replace(@List,',',''))+1;

      while (@i <= @j) And (@NotKalimLM=0)
        begin 

		  Set    @TableName = LTrim(RTrim(dbo.Isd_StringInListStr(@List,@i,',')));
          Set    @Sql1 = Replace(@Sql,'..ARKA','..'+@TableName);

          if     @TableName='FH' Or @TableName='FD'
                 begin
                   Set    @Sql1 = Replace(@Sql1,'2=2','DST<>''TR''');
                 end;

       -- Print  @Sql1;
          Exec  (@Sql1)

          Select @NotKalimLM = IsNull(NotKalimLM,0)
            From #NotKalimLM

          Set @i = @i + 1
        end

    Drop Table #NotKalimLM


    Set @PDocNotLM = @NotKalimLM

End
GO
