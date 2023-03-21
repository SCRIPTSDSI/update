SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   FUNCTION [dbo].[Isd_DateMinDoc]
(
 @PTip Varchar(10)
)
Returns DateTime 

As

Begin

	Declare @DtMin   DateTime
	    Set @DtMin = GetDate()

    Declare @Tip     Varchar(5)
        Set @Tip   = '1'    -- Rasti Date Minimum per te gjitha dokumentat qe kane operacione ne LM

    if @PTip='LM'           -- Rasti per KalimLM pra data e dokumentave te pa kaluar ne LM
        Set @Tip   = '2'
       
  --Print @DtMin

	SELECT @DtMin=Case When @DtMin<=IsNull(Min(DATEDOK),@DtMin) Then @DtMin Else IsNull(Min(DATEDOK),@DtMin) End 
  	  FROM ARKA 
	 WHERE @Tip='1' or NRDFK=0
  --Print @DtMin

	SELECT @DtMin=Case When @DtMin<=IsNull(Min(DATEDOK),@DtMin) Then @DtMin Else IsNull(Min(DATEDOK),@DtMin) End 
	  FROM BANKA 
	 WHERE @Tip='1' or NRDFK=0
	--Print @DtMin

	SELECT @DtMin=Case When @DtMin<=IsNull(Min(DATEDOK),@DtMin) Then @DtMin Else IsNull(Min(DATEDOK),@DtMin) End 
	  FROM VS
	 WHERE @Tip='1' or NRDFK=0
  --Print @DtMin

	SELECT @DtMin=Case When @DtMin<=IsNull(Min(DATEDOK),@DtMin) Then @DtMin Else IsNull(Min(DATEDOK),@DtMin) End 
	  FROM FH 
	 WHERE @Tip='1' or NRDFK=0
  --Print @DtMin

	SELECT @DtMin=Case When @DtMin<=IsNull(Min(DATEDOK),@DtMin) THEN @DtMin Else IsNull(Min(DATEDOK),@DtMin) End 
	  FROM FD
	 WHERE @Tip='1' or NRDFK=0
  --Print @DtMin

	SELECT @DtMin=Case When @DtMin<=IsNull(Min(DATEDOK),@DtMin) Then @DtMin Else IsNull(Min(DATEDOK),@DtMin) End 
	  FROM FF
	 WHERE @Tip='1' or NRDFK=0
  --Print @DtMin

	SELECT @DtMin=Case When @DtMin<=IsNull(Min(DATEDOK),@DtMin) Then @DtMin Else IsNull(Min(DATEDOK),@DtMin) End 
	  FROM FJ
	 WHERE @Tip='1' or NRDFK=0
  --Print @DtMin

	SELECT @DtMin=Case When @DtMin<=IsNull(Min(DATEDOK),@DtMin) Then @DtMin Else IsNull(Min(DATEDOK),@DtMin) End 
	  FROM DG
	 WHERE @Tip='1' or NRDFK=0
  --Print @DtMin

	Return (Convert(DateTime,@DtMin,104))

End
GO
