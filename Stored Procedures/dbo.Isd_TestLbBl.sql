SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   procedure [dbo].[Isd_TestLbBl] 
(
  @PListInv  Varchar(Max),
  @PListShp  Varchar(Max),
  @PWhere    Varchar(Max)
)

As

-- Exec dbo.Isd_TestLbBl '215,218,24','215,28,25','DATEDOK>=dbo.DateValue(''01/01/2015'')';


         Set NoCount On;
        
     Declare @Where1    Varchar(Max),
             @Where2    Varchar(Max),
             @Where3    Varchar(Max),
             @Where4    Varchar(Max),
             @Sql      nVarchar(Max),
             @List      Varchar(Max),
             @Where     Varchar(Max),
             @Llog      Varchar(30),
             @i         Int,
             @j         Int;


         Set @Where1 = '';
         Set @Where2 = '';
         Set @Where3 = '';
         Set @Where4 = '';


         Set @List   = @PListInv;
         Set @Where  = '';
         Set @j      = Len(@List)-Len(Replace(@List,',',''))+1;
         Set @i      = 1

       while @i<=@j
        begin
          Set @Llog  = dbo.Isd_StringInListStr(@List,@i,',');
           if @Llog<>''
              Set @Where = @Where + ';Left(R2.LLOGINV,'+Cast(Len(@Llog) As Varchar)+')='''+@Llog+'''';
          Set @i = @i + 1;
        end;

       if @Where<>''
          begin
            Set @Where = Substring(@Where,2,Len(@Where));
            Set @Where = '('+Replace(@Where,';',' Or ')+')';
            Set @Where1 = @Where;
            Set @Where2 = '( Not '+@Where1+' )';
          end;


         Set @List  = @PListShp;
         Set @Where = '';
         Set @j     = Len(@List)-Len(Replace(@List,',',''))+1;
         Set @i     = 1

       while @i<=@j
         begin
           Set @Llog  = dbo.Isd_StringInListStr(@List,@i,',');
            if @Llog<>''
               Set @Where = @Where + ';Left(B.KARTLLG,'+Cast(Len(@Llog) As Varchar)+')='''+@Llog+'''';
           Set @i = @i + 1;
         end;

       if @Where<>''
          begin
            Set @Where = Substring(@Where,2,Len(@Where));
            Set @Where = '('+Replace(@Where,';',' Or ')+')';
            Set @Where3 = @Where;
            Set @Where4 = '( Not '+@Where3+' )';
          end;
--Print @Where1
--Print @Where2
--Print @Where3
--Print @Where4    



     if @Where1='' Or @Where3=''
        begin

          Select NRDOK     = 0,
                 DATEDOK   = GetDate(),
                 NRRENDOR  = 0,
                 KARTLLG   = '',
                 TIPKLL    = '',
                 PERSHKRIM = 'zgjedhje bosh',
              -- R1.KODLM,
                 LLOGARILM = '',
                 ErrorMsg  = ''
           Where 1=2;

          Return;
        end;




          if Object_Id('TempDB..#TableFF') is not null
             Drop Table #TableFF;


      Select NRRENDOR=0
        Into #TableFF
        From FF
       Where 1=2

         Set @Where = '';

      if not (@PWhere='' Or @PWhere='''')
         Set @Where = 'Where '+@PWhere;

         Set @Sql = '
      Insert Into #TableFF
            (  NRRENDOR)
      Select A.NRRENDOR
        From FF A Inner Join FFSCR B On A.NRRENDOR=B.NRD
       '+@Where+'
    Group By A.NRRENDOR 
    Order By A.NRRENDOR';


--    Print  @Sql
       Exec (@Sql);
--Select * From #TableFF;


    Set @Sql = ' 

      Select A.*,
             TROW  = Cast(0 As Bit),
             TAGNR = 0
        From
     (
      Select A.NRDOK,
             A.DATEDOK,
             ARTIKULL  = B.KARTLLG,
             B.PERSHKRIM,
             INVESTIM  = IsNull(B.APLINVESTIM,0),
          -- R1.KODLM,
             LLOGARI   = Case When B.TIPKLL=''K'' Then R2.LLOGINV Else B.KARTLLG End,
             Mesazh    = Case When B.TIPKLL=''K'' And IsNull(B.APLINVESTIM,0)=0 And '+@Where1+'
                              Then ''art ''+IsNull(B.KARTLLG,'''')+'': zgjedhur investim por llog. ''      + IsNull(R2.LLOGINV,'''') + '' jo investim.''
                              When B.TIPKLL=''K'' And IsNull(B.APLINVESTIM,0)=1 And '+@Where2+'
                              Then ''art ''+IsNull(B.KARTLLG,'''')+'': zgjedhur jo investim por llog. ''   + IsNull(R2.LLOGINV,'''') + '' investim.''
                              When B.TIPKLL=''L'' And IsNull(B.APLINVESTIM,0)=0 And '+@Where3+'
                              Then ''llog ''+IsNull(B.KARTLLG,'''') +'': zgjedhur investim por llog. ''    + IsNull(B.KARTLLG,'''')  + '' jo investim.''
                              When B.TIPKLL=''L'' And IsNull(B.APLINVESTIM,0)=1 And '+@Where4+'
                              Then ''llog ''+IsNull(B.KARTLLG,'''') +'': zgjedhur jo investim por llog. '' + IsNull(B.KARTLLG,'''')  + '' investim.''
                              Else '''' End,
             VEPRIM    = B.TIPKLL,
             A.NRRENDOR
        From FF A Inner Join #TableFF F On A.NRRENDOR=F.NRRENDOR
                  Inner Join FFSCR   B  On A.NRRENDOR=B.NRD
                  Left  Join ARTIKUJ R1 On B.KARTLLG=R1.KOD And B.TIPKLL=''K''
                  Left  Join SKEMELM R2 On R1.KODLM=R2.KOD    
     ) A

       Where Mesazh<>''''
    Order By DATEDOK,NRDOK ';

   Exec (@Sql)
-- Print @Sql;

          if Object_Id('TempDB..#TableFF') is not null
             Drop Table #TableFF;


GO
