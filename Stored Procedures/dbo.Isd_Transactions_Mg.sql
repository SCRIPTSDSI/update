SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   Procedure [dbo].[Isd_Transactions_Mg]
( 
  @PTableName Varchar(50),  
  @PKod1      Varchar(30),
  @PKod2      Varchar(30),
  @PKMon1     Varchar(30),
  @PKMon2     Varchar(30),
  @PKMag1     Varchar(30),  
  @PKMag2     Varchar(30),
  @PDate1     Varchar(30),
  @PDate2     Varchar(30)
 )
As


-- Declare @PTableName   Varchar(30),
--         @PKod1        Varchar(30),
--         @PKod2        Varchar(30),
--         @PKMon1       Varchar(30),
--         @PKMon2       Varchar(30),
--         @PKMag1       Varchar(30),  
--         @PKMag2       Varchar(30),
--         @PDate1       Varchar(20),
--         @PDate2       Varchar(20)
--     Set @PTableName = ''
--     Set @PKod1      = 'P1'
--     Set @PKod2      = 'P1z'
--     Set @PKMon1     = ''
--     Set @PKMon2     = ''  -- Vetem Mb
--     Set @PKMag1     = 'PG1'
--     Set @PKMag2     = 'PG1z'
--     Set @PDate1     = '01/01/2013'
--     Set @PDate2     = '30/06/2013'
--Exec [dbo].[Isd_Transactions_MG]   @PTableName = @PTableName,
--                                   @PKod1      = @PKod1,
--                                   @PKod2      = @PKod2,
--                                   @PKMon1     = @PKMon1,
--                                   @PKMon2     = @PKMon2, 
--                                   @PKMag1     = @PKMag1,
--                                   @PKMag2     = @PKMag2,
--                                   @PDate1     = @PDate1, 
--                                   @PDate2     = @PDate2
     

-- Transaksionet ne vlefte progresive

      if Object_Id('Tempdb..#Cte') is not null
         Drop Table #Cte


  Select KOD      = Replicate(' ',60),
         KMON     = Replicate(' ',20),
         KMAG     = Replicate(' ',20),
         VL       = 0,
         VLMV     = 0,
         RN       = 0,
         NRRENDOR = 0 
    Into #Cte 
   Where 1=2



 Declare @Sql      Varchar(Max),
         @Where1      Varchar(Max),
         @Where2      Varchar(Max),
         @Lidhez      Varchar(10)
--         @Kod1        Varchar(30),
--         @Kod2        Varchar(30),
--         @KMon1       Varchar(30),
--         @KMon2       Varchar(30),
--         @KMag1       Varchar(30),  
--         @KMag2       Varchar(30),
--         @Date1       Varchar(20),
--         @Date2       Varchar(20)

--  Select @Kod1      = QuoteName(@PKod1, ''''),
--         @Kod2      = QuoteName(@PKod2, ''''),
--         @KMon1     = QuoteName(@PKMon1,''''),
--         @KMon2     = QuoteName(@PKMon2,''''),
--         @KMag1     = QuoteName(@PKMag1,''''),  
--         @KMag2     = QuoteName(@PKMag2,''''),
--         @Date1     = QuoteName(@PDate1,''''),
--         @Date2     = QuoteName(@PDate2,'''')

     Set @Where1 = ''
     Set @Where2 = ''
     Set @Lidhez = ''

     if  @PKod1<>'' Or @PKod2<>''
         begin
           if  @PKod1<>'' 
               begin
                 Set @Where1 = @Where1 + @Lidhez + 'KARTLLG>='+QuoteName(@PKod1, '''')
                 Set @Lidhez = ' And '
               end;
           if  @PKod2<>'' 
               Set   @Where1 = @Where1 + @Lidhez + 'KARTLLG<='+QuoteName(@PKod2, '''')
           Set @Lidhez = ' And '
         end;

     if  @PKMon1<>'' Or @PKMon2<>''
         begin
           if  @PKMon1<>''
               begin
                 Set @Where1 = @Where1 + @Lidhez + 'KMON>='+QuoteName(@PKMon1,'''')
                 Set @Lidhez = ' And '
               end;
           if  @PKMon2<>''
               Set    @Where1 = @Where1 + @Lidhez + 'KMON<='+QuoteName(@PKMon2,'''')
           Set @Lidhez = ' And '
         end;


     if  @PKMag1<>'' Or @PKMag2<>''
         begin
           if  @PKMag1<>''
               begin
                 Set @Where1 = @Where1 + @Lidhez + 'KMAG>='+QuoteName(@PKMag1,'''')
                 Set @Lidhez = ' And '
               end;
           if  @PKMag2<>''
               Set   @Where1 = @Where1 + @Lidhez + 'KMAG<='+QuoteName(@PKMag2,'''')
           Set @Lidhez = ' And '
         end;

     Set @Where2 = @Where1

     if  @PDate1<>'' Or @PDate2<>''
         begin
           if  @PDate1<>'' 
               begin
                 Set @Where1 = @Where1 + @Lidhez + 'DATEDOK>=dbo.DATEVALUE('+QuoteName(@PDate1,'''')+')'
                 Set @Where2 = @Where2 + @Lidhez + 'DATEDOK< dbo.DATEVALUE('+QuoteName(@PDate1,'''')+')'
                 Set @Lidhez = ' And '
               end;
           if  @PDate2<>'' 
               Set   @Where1 = @Where1 + @Lidhez + 'DATEDOK<=dbo.DATEVALUE('+QuoteName(@PDate2,'''')+')'
           Set @Lidhez = ' And '
         end;

     Set @Sql    = '

  Insert Into #Cte
        (KOD,KMAG,VL,VLMV,RN,NRRENDOR)
  Select KARTLLG,KMAG,
         VL   = Sum(SASIH  - SASID),
         VLMV = Sum(VLERAH - VLERAD),
         Rn   = 0,
         0
    From LEVIZJEHD
   Where 2=2
Group By KMAG,KARTLLG
Order By KMAG,KARTLLG

  Insert Into #Cte
        (KOD,KMAG,VL,VLMV,RN,NRRENDOR)
  Select KARTLLG,KMAG,
         VL       = SASIH  - SASID,
         VLMV     = VLERAH - VLERAD,
         Rn       = Row_Number() Over(Partition By KMAG,KARTLLG Order By DATEDOK,NRRENDOR),
         NRRENDOR = Cast(NRRENDOR As BigInt)
    From LEVIZJEHD
   Where 1=1
Order By KMAG,KARTLLG,Rn


;With Cte As
(
  Select A.*,
         Rn = Row_Number() Over(Partition By KMAG,KOD Order By DATEDOK,NRRENDOR)
    From LEVIZJEHD A 
   Where 1=1
)

  Select A.*,
         Rn      = Row_Number() Over(Partition By KMAG,KARTLLG Order By DATEDOK,NRRENDOR),
         VlPrg   = (Select Sum(B.VL) 
                      From #Cte B 
                     Where A.KMAG=B.KMAG And A.KARTLLG=B.KOD And B.Rn<=A.Rn),
         VlPrgMv = (Select Sum(B.VLMV) 
                      From #Cte B 
                     Where A.KMag=B.KMag And A.KARTLLG=B.KOD And B.Rn<=A.Rn)
    From Cte A
   Where 1=1
Order By A.KMag,A.KARTLLG,A.DateDok,A.NrRendor 
'

  if @Where1<>''
     Set @Sql = Replace(@Sql,'1=1',@Where1);
  if @Where2<>''
     Set @Sql = Replace(@Sql,'2=2',@Where2);

  Print @Sql;
  Exec (@Sql)



GO
