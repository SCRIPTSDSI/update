SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE       Procedure [dbo].[Isd_GjenerimFtDocumentsTest]
( 
  @PUser        Varchar(20),
  @PLgJob       Varchar(30),     
  @PTableName   Varchar(30),
  @PTmpName     Varchar(30),
  @PSelected    Bit
 )

As

         SET NOCOUNT ON

     Declare @Sql            Varchar(Max),
             @TableName      Varchar(30),
             @TmpName        Varchar(30);
--           @User           Varchar(20),
--           @LgJob          Varchar(30);


         SET @TableName    = @PTableName;
         SET @TmpName      = @PTmpName;
--       SET @User         = @PUser;
--       SET @LgJob        = @PLgJob;



         SET @Sql = '

          IF OBJECT_ID(''TEMPDB..#TESTNRDOK1'') is not null
             DROP TABLE #TESTNRDOK1;
          IF OBJECT_ID(''TEMPDB..#TESTNRDSHOQ2'') is not null
             DROP TABLE #TESTNRDSHOQ2;
          IF OBJECT_ID(''TEMPDB..#TESTNRSERIAL3'') is not null
             DROP TABLE #TESTNRSERIAL3;


      SELECT VITI=YEAR(A.DATEDOK),A.NRDOK,A.KODFKL
        INTO #TESTNRDOK1
        FROM '+@TmpName+' A INNER JOIN '+@TableName+' B ON A.NRDOK=B.NRDOK AND YEAR(A.DATEDOK)=YEAR(B.DATEDOK)
       WHERE 0=0
    ORDER BY 1,2;

      SELECT VITI=YEAR(A.DTDSHOQ),A.NRDSHOQ,A.KODFKL
        INTO #TESTNRDSHOQ2
        FROM '+@TmpName+' A INNER JOIN '+@TableName+' B ON A.NRDSHOQ=B.NRDSHOQ AND YEAR(A.DTDSHOQ)=YEAR(B.DTDSHOQ)
       WHERE 0=0 AND ISNULL(A.NRDSHOQ,'''')<>'''' AND ISNULL(B.NRDSHOQ,'''')<>''''
    ORDER BY 1,2;

      SELECT VITI=YEAR(A.DTDSHOQ),A.NRSERIAL,A.KODFKL
        INTO #TESTNRSERIAL3
        FROM '+@TmpName+' A INNER JOIN '+@TableName+' B ON ISNULL(A.NRSERIAL,'''')=ISNULL(B.NRSERIAL,'''') 
       WHERE 0=0 AND ISNULL(A.NRSERIAL,'''')<>'''' AND ISNULL(B.NRSERIAL,'''')<>''''
    ORDER BY 1,2;


   -- SELECT A.DATEDOK,A.NRDOK,A.NRDSHOQ,A.DTDSHOQ,A.KODFKL,A.KMON,A.KMAG,   KL=K.KOD,MN=M.KOD,MG=G.KOD,T1.NRDOK,T1.VITI,

      UPDATE A

         SET MSGERROR = CASE WHEN ISNULL(K.KOD,'''')  = ISNULL(A.KODFKL,'''')  THEN ''''                   ELSE ''Klient gabim,''   END + 
                        CASE WHEN ISNULL(M.KOD,'''')  = ISNULL(A.KMON,'''')    THEN ''''                   ELSE ''Monedhe gabim,''  END + 
                        CASE WHEN ISNULL(G.KOD,'''')  = ISNULL(A.KMAG,'''')    THEN ''''                   ELSE ''Magazine gabim,'' END +

                        CASE WHEN dbo.Isd_DateToGjendje(CONVERT(VARCHAR(30),A.DATEDOK,104))<>''H'' 
                                                                               THEN ''Datedok gabim,''     ELSE ''''                END +

                        CASE WHEN ISNULL(T1.NRDOK,0) = A.NRDOK                 THEN ''NrDok dublikuar,''   ELSE ''''                END +

                        CASE WHEN 1=1 AND ISNULL(T2.NRDSHOQ,'''')  = ISNULL(A.NRDSHOQ,'''') AND ISNULL(A.NRDSHOQ,'''')<>''''
                                                                               THEN ''NrDShoq dublikuar,'' ELSE ''''                END +
                        CASE WHEN 1=1 AND ISNULL(T3.NRSERIAL,'''') = ISNULL(A.NRSERIAL,'''') AND ISNULL(A.NRSERIAL,'''')<>''''
                                                                               THEN ''Serial dublikuar,''  ELSE ''''                END 
                   
        FROM '+@TmpName+' A 
                    LEFT JOIN KLIENT         K  ON A.KODFKL  = K.KOD
                    LEFT JOIN MONEDHA        M  ON ISNULL(A.KMON,'''')=ISNULL(M.KOD,'''')
                    LEFT JOIN MAGAZINA       G  ON A.KMAG    = G.KOD
                    LEFT JOIN #TESTNRDOK1    T1 ON A.NRDOK   = T1.NRDOK   AND YEAR(A.DATEDOK)=T1.VITI
                    LEFT JOIN #TESTNRDSHOQ2  T2 ON A.NRDSHOQ = T2.NRDSHOQ AND YEAR(A.DTDSHOQ)=T2.VITI
                    LEFT JOIN #TESTNRSERIAL3 T3 ON ISNULL(A.NRSERIAL,'''')=ISNULL(T3.NRSERIAL,'''') --AND YEAR(A.DATEDOK)=T3.VITI ';
   
         if  @PSelected=1
             begin
               SET @Sql = Replace(@Sql,'0=0','ZGJEDHUR=1');
             end;
         if  Charindex(','+@TableName+',',',FJ,FF,')>0
             begin
               SET @Sql = Replace(@Sql,'1=1','1=2');
             end;
         if  Charindex(','+@TableName+',',',FF,ORF,')>0
             begin
               SET @Sql = Replace(@Sql,'Klient','Furnitor');
             end;

    -- Print @Sql;
       EXEC (@Sql);
GO
