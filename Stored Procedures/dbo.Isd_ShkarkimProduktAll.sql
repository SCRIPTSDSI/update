SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE         Procedure [dbo].[Isd_ShkarkimProduktAll]
  (
  @Tip        Varchar(10),
  @PTagRnd    Varchar(30), -- Rasti kur vjen nga parti dokumenta tashme te zgjedhura 
  @PWhere     Varchar(Max)
  )
as

       Set NoCount Off


   Declare @TableMgScr   Varchar(30),
           @ListCommun   Varchar(Max),
           @ListCommun1  Varchar(Max),
           @WhereFh      Varchar(Max),
           @WhereFd      Varchar(Max),
           @Where        Varchar(Max)

    Select 
           @TableMgScr = 'F'+@Tip+'SCR',
           @WhereFh    = '', 
           @WhereFd    = '', 
           @Where      = '1=1'

        if @PWhere<>''
           Select @Where = @PWhere
        else 
        if @PTagRnd<>''
           Select @Where = ' TAGRND='+QuoteName(@PTagRND,'''')

        if @Tip='H'
           Select @WhereFh = ' A.DOK_JB=0 And A.DST=''PR'' And '
        else
           Select @WhereFd = ' And ((A.DOK_JB=0 And C.AUTOSHKLPFDBR=1) Or (A.DOK_JB=1 And C.AUTOSHKLPFJ=1)) '

-- 1.  Inicializim Variabla dhe struktura

-- 1.1 Krijimi i Strukturave Temporare

       
        if Object_Id('TempDB..#MGPrd') is not null
           DROP TABLE #MGPrd;

        if Object_Id('TempDB..#FHSCRPrd') is not null
           DROP TABLE #FHSCRPrd;

--     Exec('Use TempDB
--
--            if Exists (Select Name From Sys.Objects Where Object_Id=Object_Id(''#MGPrd''))
--               Drop Table #MGPrd 
--
--            if Exists (Select Name From Sys.Objects Where Object_Id=Object_Id(''#FHSCRPrd''))
--              Drop Table #FHSCRPrd ')

    SELECT KMAG, DOK_JB, DST, NRRENDOR=Cast(0 As BigInt) 
      INTO #MGPrd
      FROM FH 
     WHERE 1=2


	SELECT *, KMAG=Replicate('',30), DOK_JB=Cast(0 As Bit) 
	  INTO #FHSCRPrd
	  FROM FHSCR
	 WHERE 1=2


-- 1.2 Ndertimi i tabeles me dokumentat qe do te perpunohen (Kokat e dokumentave)

    Exec (' 
            Insert Into #MGPrd 
                  (KMAG, DOK_JB, DST, NRRENDOR)
            Select KMAG, DOK_JB, DST, NRRENDOR 
              From F'+@Tip+' A
             Where '+@Where+' And '+@WhereFH+'
                   (Select IsNull(Count(''''),0)  
                      From F'+@Tip+'SCR B INNER JOIN ARTIKUJ C On B.KARTLLG=C.KOD 
                     Where A.NRRENDOR=B.NRD And C.TIP=''P'''+@WhereFd+')>0 ')

              
    if (Select IsNull(Count(''),0) From #MGPrd)<=0
       Return




-- 2  AutoShkarkim      


-- 2.1 Fshihen ato qe sjane Produkt per rastin e Levizjeve te brendeshme....

                                   --if @DokJB=0   -- Dalje ?????    
      Exec ('
           Delete B
             From #MGPrd A Inner Join F'+@Tip+'SCR B  On A.NRRENDOR=B.NRD 
                           Inner Join ARTIKUJ C       On B.KARTLLG=C.KOD 
            Where '+@WhereFh+' A.Dok_JB=0 And C.TIP<>''P''');



-- 3.  Krijimi i Temp-it te rrjeshtave


