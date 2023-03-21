SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[P_ARTIKUJT_PESHORE]
(
	 @GJ_BC AS INT
	,@GJ_PERSHKRIM AS INT
	,@GJ_CMSH AS INT
) AS
SELECT
      KOD, 
      PERSHKRIM_P = LEFT(artikuj.PERSHKRIM+'                                                                                                  ',
                       @GJ_PERSHKRIM),
      CMSH=CONVERT(VARCHAR(100),FLOOR(cmsh)),               
      CMSH_P=RIGHT('00000'+ CONVERT(VARCHAR(100),FLOOR(cmsh)),@GJ_CMSH),
      ARTIKUJBCSCR.BC,
      BC_P = RIGHT('00000'+ ARTIKUJBCSCR.BC,@GJ_BC),
      CASE 
        WHEN 
          (LEN(ARTIKUJBCSCR.BC)>@GJ_BC) OR 
          (LEN(CONVERT(VARCHAR(100),FLOOR(cmsh)))>@GJ_CMSH) OR
          (ISNULL(ARTIKUJBCSCR.BC,'')='')
        THEN 0 ELSE 1 END AS DERGO 
      FROM ARTIKUJ
      INNER JOIN ARTIKUJBCSCR ON ARTIKUJ.NRRENDOR=ARTIKUJBCSCR.NRD
 WHERE KLASIF6 ='P' 
GO
