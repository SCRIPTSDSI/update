SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- Declare @d1 DateTime,
--         @d2 DateTime;
--     Set @d1 = dbo.DateValue('01/01/2014');
--     Set @d2 = dbo.DateValue('31/12/2014');
--    Exec Isd_RivlPrdMg01 '','zzz',@d1,@d2,'','zzz',1

CREATE PROCEDURE [dbo].[Isd_RivlPrdMg01]
(
  @PKMagKp      Varchar(30),
  @PKMagKs      Varchar(30),
  @PDateKp      DateTime,
  @PDateKs      DateTime,
  @PKodKp       Varchar(30),
  @PKodKs       Varchar(30),
  @pCmUpdated   Bit
)

AS


         SET NOCOUNT ON


     DECLARE @KMagKp     Varchar(30),
             @KMagKs     Varchar(30),
             @DateKp     DateTime,
             @DateKs     DateTime,
             @KodKp      Varchar(30),
             @KodKs      Varchar(30);

         SET @KMagKp   = @PKMagKp;
         SET @KMagKs   = @PKMagKs;
         SET @DateKp   = @PDateKp;
         SET @DateKs   = @PDateKs;
         SET @KodKp    = @PKodKp;
         SET @KodKs    = @PKodKs;



-- Kur hyn ne Rivleresim produkti per here te pare inicializon CMIMUPDATE=0
-- Duhet tek procedura tjeter Isd_RivlPrdMg01 e cila kontrollon vleren e CMIMUPDATE

-- Nga programi procedura [Isd_RivlPrdMg01] dhe [Isd_RivlPrdMg02] hidhen aq here sa te kete 
-- te pakten nje resht ne FHSCR me FHSCR.CMIMUPDATE=1

-- Heren e pare hidhet me @pCmUpdated=0 dhe zeron CMIMUPDATE=0
-- Heret e tjera kontrollon vetem ato FH qe kane te pakten nje CMIMUPDATE=1
-- Kjo e fundit hidhet deri sa te mos kete asnje resht ne FHSCR me CMIMUPDATE=1




          IF @pCmUpdated=0
             BEGIN
               UPDATE B
                  SET B.CMIMUPDATE=0
                 FROM FH A INNER JOIN FHSCR B ON A.NRRENDOR=B.NRD 
                WHERE --(A.KMAG    >= @KMagKp  And A.KMAG    <= @KMagKs) And 
                      --(A.DATEDOK <= @DateKs) And(A.DATEDOK <= @DateKs) And 
                      --(A.DST='PR') AND 
                      ISNULL(B.CMIMUPDATE,0)<>0
             END;



      SELECT A.NRRENDOR 
          -- INTO ZZZ1
        FROM
     (

      SELECT A.NRRENDOR,
             DATEDOK = MAX(A.DATEDOK),
             NRPRD   = ( SELECT SUM(CASE WHEN ISNULL(B.GJENROWAUT,0)=0 THEN 1 ELSE 0 END)
                           FROM FHSCR B
                          WHERE A.NRRENDOR=B.NRD  AND  (B.KARTLLG >= @KodKp AND B.KARTLLG <= @KodKs)),

             NRPRB   = ( SELECT SUM(CASE WHEN ISNULL(B.GJENROWAUT,0)=1 THEN 1 ELSE 0 END)
                           FROM FHSCR B
                          WHERE A.NRRENDOR=B.NRD),
                         
             NRPRUpd = ( SELECT SUM(CASE WHEN ISNULL(B.GJENROWAUT,0)=1 AND ISNULL(B.CMIMUPDATE,0)=1 THEN 1 ELSE 0 END)
                           FROM FHSCR B
                          WHERE A.NRRENDOR=B.NRD), 
                          
             NRNENPROD=( SELECT SUM(CASE WHEN ISNULL(B.GJENROWAUT,0)=1 AND (R.TIP='P') THEN 1 ELSE 0 END)
                           FROM FHSCR B INNER JOIN ARTIKUJ R ON B.KARTLLG=R.KOD
                          WHERE A.NRRENDOR=B.NRD),
                          
             EXNENPRD =( 
                         SELECT SUM(1)
                           FROM FH AA INNER JOIN FHSCR BB  ON AA.NRRENDOR=BB.NRD     AND AA.DATEDOK<=MIN(A.DATEDOK) AND AA.DST='PR' AND ISNULL(BB.GJENROWAUT,0)=0  AND AA.NRRENDOR<>A.NRRENDOR
                                      INNER JOIN FHSCR BBB ON BBB.KARTLLG=BB.KARTLLG AND BBB.NRD=A.NRRENDOR AND BBB.GJENROWAUT=1
                                      INNER JOIN ARTIKUJ R ON BBB.KARTLLG=R.KOD  AND R.TIP='P'
                       -- WHERE AA.DATEDOK<MIN(A.DATEDOK))                                       
                        )   

        FROM FH A INNER JOIN FHSCR   C ON A.NRRENDOR=C.NRD
        
       WHERE (A.KMAG    >= @KMagKp  And A.KMAG    <= @KMagKs) And 
             (A.DATEDOK <= @DateKs) And(A.DATEDOK <= @DateKs) And 
             (A.DST='PR') 

    GROUP BY A.NRRENDOR

      ) A --INNER JOIN FH C ON A.NRRENDOR=C.NRRENDOR

     WHERE  A.NRPRD=1 AND A.NRPRB>=1 AND 
           (CASE WHEN  @pCmUpdated=1                                           THEN NRPRUpd ELSE 1 END>=1) AND 
           (CASE WHEN (@pCmUpdated=0 AND NRNENPROD>0 AND NOT EXNENPRD IS NULL) THEN 0       ELSE 1 END>=1)
        --  AND NOT EXNENPRD IS NULL
                         
    ORDER BY A.DATEDOK, A.NRRENDOR;









GO
