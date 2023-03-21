SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--        Exec dbo.Isd_DocSaveFF 567717,'M',1,'#12345678','ADMIN','1234567890'

CREATE Procedure [dbo].[Isd_DocSaveFF]
(
  @PNrRendor      Int,
  @PIDMStatus     Varchar(10),
  @PSaveMg        Bit,
  @PTableTmpLm    Varchar(40),
  @PPerdorues     Varchar(30),
  @PLgJob         Varchar(30)
 )

As

-- Njesoj me FJ por Tipi='F',Isd_GjenerimFHFromFt dhe ska DokShoqerues.

         Set NoCount On

          if IsNull(@PNrRendor,0)<=0 -- IsNull(@PTableName,'')<>'FF' or IsNull(@PNrRendor,0)<=0
             Return;

		  IF @PIDMStatus='M'
		     BEGIN
			   UPDATE FF 
			      SET FISRELATEDFIC=FISIIC,ISDOCFISCAL=CASE WHEN  KLASETVSH IN ('DOMESTIC','ABROAD','FANG','AGREEMENT','OTHER') THEN 1 ELSE 0 END 
			    WHERE NRRENDOR=@PNrRendor AND ISNULL(FISRELATEDFIC,'')='';
		     END

		IF @PIDMStatus='S'
		  BEGIN
			  UPDATE FF 
			     SET FISFIC='',FISRELATEDFIC=FISIIC,
			         ISDOCFISCAL=CASE WHEN  KLASETVSH IN ('DOMESTIC','ABROAD','FANG','AGREEMENT','OTHER') THEN 1 ELSE 0 END
			   WHERE NRRENDOR=@PNrRendor;
		  END;

     Declare @NrRendor       Int,
             @IDMStatus      Varchar(10),
             @TableTmpLm     Varchar(40),
             @SaveMg         Bit,
             @Perdorues      Varchar(30),
             @LgJob          Varchar(30),
             @TableName      Varchar(30),
             @KMag           Varchar(30),
             @NrMag          Int,
             @NrRndMg        Int,
             @NrRendorFk     Int,
             @AutoPostLmFF   Bit,
             @Sql            nVarchar(Max),
             @Transaksion    Varchar(20),
             @Vlere          Float;

         Set @NrRendor     = @PNrRendor;
         Set @IDMStatus    = @PIDMStatus;
         Set @TableTmpLm   = @PTableTmpLm;
         Set @SaveMg       = @PSaveMg;   -- Perdoret rasti kur nuk prekete Fh nga Programi
         Set @Perdorues    = @PPerdorues;
         Set @LgJob        = @PLgJob;
         Set @TableName    = 'FF';
         Set @Transaksion  = 'IFMDS';  -- Delete me F apo D, Insert me I apo S


          -- Perdore ketu qe ta perdorin edhe Magazina dhe Arka
          if Object_Id('TempDb..'+@TableTmpLm) is not null
             Exec ('DROP TABLE '+@TableTmpLm);

      Select @AutoPostLmFF = Case When @PTableTmpLm<>'' Then IsNull(AUTOPOSTLMFF,0) Else 0 End
        From CONFIGLM;
              

--      Test per Kod-e, referenca, kurse etj.
        Exec dbo.Isd_DocSaveTestFields @TableName,@NrRendor,@IDMStatus;


      Select @NrRendorFk   = NRDFK,
             @Vlere        = VLERTOT,
             @KMag         = IsNull(KMAG,''),
             @NrMag        = IsNull(NRMAG,0)  
        From FF
       Where NRRENDOR = @NrRendor;

      Update A 
         Set KONVERTART = Round(Case When IsNull(B.KONV2,1)*IsNull(B.KONV1,1)<=0 
                                     Then 1 
                                     Else IsNull(B.KONV2,1)/IsNull(B.KONV1,1) End,3) 
        From FFSCR A INNER JOIN ARTIKUJ B On A.KARTLLG=B.KOD
       Where A.NRD=@NrRendor And A.TIPKLL='K';

      Update B 
         Set B.DATELASTBL = A.DATEDOK,
             B.CMB        = Case When IsNull(A.KMON,'')='' OR (A.KURS1=1 AND A.KURS2=1) OR (A.KURS1*A.KURS2<=0)
                                 Then A1.CMIMBS
                                 Else Round((A1.CMIMBS*A.KURS2)/A.KURS1,4)
                            End
        From FF A INNER JOIN FFSCR   A1 ON A.NRRENDOR=A1.NRD
                  INNER JOIN ARTIKUJ B  ON A1.KARTLLG=B.KOD
       Where A1.NRD=@NrRendor And A1.TIPKLL='K' AND IsNull(B.UPDATELASTBL,0)=1 And IsNull(B.DATELASTBL,0)<=A.DATEDOK;



-- 1.
        Exec dbo.Isd_GjenerimDitarOne @TableName, 0, @NrRendor;
-- 2.
          if CharIndex(@IDMStatus,@Transaksion)>0  
             Exec dbo.Isd_AppendTransLog @TableName,@NrRendor,@Vlere,@IDMStatus,@Perdorues,@LgJob;

     -- Postimi shiko me poshte -- Ketu le te behet fshirja ....
          if @NrRendorFk>=1
             Exec dbo.LM_DelFk @NrRendorFk;
     -- Postimi shiko me poshte 

-- 3.
          if @SaveMg=1
             BEGIN
               Exec Isd_GjenerimFHFromFt      @NrRendor,@Perdorues,@LgJob;
               EXEC Isd_GjenerimAQFromFt 'FF',@NrRendor,@Perdorues,@LgJob;
             END;  

-- 4.
     -- FF - DokShoq:  Fillim'

