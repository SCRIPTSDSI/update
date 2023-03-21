SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE          procedure [dbo].[Isd_KodChangeTest]

(
 @TipKll VarChar(20)
)
AS

Declare @Reference  Varchar(50),
        @NameColon1 Varchar(30),
        @NameColon2 Varchar(30)

    Set @Reference  = 'Llogari'
    Set @NameColon1 = 'Kod Egzistues'
    Set @NameColon2 = 'Kod i Ri'


	if @TipKll='LLG'                 -- Llogari

	   begin

         Set @Reference  = 'Llogari'

		   SELECT KOD          = ISNULL(KOD,''),   
                  KOLONA       = @NameColon1,
				  ERRORMSG     = ISNULL(KOD,'')+': Figuron disa here  - '+Cast(COUNT(*) as Varchar)+' here.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '1'
			 FROM KODCHANGE
			WHERE TIPKLL=@TipKLL
		 GROUP BY KOD
		   HAVING COUNT(*)>=2

		--per Test qe KODNEW Figuron disa here ska nevoje'

		UNION ALL
		   SELECT KOD          = ISNULL(KOD,''),   
                  KOLONA       = @NameColon1,
				  ERRORMSG     = ISNULL(KOD,'')+': '+@Reference+' panjohur/Jo Analize.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '2'
			 FROM KODCHANGE A
			WHERE TIPKLL=@TipKLL AND (Not Exists (SELECT B.KOD FROM LLOGARI B WHERE B.KOD=A.KOD AND B.POZIC=1))
		 GROUP BY KOD

		UNION ALL

		   SELECT KOD          = ISNULL(KODNEW,''),   
                  KOLONA       = @NameColon2,
				  ERRORMSG     = ISNULL(KODNEW,'')+': '+@Reference+' panjohur/Jo Analize.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '3'
			 FROM KODCHANGE A
			WHERE TIPKLL=@TipKLL AND (Not Exists (SELECT B.KOD FROM LLOGARI B WHERE B.KOD=A.KODNEW AND POZIC=1))
		 GROUP BY KODNEW

		UNION ALL
		   SELECT KOD          = ISNULL(KOD,''),   
                  KOLONA       = @NameColon1,
				  ERRORMSG     = ISNULL(KOD,'')+': '+@Reference+' figuron edhe tek kodet e reja.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '4'
			 FROM KODCHANGE A
			WHERE TIPKLL=@TipKLL AND Exists (SELECT B.KODNEW FROM KODCHANGE B WHERE B.KODNEW=A.KOD)
		 GROUP BY KOD

		 ORDER BY ERRORKOD,KOD,KOLONA

	   end;


	if @TipKll='LKL'                 -- Klient

	   begin

         Set @Reference  = 'Klient'

		   SELECT KOD          = ISNULL(KOD,''),   
                  KOLONA       = @NameColon1,
				  ERRORMSG     = ISNULL(KOD,'')+': Figuron disa here  - '+Cast(COUNT(*) as Varchar)+' here.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '1'
			 FROM KODCHANGE
			WHERE TIPKLL=@TipKLL
		 GROUP BY KOD
		   HAVING COUNT(*)>=2

		--per Test qe KODNEW Figuron disa here ska nevoje'

		UNION ALL
		   SELECT KOD          = ISNULL(KOD,''),   
                  KOLONA       = @NameColon1,
				  ERRORMSG     = ISNULL(KOD,'')+': '+@Reference+' panjohur.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '2'
			 FROM KODCHANGE A
			WHERE TIPKLL=@TipKLL AND (Not Exists (SELECT B.KOD FROM KLIENT B WHERE B.KOD=A.KOD))
		 GROUP BY KOD

		UNION ALL

		   SELECT KOD          = ISNULL(KODNEW,''),   
                  KOLONA       = @NameColon2,
				  ERRORMSG     = ISNULL(KODNEW,'')+': '+@Reference+' panjohur.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '3'
			 FROM KODCHANGE A
			WHERE TIPKLL=@TipKLL AND (Not Exists (SELECT B.KOD FROM KLIENT B WHERE B.KOD=A.KODNEW))
		 GROUP BY KODNEW

		UNION ALL
		   SELECT KOD          = ISNULL(KOD,''),   
                  KOLONA       = @NameColon1,
				  ERRORMSG     = ISNULL(KOD,'')+': '+@Reference+' figuron edhe tek kodet e reja.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '4'
			 FROM KODCHANGE A
			WHERE TIPKLL=@TipKLL AND Exists (SELECT B.KODNEW FROM KODCHANGE B WHERE B.KODNEW=A.KOD)
		 GROUP BY KOD

		 ORDER BY ERRORKOD,KOD,KOLONA

	   end;


	if @TipKll='LFU'                 -- Furnitor

	   begin

         Set @Reference  = 'Furnitor'

		   SELECT KOD          = ISNULL(KOD,''),   
                  KOLONA       = @NameColon1,
				  ERRORMSG     = ISNULL(KOD,'')+': Figuron disa here  - '+Cast(COUNT(*) as Varchar)+' here.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '1'
			 FROM KODCHANGE
			WHERE TIPKLL=@TipKLL
		 GROUP BY KOD
		   HAVING COUNT(*)>=2

		--per Test qe KODNEW Figuron disa here ska nevoje'

		UNION ALL
		   SELECT KOD          = ISNULL(KOD,''),   
                  KOLONA       = @NameColon1,
				  ERRORMSG     = ISNULL(KOD,'')+': '+@Reference+' panjohur.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '2'
			 FROM KODCHANGE A
			WHERE TIPKLL=@TipKLL AND (Not Exists (SELECT B.KOD FROM FURNITOR B WHERE B.KOD=A.KOD))
		 GROUP BY KOD

		UNION ALL

		   SELECT KOD          = ISNULL(KODNEW,''),   
                  KOLONA       = @NameColon2,
				  ERRORMSG     = ISNULL(KODNEW,'')+': '+@Reference+' panjohur.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '3'
			 FROM KODCHANGE A
			WHERE TIPKLL=@TipKLL AND (Not Exists (SELECT B.KOD FROM FURNITOR B WHERE B.KOD=A.KODNEW))
		 GROUP BY KODNEW

		UNION ALL
		   SELECT KOD          = ISNULL(KOD,''),   
                  KOLONA       = @NameColon1,
				  ERRORMSG     = ISNULL(KOD,'')+': '+@Reference+' figuron edhe tek kodet e reja.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '4'
			 FROM KODCHANGE A
			WHERE TIPKLL=@TipKLL AND Exists (SELECT B.KODNEW FROM KODCHANGE B WHERE B.KODNEW=A.KOD)
		 GROUP BY KOD

		 ORDER BY ERRORKOD,KOD,KOLONA

	   end;


	if @TipKll='ART'                 -- Artikuj

	   begin

         Set @Reference  = 'Artikuj'

		   SELECT KOD          = ISNULL(KOD,''),   
                  KOLONA       = @NameColon1,
				  ERRORMSG     = ISNULL(KOD,'')+': Figuron disa here  - '+Cast(COUNT(*) as Varchar)+' here.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '1'
			 FROM KODCHANGE
			WHERE TIPKLL=@TipKLL
		 GROUP BY KOD
		   HAVING COUNT(*)>=2

		--per Test qe KODNEW Figuron disa here ska nevoje'

		UNION ALL
		   SELECT KOD          = ISNULL(KOD,''),   
                  KOLONA       = @NameColon1,
				  ERRORMSG     = ISNULL(KOD,'')+': '+@Reference+' panjohur.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '2'
			 FROM KODCHANGE A
			WHERE TIPKLL=@TipKLL AND (Not Exists (SELECT B.KOD FROM ARTIKUJ B WHERE B.KOD=A.KOD))
		 GROUP BY KOD

		UNION ALL

		   SELECT KOD          = ISNULL(KODNEW,''),   
                  KOLONA       = @NameColon2,
				  ERRORMSG     = ISNULL(KODNEW,'')+': '+@Reference+' panjohur.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '3'
			 FROM KODCHANGE A
			WHERE TIPKLL=@TipKLL AND (Not Exists (SELECT B.KOD FROM ARTIKUJ B WHERE B.KOD=A.KODNEW))
		 GROUP BY KODNEW

		UNION ALL
		   SELECT KOD          = ISNULL(KOD,''),   
                  KOLONA       = @NameColon1,
				  ERRORMSG     = ISNULL(KOD,'')+': '+@Reference+' figuron edhe tek kodet e reja.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '4'
			 FROM KODCHANGE A
			WHERE TIPKLL=@TipKLL AND Exists (SELECT B.KODNEW FROM KODCHANGE B WHERE B.KODNEW=A.KOD)
		 GROUP BY KOD

		 ORDER BY ERRORKOD,KOD,KOLONA

	   end;


	if @TipKll='DEP'                 -- Departament

	   begin

         Set @Reference  = 'Departament'

		   SELECT KOD          = ISNULL(KOD,''),   
                  KOLONA       = @NameColon1,
				  ERRORMSG     = ISNULL(KOD,'')+': Figuron disa here  - '+Cast(COUNT(*) as Varchar)+' here.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '1'
			 FROM KODCHANGE
			WHERE TIPKLL=@TipKLL
		 GROUP BY KOD
		   HAVING COUNT(*)>=2

		--per Test qe KODNEW Figuron disa here ska nevoje'

		UNION ALL
		   SELECT KOD          = ISNULL(KOD,''),   
                  KOLONA       = @NameColon1,
				  ERRORMSG     = ISNULL(KOD,'')+': '+@Reference+' panjohur.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '2'
			 FROM KODCHANGE A
			WHERE TIPKLL=@TipKLL AND (Not Exists (SELECT B.KOD FROM DEPARTAMENT B WHERE B.KOD=A.KOD))
		 GROUP BY KOD

		UNION ALL

		   SELECT KOD          = ISNULL(KODNEW,''),   
                  KOLONA       = @NameColon2,
				  ERRORMSG     = ISNULL(KODNEW,'')+': '+@Reference+' panjohur.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '3'
			 FROM KODCHANGE A
			WHERE TIPKLL=@TipKLL AND (Not Exists (SELECT B.KOD FROM DEPARTAMENT B WHERE B.KOD=A.KODNEW))
		 GROUP BY KODNEW

		UNION ALL
		   SELECT KOD          = ISNULL(KOD,''),   
                  KOLONA       = @NameColon1,
				  ERRORMSG     = ISNULL(KOD,'')+': '+@Reference+' figuron edhe tek kodet e reja.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '4'
			 FROM KODCHANGE A
			WHERE TIPKLL=@TipKLL AND Exists (SELECT B.KODNEW FROM KODCHANGE B WHERE B.KODNEW=A.KOD)
		 GROUP BY KOD

		 ORDER BY ERRORKOD,KOD,KOLONA

	   end;


	if @TipKll='LIS'                 -- Liste

	   begin

         Set @Reference  = 'Liste'

		   SELECT KOD          = ISNULL(KOD,''),   
                  KOLONA       = @NameColon1,
				  ERRORMSG     = ISNULL(KOD,'')+': Figuron disa here  - '+Cast(COUNT(*) as Varchar)+' here.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '1'
			 FROM KODCHANGE
			WHERE TIPKLL=@TipKLL
		 GROUP BY KOD
		   HAVING COUNT(*)>=2

		--per Test qe KODNEW Figuron disa here ska nevoje'

		UNION ALL
		   SELECT KOD          = ISNULL(KOD,''),   
                  KOLONA       = @NameColon1,
				  ERRORMSG     = ISNULL(KOD,'')+': '+@Reference+' panjohur.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '2'
			 FROM KODCHANGE A
			WHERE TIPKLL=@TipKLL AND (Not Exists (SELECT B.KOD FROM DEPARTAMENT B WHERE B.KOD=A.KOD))
		 GROUP BY KOD

		UNION ALL

		   SELECT KOD          = ISNULL(KODNEW,''),   
                  KOLONA       = @NameColon2,
				  ERRORMSG     = ISNULL(KODNEW,'')+': '+@Reference+' panjohur.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '3'
			 FROM KODCHANGE A
			WHERE TIPKLL=@TipKLL AND (Not Exists (SELECT B.KOD FROM DEPARTAMENT B WHERE B.KOD=A.KODNEW))
		 GROUP BY KODNEW

		UNION ALL
		   SELECT KOD          = ISNULL(KOD,''),   
                  KOLONA       = @NameColon1,
				  ERRORMSG     = ISNULL(KOD,'')+': '+@Reference+' figuron edhe tek kodet e reja.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '4'
			 FROM KODCHANGE A
			WHERE TIPKLL=@TipKLL AND Exists (SELECT B.KODNEW FROM KODCHANGE B WHERE B.KODNEW=A.KOD)
		 GROUP BY KOD

		 ORDER BY ERRORKOD,KOD,KOLONA

	   end;


	if @TipKll='NJ'                 -- Njesi

	   begin

         Set @Reference  = 'Njesi'

		   SELECT KOD          = ISNULL(KOD,''),   
                  KOLONA       = @NameColon1,
				  ERRORMSG     = ISNULL(KOD,'')+': Figuron disa here  - '+Cast(COUNT(*) as Varchar)+' here.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '1'
			 FROM KODCHANGE
			WHERE TIPKLL=@TipKLL
		 GROUP BY KOD
		   HAVING COUNT(*)>=2

		--per Test qe KODNEW Figuron disa here ska nevoje'

		UNION ALL
		   SELECT KOD          = ISNULL(KOD,''),   
                  KOLONA       = @NameColon1,
				  ERRORMSG     = ISNULL(KOD,'')+': '+@Reference+' panjohur.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '2'
			 FROM KODCHANGE A
			WHERE TIPKLL=@TipKLL AND (Not Exists (SELECT B.KOD FROM NJESI B WHERE B.KOD=A.KOD))
		 GROUP BY KOD

		UNION ALL

		   SELECT KOD          = ISNULL(KODNEW,''),   
                  KOLONA       = @NameColon2,
				  ERRORMSG     = ISNULL(KODNEW,'')+': '+@Reference+' panjohur.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '3'
			 FROM KODCHANGE A
			WHERE TIPKLL=@TipKLL AND (Not Exists (SELECT B.KOD FROM NJESI B WHERE B.KOD=A.KODNEW))
		 GROUP BY KODNEW

		UNION ALL
		   SELECT KOD          = ISNULL(KOD,''),   
                  KOLONA       = @NameColon1,
				  ERRORMSG     = ISNULL(KOD,'')+': '+@Reference+' figuron edhe tek kodet e reja.',
                  NRPERSERITUR = COUNT(*),
                  ERRORKOD     = '4'
			 FROM KODCHANGE A
			WHERE TIPKLL=@TipKLL AND Exists (SELECT B.KODNEW FROM KODCHANGE B WHERE B.KODNEW=A.KOD)
		 GROUP BY KOD

		 ORDER BY ERRORKOD,KOD,KOLONA

	   end;



GO
