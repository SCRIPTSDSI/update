SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [dbo].[Isd_NdarjeNd1]
 (
  @pDataBase     Varchar(50),
  @pDataBase1    Varchar(50),
  @pDataBase2    Varchar(50),
  @pBackUp_Pass  Varchar(50),
  @pNewDb        Bit,
  @pError        Bit Output
 )
As

    Set NoCount On;

    RaisError (N'

---------------------------------------
1      -      FILLIM Isd_NdarjeNd1 !
    -----------------------------------

',0,1) with NoWait;


--  Exec dbo.Isd_NdarjeNd1 @pDataBase    = 'EHW13',   @pDataBase1   = 'EHW13AA',
--                         @pDataBase2   = 'EHW13BB', @pBackUp_Pass = 'F50',0,@pError=0


  Declare @DocNotLM     Bit;


      Set @pError     = 0;

      Set @pDataBase  = LTrim(RTrim(Upper(@pDataBase)));
      Set @pDataBase1 = LTrim(RTrim(Upper(@pDataBase1)));
      Set @pDataBase2 = LTrim(RTrim(Upper(@pDataBase2)));

      if  (@pDataBase=@pDataBase1) Or (@pDataBase=@pDataBase2) Or (@pDataBase1=@pDataBase2)
          begin
            RaisError (N'1.1    -      Emrat e Databaseve duhet te jene te ndryshem ( %s, %s, %s )  ..!',0,1,@pDataBase,@pDataBase1,@pDataBase2) with NoWait;
            Set   @pError = 1
            Return
          end;

      if  IsNull(db_id(@pDataBase),0)<=0
          begin
            RaisError (N'1.2    -      Database me emer %s nuk egziston ..! ',0,1,@pDataBase) with NoWait;
            Set   @pError = 1
            Return
          end;

      if  @pNewDb=1 And db_id(@pDataBase1)>0
          begin
            RaisError (N'1.3    -      Database me emer %s egziston ..! ',0,1,@pDataBase1) with NoWait;
            Set   @pError = 1
            Return
          end;

      if  @pNewDb=1 And db_id(@pDataBase2)>0
          begin
            RaisError (N'1.4    -      Database me emer %s egziston ..! ',0,1,@pDataBase2) with NoWait;
            Set   @pError = 1
            Return
          end;

    Exec dbo.Isd_ExistsDocNotLM @pDataBase=@pDataBase,@pDate='',@pDocNotLM=@DocNotLM Output
      if @DocNotLM=1
          begin
            RaisError (N'1.5    -      Database me emer %s ka dokumenta te pa kaluara ne LM ..! ',0,1,@pDataBase) with NoWait;
            Set   @pError = 1
            Return
          end;
     
  Declare @Sql           Varchar(Max),
          @DataBase      Varchar(50),
          @DataBase1     Varchar(50),
          @DataBase2     Varchar(50),
          @BackUp_Path   Varchar(500),
          @BackUp_Name   Varchar(50),
          @BackUp_Desc   Varchar(100),
          @BackUp_Pass   Varchar(50);

      Set @DataBase      = @pDataBase;
      Set @DataBase1     = @pDataBase1;
      Set @DataBase2     = @pDataBase2;

      Set @BackUp_Name   = 'F50';
      Set @BackUp_Desc   = 'Arshive';
      Set @BackUp_Pass   = @pBackUp_Pass;
    --Set @BackUp_Path   = 'C:\0FinWNt D2007\'+@DataBase+'_Tmp.BAK'
 -- Krijo Emer Random ne kete rast ....

   Select @BackUp_Path = Replace(FILENAME,'\Master.Mdf','\'+@DataBase+'_Tmp.BAK')
     From MASTER..SysFiles 
    Where FILEID=1;

--Print @BackUp_Path

     Exec DRH.dbo.BackUp_DataBase       @DataBase     = @DataBase,
                                        @BackUp_Path  = @BackUp_Path,
                                        @BackUp_Name  = @BackUp_Name,
                                        @BackUp_Desc  = @BackUp_Desc,
                                        @BackUp_Pass  = @BackUp_Pass;
     RaisError (N'1.6    -      Mbaroi BackUp  per %s ! ',0,1,@DataBase) with NoWait;




     Exec DRH.dbo.Isd_Restore_DataBase  @pDataBase    = @DataBase1,
                                        @pBackUp_Path = @BackUp_Path,
                                        @pBackUp_Pass = @BackUp_Pass;


      if  IsNull(db_id(@pDataBase1),0)<=0
          begin
            RaisError (N'1.7    -      Database me emer %s nuk u krijua ..! ',0,1,@pDataBase1) with NoWait
            Set   @pError = 1
            Return
          end
      else
            RaisError (N'1.8    -      Mbaroi Restore per %s ..! ',0,1,@DataBase1) with NoWait;




     Exec DRH.dbo.Isd_Restore_DataBase  @pDataBase    = @DataBase2,
                                        @pBackUp_Path = @BackUp_Path,
                                        @pBackUp_Pass = @BackUp_Pass;


      if  IsNull(db_id(@pDataBase2),0)<=0
          begin
            RaisError (N'1.9    -      Database me emer %s nuk u krijua ..! ',0,1,@pDataBase2) with NoWait
            Set   @pError = 1
            Return
          end
      else
            RaisError (N'1.10   -      Mbaroi Restore per %s ..! ',0,1,@DataBase2) with NoWait;


RaisError (N'

    -----------------------------------
1      -      FUND   Isd_NdarjeNd1 !
---------------------------------------

',0,1) with NoWait;


GO
