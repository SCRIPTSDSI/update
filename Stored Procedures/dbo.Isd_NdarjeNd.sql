SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [dbo].[Isd_NdarjeNd]
 (
  @pDataBase     Varchar(50),
  @pDataBase1    Varchar(50),
  @pDataBase2    Varchar(50),
  @pPershkrim1   Varchar(150),
  @pPershkrim2   Varchar(150),
  @pBackUp_Pass  Varchar(50),
  @pDateKp       Varchar(20),
  @pDateOpen     Varchar(20),
  @pAnalitikKl   Int,
  @pAnalitikFu   Int,
  @pGrupimArtDL  Int,
  @pGrupimArtFar Int,
  @pGrupimArtBC  Int,
  @pLlogari      Varchar(50),
  @pIndex        Int,
  @pNewDb        Bit,
  @pError        Bit Output 
 )
As


--  Declare @pDataBase      Varchar(50),
--          @pDataBase1     Varchar(50),
--          @pDataBase2     Varchar(50),
--          @pPershkrim1    Varchar(150),
--          @pPershkrim2    Varchar(150),
--          @pBackUp_Pass   Varchar(50),
--          @pDateKp        Varchar(20),
--          @pDateOpen      Varchar(20),
--          @pAnalitikKl    Int,
--          @pAnalitikFu    Int,
--          @pGrupimArtDL   Int,
--          @pGrupimArtFar  Int,
--          @pGrupimArtBC   Int,
--          @pLlogari       Varchar(50),     
--          @pIndex         Int,
--          @pNewDb         Bit,
--          @pError         Bit 
--   
--      Set @pDataBase     = 'EHW13'   
--      Set @pDataBase1    = 'EHW13AA'
--      Set @pDataBase2    = 'EHW13BB' 
--      Set @pPershkrim1   = 'EHW Continue'
--      Set @pPershkrim2   = 'EHW Close'
--      Set @pBackUp_Pass  = 'F50'
--      Set @pDateKp       = '15/01/2013'
--      Set @pDateOpen     = '16/01/2013'
--      Set @pAnalitikKl   = 0
--      Set @pAnalitikFu   = 0
--      Set @pGrupimArtDL  = 0
--      Set @pGrupimArtFar = 0
--      Set @pGrupimArtBC  = 0
--      Set @pLlogari      = '1219'
--      Set @pIndex        = 0
--      Set @pNewDb        = 0
--      Set @pError        = 0
--
--
--     Exec dbo.Isd_NdarjeNd @pDataBase     = @pDataBase, 
--                           @pDataBase1    = @pDataBase1, 
--                           @pDataBase2    = @pDataBase2, 
--                           @pPershkrim1   = @pPershkrim1,
--                           @pPershkrim2   = @pPershkrim2,
--                           @pBackUp_Pass  = @pBackUp_Pass,
--                           @pDateKp       = @pDateKp, 
--                           @pDateOpen     = @pDateOpen, 
--                           @pAnalitikKl   = @pAnalitikKl,
--                           @pAnalitikFu   = @pAnalitikFu,
--                           @pGrupimArtDL  = @pGrupimArtDL,
--                           @pGrupimArtFar = @pGrupimArtFar,
--                           @pGrupimArtBC  = @pGrupimArtBC,
--                           @pLlogari      = @pLlogari,
--                           @pIndex        = @pIndex, 
--                           @pNewDb        = @pNewDb,
--                           @pError        = @pError Output
-- 
--  if @pError=1
--     RaisError (N'
--
--* *           '- - Procedura perfundoi me gabime ..! '       * *
--
--* - * - * - * - * - * - * - * - * - * - * - * - * - * - *
--',0,1) with NoWait;

    Set NoCount On;
    
RaisError (N'

*****************************************************

0.     -      FILLIM Isd_NdarjeNd !

    -------------------------------------------------

',0,1) with NoWait;


  Declare @Sql          Varchar(Max),
          @Index        Varchar(10),
          @DocNotLM     Bit,
          @Error        Bit;

      Set @Index      = Cast(@pIndex as Varchar);
      Set @DocNotLM   = 0;
      Set @Error      = 0;

      Set @pDataBase  = LTrim(RTrim(Upper(@pDataBase)));
      Set @pDataBase1 = LTrim(RTrim(Upper(@pDataBase1)));
      Set @pDataBase2 = LTrim(RTrim(Upper(@pDataBase2)));

      if  (@pDataBase=@pDataBase1) Or (@pDataBase=@pDataBase2) Or (@pDataBase1=@pDataBase2)
          begin
            RaisError (N'0.1    -      Emrat e Databaseve duhet te jene te ndryshem ! ( %s, %s, %s ) ..! ',0,1,@pDataBase,@pDataBase1,@pDataBase2) with NoWait;
            Set   @pError = 1
            Return
          end;

      if  IsNull(db_id(@pDataBase),0)<=0
          begin
            RaisError (N'0.2    -      Database me emer %s nuk egziston ..! ',0,1,@pDataBase) with NoWait;
            Set   @pError = 1
            Return
          end;

      if  @pNewDb=1 And db_id(@pDataBase1)>0
          begin
            RaisError (N'0.3    -      Database me emer %s egziston ..! ',0,1,@pDataBase1) with NoWait;
            Set   @pError = 1
            Return
          end;

      if  @pNewDb=1 And db_id(@pDataBase2)>0
          begin
            RaisError (N'0.4    -      Database me emer %s egziston ..! ',0,1,@pDataBase2) with NoWait;
            Return
          end;
      
      Exec dbo.Isd_ExistsDocNotLM @pDataBase=@pDataBase,@pDate=@pDateKp,@pDocNotLM=@DocNotLM Output
      if  @DocNotLM=1
          begin
            RaisError (N'0.5    -      Database me emer %s ka dokumenta te pa kaluara ne LM   ( date: %s ) ..! ',0,1,@pDataBase,@pDateKp) with NoWait;
            Set   @pError = 1
            Return
          end;


      if Db_Name()=@pDataBase
         begin
           if  not Exists (Select KOD From LLOGARI Where KOD=@pLlogari And POZIC=1)
               begin
                 RaisError (N'0.6    -      Llogaria &s per zerim Ardhura/Shpenzime e panjohur ose jo Analize ..! ',0,1,@pLlogari) with NoWait;
                 Set @pError = 1
                 Return
               end
          end;
      

     Exec dbo.Isd_NdarjeNd1 @pDataBase    = @pDataBase,   
                            @pDataBase1   = @pDataBase1,
                            @pDataBase2   = @pDataBase2, 
                            @pBackUp_Pass = @pBackUp_Pass,
                            @pNewDb       = @pNewDb,
                            @pError       = @Error Output;
    RaisError (N'0.7    -      1 / 3 Perfundoi dbo.Isd_NdarjeNd1 ..! ',0,1) with NoWait;
    if @Error=1
       begin
         Set   @pError = 1
         Return
       end;



      Set @Sql = ' 

 USE '+@pDataBase1+'

Declare @pError Bit
    Set @pError = 0

 Exec dbo.Isd_NdarjeNd2 @pDataBase     = '''+@pDataBase+''', 
                        @pDataBase1    = '''+@pDataBase1+''', 
                        @pDateKp       = '''+@pDateKp+''',
                        @pDateOpen     = '''+@pDateOpen+''',
                        @pAnalitikKl   = '+Cast(@pAnalitikKl   As Varchar)+',
                        @pAnalitikFu   = '+Cast(@pAnalitikFu   As Varchar)+',
                        @pGrupimArtDL  = '+Cast(@pGrupimArtDL  As Varchar)+',
                        @pGrupimArtFar = '+Cast(@pGrupimArtFar As Varchar)+',
                        @pGrupimArtBC  = '+Cast(@pGrupimArtBC  As Varchar)+',
                        @pLlogari      = '''+@pLlogari+''',
                        @pIndex        = '  +@Index+',
                        @pError        = @pError Output';

    Exec (@Sql);
    RaisError (N'0.8    -      2 / 3 Perfundoi dbo.Isd_NdarjeNd2 ..! ',0,1) with NoWait;


      Set @Sql = ' 

 USE '+@pDataBase2+'

 Exec dbo.Isd_NdarjeNd3 '''+@pDateKp+''' ';

     Exec (@Sql);
    RaisError (N'0.9 - 3 / 3 Perfundoi dbo.Isd_NdarjeNd3 ..! ',0,1) with NoWait;




-- Futja ne Catalog Nd/je
RaisError (N'

0.10    -      1/2 Futja e nd/je te reja ne katalogun e nd/jeve  ..!',0,1) with NoWait;

-- a1
    DELETE 
      FROM DRH..NDUS 
     WHERE KODND=@pDataBase1 OR KODND=@pDataBase2;
     
    DELETE 
      FROM DRH..NDERM 
     WHERE KOD=@pDataBase1 OR KOD=@pDataBase2;

-- a2
    INSERT INTO DRH..NDUS
          (KODND,KODUS,LASTND,SKINACTIVE,SKINNAME)
    SELECT @pDataBase1,KODUS,LASTND=0,SKINACTIVE,SKINNAME
      FROM DRH..NDUS 
     WHERE KODND=@pDataBase
 UNION ALL
    SELECT @pDataBase2,KODUS,LASTND=0,SKINACTIVE,SKINNAME
      FROM DRH..NDUS 
     WHERE KODND=@pDataBase;

-- a3
    INSERT  INTO DRH..NDERM
           (KOD,PERSHKRIM)
    Values (@pDataBase1,@pPershkrim1);
 
    INSERT  INTO DRH..NDERM
           (KOD,PERSHKRIM)
    Values (@pDataBase2,@pPershkrim2);
   


    Set @Sql = '

UPDATE '+@pDataBase1+'..CONFND
   SET PERSHKRIM='''+@pPershkrim1+'''

UPDATE '+@pDataBase2+'..CONFND
   SET PERSHKRIM='''+@pPershkrim2+'''
';
Exec (@Sql);


RaisError (N'
0.11    -      2/2 Mbaroi Futja e nd/je te reja ne katalogun e nd/jeve  ..! ',0,1) with NoWait;



RaisError (N'

    -------------------------------------------------

0      -      FUND   Isd_NdarjeNd !

*****************************************************

',0,1) with NoWait;
GO
