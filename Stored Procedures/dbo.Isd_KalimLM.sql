SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- EXEC [Isd_KalimLM] @PTip='A', @PNrRendor=0, @PSQLFilter='A.DATEDOK>=DBO.DATEVALUE(''01/01/2011'') AND A.DATEDOK<=DBO.DATEVALUE(''31/01/2011'')', @PTableNameTmp='##AAAA';

CREATE Procedure [dbo].[Isd_KalimLM]
 (
  @PTip             Varchar(10),
  @PNrRendor        Int,
  @PSQLFilter       Varchar(MAX),
  @PTableNameTmp    Varchar(40)
  )
AS

         SET NOCOUNT ON

     DECLARE @TimeSt        Datetime,
             @TimeDi        Varchar(20),
             @TimeEn        Varchar(20),
             @DokName       Varchar(30),
             @Where         Varchar(MAX),
             @sNrRendor     Varchar(20);

         SET @TimeSt      = GETDATE();
         SET @TimeDi      = CONVERT(Varchar(20),@TimeSt,108);
         SET @Where       = '';


         IF  CHARINDEX(@PTip,'ABEHDGFSX')=0
             RETURN;
             

         SET @DokName = LTRIM(RTRIM(SUBSTRING('ARKA ,BANKA,VS   ,FH   ,FD   ,DG   ,FF   ,FJ   ,AQ   ',6*CHARINDEX(@PTip,'ABEHDGFSX')-5,5)));

         IF  @PNrRendor<>0    
             SET @Where = 'WHERE (A.NRRENDOR='+CAST(@PNrRendor AS Varchar(20))+')'
         ELSE
         IF  @PSQLFilter<>''
             SET @Where = 'WHERE '+@pSQLFilter;       -- ' AND (ISNULL(A.NRDFK,0)=0) '



   RAISERROR ('
_______________________________________________________________________________

  Fillim Kalimi ne LM te dokumentave %s.                                  %s
_______________________________________________________________________________', 0, 1,@DokName,@TimeDi) WITH NOWAIT;


-- Strukturat e Nevojeshme ne Temp

       PRINT '  Krijim struktura ne dbTemp  ';
       
          IF OBJECT_ID('TempDb..#FK')    IS NOT NULL
             DROP TABLE #FK;
          IF OBJECT_ID('TempDb..#FKSCR') IS NOT NULL
             DROP TABLE #FKSCR;

      SELECT * INTO #FK     FROM FK    WHERE 1=2;
      SELECT * INTO #FKSCR  FROM FKSCR WHERE 1=2;

          IF NOT EXISTS (SELECT NAME FROM Sys.COLUMNS WHERE OBJECT_ID=OBJECT_ID('FKSCR') AND NAME='KMAG')
   	         ALTER TABLE #FKSCR ADD KMAG     Varchar(10) NULL;
          IF NOT EXISTS (SELECT NAME FROM Sys.COLUMNS WHERE OBJECT_ID=OBJECT_ID('FKSCR') AND NAME='KODREF')
	         ALTER TABLE #FKSCR ADD KODREF   Varchar(30) NULL;
	      IF NOT EXISTS (SELECT NAME FROM Sys.COLUMNS WHERE OBJECT_ID=OBJECT_ID('FKSCR') AND NAME='MSGERROR')
	         ALTER TABLE #FKSCR ADD MSGERROR Varchar(250) NULL;
	      IF NOT EXISTS (SELECT NAME FROM Sys.COLUMNS WHERE OBJECT_ID=OBJECT_ID('FKSCR') AND NAME='DSCERROR')
	         ALTER TABLE #FKSCR ADD DSCERROR Varchar(250) NULL; 
	      IF NOT EXISTS (SELECT NAME FROM Sys.COLUMNS WHERE OBJECT_ID=OBJECT_ID('FKSCR') AND NAME='SEGMENT')
	         ALTER TABLE #FKSCR ADD SEGMENT  Varchar(250) NULL ;
	      IF NOT EXISTS (SELECT NAME FROM Sys.COLUMNS WHERE OBJECT_ID=OBJECT_ID('FKSCR') AND NAME='DEPRF')
	         ALTER TABLE #FKSCR ADD DEPRF    Varchar(30) NULL ;
	      IF NOT EXISTS (SELECT NAME FROM Sys.COLUMNS WHERE OBJECT_ID=OBJECT_ID('FKSCR') AND NAME='LISTERF')
	         ALTER TABLE #FKSCR ADD LISTERF  Varchar(30) NULL ;
	      IF NOT EXISTS (SELECT NAME FROM Sys.COLUMNS WHERE OBJECT_ID=OBJECT_ID('FKSCR') AND NAME='DEPART')
	         ALTER TABLE #FKSCR ADD DEPART   Varchar(30) NULL ;
	      IF NOT EXISTS (SELECT NAME FROM Sys.COLUMNS WHERE OBJECT_ID=OBJECT_ID('FKSCR') AND NAME='LISTEART')
	         ALTER TABLE #FKSCR ADD LISTEART Varchar(30) NULL ;

          IF NOT EXISTS (SELECT NAME FROM Sys.COLUMNS WHERE OBJECT_ID=OBJECT_ID('FKSCR') AND NAME='SG1')
             BEGIN
	           ALTER TABLE #FKSCR ADD SG1  Varchar(30)  NULL;
  	           ALTER TABLE #FKSCR ADD SG2  Varchar(30)  NULL; 
	           ALTER TABLE #FKSCR ADD SG3  Varchar(30)  NULL; 
	           ALTER TABLE #FKSCR ADD SG4  Varchar(30)  NULL; 
	           ALTER TABLE #FKSCR ADD SG5  Varchar(30)  NULL; 
             END; 

      SELECT * INTO #FKSCR1 FROM #FKSCR WHERE 1=2;

   RAISERROR ('   Fund krijim struktura ne dbTemp', 0, 1) WITH NOWAIT;



-- Fshirje te FK-ve 

         IF  @PNrRendor<>'0'
             BEGIN
               EXEC(' 
                     DELETE B FROM '+@DokName+' A INNER JOIN FK B ON A.NRDFK=B.NRRENDOR '+@Where + ';

                     UPDATE A SET NRDFK=0 FROM '+@DokName+' A '+@Where+' AND ISNULL(A.NRDFK,0)<>0; ');
             END;
             
         IF  @Where<>''
             SET @Where = @Where + ' AND (ISNULL(A.NRDFK,0)=0) '
         ELSE  
             SET @Where = 'WHERE (ISNULL(A.NRDFK,0)=0) ';
   --  Genti Rasti kur @Where vjen bosh dhe kjo bente qe te postoheshin dhe njehere te gjithe dokumentat

      SELECT @sNrRendor = CAST(@PNrRendor AS Varchar(20));
   


          IF CHARINDEX(@PTip,'ABESFHDGX')>0
             BEGIN
               IF  @PTip='S'
                   EXEC Isd_KalimLM_FJ    @PTip, @sNrRendor, @Where, @PTableNameTmp
               ELSE
               IF  @PTip='F'
                   EXEC Isd_KalimLM_FF    @PTip, @sNrRendor, @Where, @PTableNameTmp
               ELSE
               IF  @PTip='H'
                   EXEC Isd_KalimLM_FH    @PTip, @sNrRendor, @Where, @PTableNameTmp
               ELSE
               IF  @PTip='D'
                   EXEC Isd_KalimLM_FD    @PTip, @sNrRendor, @Where, @PTableNameTmp
               ELSE
               IF  @PTip='X'
                   EXEC Isd_KalimLM_AQ    @PTip, @sNrRendor, @Where, @PTableNameTmp
               ELSE
                   EXEC Isd_KalimLM_ABEG  @PTip, @sNrRendor, @Where, @PTableNameTmp
             END;


-- WaitFor Delay '00:00:00:200'

          IF OBJECT_ID('TempDb..#FK')    IS NOT NULL
             DROP TABLE #FK;
          IF OBJECT_ID('TempDb..#FKSCR') IS NOT NULL
             DROP TABLE #FKSCR;


         SET @TimeEn = CONVERT(Varchar(10),GETDATE(),108)
         SET @TimeDi = CONVERT(Varchar(10),DATEADD(Second,DATEDIFF(Second,@TimeSt,GETDATE()),'2001-01-01 00:00:00'),108)



   RAISERROR (N'
_______________________________________________________________________________

  Fund Kalimi ne LM te dokumentave %s.   %s.   %s
_______________________________________________________________________________', 0, 1,@DokName,@TimeEn,@TimeDi) WITH NOWAIT;

GO
