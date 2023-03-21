SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--Exec [dbo].[Isd_TestFkSipasDok] 'FJ','REFERDOK=''K00010''','KODFKL=''K00010''','ADMIN',3

CREATE   procedure [dbo].[Isd_TestFkSipasDok]
(
  @PTableDok   VarChar(50),
  @PWhereDok   Varchar(Max),
  @PWhereFk    Varchar(Max),
  @PUser       VarChar(30),
  @PFormatRp   Int         
)
As


   Declare @User        Varchar(30),
           @TableD      Varchar(30),
           @DtUser      Varchar(20),
           @Org         Varchar(10),
           @Fields      Varchar(500),
           @i           Int,
           @FormatRp    Int;

       Set @FormatRp  = @PFormatRp
       Set @User      = @PUser;
       Set @TableD    = @PTableDok;
       Set @i         = dbo.Isd_StringInListInd('ARKA,BANKA,VS,FK,FH,FD,FJ,FF,DG',@TableD,',');
       Set @Org       = dbo.Isd_StringInListStr('A,B,E,T,H,D,S,F,G',@i,',');

        if @TableD<>''
           Set @DtUser = Dbo.DRHDateKP(@User,@TableD)

        if IsNull(@TableD,'')='' or @i<=0 or @Org=''
           begin
             Select PERSHKRIM = '',TROW=CAST(0 AS BIT);
             Return;
           end;

        if Object_Id('TempDB..#LiberTmp') is not null
           DROP TABLE #LiberTmp;

-- Hapi 1.   Liste e Kodeve


/* 
-- Metoda per Kolaudim

   Declare @ListLlg1    Varchar(Max),
           @ListLlg2    Varchar(Max),
           @ListLlg3    Varchar(Max),
           @Sql        nVarchar(Max);

       Set @ListLlg1 = '';
       Set @ListLlg2 = '';
       Set @ListLlg3 = '';

    SELECT @ListLlg1 = @ListLlg1 +',['+LLOGARIPK+']',
           @ListLlg2 = @ListLlg2 +',['+LLOGARIPK+']=Round(ISNULL(['+LLOGARIPK+'],0),2)',
           @ListLlg3 = @ListLlg3 +'+ISNULL(['+LLOGARIPK+'],0)'
      FROM FK A INNER JOIN FKSCR B ON A.NRRENDOR=B.NRD
     WHERE ORG='S' AND DATEDOK>=Dbo.DateValue('01/04/2011') AND DATEDOK<=Dbo.DateValue('30/04/2014')
  GROUP BY LLOGARIPK
  ORDER BY LLOGARIPK;

        if IsNull(@ListLlg1,'')=''
           begin
             Select PERSHKRIM = '';
             Return;
           end;

        if Left(@ListLlg1,1)=','
           Set @ListLlg1 = Substring(@ListLlg1,2,Len(@ListLlg1));
        if Left(@ListLlg2,1)=','
           Set @ListLlg2 = Substring(@ListLlg2,2,Len(@ListLlg2));
        if Left(@ListLlg3,1)='+'
           Set @ListLlg3 = 'Total=Round('+Substring(@ListLlg3,2,Len(@ListLlg3))+',2)';

        Print @ListLlg2
        Print @ListLlg3
--
*/


   Declare @ListLlg1    Varchar(Max),
           @ListLlg2    Varchar(Max),
           @ListLlg3    Varchar(Max),
           @Sql        nVarchar(Max),
           @Where3      Varchar(200),
           @Params     nVarchar(Max);

       Set @ListLlg1  = '';
       Set @ListLlg2  = '';
       Set @ListLlg3  = '';
       Set @Params    = N' @ListLlg1o Varchar(Max) OUTPUT,  @ListLlg2o Varchar(Max) OUTPUT,  @ListLlg3o Varchar(Max) OUTPUT';

       Set @Sql = '
    SELECT @ListLlg1o = @ListLlg1o +'',[''+LLOGARIPK+'']'',
           @ListLlg2o = @ListLlg2o +'',[''+LLOGARIPK+'']=Round(ISNULL([''+LLOGARIPK+''],0),2)'',
           @ListLlg3o = @ListLlg3o +''+ISNULL([''+LLOGARIPK+''],0)''
      FROM FK A INNER JOIN FKSCR B ON A.NRRENDOR=B.NRD
     WHERE ORG='''+@Org+''' AND 1=1 
  GROUP BY LLOGARIPK
  ORDER BY LLOGARIPK; '
