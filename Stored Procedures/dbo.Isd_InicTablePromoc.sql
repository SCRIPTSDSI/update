SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE Procedure [dbo].[Isd_InicTablePromoc] 

As

-- Perdoret vetem per rastin e pare te table Promoc

Declare @LlogDhurA Varchar(30),
        @LlogDhurB Varchar(30),
        @LlogDhurC Varchar(30),
        @LlogDhurD Varchar(30),
        @Kod       Varchar(5),
        @Llogari   Varchar(30),

        @ListKod   Varchar(10),
        @Pershkrim Varchar(50),
        @Koment    Varchar(50),
        @Prompt    Varchar(30),
        @Bosh      Varchar(5),
        @Lidhez    Varchar(5)

      SELECT @LlogDhurA=LLOGDHURA, @LlogDhurB=LLOGDHURB, @LlogDhurC=LLOGDHURC, @LlogDhurD=LLOGDHURD 
        FROM CONFIGLM

         SET @ListKod   = 'ABCD'
         SET @Prompt    = 'Promocion '
         SET @Koment    = 'Promocion ne shitje'
         SET @Bosh      = ''
         SET @Lidhez    = ' - ';


         SET @Kod       = SUBSTRING(@ListKod,1,1)
         SET @Llogari   = @LlogDhurA
         SET @Pershkrim = @Prompt+@Kod+@Lidhez+@Llogari;

         IF (IsNull(@Llogari,@Bosh)<>@Bosh) AND (NOT EXISTS (SELECT KOD FROM PROMOC WHERE KOD=@Kod))
            BEGIN
              INSERT INTO PROMOC
                     (KOD,PERSHKRIM,SHENIM1,SHENIM2,SHENIM3,KODLMFJ,KODLMFF,TIPI,KLASIFIKIM1,KLASIFIKIM2,DATELIMITED,NOTACTIV)
              VALUES (@Kod,@Pershkrim,@Koment,@Bosh,@Bosh,@Llogari,@Bosh,2,@Bosh,@Bosh,0,0);
            END;

         SET @Kod       = SUBSTRING(@ListKod,2,1)
         SET @Llogari   = @LlogDhurB
         SET @Pershkrim = @Prompt+@Kod+@Lidhez+@Llogari;

         IF (IsNull(@Llogari,@Bosh)<>@Bosh) AND (NOT EXISTS (SELECT KOD FROM PROMOC WHERE KOD=@Kod))
            BEGIN
              INSERT INTO PROMOC
                     (KOD,PERSHKRIM,SHENIM1,SHENIM2,SHENIM3,KODLMFJ,KODLMFF,TIPI,KLASIFIKIM1,KLASIFIKIM2,DATELIMITED,NOTACTIV)
              VALUES (@Kod,@Pershkrim,@Koment,@Bosh,@Bosh,@Llogari,@Bosh,2,@Bosh,@Bosh,0,0);
            END;

         SET @Kod       = SUBSTRING(@ListKod,3,1)
         SET @Llogari   = @LlogDhurC
         SET @Pershkrim = @Prompt+@Kod+@Lidhez+@Llogari;

         IF (IsNull(@Llogari,@Bosh)<>@Bosh) AND (NOT EXISTS (SELECT KOD FROM PROMOC WHERE KOD=@Kod))
            BEGIN
              INSERT INTO PROMOC
                     (KOD,PERSHKRIM,SHENIM1,SHENIM2,SHENIM3,KODLMFJ,KODLMFF,TIPI,KLASIFIKIM1,KLASIFIKIM2,DATELIMITED,NOTACTIV)
              VALUES (@Kod,@Pershkrim,@Koment,@Bosh,@Bosh,@Llogari,@Bosh,2,@Bosh,@Bosh,0,0);
            END;

         SET @Kod       = SUBSTRING(@ListKod,4,1)
         SET @Llogari   = @LlogDhurD
         SET @Pershkrim = @Prompt+@Kod+@Lidhez+@Llogari;

         IF (IsNull(@Llogari,@Bosh)<>@Bosh) AND (NOT EXISTS (SELECT KOD FROM PROMOC WHERE KOD=@Kod))
            BEGIN
              INSERT INTO PROMOC
                     (KOD,PERSHKRIM,SHENIM1,SHENIM2,SHENIM3,KODLMFJ,KODLMFF,TIPI,KLASIFIKIM1,KLASIFIKIM2,DATELIMITED,NOTACTIV)
              VALUES (@Kod,@Pershkrim,@Koment,@Bosh,@Bosh,@Llogari,@Bosh,2,@Bosh,@Bosh,0,0);
            END;

      SELECT @Llogari = CASE WHEN ISNULL(LLOGDHURA,'')<>'' THEN LLOGDHURA
                             WHEN ISNULL(LLOGDHURB,'')<>'' THEN LLOGDHURB
                             WHEN ISNULL(LLOGDHURC,'')<>'' THEN LLOGDHURC
                             WHEN ISNULL(LLOGDHURD,'')<>'' THEN LLOGDHURD
                             ELSE ''
                        END
        FROM CONFIGLM;


          IF IsNull(@Llogari,@Bosh)<>@Bosh
             BEGIN
               UPDATE CONFIGLM
                  SET LLOGPRMCFJ = CASE WHEN ISNULL(LLOGPRMCFJ,@Bosh)<>@Bosh 
                                        THEN ISNULL(LLOGPRMCFJ,@Bosh)
                                        ELSE @Llogari 
                                   END,
                      LLOGPRMCFF = CASE WHEN ISNULL(LLOGPRMCFF,@Bosh)<>@Bosh 
                                        THEN ISNULL(LLOGPRMCFF,@Bosh)
                                        ELSE @Llogari 
                                   END
             END;

--  UPDATE CONFIGLM -- A duhet ?
--     SET LLOGDHURA=@Bosh, LLOGDHURB=@Bosh, LLOGDHURC=@Bosh, LLOGDHURD=@Bosh

GO
