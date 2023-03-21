SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO




CREATE   FUNCTION [dbo].[Isd_TestBcOne]
(
  @pBarKod   Varchar(100),
  @pKod      Varchar(100),
  @pNrRendor Int
)

  RETURNS Varchar(100) 

AS

BEGIN

-- Select [dbo].[Isd_TestOneBc]( '1234567890','A000',1)

     DECLARE @sKod      Varchar(100),
             @sBarKod   Varchar(100),
             @sResult   Varchar(100),
             @iNrRendor Int;


         SET @sKod      = ISNULL(@pKod,'');
         SET @sBarKod   = ISNULL(@pBarkod,'');
         SET @iNrRendor = ISNULL(@pNrRendor,0);

         SET @sResult   = '';


          IF @sBarKod='' -- OR @sKod=''
             BEGIN
               RETURN (@sResult)
             END


          IF EXISTS (SELECT BC FROM ARTIKUJ WHERE ISNULL(BC,'')=@sBarKod AND KOD<>@sKod)
             BEGIN

               SET @sResult = 'Barkod perseritur. Shiko barkod reference per artikullin '+
                             (   SELECT TOP 1 KOD
                                   FROM ARTIKUJ 
                                  WHERE ISNULL(BC,'')=@sBarKod AND KOD<>@sKod
                               ORDER BY KOD
                              )+' ..!'

             END

          ELSE

          IF EXISTS (SELECT BC FROM ARTIKUJBCSCR WHERE ISNULL(BC,'')=@sBarKod AND NRRENDOR<>@iNrRendor)
             BEGIN

               SET @sResult = 'Barkod perseritur. Shiko multi barkod per artikullin '+
                             (   
                                 SELECT TOP 1 ISNULL(KOD,'')
                                   FROM ARTIKUJ
                                  WHERE NRRENDOR = (
                                                     SELECT TOP 1 B.NRD 
                                                       FROM ARTIKUJBCSCR B 
                                                      WHERE ISNULL(B.BC,'')=@sBarKod AND B.NRRENDOR<>@iNrRendor
                                                    )
                               ORDER BY KOD
                              )+' ..!'

             END;

      RETURN (@sResult)
END
GO
