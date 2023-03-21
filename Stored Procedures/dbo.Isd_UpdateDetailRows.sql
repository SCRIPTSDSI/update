SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE   Procedure [dbo].[Isd_UpdateDetailRows]
( 
  @pNrRendor  Int,  
  @pPerqindje Float,
  @pDecimal   Int
 )
AS



       SET NOCOUNT ON

   DECLARE @NrRendor     Int,
           @Perqindje    Float,
           @Decimal      Int

       SET @NrRendor   = @pNrRendor;
       SET @Perqindje  = @pPerqindje;
       SET @Decimal    = @pDecimal;
       
        IF NOT EXISTS(SELECT * FROM Sys.Columns WHERE OBJECT_ID=OBJECT_ID('SMSCR')    AND [NAME]='VLERASM')
           ALTER TABLE SMSCR ADD VLERASM FLOAT NULL;
        IF NOT EXISTS(SELECT * FROM Sys.Columns WHERE OBJECT_ID=OBJECT_ID('SMBAKSCR') AND [NAME]='VLERASM')
           ALTER TABLE SMBAKSCR ADD VLERASM FLOAT NULL;
           

    --UPDATE SMSCR
    --   SET VLERASM  =       CASE WHEN ISNULL(VLERASM,0) =0  THEN VLERABS ELSE          VLERASM END,
    --    -- VLERABS  = ROUND(CASE WHEN ISNULL(VLERASM,0) =0  THEN VLERABS ELSE          VLERASM END * @Perqindje/100, @Decimal),
    --       VLPATVSH = ROUND(CASE WHEN ISNULL(VLERASM,0) =0  THEN VLERABS ELSE          VLERASM END * @Perqindje/100  
    --                        / 
    --                        CASE WHEN ISNULL(PERQTVSH,0)=0  THEN 1       ELSE 1+(PERQTVSH/100) END, @Decimal)
    -- WHERE NRD=@pNrRendor;
    --
    --UPDATE SMSCR
    --   SET CMIMBS   = ROUND( CASE WHEN ISNULL(SASI,0)=0 THEN CMIMBS ELSE VLPATVSH/SASI END,@Decimal),
    --       VLTVSH   = ROUND((VLPATVSH * PERQTVSH)/100, @Decimal),
    --       VLERABS  = VLPATVSH + ROUND((VLPATVSH * PERQTVSH)/100, @Decimal)
    -- WHERE NRD=@pNrRendor;

    UPDATE SMSCR
       SET VLERASM  =       CASE WHEN ISNULL(VLERASM,0) =0  THEN VLERABS ELSE          VLERASM END,
           VLERABS  = ROUND(CASE WHEN ISNULL(VLERASM,0) =0  THEN VLERABS ELSE          VLERASM END * @Perqindje/100, @Decimal)
     WHERE NRD=@pNrRendor;

    UPDATE SMSCR
       SET VLPATVSH =            ROUND(VLERABS / CASE WHEN ISNULL(PERQTVSH,0)=0  THEN 1       ELSE 1+(PERQTVSH/100) END, 2),
           VLTVSH   = VLERABS  - ROUND(VLERABS / CASE WHEN ISNULL(PERQTVSH,0)=0  THEN 1       ELSE 1+(PERQTVSH/100) END, 2),
           CMIMBS   = ROUND( CASE WHEN ISNULL(SASI,0)=0 
                                  THEN CMIMBS 
                                  ELSE ROUND(VLERABS / CASE WHEN ISNULL(PERQTVSH,0)=0  THEN 1 ELSE 1+(PERQTVSH/100) END, 2)/SASI 
                             END,2)
     WHERE NRD=@pNrRendor;
GO
