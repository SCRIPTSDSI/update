SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [dbo].[Isd_NdarjeNd2]
 (
  @pDataBase     Varchar(50),
  @pDataBase1    Varchar(50),
  @pDateKp       Varchar(20),
  @pDateOpen     Varchar(20),
  @pAnalitikKl   Int,
  @pAnalitikFu   Int,
  @pGrupimArtDL  Int,
  @pGrupimArtFar Int,
  @pGrupimArtBC  Int,
  @pLlogari      Varchar(50),     
  @pIndex        Int,              -- Grupimi sipas Dep/List/Llogari analitike
  @pError        Bit Output
 )
As


--  Declare @pDateKp     Varchar(20),
--          @pDateOpen   Varchar(20),
--          @pLlogari    Varchar(50),
--          @pIndex      Int,
--
--      Set @pDateKp   = '15.01.2013'
--      Set @pDateOpen = '16.01.2013'
--      Set @pLlogari  = '121'
--      Set @pIndex    = 0  

    Set NoCount On;

RaisError (N'

---------------------------------------
2      -      FILLIM Isd_NdarjeNd2 !
    -----------------------------------

',0,1) with NoWait;

  Declare @Sql           Varchar(Max),
          @DataBase      Varchar(50),
          @DataBase1     Varchar(50),
          @DocNotLM      Bit,
          @Error         Bit;

      Set @DataBase    = @pDataBase;
      Set @DataBase1   = @pDataBase1;
      Set @DocNotLM    = 0;
      Set @Error       = 0;


     Exec dbo.Isd_ExistsDocNotLM @pDataBase=@pDataBase,@pDate=@pDateKp,@pDocNotLM=@DocNotLM Output
       if @DocNotLM=1
          begin
            RaisError (N'2.1    -      Database me emer %s ka dokumenta te pa kaluara ne (date: %s) LM ..! ',0,1,@pDataBase,@pDateKp) with NoWait;
            Set @pError = 1
            Return
          end;
      
       if not Exists (Select KOD From LLOGARI Where KOD=@pLlogari And POZIC=1)
          begin
            RaisError (N'2.2    -      Llogaria %s per zerim Ardhura/Shpenzime e panjohur ose jo Analize ..! ',0,1,@pLlogari) with NoWait;
            Set @pError = 1
            Return
          end;

  Declare @pKoment     Varchar(500),
          @pWhere      Varchar(Max),
          @pOper       Int,
          @pNrDok      Int,
          @pNrRendor   Int;

      Set @pKoment   = 'Zerim Ardhura Shpenzime';
      Set @pWhere    = ' LLOGARI.KOD>=''6'' AND LLOGARI.KOD<''8'' AND DATEDOK<=Dbo.DATEVALUE('''+@pDateKp+''') ';

      Set @pOper     = 1;  -- Krijim dokumenti
      Set @pNrDok    = 0;
      Set @pNrRendor = 0;




    Exec dbo.Isd_ZerimAS          @pDate       = @pDateKp,   
                                  @pLlogari    = @pLlogari, 
                                  @pKoment     = @pKoment,
                                  @pWhere      = @pWhere, 
                                  @pIndex      = @pIndex, 
                                  @pOper       = @pOper,
                                  @pNrDok      = @pNrDok    Output,
                                  @pNrRendor   = @pNrRendor Output;
    RaisError (N'2.3    -      Mbaroi zerimi A/S ..! ',0,1) with NoWait;


   Select NRRENDOR=0,TIP=Replicate(' ',10),DATEDOK
     Into #TipDok
     From FH 
    Where 1=2;

   Insert Into #TipDok
         (NRRENDOR,DATEDOK,TIP)
   Select NRRENDOR,DATEDOK,TIP='FH'
     From FH; 

   Insert Into #TipDok
         (NRRENDOR,DATEDOK,TIP)
   Select NRRENDOR,DATEDOK,TIP='VS'
     From VS; 

    Insert Into #TipDok
          (NRRENDOR,DATEDOK,TIP)
    Select NRRENDOR,DATEDOK,TIP='FK'
      From FK;

    Create Index TmpIndex On #TipDok (NRRENDOR,DATEDOK,TIP);



    Exec  dbo.Isd_ImportCeljeMg   @pDbOrigjine   = @DataBase, 
                                  @pDateCls      = @pDateKp, 
                                  @pDateDoc      = @pDateOpen, 
                                  @pWhere        = '',
                                  @pGrupimArtDL  = @pGrupimArtDL,
                                  @pGrupimArtFar = @pGrupimArtFar,
                                  @pGrupimArtBC  = @pGrupimArtBC;
    RaisError (N'2.4    -      Mbaroi Import Celje Mg ..! ',0,1) with NoWait;


    Exec  dbo.Isd_ImportCeljeFSAB @pDbOrigjine = @DataBase, 
                                  @pDateCls    = @pDateKp,
                                  @pDateDoc    = @pDateOpen,
                                  @pWhere      = '',
                                  @pModul      = 'F', 
                                  @pAnalitik   = @pAnalitikFu;
    RaisError (N'2.5    -      Mbaroi Import Celje Furnitore ..! ',0,1) with NoWait;

    Exec  dbo.Isd_ImportCeljeFSAB @pDbOrigjine = @DataBase, 
                                  @pDateCls    = @pDateKp,
                                  @pDateDoc    = @pDateOpen,
                                  @pWhere      = '',
                                  @pModul      = 'S', 
                                  @pAnalitik   = @pAnalitikKl;
    RaisError (N'2.6    -      Mbaroi Import Celje Kliente ..!',0,1) with NoWait;

    Exec  dbo.Isd_ImportCeljeFSAB @pDbOrigjine = @DataBase, 
                                  @pDateCls    = @pDateKp,
                                  @pDateDoc    = @pDateOpen,
                                  @pWhere      = '',
                                  @pModul      = 'A', 
                                  @pAnalitik   = 0;
    RaisError (N'2.7    -      Mbaroi Import Celje Arke ..! ',0,1) with NoWait;

    Exec  dbo.Isd_ImportCeljeFSAB @pDbOrigjine = @DataBase, 
                                  @pDateCls    = @pDateKp,
                                  @pDateDoc    = @pDateOpen,
                                  @pWhere      = '',
                                  @pModul      = 'B', 
                                  @pAnalitik   = 0;
   RaisError (N'2.8     -      Mbaroi Import Celje Banke ..! ',0,1) with NoWait;


   Declare @DtMin     Varchar(20),
           @DtMax     Varchar(30);
       Set @DtMin = dbo.Isd_DateMinMaxSql(0);
       Set @DtMax = dbo.Isd_DateMinMaxSql(1);

 
 -- Postim te Gjitha dokumentat e Reja....

  RaisError (N'2.9    -      Fillim Kalim LM - Arke ..! ',0,1) with NoWait;
  Exec dbo.Isd_KalimLM            @pTip = 'A', @pNrRendor = 0, @pSQLFilter = '', @pTableNameTmp = '#KalimLM_AR';

  RaisError (N'2.10   -      Fillim Kalim LM - Banke ..! ',0,1) with NoWait;
  Exec dbo.Isd_KalimLM            @pTip = 'B', @pNrRendor = 0, @pSQLFilter = '', @pTableNameTmp = '#KalimLM_BA';

  RaisError (N'2.11   -      Fillim Kalim LM - FF ..! ',0,1) with NoWait;
  Exec dbo.Isd_KalimLM            @pTip = 'F', @pNrRendor = 0, @pSQLFilter = '', @pTableNameTmp = '#KalimLM_FF';

  RaisError (N'2.12   -      Fillim Kalim LM - FJ ..! ',0,1) with NoWait;
  Exec dbo.Isd_KalimLM            @pTip = 'S', @pNrRendor = 0, @pSQLFilter = '', @pTableNameTmp = '#KalimLM_FJ';

  RaisError (N'2.13   -      Fillim Kalim LM - FH ..! ',0,1) with NoWait;
  Exec dbo.Isd_KalimLM            @pTip = 'H', @pNrRendor = 0, @pSQLFilter = '', @pTableNameTmp = '#KalimLM_FH';

  RaisError (N'2.14   -      Fillim Kalim LM - FD ..! ',0,1) with NoWait;
  Exec dbo.Isd_KalimLM            @pTip = 'D', @pNrRendor = 0, @pSQLFilter = '', @pTableNameTmp = '#KalimLM_FD';

  RaisError (N'2.15   -      Fillim Kalim LM - DG ..! ',0,1) with NoWait;
  Exec dbo.Isd_KalimLM            @pTip = 'G', @pNrRendor = 0, @pSQLFilter = '', @pTableNameTmp = '#KalimLM_DG';

  RaisError (N'2.16   -      Fillim Kalim LM - VS ..! ',0,1) with NoWait;
  Exec dbo.Isd_KalimLM            @pTip = 'E', @pNrRendor = 0, @pSQLFilter = '', @pTableNameTmp = '#KalimLM_VS';

  RaisError (N'2.17   -      Fund Kalime LM  ..! ',0,1) with NoWait;

 
 -- Ndrysho Vlerat per FK e reja te sapo Krijuara (ato me NrRendor jo tek Tempi)
    Update FKSCR 
       Set DB     = 0-DB,
           KR     = 0-KR,
           DBKRMV = 0-DBKRMV--,
        -- TREGDK = Case When TREGDK='D' Then 'K' Else 'D' End
     Where Not Exists (Select NRRENDOR From #TipDok B Where B.NRRENDOR=FKSCR.NRD And B.TIP='FK');


    Exec dbo.Isd_ImportCeljeFK    @pDbOrigjine = @DataBase1, --Genti: mendoj se duhet te jete baza qe sapo shtuam ndryshuam treguesin ..
                                  @pDateCls    = @pDateKp,
                                  @pDateDoc    = @pDateOpen,
                                  @pWhere      = '',
                                  @pModul      = 'T',
                                  @pZerim67    = 1,
                                  @pZerimAS    = 1;
 -- Ndrysho Vlerat per FK e reja te sapo Krijuara (ato me Id jo tek Tempi)
    Update FKSCR 
       Set DB     = 0-DB,
           KR     = 0-KR,
           DBKRMV = 0-DBKRMV--,
         --TREGDK = Case When TREGDK='D' Then 'K' Else 'D' End
     Where Not Exists (Select NRRENDOR From #TipDok B Where B.NRRENDOR=FKSCR.NRD And B.TIP='FK');



---- Procedure e shtuar nga Genti
---- Iliri: Nuk e kuptoj sepse e kam bere pak me siper....
--    Print '2 - Fillim Kalim LM - VS per Fk-ne e krijuar nga Import celje'  --Genti: duhej postuar dhe veprimi i fundit
--    Exec dbo.Isd_KalimLM            @pTip = 'E', @pNrRendor = 0, @pSQLFilter = '', @pTableNameTmp = '#KalimLM_VS'
--


  -- Fshirje te panevojeshmet ....
     RaisError (N'2.18   -      Fshirje FK,FH,VS te panevojeshme ..! ',0,1) with NoWait;

    Delete 
      From FK 
     Where DATEDOK<=Dbo.DATEVALUE(@pDateKp) And 
          (Exists (Select NRRENDOR From #TipDok B Where B.NRRENDOR=FK.NRRENDOR And B.TIP='FK'));
    Delete 
      From FH 
     Where DATEDOK<=Dbo.DATEVALUE(@pDateKp) And 
          (Exists (Select NRRENDOR From #TipDok B Where B.NRRENDOR=FH.NRRENDOR And B.TIP='FH'));
    Delete 
      From VS 
     Where DATEDOK<=Dbo.DATEVALUE(@pDateKp) And 
          (Exists (Select NRRENDOR From #TipDok B Where B.NRRENDOR=VS.NRRENDOR And B.TIP='VS'));

      Exec dbo.Isd_DeleteDocs '','FK,FH,VS,VSST,FKST',@pDateKp,0,0;
     RaisError (N'2.19   -      Fund te Fshirjeve ..! ',0,1) with NoWait;


 -- Ditaret
    RaisError (N'2.20   -      Fillim Ditare per Arka ..! ',0,1) with NoWait;
    Exec dbo.Isd_GjenerimDitar @DtMin, @DtMax, 'A','1';

    RaisError (N'2.21   -      Fillim Ditare per Banka ..! ',0,1) with NoWait;
    Exec dbo.Isd_GjenerimDitar @DtMin, @DtMax, 'B','1';

    RaisError (N'2.22   -      Fillim Ditare per FF ..! ',0,1) with NoWait;
    Exec dbo.Isd_GjenerimDitar @DtMin, @DtMax, 'F','1';

    RaisError (N'2.23   -      Fillim Ditare per FJ ..! ',0,1) with NoWait;
    Exec dbo.Isd_GjenerimDitar @DtMin, @DtMax, 'S','1';


    Set  @Sql = 'DBCC ShrinkDataBase ('+Db_Name()+')';
    Exec (@Sql);



RaisError (N'

    -----------------------------------
2      -      FUND   Isd_NdarjeNd2 !
---------------------------------------

',0,1) with NoWait;






GO
