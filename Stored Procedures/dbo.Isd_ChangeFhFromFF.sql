SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--Exec [dbo].[Isd_ChangeFhFromFF] 'FHSCR',1,'PG1',1,1

CREATE Procedure [dbo].[Isd_ChangeFhFromFF] 
(
  @pTableName   Varchar(100),
  @pNrRendor    Int,
  @pKMag        Varchar(30),
  @pKurs1       Float,
  @pKurs2       Float
)


As

Begin

         Set NoCount On

     Declare @sSql         nVarchar(Max),
             @TableName    Varchar(30),
             @NrRendor     Int,
             @KMag         Varchar(30),
             @Kurs1        Float,
             @Kurs2        Float,
             @GetTest      Int,
             @Result       Bit;

         Set @TableName  = LTrim(RTrim(@PTableName));
         Set @NrRendor   = @PNrRendor; 
         Set @KMag       = IsNull(@PKMag,'');
         Set @Kurs1      = IsNull(@PKurs1,1);
         Set @Kurs2      = IsNull(@PKurs2,1);

         Set @GetTest    = 2;
         Set @Result     = 0;

          if (Left(@TableName,1) ='#' And (Object_Id('Tempdb..'+@TableName) is null)) Or
             (Left(@TableName,1)<>'#' And (Object_Id(@TableName) is null)) Or
             @NrRendor<=0 Or (@KMag='')
             begin
               Set  @GetTest = 0;
               GoTo Display_Result;
             end;



-- Test per FF
 
          if (@GetTest<>0) And 
             ( Exists ( Select KMAG, KURS1,KURS2 
                          From FF
                         Where NrRendor = @NrRendor 

                        EXCEPT

                        Select KMAG=@KMag, KURS1=@Kurs1, KURS2=@Kurs2 ) )
             begin
               Set  @GetTest = 1;
               GoTo Display_Result;
             end;


-- Test per FH

         Set @sSql       = N'

         Set NoCount On

     Declare @ChangeScr    Bit,
             @NrRendor     Int,
             @NrRendorMg   Int,
             @Kurs1        Float,
             @Kurs2        Float;

         Set @NrRendor   = '+Cast(Cast(@NrRendor As BigInt) As Varchar)+';
         Set @ChangeScr  = 0;    

      Select @NrRendorMg = IsNull(NRRENDDMG,0),
             @Kurs1      = KURS1,
             @Kurs2      = KURS2
        From FF A
       Where NRRENDOR=@NrRendor;

         Set @NrRendorMg=IsNull(@NrRendorMg,0);

          if ( Exists ( Select KODAF, SASI, 
                               Round((CMIMBS   * @Kurs2)/@Kurs1,3), 
                               Round((VLPATVSH * @Kurs2)/@Kurs1,3),
                               NrRow = (Select Count(*) From FFScr Where NrD=@NrRendor And TIPKLL=''K'')
                          From FFScr
                         Where NrD = @NrRendor And TIPKLL=''K''

                        EXCEPT

                        Select KODAF, SASI, CMIMOR, VLERAOR, 
                               NrRow = (Select Count(*) From FHScr Where NrD=@NrRendorMg)
                          From FHScr 
                         Where NrD = @NrRendorMg  And IsNull(GJENROWAUT,0)=0)) 

             Or

             ( Exists ( Select KODAF, SASI, CMIMOR, VLERAOR, 
                               NrRow = (Select Count(*) From FHScr Where NrD=@NrRendorMg) 
                          From FHScr 
                         Where NrD = @NrRendorMg And IsNull(GJENROWAUT,0)=0

                        EXCEPT

                        Select KODAF, SASI, 
                               Round((CMIMBS   * @Kurs2)/@Kurs1,3), 
                               Round((VLPATVSH * @Kurs2)/@Kurs1,3),
                               NrRow = (Select Count(*) From FFScr Where NrD=@NrRendor And TIPKLL=''K'') 
                          From FFScr 
                         Where NrD = @NrRendor And TIPKLL=''K''))

             Set @ChangeScr = 1;


       Set @Result = @ChangeScr;  ';


          if Left(@TableName,1)<>'FFSCR'
             begin
               Set @sSql = Replace(@sSql,'FFScr',@TableName);
             end;
          if Left(@TableName,1)='#'
             begin
               Set @sSql = Replace(@sSql,'NrD=@NrRendor And ','');
             end;
    -- Print @sSql;

          if @GetTest=2
             begin
               Execute sp_ExecuteSql @sSql, N'@Result Bit Out',@Result Output;
               --Print @Result;
               if @Result=0
                  Set @GetTest = 0
               else 
                  Set @GetTest = 1;
             end;



    Display_Result:


          if (@GetTest=1) 
             begin
               Select VLEXTRA,  EXTMGFIELD,  EXTMGVLORIGJ,  EXTMGFORME,  RESULT=Cast(1 As Bit)
                 From FH
                Where NRRENDOR = (Select NRRENDDMG 
                                    From FF
                                   Where NRRENDOR=@NrRendor);
             end;

          if @GetTest=0
             begin
               Select VLEXTRA=0,EXTMGFIELD=0,EXTMGVLORIGJ=0,EXTMGFORME=0,RESULT=Cast(0 As Bit);
             end;

End
GO
