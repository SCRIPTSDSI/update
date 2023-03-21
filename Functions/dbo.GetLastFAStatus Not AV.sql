SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO











CREATE     Function [dbo].[GetLastFAStatus Not AV]
(
@PKod AS Varchar(50)
)

Returns Varchar(50)

AS

Begin

--Declare @PKod Varchar(100)
--Set @PKod = '200002'



Declare @FAStatusFH Varchar(100)
Declare @FAStatusFD Varchar(100)
Declare @FAStatus   Varchar(30)
Declare @FADateFH   DateTime
Declare @FADateFD   DateTime


Declare @FAStatusAK Varchar(30)
Declare @FAStatusWP Varchar(30)
Set @FAStatusAK=Upper('Aktiv')
Set @FAStatusWP=Upper('Wip')



----
----Set @FAStatusFH = (SELECT FASTATUS FROM FHSCR WHERE FASTATUS='Aktiv')
----if @FAStatusFH<>'Aktiv'
----   Set @FAStatusFD = (SELECT FASTATUS FROM FDSCR WHERE FASTATUS='Aktiv')
----
----if (@FAStatusFD='Aktiv') or (@FAStatusFH='Aktiv')
----
----   begin
----     if (@FAStatusFD='Aktiv')
----        SET @FAStatus=@FAStatusFD
----     else
----        SET @FAStatus=@FAStatusFH
----
----     Return @FAStatus   
----   end
----
----Else



 SELECT TOP 1 @FAStatusFD=IsNull(FASTATUS,''), @FADateFD=FADATE 
   FROM FDSCR A
  WHERE KARTLLG=@PKod AND FASTATUS=@FAStatusAK

    Set @FAStatusFD=Upper(Isnull(@FAStatusFD,''))


  if @FAStatusFD<>@FAStatusAK
     Begin
       SELECT TOP 1 @FAStatusFH=IsNull(FASTATUS,''), @FADateFH=FADATE 
         FROM FHSCR A
        WHERE KARTLLG=@PKod AND FASTATUS=@FAStatusAK

       Set @FAStatusFH=Upper(Isnull(@FAStatusFH,''))
     End 

if not (@FAStatusFD=@FAStatusAK or @FAStatusFH=@FAStatusAK)
   Begin

         SELECT TOP 1 @FAStatusFD=FASTATUS, @FADateFD=FADATE 
           FROM FDSCR A
          WHERE KARTLLG=@PKod AND FADATE=(SELECT TOP 1 MAX(FADATE) FROM FDSCR B WHERE B.KARTLLG=@PKod) 

         SELECT TOP 1 @FAStatusFH=FASTATUS, @FADateFH=FADATE 
           FROM FHSCR A
          WHERE KARTLLG=@PKod AND FADATE=(SELECT TOP 1 MAX(FADATE) FROM FHSCR B WHERE B.KARTLLG=@PKod)
   End

SELECT @FAStatusFD=Upper(IsNull(@FAStatusFD,'')), @FAStatusFH=Upper(IsNull(@FAStatusFH,'')) 


if (@FAStatusFD=@FAStatusAK) or (@FAStatusFH=@FAStatusAK)

   begin
     if (@FAStatusFD=@FAStatusAK)
        SET @FAStatus=@FAStatusFD
     else
        SET @FAStatus=@FAStatusFH

     Return @FAStatus   
   end

Else

if (@FAStatusFD=@FAStatusWP) or (@FAStatusFH=@FAStatusWP)
   Begin
     if (@FAStatusFD=@FAStatusWP)
        SET @FAStatus=@FAStatusFD
     else
        SET @FAStatus=@FAStatusFH
   End

Else

if (@FAStatusFD<>'') or (@FAStatusFH<>'')
   Begin
     if @FAStatusFD<>''
        SET @FAStatus=@FAStatusFD
     Else
        SET @FAStatus=@FAStatusFH
    End

 --SELECT FASTATUS=IsNull(@FAStatus,'')


--SET @FADateFD=(SELECT MAX(FADATE) FROM FDSCR WHERE KARTLLG=@PKod)
--SET @FADateFH=(SELECT MAX(FADATE) FROM FHSCR WHERE KARTLLG=@PKod)
--
--if  @FADateFD>@FADateFH 
--
--    Begin
--      SELECT @FAStatus=FASTATUS 
--        FROM FDSCR A
--       WHERE KARTLLG=@PKod AND FADATE=@FADAteFD
--    End
--
--Else
--
--if  @FADateFD<@FADateFH 
--
--    Begin
--      SELECT @FAStatus=FASTATUS 
--        FROM FHSCR A
--       WHERE KARTLLG=@PKod AND FADATE=@FADAteFH
--    End
--
--Else
--    Begin
--      SELECT @FAStatusFD=FASTATUS 
--        FROM FDSCR 
--       WHERE KARTLLG=@PKod AND FADATE=@FADAteFD
--
--      SELECT @FAStatusFH=FASTATUS 
--        FROM FHSCR 
--       WHERE KARTLLG=@PKod AND FADATE=@FADAteFH
--
--      SELECT @FAStatus=Case When @FADateFD Is Null Then @FAStatusFH Else @FAStatusFD End
--    End

--Print 'FH:'+IsNull(@FAStatusFH,'') 
--Print 'FD:'+IsNull(@FAStatusFD,'') 
--Print @FADateFH 
--Print @FADateFD 

  Return @FAStatus

End



GO
