SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   FUNCTION [dbo].[Isd_TestTotalDok]
(
 @pTableName  Varchar(50),
 @pNrRendor   Int
)

Returns Varchar(100)

AS


BEGIN


     DECLARE @vRound1     Float,
             @vRound2     Float,
             @vRound      Float,
             @vD1         Float,
             @vD2         Float,
             @vD3         Float,
             @NrRendor    Int,
             @TableName   Varchar(40),
             @KMon        Varchar(10),
             @Error       Bit,
             @Result      Varchar(50);

         SET @TableName = @pTableName;
         SET @NrRendor  = @pNrRendor; --436690;

         SET @vRound1   = 1;
         SET @vRound2   = 0.02;
         SET @vD1       = 0;
         SET @vD2       = 0;
         SET @vD3       = 0;

         SET @Result    = '';
         SET @Error     = 0;

          IF CHARINDEX(','+@TableName+',',',FJ,FF,FJT,ORK,OFK,ORF,SM,FK,VS,ARKA,BANKA,VSST,FKST')=0
             BEGIN
               RETURN @Result;
             END;

          IF CHARINDEX(','+@TableName+',',',FK,VS,ARKA,BANKA,FKST,VSST')>0
             BEGIN
               SET @vRound   = 2;

               IF  @TableName='FK'    AND EXISTS  (   SELECT SUM(ISNULL(B.DBKRMV,0))
                                                        FROM FK A INNER JOIN FKSCR B ON A.NRRENDOR=B.NRD
                                                       WHERE A.NRRENDOR=@NrRendor                              
                                                    GROUP BY A.NRRENDOR
                                                      HAVING ABS(SUM(ISNULL(B.DBKRMV,0)))>=@vRound
                                                    )
                   SET @Error = 1;


               IF  @TableName='VS'    AND EXISTS   (   SELECT SUM(ISNULL(B.DBKRMV,0))
                                                         FROM VS A INNER JOIN VSSCR B ON A.NRRENDOR=B.NRD
                                                        WHERE A.NRRENDOR=@NrRendor                              
                                                     GROUP BY A.NRRENDOR
                                                       HAVING ABS(SUM(ISNULL(B.DBKRMV,0)))>=@vRound
                                                    )
                   SET @Error = 1;


               IF  @TableName='ARKA'  AND EXISTS   (   SELECT SUM(ISNULL(B.DBKRMV,0))
                                                         FROM ARKA A INNER JOIN ARKASCR B ON A.NRRENDOR=B.NRD
                                                        WHERE A.NRRENDOR=@NrRendor                              
                                                     GROUP BY A.NRRENDOR
                                                       HAVING ABS(SUM(ISNULL(B.DBKRMV,0)))>=@vRound
                                                    )
                   SET @Error = 1;

             
               IF  @TableName='BANKA' AND EXISTS   (   SELECT SUM(ISNULL(B.DBKRMV,0))
                                                         FROM BANKA A INNER JOIN BANKASCR B ON A.NRRENDOR=B.NRD
                                                        WHERE A.NRRENDOR=@NrRendor                              
                                                     GROUP BY A.NRRENDOR
                                                       HAVING ABS(SUM(ISNULL(B.DBKRMV,0)))>=@vRound
                                                    )
                   SET @Error = 1;


               IF  @TableName='VSST'  AND EXISTS   (   SELECT SUM(ISNULL(B.DBKRMV,0))
                                                         FROM VSST A INNER JOIN VSSTSCR B ON A.NRRENDOR=B.NRD
                                                        WHERE A.NRRENDOR=@NrRendor                              
                                                     GROUP BY A.NRRENDOR
                                                       HAVING ABS(SUM(ISNULL(B.DBKRMV,0)))>=@vRound
                                                    )
                   SET @Error = 1;

               IF  @TableName='FKST'  AND EXISTS   (   SELECT SUM(ISNULL(B.DBKRMV,0))
                                                         FROM FKST A INNER JOIN FKSTSCR B ON A.NRRENDOR=B.NRD
                                                        WHERE A.NRRENDOR=@NrRendor                              
                                                     GROUP BY A.NRRENDOR
                                                       HAVING ABS(SUM(ISNULL(B.DBKRMV,0)))>=@vRound
                                                    )
                   SET @Error = 1;

               IF  @Error=1
                   SET @Result = 'Gabim: Shuma Debi <> Shuma Kredi';

               RETURN  @Result;

             END;





