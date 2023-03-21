SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 
CREATE proc [dbo].[getProductForSale](
                                                                                                                                @kodart0 as varchar(150),
                                                                                                                                @kmag0 as varchar(50),
                                                                                                                                @kkli0 as varchar(50),
                                                                                                                                @getgjendje0 bit = 0,
                                                                                                                                @kthim0 as bit,
                                                                                                                                @koeficpeshore0 as float,
                                                                                                                                @sasipershitje0 as float = 1
                                                                                                                                --@test as varchar(100)
                                                                                                                  )
as
if @kodart0<>''
begin
                                --inicializim i brendshem i parametrave qe vijne nga lart.
                                declare                 @kodart as varchar(150),
                                                                                @kmag as varchar(50),
                                                                                @kkli as varchar(50),
                                                                                @getgjendje bit = 0,
                                                                                @kthim as bit,
                                                                                @koeficpeshore as float,
                                                                                @sasipershitje as float,
                                                                                @shitmekod as varchar(2) ,
                                                                                @shitpagjendje as bit = 1;
 
                                set                                          @kodart = @kodart0
                                set                                          @kmag = @kmag0
                                set                                          @kkli = @kkli0
                                --set                                      @getgjendje = @getgjendje0
                                set                                          @kthim = @kthim0
                                set                                          @koeficpeshore = @koeficpeshore0
                                set                                          @sasipershitje = @sasipershitje0
                                set @shitmekod = (select top 1 left(shitmekod,2) from POSKONFIGMAG where KMAG = @kmag)
                                set @shitpagjendje = (select top 1 case when  left(shitpagjendje,2) = 'PO' then 1 else 0 end from POSKONFIGMAG where KMAG = @kmag)
                                set @getgjendje = (select top 1 case when  left(getgjendje,2) = 'PO' then 1 else 0 end from POSKONFIGMAG where KMAG = @kmag)
                                print convert(varchar(20),@getgjendje)
                                print convert(varchar(20),@shitpagjendje)
                                print convert(varchar(20),@sasipershitje)
                                -- fund inicializimi
 
                                declare @kod as varchar(50),@cmimshitje as float = 0
 
                                --merr konfigurime te nevojshme per peshore
                                declare @prefixbarkod as varchar(50),@gjatesibarkod as int,@peshoreaktiv as bit,@peshorevlerebc as bit,@tmpkod as varchar(50),@ispeshore as bit,
                                @peshoreklasifcope varchar(50)
                                select top 1 @prefixbarkod = PESHOREKODBC ,@gjatesibarkod = PESHORESIZEBC ,@peshoreaktiv = PESHOREACTIV ,@peshorevlerebc= PESHOREVLEREBC
                                from CONFIGMG
                                select top 1 @peshoreklasifcope = peshoreklasifcope from POSKONFIGMAG where KMAG = @kmag
 
                                --ruaj barkodin e skanuar per perdorim me vone
                                set @tmpkod = @kodart
 
                                --kontrollo nese eshte derguar kod apo barkod
                                set @kod = '';
                                set @kod = (select top 1 KOD from ARTIKUJ where KOD = @kodart and @shitmekod = 'PO')
 
                                --nxirr kodin e artikullit nga kodi i peshores nese i tille
                                if len(@tmpkod) = 13
                                                if  (select count(1) from dbo.split(@prefixbarkod,',') where  left(@tmpkod,2) = Splitet) > 0
                                                                begin
                                                                                set @ispeshore = 1
                                                                                set @kodart = RIGHT(LEFT(@tmpkod,7),5);
                                                                end 
                
 
                                --print @kodart
                                --print @kod
                                --mbush tabele temporane per artikullin e gjetur nese ka
                                select                    nrrendorartikull = a.nrrendor,
                                                                                bcartikull = case when ltrim(rtrim(isnull(@kod,''))) = '' then @kodart else '' end,
                                                                                kodartikull = a.kod,
                                                                                pershkrimartikull = a.pershkrim,
                                                                                sasiartikull =case when @getgjendje = 1 and @shitpagjendje = 0 then 
                                                                                case when @sasipershitje>(select SUM(sasih-sasid) from LEVIZJEHDSM where KARTLLG = a.KOD and kmag=@kmag)
                                                                                then (select SUM(sasih-sasid) from LEVIZJEHDSM where KARTLLG = a.KOD and kmag=@kmag) else @sasipershitje end
                                                                                else @sasipershitje end,
                                                                                njesiartikull = a.njessh,
                                                                                cmtot = a.CMSH,
                                                                                skonto = 0,
                                                                                cmimartikull = convert(float,0),
                                                                                vlmetvsh = 0,
                                                                                totali =0,
                                                                                klasifartikull = a.KLASIF,
                                                                                klasif2artikull = a.KLASIF2,
                                                                                tatim = kt.PERQTVSH,
                                                                                FISKAL = a.FISKAL,
                                                                                seriali='',
                                                                                tatimsade = 0,
                                                                                arsyekthimi = '',
                                                                                dtskad = null,
                                                                                seria = null,
                                                                                cmimpike = 0,
                                                                                pikekonsumuar = 0, 
                                                                                gjendje = case when @getgjendje = 1 then
                                                                                                (select SUM(sasih-sasid) from LEVIZJEHDSM where KARTLLG = a.KOD and kmag=@kmag)
                                                                                                else 0 end,
                                                                                Marketing = Convert(bit,0),
                                                                                checked = Convert(bit,0),
                                                                                MARK = Convert(bit,0)
                                into #tmp
                                from ARTIKUJ a                 
                                inner join KLASATVSH kt on kt.KOD = a.KODTVSH
                                left join ARTIKUJBCSCR abc on abc.NRD = a.NRRENDOR
                                where ((a.KOD =@kodart and @shitmekod = 'PO') or abc.BC = @kodart or a.BC = @kodart)
 
                                --Percakto cmim shitje pasi ke gjetur kodin e sakte te artikullit                   
                                select @cmimshitje =  dbo.getprice(@kodart,@kmag,@kkli,@sasipershitje)
                                from ARTIKUJ a 
                                inner join #tmp b on b.kodartikull = a.KOD
 
                                --Nese eshte konfirmuar me siper se eshte rast peshore, atehere meqe ke gjetur dhe cmimin kalkulo sasine 
                                if @ispeshore = 1
                                begin
                                --marrje konfigurimi nese artikulli i gjetur eshte me klasif te konfiguruar cope atehere modifiko koeficpeshore ne 1
                                declare @copeOsePeshe varchar(50)
                                select @copeOsePeshe = case when @peshoreklasifcope = 'KLASIF' THEN KLASIF
                                                                                                                                                when @peshoreklasifcope = 'KLASIF2' THEN KLASIF2                
                                                                                                                                                when @peshoreklasifcope = 'KLASIF3' THEN KLASIF3
                                                                                                                                                when @peshoreklasifcope = 'KLASIF4' THEN KLASIF4
                                                                                                                                                when @peshoreklasifcope = 'KLASIF5' THEN KLASIF5                
                                                                                                                                                when @peshoreklasifcope = 'KLASIF6' THEN KLASIF6
                                                                                                                ELSE '' END
                                FROM ARTIKUJ A INNER JOIN #tmp T ON T.kodartikull = A.KOD
                                IF @copeOsePeshe = 'C' 
 
                                                SET @koeficpeshore = 1
 
                                                if @peshorevlerebc = 1
                                                                set @sasipershitje = (CONVERT(float,right(left(@tmpkod,12),5))/@koeficpeshore)/@cmimshitje
                                                else
                                                                set @sasipershitje = (CONVERT(float,right(left(@tmpkod,12),5))/@koeficpeshore)
                                end
 
                                --Perditeso vlerat ne tabele temporane sipas gjetjeve, cmim, sasi etj
                                select @sasipershitje =  case when @getgjendje = 1 and @shitpagjendje = 0 then 
                                                                                case when @sasipershitje>(select SUM(sasih-sasid) from LEVIZJEHDSM where KARTLLG = a.KOD and kmag=@kmag)
                                                                                then (select SUM(sasih-sasid) from LEVIZJEHDSM where KARTLLG = a.KOD and kmag=@kmag) else @sasipershitje end
                                                                                else @sasipershitje end
                                from #tmp b
                                inner join ARTIKUJ a on a.KOD = b.kodartikull
                                inner join KLASATVSH kt on kt.KOD = a.KODTVSH
 
                                if @kthim = 1
                                                set @sasipershitje = @sasipershitje*-1
 
                                update b 
                                set b.tatimsade  = (Convert(float,kt.perqtvsh)/100)*@sasipershitje*@cmimshitje,
                                                b.vlmetvsh = @sasipershitje * @cmimshitje,
                                                b.totali = @sasipershitje * @cmimshitje,
                                                b.cmimartikull = @cmimshitje,
                                                b.sasiartikull = @sasipershitje
                                from #tmp b
                                inner join ARTIKUJ a on a.KOD = b.kodartikull
                                inner join KLASATVSH kt on kt.KOD = a.KODTVSH
 
                                select * from #tmp
end
else
select * from artikuj where 1=2

GO
