SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Exec [Isd_UpdateCmimMgArtikull] '31.12.2014',''
CREATE        Procedure [dbo].[Isd_UpdateCmimMgArtikuj]
( 
  @PDtKs         Varchar(30),
  @PTableTmp     Varchar(50)
 )
As


-- Update KostMes tek Lista ARTIKUJ sipas CmimM te rivleresuar por qe meret tek Fhscr,FdScr
-- Update vetem ato Artikuj qe ndodhen tek @PTableTmp (nga Programi)


        SET NOCOUNT ON

         IF OBJECT_ID('TempDB..#TEMPKM') IS NOT NULL
            DROP TABLE #TEMPKM;
         IF OBJECT_ID('TempDB..#TEMPKMFH') IS NOT NULL
            DROP TABLE #TEMPKMFH;
         IF OBJECT_ID('TempDB..#TEMPKMFD') IS NOT NULL
            DROP TABLE #TEMPKMFD;
         IF OBJECT_ID('TempDB..#TempKMArt') IS NOT NULL
            DROP TABLE #TempKMArt;


    Declare @DtKs    DateTime,
            @sDtKs   Varchar(20);

        SET @sDtKs = @PDtKs;
        SET @DtKs  = dbo.DateValue(@sDtKs);


-- Gjenerohet Lista e Artikujve dhe cmimet #TEMPKM (procedure I.)
-- Per ata qe kane sasi (pra Cmim>0) zbatohet procedure II. per te tjeret procedure III.




-- SQAROJE !

-- Nuk e kuptoj pse duhet #TEMPKM mjafton vetem @PTableTmp dhe ajo te mbushe TEMPKM por thjesdht Copy qe mos punohet me variable PTableTmp

-- Per mua bie pika I. dhe Pika II. dhe mbetet fundi i pikes III. (vetem pjesa III.A)




-- I.   Ndertohet nje Liste me ato qe do te modifikojne Artikuj.KostMes te cilat ruhen ne #TempKM


     SELECT KartLlg, Cmim = ROUND(CASE WHEN SUM(VleraM)*SUM(Sasi)>0 THEN SUM(VleraM)/SUM(Sasi) ELSE 0 END,3)

       INTO #TEMPKM

       FROM
    (
     SELECT KartLlg, Sasi, VleraM

       FROM FH A INNER JOIN FHSCR B ON A.NrRendor=B.Nrd
      WHERE DATEDOK<=@DtKs

  UNION ALL

     SELECT KartLlg, Sasi = 0-Sasi, VleraM = 0-VleraM
       FROM FD A INNER JOIN FDSCR B ON A.NrRendor=B.Nrd
      WHERE DATEDOK<=@DtKs

      ) A

   GROUP BY KartLlg
   ORDER BY KartLlg;

