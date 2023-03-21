SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   FUNCTION [dbo].[Isd_FieldDescription]
(
 @PTable   Varchar(20),
 @PField   Varchar(20)
)
Returns Varchar(100) 
--Select [dbo].Isd_FieldDescription('Bashki','KOD')
As

begin

  Declare @PropertyValue Varchar(100) 

  Set @PropertyValue = Convert(Varchar,
                       IsNull(
                       (SELECT PropertyValue=e.Value
                          FROM Sys.Objects o Inner Join Sys.Extended_Properties e ON o.object_id = e.major_id
                                             Inner Join sys.schemas s  ON o.schema_id = s.schema_id
                                             Left  Join SysColumns c ON e.minor_id = c.colid AND e.major_id = c.id
                         WHERE o.Type in ('V', 'U', 'P') and o.name=@PTable and c.Name=@PField),
                        ''))

  Return (Convert(Varchar,@PropertyValue))

end


GO
