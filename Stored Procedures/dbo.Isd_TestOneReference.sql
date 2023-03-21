SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--  Declare @pDbDstName   Varchar(30),
--          @pRFDstName   Varchar(30),
--          @pDbOrgName   Varchar(30),  
--          @pTbOrgName   Varchar(30),
--          @PGroupMsg    Bit

--      Set @pDbDstName = 'EHW13'
--      Set @pRFDstName = 'KLIENT'

--      Set @pDbOrgName = 'EHWIMPPALM'
--      Set @pTbOrgName = 'TableRefReady'
--      Set @PGroupMsg  = 0
--     Exec dbo.Isd_TestOneReference @pDbDstName=@pDbDstName, @pRFDstName=@pRFDstName,
--                                   @pDbOrgName=@pDbOrgName,@pTbOrgName=@pTbOrgName,@PGroupMsg=0

CREATE   Procedure [dbo].[Isd_TestOneReference]
( 
 @pDbDstName Varchar(30),  -- DataBase Destinacion
 @pRFDstName Varchar(30),  -- Referenca 

 @pDbOrgName Varchar(30),  -- DataBase ku ndodhet informacioni
 @pTbOrgName Varchar(30),  -- Tabela   ku ndodhet informacioni,
 @PGroupMsg  Bit
 )
as

         Set NoCount On


     Declare @TableName   Varchar(30),
             @DbDstName   Varchar(30),

             @DbOrgName   Varchar(30),
             @TbOrgName   Varchar(30)


         Set @DbDstName = @pDbDstName
         Set @TableName = @pRFDstName

         Set @DbOrgName = @pDbOrgName
         Set @TbOrgName = @pTbOrgName
        

          if @DbDstName<>''
             Set @DbDstName = @DbDstName+'..'

          if @DbOrgName<>''
             Set @DbOrgName  = @DbOrgName +'..'

          if Object_Id('TempDb..##TestReference') is Not Null
             Drop Table ##TestReference

      Select TableName = Space(50),
             Kod       = Space(50),
             Pershkrim = Space(150),
             MsgError  = Space(100),
             TRow      = Cast(0 As Bit),
             TagNr     = 0
        Into ##TestReference
       Where 1=2

     Declare @Ind1         Int,
             @Nr1          Int,
             @SQL          Varchar(Max),
             @ListTables   Varchar(Max),
             @FldList      Varchar(Max),
             @FieldName    Varchar(50),
             @TableNameRF  Varchar(50),
             @FieldNameRF  Varchar(50),
             @WhereRF      Varchar(200),
             @MsgError     Varchar(100),
             @FldEmpty     Bit;
--

         Set @FldList = '';

      Select @FldList = @FldList   +','+IsNull(TABLEFIELD,'')
        From CONFIG..TABLESLINK
       Where TABLENAME=@TableName;

      if Len(@FldList)>1
         Set @FldList    = Substring(@FldList,2,Len(@FldList));
--


 	     Set @ListTables = dbo.Isd_ListTablesDR('','REF');
 	     Set @Nr1   = Len(@FldList)-Len(Replace(@FldList,',',''))+1;
	     Set @Ind1  = 1;

	   while @Ind1 <= @Nr1 
	 	 begin

		        Set @FieldName   = LTrim(RTrim(dbo.Isd_StringInListStr(@FldList,@Ind1,',')))     

             Select @TableNameRF = IsNull(REFERTABLE,''), 
                    @FieldNameRF = IsNull(REFERFIELD,''), 
                    @WhereRF     = IsNull(REFERWHERE,''),
                    @MsgError    = IsNull(ERRORMSG,''),
                    @FldEmpty    = IsNull(FIELDEMPTY,1)
               From CONFIG..TABLESLINK
              Where TABLENAME  = @TableName And TABLEFIELD = @FieldName;

		        Set @TableNameRF  = LTrim(RTrim(Replace(@TableNameRF,' ','')));  

		       if  (dbo.Isd_StringInListExs(@ListTables,@TableNameRF)>0) And 
                   (dbo.Isd_FieldTableExists(@TableName,@FieldName)=1) And
                   (dbo.Isd_FieldTableExists(@TableNameRF,@FieldNameRF)=1)
			       begin

                     Set @Sql = '

             Insert Into ##TestReference
                   (TABLENAME,KOD,PERSHKRIM,MSGERROR,TROW,TAGNR)
             Select '''+@TableName+''',
                    A.KOD,
                    A.PERSHKRIM,
                    MSGERROR = '''+@MsgError+': ''+Cast(IsNull('+@FieldName+','''') As Varchar),
                    0,
                    0
               From '+@DbOrgName + @TbOrgName+' A
              Where 1=1 And (Not Exists (Select '+@FieldNameRF+'
                                           From '+@DbDstName+@TableNameRF+' B 
                                          Where B.'+@FieldNameRF+'=A.'+@FieldName+' And 2=2 )) ';

                     if @FldEmpty=1
                        Set @Sql = Replace(@Sql,'1=1','IsNull(A.'+@FieldName+','''')<>''''');
                     if @WhereRF<>''
                        Set @Sql = Replace(@Sql,'2=2',@WhereRF);

                     Print IsNull(@Sql,'Sql eshte null ..!');
				     Exec (@Sql);  
			       end
               else
                   begin
                     Print 'Tabela e mbushur jo ne rregull: Referenca '+@TableName  +' fusha '+@FieldName+' - lidhje me Tabelen '+ @TableNameRF+' me fushe '+@FieldNameRF+ '..!';
                   end;

		       Set @Ind1 = @Ind1 + 1;

		 end;
--


  if @PGroupMsg=1
     begin
         Select TableName,
                Kod       ='',
                PERSHKRIM ='',
                MsgError,
                TRow,
                TagNr
           From ##TestReference 
       Group By TableName,MsgError,TRow,TagNr
       Order By TableName,MsgError;
     end
  else
     begin
         Select * 
           From ##TestReference 
       Order By TableName,Kod;
     end;
GO
