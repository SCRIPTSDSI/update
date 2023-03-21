SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   FUNCTION [dbo].[Isd_ReferenceMeVeprim]
(
  @pTableName  VARCHAR(30),
  @pKod        VARCHAR(50)
)

RETURNS VARCHAR(200)

AS

BEGIN

-- Select [dbo].[Isd_ReferenceMeVeprim]('Liste','AM101z')

     DECLARE @Tip        VARCHAR(10),
             @Result     VARCHAR(150);

         SET @Result   = '';


--     Magazina

  IF UPPER(@pTableName)='MAGAZINA' AND (@Result='')
     BEGIN
       IF @Result='' AND (EXISTS ( SELECT 1 FROM LMG       WHERE SG1=@pKod ))
          SET @Result = dbo.Isd_TableDecription('LMG');
          
       IF @Result='' AND (EXISTS ( SELECT 1 FROM LM        WHERE SG4=@pKod ))
          SET @Result = dbo.Isd_TableDecription('LM');
     END;


--     Monedha

  IF UPPER(@pTableName)='MONEDHA' AND (@Result='')
     BEGIN
       IF @Result='' AND (EXISTS ( SELECT 1 FROM LAR       WHERE SG5=@pKod ))
          SET @Result = dbo.Isd_TableDecription('LAR');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM LBA       WHERE SG5=@pKod ))
          SET @Result = dbo.Isd_TableDecription('LBA');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM LKL       WHERE SG5=@pKod ))
          SET @Result = dbo.Isd_TableDecription('LKL');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM LFU       WHERE SG5=@pKod ))
          SET @Result = dbo.Isd_TableDecription('LFU');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM LM        WHERE SG5=@pKod ))
          SET @Result = dbo.Isd_TableDecription('LM');
     END;


--     Klient

  IF UPPER(@pTableName)='KLIENT' AND (@Result='')
     BEGIN
       IF @Result='' AND (EXISTS ( SELECT 1 FROM LKL       WHERE SG1=@pKod ))
          SET @Result = dbo.Isd_TableDecription('LKL');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM DKL       WHERE CASE WHEN CHARINDEX('.',KOD)>0 THEN LEFT(KOD,CHARINDEX('.',KOD)-1) ELSE KOD END=@pKod ))
          SET @Result = dbo.Isd_TableDecription('DKL');
     END;


--     Furnitor

  IF UPPER(@pTableName)='FURNITOR' AND (@Result='')
     BEGIN
       IF @Result='' AND (EXISTS ( SELECT 1 FROM LFU       WHERE SG1=@pKod ))
          SET @Result = dbo.Isd_TableDecription('LFU');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM DFU       WHERE CASE WHEN CHARINDEX('.',KOD)>0 THEN LEFT(KOD,CHARINDEX('.',KOD)-1) ELSE KOD END=@pKod ))
          SET @Result = dbo.Isd_TableDecription('DFU');
     END;

--     Arka

  IF (UPPER(@pTableName)='ARKA' OR UPPER(@pTableName)='ARKAT') AND (@Result='')
     BEGIN
       IF @Result='' AND (EXISTS ( SELECT 1 FROM LAR       WHERE SG1=@pKod ))
          SET @Result = dbo.Isd_TableDecription('LAR');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM DAR       WHERE CASE WHEN CHARINDEX('.',KOD)>0 THEN LEFT(KOD,CHARINDEX('.',KOD)-1) ELSE KOD END=@pKod ))
          SET @Result = dbo.Isd_TableDecription('DAR');
     END;


--     Banka

  IF (UPPER(@pTableName)='BANKA' OR  UPPER(@pTableName)='BANKAT') AND (@Result='')
     BEGIN
       IF @Result='' AND (EXISTS ( SELECT 1 FROM LBA       WHERE SG1=@pKod ))
          SET @Result = dbo.Isd_TableDecription('LBA');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM DBA       WHERE CASE WHEN CHARINDEX('.',KOD)>0 THEN LEFT(KOD,CHARINDEX('.',KOD)-1) ELSE KOD END=@pKod ))
          SET @Result = dbo.Isd_TableDecription('DBA');
     END;


