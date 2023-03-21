SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





--Exec dbo.Isd_LMUpdateErrors 'NOTDOC','AB','','',' ADMIN',''

CREATE         Procedure [dbo].[Isd_LMUpdateErrors]
(
  @PTipErrors     Varchar(50),   -- 'NOTDOC,NOTROW,NRDNULL,NRDFKERROR'
  @POrg           Varchar(30),
  @PDateKp        Varchar(20),
  @PDateKs        Varchar(20),
  @PPerdorues     Varchar(30),
  @PLgJob         Varchar(30)
 )

As


         Set NoCount On



     Declare @TipErrors   Varchar(50),
             @sOrg        Varchar(10),
             @DateKp      Varchar(20),
             @DateKs      Varchar(20),

             @Sql         Varchar(Max),
             @Sql1        Varchar(Max),
             @Sql2        Varchar(Max),
             @Where       Varchar(Max),
             @ListTbls    Varchar(100),
             @ListOrg     Varchar(30),
             @DocOrg      Varchar(10),
             @DocName     Varchar(20),
             @i           Int;

-- Problem si duhet te vijne Tipet:
-- Me presje ose jo (Fut funksion qe shton Presje)

         Set @Sql       = '';
         Set @Sql1      = '';
         Set @Where     = '';

         Set @TipErrors = @PTipErrors;
         Set @sOrg      = @POrg;
         Set @DateKp    = @PDateKp; 
         Set @DateKs    = @PDateKs;

         Set @ListTbls  = 'ARKA,BANKA,VS,DG,FF,FH,FJ,FD';
         Set @ListOrg   = 'A,B,E,G,F,H,S,D';


          if @sOrg=''
             Return;

          if @sOrg='*'
             Set @sOrg  = 'A,B,E,G,F,H,S,D';


          if @DateKp<>''
               Set @Where  = @Where + 'DATEDOK>=dbo.DateValue('''+@DateKp+''')';
          if @DateKs<>''
             begin
               if @Where<>''
                  Set @Where = @Where + ' And ';
               Set @Where  = @Where + 'DATEDOK>=dbo.DateValue('''+@DateKs+''')';
             end;

--Print @ListOrg
--Print @TipErrors


     -- Error 1

     if dbo.Isd_StringInListInd(@TipErrors,'NOTDOC',',')>0
        begin

          Delete 
            From FK 
           Where IsNull(ORG,'''')=''''; 

             Set @Sql1 = '';
             Set @Sql  = '
 
                 Delete 
                   From FK 
                  Where ORG=''A'' And 
                        1=1 And 
                       (Not Exists (Select NRDFK 
                                      From ARKA B 
                                     Where B.NRDFK=FK.NRRENDOR)); ';
             if @Where<>''
                Set @Sql = Replace(@Sql,'1=1',@Where);

            Set @i = 1;

          while @i<=8
             begin

               Set @DocOrg  = dbo.Isd_StringInListStr(@ListOrg, @i,',');
               Set @DocName = dbo.Isd_StringInListStr(@ListTbls,@i,',');

                if @DocOrg<>'' And @DocName<>'' And CharIndex(@DocOrg,@sOrg)>0
                   begin
                     Set @Sql2 = Replace(@Sql, '''A''', ''''+@DocOrg +'''');
                     Set @Sql2 = Replace(@Sql2,' ARKA ',' ' +@DocName  +' ');
                     Set @Sql1 = @Sql1 + @Sql2;
                   end;

               Set @i =  @i + 1;

             end;

             if @Sql1<>''
                begin
                  Print ' Test 1: NOTDOC';
                  Print @Sql1
                  Exec (@Sql1);

--                  if dbo.Isd_StringInListInd(@TipErrors,'NRDFKERROR',',')=0
--                     Set @TipErrors = @TipErrors + ',NRDFKERROR';

                end;

        end;
     -- Error 1 Fund


     -- Error 2
     if dbo.Isd_StringInListInd(@TipErrors,'NRDNULL',',')>0
        begin
          Print ' Test 2: NRDNULL';

          Delete
            From FKSCR 
           Where ISNULL(NRD,0)=0;

--            if dbo.Isd_StringInListInd(@TipErrors,'NOTROW',',')=0
--               Set @TipErrors = @TipErrors + ',NOTROW';

        end;



     -- Error 3
     if dbo.Isd_StringInListInd(@TipErrors,'NOTROW',',')>0
        begin
          Print ' Test 3: NOTROW';
          Delete 
            From FK
           Where not Exists (Select Top 1 NRRENDOR 
                               From FKSCR 
                              Where FK.NRRENDOR=FKSCR.NRD) 

--            if dbo.Isd_StringInListInd(@TipErrors,'NRDFKERROR',',')=0
--               Set @TipErrors = @TipErrors + ',NRDFKERROR';
        end;



     -- Error 4 
     if dbo.Isd_StringInListInd(@TipErrors,'NRDFKERROR',',')>0
        begin

            Set @Sql1 = '';
            Set @Sql  = '

               Update A 
                  Set A.NRDFK=0 
                 From ARKA A Inner Join FK B On A.NRDFK=B.NRRENDOR 
                Where IsNull(A.NRDFK,0)<>0   And 
                      1=1 And  
                      IsNull(B.ORG,'''')<>''A'';';  

            Set @i = 1;

          while @i<=8
            begin   

               Set @DocOrg  = dbo.Isd_StringInListStr(@ListOrg, @i,',');
               Set @DocName = dbo.Isd_StringInListStr(@ListTbls,@i,',');

                if @DocOrg<>'' And @DocName<>'' And CharIndex(@DocOrg,@sOrg)>0
                   begin
                     Set @Sql2 = Replace(@Sql, '''A''', ''''+@DocOrg +'''');
                     Set @Sql2 = Replace(@Sql2,' ARKA ',' ' +@DocName+' ');
                     Set @Sql1 = @Sql1 + @Sql2;
                   end;

               Set @i =  @i + 1;

            end;
          Print ' Test 4: NRDFKERROR';
          Print @Sql1;
             if @Sql1<>''
                Exec (@Sql1);

        end;
     -- Fund Error 4

GO
