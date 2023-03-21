SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE    PROCEDURE [dbo].[Isd_AQCeljeCommands]
(
  @pNrRendorDok    Int,
  @pPerdorues      VARCHAR(20),
  @pWhere          VARCHAR(MAX),
  @pCommand        VARCHAR(20)
 )

AS

-- EXEC Isd_AQCeljeCreate 3,'ADMIN','ADD';

         SET NOCOUNT OFF
         
     DECLARE @Nrd           Int,
             @Perdorues     Varchar(20),
             @Command       Varchar(20);
             
         SET @Nrd         = ISNULL(@pNrRendorDok,0);    
         SET @Perdorues   = @pPerdorues;
         SET @Command     = UPPER(@pCommand);
         
         
         
         
         
--        1. Shtim celje per ato qe mungojne         



          IF @Command='ADD' 
             BEGIN

                 INSERT INTO AQCelje
                       (KARTLLG,KOD,KODAF,PERSHKRIM,DATEOPER,VLERAFAT,VLERAFATMV,AMVLEREMBET,KURS1,KURS2,KMON,  USI,USM,TIPKLL,NRD,NRRENDKLLG)
                
                 SELECT A.KARTLLG,A.KARTLLG,A.KARTLLG,A.PERSHKRIM,A.DATEOPER,
                        VLERACEL     = ROUND(CASE WHEN ISNULL(A.KMON,'')='' 
                                                  THEN ISNULL(A.VLERACELMV,0) 
                                                  ELSE ROUND((ISNULL(A.VLERACELMV,0)*ISNULL(A.KURS1,1))/ISNULL(A.KURS2,1),2) 
                                             END,2),
                        VLERACELMV   = ROUND(A.VLERACELMV,2),
                        AMVLEREMBET  = ISNULL(A.AMVLEREMBET,0),
                        KURS1        = ISNULL(A.KURS1,1),
                        KURS2        = ISNULL(A.KURS2,1),
                        KMON         = ISNULL(A.KMON,''),
                        USI          = @Perdorues,
                        USM          = @Perdorues,
                        TIPKLL       = 'X',
                        NRD          = R1.NRRENDOR,
                        NRRENDKLLG   = R1.NRRENDOR
                   FROM

                     (
                        SELECT A.KARTLLG, A.PERSHKRIM, A.DATEOPER, R2.AMVLEREMBET,
                               VLERACELMV = CASE WHEN ISNULL(R2.AMVLEREMBET,0)=1 
                                                 THEN ROUND(ISNULL(A.VLERABS,0)+ISNULL(A.VLERAAM,0),2)
                                                 ELSE ROUND(ISNULL(A.VLERABS,0),2)
                                            END, 
                               KURS1      = CASE WHEN ISNULL(A.KMON,'')='' OR ISNULL(A.KURS1,1)*ISNULL(A.KURS2,1)<=0 THEN 1 ELSE ISNULL(A.KURS2,1) END,
                               KURS2      = CASE WHEN ISNULL(A.KMON,'')='' OR ISNULL(A.KURS1,1)*ISNULL(A.KURS2,1)<=0 THEN 1 ELSE ISNULL(A.KURS2,1) END, 
                               KMON       = ISNULL(A.KMON,''),CE.NRD     --, A.* 
                    
                          FROM AQSCR A INNER JOIN AQKARTELA  R1 ON A.KARTLLG=R1.KOD
                                       INNER JOIN AQKategori R2 ON R1.KATEGORI=R2.KOD
                                       LEFT  JOIN AQCelje    CE ON CE.NRD=R1.NRRENDOR 
               
                         WHERE A.NRD=@Nrd AND A.KODOPER='CE' AND ((CE.NRD IS NULL) AND (CE.KARTLLG IS NULL))
           
                             ) A  LEFT JOIN AQKARTELA R1 ON A.KARTLLG=R1.KOD
                  
                  WHERE ISNULL(R1.NRRENDOR,0)>0           
               
               ORDER BY A.KARTLLG;

             END;






--        2. Modifikim i celjeve me diferenca
         


          IF @Command='UPDATEDIF'
             BEGIN

               UPDATE CE
                  SET CE.KARTLLG      = A.KARTLLG,
                      CE.KOD          = A.KARTLLG,
                      CE.KODAF        = A.KARTLLG,
                      CE.PERSHKRIM    = A.PERSHKRIM,
                      CE.DATEOPER     = A.DATEOPER,
                      CE.VLERAFAT     = ROUND(CASE WHEN ISNULL(A.KMON,'')='' OR ISNULL(A.KURS1,1)*ISNULL(A.KURS2,1)<=0 
                                                   THEN ISNULL(A.VLERABS,0)+ISNULL(A.VLERAAM,0) 
                                                   ELSE CE.VLERAFAT 
                                              END,2), 
                      CE.VLERAFATMV   = ROUND(ISNULL(A.VLERABS,0)+ISNULL(A.VLERAAM,0),2),
                      CE.KURS1        = CASE WHEN ISNULL(A.KMON,'')='' OR ISNULL(A.KURS1,1)*ISNULL(A.KURS2,1)<=0 THEN 1 ELSE ISNULL(A.KURS1,1) END,
                      CE.KURS2        = CASE WHEN ISNULL(A.KMON,'')='' OR ISNULL(A.KURS1,1)*ISNULL(A.KURS2,1)<=0 THEN 1 ELSE ISNULL(A.KURS2,1) END, 
                      CE.KMON         = ISNULL(A.KMON,''),
                   -- CE.USI          = @Perdorues,
                      CE.USM          = @Perdorues,
                      TIPKLL          = 'X',
                      CE.NRRENDKLLG   = R1.NRRENDOR
                    
                 FROM AQSCR A INNER JOIN AQKARTELA R1 ON A.KARTLLG=R1.KOD
                              INNER JOIN AQCelje   CE ON CE.NRD=R1.NRRENDOR
               
                WHERE A.NRD=@Nrd AND A.KODOPER='CE' AND (CE.VLERAFATMV<>(ISNULL(A.VLERABS,0)+ISNULL(A.VLERAAM,0)));
                
             END;      




--        3. Fshirje te gjitha vlerat per celjet e dokumentit konkret



          IF @Command='DELETEDOC'
             BEGIN

               DELETE CE
                 FROM AQSCR A INNER JOIN AQKARTELA R1 ON A.KARTLLG=R1.KOD
                              INNER JOIN AQCelje   CE ON CE.NRD=R1.NRRENDOR

                WHERE A.NRD=@Nrd AND A.KODOPER='CE';

             END;  
			     


--        4. Fshirje te gjitha vlerat per celjet



          IF @Command='DELETEALL'
             BEGIN

               DELETE FROM AQCelje;
                
             END;      



--        5. Fshirje vetem celjet me diference



          IF @Command='DELETEDIF'
             BEGIN

               DELETE CE
                 FROM AQSCR A INNER JOIN AQKARTELA R1 ON A.KARTLLG=R1.KOD
                              INNER JOIN AQCelje   CE ON CE.NRD=R1.NRRENDOR
               
                WHERE A.NRD=@Nrd AND A.KODOPER='CE' AND (CE.VLERAFATMV<>(ISNULL(A.VLERABS,0)+ISNULL(A.VLERAAM,0)));
                
             END;      

GO
