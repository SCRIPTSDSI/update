SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE Procedure [dbo].[Isd_KthimAmballazhNgaFJ]
 (
   @PTableTmpName  Varchar(20),
   @PWhere         Varchar(5000)
  )
As

-- Krijon nreshta per nje FHSCR e cila mer nga faturat vetem reshtat Amballazh

-- EXEC [dbo].[Isd_KthimAmballazhNgaFJ] 
--      '#FHSCR',
--      'A.KODFKL>='''' AND A.KODFKL<=''zzzz'' AND A.DATEDOK>=DBO.DATEVALUE(''31/12/2015'') AND A.DATEDOK<=DBO.DATEVALUE(''31/12/2015'')'


         Set NoCount On

     Declare @Sql        Varchar(Max),
             @TableName  Varchar(20),
             @Where      Varchar(Max);

         SET @TableName  = @PTableTmpName;
         SET @Where      = @PWhere;

         Set @Sql = '
      INSERT INTO '+@TableName+' 
            (KOD,KARTLLG,KODAF,PERSHKRIM,NJESI,NJESINV,BC,TIPKLL,KONVERTART,KMON,

             SASI,CMIMM,CMIMBS,CMIMOR,CMIMSH,VLERAM,VLERABS,VLERASH,VLERAFT,VLERAOR,
             KOEFSHB,PROMOCTIP,PROMOC,PROMOCKOD,

             KOMENT,RIMBURSIM,DTSKADENCE,PESHANET,PESHABRT,NRSERIAL,KODKLF,PERSHKRIMKLF,DTDOK,
             SERI,GJENROWAUT,ISAMB,NRRENDKLLG,ORDERSCR)  
      SELECT B.KOD,B.KARTLLG, B.KODAF,R1.PERSHKRIM, B.NJESI,B.NJESINV,B.BC,B.TIPKLL,B.KONVERTART,'''',

             B.SASI, R1.KOSTMES, R1.KOSTMES, R1.KOSTMES,B.CMIMBS,
             ROUND(B.SASI*R1.KOSTMES,2),ROUND(B.SASI*R1.KOSTMES,2),ROUND(B.SASI*R1.KOSTMES,2),ROUND(B.SASI*R1.KOSTMES,2),ROUND(B.SASI*R1.KOSTMES,2),
             B.KOEFSHB,B.PROMOCTIP,B.PROMOC,B.PROMOCKOD,

             ''Kthim amballazh'',B.RIMBURSIM,B.DTSKADENCE,R1.PESHANET,R1.PESHABRT,B.NRSERIAL,A.KODFKL,A.SHENIM1,A.DATEDOK,
             SERI,0,ISNULL(B.ISAMB,0),R1.NRRENDOR,0 
        FROM FJ A LEFT JOIN FJSCR   B  ON A.NRRENDOR=B.NRD 
                  LEFT JOIN ARTIKUJ R1 ON B.KARTLLG=R1.KOD
       WHERE 1=1 AND 
             A.TROW=1 AND B.TIPKLL=''K'' AND ISNULL(B.ISAMB,0)=1  
    ORDER BY A.KMON,B.KODAF,B.KARTLLG ';

         SET @Sql = REPLACE(@Sql,'1=1',REPLACE(@Where,' WHERE ',' '));
       
     Print @Sql;
        EXEC (@Sql);
--

--SELECT * FROM FJ WHERE ISAMB=1
GO
