SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE PROC [dbo].[KerkoTeGjitha]
(
      @SearchStr As NVarChar(100),
      @TBL       As NVarChar(Max),
      @TBLTYPE   As NVarChar(100),
      @TmpTable  As VarChar(100)
)
As

Begin
      CREATE TABLE #Results (NRRENDOR int,
                             Tabela   NVarChar(100), 
                             Kolona   NVarChar(370), 
                             Vlera    NVarChar(3630),
                             POZICION  VarChar(10))

      Set NoCount ON

      Declare @TableName  NVarChar(256), 
              @ColumnName NVarChar(128), 
              @SearchStr2 NVarChar(110)

      Set  @TableName = ''
      Set  @SearchStr2 = QuoteName('%' + @SearchStr + '%','''')

      While @TableName IS NOT NULL
      Begin
            Set @ColumnName = ''
            Set @TableName = 
            (
                  Select MIN(QuoteName(TABLE_SCHEMA) + '.' + QuoteName(TABLE_NAME))
                    From INFORMATION_SCHEMA.TABLES
                   Where TABLE_NAME IN (Select SPLITET From DBO.SPLIT(@TBL,',')) AND TABLE_TYPE Like @TBLTYPE
                        AND   QuoteName(TABLE_SCHEMA) + '.' + QuoteName(TABLE_NAME) > @TableName
                        AND   OBJECTPROPERTY(
                                    OBJECT_ID(
                                          QuoteName(TABLE_SCHEMA) + '.' + QuoteName(TABLE_NAME)
                                          ), 'IsMSShipped'
                                           ) = 0
            )

            While (@TableName IS NOT NULL) AND (@ColumnName IS NOT NULL)
            Begin
                  Set @ColumnName =
                  (
                        Select MIN(QuoteName(COLUMN_NAME))
                        From INFORMATION_SCHEMA.COLUMNS
                        Where             TABLE_SCHEMA      = PARSENAME(@TableName, 2)
                              AND   TABLE_NAME  = PARSENAME(@TableName, 1)
                              AND   DATA_TYPE IN ('char', 'varchar', 'nchar', 'NVarChar')
                              AND   QuoteName(COLUMN_NAME) > @ColumnName
                  )
      
                  If @ColumnName IS NOT NULL
                     Declare @QR As NVarChar(4000);

                  if Dbo.Isd_FieldTableExists(@TableName,'NRRENDOR')=0
                        Set @QR = 'Select NRRENDOR=0,''' + @TableName + ''',''' + @ColumnName + ''', LEFT(' + @ColumnName + ', 3630),''M'' '+
                                  ' From ' + @TableName + ' (NoLock) ' +
                                  ' Where ' + @ColumnName + ' Like ' + @SearchStr2;
                  Else

                  If @TableName NOT Like '%SCR%'
                        Set @QR = 'Select NRRENDOR,''' + @TableName + ''',''' + @ColumnName + ''', LEFT(' + @ColumnName + ', 3630),''M'' '+
                                  ' From ' + @TableName + ' (NoLock) ' +
                                  ' Where ' + @ColumnName + ' Like ' + @SearchStr2;
                  Else
                        Set @QR = 'Select NRD,''' + @TableName + ''',''' + @ColumnName + ''', LEFT(' + @ColumnName + ', 3630),''D'' '+
                                  ' From ' + @TableName + ' (NoLock) ' +
                                  ' Where ' + @ColumnName + ' Like ' + @SearchStr2;                             
                  
                  Begin
                        Insert Into #Results
                        Exec
                        (
                                    @QR
                        )
                  End
            End   
      End

--      Print '  Insert Into '+@TmpTable+' (NrRendor,Tabela,Kolona, Vlera,Pozicion)
--                  Select NrRendor,Tabela,Kolona, Vlera, Pozicion    
--                    From   #Results '


      If (@TmpTable Is Not Null) and (@TmpTable<>'')

         Exec ('  Insert Into '+@TmpTable+' (NrRendor,Tabela,Kolona, Vlera,Pozicion)
                  Select NrRendor,Tabela,Kolona, Vlera, Pozicion    
                    From   #Results ')

      Else

         Begin   

           Select NrRendor,Tabela,Kolona, Vlera,Pozicion
             From   #Results

         End

End













GO