--     EXEC ('SELECT * FROM '+@PTableTmp);  -- Ilir 16.10.19
--   SELECT * FROM #TEMPKM;                 -- Ilir 16.10.19

         -- Fshihen kodet qe nuk jane te rivleresuara tek tabela @PTableTmp

         IF OBJECT_ID('TempDB..'+@PTableTmp) IS NOT NULL
            Begin
              Exec ('
                     DELETE B
                       FROM 
                     (
                         SELECT KARTLLG FROM #TEMPKM
                         EXCEPT 
                         SELECT KARTLLG FROM '+@PTableTmp+' 
                      ) A INNER JOIN #TEMPKM B ON A.KARTLLG=B.KARTLLG');
            End;

--   SELECT * FROM #TEMPKM;   -- Ilir 16.10.19
--   RETURN;                  -- Ilir 16.10.19


-- II.      UPDATE Cmimet > 0 tek Artikuj nga #TEMPKM per Cmim>0

     UPDATE A
        SET A.KostMes = B.CMIM
       FROM Artikuj A INNER JOIN #TEMPKM B ON A.KOD=B.KartLlg
      WHERE ISNULL(B.CMIM,0)>0

     DELETE FROM #TEMPKM WHERE ISNULL(CMIM,0)>0;



/*       -- Komentuar 16.10.19

-- III.     Per ato nga #TEMPKM me Cmim=0 mer tek FH ose FD Cmim per Cmim >0 (daten me te fundit)

         -- Fh

     SELECT B.KartLlg, A.DATEDOK, CMIMM=MAX(B.CMIMM)
       INTO #TEMPKMFH
       FROM FH A INNER JOIN FHSCR    B ON A.NrRendor=B.Nrd
                 INNER JOIN #TEMPKM  C ON B.KartLlg=C.KartLlg 
      WHERE A.DATEDOK<=@DtKs And ISNULL(B.CmimM,0)>0
   GROUP BY B.KartLlg,A.DATEDOK
   ORDER BY B.KartLlg;


         -- Fd

     SELECT B.KartLlg, A.DATEDOK, CMIMM=MAX(B.CMIMM)
       INTO #TEMPKMFD
       FROM FD A INNER JOIN FDSCR    B ON A.NrRendor=B.Nrd
                 INNER JOIN #TEMPKM  C ON B.KartLlg=C.KartLlg
      WHERE A.DATEDOK<=@DtKs And ISNULL(B.CmimM,0)>0
   GROUP BY B.KartLlg, A.DATEDOK
   ORDER BY B.KartLlg;



         -- Mer cmim ne Fh ose Fd aty ku ka daten me te fundit      

                                           
     SELECT A.KARTLLG,
            CMIMM = CASE WHEN ISNULL(A.KARTLLG,'')<>'' AND ISNULL(B.KARTLLG,'')<>'' 
                              THEN CASE WHEN A.DATEDOK>=B.DATEDOK THEN A.CMIMM ELSE B.CMIMM END
                         WHEN ISNULL(A.KARTLLG,'')<>''
                              THEN A.CMIMM
                         ELSE      B.CMIMM
                   END

       INTO #TempKMArt     

       FROM #TEMPKMFH A FULL OUTER JOIN 

                        ( SELECT A.*
                            FROM #TEMPKMFD A
                           WHERE A.DATEDOK = ( SELECT MAX(B.DATEDOK) FROM #TEMPKMFD B WHERE A.KARTLLG=B.KARTLLG )) B
                         ON A.KARTLLG=B.KARTLLG

      WHERE A.DATEDOK = ( SELECT MAX(B.DATEDOK) FROM #TEMPKMFH B WHERE A.KARTLLG=B.KARTLLG );    
      
     UPDATE A
        SET A.KOSTMES = B.CMIMM
       FROM ARTIKUJ A INNER JOIN #TempKMArt B ON A.KARTLLG=B.KOD
      WHERE ISNULL(B.CMIMM,0)>0;
      
            
--    Fund Komentuar 16.10.19    */
      



      
-- Shtuar ne vend te komentit 16.10.19

-- III.A    Per ato nga #TEMPKM me Cmim=0 mer tek FH ose FD Cmim per Cmim >0 (daten me te fundit)

     SELECT KARTLLG,CMIMM INTO #TempKart FROM FHSCR WHERE 1=2;
                                                                    -- Kriteri per MAX(NrRow) eshte = (daten me te fundit) sepse ashtu jane te renditur
     EXEC ('INSERT INTO #TempKart            
                  (KARTLLG,CMIMM)
            SELECT KARTLLG,CMIMMNEW
              FROM '+@PTableTmp+' A
             WHERE NRROW=(SELECT MAX(NRROW) FROM '+@PTableTmp+' B WHERE A.KARTLLG=B.KARTLLG) ');

     UPDATE A
        SET A.KOSTMES = B.CMIMM
       FROM ARTIKUJ A INNER JOIN #TempKart B ON A.KOD=B.KARTLLG
      WHERE ISNULL(B.CMIMM,0)>0;
     
-- Fund III.A.    Shtuar ne vend te komentit 16.10.19
     




         IF OBJECT_ID('TempDB..#TEMPKM')    IS NOT NULL
            DROP TABLE #TEMPKM;
         IF OBJECT_ID('TempDB..#TEMPKMFH')  IS NOT NULL
            DROP TABLE #TEMPKMFH;
         IF OBJECT_ID('TempDB..#TEMPKMFD')  IS NOT NULL
            DROP TABLE #TEMPKMFD;
         IF OBJECT_ID('TempDB..#TempKMArt') IS NOT NULL
            DROP TABLE #TempKMArt;
GO