/*        if Not Exists (Select * 
                           From FJSHOQERUES 
                          Where NRD=@NrRendor)
             begin
               
               Insert  Into FJSHOQERUES
                      (NRD,[DATE],[TIME])
               Values (@NrRendor,GetDate(),dbo.Isd_DateTimeServer ('T'));

               UpDate A 
                  Set A.NIPT            = B.NIPT,
                      A.NIPTCERTIFIKATE = B.NIPTCERTIFIKATE,
                      A.KODFISKAL       = B.KODFISKAL,
                      A.NRLICENCE       = B.NRLICENCE,
                      A.TARGE           = B.TARGE,
                      A.MJET            = B.MJET,
                      A.KOMPANI         = B.KOMPANI,
                      A.TRANSPORTUES    = B.PERSHKRIM,
                      A.SHENIM1         = B.ADRESA1,
                      A.SHENIM2         = B.ADRESA2,
                      A.SHENIM3         = B.ADRESA3,
                      A.TELEFON1        = B.TELEFON1,
                      A.TELEFON2        = B.TELEFON2,
                      A.FAX             = B.FAX 
                 From FJSHOQERUES A, TRANSPORT B
                Where A.NRD = @NrRendor And B.LINKKLIENT = @KodKF;

             end;
*/
     -- FF - DokShoq:  Fund'


-- 5.

     -- FF - Dokument Arke: Fillim

        Exec dbo.Isd_DocumentArkeFromFt @TableName,0,@NrRendor,@Perdorues,@LgJob;

     -- FF - Dokument Arke: Fund


-- 6.

     -- FF - Kalimi ne Lm: Fillim

     --   if @NrRendorFk>=1
     --      Exec dbo.LM_DelFk @NrRendorFk;

          if @NrRendorFk>=1
             begin
               if IsNull(@AutoPostLmFF,0)=1
                  begin
                    Delete 
                      From FKSCR 
                     Where NrD = @NrRendorFk
                  end 
               else
                  begin
                    Delete 
                      From FK 
                     Where NrRendor=@NrRendorFk;

                    Update FF
                       Set NRDFK=0
                     Where NRRENDOR = @NrRendor;

                    Return;
                  end;
             end;

          if IsNull(@AutoPostLmFF,0)=0 Or @TableTmpLm=''
             Return;

--        Jo ketu fshirja sepse mund te perdoret nga Arka ose magazina ....
--        if Object_Id('TempDb..'+@TableTmpLm) is not null
--           Exec ('DROP TABLE '+@TableTmpLm);

        Exec [Isd_KalimLM] @PTip='F', @PNrRendor=@NrRendor, @PSQLFilter='', @PTableNameTmp=@TableTmpLm; 

     -- FF - Kalimi ne Lm: Fund 

/*                   PJESA TEST TEPER E RENDESISHME
  Declare @NrRendor Int
      Set @NrRendor=44749

   Select T01Dok='FF-Ff     ',* from Ff          Where NrRendor =@NrRendor;
   Select T02Dok='FF-FfRow  ',* from FfScr       Where Nrd      =@NrRendor;
-- Select T03Dok='FF-Tr     ',* From FJSHOQERUES Where Nrd      =@NrRendor;
-- Select T04Dok='FF-Pg     ',* From FJPG        Where Nrd      =@NrRendor;
   Select T05Dok='FF-FfDt   ',* From DKL         Where NrRendor =(Select NRDITAR    From Ff Where NrRendor=@NrRendor);

   Select T06Dok='FF-Fh     ',* From FH          Where NrRendor =(Select NRRENDDMG  From Ff Where NrRendor=@NrRendor);
   Select T07Dok='FF-FhRow  ',* From FHScr       Where Nrd      =(Select NRRENDDMG  From Ff Where NrRendor=@NrRendor);

   Select T08Dok='FF-Ar     ',* From Arka        Where NrRendor =(Select NRRENDORAR From Ff Where NrRendor=@NrRendor);
   Select T09Dok='FF-ArRow  ',* From ArkaScr     Where Nrd      =(Select NRRENDORAR From Ff Where NrRendor=@NrRendor);
   Select T10Dok='FF-ArDt   ',* From DAR         Where NrRendor =(Select NRDITAR 
                                                                    From Arka
                                                                   Where NrRendor=(Select NRRENDORAR From Ff Where NrRendor=@NrRendor));
-- Fk-Ff
   Select T11Dok='FF-Fk     ',* From FK          Where NrRendor =(Select NRDFK      From Ff Where NrRendor=@NrRendor);
   Select T12Dok='FF-FkRow  ',* From FKScr       Where Nrd      =(Select NRDFK      From Ff Where NrRendor=@NrRendor);
-- Fk-Fh
   Select T13Dok='FF-FhFk   ',* From FK          Where NrRendor =(Select NRDFK 
                                                                    From FH
                                                                   Where NrRendor=(Select NRRENDDMG  From Ff Where NrRendor=@NrRendor));
   Select T14Dok='FF-FhFkRow',* From FKScr       Where Nrd      =(Select NRDFK 
                                                                    From FH
                                                                   Where NrRendor=(Select NRRENDDMG  From Ff Where NrRendor=@NrRendor));
-- Fk-Arka
   Select T15Dok='FF-ArFk   ',* From FK          Where NrRendor =(Select NRDFK 
                                                                    From Arka
                                                                   Where NrRendor =(Select NRRENDORAR From Ff Where NrRendor=@NrRendor));
   Select T16Dok='FF-ArFkRow',* From FKScr       Where Nrd      =(Select NRDFK 
                                                                    From Arka
                                                                   Where NrRendor =(Select NRRENDORAR From Ff Where NrRendor=@NrRendor));
*/
GO
