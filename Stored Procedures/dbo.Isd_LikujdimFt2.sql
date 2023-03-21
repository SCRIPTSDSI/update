SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  Procedure [dbo].[Isd_LikujdimFt2]               
(
  @PTableName   Varchar(50),
  @PVlefte      Float,
  @PKoment      Varchar(150),
  @PWhere       Varchar(Max)
)

-- Shperndarje vlefte te faturave pa shlyer. (Shiko Isd_LikujdimFt per gjenerimin e listes)

As 

Begin   
--Exec dbo.Isd_LikujdimFt2 @PTableName = 'Prove', @PVlefte = 500000, @PKoment='aaaa', @PWhere='ACTIV=1' 

--Declare @PVlefte      Float,
--        @PTableName   Varchar(50),
--        @PKoment      Varchar(150),
--        @PWhere       Varchar(Max)
--    Set @PTableName = 'Prove'
--    Set @PVlefte    = 500000
--    Set @PWhere     = 'ACTIV=1'

       if @PTableName=''
          Return

      Set NoCount On

  Declare @Sql          Varchar(Max),
          @TableName    Varchar(50)

      Set @TableName = @PTableName
      Set @Sql        = '

          UPDATE #FTLikujdim 

             SET LIKUJDIM   = 0,
                 LIKUJDIMMV = 0,
                 KURS1      = CASE WHEN ISNULL(KURS1,0)<=0 THEN 1 ELSE KURS1 END,
                 KURS2      = CASE WHEN ISNULL(KURS2,0)<=0 THEN 1 ELSE KURS2 END
           WHERE 1=1 


          UPDATE #FTLikujdim         

             SET LIKUJDIMMV = ROUND(
                              CASE WHEN -0  -        (SELECT ISNULL(SUM(DETYRIMMV),0) 
                                                        FROM #FTLikujdim   B 
                                                       WHERE 1=1 AND
		                                                     B.ROWNUMBER<A.ROWNUMBER) < 0 
                                   THEN  0 

                                   WHEN -0  -        (SELECT ISNULL(SUM(DETYRIMMV),0) 
                                                        FROM #FTLikujdim   B 
                                                       WHERE 1=1 AND
				                                             B.ROWNUMBER<A.ROWNUMBER) >= DETYRIMMV 

                                  THEN DETYRIMMV
 
                                  ELSE -0  -         (SELECT ISNULL(SUM(DETYRIMMV),0) 
                                                        FROM #FTLikujdim   B 
                                                       WHERE 1=1 AND
				                                             B.ROWNUMBER<A.ROWNUMBER) 
                            END, 2), 

                 KOMENT     = '''+IsNull(@PKoment,'')+'''

            FROM #FTLikujdim A 
           WHERE 1=1 AND ABS(VLEFTA-PJESASHLYER)>=0.01 ';


       Set @Sql = Replace(@Sql,'#FTLikujdim',@TableName);
       Set @Sql = Replace(@Sql,' -0 ','  '+Cast(IsNull(@PVlefte,0) As Varchar(50))+' ');
       if  @PWhere<>''
           Set @Sql = Replace(@Sql,'1=1',@PWhere);
     Print @Sql;
     Exec (@Sql)


      Set @Sql        = '

          UPDATE #FTLikujdim         
             SET LIKUJDIM   = ROUND(CASE WHEN ISNULL(KMON,'''')=''''          THEN LIKUJDIMMV
                                         WHEN ABS(LIKUJDIMMV-DETYRIMMV)<=0.01 THEN DETYRIM
                                         ELSE (LIKUJDIMMV*KURS1)/KURS2 END, 2)

            FROM #FTLikujdim A 
           WHERE 1=1 AND ABS(LIKUJDIMMV)<>0 ';

       Set @Sql = Replace(@Sql,'#FTLikujdim',@TableName);
       Set @Sql = Replace(@Sql,' -0 ','  '+Cast(IsNull(@PVlefte,0) As Varchar(50))+' ');
       if  @PWhere<>''
           Set @Sql = Replace(@Sql,'1=1',@PWhere);
     Print @Sql;
     Exec (@Sql)


--   Te hiqet ...
--   Exec ('SELECT * FROM '+@TableName+' A ORDER BY A.KMON,A.KOD,A.DATEDOK;');



    

/*
      Set @Sql        = '

          UPDATE #FTLikujdim 
             SET LIKUJDIM   = 0,
                 LIKUJDIMMV = 0;


          UPDATE #FTLikujdim         
             SET LIKUJDIM   = ROUND(
                              CASE WHEN -0  -        (SELECT ISNULL(SUM(DETYRIM),0) 
                                                        FROM #FTLikujdim   B 
                                                       WHERE B.KMON=A.KMON AND 1=1 AND
				                                             B.ROWNUMBER<A.ROWNUMBER) < 0 
                                   THEN  0 

                                   WHEN -0  -        (SELECT ISNULL(SUM(DETYRIM),0)  
                                                        FROM #FTLikujdim   B 
                                                       WHERE B.KMON=A.KMON AND 1=1 AND
				                                             B.ROWNUMBER<A.ROWNUMBER) >= DETYRIM 

                                   THEN DETYRIM 

                                   ELSE -0  -        (SELECT ISNULL(SUM(DETYRIM),0) 
                                                        FROM #FTLikujdim   B 
                                                       WHERE B.KMON=A.KMON AND 1=1 AND
				                                             B.ROWNUMBER<A.ROWNUMBER) 
                              END,2),

                 LIKUJDIMMV = ROUND(
                              CASE WHEN -0  -        (SELECT ISNULL(SUM(DETYRIM),0) 
                                                        FROM #FTLikujdim   B 
                                                       WHERE B.KMON=A.KMON AND 1=1 AND
		                                                     B.ROWNUMBER<A.ROWNUMBER) < 0 
                                   THEN  0 

                                   WHEN -0  -        (SELECT ISNULL(SUM(DETYRIM),0) 
                                                        FROM #FTLikujdim   B 
                                                       WHERE B.KMON=A.KMON AND 1=1 AND
				                                             B.ROWNUMBER<A.ROWNUMBER) >= DETYRIM 

                                  THEN DETYRIM
 
                                  ELSE -0  -         (SELECT ISNULL(SUM(DETYRIM),0) 
                                                        FROM #FTLikujdim   B 
                                                       WHERE B.KMON=A.KMON AND 1=1 AND
				                                             B.ROWNUMBER<A.ROWNUMBER) 
                            END * 
                            CASE WHEN ISNULL(KURS1*KURS2,0)>0 THEN KURS2/KURS1 ELSE 0 END,2), 

                 KOMENT     = '''+IsNull(@PKoment,'')+'''

            FROM #FTLikujdim A 
           WHERE 1=1 AND ABS(VLEFTA-PJESASHLYER)>=0.01 ';
*/

End;
GO
