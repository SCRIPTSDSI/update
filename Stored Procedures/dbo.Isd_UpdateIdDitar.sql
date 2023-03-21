SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE   procedure [dbo].[Isd_UpdateIdDitar]

As



    Declare @Sql  Varchar(Max),
            @Sql1 Varchar(Max),
            @Sql2 Varchar(Max);


         Set NoCount On

            
-- 1.	Koka Arke,Banke

         Set @Sql1 = '

      Update C
         Set C.NRRENDORDOK = A.NRRENDOR,
             C.ORG         = ''_'',
             C.TIPKLL      = ''''
        From Arka  A Inner Join DAR C On A.NRDITAR=C.NRRENDOR
       Where IsNull(C.NRRENDORDOK,0)=0 Or IsNull(C.ORG,'''')=''''; 
';


--		Scr Arka,Banka,VS

         Set @Sql2 = '

      Update C
         Set C.NRRENDORDOK = A.NRRENDOR,
             C.ORG         = ''_'',
             C.TIPKLL      = B.TIPKLL
        From Arka  A Inner Join ArkaScr  B On A.NRRENDOR=B.NRD And B.TIPKLL=''A'' 
                     Inner Join DAR      C On B.NRDITAR=C.NRRENDOR
       Where IsNull(C.NRRENDORDOK,0)=0 Or IsNull(C.ORG,'''')='''';
 
      Update C
         Set C.NRRENDORDOK = A.NRRENDOR,
             C.ORG         = ''_'',
             C.TIPKLL      = B.TIPKLL
        From Arka  A Inner Join ArkaScr  B On A.NRRENDOR=B.NRD And B.TIPKLL=''B'' 
                     Inner Join DBA      C On B.NRDITAR=C.NRRENDOR
       Where IsNull(C.NRRENDORDOK,0)=0 Or IsNull(C.ORG,'''')=''''; 

      Update C
         Set C.NRRENDORDOK = A.NRRENDOR,
             C.ORG         = ''_'',
             C.TIPKLL      = B.TIPKLL
        From Arka  A Inner Join ArkaScr  B On A.NRRENDOR=B.NRD And B.TIPKLL=''S'' 
                     Inner Join DKL      C On B.NRDITAR=C.NRRENDOR
       Where IsNull(C.NRRENDORDOK,0)=0 Or IsNull(C.ORG,'''')=''''; 

      Update C
         Set C.NRRENDORDOK = A.NRRENDOR,
             C.ORG         = ''_'',
             C.TIPKLL      = B.TIPKLL
        From Arka  A Inner Join ArkaScr  B On A.NRRENDOR=B.NRD And B.TIPKLL=''F'' 
                     Inner Join DFU      C On B.NRDITAR=C.NRRENDOR
       Where IsNull(C.NRRENDORDOK,0)=0 Or IsNull(C.ORG,'''')=''''; 
';


--		Arka
         Set  @Sql  = @Sql1 + @Sql2; 
         Set  @Sql  = Replace(@Sql, '_','A');               --Print @Sql;
        Exec (@Sql);


--		Banka
         Set  @Sql  = Replace(@Sql1,'DAR'  ,'DBA')   + @Sql2;

         Set  @Sql  = Replace(@Sql, '_','B');
         Set  @Sql  = Replace(@Sql, 'Arka '   ,'Banka');    
         Set  @Sql  = Replace(@Sql, 'ArkaScr ','BankaScr'); --Print @Sql
        Exec (@Sql);


--		Vs
         Set  @Sql  = Replace(@Sql2,'_','E');
         Set  @Sql  = Replace(@Sql, 'Arka '   ,'VS   ');    
         Set  @Sql  = Replace(@Sql, 'ArkaScr ','VSScr   '); --Print @Sql;
        Exec (@Sql);



-- 2	Faturat

         Set @Sql1 = '

      Update C
         Set C.NRRENDORDOK = A.NRRENDOR,
             C.ORG         = ''_'',
             C.TIPKLL      = ''''
        From FJ  A Inner Join DKL C On A.NRDITAR=C.NRRENDOR
       Where IsNull(A.NRDITAR,0)<>0     And (IsNull(C.NRRENDORDOK,0)=0 Or IsNull(C.ORG,'''')=''''); 

      Update C
         Set C.NRRENDORDOK = A.NRRENDOR,
             C.ORG         = ''_'',
             C.TIPKLL      = ''''
        From FJ  A Inner Join DKL C On A.NRDITARSHL=C.NRRENDOR
       Where IsNull(A.NRDITARSHL,0)<>0  And (IsNull(C.NRRENDORDOK,0)=0 Or IsNull(C.ORG,'''')=''''); 
';

         Set  @Sql2 = '
      Update C
         Set C.NRRENDORDOK = A.NRRENDOR,
             C.ORG         = ''_'',
             C.TIPKLL      = ''''
        From FJ  A Inner Join DKL C On A.NRDITARPRMC=C.NRRENDOR
       Where IsNull(A.NRDITARPRMC,0)<>0 And (IsNull(C.NRRENDORDOK,0)=0 Or IsNull(C.ORG,'''')='''');';

--		FJ

         Set  @Sql = Replace(@Sql1+@Sql2,'_','S');          --Print @Sql;
        Exec (@Sql);

--		FF

         Set  @Sql = Replace(@Sql1,' FJ ' ,' FF '); 
         Set  @Sql = Replace(@Sql, ' DKL ',' DFU '); 
         Set  @Sql = Replace(@Sql, '_','F');                --Print @Sql;
        Exec (@Sql);
GO
