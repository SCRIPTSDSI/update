SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [dbo].[Isd_PrintDocFJKase]
(
  @PFiskal         Varchar(20),                -- Rasti 'FIS' ose jo
  @PDirectFromINI  Bit                         -- Rasti DIRECTKASEFJ tek Raport.Ini
)

As 

Begin

		Set NoCount On

	Declare @PrintKase       Bit,        -- Output
			@PrintDoc        Bit         -- Output

		Set @PrintKase     = 0;
		Set @PrintDoc      = 0;


		 if (Select IsNull(EXPORTKASE,0) From DBRP..CONFIG)=1
			begin
			  Select @PrintKase = IsNull(KASEACTIV,0) 
				From CONFIGMG;
			end;


		 if @PFiskal='FIS'
			begin
			  Select @PrintDoc = Case When IsNull(KASEDIRECT,0)=1 
                                      Then 0 
                                      Else 1 End
				From CONFIGMG;
			end
		 else
			begin
			  Select @PrintDoc = Case When IsNull(@PDirectFromINI,0)=1 -- nga Ini File
									  Then 0 
									  Else 1 End;
			end;


		 Select PRINTKASE=@PrintKase, PRINTDOC=@PrintDoc;

		Set NoCount Off

End;
GO
