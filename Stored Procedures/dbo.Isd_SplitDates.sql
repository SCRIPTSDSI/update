SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









--Exec [Isd_SplitDates]
--  @PDateKp     = '01/01/2010',
--  @PDateKs     = '31/01/2010',
--  @PNrSteps    = 10


CREATE         Procedure [dbo].[Isd_SplitDates]
  (
  @PDateKp       Varchar(20),
  @PDateKs       Varchar(20),
  @PNrSteps      Int
  )
as


--      Set    NoCount Off
--      Set    NoCount on

Declare @Dt1  DateTime,
        @Dt2  DateTime
--Select  @Dt1       = Dbo.DateValue('21/01/2012'),
--        @Dt2       = Dbo.DateValue('21/02/2012') 

Select  @Dt1       = Dbo.DateValue(@PDateKp),
        @Dt2       = Dbo.DateValue(@PDateKs) 


Declare @NrSteps   Int,
        @DayStep   Int,
        @NrDaysTot Float,
        @PerqProg  Float,
        @Dt        DateTime

Select  @NrSteps   = Case When @PNrSteps<=0 Then 10 Else @PNrSteps End, 
        @NrDaysTot = DateDiff(dd,@Dt1,@Dt2)+1
Select  @DayStep   = Round(@NrDaysTot/@NrSteps,0) 
        
       Exec(' USE TEMPDB 
			  if Exists (SELECT NAME FROM Sys.Objects Where Object_Id=Object_Id(''#KALIMLM''))
				 DROP TABLE #KALIMLM ')

CREATE TABLE #KalimLM (
   	   [DATEKP]   [datetime] NULL,
	   [DATEKS]   [datetime] NULL,
       [PERQPROG] [Float] null,
       [NRSTEP]   [Float] null,
       [NRTOT]    [Float] null
  ) ON [PRIMARY]


if @Dt1>@Dt2
   Return

if @DayStep=0
   Set  @DayStep = @NrSteps

Select @Dt=@Dt1 + @DayStep

    if @Dt > @Dt2 
       Set @Dt = @Dt2

while DateDiff(dd,@Dt1,@Dt2)>=0  
  Begin

    Set @PerqProg = Round(((DateDiff(dd,Dbo.DateValue(@PDateKp),@Dt)+1)/@NrDaysTot)*100,1)
    if  @PerqProg>100
        Set @PerqProg = 100

    Insert Into #KalimLM
            (DateKp,DateKs,PerqProg,NrStep,NrTot)
     Values (@Dt1,@Dt,@PerqProg,DateDiff(dd,@Dt1,@Dt)+1,@NrDaysTot)

    Set   @Dt1 = @Dt+1
    Set   @Dt  = @Dt  + Case When @DayStep=0 Then 1 Else @DayStep End

    if    @Dt > @Dt2 
          Set @Dt = @Dt2

  End

SELECT * FROM #KalimLM Order By DateKp



GO
