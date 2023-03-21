SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   procedure [dbo].[Isd_ChangeFtKodMg]
(
  @PTip       Varchar(30),
  @PKMag      Varchar(30),
  @PWhere     Varchar(Max),
  @PNrStart   Int,
  @POper      Int
)
AS

--   Exec dbo.Isd_ChangeFtKodMg 'FF','AT','KMAG=''PG1''',340,0
--Declare @PTip     Varchar(30),
--        @PKMag    Varchar(30),
--        @PWhere   Varchar(Max),
--        @PNrStart Int,
--        @POper    Int;
--    Set @PTip     = 'FF';
--    Set @PKMag    = 'AT';
--    Set @PNrStart = 341;
--    Set @POper    = 0;
--


     Declare @NrMag Int,
             @Sql   Varchar(Max);


      Select @NrMag = IsNull((SELECT NRRENDOR FROM MAGAZINA WHERE KOD=@PKMag),0);

          if @NrMag<=0
             begin

		       if @POper=0          -- Display
		          begin
			          SELECT DOKUMENT, NRDOK,    DATEDOK, 
                             KMAG,     DTDMAG,   NRDMAG,  FRDMAG,
                             KMAGNEW,  NRDOKNEW, GABIM, 
				             KODFKL,   SHENIM1,  SHENIM2, NIPT,  KMON,    VLERTOT, NRRENDOR
				        FROM #ChangeKMag
			        ORDER BY DATEDOK,KMAG,NRDOK;
		          end
               else

                  Return;

             end;

          if @PWhere=''
             Set @PWhere = '1=1';

          if Object_Id('TempDB..#ChangeKMag') is not null
             DROP TABLE #ChangeKMag;