--     Artikuj

  IF UPPER(@pTableName)='ARTIKUJ' AND (@Result='')
     BEGIN

          SET @Tip = 'K';

       IF @Result='' AND (EXISTS ( SELECT 1 FROM LMG       WHERE SG2=@pKod ))
          SET @Result = dbo.Isd_TableDecription('LMG');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM FHSCR     WHERE KARTLLG=@pKod ))
          SET @Result = dbo.Isd_TableDecription('FHSCR');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM FDSCR     WHERE KARTLLG=@pKod ))
          SET @Result = dbo.Isd_TableDecription('FDSCR');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM FFSCR     WHERE KARTLLG=@pKod AND TIPKLL=@Tip ))
          SET @Result = dbo.Isd_TableDecription('FFSCR');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM ORFSCR    WHERE KARTLLG=@pKod AND TIPKLL=@Tip ))
          SET @Result = dbo.Isd_TableDecription('ORFSCR');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM FJSCR     WHERE KARTLLG=@pKod AND TIPKLL=@Tip ))
          SET @Result = dbo.Isd_TableDecription('FJSCR');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM FJTSCR    WHERE KARTLLG=@pKod AND TIPKLL=@Tip ))
          SET @Result = dbo.Isd_TableDecription('FJTSCR');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM OFKSCR    WHERE KARTLLG=@pKod AND TIPKLL=@Tip ))
          SET @Result = dbo.Isd_TableDecription('OFKSCR');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM ORKSCR    WHERE KARTLLG=@pKod AND TIPKLL=@Tip ))
          SET @Result = dbo.Isd_TableDecription('ORKSCR');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM SMSCR     WHERE KARTLLG=@pKod AND TIPKLL=@Tip ))
          SET @Result = dbo.Isd_TableDecription('SMSCR');

     END;


--     Sherbim

  IF UPPER(@pTableName)='SHERBIM' AND (@Result='')
     BEGIN

          SET @Tip = 'R';

       IF @Result='' AND (EXISTS ( SELECT 1 FROM FFSCR     WHERE KARTLLG=@pKod AND TIPKLL=@Tip ))
          SET @Result = dbo.Isd_TableDecription('FFSCR');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM ORFSCR    WHERE KARTLLG=@pKod AND TIPKLL=@Tip ))
          SET @Result = dbo.Isd_TableDecription('ORFSCR');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM FJSCR     WHERE KARTLLG=@pKod AND TIPKLL=@Tip ))
          SET @Result = dbo.Isd_TableDecription('FJSCR');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM FJTSCR    WHERE KARTLLG=@pKod AND TIPKLL=@Tip ))
          SET @Result = dbo.Isd_TableDecription('FJTSCR');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM OFKSCR    WHERE KARTLLG=@pKod AND TIPKLL=@Tip ))
          SET @Result = dbo.Isd_TableDecription('OFKSCR');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM ORKSCR    WHERE KARTLLG=@pKod AND TIPKLL=@Tip ))
          SET @Result = dbo.Isd_TableDecription('ORKSCR');
           
       IF @Result='' AND (EXISTS ( SELECT 1 FROM SMSCR     WHERE KARTLLG=@pKod AND TIPKLL=@Tip ))
          SET @Result = dbo.Isd_TableDecription('SMSCR');

     END;


--     Tatim

 IF UPPER(@pTableName)='TATIM'  AND (@Result='')
     BEGIN
       IF @Result='' AND (EXISTS ( SELECT 1 FROM DGSCR     WHERE TATIM=@pKod ))
          SET @Result = dbo.Isd_TableDecription('DGSCR');
     END;


--     Zbritje

 IF UPPER(@pTableName)='ZBRITJE'  AND (@Result='')
     BEGIN
       IF @Result='' AND (EXISTS ( SELECT 1 FROM ARTIKUJ   WHERE DSCNTKLA=@pKod OR DSCNTKLB=@pKod OR DSCNTKLC=@pKod OR DSCNTKLD=@pKod ))
          SET @Result = dbo.Isd_TableDecription('ARTIKUJ');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM SHERBIM   WHERE DSCNTKLA=@pKod OR DSCNTKLB=@pKod OR DSCNTKLC=@pKod OR DSCNTKLD=@pKod ))
          SET @Result = dbo.Isd_TableDecription('SHERBIM');
     END;


