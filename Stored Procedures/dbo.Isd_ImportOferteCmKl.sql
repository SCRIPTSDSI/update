SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




--Exec [Isd_ImportOferteCmKl] @PTableOrg = 'KLIENT', 
--                            @PNrDIns   = 1, 
--                            @PNrDOrg   = 2,
--                            @PWhere    = ' (A.KOD>=''K0'' AND A.KOD<=''K00126'') ',
--                            @POkCmim=1

CREATE Procedure [dbo].[Isd_ImportOferteCmKl]
 (
  @PTableOrg Varchar(20),
  @PNrDIns   Int,
  @PNrDOrg   Int,
  @PWhere    Varchar(Max),
  @POkCmim   Bit
  )
as

--  Declare @PTableOrg Varchar(20),
--          @PNrDIns   Int,
--          @PNrDOrg   Int,
--          @PWhere    Varchar(Max),
--          @POkCmim   Bit

--    --Rasti KLIENT
--      Set @PTableOrg  = 'KLIENT'
--      Set @PWhere     = ' (A.KOD>=''K0'' AND A.KOD<=''K00126'') '
--
--    --Rasti ARTIKUJ
--      Set @PTableOrg  = 'ARTIKUJ'
--      Set @PWhere     = ' (A.KOD>=''P1'' AND A.KOD<=''P42'') '
--
--    --Rasti Liste Egzistuese 1. KLIENT
--      Set @PTableOrg  = 'KLIENTCMIMKL'
--      Set @PWhere     = ' A.NRD=2'
--
--    --Rasti Liste Egzistuese 1. ARTIKUJ / CMIME (Me ose Pa Cmime)
--      Set @PTableOrg  = 'KLIENTCMIMART'
--      Set @PWhere     = ' A.NRD=2'
--
--    --Rasti Liste Egzistuese 1. KLIENT, ARTIKUJ / CMIME (Me ose Pa Cmime)
--      Set @PTableOrg  = 'KLIENTCMIM'
--      Set @PWhere     = ' A.NRD=2'
--
--      Set @PNrDIns = 1
--      Set @POkCmim = 1
--


  if  @PWhere=''
      Set @PWhere = ' 1=1 '  

  Declare @Fields   Varchar(Max), 
          @FieldsAl Varchar(Max), 
          @Sql      Varchar(Max),
          @Sql0     Varchar(Max),
          @sNrDIns  Varchar(20),
          @TableOrg Varchar(30),
          @TableIns Varchar(30)

      Set @sNrDIns = Cast(@PNrDIns As Integer)

      Set @Sql     = ' INSERT INTO C_C_C_C 
                             (A_A_A_A,NRD,TAGNR)
                       SELECT A_A_A_A,NRD='+@sNrDIns+',TAGNR=A.NRRENDOR 
                         FROM B_B_B_B A
                        WHERE '+@PWhere+' AND 
                             (Not Exists (SELECT B.KOD 
                                            FROM C_C_C_C B 
                                           WHERE B.KOD=A.KOD AND B.NRD='+@sNrDIns+'))'
      Set @Sql0     = @Sql 
      Set @TableOrg = @PTableOrg
      Set @TableIns = ''

      if  Upper(@TableOrg) = 'KLIENT'
          Set   @TableIns  = 'KlientCmimKl'
      else
      if  Upper(@TableOrg) = 'ARTIKUJ'
          Set   @TableIns  = 'KlientCmimArt'

      Print @PTableOrg


      if  @TableIns<>''
          begin
            Set @Fields = dbo.Isd_ListFields2Tables(@TableOrg,@TableIns,'NRD,TAGNR,NRRENDOR,TROW') 
            Set @Sql    = Replace(@Sql0,'A_A_A_A',@Fields)
            Set @Sql    = Replace(@Sql,'B_B_B_B',@TableOrg)
            Set @Sql    = Replace(@Sql,'C_C_C_C',@TableIns)
            Exec (@Sql)
          end

      if  Upper(@PTableOrg)=Upper('KlientCmim') Or Upper(@PTableOrg)=Upper('KlientCmimKL')
          begin
            Set @TableOrg = 'KlientCmimKL'
            Set @TableIns = 'KlientCmimKL'
            Set @Fields = dbo.Isd_ListFields2Tables(@TableOrg,@TableIns,'NRD,TAGNR,NRRENDOR,TROW') 
            Set @Sql    = Replace(@Sql0,'A_A_A_A',@Fields)
            Set @Sql    = Replace(@Sql,'B_B_B_B',@TableOrg)
            Set @Sql    = Replace(@Sql,'C_C_C_C',@TableIns)
            Exec (@Sql)
            Exec ('  UPDATE '+@TableIns+' 
                        SET TAGNR=0 
                      WHERE ISNULL(TAGNR,0)<>0 ')
          end

      if  Upper(@PTableOrg)=Upper('KlientCmim') Or Upper(@PTableOrg)=Upper('KlientCmimArt')
          begin
            Set @TableOrg = 'KlientCmimArt'
            Set @TableIns = 'KlientCmimArt'
            Set @Fields = dbo.Isd_ListFields2Tables(@TableOrg,@TableIns,'NRD,TAGNR,NRRENDOR,TROW') 
            Set @Sql    = Replace(@Sql0,'A_A_A_A',@Fields)
            Set @Sql    = Replace(@Sql,'B_B_B_B',@TableOrg)
            Set @Sql    = Replace(@Sql,'C_C_C_C',@TableIns)
            Exec (@Sql)
            Print @Sql

            if  @POkCmim=1
                begin
                  Set @TableOrg = 'KlientCmimCM'
                  Set @TableIns = 'KlientCmimCM'
                  Set @Fields   = dbo.Isd_ListFields2Tables(@TableOrg,@TableIns,'NRD,TAGNR,NRRENDOR,TROW') 
                  Set @FieldsAl = dbo.Isd_ListFieldsAlias(@Fields,'B')

                  Set @Sql      = '  
                      INSERT INTO '+@TableIns+'
                            ('+@Fields+', NRD)  
                      SELECT '+@FieldsAl+', NRD=A.NRRENDOR 
                        FROM KlientCmimArt A Inner Join '+@TableOrg+' B On A.TAGNR=B.NRD
                       WHERE ISNULL(A.TAGNR,0)<>0 '
                  Print @Sql
                  Exec (@Sql)
                  Exec ('  UPDATE KlientCmimArt
                              SET TAGNR=0 
                            WHERE ISNULL(TAGNR,0)<>0 ')
                end
          end




GO