--Print @Sql;

        if @PWhereFk<>''
           Set @Sql = Replace(@Sql,'1=1',@PWhereFk);

      Exec Sp_ExecutesQL @Sql, @Params, @ListLlg1o=@ListLlg1 Output, @ListLlg2o=@ListLlg2 Output, @ListLlg3o=@ListLlg3 Output

        if Left(@ListLlg1,1)=','
           Set @ListLlg1 = Substring(@ListLlg1,2,Len(@ListLlg1));
        if Left(@ListLlg2,1)=','
           Set @ListLlg2 = Substring(@ListLlg2,2,Len(@ListLlg2));
        if Left(@ListLlg3,1)='+'
           Set @ListLlg3 = 'Total=Round('+Substring(@ListLlg3,2,Len(@ListLlg3))+',2)';
     -- Print @ListLlg1; Print @ListLlg2; Print @ListLlg3;

        if IsNull(@ListLlg1,'')=''
           begin
             Select PERSHKRIM = '',TROW=CAST(0 AS BIT);
             Return;
           end;

        Set @Where3   = '';
        if  @TableD='FK'
            Set @Where3 = 'ISNULL(A.ORG,'''')=''T'' '
        else
        if  @FormatRp = '2'
            Set @Where3 = 'ISNULL(B.ORG,'''') <> '''' ' 
        else
        if  @FormatRp = '3'
            Set @Where3 = 'ISNULL(B.ORG,'''') = '''' '; 

        if  @Org='S' Or @Org='F'
            Set @Fields = 'A.DATEDOK,A.NRDOK,A.KODFKL,A.SHENIM1,A.VLERTOT,A.KMON';
        if  @Org='A' or @Org='B'
            Set @Fields = 'A.KODAB,TIPDOK,A.NUMDOK,A.DATEDOK,A.SHENIM1,A.VLERA,A.VLERAMV,A.KMON';
        if  @Org='H' or @Org='D'
            Set @Fields = 'A.KMAG,A.DATEDOK,A.NRDOK,A.SHENIM1,A.DST,A.KMAGLNK';
        if  @Org='G'
            Set @Fields = 'A.DATEDOK,A.NRDOK,A.KOD,A.SHENIM1,A.SHENIM2';
        if  @Org='E'
            Set @Fields = 'A.DATEDOK,A.NRDOK,A.PERSHKRIM1,A.PERSHKRIM2';
        if  @Org='T'
            Set @Fields = 'A.DATEDOK,A.NRDOK,A.REFERDOK,A.PERSHKRIM1,A.PERSHKRIM2,A.TIPDOK';

       Set  @Fields = 'DOK='''+@TableD+''','+@Fields;
       Set  @Sql = '

           if Object_Id(''TempDB..#LiberTmpP'') is not null
              DROP TABLE #LiberTmpP;

       SELECT * 
         INTO #LiberTmpP
         FROM 

     ( SELECT NRRENDOR_FK=A.NRRENDOR,
              B.LLOGARIPK,
              SHUMA=SUM(B.DBKRMV),
              A.ORG,
              REFERFK = CASE WHEN A.ORG IN (''A'',''B'',''H'',''D'') THEN MAX(A.REFERDOK) ELSE '''' END
         FROM FK A INNER JOIN FKSCR B ON A.NRRENDOR=B.NRD 
        WHERE A.ORG='''+@Org+''' AND 1=1
     GROUP BY A.NRRENDOR,B.LLOGARIPK,A.ORG,CASE WHEN A.ORG IN (''A'',''B'',''H'',''D'') THEN '''' ELSE A.REFERDOK END
     ) A
        PIVOT
       (
              SUM(SHUMA) FOR LLOGARIPK IN (' + @ListLlg1 + ')
        ) pvt

       SELECT '+@Fields+',
              MESAZH = CASE WHEN ISNULL(B.ORG,'''')=''T'' THEN ''''
                            WHEN ISNULL(B.ORG,'''')=''''  THEN ''Pa kaluar LM''
                            ELSE '''' END,
              B.ORG,'+@ListLlg2+','+@ListLlg3+',A.NRRENDOR,A.NRDFK,TROW=CAST(0 AS BIT)
         FROM '+@TableD+' A LEFT JOIN #LiberTmpP B On A.NRDFK=B.NRRENDOR_FK
        WHERE 2=2 AND 3=3
     ORDER BY 2,3,4;

           if Object_Id(''TempDB..#LiberTmpP'') is not null
              DROP TABLE #LiberTmpP; ';

        if @PWhereFk<>''
           Set @Sql = Replace(@Sql,'1=1',@PWhereFk);
        if @PWhereDok<>''
           Set @Sql = Replace(@Sql,'2=2',@PWhereDok);
        if @Where3<>''
           Set @Sql = Replace(@Sql,'3=3',@Where3);

        Print @Sql
        Exec (@Sql)

       if Object_Id('TempDB..#LiberTmp')  is not null
          DROP TABLE #LiberTmp;





GO
