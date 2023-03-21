SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   procedure [dbo].[Isd_FieldsImplicidValues]
(
  @pTableName    Varchar(100),
  @pList         Varchar(Max),
  @pOper         Varchar(10),
  @pTip          Varchar(30),
  @pPerdorues    Varchar(30)
)
AS



     Declare @sTableName    Varchar(100),
             @sPerdorues    Varchar(30),
             @sList1        Varchar(Max),
             @sList2        Varchar(Max),
             @sSql          Varchar(Max),
             @sTip          Varchar(30),
             @sOper         Varchar(10);

         SET @sTableName  = @pTableName;
--       SET @sList       = @pList;
         SET @sOper       = @pOper;
         SET @sTip        = @pTip;
         SET @sPerdorues  = @pPerdorues;
         SET @sList1      = '';
         SET @sList2      = '';

         IF  @sTip='REFIMPORT'
             BEGIN
               SET @sList1 = @pList;
               SET @sList2 = '';
             END;
         IF  @sTip='REFNOTEMPTY'
             BEGIN
               SET @sList1 = '';
               SET @sList2 = @pList;
             END;

         IF  @sOper='S' AND @sTip=''                -- Regjistrimi ne tabele i konfigurimit 
             BEGIN

               IF NOT EXISTS (SELECT * FROM CONFIG..TABLECONFIGS WHERE TABLENAME=@sTableName) 
                  BEGIN 

                      INSERT  CONFIG..TableConfigs 
                             (TABLENAME,FIELDSPREVIOUS,FIELDSNOTEMPTY,ACTIVFIELDSPRVS,ACTIVFIELDSNOTEMP,USI,USM)
                      VALUES (@sTableName,@sList1,@sList2,0,0,@sPerdorues,@sPerdorues)

                  END
                  
               RETURN;   
               
             END;


         IF  @sOper='S'                             -- Regjistrimi ne tabele i konfigurimit
             BEGIN

               IF NOT EXISTS (SELECT * FROM CONFIG..TABLECONFIGS WHERE TABLENAME=@sTableName) 
                  BEGIN 

                      INSERT  CONFIG..TableConfigs 
                             (TABLENAME,FIELDSPREVIOUS,FIELDSNOTEMPTY,ACTIVFIELDSPRVS,ACTIVFIELDSNOTEMP,USI,USM)
                      VALUES (@sTableName,@sList1,@sList2,0,0,@sPerdorues,@sPerdorues)

                  END

               ELSE

                  BEGIN
   
                      UPDATE CONFIG..TableConfigs 
                         SET FIELDSPREVIOUS = CASE WHEN @sTip='REFIMPORT'   THEN @sList1 ELSE FIELDSPREVIOUS END,
                             FIELDSNOTEMPTY = CASE WHEN @sTip='REFNOTEMPTY' THEN @sList2 ELSE FIELDSNOTEMPTY END,  
                             USM            = @sPerdorues,
                             DATEEDIT       = GETDATE() 
                       WHERE TABLENAME      = @sTableName;

                  END

               RETURN;

             END;




       IF  @sTableName='ARTIKUJ'
           SET @sList1 = 'TIP,TATIM,NEGST,NJESI,NJESB,NJESSH,MINI,MAKS,KLASIF,KLASIF2,KLASIF3,KLASIF4,KLASIF5,KODLM,KODTVSH,DEP,LIST'

       ELSE 
       IF  @sTableName='KLIENT'
           SET @sList1 = 'LLOGARI,DEP,LISTE,TATIM,GRUP,KATEGORI,VENDNDODHJE,RAJON,KLASIFIKIM1,KLASIFIKIM2,KLASIFIKIM3,MODPG,AFAT' -- KMAG,KMON,AGJENTSHITJE,

       ELSE 
       IF  @sTableName='FURNITOR'
           SET @sList1 = 'LLOGARI,DEP,LISTE,TATIM,GRUP,KATEGORI,VENDNDODHJE,RAJON,KLASIFIKIM1,KLASIFIKIM2,KLASIFIKIM3,MODPG,AFAT' -- KMAG,KMON,AGJENTSHITJE,

       ELSE 
       IF  @sTableName='AGJENTSHITJE'
           SET @sList1 = ''

       ELSE 
       IF  @sTableName='MAGAZINA'
           SET @sList1 = 'NIPT,NIPTCERTIFIKATE,DEP,LIST,ZONA,TELEFON1,GRUP,KLASIF,QELLIM'

       ELSE 
       IF  @sTableName='SHERBIM'
           SET @sList1 = 'LLOGSH,LLOGB,NJESI,TATIM,DEP,LISTE,KODTVSH,KLASIFIKIM,DSCNTKLA,DSCNTKLB,DSCNTKLC,DSCNTKLD'

       ELSE 
       IF  @sTableName='TATIM'
           SET @sList1 = 'TIP,PERQINDJE,LLOGARIDB,LLOGARIKR'

       ELSE 
       IF  @sTableName='ZBRITJE'
           SET @sList1 = 'MINI1,DISCNT1,MINI2,DISCNT2,MINI3,DISCNT3,MINI4,DISCNT4,LLOJI,RRUMBULL'

       ELSE 
       IF  @sTableName='TRANSPORT'
           SET @sList1 = 'MJET,TONAZH,SASINGARKIM,NJESINGARKIM,TELEFON1,TELEFON2,FAX,KOMPANI,ADRESA1,ADRESA2,ADRESA3,NIPT,NIPTCERTIFIKATE,NRLICENCE,KODFISKAL'

