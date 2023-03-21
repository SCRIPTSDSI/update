SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



--Exec [Isd_RivlPrdMg02] 2159, '31/03/2015',


CREATE Procedure [dbo].[Isd_RivlPrdMg02]
(
  @PNrRendor   Int, 
  @PDateKs     Varchar(20)
 )


AS


         SET NOCOUNT ON


     DECLARE @NrRendor     Int,
             @DateKp       Datetime,
             @DateKS       DateTime,
             @NrRendorPRD  Int,
             @VleraPRD     Float,
             @CmimPRD      Float,
             @KodPRD       Varchar(50);
  
         SET @NrRendor   = @PNrRendor
         SET @DateKS     = dbo.DateValue(@PDateKs);
  
  
  
--           1.1. Gjen produkte
  
      SELECT TOP 1 @NrRendorPRD = A.NRRENDOR
        FROM FHSCR A                                     
       WHERE NRD = @NrRendor AND ISNULL(A.GJENROWAUT,0)=0 
    ORDER BY A.NRRENDOR;   
  
  
--           1.2. Llogarit vlera te elementeve (pa produktin)
 
      SELECT @VleraPRD = SUM(VLERAM)
        FROM FHSCR A
       WHERE A.NRD=@NrRendor AND A.NRRENDOR<>@NrRendorPRD; 
  
  
--           1.3. Modifikon vlere produkti ....
  
      UPDATE A
         SET A.VLERAM = 0-@VleraPRD,
             A.CMIMM  = CASE WHEN  A.SASI<>0 THEN (0-@VleraPRD)/A.SASI ELSE  0-@VleraPRD END
        FROM FHSCR A INNER JOIN FH B ON A.NRD=B.NRRENDOR                 
       WHERE A.NRRENDOR = @NrRendorPRD AND ISNULL(B.DOK_JB,0)=0;  -- Blerje ????
   
   
--           1.4. Modifikon fushen qe tregon se produktit ju kalkulua cmimi
--                Per kete pike shiko komentet tek Isd_RivlPrdMg01

      UPDATE A
         SET A.CMIMUPDATE = 0
        FROM FHSCR A INNER JOIN FH B ON A.NRD=B.NRRENDOR                 
       WHERE A.NRD = @NrRendor 


   
 --          2.1 Marim kodin dhe daten e produktit
 
      SELECT @KodPRD = B.KARTLLG,
             @DateKp = A.DATEDOK
        FROM FH A INNER JOIN FHSCR B ON A.NRRENDOR=B.NRD
       WHERE B.NRRENDOR = @NrRendorPRD;     




 -- Update Fhscr,Fdscr  

--           3.1 Gjej kosto mesatare historike te produktit

      SELECT @CmimPRD = ABS( SUM(CASE WHEN TIP='H' THEN VLERAH ELSE 0-VLERAD END)  

                             /
                             CASE WHEN SUM(CASE WHEN TIP='H' THEN SASIH ELSE 0-SASID END) <> 0 
                                  THEN SUM(CASE WHEN TIP='H' THEN SASIH ELSE 0-SASID END)
                                  ELSE 1 
                             END
                             )
        FROM LEVIZJEHD A
       WHERE A.KARTLLG = @KodPRD AND     -- A.DATEDOK<=@DateKp    
           (
            (A.DATEDOK < @DateKp)
             OR 
            (A.TIP='H' AND A.DATEDOK=@DateKp AND CHARINDEX(','+UPPER(ISNULL(A.DST,''))+',',',BL,SI,PR,')>0 AND ISNULL(A.GJENROWAUT,0)=0)
            ) 
    GROUP BY KARTLLG;

--Per test te fshihet

    --INSERT INTO [ZZZZ_RIVLMG]
    --       ([DOKNRRENDOR]
    --       ,[SCRNRRENDOR]
    --       ,[KARTTLG]
    --       ,[CMIMPROD]
    --       ,[DATEDOK]
    --       ,[TIPDOK]
    --       ,[KMAG])
    -- VALUES
    --       (@NrRendorPRD,
    --       0,
    --       @KodPRD,
    --       @CmimPRD,
    --       @DateKp,
    --       'H',
    --       '')

--Per test te fshihet




     
--           3.2   me kete kosto ndryshon vlerat ne dokumentat e tjere
--           3.2.1 Fh

      UPDATE B
         SET B.CMIMM      = @CmimPRD,
             B.VLERAM     = B.SASI * @CmimPRD,
             B.CMIMUPDATE = CASE WHEN UPPER(A.DST)='PR' AND ISNULL(B.GJENROWAUT,0)=1 THEN 1 ELSE B.CMIMUPDATE END
             
        FROM FH A INNER JOIN FHSCR B ON A.NRRENDOR=B.NRD
        
       WHERE A.NRRENDOR<>@NrRendor  AND ISNULL(DOK_JB,0)=0     AND 
       
           (
            ( A.DATEDOK >@DateKp    AND A.DATEDOK <@DateKS)  
             OR  
            ((A.DATEDOK =@DateKp    OR  A.DATEDOK =@DateKs) AND (A.NRRENDOR>@NrRendor OR ISNULL(A.DST,'')<>'PR')) 
            )                       AND

             B.KARTLLG =@KodPRD     AND 
             
           ( 
            (UPPER(A.DST)='PR' AND ISNULL(B.GJENROWAUT,0)=1)
              OR 
             CHARINDEX(','+UPPER(ISNULL(A.DST,''))+',',',BL,SI,PR,')=0 
            );
        
             
--           3.2. Fd

      UPDATE B
         SET B.CMIMM  = @CmimPRD,
             B.VLERAM = B.SASI * @CmimPRD
        FROM FD A INNER JOIN FDSCR B ON A.NRRENDOR=B.NRD
        
       WHERE A.DATEDOK>=@DateKp  AND  A.DATEDOK<=@DateKS          AND
       
             CHARINDEX(','+UPPER(ISNULL(A.DST,''))+',',',SI,')=0  AND

             B.KARTLLG =@KodPRD; 

GO
