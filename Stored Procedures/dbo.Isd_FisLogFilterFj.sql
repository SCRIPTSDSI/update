SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Isd_FisLogFilterFj]
(
  @pWhereFJ    Varchar(Max),
  @pWhereFF    Varchar(Max),
  @pFiskal     Int,                       -- Nuk ka nevoje sepse behet brenda ne program
  @pStatus     Int,
  @pResultFJ   Varchar(Max) Output,
  @pResultFF   Varchar(Max) Output
)

AS

BEGIN
-- Perdoret ne filter ditar fiskalizime

-- @pFiskal -           0 te gjitha, 1 Fiskalizuar, 2 Pa fiskalizuar, -- kjo bie sepse ky test behet tek programi brenda
-- @pStatus - Per EIC   0 te gjitha, 1 Delivered,   2 Accepted,       3 Rejected


         SET NOCOUNT ON;

     DECLARE @sWhereFJ    Varchar(Max),
	         @sWhereFF    VarchaR(Max), 
--	         @sFiskal     Varchar(100),
			 @sStatus     Varchar(200),
			 @iStatus     Int;

	     SET @sWhereFJ  = ISNULL(@pWhereFJ,'');
	     
		 SET @sWhereFF  = ISNULL(@pWhereFF,'')+CASE WHEN ISNULL(@pWhereFF,'')<>'' THEN ' AND ' ELSE ''
		 END+'(KLASETVSH IN (''DOMESTIC'',''ABROAD'',''FANG'',''AGREEMENT'',''OTHER''))';                 
	     --  KLASETVSH='FFRM'   ->  Blerje nga Fermere 
		 --  KLASETVSH='BSHJV'  ->  Blerje sherbime nga jashte vendit

		 SET @iStatus = ISNULL(@pStatus,0);

--       SET @sFiskal = CASE WHEN @pFiskal = 1 THEN 'FISKALIZUAR=0'
--                           WHEN @pFiskal = 2 THEN 'FISKALIZUAR=1'
--                           ELSE                   ''
--                      END;

         SET @sStatus = CASE WHEN @iStatus = 1 THEN 'FISSTATUS=''DELIVERED'''
                             WHEN @iStatus = 2 THEN 'FISSTATUS=''ACCEPTED'''
							 WHEN @iStatus = 3 THEN 'FISSTATUS=''REFUSED'''
                             ELSE                   ''
                        END;

          IF @sStatus<>''
             BEGIN
	           IF @sWhereFJ<>''
                  SET @sWhereFJ = @sWhereFJ + ' AND ' + @sStatus
               ELSE
		          SET @sWhereFJ = @sStatus;

	           IF @sWhereFF<>''
                  SET @sWhereFF = @sWhereFF + ' AND ' + @sStatus
               ELSE
		          SET @sWhereFF = @sStatus;
	         END;

         SET @pResultFj = @sWhereFJ;
         SET @pResultFF = @sWhereFF;

      SELECT ResultFJ   = @sWhereFJ, ResultFF = @sWhereFF;
	    

END


GO
