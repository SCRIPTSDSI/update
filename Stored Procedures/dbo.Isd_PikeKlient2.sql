SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--  Declare @pClID       VarChar(50), 
--          @pClPoints   Float; 
--     Exec dbo.Isd_PikeKlient2 'AS333',@pClPoints Out; 

CREATE procedure [dbo].[Isd_PikeKlient2]
(
   @pClientID      VarChar(50),
-- @pClientDscr    Varchar(100) Out,
-- @pClientComment Varchar(100) Out,
   @pClientPoints  Float        Out 
)
AS



      -- Set @pClientDscr    = '';
      -- Set @pClientComment = '';
         Set @pClientPoints  = 0;


     Declare @KlientId      Varchar(50),
             @KlientPike    Float,
             @AktivPike     Bit;

         Set @KlientId    = @pClientID
         Set @KlientPike  = 0;
         Set @AktivPike   = 0;

      Select @AktivPike = IsNull(AKTIVPRINTPIKE,0)
        From CONFIGMG;



          if @AktivPike=1
             EXEC Isd_PikeKlient @KlientId,@KlientPike out; 

         -- te zgjerohet dhe te meren jo vetem piket por edhe te dhena te tjera ...

    

      Select CLIENTID        = @KlientId,
             CLIENTDSCR      = '',          -- te meren nga tabela ose View per KientKarte
             CLIENTCOMMENT   = '',          --                  ''
             CLIENTPOINTS    = 0;           -- @KlientPike;

         Set @pClientID      = @KlientId;
      -- Set @pClientDscr    = '';
      -- Set @pClientComment = '';
         Set @pClientPoints  = @KlientPike; 
GO
