SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE   PROCEDURE [dbo].[Isd_TestReferenceIsBlocked]
(
  @pReference   Varchar(50),
  @pKod         Varchar(60),
  @pUser        Varchar(20),
  @pActiv       Bit
 )

-- e blokuar quhet cdo reference qe nuk eshte ne DRHREFERENCE

AS
BEGIN

/*  Ne program ishte: 
  sSql := ''+
          'SELECT TOP 1 BLOK=CAST(1 AS BIT) '+
          '  FROM '+pReference+' A  INNER JOIN DRHREFERENCE B ON A.KOD=B.KOD '+
          ' WHERE B.KODUS    ='+QST(Perdorues)+' AND '+
          '       B.REFERENCE='+QST(pReference)+' AND '+
          '       A.KOD='+QST(pKod)+sWhere;
  Result := GetFieldValueC(pConnection,sSql,'BLOK','B')=False;
*/

--  EXEC dbo.Isd_TestReferenceIsBlocked 'MAGAZINA','D01','ADMIN',1

     DECLARE @sUser          Varchar(20),
             @sReference     Varchar(50),
             @sKod           Varchar(60),
             @bActiv         Bit,
             @bFldNotActiv   Bit,
             @bResult        Bit,
             @sSql           nVarchar(Max);

         SET @sUser        = @pUser;      -- 'ADMIN';
         SET @sReference   = @pReference; -- 'MAGAZINA';
         SET @sKod         = @pKod;       -- 'D05';
         SET @bActiv       = @pActiv;     -- 1;
         SET @bResult      = 0;
         SET @bFldNotActiv = 0;

         SET @sSql       = '
             IF  EXISTS ( 
                            SELECT 1
                              FROM '+@sReference+' A  INNER JOIN DRHREFERENCE B ON A.KOD=B.KOD 
                             WHERE B.KODUS = '+QuoteName(@sUser,'''')+' AND B.REFERENCE='+QuoteName(@sReference,'''')+' AND A.KOD='+QuoteName(@sKod,'''')+' AND 1=1 
                           )
                 BEGIN
                     SET @bResult = CAST(0 AS BIT)
                 END

             ELSE

                 BEGIN
                     SET @bResult = CAST(1 AS BIT)
                 END ';

      SELECT @bFldNotActiv = dbo.Isd_FieldTableExists(@sReference,'NOTACTIV');
 
         IF  @bActiv=1 And (@bFldNotActiv=1)
             BEGIN
               SET @sSql = Replace(@sSql,'1=1','ISNULL(NOTACTIV,0)=0');
             END;

        EXEC Sp_Executesql @sSql, N'@bResult Bit Output', @bResult OUTPUT;

	  SELECT BLOK = ISNULL(@bResult,0);

END
GO