-- 3.1 Produktet


      Set  @ListCommun  = dbo.Isd_ListFields2Tables('#FHSCRPrd','F'+@Tip+'SCR','NRRENDOR,GJENROWAUT,TROW,TAGNR,KMAG,DOK_JB')
      Set  @ListCommun1 = dbo.Isd_ListFieldsAlias(@ListCommun,'B')

	  Exec (' 
              INSERT INTO #FHSCRPrd
			 	    ('+@ListCommun+',
                     GJENROWAUT,TROW,TAGNR,KMAG,DOK_JB) 
			  SELECT '+@ListCommun1+',  
			  	     0,
				     Case When A.Dok_JB=1  Then   1 Else 0 End,     
				     Case When C.TIP=''P'' Then 100 Else 0 End,
				     A.KMAG,
                     A.DOK_JB
			    FROM #MGPrd A INNER JOIN F'+@Tip+'SCR B ON A.NRRENDOR=B.NRD
				  		      INNER JOIN ARTIKUJ C      ON B.KARTLLG=C.KOD 
			   WHERE '+@WhereFh+' C.TIP=''P'' And IsNull(B.GJENROWAUT,0)=0 And
                    ( '''+@Tip+'''= ''H'' Or 
                     (A.DOK_JB=1 And C.AUTOSHKLPFJ=1) Or (A.DOK_JB=0 And C.AUTOSHKLPFDBR=1)) ')



-- 3.2 Perberesit e produkteve

       Exec ('
              INSERT INTO #FHSCRPrd         
                    (NRD, KOD, KODAF, KARTLLG, PERSHKRIM, SASI, VLERAM, GJENROWAUT, TROW, TAGNR,KMAG,DOK_JB)      

              SELECT A.NRRENDOR,
                     MIN(A.KMAG)+''.''+C.KOD+C.QKOSTO+''.'',           
                     C.KOD + CASE WHEN C.QKOSTO=''..'' THEN '''' ELSE C.QKOSTO END,           
                     C.KOD, 
                     MIN(C.PERSHKRIM), 
                     SASIRE  = Case When A.DOK_JB=0 Then -1 Else 1 End 
                               * 
                               ROUND(Case When SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) =0
                                          Then 0.001        
                                          Else SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) End,4),
                     VLERARE = Case When A.Dok_JB=0 Then -1 Else 1 End 
                               * 
                               ROUND(Case When SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) =0 
                                          Then 0.001 
                                          Else SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB) End
                                          *
                                          MIN(C.KOSTMES),4), 
                     1,0,10,
                     MAX(A.KMAG),
                     A.DOK_JB
                FROM #MGPrd A LEFT JOIN F'+@Tip+'SCR B ON A.NRRENDOR=B.NRD
                              LEFT JOIN QARTIKUJSCR C  ON B.KARTLLG =C.KODPR  
               WHERE '+@WhereFh+' IsNull(B.GJENROWAUT,0)=0 And 
                    ( ('''+@Tip+'''= ''H'') Or 
                      (A.Dok_JB=1 And C.AUTOSHKLPFJ=1) Or (A.Dok_JB=0 And C.AUTOSHKLPFDBR=1) )
            GROUP BY A.NRRENDOR,C.KOD,C.QKOSTO,A.DOK_JB   
              HAVING ROUND(SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB),4)<>0 ')



-- 3.3 Udate te ndryshme
 
    UPDATE #FHSCRPrd
       SET CMIMM   = Case When VLERAM*SASI<=0 Then 0 Else VLERAM/SASI End, 
           CMIMOR  = Case When VLERAM*SASI<=0 Then 0 Else VLERAM/SASI End,
           VLERAOR = VLERAM, 
           CMIMBS  = Case When VLERAM*SASI<=0 Then 0 Else VLERAM/SASI End, 
           VLERABS = VLERAM,
           KOMENT  = '2. Shkarkim Perberesa'
     WHERE TAGNR=10

-- 3.4 Produkt i Rivleresuar ne Cmim 
-- Me Konfigurim ne ConfigMG
    UPDATE A       --Ndryshuar nga Genti 09/01/2012 per Aiba
       SET VLERAM = (SELECT SUM(C.KOEFICIENT * C.KOSTMES * B.SASI / C.KOEFICPERB)
                       FROM #FHSCRPrd B INNER JOIN QARTIKUJSCR C ON B.KARTLLG = C.KODPR
                      WHERE B.KARTLLG=A.KARTLLG
                   GROUP BY B.KARTLLG
                     HAVING ROUND(SUM((SASI*C.KOEFICIENT)/C.KOEFICPERB),4)<>0)
      FROM #FHSCRPrd A INNER JOIN ARTIKUJ B ON A.KARTLLG=B.KOD  
     WHERE A.TAGNR = 100



-- 3.5 Shkarkim i vete Produkteve Ne se duhet te shkarkohen dhe vete produkti, Rasti FJ

    INSERT INTO #FHSCRPrd
          (NRD, KOD, KODAF, KARTLLG, NRRENDKLLG, PERSHKRIM, NJESI,KMON,KOMENT,  
           SASI, VLERAM, CMIMM, VLERAOR, CMIMOR,
           VLERAFT, CMIMBS, VLERABS, KOEFSHB, NJESINV, TIPKLL, GJENROWAUT, TROW, KMAG,DOK_JB)     
    SELECT NRD, A.KOD, A.KODAF, A.KARTLLG, A.NRRENDKLLG, A.PERSHKRIM, A.NJESI,A.KMON,
           '1. Deklarimi produktit', 
           0-A.SASI, 0-A.VLERAM, CMIMM, 0-A.VLERAM, CMIMM, 
           VLERAFT, CMIMBS, 0-VLERABS, KOEFSHB, NJESINV, TIPKLL, 1, 0, A.KMAG, A.DOK_JB
      FROM #FHSCRPrd A
     WHERE A.TAGNR = 100 AND A.DOK_JB=1



-- 3.6 Update te ndryshme

       UPDATE A 
          SET A.KOD        = Upper(A.KOD),     --A.NRD        = @PNrRendor,
              A.NRRENDKLLG = B.NRRENDOR,
              A.KONVERTART = ISNULL(KONV2,1) / 
                                    CASE WHEN ISNULL(KONV1,1)=0 THEN 1 ELSE ISNULL(KONV1,1) END, 
              A.CMIMM      = ROUND( CASE WHEN VLERAM*SASI>0 THEN VLERAM/SASI ELSE 1 END,3),
              A.NJESI      = B.NJESI,
              A.NJESINV    = B.NJESI,
              A.TIPKLL     = 'K',
              A.KMON       = '',
              A.KOEFSHB    = 1,
              CMIMSH       = CASE WHEN C.Grup='B' THEN IsNull(CMSH1,CMSH) 
							      WHEN C.Grup='C' THEN IsNull(CMSH2,CMSH)  
							      WHEN C.Grup='D' THEN IsNull(CMSH3,CMSH) 
							      WHEN C.Grup='E' THEN IsNull(CMSH4,CMSH) 
							      WHEN C.Grup='F' THEN IsNull(CMSH5,CMSH) 
							      WHEN C.Grup='G' THEN IsNull(CMSH6,CMSH) 
							      WHEN C.Grup='H' THEN IsNull(CMSH7,CMSH) 
							      WHEN C.Grup='I' THEN IsNull(CMSH8,CMSH) 
							      WHEN C.Grup='J' THEN IsNull(CMSH9,CMSH) 
							      WHEN C.Grup='K' THEN IsNull(CMSH10,CMSH) 
							      WHEN C.Grup='L' THEN IsNull(CMSH11,CMSH) 
							      WHEN C.Grup='M' THEN IsNull(CMSH12,CMSH) 
							      WHEN C.Grup='N' THEN IsNull(CMSH13,CMSH) 
							      WHEN C.Grup='O' THEN IsNull(CMSH14,CMSH) 
							      WHEN C.Grup='P' THEN IsNull(CMSH15,CMSH) 
							      WHEN C.Grup='Q' THEN IsNull(CMSH16,CMSH) 
							      WHEN C.Grup='R' THEN IsNull(CMSH17,CMSH) 
							      WHEN C.Grup='S' THEN IsNull(CMSH18,CMSH) 
							      WHEN C.Grup='T' THEN IsNull(CMSH19,CMSH) 
							      ELSE CMSH END,

              VLERASH      = ROUND(SASI * 
							 CASE WHEN C.Grup='B' THEN IsNull(CMSH1,CMSH) 
							 	  WHEN C.Grup='C' THEN IsNull(CMSH2,CMSH)  
							      WHEN C.Grup='D' THEN IsNull(CMSH3,CMSH) 
							      WHEN C.Grup='E' THEN IsNull(CMSH4,CMSH) 
							      WHEN C.Grup='F' THEN IsNull(CMSH5,CMSH) 
							      WHEN C.Grup='G' THEN IsNull(CMSH6,CMSH) 
							      WHEN C.Grup='H' THEN IsNull(CMSH7,CMSH) 
							      WHEN C.Grup='I' THEN IsNull(CMSH8,CMSH) 
							      WHEN C.Grup='J' THEN IsNull(CMSH9,CMSH)  
							      WHEN C.Grup='K' THEN IsNull(CMSH10,CMSH)  
							      WHEN C.Grup='L' THEN IsNull(CMSH11,CMSH)  
							      WHEN C.Grup='M' THEN IsNull(CMSH12,CMSH)  
							      WHEN C.Grup='N' THEN IsNull(CMSH13,CMSH)  
							      WHEN C.Grup='O' THEN IsNull(CMSH14,CMSH)  
							      WHEN C.Grup='P' THEN IsNull(CMSH15,CMSH)  
							      WHEN C.Grup='Q' THEN IsNull(CMSH16,CMSH)  
							      WHEN C.Grup='R' THEN IsNull(CMSH17,CMSH)  
							      WHEN C.Grup='S' THEN IsNull(CMSH18,CMSH)  
							      WHEN C.Grup='T' THEN IsNull(CMSH19,CMSH)  
								  ELSE CMSH END,3),

              A.GJENROWAUT = IsNull(A.GJENROWAUT,0),
              A.BC         = IsNull(A.BC,''),
              A.PROMOC     = IsNull(A.PROMOC,0),
              A.PROMOCTIP  = IsNull(A.PROMOCTIP,''),
              A.RIMBURSIM  = IsNull(A.RIMBURSIM,0),
              A.SERI       = IsNull(A.SERI,''),
              A.TIPFR      = IsNull(A.TIPFR,''),
              A.SASIFR     = IsNull(A.SASIFR,0),
              A.VLERAFR    = IsNull(A.VLERAFR,0),
              A.LLOGLM     = IsNull(A.LLOGLM,''),
              A.KOEFICIENT = IsNull(A.KOEFICIENT,0),
              A.ORDERSCR   = IsNull(A.ORDERSCR,0),
              A.TIPKTH     = IsNull(A.TIPKTH,''),
              A.FBARS      = IsNull(A.FBARS,0),
              A.FCOLOR     = IsNull(A.FCOLOR,''),
              A.FLENGTH    = IsNull(A.FLENGTH,''),
              A.FPROFIL    = IsNull(A.FPROFIL,''), 
              A.FAKLS      = IsNull(A.FAKLS,''),
              A.FADESTIN   = IsNull(A.FADESTIN,''),
              A.FASTATUS   = IsNull(A.FASTATUS,''),
              A.TAGNR      = 0
         FROM #FHSCRPrd A INNER JOIN ARTIKUJ B  ON A.KARTLLG=B.KOD 
                          INNER JOIN MAGAZINA C ON A.KMAG=C.KOD

       UPDATE A 
          SET A.VLERAFT    = IsNull(A.VLERAFT,A.VLERASH)
         FROM #FHSCRPrd A



-- 4  Kalimi ne DbFin

-- 4.1 Fshihen rrjeshtat e krijuara me pare ne FD te ardhura nga FJ (Kujdes ne DB Fin...)

  if @Tip='D' 
     Exec (' 
             Delete From #FHSCRPrd Where TROW=1;

             Delete B
			   From #MGPrd A Inner Join F'+@Tip+'SCR B On A.NRRENDOR=B.NRD 
                             Inner Join ARTIKUJ C      On B.KARTLLG =C.KOD 
			  Where A.Dok_JB=1 And IsNull(B.GJENROWAUT,0)=1; ')


-- 4.2 Fshihen rrjeshtat Scr te vjetra per rastin e dokumentave te brendeshem (Kujdes ne DB Fin...)

     Exec (' Delete B 
               From #MGPrd A Inner Join '+@TableMgScr+' B On A.NRRENDOR=B.NRD 
              Where A.DOK_JB=0; ')


-- 4.3 Shtim Scr te reja ne Bazen reale

     Set  @ListCommun = dbo.Isd_ListFields2Tables('#FHSCRPrd',@TableMgScr,'NRRENDOR')
     Exec ( ' 
              INSERT INTO '+@TableMgScr+' 
                    ('+@ListCommun+') 
              SELECT '+@ListCommun+'
                FROM #FHSCRPrd; ' )


-- 5  Fshirja e Temporareve

        if Object_Id('TempDB..#FHSCRPrd') is not null
           DROP TABLE #FHSCRPrd;
        if Object_Id('TempDB..#MGPrd')    is not null
           DROP TABLE #MGPrd;

--     Exec('Use TempDB
--
--           if Exists (SELECT NAME FROM Sys.Objects Where Object_Id=Object_Id(''#FHSCRPrd''))
--              DROP TABLE #FHSCRPrd 
--
--           if Exists (SELECT NAME FROM Sys.Objects Where Object_Id=Object_Id(''#MGPrd''))
--              DROP TABLE #MGPrd ')





GO
