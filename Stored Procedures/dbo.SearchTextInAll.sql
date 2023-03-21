SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SearchTextInAll]       
(
  @StrFind AS VARCHAR(MAX)
 )
 
AS

BEGIN

    SET NOCOUNT ON; 
    
    -- TO FIND STRING IN ALL PROCEDURES        
    BEGIN
        SELECT OBJECT_NAME(OBJECT_ID) SP_Name,       OBJECT_DEFINITION(OBJECT_ID) SP_Definition
          FROM Sys.Procedures
         WHERE OBJECT_DEFINITION(OBJECT_ID) LIKE '%'+@StrFind+'%';
    END 

    -- TO FIND STRING IN ALL VIEWS        
    BEGIN
        SELECT OBJECT_NAME(OBJECT_ID) View_Name,     OBJECT_DEFINITION(OBJECT_ID) View_Definition
          FROM Sys.Views
         WHERE OBJECT_DEFINITION(OBJECT_ID) LIKE '%'+@StrFind+'%';
    END 

    -- TO FIND STRING IN ALL FUNCTION        
    BEGIN
        SELECT ROUTINE_NAME           Function_Name, ROUTINE_DEFINITION     Function_definition
          FROM INFORMATION_SCHEMA.ROUTINES
         WHERE ROUTINE_DEFINITION LIKE '%'+@StrFind+'%' AND ROUTINE_TYPE = 'FUNCTION'
      ORDER BY ROUTINE_NAME;
    END

    -- TO FIND STRING IN ALL COLUMNS OF TABLES OF DATABASE.    
    BEGIN
        SELECT T.Name      AS Table_Name,            C.Name      AS Column_Name
          FROM Sys.Tables  AS T INNER JOIN Sys.Columns C ON T.OBJECT_ID = C.OBJECT_ID
         WHERE C.Name LIKE '%'+@StrFind+'%'
      ORDER BY Table_Name;
    END
    
    -- TO FIND STRING IN ALL OBJECTS OF DATABASE.    
    BEGIN
        SELECT O.Name       AS Object_Name,          O.Type      AS Type_Name
          FROM Sys.Objects  AS O
         WHERE O.Name LIKE '%'+@StrFind+'%'
      ORDER BY [Object_Name];
    END

END
GO
