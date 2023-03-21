SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[getpikeForProduct](@kodart as varchar(50),@nrkarta as varchar(50),@vlpatvsh as float)

as

 

declare @kursi as float

 

 

if isnull(@nrkarta,'')=''

      begin

      set @kursi = (select top 1 PIKEB/LEKEB from karteantaresie..karta_tip)

      end

else

      begin

            set @kursi =(select TOP 1 PIKEB/LEKEB from karteantaresie..karta_tip

                                    inner join karteantaresie..SCR AS S ON S.KARTA_TIP = karteantaresie..karta_tip.NRRENDOR

                                    WHERE S.BARCODE = @nrkarta)

      end

     

if (select count(1) from artikuj where kod = @kodart and isnull(klasif4,'') = 'X' )>0

begin

      set @kursi = 0;

end

 

select  @vlpatvsh * @kursi
GO
