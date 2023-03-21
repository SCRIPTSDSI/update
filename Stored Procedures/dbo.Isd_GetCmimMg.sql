SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Declare @PCmim Float;
-- Exec [Isd_GetCmimMg] 'P100','31.12.2014',0, @PCmim Output

CREATE        Procedure [dbo].[Isd_GetCmimMg]
( 
  @PKod      Varchar(30),
  @PDate     Varchar(30),
  @POper     Int,
  @PCmim     Float Output
 )
As

        Set NoCount On

    Declare @Kod      Varchar(30),
            @DtKs     DateTime,
            @NrFh     Int,
            @NrFd     Int,
            @DtFh     DateTime,
            @DtFd     DateTime,
            @Cmim     Float,
            @Dok      Varchar(5);

        Set @Kod    = @PKod; 
        Set @DtKs   = dbo.DateValue(@PDate);

        Set @NrFd   = 0;
        Set @NrFh   = 0;
        Set @Cmim   = 0.0;
        Set @Dok    = '';


-- Rast I

     Select @Cmim = Case When Sum(VleraM)*Sum(Sasi)>0
                         Then Sum(VleraM)/Sum(Sasi)
                         Else 0 
                    End
       From
    (
     Select KartLlg, Sasi, VleraM

       From Fh A Inner Join Fhscr B On A.NrRendor=B.Nrd
      Where KartLlg=@Kod And DATEDOK<=@DtKs

  Union All

     Select KartLlg, Sasi = 0-Sasi, VleraM = 0-VleraM
       From Fd A Inner Join Fdscr B On A.NrRendor=B.Nrd
      Where KartLlg=@Kod And DATEDOK<=@DtKs
      ) A
   Group By KartLlg;


         if @Cmim>0
            begin

           -- Set  @PCmim = @Cmim;
              Goto UpdateArt;
 
            end;



-- Rast II


     Select @DtFh = Max(DATEDOK), 
            @NrFh = Max(B.NRRENDOR)
       From Fh A Inner Join Fhscr B On A.NrRendor=B.Nrd
      Where KartLlg=@Kod And DATEDOK<=@DtKs
   Group By KartLlg,DATEDOK;

     Select @DtFd = Max(DATEDOK), 
            @NrFd = Max(B.NRRENDOR)
       From Fd A Inner Join Fdscr B On A.NrRendor=B.Nrd
      Where KartLlg=@Kod And DATEDOK<=@DtKs
   Group By KartLlg,DATEDOK;


         if IsNull(@NrFh,0)<>0 And IsNull(@NrFd,0)<>0
            begin

              if @DtFh>=@DtFd
                 begin
                   Set @Dok   = 'H'
                 end
              else
                 begin
                   Set @Dok   = 'D'
                 end;
            end

         else

         if IsNull(@NrFh,0)<>0 And IsNull(@NrFd,0)=0
            begin

              Set @Dok   = 'H'

            end

         else

         if IsNull(@NrFh,0)= 0 And IsNull(@NrFd,0)<>0
            begin

              Set @Dok   = 'D'

            end;


         if @Dok = 'H'
            begin 

              Select @Cmim = Max(CMIMBS)
                From Fh A Inner Join Fhscr B On A.NrRendor=B.Nrd
               Where A.DATEDOK=@DtFh And B.NrRendor=@NrFh;

            end

         else

         if @Dok = 'D'
            begin 

              Select @Cmim = Max(CMIMBS)
                From Fd A Inner Join Fdscr B On A.NrRendor=B.Nrd
               Where A.DATEDOK=@DtFd And B.NrRendor=@NrFd;

            end;
--Print @POper
--Print @Cmim

UpdateArt:

   
    Set @Cmim = Round(IsNull(@Cmim,0),3);

    if @POper=1 And @Cmim>0
       begin

         UpDate ARTIKUJ
            Set KOSTMES = @Cmim
          Where KOD=@Kod;
--        Print 'U Update '+@Kod +' me cmim '+Cast(@Cmim As Varchar)
       end;

   Set @PCmim = @Cmim;
GO
