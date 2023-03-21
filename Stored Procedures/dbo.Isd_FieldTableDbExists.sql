SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--   Declare @Bit BIT;   Exec dbo.Isd_FieldTableDbExists 'CONFIG', 'ARTIKUJ', 'KOD', @Bit Output


CREATE         Procedure [dbo].[Isd_FieldTableDbExists] 
(
   @pDbName         Varchar(100),
   @pTableName      Varchar(100),
   @pFieldName      Varchar(100),
   @pBit            Bit Output

 )

As  

	  DECLARE @TableName     Varchar(100), 
              @dbName        Varchar(100), 
			  @FieldName     Varchar(100),
              @Bit           Bit,
			  @sSql         nVarchar(MAX),
              @Parameter    nVarchar(MAX); 


          SET @TableName   = ISNULL(@pTableName,''); 
          SET @dbName      = ISNULL(@pdbName,''); 
	      SET @FieldName   = ISNULL(@pFieldName,'');
          SET @Bit         = ISNULL(@pBit,0);
		  SET @Parameter   = '@Bit BIT OUTPUT';
		  

           IF NOT (EXISTS (Select 1 FROM Sys.databases WHERE [NAME]=@dbName))
		      BEGIN
			    SET @Bit = 0
			  END
          ELSE
		      BEGIN
                SET @sSQL        = '

	                USE '+@dbName+';
			  
	                IF  EXISTS (SELECT * FROM SYS.COLUMNS WHERE OBJECT_ID=OBJECT_ID('''+@TableName+''') AND [NAME]='''+@FieldName+''')
			            SET @Bit = 1
			        ELSE
			            SET @Bit = 0;';
				    
--                PRINT @sSql;

                EXECUTE sp_ExecuteSql @sSQL, @Parameter, @bit  OUTPUT;

	          END;

        SET @pBit       = @Bit;
  -- SELECT FieldExists = @pBit;
GO