-- Dokumenta magazine


          IF @TableName='FJ'
             BEGIN

                 SELECT @vRound = CASE WHEN MAX(ISNULL(A.KMON,''))='' 
                                       THEN @vRound1 
                                       ELSE @vRound2 
                                  END,
                        @vD1    = ROUND(MAX(A.VLPATVSH)-SUM(B.VLPATVSH),2),
                        @vD2    = ROUND(MAX(A.VLTVSH)  -SUM(B.VLTVSH),2),
                        @vD3    = CASE WHEN MAX(ISNULL(A.VLERZBR,0))=0 
                                       THEN ROUND(MAX(A.VLERTOT) -SUM(B.VLERABS),2)
                                       ELSE ROUND(MAX(A.VLPATVSH - A.VLERZBR + A.VLTVSH - A.VLERTOT),2)
                                  END
                   FROM FJ A INNER JOIN FJSCR B ON A.NRRENDOR=B.NRD
                  WHERE A.NRRENDOR=@NrRendor                              
               GROUP BY A.NRRENDOR;

             END;

          IF @TableName='FF'
             BEGIN

                 SELECT @vRound = CASE WHEN MAX(ISNULL(A.KMON,''))='' 
                                       THEN @vRound1 
                                       ELSE @vRound2 
                                  END,
                        @vD1    = ROUND(MAX(A.VLPATVSH)-SUM(B.VLPATVSH),2),
                        @vD2    = ROUND(MAX(A.VLTVSH)  -SUM(B.VLTVSH),2),
                        @vD3    = CASE WHEN MAX(ISNULL(A.VLERZBR,0))=0 
                                       THEN ROUND(MAX(A.VLERTOT) -SUM(B.VLERABS),2)
                                       ELSE ROUND(MAX(A.VLPATVSH - A.VLERZBR + A.VLTVSH - A.VLERTOT),2)
                                  END
                   FROM FF A INNER JOIN FFSCR B ON A.NRRENDOR=B.NRD
                  WHERE A.NRRENDOR=@NrRendor                              
               GROUP BY A.NRRENDOR;

             END;

          IF @TableName='FJT'
             BEGIN

                 SELECT @vRound = CASE WHEN MAX(ISNULL(A.KMON,''))='' 
                                       THEN @vRound1 
                                       ELSE @vRound2 
                                  END,
                        @vD1    = ROUND(MAX(A.VLPATVSH)-SUM(B.VLPATVSH),2),
                        @vD2    = ROUND(MAX(A.VLTVSH)  -SUM(B.VLTVSH),2),
                        @vD3    = CASE WHEN MAX(ISNULL(A.VLERZBR,0))=0 
                                       THEN ROUND(MAX(A.VLERTOT) -SUM(B.VLERABS),2)
                                       ELSE ROUND(MAX(A.VLPATVSH - A.VLERZBR + A.VLTVSH - A.VLERTOT),2)
                                  END
                   FROM FJT A INNER JOIN FJTSCR B ON A.NRRENDOR=B.NRD
                  WHERE A.NRRENDOR=@NrRendor                              
               GROUP BY A.NRRENDOR;

             END;

          IF @TableName='OFK'
             BEGIN

                 SELECT @vRound = CASE WHEN MAX(ISNULL(A.KMON,''))='' 
                                       THEN @vRound1 
                                       ELSE @vRound2 
                                  END,
                        @vD1    = ROUND(MAX(A.VLPATVSH)-SUM(B.VLPATVSH),2),
                        @vD2    = ROUND(MAX(A.VLTVSH)  -SUM(B.VLTVSH),2),
                        @vD3    = CASE WHEN MAX(ISNULL(A.VLERZBR,0))=0 
                                       THEN ROUND(MAX(A.VLERTOT) -SUM(B.VLERABS),2)
                                       ELSE ROUND(MAX(A.VLPATVSH - A.VLERZBR + A.VLTVSH - A.VLERTOT),2)
                                  END
                   FROM OFK A INNER JOIN OFKSCR B ON A.NRRENDOR=B.NRD
                  WHERE A.NRRENDOR=@NrRendor                              
               GROUP BY A.NRRENDOR;

             END;


          IF @TableName='ORK'
             BEGIN

                 SELECT @vRound = CASE WHEN MAX(ISNULL(A.KMON,''))='' 
                                       THEN @vRound1 
                                       ELSE @vRound2 
                                  END,
                        @vD1    = ROUND(MAX(A.VLPATVSH)-SUM(B.VLPATVSH),2),
                        @vD2    = ROUND(MAX(A.VLTVSH)  -SUM(B.VLTVSH),2),
                        @vD3    = CASE WHEN MAX(ISNULL(A.VLERZBR,0))=0 
                                       THEN ROUND(MAX(A.VLERTOT) -SUM(B.VLERABS),2)
                                       ELSE ROUND(MAX(A.VLPATVSH - A.VLERZBR + A.VLTVSH - A.VLERTOT),2)
                                  END
                   FROM ORK A INNER JOIN ORKSCR B ON A.NRRENDOR=B.NRD
                  WHERE A.NRRENDOR=@NrRendor                              
               GROUP BY A.NRRENDOR;

             END;


          IF @TableName='ORF'
             BEGIN

                 SELECT @vRound = CASE WHEN MAX(ISNULL(A.KMON,''))='' 
                                       THEN @vRound1 
                                       ELSE @vRound2 
                                  END,
                        @vD1    = ROUND(MAX(A.VLPATVSH)-SUM(B.VLPATVSH),2),
                        @vD2    = ROUND(MAX(A.VLTVSH)  -SUM(B.VLTVSH),2),
                        @vD3    = CASE WHEN MAX(ISNULL(A.VLERZBR,0))=0 
                                       THEN ROUND(MAX(A.VLERTOT) -SUM(B.VLERABS),2)
                                       ELSE ROUND(MAX(A.VLPATVSH - A.VLERZBR + A.VLTVSH - A.VLERTOT),2)
                                  END
                   FROM ORF A INNER JOIN ORFSCR B ON A.NRRENDOR=B.NRD
                  WHERE A.NRRENDOR=@NrRendor                              
               GROUP BY A.NRRENDOR;

             END;

          IF @TableName='SM'
             BEGIN

                 SELECT @vRound = CASE WHEN MAX(ISNULL(A.KMON,''))='' 
                                       THEN @vRound1 
                                       ELSE @vRound2 
                                  END,
                        @vD1    = ROUND(MAX(A.VLPATVSH)-SUM(B.VLPATVSH),2),
                        @vD2    = ROUND(MAX(A.VLTVSH)  -SUM(B.VLTVSH),2),
                        @vD3    = CASE WHEN MAX(ISNULL(A.VLERZBR,0))=0 
                                       THEN ROUND(MAX(A.VLERTOT) -SUM(B.VLERABS),2)
                                       ELSE ROUND(MAX(A.VLPATVSH - A.VLERZBR + A.VLTVSH - A.VLERTOT),2)
                                  END
                   FROM SM A INNER JOIN SMSCR B ON A.NRRENDOR=B.NRD
                  WHERE A.NRRENDOR=@NrRendor                              
               GROUP BY A.NRRENDOR;

             END;


         SET @vRound = ISNULL(@vRound,0.01);

         SET @Result  = CASE WHEN ABS(ISNULL(@vD1,0))>@vRound THEN 'Vl. pa tvsh,' ELSE '' END +
                        CASE WHEN ABS(ISNULL(@vD2,0))>@vRound THEN 'Vl. tvsh,'    ELSE '' END + 
                        CASE WHEN ABS(ISNULL(@vD3,0))>@vRound THEN 'Vl. total'    ELSE '' END;

          IF @Result<>''
             SET @Result = 'Gabim kuadrimi: '+@Result;

  RETURN (LTRIM(RTRIM(@Result)));

END



GO
