SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[CheckLinkedServer] 
( 
  @ServerName  nText,
  @Ret         Int    Output
  )
  
AS

BEGIN


         SET NOCOUNT ON;
         

     DECLARE @RetVal         Int,       
             @SysServerName  SysName;
          -- @STAT1          Int;       -- Ku perdoret ????
            

         SET @RetVal = 0;
        

       BEGIN TRY
       
             SELECT @SysServerName = CONVERT(SysName, @ServerName);
               EXEC @RetVal = sys.sp_TestLinkedServer @SysServerName;
             SELECT @Ret = 1;
       END   TRY
       
       
       BEGIN CATCH
       
          SELECT @Ret = 0;
          
       END CATCH;      
    
    

      RETURN @Ret
      

END

GO
