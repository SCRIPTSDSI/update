SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   Procedure [dbo].[Isd_Transactions_ABSF]
( 
  @PTableName Varchar(50),
  @PKod1      Varchar(30),
  @PKod2      Varchar(30),
  @PKMon1     Varchar(30),
  @PKMon2     Varchar(30),
  @PKMag1     Varchar(30),  
  @PKMag2     Varchar(30),
  @PDate1     Varchar(30),
  @PDate2     Varchar(30)--,
 )
as

-- Declare @PTableName   Varchar(30),
--         @PKod1        Varchar(30),
--         @PKod2        Varchar(30),
--         @PKMon1       Varchar(30),
--         @PKMon2       Varchar(30),
--         @PKMag1       Varchar(30),  
--         @PKMag2       Varchar(30),
--         @PDate1       Varchar(20),
--         @PDate2       Varchar(20)
--     Set @PTableName = 'DAR'
--     Set @PKod1      = 'A01'
--     Set @PKod2      = 'A01z'
--     Set @PKMon1     = ''
--     Set @PKMon2     = ' A'  -- Vetem Mb
--     Set @PKMag1     = ''
--     Set @PKMag2     = ''
--     Set @PDate1     = '01/01/2013'
--     Set @PDate2     = '30/06/2013'
--Exec [dbo].[Isd_Transactions_ABSF] @PTableName = @PTableName,
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
         VL       = Cast(0 As Float),
         VLMV     = Cast(0 As Float),
         RN       = 0,
         NRRENDOR = 0 
    Into #Cte 
   Where 1=2

 Declare @Sql         Varchar(Max),
         @Where1      Varchar(Max),
         @Where2      Varchar(Max),
         @Lidhez      Varchar(10),
         @Fields      Varchar(Max)
       --@Kod1        Varchar(30),
       --@Kod2        Varchar(30),
       --@KMon1       Varchar(30),
       --@KMon2       Varchar(30),
       --@KMag1       Varchar(30),  
       --@KMag2       Varchar(30),
       --@Date1       Varchar(20),
       --@Date2       Varchar(20)

     Set @Where1 = ''
     Set @Where2 = ''
     Set @Lidhez = ''

     if  @PKod1<>'' Or @PKod2<>''
         begin
           if  @PKod1<>'' 
               begin
               --Set @Kod1   = QuoteName(@PKod1, '''')
                 Set @Where1 = @Where1 + @Lidhez + 'CASE WHEN CHARINDEX(''.'',KOD)>0 THEN LEFT(KOD,CHARINDEX(''.'',KOD)-1) ELSE KOD END>='+QuoteName(@PKod1, '''')
                 Set @Lidhez = ' And '
               end;
           if  @PKod2<>'' 
               begin
               --Set @Kod2   = QuoteName(@PKod2, '''')
                 Set @Where1 = @Where1 + @Lidhez + 'CASE WHEN CHARINDEX(''.'',KOD)>0 THEN LEFT(KOD,CHARINDEX(''.'',KOD)-1) ELSE KOD END<='+QuoteName(@PKod2, '''')
               end;
           Set @Lidhez = ' And '
         end;

     if  @PKMon1<>'' Or @PKMon2<>''
         begin
           if  @PKMon1<>''
               begin
               --Set @KMon1  = QuoteName(@PKMon1,'''')
                 Set @Where1 = @Where1 + @Lidhez + 'KMON>='+QuoteName(@PKMon1,'''')
                 Set @Lidhez = ' And '
               end;
           if  @PKMon2<>''
               begin
               --Set  @KMon2  = QuoteName(@PKMon2,'''')
                 Set  @Where1 = @Where1 + @Lidhez + 'KMON<='+QuoteName(@PKMon2,'''')
               end;
           Set @Lidhez = ' And '
         end;

     if  @PKMag1<>'' Or @PKMag2<>''
         begin
           if  @PKMag1<>''
               begin
               --Set @KMag1     = QuoteName(@PKMag1,'''')
                 Set @Where1 = @Where1 + @Lidhez + 'KMAG>='+QuoteName(@PKMag1,'''')
                 Set @Lidhez = ' And '
               end;
           if  @PKMag2<>''
               begin
               --Set @KMag2  = QuoteName(@PKMag2,'''')
                 Set @Where1 = @Where1 + @Lidhez + 'KMAG<='+QuoteName(@PKMag2,'''')
               end;
           Set @Lidhez = ' And '
         end;

     Set @Where2 = @Where1

     if  @PDate1<>'' Or @PDate2<>''
         begin
           if  @PDate1<>'' 
               begin
               --Set @Date1  = QuoteName(@PDate1,'''')
                 Set @Where1 = @Where1 + @Lidhez + 'DATEDOK>=dbo.DATEVALUE('+QuoteName(@PDate1,'''')+')'
                 Set @Where2 = @Where2 + @Lidhez + 'DATEDOK< dbo.DATEVALUE('+QuoteName(@PDate1,'''')+')'
                 Set @Lidhez = ' And '
               end;
           if  @PDate2<>'' 
               begin
               --Set @Date2  = QuoteName(@PDate2,'''')
                 Set @Where1 = @Where1 + @Lidhez + 'DATEDOK<=dbo.DATEVALUE('+QuoteName(@PDate2,'''')+')'
               end;
           Set @Lidhez = ' And '
         end;


     Set @Fields = '
         KOD,PERSHKRIM,KOMENT,TIPDOK,DATEDOK,
         NRDOK      = CASE WHEN ISNULL(FRAKSDOK,0)=0 
                           THEN CAST(NRDOK AS VARCHAR)
                           ELSE CAST(NRDOK AS VARCHAR)+''.''+CAST(FRAKSDOK AS VARCHAR) END,
         KURS       = CASE WHEN KURS2=KURS1 
                           THEN ''''
                           ELSE CAST(KURS1 AS VARCHAR)+'' - ''+CAST(KURS2 AS VARCHAR) END,
         KMON,
         DETYRIM    = CASE WHEN (TableName=''DKL'' AND TREGDK=''D'') OR 
                                (TableName=''DFU'' AND TREGDK=''K'')
                           THEN VLEFTA 
                           ELSE 0 END,
         LIKUJDIM   = CASE WHEN (TableName=''DKL'' AND TREGDK=''K'') OR 
                                (TableName=''DFU'' AND TREGDK=''D'') 
                           THEN VLEFTA 
                           ELSE 0 END,
         ARKETIM    = CASE WHEN TREGDK=''D'' THEN VLEFTA   ELSE 0 END,
         PAGESE     = CASE WHEN TREGDK=''K'' THEN VLEFTA   ELSE 0 END,
         VLEFTEMV   = CASE WHEN TREGDK=''D'' THEN VLEFTAMV ELSE 0-VLEFTAMV END,
         TIPFAT,NRFAT,DTFAT,TREGDK,
         NRRENDOR,
         TAGNR      = 0 '
  Set @Fields = Replace(@Fields,'TableName',QuoteName(@PTableName,''''))


     Set @Sql = '

  Insert Into #Cte
        (KOD,KMON,VL,VLMV,RN,NRRENDOR)
  Select KOD,KMON,
         VL   = Sum(Case When TREGDK=''D'' Then VLEFTA   Else 0-VLEFTA   End),
         VLMV = Sum(Case When TREGDK=''D'' Then VLEFTAMV Else 0-VLEFTAMV End),
         Rn   = 0,
         0
    From '+@PTableName+'
   Where 2=2
Group By KMon,Kod
Order By Kod

  Insert Into #Cte
        (KOD,KMON,VL,VLMV,RN,NRRENDOR)
  Select KOD,KMON,
         VL   = Case When TREGDK=''D'' Then VLEFTA   Else 0-VLEFTA   End,
         VLMV = Case When TREGDK=''D'' Then VLEFTAMV Else 0-VLEFTAMV End,
         Rn   = Row_Number() Over(Partition By KMON,KOD Order By DATEDOK,NRRENDOR),
         NRRENDOR=Cast(NRRENDOR As BigInt)
    From '+@PTableName+'
   Where 1=1
Order By Kod,Rn


;With Cte As
(
  Select A.*,
         Rn = Row_Number() Over(Partition By KMON,KOD Order By DATEDOK,NRRENDOR)
    From '+@PTableName+' A 
   Where 1=1
)

  Select '+@Fields+',
         Rn = Row_Number() Over(Partition By KMON,KOD Order By DATEDOK,NRRENDOR),
         SHUMAPRG   = Cast((Select Sum(B.VL) 
                              From #Cte B 
                             Where A.Kod=B.Kod And B.Rn<=A.Rn) As Float),
         SHUMAPRGMV = Cast((Select Sum(B.VLMV) 
                              From #Cte B 
                             Where A.Kod=B.Kod And B.Rn<=A.Rn) As Float),
         DATEKALUAR = CASE WHEN DATEDIFF(DD,GETDATE(),DATEDOK)>0 
                           THEN ''+'' 
                           ELSE '''' END,
         TROW       = CASE WHEN DATEDIFF(DD,GETDATE(),DATEDOK)>0 
                           THEN CAST(1 AS BIT) 
                           ELSE CAST(0 AS BIT) END
    From Cte A
   Where 1=1
Order By A.KMon,A.Kod,A.DateDok,A.NrRendor '


  if @Where1<>''
     Set @Sql = Replace(@Sql,'1=1',@Where1)
  if @Where2<>''
     Set @Sql = Replace(@Sql,'2=2',@Where2)

  Print @Sql
  Exec (@Sql)



GO
