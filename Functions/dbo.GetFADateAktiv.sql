SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO













CREATE     Function [dbo].[GetFADateAktiv]
(
@PKod AS Varchar(50)
)

Returns DateTime

AS

Begin

--Declare @PKod Varchar(100)
--Set @PKod = '200002'
 
Declare @FAStatusFH Varchar(100)
Declare @FAStatusFD Varchar(100)
Declare @FADateFH   DateTime
Declare @FADateFD  DateTime

Declare @FAStatusAK Varchar(30)
Set     @FAStatusAK=Upper('Aktiv')


Declare @FADate     DateTime

 SELECT TOP 1 @FAStatusFD=FASTATUS, @FADateFD=FADATE 
   FROM FDSCR 
  WHERE KARTLLG=@PKod AND FASTATUS=@FAStatusAK 

 SELECT TOP 1 @FAStatusFH=FASTATUS, @FADateFH=FADATE 
   FROM FHSCR 
  WHERE KARTLLG=@PKod AND FASTATUS=@FAStatusAK

 
if (@FAStatusFD=@FAStatusAK) 
   Set @FADate=@FADateFD

Else   
if (@FAStatusFH=@FAStatusAK)
   Set @FADate=@FADateFH

Else
   Set @FADate=null

Return @FADate

End





GO