--     Llogari

  IF UPPER(@pTableName)='LLOGARI' AND (@Result='')
     BEGIN

          SET @Tip = 'L';

       IF @Result='' AND (EXISTS ( SELECT 1 FROM LM        WHERE SG1=@pKod ))
          SET @Result = dbo.Isd_TableDecription('LM');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM SKEMELM   WHERE LLOGINV=@pKod OR NDRGJEND=@pKod OR LLOGB=@pKod OR LLOGSH=@pKod OR LLOGSHPZ01=@pKod ))
          SET @Result = dbo.Isd_TableDecription('SKEMELM');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM ARKAT     WHERE LLOGARI=@pKod ))
          SET @Result = dbo.Isd_TableDecription('ARKAT');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM BANKAT    WHERE LLOGARI=@pKod ))
          SET @Result = dbo.Isd_TableDecription('BANKAT');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM KLIENT    WHERE LLOGARI=@pKod ))
          SET @Result = dbo.Isd_TableDecription('KLIENT');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM FURNITOR  WHERE LLOGARI=@pKod ))
          SET @Result = dbo.Isd_TableDecription('FURNITOR');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM FFSCR     WHERE KARTLLG=@pKod AND TIPKLL=@Tip ))
          SET @Result = dbo.Isd_TableDecription('FFSCR');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM ORFSCR    WHERE KARTLLG=@pKod AND TIPKLL=@Tip ))
          SET @Result = dbo.Isd_TableDecription('ORFSCR');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM FJSCR     WHERE KARTLLG=@pKod AND TIPKLL=@Tip ))
          SET @Result = dbo.Isd_TableDecription('FJSCR');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM FJTSCR    WHERE KARTLLG=@pKod AND TIPKLL=@Tip ))
          SET @Result = dbo.Isd_TableDecription('FJTSCR');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM OFKSCR    WHERE KARTLLG=@pKod AND TIPKLL=@Tip ))
          SET @Result = dbo.Isd_TableDecription('OFKSCR');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM ORKSCR    WHERE KARTLLG=@pKod AND TIPKLL=@Tip ))
          SET @Result = dbo.Isd_TableDecription('ORKSCR');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM SMSCR     WHERE KARTLLG=@pKod AND TIPKLL=@Tip ))
          SET @Result = dbo.Isd_TableDecription('SMSCR');
     END;


--     Departament

  IF UPPER(@pTableName)='DEPARTAMENT' AND (@Result='')
     BEGIN

       IF @Result='' AND (EXISTS ( SELECT 1 FROM LM        WHERE SG2=@pKod))
          SET @Result = dbo.Isd_TableDecription('LM');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM LMG       WHERE SG3=@pKod))
          SET @Result = dbo.Isd_TableDecription('LMG');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM ARKAT     WHERE DEP=@pKod))
          SET @Result = dbo.Isd_TableDecription('ARKAT');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM BANKAT    WHERE DEP=@pKod))
          SET @Result = dbo.Isd_TableDecription('BANKAT');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM KLIENT    WHERE DEP=@pKod))
          SET @Result = dbo.Isd_TableDecription('KLIENT');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM FURNITOR  WHERE DEP=@pKod))
          SET @Result = dbo.Isd_TableDecription('FURNITOR');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM ARTIKUJ   WHERE DEP=@pKod))
          SET @Result = dbo.Isd_TableDecription('ARTIKUJ');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM MAGAZINA  WHERE DEP=@pKod))
          SET @Result = dbo.Isd_TableDecription('MAGAZINA');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM SHERBIM   WHERE DEP=@pKod))
          SET @Result = dbo.Isd_TableDecription('SHERBIM');

     END;


--     Liste

  IF UPPER(@pTableName)='LISTE' AND (@Result='')
     BEGIN

       IF @Result='' AND (EXISTS ( SELECT 1 FROM LM        WHERE SG3=@pKod))
          SET @Result = dbo.Isd_TableDecription('LM');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM LMG       WHERE SG4=@pKod))
          SET @Result = dbo.Isd_TableDecription('LMG');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM ARKAT     WHERE LISTE=@pKod))
          SET @Result = dbo.Isd_TableDecription('ARKAT');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM BANKAT    WHERE LISTE=@pKod))
          SET @Result = dbo.Isd_TableDecription('BANKAT');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM KLIENT    WHERE LISTE=@pKod))
          SET @Result = dbo.Isd_TableDecription('KLIENT');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM FURNITOR  WHERE LISTE=@pKod))
          SET @Result = dbo.Isd_TableDecription('FURNITOR');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM ARTIKUJ   WHERE LIST=@pKod))
          SET @Result = dbo.Isd_TableDecription('ARTIKUJ');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM MAGAZINA  WHERE LIST=@pKod))
          SET @Result = dbo.Isd_TableDecription('MAGAZINA');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM SHERBIM   WHERE LISTE=@pKod))
          SET @Result = dbo.Isd_TableDecription('SHERBIM');

     END;
     

