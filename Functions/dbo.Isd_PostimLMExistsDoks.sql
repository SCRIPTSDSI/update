SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








--Select [dbo].[Isd_PostimLMExistsDoks]('01/01/2000','02/02/2020','a',1)


CREATE   FUNCTION [dbo].[Isd_PostimLMExistsDoks]
(
  @PDateKp       Varchar(20),
  @PDateKs       Varchar(20),
  @PSQLFilter    Varchar(Max),
  @POption       Int 
)
Returns Bit

As

  Begin

-- Select [dbo].[Isd_PostimLMExistsDoks]('01/01/2010','31/01/2010','',1)

	Declare @Res Bit
    Declare @DateMin Varchar(20)

	Set     @Res = 0
    Set     @DateMin = '01/01/1900'

    if @POption=0  -- Te gjitha 
       begin
         Set @PDateKp = @DateMin
         Set @PDateKs = '01/01/2100'
       end
    else
    if @POption=1  -- Deri ne KufiP
       begin
         Set @PDateKs = @PDateKp
         Set @PDateKp = @DateMin
       end
    else
    if @POption=2  -- Deri ne KufiS
       begin
         Set @PDateKp = @DateMin
       end;

    if (Exists (SELECT NRRENDOR 
                  FROM ARKA  
                 WHERE DATEDOK>=Dbo.DateValue(@PDateKp) And DATEDOK<=Dbo.DateValue(@PDateKs) And ISNULL(NRDFK,0)=0)) or 
	   (Exists (SELECT NRRENDOR 
                  FROM BANKA 
                 WHERE DATEDOK>=Dbo.DateValue(@PDateKp) And DATEDOK<=Dbo.DateValue(@PDateKs) And ISNULL(NRDFK,0)=0)) or 
	   (Exists (SELECT NRRENDOR 
                  FROM VS    
                 WHERE DATEDOK>=Dbo.DateValue(@PDateKp) And DATEDOK<=Dbo.DateValue(@PDateKs) And ISNULL(NRDFK,0)=0)) or 
	   (Exists (SELECT NRRENDOR 
                  FROM DG    
                 WHERE DATEDOK>=Dbo.DateValue(@PDateKp) And DATEDOK<=Dbo.DateValue(@PDateKs) And ISNULL(NRDFK,0)=0)) or 
	   (Exists (SELECT NRRENDOR 
                  FROM FF    
                 WHERE DATEDOK>=Dbo.DateValue(@PDateKp) And DATEDOK<=Dbo.DateValue(@PDateKs) And ISNULL(NRDFK,0)=0)) or 
	   (Exists (SELECT NRRENDOR 
                  FROM FH    
                 WHERE DATEDOK>=Dbo.DateValue(@PDateKp) And DATEDOK<=Dbo.DateValue(@PDateKs) And ISNULL(NRDFK,0)=0 And DST<>'TR')) or 
	   (Exists (SELECT NRRENDOR 
                  FROM FJ    
                 WHERE DATEDOK>=Dbo.DateValue(@PDateKp) And DATEDOK<=Dbo.DateValue(@PDateKs) And ISNULL(NRDFK,0)=0)) or 
	   (Exists (SELECT NRRENDOR 
                  FROM FD    
                 WHERE DATEDOK>=Dbo.DateValue(@PDateKp) And DATEDOK<=Dbo.DateValue(@PDateKs) And ISNULL(NRDFK,0)=0 And DST<>'TR')) 
	   Set @Res=1  

--    if @Res=0   -- Test per ngaterime FK 
--
--       Begin
--
--         if (not Exists (SELECT A.NRRENDOR 
--                           FROM ARKA A INNER JOIN FK B ON A.NRDFK=B.NRRENDOR  
--                          WHERE A.DATEDOK>=Dbo.DateValue(@PDateKp) And A.DATEDOK<=Dbo.DateValue(@PDateKs) And
--                                IsNull(A.NRDFK,0)<>0 AND IsNull(B.ORG,'')<>'A')) or 
--            (not Exists (SELECT A.NRRENDOR 
--                           FROM BANKA A INNER JOIN FK B ON A.NRDFK=B.NRRENDOR  
--                          WHERE A.DATEDOK>=Dbo.DateValue(@PDateKp) And A.DATEDOK<=Dbo.DateValue(@PDateKs) And
--                               (IsNull(A.NRDFK,0)<>0) AND IsNull(B.ORG,'')<>'B')) or 
--            (not Exists (SELECT A.NRRENDOR 
--                           FROM VS A INNER JOIN FK B ON A.NRDFK=B.NRRENDOR  
--                          WHERE A.DATEDOK>=Dbo.DateValue(@PDateKp) And A.DATEDOK<=Dbo.DateValue(@PDateKs) And
--                               (IsNull(A.NRDFK,0)<>0) AND IsNull(B.ORG,'')<>'E')) or 
--            (not Exists (SELECT A.NRRENDOR 
--                           FROM DG A INNER JOIN FK B ON A.NRDFK=B.NRRENDOR  
--                          WHERE A.DATEDOK>=Dbo.DateValue(@PDateKp) And A.DATEDOK<=Dbo.DateValue(@PDateKs) And
--                               (IsNull(A.NRDFK,0)<>0) AND IsNull(B.ORG,'')<>'G')) or 
--            (not Exists (SELECT A.NRRENDOR 
--                           FROM FF A INNER JOIN FK B ON A.NRDFK=B.NRRENDOR  
--                          WHERE A.DATEDOK>=Dbo.DateValue(@PDateKp) And A.DATEDOK<=Dbo.DateValue(@PDateKs) And
--                               (IsNull(A.NRDFK,0)<>0) AND IsNull(B.ORG,'')<>'F')) or 
--            (not Exists (SELECT A.NRRENDOR 
--                           FROM FH A INNER JOIN FK B ON A.NRDFK=B.NRRENDOR  
--                          WHERE A.DATEDOK>=Dbo.DateValue(@PDateKp) And A.DATEDOK<=Dbo.DateValue(@PDateKs) And
--                               (IsNull(A.NRDFK,0)<>0) AND IsNull(B.ORG,'')<>'H')) or 
--            (not Exists (SELECT A.NRRENDOR 
--                           FROM FJ A INNER JOIN FK B ON A.NRDFK=B.NRRENDOR  
--                          WHERE A.DATEDOK>=Dbo.DateValue(@PDateKp) And A.DATEDOK<=Dbo.DateValue(@PDateKs) And
--                               (IsNull(A.NRDFK,0)<>0) AND IsNull(B.ORG,'')<>'S')) or 
--            (not Exists (SELECT A.NRRENDOR 
--                           FROM FD A INNER JOIN FK B ON A.NRDFK=B.NRRENDOR  
--                          WHERE A.DATEDOK>=Dbo.DateValue(@PDateKp) And A.DATEDOK<=Dbo.DateValue(@PDateKs) And
--                               (IsNull(A.NRDFK,0)<>0) AND IsNull(B.ORG,'')<>'D'))
--
--		 Set @Res=1  
--
--       End


	Return @Res

  End




GO
