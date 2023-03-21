SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO












CREATE     Function [dbo].[IsFAStatusAktiv]
(
@PKod AS Varchar(50)
)

Returns Bit

as

begin

--Declare @PKod Varchar(100)
--Set @PKod = '200002'

Declare @FAStatusFH Varchar(100),
        @FAStatusFD Varchar(100),
        @FAStatus   Bit,
        @FAStatusAK Varchar(30)

    Set @FAStatusAK=Upper('Aktiv')

   Set @FAStatusFH = IsNull((SELECT TOP 1 FASTATUS FROM FHSCR WHERE KARTLLG=@PKod AND FASTATUS=@FAStatusAK),'')

if @FAStatusFH<>@FAStatusAK
   Set @FAStatusFD = IsNull((SELECT TOP 1 FASTATUS FROM FDSCR WHERE KARTLLG=@PKod AND FASTATUS=@FAStatusAK),'')

if (@FAStatusFD=@FAStatusAK) or (@FAStatusFH=@FAStatusAK)
   Set @FAStatus=1   
   
else

   Set @FAStatus=0

Return @FAStatus

end




GO