--LM
       ELSE 
       IF  @sTableName='ARKAT'
           SET @sList1 = 'KMON,LLOGARI,DEP,KLASIFIKIM,SHENIM1,SHENIM2'

       ELSE 
       IF  @sTableName='BANKAT'
           SET @sList1 = 'KMON,LLOGARI,DEP,KLASIFIKIM,SHENIM1,SHENIM2'

       ELSE 
       IF  @sTableName='DEPARTAMENT'
           SET @sList1 = ''
       ELSE 
       IF  @sTableName='LISTE'
           SET @sList1 = ''
       ELSE
       IF  @sTableName='SKEMELM'
           SET @sList1 = ''
       ELSE 
       IF  @sTableName='KLASATATIM'
           SET @sList1 = 'PERQINDJE,KLASIFIKIM,LLOGARIDB,LLOGARIKR';
      

         IF  @sOper='R'                 -- Leximi nga tabela i konfigurimit
             BEGIN

               IF NOT EXISTS (SELECT * FROM CONFIG..TABLECONFIGS WHERE TABLENAME=@sTableName) 
                  BEGIN 

                      INSERT  CONFIG..TableConfigs 
                             (TABLENAME,FIELDSPREVIOUS,FIELDSNOTEMPTY,ACTIVFIELDSPRVS,ACTIVFIELDSNOTEMP,USI,USM)
                      VALUES (@sTableName,@sList1,@sList2,CAST(0 AS BIT),CAST(0 AS BIT),@sPerdorues,@sPerdorues)

                  END

               ELSE

                  BEGIN
   
                      SELECT @sList1=FIELDSPREVIOUS,@sList2=FIELDSNOTEMPTY
                        FROM CONFIG..TableConfigs 
                       WHERE TABLENAME = @sTableName;

                  END

               SELECT FIELDSPREV   = FIELDSPREVIOUS,    -- FIELDSPREV=@sList1,FIELDSNOTEMP=@sList2
                      FIELDSNOTEMP = FIELDSNOTEMPTY,
                      ACTIVINS     = CAST(ACTIVFIELDSPRVS AS BIT),
                      ACTIVNOTEMP  = CAST(ACTIVFIELDSNOTEMP AS BIT)
                 FROM CONFIG..TableConfigs 
                WHERE TABLENAME = @sTableName;
               RETURN;

             END;


   


GO
