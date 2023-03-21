SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



--
-- Exec Ehw_F5_Palm_Imp
--                      @PDBaseFinName = 'EHW09',
--                      @PServer       = 'F5Palm',
--                      @PPathAdress   = 'E:\MobSell\F5PalmIbd.mdb',
--                      @PDBaseImpName = 'EHWIMPPALM',

CREATE        procedure [dbo].[Ehw_F5_Palm_Imp]
  (
  @PDBaseFinName    As Varchar(20),
  @PServer          As Varchar(100),
  @PPathAdress      As Varchar(150),
  @PDBaseImpName    As Varchar(20)
  )
as

Declare @VDbFin        Varchar(30)
Declare @VDbImp        Varchar(30)
Set @VDbFin          = @PDBaseFinName+'..' --'EHW09..'
Set @VDbImp          = @PDBaseImpName+'..' --'EHWIMPPALM..'

--									L I N K   S E R V E R   M E   F I L E   A C C E S S
Declare @VServer       Varchar(50)
Declare @QServer       Varchar(50)
Declare @VPathAdress   Varchar(150)
Set @QServer         = @PServer
Set @VServer         = QuoteName(@QServer,'''')
Set @VPathAdress     = QuoteName(@PPathAdress,'''')

Exec('SP_DROPSERVER '+@VServer+',"Droplogins"')
Exec('SP_ADDLINKEDSERVER '+@VServer+',"Access 2000","Microsoft.Jet.OLEDB.4.0",'+@VPathAdress)
Exec('SP_ADDLINKEDSRVLOGIN '+@VServer+',False,"sa","Admin",null')
Set @VServer  = Case When @QServer<>'' Then @QServer+'...' Else @QServer End
--									F U N D  L I N K   S E R V E R



--									P E R G A T I T J E   T E   S T R U K T U R A V E
Declare @VTbName       Varchar(30)
Declare @VTbNameO      Varchar(30)
Declare @VTbNameD      Varchar(30)
Declare @TableRef      Varchar(30)

Set @VTbName         = 'ARKA'
Set @VTbNameO        = @VDbFin+@VTbName
Set @VTbNameD        = @VDbImp+@VTbName

Exec('DROP TABLE '   + @VTbNameD+'SCR')
Exec('DROP TABLE '   + @VTbNameD)
Exec('SELECT * INTO '+ @VTbNameD+'    FROM '+@VTbNameO+'    WHERE 0=1')
Exec('SELECT * INTO '+ @VTbNameD+'SCR FROM '+@VTbNameO+'SCR WHERE 0=1')
Exec('ALTER TABLE '  + @VTbNameD+'SCR ADD KODAB   VarChar (20)')
Exec('ALTER TABLE '  + @VTbNameD+'SCR ADD DATEDOK DateTime ')

--
Set @VTbName         = 'FJ'
Set @VTbNameO        = @VDbFin+@VTbName
Set @VTbNameD        = @VDbImp+@VTbName
Exec('DROP TABLE '   + @VTbNameD+'SCR')
Exec('DROP TABLE '   + @VTbNameD)
Exec('SELECT * INTO '+ @VTbNameD+'    FROM '+@VTbNameO+'    WHERE 0=1')
Exec('SELECT * INTO '+ @VTbNameD+'SCR FROM '+@VTbNameO+'SCR WHERE 0=1')
Exec('ALTER TABLE '  + @VTbNameD+'SCR ADD KMAG    Varchar (10) ')
Exec('ALTER TABLE '  + @VTbNameD+'SCR ADD NRDOK   BigInt ')
Exec('ALTER TABLE '  + @VTbNameD+'SCR ADD DATEDOK DateTime ')
--
Set @VTbName         = 'FH'
Set @VTbNameO        = @VDbFin+@VTbName
Set @VTbNameD        = @VDbImp+@VTbName
Exec('DROP TABLE '   + @VTbNameD+'SCR')
Exec('DROP TABLE '   + @VTbNameD)
Exec('SELECT * INTO '+ @VTbNameD+'    FROM '+@VTbNameO+'    WHERE 0=1')
Exec('SELECT * INTO '+ @VTbNameD+'SCR FROM '+@VTbNameO+'SCR WHERE 0=1')
Exec('ALTER TABLE '  + @VTbNameD+'SCR ADD KMAG    Varchar (10) ')
Exec('ALTER TABLE '  + @VTbNameD+'SCR ADD NRDOK   BigInt ')
Exec('ALTER TABLE '  + @VTbNameD+'SCR ADD DATEDOK DateTime ')
--
Set @VTbName         = 'FD'
Set @VTbNameO        = @VDbFin+@VTbName
Set @VTbNameD        = @VDbImp+@VTbName
Exec('DROP TABLE '   + @VTbNameD+'SCR')
Exec('DROP TABLE '   + @VTbNameD)
Exec('SELECT * INTO '+ @VTbNameD+'    FROM '+@VTbNameO+'    WHERE 0=1')
Exec('SELECT * INTO '+ @VTbNameD+'SCR FROM '+@VTbNameO+'SCR WHERE 0=1')
Exec('ALTER TABLE '  + @VTbNameD+'SCR ADD KMAG    Varchar (10) ')
Exec('ALTER TABLE '  + @VTbNameD+'SCR ADD NRDOK   BigInt ')
Exec('ALTER TABLE '  + @VTbNameD+'SCR ADD DATEDOK DateTime ')
--


--							F U N D I  I  P E R G A T I T J E   T E   S T R U K T U R A V E


--							I M P O R T   N G A   F I L E  A C C E S S   N E   S T R U K T U R E   S Q L - S E R V E R

--									A   R   K   A

Set @VTbName         = 'ARKA'
Set @TableRef        = @VDbFin+'ARKAT'
Set @VTbNameO        = @VDbFin+@VTbName
Set @VTbNameD        = @VDbImp+@VTbName
Exec('UPDATE '+@VServer+'KLIENTPAGESA SET DATEDOK = CAST(CONVERT(VARCHAR(10),DATEDOK,101) AS DATETIME)')
Exec('INSERT INTO '+@VTbNameD+' (KODAB,DATEDOK,VLERA,VLERAMV,KMON,KURS1,KURS2,SHENIM1,TIPDOK,NUMDOK,NRDFK,FRAKSDOK,NRDITAR,USI,USM,FIRSTDOK,TAGNR,NRSERI)
      SELECT KMAG,DATEDOK,SUM(VLERA),SUM(VLERA),'''',1,1,''Arketuar nga Kliente'',''MA'',0,0,0,0,'''','''','''','''',0
        FROM '+@VServer+'KLIENTPAGESA 
     WHERE ABS(ISNULL(VLERA,0))>=0.01 AND (ISNULL(STATUS,0)=0)
    GROUP BY KMAG,DATEDOK 
    ORDER BY KMAG,DATEDOK ')
Exec('UPDATE '+@VTbNameD+' SET DATEDOK = CAST(CONVERT(VARCHAR(10),DATEDOK,101) AS DATETIME)')
     

Exec('INSERT INTO '+@VTbNameD+'Scr 
            (NRD,KODAB,DATEDOK,KODAF,KOD,LLOGARI,LLOGARIPK,
             TIPREF,NRDOKREF,DB,KR,DBKRMV,KMON,KURS1,KURS2,KOMENT,TIPKLL,RRAB,TREGDK)
      SELECT 0,KMAG,DATEDOK,'''',''''+''....'','''','''',
             '''','''',SUM(VLERA),0,SUM(VLERA),'''',1,1,''Arketuar nga Kliente'',''T'',''K'',''D''
        FROM '+@VServer+'KLIENTPAGESA 
       WHERE ABS(ISNULL(VLERA,0))>=0.01 AND (ISNULL(STATUS,0)=0)
    GROUP BY KMAG,DATEDOK ')
Exec('INSERT INTO '+@VTbNameD+'Scr 
            (NRD,KODAB,DATEDOK,KODAF,KOD,LLOGARI,LLOGARIPK,
             TIPREF,NRDOKREF,DATEDOKREF,
             DB,KR,DBKRMV,KMON,KURS1,KURS2,KOMENT,TIPKLL,RRAB,TREGDK)
      SELECT 0,KMAG,DATEDOK,KOD AS KODA,KOD+''.'' AS KODB,KOD AS KODC,KOD AS KODD,
             ''FJ'',ISNULL(NRDSHOQ,''''),DATEDOK,
             0,VLERA,0-VLERA,'''',1,1,'''',''S'','''',''K''
        FROM '+@VServer+'KLIENTPAGESA 
       WHERE ABS(ISNULL(VLERA,0))>=0.01 AND (ISNULL(STATUS,0)=0)
    ORDER BY KOD ')
--             ISNULL(NRDSHOQ,''''),DATEDOK,

Exec('UPDATE '+@VTbNameD+'Scr  SET DATEDOK = CAST(CONVERT(VARCHAR(10),DATEDOK,101) AS DATETIME) ')

Exec('UPDATE A SET A.NRD=B.NRRENDOR
        FROM '+@VTbNameD+'Scr A INNER JOIN '+@VTbNameD+' B ON A.KODAB=B.KODAB AND A.DATEDOK=B.DATEDOK ')
Exec('ALTER TABLE '+@VTbNameD+'SCR DROP COLUMN KODAB   ')
Exec('ALTER TABLE '+@VTbNameD+'SCR DROP COLUMN DATEDOK ')

--									Plotesime para importit
--									Rinumurimi brenda Arkes
Exec('UPDATE A SET NUMDOK = ISNULL((SELECT SUM(1) 
                                      FROM '+@VTbNameD+' C 
                                     WHERE (A.KODAB=C.KODAB) AND (C.DATEDOK<A.DATEDOK OR (A.DATEDOK=C.DATEDOK AND C.NRRENDOR<A.NRRENDOR))),0)+
                            ISNULL((SELECT MAX(NUMDOK) FROM '+@VTbNameO+' B WHERE A.KODAB=B.KODAB AND B.TIPDOK=''MA''),0)+1
      FROM '+@VTbNameD+' A ')
Exec('UPDATE A SET A.NRRENDORAB=B.NRRENDOR, A.LLOGARI=B.LLOGARI,A.FIRSTDOK=''A''+CAST(CAST(A.NRRENDOR AS BIGINT) AS VARCHAR) 
        FROM '+@VTbNameD+'    A INNER JOIN '+@TableRef+' B ON A.KODAB=B.KOD ')


--									Elemente te ArkaSCR 
Exec('UPDATE A 
         SET A.LLOGARI   =B.LLOGARI,
             A.KODAF     =B.LLOGARI,
             A.KOD       =B.LLOGARI+''....'',
             A.LLOGARIPK =B.LLOGARI
        FROM '+@VTbNameD+'SCR A INNER JOIN '+@VTbNameD+' B ON A.NRD=B.NRRENDOR WHERE A.RRAB=''K''')
Exec('UPDATE A SET A.PERSHKRIM=B.PERSHKRIM
        FROM '+@VTbNameD+'Scr A INNER JOIN '+@VDbFin+'LLOGARI B ON A.KODAF=B.KOD WHERE A.TIPKLL=''T''')
Exec('UPDATE A SET A.PERSHKRIM=B.PERSHKRIM
        FROM '+@VTbNameD+'Scr A INNER JOIN '+@VDbFin+'KLIENT  B ON A.KODAF=B.KOD WHERE A.TIPKLL=''S''')
--Exec('UPDATE A SET A.NRDOKREF='''',A.TIPREF=''''
--        FROM '+@VTbNameD+'Scr A')

--									F U N D I	A R K A



--									F A T U R A   S H I T J E
Set @VTbName         = 'FJ'
Set @TableRef        = @VDbFin+'KLIENT'
Set @VTbNameO        = @VDbFin+@VTbName
Set @VTbNameD        = @VDbImp+@VTbName

Exec('UPDATE '+@VServer+'FJIMPF5 SET DATEDOK = CAST(CONVERT(VARCHAR(10),DATEDOK,101) AS DATETIME)')

--Print '2'
Exec('INSERT INTO '+@VTbNameD+ '
            (KODFKL,KOD,DATEDOK,NRDOK,NRFRAKS,KMAG,KMON,KURS1,KURS2,
             NIPT,NRSERIAL,RRETHI,SHENIM1,SHENIM2,SHENIM3,LLOJDOK,USI,USM,TAGNR,STATUS)
      SELECT MAX(ISNULL(KODKL,'''')),MAX(ISNULL(KODKL,''''))+''.'',DATEDOK,NRDOK,0,KMAG,'''',1,1,
             MAX(ISNULL(NIPT,'''')),CAST(CAST(NRDOK AS BIGINT) AS VARCHAR),
             MAX(ISNULL(RRETHI,'''')),MAX(ISNULL(SHENIM1,'''')),MAX(ISNULL(SHENIM2,'''')),MAX(ISNULL(SHENIM3,'''')),
             MAX(CASE WHEN ISNULL(IDKTHIMI,'''')=''KM'' 
                      THEN ''K'' 
                      WHEN ISNULL(IDKTHIMI,'''')=''DM'' 
                      THEN ''D'' 
                      ELSE ''A'' END),
             '''','''',0,0
        FROM '+@VServer+'FJIMPF5
       WHERE (ISNULL(STATUS,0)=0)
    GROUP BY KMAG,DATEDOK,NRDOK 
    ORDER BY KMAG,DATEDOK,NRDOK ')
Exec('UPDATE '+@VTbNameD+' SET DATEDOK = CAST(CONVERT(VARCHAR(10),DATEDOK,101) AS DATETIME) ')

Exec('INSERT INTO '+@VTbNameD+'Scr 
            (NRD,KMAG,NRDOK,DATEDOK,KARTLLG,KODAF,KOD,LLOGARIPK,SASI,
             CMIMBS,VLPATVSH,VLTVSH,TIPKLL)
      SELECT 0,KMAG,NRDOK,DATEDOK,KOD,KOD,KOD+''....'',KOD,SASI,CMIMPATVSH,ISNULL(VLPATVSH,0),ISNULL(VLTVSH,0),''K''
        FROM '+@VServer+'FJIMPF5 
       WHERE (ISNULL(STATUS,0)=0)')
Exec('UPDATE '+@VTbNameD+'Scr SET DATEDOK = CAST(CONVERT(VARCHAR(10),DATEDOK,101) AS DATETIME) ')

Exec('UPDATE A SET A.NRD=B.NRRENDOR,A.KOD=A.KMAG+''.''+KARTLLG+''...''
        FROM '+@VTbNameD+'Scr A INNER JOIN '+@VTbNameD+' B ON A.KMAG=B.KMAG AND A.DATEDOK=B.DATEDOK AND A.NRDOK=B.NRDOK ')
Exec('ALTER TABLE '+@VTbNameD+'SCR DROP COLUMN KMAG   ')
Exec('ALTER TABLE '+@VTbNameD+'SCR DROP COLUMN DATEDOK ')
Exec('ALTER TABLE '+@VTbNameD+'SCR DROP COLUMN NRDOK ')

--									Plotesime para importit FJ,FJSCR
Exec('UPDATE A SET A.KLASAKF=B.GRUP, A.VENHUAJ=B.VENDHUAJ
        FROM '+@VTbNameD+'    A INNER JOIN '+@TableRef+' B ON A.KODFKL=B.KOD ')
 
Set @TableRef = @VDbFin+'MAGAZINA'
Exec('UPDATE A 
         SET A.KMAG=B.KOD, A.NRMAG=B.NRRENDOR
        FROM '+@VTbNameD+' A INNER JOIN '+@TableRef+' B ON A.KMAG=B.KOD ')

Exec('UPDATE A 
         SET A.VLTVSH      = (SELECT SUM(B.VLTVSH)   FROM '+@VTbNameD+'Scr B WHERE A.NRRENDOR=B.NRD),
             A.VLPATVSH    = (SELECT SUM(B.VLPATVSH) FROM '+@VTbNameD+'Scr B WHERE A.NRRENDOR=B.NRD),
             VLERTOT       = (SELECT SUM(B.VLTVSH+B.VLPATVSH) FROM '+@VTbNameD+'Scr B WHERE A.NRRENDOR=B.NRD),
             NRDSHOQ       = CAST(CAST(NRDOK AS BIGINT) AS VARCHAR),
             DTDSHOQ       = DATEDOK,
             KTH           = 0,
             SHENIM1       = ISNULL(SHENIM1,''''),
             SHENIM2       = ISNULL(SHENIM2,''''),
             SHENIM3       = ISNULL(SHENIM3,''''),
             SHENIM4       = ISNULL(SHENIM4,''''),
             GRUP          = '''',
             KODKART       = '''',
             DTAF          = 0,
             PERQDS        = 0,
             VLTAX         = 0,
             VLERZBR       = 0,
             PARAPG        = 0,
             PERQZBR       = 0,
             PERQTVSH      = 0,
             NRRENDDMG     = 0, 
             NRDMAG        = 0,
             FRDMAG        = 0,
             NRDFK         = 0,
             NRFATST       = '''',
             MODPG         = '''',
             KODFISKAL     = '''',
             TIPDMG        = ''D'',
             DTDMAG        = DATEDOK,
             ISDOKSHOQ     = 0,
             POSTIM        = 0,
             LETER         = 0,
             FIRSTDOK      = '''',
             ISDG          = 0,
             NRDOKDG       = 0,
             NRDITAR       = 0,
             NRDITARSHL    = 0,
             NRDITARPRMC   = 0,
             NRRENDKF      = 0,
             NRFRAKSKF     = 0,
             NRRENDORAQ    = 0,
             NRDFTEXTRA    = 0,
             NRRENDOROR    = 0,
             NRRENDOROF    = 0,
             NRRENDORORGFJ = 0,
             LLOJDOK       = ISNULL(LLOJDOK,''''),
             TIPFT         = '''',
             GRUPIMFT      = '''',
             AGJENTSHITJE  = '''',
             KLASIFIKIM    = '''',
             KLASIFIKIM1   = '''',
             VLKASE        = 0,
             ISPERMBLEDHES = 0,
             PRINTKOMENT   = 0,
             ACTIVFJKOMENT = 0,
             TAG           = 0,
             TROW          = 0
        FROM '+@VTbNameD+' A ')

Set @TableRef = @VDbFin+'CONFIGLM'
Exec('UPDATE A 
         SET A.LLOGTVSH=B.LLOGTATS, A.LLOGZBR=B.LLOGZBR, A.LLOGARK=B.LLOGARK
        FROM '+@VTbNameD+' A, '+@TableRef+' B')


--									Elemente te FJSCR 

Set @TableRef = @VDbFin+'ARTIKUJ'
Exec('UPDATE A 
         SET A.PERSHKRIM=B.PERSHKRIM, A.NJESI=B.NJESI,A.CMIMM=B.KOSTMES,CMSHZB0=B.CMSH,A.NRRENDKLLG=B.NRRENDOR
        FROM '+@VTbNameD+'Scr A INNER JOIN '+@TableRef+' B ON A.KARTLLG=B.KOD 
       WHERE A.TIPKLL=''K''')

Exec('UPDATE A 
         SET A.VLERABS=A.VLPATVSH+A.VLTVSH, A.VLERAM=ROUND(A.SASI*A.CMIMM,3),NJESINV=NJESI,
             PERQDSCN=0,
             PERQTVSH=CASE WHEN VLPATVSH<>0 THEN ROUND((VLTVSH/VLPATVSH)*100,0) ELSE 0 END,
             VLTAX=1,KOEFSHB=1,BC='''',NOTMAG=0,SASIFR=0,VLERAFR=0,TIPFR='''',KOMENT='''',
             KONVERTART=0,PROMOC=0,PROMOCTIP='''',NRDITAR=0
        FROM '+@VTbNameD+'Scr A 
       WHERE A.TIPKLL=''K''')

--									Gjenerim Nr per dokumentat Magazine nr renditjes sipas radhes(FD)
  Exec('UPDATE A SET NRDMAG = ISNULL((SELECT SUM(1) 
                                       FROM '+@VTbNameD+' B 
                                      WHERE (A.KMAG=B.KMAG) AND (B.DATEDOK<A.DATEDOK OR (A.DATEDOK=B.DATEDOK AND B.NRRENDOR<A.NRRENDOR))),0)+
                              ISNULL((SELECT MAX(NRDOK) FROM '+@VDbFin+'FD B WHERE A.KMAG=B.KMAG),0)+1
      FROM '+@VTbNameD+' A ')

--									Krijimi i FD nga FJ
Exec('INSERT INTO '+@VDBImp+'FD 
            (TIP,KMAG,NRMAG,DATEDOK,NRDOK,NRFRAKS,NRSERIAL,KMAGRF,KMAGLNK,NRDOKLNK,NRFRAKSLNK,NRDFK,DOK_JB,DST,KODLM,
             SHENIM1,SHENIM2,SHENIM3,SHENIM4,NRRENDORFAT,KALIMLMZGJ,POSTIM,LETER,USI,USM,TAG,TROW,TAGNR,FIRSTDOK)
      SELECT ''D'',KMAG,NRMAG,DATEDOK,NRDMAG,0,NRSERIAL,'''','''',0,0,0,1,''SH'','''',
             SHENIM1,SHENIM2,SHENIM3,SHENIM4,NRRENDOR,0,0,0,'''','''',0,0,0,''D''+CAST(CAST(NRRENDOR AS BIGINT) AS VARCHAR)
        FROM '+@VTbNameD+'
       WHERE (ISNULL(STATUS,0)=0)
    ORDER BY KMAG,DATEDOK,NRDOK ')

Exec('INSERT INTO '+@VDBImp+'FDSCR
            (NRD,KARTLLG,KODAF,KOD,NRRENDKLLG,PERSHKRIM,NJESI,NJESINV,SASI,CMIMBS,CMIMM,VLERAM,VLERABS,CMIMSH,
             VLERASH, VLERAFT, KOEFSHB,TIPKLL,KONVERTART,SASIFR,VLERAFR,VLERAOR,PROMOC,PROMOCTIP,BC,KOMENT,SERI,KMON)
      SELECT NRD,KARTLLG,KODAF,KOD,NRRENDKLLG,PERSHKRIM,NJESI,NJESINV,SASI,CMIMM, CMIMM,VLERAM,VLERAM, CMIMBS,
             VLPATVSH,VLPATVSH,KOEFSHB,TIPKLL,KONVERTART,SASIFR,VLERAFR,VLPATVSH,PROMOC,PROMOCTIP,BC,KOMENT,SERI,''''
        FROM '+@VTbNameD+'SCR
    ORDER BY NRD,KARTLLG ')

Exec('UPDATE A SET A.NRD=B.NRRENDOR
        FROM '+@VDBImp+'FDSCR A INNER JOIN '+@VDBImp+'FD B ON A.NRD=B.NRRENDORFAT ')

Exec('UPDATE A SET A.NRRENDDMG=B.NRRENDOR
        FROM '+@VTbNameD+' A INNER JOIN '+@VDBImp+'FD B ON A.NRRENDOR=B.NRRENDORFAT ')

--									F U N D I	F A T U R A   S H I T J E 

--									D O K U M E N T A   F L E T E  D A L J E 
Set @VTbName         = 'FD'
Set @VTbNameO        = @VDbFin+@VTbName
Set @VTbNameD        = @VDbImp+@VTbName

Exec('UPDATE '+@VTbNameD+'    SET TAGNR=0 ') 
Exec('UPDATE '+@VTbNameD+'Scr SET TAGNR=0 ') 
Exec('UPDATE '+@VServer+'MGIMPF5 SET DATEDOK = CAST(CONVERT(VARCHAR(10),DATEDOK,101) AS DATETIME)')

Exec('INSERT INTO '+@VTbNameD+ '
            (TIP,KMAG,DATEDOK,NRDOK,NRFRAKS,NRSERIAL,DST,SHENIM1,DOK_JB,USI,USM,TAGNR)
      SELECT ''D'',KMAG,DATEDOK,NRDOK,0,      MAX(ISNULL(NRSERIAL,'''')),''KM'',
             MAX(ISNULL(SHENIM1,'''')),0,'''','''',100
        FROM '+@VServer+'MGIMPF5
       WHERE (ABS(ISNULL(SASI,0))>=0.001) AND (NOT ((KMAG=''M07'') OR (KMAG=''M08''))) AND (ISNULL(STATUS,0)=0)
    GROUP BY TIP,KMAG,DATEDOK,NRDOK 
    ORDER BY TIP,KMAG,DATEDOK,NRDOK ')
--     WHERE TIP=''D'' AND (NOT ((KMAG=''M07'') OR (KMAG=''M08''))) AND ABS(ISNULL(SASI,0))>=0.001 
Exec('UPDATE '+@VTbNameD+' SET DATEDOK = CAST(CONVERT(VARCHAR(10),DATEDOK,101) AS DATETIME) ')

Exec('INSERT INTO '+@VTbNameD+'Scr (NRD,KMAG,NRDOK,DATEDOK,KARTLLG,KODAF,KOD,SASI,CMIMBS,CMIMM,VLERAM,TIPKLL,TAGNR)
      SELECT 0,KMAG,NRDOK,DATEDOK,KOD,KOD,KMAG+''.''+KOD+''...'',SASI,0,0,0,''K'',100
        FROM '+@VServer+'MGIMPF5 
       WHERE ABS(ISNULL(SASI,0))>=0.001 AND (NOT ((KMAG=''M07'') OR (KMAG=''M08''))) AND (ISNULL(STATUS,0)=0)')

Exec('UPDATE '+@VTbNameD+'Scr  SET DATEDOK = CAST(CONVERT(VARCHAR(10),DATEDOK,101) AS DATETIME) ')

Exec('UPDATE A SET A.NRD=B.NRRENDOR
        FROM '+@VTbNameD+'Scr A INNER JOIN '+@VTbNameD+' B ON A.KMAG=B.KMAG AND A.DATEDOK=B.DATEDOK AND A.NRDOK=B.NRDOK 
       WHERE A.TAGNR=100 AND B.TAGNR=100 ')
-- Kujdes Duhet edhet DOK_JB=0 sepse per DOK_JB=1 eshte bere me siper...

--									Plotesime para importit FD,FDSCR
Set @TableRef        = @VDbFin+'MAGAZINA'
Exec('UPDATE A 
         SET A.KMAG=B.KOD, A.NRMAG=B.NRRENDOR
        FROM '+@VTbNameD+' A INNER JOIN '+@TableRef+' B ON A.KMAG=B.KOD ')

Exec('UPDATE '+@VTbNameD+' 
         SET SHENIM2     = '''',
             SHENIM3     = '''',
             SHENIM4     = '''',
             KMAGRF      = '''', 
             KMAGLNK     = '''',
             NRDOKLNK    = 0,
             NRFRAKSLNK  = 0,
             DOK_JB      = 0,
             NRRENDORFAT = 0,
             NRDFK       = 0,
             POSTIM      = 0,
             LETER       = 0,
             KODLM       = '''',
             NRSERIAL    = '''',
             KALIMLMZGJ  = 0,
             TROW        = 0,
             TAG         = 0,
             TIPFAT      = '''',
             NRRENDORAQ  = 0,
             FIRSTDOK    = TIP+CAST(CAST(NRRENDOR AS BIGINT) AS VARCHAR)
       WHERE TAGNR=100 ')

--									Elemente te SCR 

Set @TableRef        = @VDbFin+'ARTIKUJ'
Exec('UPDATE A 
         SET A.PERSHKRIM=B.PERSHKRIM, A.NJESI=B.NJESI,A.CMIMM=B.KOSTMES,A.CMIMBS=B.KOSTMES,CMIMSH=B.CMSH,
             A.NRRENDKLLG=B.NRRENDOR
        FROM '+@VTbNameD+'Scr A INNER JOIN '+@TableRef+' B ON A.KARTLLG=B.KOD
       WHERE A.TAGNR=100')

Exec('UPDATE '+@VTbNameD+'Scr 
         SET VLERAM     = ROUND(SASI*CMIMM,3), 
             VLERABS    = ROUND(SASI*CMIMM,3),
             VLERASH    = ROUND(SASI*CMIMM,3),
             VLERAFT    = ROUND(SASI*CMIMM,3),
             CMIMOR     = CMIMM, 
             VLERAOR    = VLERAM,
             NJESINV    = NJESI, 
             KOEFSHB    = 1,
             BC         = '''',
             SASIFR     = 0,
             VLERAFR    = 0,
             TIPFR      = '''',
             KOMENT     = '''',
             KONVERTART = 0, 
             PROMOC     = 0,
             PROMOCTIP  = '''',
             SERI       = '''',
             KMON       = '''',
             GJENROWAUT = 0,
             TROW       = 0
       WHERE TAGNR=100 ')

--									Gjenerim Nr per dokumentat FD Magazine,renditjes sipas radhes
Exec('UPDATE A SET NRDOK = ISNULL((SELECT SUM(1) 
                                     FROM '+@VTbNameD+' B 
                                    WHERE (A.KMAG=B.KMAG) AND (B.DATEDOK<A.DATEDOK OR (A.DATEDOK=B.DATEDOK AND B.NRRENDOR<A.NRRENDOR))),0)+
                            ISNULL((SELECT MAX(NRDOK) FROM '+@VTbNameD+' B WHERE A.KMAG=B.KMAG),0)+1
      FROM '+@VTbNameD+' A ')
Exec('UPDATE '+@VTbNameD+'    SET TAGNR=0 ') 
Exec('UPDATE '+@VTbNameD+'Scr SET TAGNR=0 ') 
--									F U N D I	D O K U M E N T A   F L E T E  D A L J E

Set @VTbName         = 'FH'
Set @VTbNameO        = @VDbFin+@VTbName
Set @VTbNameD        = @VDbImp+@VTbName
Exec('ALTER TABLE '+@VTbNameD+'SCR DROP COLUMN KMAG   ')
Exec('ALTER TABLE '+@VTbNameD+'SCR DROP COLUMN DATEDOK ')
Exec('ALTER TABLE '+@VTbNameD+'SCR DROP COLUMN NRDOK ')

Set @VTbName         = 'FD'
Set @VTbNameO        = @VDbFin+@VTbName
Set @VTbNameD        = @VDbImp+@VTbName
Exec('ALTER TABLE '+@VTbNameD+'SCR DROP COLUMN KMAG   ')
Exec('ALTER TABLE '+@VTbNameD+'SCR DROP COLUMN DATEDOK ')
Exec('ALTER TABLE '+@VTbNameD+'SCR DROP COLUMN NRDOK ')


Exec('UPDATE A SET STATUS=1 FROM '+@VServer+'KLIENTPAGESA WHERE ISNULL(STATUS,0)=0 ')
Exec('UPDATE A SET STATUS=1 FROM '+@VServer+'FJIMPF5      WHERE ISNULL(STATUS,0)=0 ')
Exec('UPDATE A SET STATUS=1 FROM '+@VServer+'MGIMPF5      WHERE ISNULL(STATUS,0)=0 ')


--							F U N D  I M P O R T   N G A   F I L E  A C C E S S   N E   S T R U K T U R E   S Q L - S E R V E R









GO
