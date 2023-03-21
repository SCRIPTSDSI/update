SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[Split]
( @String As NVarChar(4000),
  @Char   As NVarChar(1)
)
Returns @RET Table (Splitet NVarChar(250) NULL)
As

-- Select *       FROM dbo.Split ('KODAF,PERSHKRIM,SASI,VLERABS,TATUESHEM,0,PERQZBR,0,0,NRDSHOQ,TIPFAT',',')
-- Select SPLITET From dbo.Split ('KODAF,PERSHKRIM,SASI,VLERABS,TATUESHEM,0,PERQZBR,0,0,NRDSHOQ,TIPFAT',',')

Begin

      While Len(@STRING)>0
      Begin
            If CharIndex(@CHAR,@STRING)>0
               Begin
                 Insert @RET 
                 Select LEFT(@STRING,CharIndex(@CHAR,@STRING)-1)

                 Set    @STRING = (Select SUBSTRING(@STRING,CharIndex(@CHAR,@STRING)+1,Len(@STRING)-CharIndex(@CHAR,@STRING)));
               End

            Else

               Begin
                 Insert @RET 
                 Select @STRING;
                 
                 Set    @STRING = '';
               End
      End
      Return;
End
GO
