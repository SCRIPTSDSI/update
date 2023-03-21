SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE         Procedure [dbo].[Isd_JobsStartMg01]
  (
  @SasiNegative  Varchar(5),
  @ArtikujMinMax Bit,
  @OnlyMinimum   Bit,
  @OnlyMaximum   Bit,
  @OnlyTest      Bit
  )
as

--Declare @SasiNegative Varchar(1)
--Set @SasiNegative  = '0',
--    @ArtikujMinMax = 1,
--    @OnlyMinimum   = 1,
--    @OnlyMaximum   = 1

    Declare @RowCount Int,
            @Where    Varchar(5000),
            @Having   Varchar(5000),
            @Fields   Varchar(5000)

        Set @Where      = ''
        Set @Fields     = '1'
        if  @OnlyTest   = 0
            Set @Fields = ' KOD       = MAX(ARTIKUJ.KOD),
                            PERSHKRIM = MAX(ARTIKUJ.PERSHKRIM),
                            GJENDJE   = ROUND(ISNULL(SUM(SASIH-SASID),0),2),
				            MINIMUM   = ISNULL(MAX(MINI),0),
                            MAKSIMUM  = ISNULL(MAX(MAKS),0) '

        Set NOCOUNT Off

    if  @ArtikujMinMax = 1
        Set @Where     = ' WHERE (ISNULL(MINI,0)>0 OR ISNULL(MAKS,0)>0) '

    Set @Having        = ' HAVING (1=1) AND (2=2) '

    if  @SasiNegative  = 0
        Set @Having    = Replace(@Having, '1=1',' (ISNULL(SUM(SASIH-SASID),0)>0.01) ')

    if  @OnlyMinimum   = 1
        Set @Having    = Replace(@Having, '2=2',' ISNULL(SUM(SASIH-SASID),0)<ISNULL(MAX(MINI),0) ')
    else
    if  @OnlyMaximum   = 1
        Set @Having    = Replace(@Having, '2=2',' ISNULL(SUM(SASIH-SASID),0)>ISNULL(MAX(MAKS),0) ')
    else
        Begin
          Set @Having  = Replace(@Having, '2=2',' ISNULL(SUM(SASIH-SASID),0)<ISNULL(MAX(MINI),0) OR  
                                                  ISNULL(SUM(SASIH-SASID),0)>ISNULL(MAX(MAKS),0) ')
        End
Print 'SELECT '+@Fields+'
            FROM LEVIZJEHD INNER JOIN ARTIKUJ ON LEVIZJEHD.KARTLLG=ARTIKUJ.KOD '+
          @Where+'
        GROUP BY KARTLLG '+
         @Having


   Exec ('SELECT '+@Fields+'
            FROM LEVIZJEHD INNER JOIN ARTIKUJ ON LEVIZJEHD.KARTLLG=ARTIKUJ.KOD '+
          @Where+'
        GROUP BY KARTLLG '+
         @Having)

 Select @RowCount = @@ROWCOUNT  
 UPDATE JOBSSTART 
    SET ROWSCOUNT = ISNULL(@RowCount,0), DATEJOBS=GETDATE(), DATEAFTER=GETDATE() 
  WHERE KOD='MG001' AND MODUL='M'

Set NOCOUNT On


GO
