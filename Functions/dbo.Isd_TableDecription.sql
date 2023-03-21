SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   FUNCTION [dbo].[Isd_TableDecription]
( 
 @PTableName Varchar(50)
 )
Returns Varchar(Max)

AS

Begin

-- Select AA=dbo.Isd_TableDecription('VS')

     Declare @Result     Varchar(Max),
             @TableStr   Varchar(10);

         Set @Result   = '';
         Set @TableStr = '';
    
      Select @Result   = A.PERSHKRIM,
             @TableStr = A.TABLESTR
        From CONFIG..TABLESNAME A 
       Where TABLENAME = @PTableName;

         if  @TableStr='REF'
             Set @Result = 'Reference: ' + IsNull(@Result,'')
         else
         if  @TableStr='DOC'
             Set @Result = 'Dokument: '  + IsNull(@Result,'')
         else
         if  CharIndex(@PTableName,'LAR,LBA,LKL,LFU,LM,LMG,LAQ')>0
             Set @Result = 'Liber: ' + @PTableName
         else
         if  CharIndex(@PTableName,'DAR,DBA,DKL,DFU')>0
             Set @Result = 'Ditar: ' + @PTableName
         else
         if  CharIndex(@PTableName,'CONFND,CONFIGLM,CONFIGMG')>0
             Set @Result = 'Konfigurim: ' + @PTableName
         else
             Set @Result = 'Tabela: '+ @PTableName;


      Return @Result;


End


GO
