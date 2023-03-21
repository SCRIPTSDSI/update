SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE Function [dbo].[RemoveSpecialChars] 
(
 @s Varchar(256)
 ) 

Returns Varchar(256) With SchemaBinding

Begin


          If @s Is Null
             Return Null;
             
             
     Declare @s2   Varchar(256),
             @l    Int,
             @p    Int,
             @c    Int
             
         Set @s2 = '';
         Set @l  = len(@s);
         Set @p  = 1;



       While @p <= @l 
         Begin

           Set @c = Ascii(Substring(@s, @p, 1));

           If (@c Between 40 And 57) Or (@c Between 60 And 90) Or (@c Between 97 And 122) Or (@c In (32, 33))
              Set @s2 = @s2 + Char(@c);

           Set @p = @p + 1;

         end;
         
         
   If Len(@s2) = 0
      Return Null;
      
   Return @s2;
   
   
End
GO
