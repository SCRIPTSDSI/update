SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[CHECKOFFER](@KODKLILOYAL AS VARCHAR(50),@VLERTOT AS FLOAT,@MAGAZINA AS VARCHAR(30),@nrrendorsm as int)
                AS

                declare @nrrendorlast as int,@nrdshorte as int

                set @nrrendorlast = @nrrendorsm;--(select max(nrrendor) from sm with(nolock))


                set @nrdshorte = isnull((select top 1 kod from ofertemarketing where SHORTE = 1 and
	                DNGA		<=GETDATE()			AND DDERI		>= GETDATE()
                  AND VLNGA		<=@VLERTOT			AND VLDERI		>= @VLERTOT
                  AND ((KLILOYNGA <=@KODKLILOYAL		AND KLILOYDERI  >= @KODKLILOYAL) OR PERKLILOYAL=0)
                  AND MAGAZINAT LIKE '%' + @MAGAZINA + '%'),0)
                  
                if (((select count(1) from smscr where nrd = @nrrendorlast and exists (select 1 from ofertemarketingboundle shorte 
		                where shorte.kod = smscr.kartllg and shorte.nrd = @nrdshorte ))>=1 ) or (select allartc from ofertemarketing where nrrendor =@nrdshorte)=1)
		                and @nrdshorte!=0
                begin
		                SELECT TOP 1 KOD,
					                 PERSHKRIM, 
					                 VLERZBR = CASE WHEN VLFIX = 1 THEN VLERZBR ELSE 0 END,
					                 PERQZBR = CASE WHEN VLFIX = 0 THEN VLERZBR ELSE 0 END,
					                 KUPONIRRADHES,
					                 VLEFSHMERIA,
					                 mesazhpromocional=pershkrim,
					                 SHORTE = SHORTE
		                FROM OFERTEMARKETING where nrrendor = @nrdshorte
                end
                else
                begin
		                SELECT TOP 1 KOD,
					                 PERSHKRIM, 
					                 VLERZBR = CASE WHEN VLFIX = 1 THEN VLERZBR ELSE 0 END,
					                 PERQZBR = CASE WHEN VLFIX = 0 THEN VLERZBR ELSE 0 END,
					                 KUPONIRRADHES,
					                 VLEFSHMERIA,
					                 mesazhpromocional=pershkrim,
					                 SHORTE = SHORTE
		                FROM OFERTEMARKETING
		                WHERE DNGA		<=GETDATE()			AND DDERI		>= GETDATE()
		                  AND VLNGA		<=@VLERTOT			AND VLDERI		>= @VLERTOT
		                  AND ((KLILOYNGA <=@KODKLILOYAL		AND KLILOYDERI  >= @KODKLILOYAL) OR PERKLILOYAL=0)
		                  AND MAGAZINAT LIKE '%' + @MAGAZINA + '%'
                end
                
GO
