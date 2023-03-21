SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE       Procedure [dbo].[Isd_FieldsDescription]
(
  @PTable   Varchar(20),
  @PField   Varchar(20)
 )

As

-- Exec Dbo.Isd_Fieldsdescription @PTable='Bashki',@PField='KOD'
        Set NoCount On

     SELECT ObjectName   =o.Name,
            ObjectType   =o.Type,
            SchemaOwner  =s.Name,
            PropertyName =e.Name,
            PropertyValue=e.Value,
            ColumnName   =c.Name,
            Ordinal      =c.colid
       FROM Sys.Objects o Inner Join Sys.Extended_Properties e ON o.object_id = e.major_id
                          INNER Join sys.schemas s  ON o.schema_id = s.schema_id
                          Left  Join SysColumns c ON e.minor_id = c.colid AND e.major_id = c.id
      WHERE o.Type in ('V', 'U', 'P') and o.name=@PTable --and c.Name=@PField
   ORDER BY SchemaOwner,ObjectName, ObjectType, Ordinal
GO
