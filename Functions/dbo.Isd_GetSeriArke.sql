SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Function [dbo].[Isd_GetSeriArke]
(
  @PKodAB       Varchar(30),
  @PTip         Varchar(10),
  @PViti        Int
)

Returns Varchar(30)

As

Begin
-- Select [dbo].[Isd_GetSeriArke]('A02','MP',2012)

  Declare @SeriAutArk   Int,
          @NrDigit      Int,
          @NrSeri       BigInt,
          @Result       Varchar(30)


   Select @SeriAutArk = SERIAUTARK, @NrDigit = NRDIGISERI 
     From CONFIGLM
 
      Set @NrSeri     = ''

       if @SeriAutArk = 0
          Return ''

       else

       if @SeriAutArk = 1

          Select @NrSeri = IsNull(Max(Case When IsNumeric(NRSERI)=1 
                                           Then Cast(NRSERI As BigInt) 
                                           Else 0 End),'0')+1
            From ARKA
           Where KODAB=@PKodAB And Year(DATEDOK)=@PViti And TIPDOK=@PTip 

       else

       if @SeriAutArk = 2

          Select @NrSeri = IsNull(Max(Case When IsNumeric(NRSERI)=1 
                                           Then Cast(NRSERI As BigInt) 
                                           Else 0 End),'0')+1
            From ARKA
           Where KODAB=@PKodAB And Year(DATEDOK)=@PViti

      Set @Result = Cast(@NrSeri As Varchar(30))

	if @NrDigit>0
	   Select @Result = Right(Replicate('0',@NrDigit)+@Result,@NrDigit)

  Return @Result

End
GO