--     Njesi

  IF UPPER(@pTableName)='NJESI' AND (@Result='')
     BEGIN
       IF @Result='' AND (EXISTS ( SELECT 1 FROM ARTIKUJ   WHERE NJESI=@pKod OR NJESB=@pKod OR NJESSH=@pKod ))
          SET @Result = dbo.Isd_TableDecription('ARTIKUJ');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM SHERBIM   WHERE NJESI=@pKod ))
          SET @Result = dbo.Isd_TableDecription('SHERBIM');
     END;


--     Kase

  IF UPPER(@pTableName)='KASE' AND (@Result='')
     BEGIN
       IF @Result='' AND (EXISTS ( SELECT 1 FROM SM        WHERE KASE=@pKod ))
          SET @Result = dbo.Isd_TableDecription('SM');
     END;


--     AgjentShitje

  IF UPPER(@pTableName)='AGJENTSHITJE' AND (@Result='')
     BEGIN
       IF @Result='' AND (EXISTS ( SELECT 1 FROM KLIENT    WHERE AGJENTSHITJE=@pKod ))
          SET @Result = dbo.Isd_TableDecription('KLIENT');
     END;


--     VendNdodhje

  IF UPPER(@pTableName)='VENDNDODHJE' AND (@Result='')
     BEGIN
       IF @Result='' AND (EXISTS ( SELECT 1 FROM KLIENT    WHERE VENDNDODHJE=@pKod ))
          SET @Result = dbo.Isd_TableDecription('KLIENT');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM FURNITOR  WHERE VENDNDODHJE=@pKod ))
          SET @Result = dbo.Isd_TableDecription('FURNITOR');
     END;


--     Rajon

  IF UPPER(@pTableName)='RAJON' AND (@Result='')
     BEGIN
       IF @Result='' AND (EXISTS ( SELECT 1 FROM KLIENT    WHERE RAJON=@pKod ))
          SET @Result = dbo.Isd_TableDecription('KLIENT');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM FURNITOR  WHERE RAJON=@pKod ))
          SET @Result = dbo.Isd_TableDecription('FURNITOR');
     END;


--     Kategori

  IF UPPER(@pTableName)='KATEGORI' AND (@Result='')
     BEGIN
       IF @Result='' AND (EXISTS ( SELECT 1 FROM KLIENT    WHERE KATEGORI=@pKod ))
          SET @Result = dbo.Isd_TableDecription('KLIENT');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM FURNITOR  WHERE KATEGORI=@pKod ))
          SET @Result = dbo.Isd_TableDecription('FURNITOR');
     END;


--     SkemeLM

  IF UPPER(@pTableName)='SKEMELM' AND (@Result='')
     BEGIN
       IF @Result='' AND (EXISTS ( SELECT 1 FROM ARTIKUJ   WHERE KODLM=@pKod ))
          SET @Result = dbo.Isd_TableDecription('ARTIKUJ');
     END;


--     Kartele Aseti

  IF UPPER(@pTableName)='AQKARTELA' AND (@Result='')
     BEGIN

          SET @Tip = 'X';

       IF @Result='' AND (EXISTS ( SELECT 1 FROM LAQ       WHERE SG1=@pKod ))
          SET @Result = dbo.Isd_TableDecription('LAQ');
          
       IF @Result='' AND (EXISTS ( SELECT 1 FROM AQSCR     WHERE KARTLLG=@pKod ))
          SET @Result = dbo.Isd_TableDecription('AQSCR');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM FFSCR     WHERE KARTLLG=@pKod AND TIPKLL=@Tip ))
          SET @Result = dbo.Isd_TableDecription('FFSCR');

       IF @Result='' AND (EXISTS ( SELECT 1 FROM FJSCR     WHERE KARTLLG=@pKod AND TIPKLL=@Tip ))
          SET @Result = dbo.Isd_TableDecription('FJSCR');

     END


--     AQSkemeLM

  IF UPPER(@pTableName)='AQSKEMELM' AND (@Result='')
     BEGIN
       IF @Result='' AND (EXISTS ( SELECT 1 FROM AQKARTELA WHERE KODLM=@pKod ))
          SET @Result = dbo.Isd_TableDecription('AQKARTELA');
     END;



  IF @Result<>''
     SET @Result = '  '+@pKod+' / Veprime '+@Result;

  RETURN @Result;
  

END;

GO