--      Exec(' 
--            Use TempDB   
--            if  Exists (SELECT Name FROM Sys.Tables WHERE Object_Id=Object_Id(''#ChangeKMag''))
--                DROP TABLE #ChangeKMag');



      SELECT DOKUMENT = @PTip,
             KODFKL,
             NRDOK,
             DATEDOK,
             KMAG,
             DTDMAG,
             NRDMAG,
             FRDMAG,
             SHENIM1,
             SHENIM2,
             NIPT,
             KMON,
             VLERTOT,
             NRRENDOR = 0,
             KMAGNEW   = @PKMag,
             NRDOKNEW  = 0,
             GABIM    = SHENIM1
        INTO #ChangeKMag
        FROM FF A 
	   WHERE 1=2;


         Set @Sql = '

		   INSERT INTO #ChangeKMag
				 (DOKUMENT, 
				  KODFKL,  NRDOK, DATEDOK, KMAG,    DTDMAG,   NRDMAG, FRDMAG,
				  SHENIM1, SHENIM2, NIPT,  KMON,    VLERTOT, NRRENDOR, 
				  KMAGNEW,  NRDOKNEW, GABIM)

		   SELECT '''+@PTip+''',
				  KODFKL,  NRDOK, DATEDOK, KMAG,    DTDMAG,   NRDMAG, FRDMAG,
				  SHENIM1, SHENIM2, NIPT,  KMON,    VLERTOT, NRRENDOR, 
				  '''+@PKMag+''',
				  NRDOKNEW,
				  GABIM = CASE WHEN Exists (SELECT NRRENDOR
											  FROM FH B
											 WHERE B.KMAG=A.KMAGNEW AND
												   YEAR(A.DATEDOK)=YEAR(B.DATEDOK) AND
												   B.NRDOK=A.NRDOKNEW)
							   THEN ''****''
							   ELSE '''' END
		           
			 FROM
		  (
		   SELECT A.KODFKL,
				  A.NRDOK,
				  A.DATEDOK,
				  A.KMAG,
				  A.DTDMAG,
				  A.NRDMAG,
				  A.FRDMAG,
				  KMAGNEW  = '''+@PKMag+''',
				  NRDOKNEW = '+Cast(@PNrStart As Varchar)+' + Row_Number() Over (Order By A.DATEDOK,A.KMAG,A.NRDOK),
				  A.SHENIM1,
				  A.SHENIM2,
				  A.NIPT,
				  A.KMON,
				  A.VLERTOT,
				  A.NRRENDOR
			 FROM FF A 
			WHERE ISNULL(KMAG,'''')<>'''' AND '+@PWhere+'
		  ) A
		 ORDER BY A.DATEDOK,A.KMAG,A.NRDOK ';


          if @PTip = 'FJ'
             begin
               Set @Sql = Replace(@Sql,' FF ',' FJ ');
               Set @Sql = Replace(@Sql,' FH ',' FD ');
             end;

        Exec (@Sql);


        Set  @Sql = '

			   UPDATE A
				  SET A.KMAG   = B.KMAGNEW,
					  A.NRDMAG = B.NRDOKNEW,
					  A.NRMAG  = '+Cast(@NrMag As Varchar)+'
				 FROM FF A INNER JOIN #ChangeKMag B ON A.NRRENDOR=B.NRRENDOR

			   UPDATE C
				  SET C.KMAG   = B.KMAGNEW,
					  C.NRDOK  = B.NRDOKNEW,
					  C.NRMAG  = '+Cast(@NrMag As Varchar)+'
				 FROM FF A INNER JOIN #ChangeKMag B ON A.NRRENDOR =B.NRRENDOR
						   INNER JOIN FH C          ON A.NRRENDDMG=C.NRRENDOR 

			   UPDATE C
				  SET C.KOD    = Dbo.Isd_SegmentNewInsert(C.KOD,'''+@PKMag+''',1)
				 FROM FF A INNER JOIN #ChangeKMag B ON A.NRRENDOR =B.NRRENDOR
						   INNER JOIN FFSCR C       ON A.NRRENDOR =C.NRD
				WHERE C.TIPKLL=''K''

			   UPDATE C
				  SET C.KOD    = Dbo.Isd_SegmentNewInsert(C.KOD,'''+@PKMag+''',1)
				 FROM FF A INNER JOIN #ChangeKMag B ON A.NRRENDOR =B.NRRENDOR
						   INNER JOIN FHSCR C       ON A.NRRENDDMG=C.NRD

           -- Delete FK

			   DELETE A
				 FROM FF A INNER JOIN #ChangeKMag B ON A.NRRENDOR=B.NRRENDOR
                           INNER JOIN FK C          ON A.NRDFK   =C.NRRENDOR
                WHERE ISNULL(A.NRDFK,0)<>0

			   UPDATE A
                  SET A.NRDFK = 0
				 FROM FF A INNER JOIN #ChangeKMag B ON A.NRRENDOR=B.NRRENDOR
                WHERE ISNULL(A.NRDFK,0)<>0

			   DELETE C
				 FROM FF A INNER JOIN #ChangeKMag B ON A.NRRENDOR  = B.NRRENDOR
                           INNER JOIN FH C          ON A.NRRENDDMG = C.NRRENDOR
                           INNER JOIN FK D          ON C.NRDFK     = D.NRRENDOR
                WHERE ISNULL(C.NRDFK,0)<>0

			   UPDATE C
                  SET C.NRDFK = 0
				 FROM FF A INNER JOIN #ChangeKMag B ON A.NRRENDOR=B.NRRENDOR
                           INNER JOIN FH C          ON A.NRRENDDMG = C.NRRENDOR
                WHERE ISNULL(C.NRDFK,0)<>0 ';

          if @PTip = 'FJ'
             begin
               Set @Sql = Replace(@Sql,' FF ',' FJ ')
               Set @Sql = Replace(@Sql,' FH ',' FD ')
             end;


		  if @POper=0          -- Display
		     begin
			     SELECT DOKUMENT, NRDOK,    DATEDOK, 
                        KMAG,     DTDMAG,   NRDMAG,  FRDMAG,
                        KMAGNEW,  NRDOKNEW, GABIM, 
				        KODFKL,   SHENIM1,  SHENIM2, NIPT,  KMON,    VLERTOT, NRRENDOR
				   FROM #ChangeKMag
			   ORDER BY DATEDOK,KMAG,NRDOK
		     end;

		else

             begin
               Exec (@Sql)
             end;


          if Object_Id('TempDB..#ChangeKMag') is not null
             DROP TABLE #ChangeKMag;
GO
