SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
            
                                                   
CREATE Procedure [dbo].[Isd_xStartNewVersion]                                     
As                         
             
     Declare @OkEx       Bit,  
             @sSql       nVarchar(Max),                    
             @sSql1      nVarchar(Max),                  
             @sSql2      nVarchar(Max),
             @sKlase     Varchar(100),
			 @Bit        Bit,
			 @NrRendor   Int,
			 @sdbname    Varchar(100); 

         Set @OkEx     = 0;
         Set @sSql     = '';      
 
         Set NoCount on;



     Declare @updLastDt  DateTime,
             @stpLastDt  DateTime;

      Select @stpLastDt=ModiFy_Date 
        From Sys.Procedures
       Where Object_Id=Object_Id('Isd_xStartNewVersion');

          if dbo.Isd_FieldTableExists('CONFND','LASTDTUPD')=0
             begin
               ALTER TABLE CONFND ADD LASTDTUPD DateTime
               Print 'Shtim fusha LASTDTUPD ne CONFND: DateTime'
             end;

         Set @sSql = 'SELECT @updLastDt=LASTDTUPD FROM CONFND;';
     Execute sp_ExecuteSql @sSql, N'@updLastDt DateTime Out',@updLastDt Output;

         Set @updLastDt = IsNull(@updLastDt,@stpLastDt-1);

    -- Print Convert(Varchar(10),@stpLastDt,103)
    -- Print Convert(Varchar(8), @updLastDt,108);
       Print 'stp modified   :    date '+Convert(Varchar(11),@stpLastDt,104) + ',  ora '+ Convert(Varchar(8),@stpLastDt,108);
       Print 'update database:    date '+Convert(Varchar(11),@UpdLastDt,104) + ',  ora '+ Convert(Varchar(8),@UpdLastDt,108);

        if (DATEDIFF(Day,@UpdLastDt,@stpLastDt)<0) Or
           (DATEDIFF(Day,@UpdLastDt,@stpLastDt)=0 And DATEDIFF(Minute,@UpdLastDt,@stpLastDt)<0) Or
           (DATEDIFF(Day,@UpdLastDt,@stpLastDt)=0 And DATEDIFF(Minute,@UpdLastDt,@stpLastDt)=0  And DATEDIFF(Second,@UpdLastDt,@stpLastDt)<0)
--        if @UpdLastDt<=@stpLastDt
             begin
               Print 'Strukture e te dhenave konform versionit.  / '+db_Name()+' /';

               Exec [dbo].[Isd_InicTablePromoc];

               Return;
             end;




      UPDATE CONFND SET LASTDTUPD=GetDate()
       Print '
      Pergatitje Strukture te te dhenave konform versionit. / '+db_Name()+' /
             ';




     Declare @TablesList    Varchar(2000),
	         @FieldsList    Varchar(2000),
             @TableName     Varchar(50),
             @sFieldName    Varchar(30),
             @sFieldName2   Varchar(30),
             @sString       Varchar(50),
             @Size          Int,
             @Tip           Varchar(30),
             @i             Int,
             @j             Int,
             @k             Int;




-- CfgLM --

   if dbo.Isd_FieldTableExists('CONFIGLM','SERIAUTARK')=0
      begin
        ALTER TABLE CONFIGLM ADD SERIAUTARK Int;
        Print 'Shtim fusha SERIAUTARK ne CONFIGLM: Integer';
      end;
   if dbo.Isd_FieldTableExists('CONFIGLM','NRDIGISERI')=0
      begin
        ALTER TABLE CONFIGLM ADD NRDIGISERI Int;
      --Exec ('UPDATE CONFIGLM SET NRDIGISERI=8 ')
        Print 'Shtim fusha NRDIGISERI ne CONFIGLM: Integer';
      end;
   if dbo.Isd_FieldTableExists('CONFIGLM','NRDOKAUTBANK')=0
      begin
        ALTER TABLE CONFIGLM ADD NRDOKAUTBANK Int;
        Print 'Shtim fusha NRDOKAUTBANK ne CONFIGLM: Integer';
      end;
   if dbo.Isd_FieldTableExists('CONFIGLM','KALIMFHLMDEPLIST')=0
      begin
        ALTER TABLE CONFIGLM ADD KALIMFHLMDEPLIST Bit
        Print 'Shtim fusha KALIMFHLMDEPLIST ne CONFIGLM: Bit'
      end
   if dbo.Isd_FieldTableExists('CONFIGLM','KALIMFDLMDEPLIST')=0
      begin
        ALTER TABLE CONFIGLM ADD KALIMFDLMDEPLIST Bit
        Print 'Shtim fusha KALIMFDLMDEPLIST ne CONFIGLM: Bit'
      end
   if dbo.Isd_FieldTableExists('CONFIGLM','KALIMFFLMDEPLIST')=0
      begin
        ALTER TABLE CONFIGLM ADD KALIMFFLMDEPLIST Bit
        Print 'Shtim fusha KALIMFFLMDEPLIST ne CONFIGLM: Bit'
      end
   if dbo.Isd_FieldTableExists('CONFIGLM','KALIMFJLMDEPLIST')=0
      begin
        ALTER TABLE CONFIGLM ADD KALIMFJLMDEPLIST Bit Null
        Print 'Shtim fusha KALIMFJLMDEPLIST ne CONFIGLM: Bit'
      end
   if dbo.Isd_FieldTableExists('CONFIGLM','KLDEPLISTNGAREF')=0
      begin
        ALTER TABLE CONFIGLM ADD KLDEPLISTNGAREF Bit Null
        Print 'Shtim fusha KLDEPLISTNGAREF ne CONFIGLM: Bit'
      end
   if dbo.Isd_FieldTableExists('CONFIGLM','FUDEPLISTNGAREF')=0
      begin
        ALTER TABLE CONFIGLM ADD FUDEPLISTNGAREF Bit Null
        Print 'Shtim fusha FUDEPLISTNGAREF ne CONFIGLM: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGLM','DEPLISTNGAART')=0
      begin
        ALTER TABLE CONFIGLM ADD DEPLISTNGAART Bit Null
        Print 'Shtim fusha DEPLISTNGAART ne CONFIGLM: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGLM','DEPLISTNGASHERB')=0
      begin
        ALTER TABLE CONFIGLM ADD DEPLISTNGASHERB Bit Null
        Print 'Shtim fusha DEPLISTNGASHERB ne CONFIGLM: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGLM','DEPLISTNGAAQKART')=0
      begin
        ALTER TABLE CONFIGLM ADD DEPLISTNGAAQKART Bit Null
        Print 'Shtim fusha DEPLISTNGAAQKART ne CONFIGLM: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGLM','LLOGPRMCFJ')=0
      begin
        ALTER TABLE CONFIGLM ADD LLOGPRMCFJ Int
        Print 'Shtim fusha LLOGPRMCFJ ne CONFIGLM: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('CONFIGLM','LLOGPRMCFF')=0
      begin
        ALTER TABLE CONFIGLM ADD LLOGPRMCFF Int
        Print 'Shtim fusha LLOGPRMCFF ne CONFIGLM: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('CONFIGLM','IMPORTKODND')=0
      begin
        ALTER TABLE CONFIGLM ADD IMPORTKODND Varchar(30)
        Print 'Shtim fusha IMPORTKODND ne CONFIGLM: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('CONFIGLM','DUBLSCR')=0
      begin
        ALTER TABLE CONFIGLM ADD DUBLSCR Bit
        Print 'Shtim fusha DUBLSCR ne CONFIGLM: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGLM','DUBLSCRANL')=0
      begin
        ALTER TABLE CONFIGLM ADD DUBLSCRANL Bit
        Print 'Shtim fusha DUBLSCRANL ne CONFIGLM: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGLM','DUBLSCRBLK')=0
      begin
        ALTER TABLE CONFIGLM ADD DUBLSCRBLK Bit
        Print 'Shtim fusha DUBLSCRBLK ne CONFIGLM: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGLM','KALIMARLMDEPLIST')=0
      begin
        ALTER TABLE CONFIGLM ADD KALIMARLMDEPLIST Bit
        Print 'Shtim fusha KALIMARLMDEPLIST ne CONFIGLM: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGLM','KALIMBALMDEPLIST')=0
      begin
        ALTER TABLE CONFIGLM ADD KALIMBALMDEPLIST Bit
        Print 'Shtim fusha KALIMBALMDEPLIST ne CONFIGLM: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGLM','KALIMABLM67DEPLIST')=0
      begin
        ALTER TABLE CONFIGLM ADD KALIMABLM67DEPLIST Bit
        Print 'Shtim fusha KALIMABLM67DEPLIST ne CONFIGLM: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGLM','ROWDIFFDEBIKREDI')=0
      begin
        ALTER TABLE CONFIGLM ADD ROWDIFFDEBIKREDI VARCHAR(5)
        Print 'Shtim fusha ROWDIFFDEBIKREDI ne CONFIGLM: VARCHAR(5)'
      end;
   if dbo.Isd_FieldTableExists('CONFIGLM','ORDERNRAQ')=0
      begin
        ALTER TABLE CONFIGLM ADD ORDERNRAQ Bit NULL
        Print 'Shtim fusha ORDERNRAQ ne CONFIGLM: bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGLM','ACTIVDTAQ')=0
      begin
        ALTER TABLE CONFIGLM ADD ACTIVDTAQ Bit NULL 
        Print 'Shtim fusha ACTIVDTAQ ne CONFIGLM: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGLM','LISTEGRIDSHORTC')=0
      begin
        ALTER TABLE CONFIGLM ADD LISTEGRIDSHORTC Varchar(1000) NULL 
        Print 'Shtim fusha LISTEGRIDSHORTC ne CONFIGLM: Varchar(1000)'
      end;
   if dbo.Isd_FieldTableExists('CONFIGLM','APLIKOKURSHIST')=0
      begin
        ALTER TABLE CONFIGLM ADD APLIKOKURSHIST Bit NULL 
        Print 'Shtim fusha APLIKOKURSHIST ne CONFIGLM: bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGLM','BLOKDOKARKEZERO')=0
      begin
        ALTER TABLE CONFIGLM ADD BLOKDOKARKEZERO Bit NULL 
        Print 'Shtim fusha BLOKDOKARKEZERO ne CONFIGLM: bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGLM','BLOKDOKBANKEZERO')=0
      begin
        ALTER TABLE CONFIGLM ADD BLOKDOKBANKEZERO Bit NULL 
        Print 'Shtim fusha BLOKDOKBANKEZERO ne CONFIGLM: bit'
      end;


-- ConfigUS
     
   if dbo.Isd_FieldTableExists('CONFIGUS','XCOLOR')=0
      begin
        ALTER TABLE CONFIGUS ADD XCOLOR Int;
      --Exec ('UPDATE CONFIGLM SET NRDIGISERI=8 ')
        Print 'Shtim fusha XCOLOR ne CONFIGUS: Integer';
      end;
      
   if dbo.Isd_FieldTableExists('CONFIGUS','XCOLORACT')=0
      begin
        ALTER TABLE CONFIGUS ADD XCOLORACT Bit;
        Print 'Shtim fusha XCOLORACT ne CONFIGUS: Bit';
      end;

-- Mg --

   if dbo.Isd_FieldTableExists('MAGAZINA','LIST')=0
      begin
        ALTER TABLE MAGAZINA ADD LIST VARCHAR(30) NULL
        Print 'Shtim fusha LIST ne MAGAZINA: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('MAGAZINA','KLIENTKASE')=0
      begin
        ALTER TABLE MAGAZINA ADD KLIENTKASE VARCHAR(30) NULL
        Print 'Shtim fusha KLIENTKASE ne MAGAZINA: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('MAGAZINA','NRPRODUKTKP')=0
      begin
        ALTER TABLE MAGAZINA ADD NRPRODUKTKP Int NULL
        Print 'Shtim fusha NRPRODUKTKP ne MAGAZINA: Int'
      end;
   if dbo.Isd_FieldTableExists('MAGAZINA','NRPRODUKTKS')=0
      begin
        ALTER TABLE MAGAZINA ADD NRPRODUKTKS Int NULL
        Print 'Shtim fusha NRPRODUKTKS ne MAGAZINA: Int'
      end;
   if dbo.Isd_FieldTableExists('MAGAZINA','ISDOGANE')=0
      begin
        ALTER TABLE MAGAZINA ADD ISDOGANE Bit NULL
        Print 'Shtim fusha ISDOGANE ne MAGAZINA: Bit'
      end;
   if dbo.Isd_FieldTableExists('MAGAZINA','NRPERSONEL')=0
      begin
        ALTER TABLE MAGAZINA ADD NRPERSONEL Int NULL
        Print 'Shtim fusha NRPERSONEL ne MAGAZINA: Int'
      end;
   if dbo.Isd_FieldTableExists('MAGAZINA','NJESIADMIN')=0
      begin
        ALTER TABLE MAGAZINA ADD NJESIADMIN Varchar(10) NULL
        Print 'Shtim fusha NJESIADMIN ne MAGAZINA: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('MAGAZINA','FISOBJECT')=0
      begin
        ALTER TABLE MAGAZINA ADD FISOBJECT VARCHAR(20) NULL
        Print 'Shtim fusha FISOBJECT ne MAGAZINA: Varchar(20)'
      end;
   if dbo.Isd_FieldTableExists('MAGAZINA','FISBUSINESSUNIT')=0
      begin
        ALTER TABLE MAGAZINA ADD FISBUSINESSUNIT VARCHAR(50) NULL
        Print 'Shtim fusha FISBUSINESSUNIT ne MAGAZINA: Varchar(50)'
      end;


-- TATIM --

   if dbo.Isd_FieldTableExists('TATIM','DEP')=0
      begin
        ALTER TABLE TATIM ADD DEP VARCHAR(30) NULL
        Print 'Shtim fusha DEP ne TATIM: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('TATIM','LIST')=0
      begin
        ALTER TABLE TATIM ADD LIST VARCHAR(30) NULL
        Print 'Shtim fusha LIST ne TATIM: Varchar(30)'
      end

-- Dt --

   if dbo.Isd_FieldTableExists('DAR','NRRENDORDOK')=0
      begin
        ALTER TABLE DAR ADD NRRENDORDOK BigInt NULL
        Print 'Shtim fusha NRRENDORDOK ne DAR: BigInt'
          Set @OkEx = 1;
      end;
   if dbo.Isd_FieldTableExists('DBA','NRRENDORDOK')=0
      begin
        ALTER TABLE DBA ADD NRRENDORDOK BigInt NULL
        Print 'Shtim fusha NRRENDORDOK ne DBA: BigInt'
          Set @OkEx = 1;
      end;
   if dbo.Isd_FieldTableExists('DKL','NRRENDORDOK')=0
      begin
        ALTER TABLE DKL ADD NRRENDORDOK BigInt NULL
        Print 'Shtim fusha NRRENDORDOK ne DKL: BigInt'
          Set @OkEx = 1;
      end;
   if dbo.Isd_FieldTableExists('DFU','NRRENDORDOK')=0
      begin
        ALTER TABLE DFU ADD NRRENDORDOK BigInt NULL
        Print 'Shtim fusha NRRENDORDOK ne DFU: BigInt'
          Set @OkEx = 1;
      end;

   if dbo.Isd_FieldTableExists('DAR','TIPKLL')=0
      begin
        ALTER TABLE DAR ADD TIPKLL Varchar(5) NULL
        Print 'Shtim fusha TIPKLL ne DBA: Varchar(5)'
          Set @OkEx = 1;
      end;
   if dbo.Isd_FieldTableExists('DBA','TIPKLL')=0
      begin
        ALTER TABLE DBA ADD TIPKLL Varchar(5) NULL
        Print 'Shtim fusha TIPKLL ne DBA: Varchar(5)'
          Set @OkEx = 1;
      end;
   if dbo.Isd_FieldTableExists('DKL','TIPKLL')=0
      begin
        ALTER TABLE DKL ADD TIPKLL Varchar(5) NULL
        Print 'Shtim fusha TIPKLL ne DKL: Varchar(5)'
          Set @OkEx = 1;
      end;
   if dbo.Isd_FieldTableExists('DFU','TIPKLL')=0
      begin
        ALTER TABLE DFU ADD TIPKLL Varchar(5) NULL
        Print 'Shtim fusha TIPKLL ne DFU: Varchar(5)'
          Set @OkEx = 1;
      end;

   if @OkEx=1
      begin
        Exec dbo.Isd_UpdateIdDitar;
        Set  @OkEx = 0;
      end;


   if dbo.Isd_FieldTableExists('DAR','TRANNUMBER')=0
      begin
        ALTER TABLE DAR ADD TRANNUMBER Varchar(30) NULL
        Print 'Shtim fusha TRANNUMBER ne DAR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('DBA','TRANNUMBER')=0
      begin
        ALTER TABLE DBA ADD TRANNUMBER Varchar(30) NULL
        Print 'Shtim fusha TRANNUMBER ne DBA: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('DKL','TRANNUMBER')=0
      begin
        ALTER TABLE DKL ADD TRANNUMBER Varchar(30) NULL
        Print 'Shtim fusha TRANNUMBER ne DKL: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('DFU','TRANNUMBER')=0
      begin
        ALTER TABLE DFU ADD TRANNUMBER Varchar(30) NULL
        Print 'Shtim fusha TRANNUMBER ne DFU: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FK','TRANNUMBER')=0
      begin
        ALTER TABLE FK ADD TRANNUMBER Varchar(30) NULL
        Print 'Shtim fusha TRANNUMBER ne FK: Varchar(30)'
      end;

   if (Select character_maximum_length   
         From information_schema.columns  
        Where Table_Name = 'DKL' And Column_name='TIPFAT') <=2
      begin
        ALTER TABLE DKL ALTER COLUMN TIPFAT Varchar(10) Null;
        Print 'Update fusha TIPFAT ne DKL: Varchar(10)'
      end;
   if (Select character_maximum_length   
         From information_schema.columns  
        Where Table_Name = 'DFU' And Column_name='TIPFAT') <=2
      begin
        ALTER TABLE DFU ALTER COLUMN TIPFAT Varchar(10) Null;
        Print 'Update fusha TIPFAT ne DFU: Varchar(10)'
      end;
   if (Select character_maximum_length   
         From information_schema.columns  
        Where Table_Name = 'DAR' And Column_name='TIPFAT') <=2
      begin
        ALTER TABLE DAR ALTER COLUMN TIPFAT Varchar(10) Null;
        Print 'Update fusha TIPFAT ne DAR: Varchar(10)'
      end;
   if (Select character_maximum_length   
         From information_schema.columns  
        Where Table_Name = 'DBA' And Column_name='TIPFAT') <=2
      begin
        ALTER TABLE DBA ALTER COLUMN TIPFAT Varchar(10) Null;
        Print 'Update fusha TIPFAT ne DBA: Varchar(10)'
      end;

    SET @sSql1 = '

   if (Select Data_Type   
         From information_schema.columns  
        Where Table_Name = ''DKL'' And Column_name=''NRDOK'')=''INT''
      begin
        ALTER TABLE DKL ALTER COLUMN NRDOK BigInt Null;
        Print ''Update fusha NRDOK ne DKL: BigInt''
      end; 
   if (Select Data_Type   
         From information_schema.columns  
        Where Table_Name = ''DKL'' And Column_name=''NRDITAR'')=''INT''
      begin
        ALTER TABLE DKL ALTER COLUMN NRDITAR BigInt Null;
        Print ''Update fusha NRDITAR ne DKL: BigInt''
      end;       
   if (Select Data_Type   
         From information_schema.columns  
        Where Table_Name = ''DKL'' And Column_name=''NRLIBER'')=''INT''
      begin
        ALTER TABLE DKL ALTER COLUMN NRLIBER BigInt Null;
        Print ''Update fusha NRLIBER ne DKL: BigInt''
      end;
   --if (Select Data_Type   
   --      From information_schema.columns  
   --     Where Table_Name = ''DKL'' And Column_name=''NRRENDORDOK'')=''INT''
   --   begin
   --     ALTER TABLE DKL ALTER COLUMN NRRENDORDOK BigInt Null;
   --     Print ''Update fusha NRRENDORDOK ne DKL: BigInt''
   --   end;
      ';

    Exec (@sSql1);
    
    Set   @sSql2 = @sSql1;
    
    Set   @sSql1 = Replace(Replace(@sSql2,'''DKL''','''DFU'''),' DKL',' DFU');
    Exec (@sSql1);

    Set   @sSql1 = Replace(Replace(@sSql2,'''DKL''','''DAR'''),' DKL',' DAR');
    Exec (@sSql1);

    Set   @sSql1 = Replace(Replace(@sSql2,'''DKL''','''DBA'''),' DKL',' DBA');
    Exec (@sSql1);



-- AGJENTSHITJE --

   if dbo.Isd_FieldTableExists('AGJENTSHITJE','KODMASTER')=0
      begin
        ALTER TABLE AGJENTSHITJE ADD KODMASTER Varchar(30) NULL
        Print 'Shtim fusha KODMASTER ne AGJENTSHITJE: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('AGJENTSHITJE','DEP')=0
      begin
        ALTER TABLE AGJENTSHITJE ADD DEP VARCHAR(30) NULL
        Print 'Shtim fusha DEP ne AGJENTSHITJE: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('AGJENTSHITJE','LISTE')=0
      begin
        ALTER TABLE AGJENTSHITJE ADD LISTE VARCHAR(30) NULL
        Print 'Shtim fusha LISTE ne AGJENTSHITJM: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('AGJENTSHITJE','KOEFICENTART')=0
      begin
        ALTER TABLE AGJENTSHITJE ADD KOEFICENTART Float NULL
        Print 'Shtim fusha KOEFICENTART ne AGJENTSHITJM: Float'
      end;
   if dbo.Isd_FieldTableExists('AGJENTSHITJE','APLVLPATVSH')=0
      begin
        ALTER TABLE AGJENTSHITJE ADD APLVLPATVSH Bit
        Print 'Shtim fusha APLVLPATVSH ne AGJENTSHITJE: Bit'
      end
   if dbo.Isd_FieldTableExists('AGJENTSHITJE','APLARTIKUJKTG')=0
      begin
        ALTER TABLE AGJENTSHITJE ADD APLARTIKUJKTG Varchar(60) NULL
        Print 'Shtim fusha APLARTIKUJKTG ne AGJENTSHITJE: Varchar(60)'
      end;
      
--KOEFICENT

-- ARTIKUJFIR --

   if dbo.Isd_FieldTableExists('ARTIKUJFIR','KOEFICENTE')=0
      begin
        ALTER TABLE ARTIKUJFIR ADD KOEFICENTE Float NULL
        Print 'Shtim fusha KOEFICENTE ne ARTIKUJFIR: Float'
      end
   if dbo.Isd_FieldTableExists('ARTIKUJFIR','KOEFICENTF')=0
      begin
        ALTER TABLE ARTIKUJFIR ADD KOEFICENTF Float NULL
        Print 'Shtim fusha KOEFICENTF ne ARTIKUJFIR: Float'
      end
   if dbo.Isd_FieldTableExists('ARTIKUJFIR','KOEFICENTG')=0
      begin
        ALTER TABLE ARTIKUJFIR ADD KOEFICENTG Float NULL
        Print 'Shtim fusha KOEFICENTG ne ARTIKUJFIR: Float'
      end
   if dbo.Isd_FieldTableExists('ARTIKUJFIR','KOEFICENTH')=0
      begin
        ALTER TABLE ARTIKUJFIR ADD KOEFICENTH Float NULL
        Print 'Shtim fusha KOEFICENTH ne ARTIKUJFIR: Float'
      end
   if dbo.Isd_FieldTableExists('ARTIKUJFIR','KOEFICENTI')=0
      begin
        ALTER TABLE ARTIKUJFIR ADD KOEFICENTI Float NULL
        Print 'Shtim fusha KOEFICENTI ne ARTIKUJFIR: Float'
      end
   if dbo.Isd_FieldTableExists('ARTIKUJFIR','KOEFICENTJ')=0
      begin
        ALTER TABLE ARTIKUJFIR ADD KOEFICENTJ Float NULL
        Print 'Shtim fusha KOEFICENTJ ne ARTIKUJFIR: Float'
      end


   if dbo.Isd_FieldTableExists('ARTIKUJFIR','LLOGARIE')=0
      begin
        ALTER TABLE ARTIKUJFIR ADD LLOGARIE varchar (30) NULL
        Print 'Shtim fusha LLOGARIE ne ARTIKUJFIR: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('ARTIKUJFIR','LLOGARIF')=0
      begin
        ALTER TABLE ARTIKUJFIR ADD LLOGARIF varchar (30) NULL
        Print 'Shtim fusha LLOGARIF ne ARTIKUJFIR: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('ARTIKUJFIR','LLOGARIG')=0
      begin
        ALTER TABLE ARTIKUJFIR ADD LLOGARIG varchar (30) NULL
        Print 'Shtim fusha LLOGARIG ne ARTIKUJFIR: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('ARTIKUJFIR','LLOGARIH')=0
      begin
        ALTER TABLE ARTIKUJFIR ADD LLOGARIH varchar (30) NULL
        Print 'Shtim fusha LLOGARIH ne ARTIKUJFIR: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('ARTIKUJFIR','LLOGARII')=0
      begin
        ALTER TABLE ARTIKUJFIR ADD LLOGARII varchar (30) NULL
        Print 'Shtim fusha LLOGARII ne ARTIKUJFIR: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('ARTIKUJFIR','LLOGARIJ')=0
      begin
        ALTER TABLE ARTIKUJFIR ADD LLOGARIJ Varchar (30) NULL
        Print 'Shtim fusha LLOGARIJ ne ARTIKUJFIR: Varchar(30)'
      end;


-- ARTIKUJBCSCR
   if dbo.Isd_FieldTableExists('ARTIKUJBCSCR','MASE')=0
      begin
        ALTER TABLE ARTIKUJBCSCR ADD MASE Varchar(10) NULL 
        Print 'Shtim fusha MASE ne ARTIKUJBCSCR: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJBCSCR','NGJYRE')=0
      begin
        ALTER TABLE ARTIKUJBCSCR ADD NGJYRE Varchar(10) NULL 
        Print 'Shtim fusha NGJYRE ne ARTIKUJBCSCR: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJBCSCR','PERIMETER')=0
      begin
        ALTER TABLE ARTIKUJBCSCR ADD PERIMETER Varchar(10) NULL 
        Print 'Shtim fusha PERIMETER ne ARTIKUJBCSCR: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJBCSCR','CMSH')=0
      begin
        ALTER TABLE ARTIKUJBCSCR ADD CMSH Float NULL 
        Print 'Shtim fusha CMSH ne ARTIKUJBCSCR: Float';
        Exec ('
        UPDATE A SET A.CMSH=B.CMSH FROM ArtikujBcScr A INNER JOIN Artikuj B ON A.BC=B.BC        WHERE ISNULL(A.BC,'''')<>'''' AND ISNULL(A.CMSH,0)=0;
        UPDATE A SET A.CmSh=B.CmSH FROM ArtikujBcScr A INNER JOIN Artikuj B ON A.NRD=B.NRRENDOR WHERE ISNULL(A.NRD,0)<>0      AND ISNULL(A.CMSH,0)=0;
        PRINT ''Update fushen CMSH ne ArtikjBcScr me ate CMSH te karteles Artikuj''; ');
      end;

-- KLIENT
   if dbo.Isd_FieldTableExists('KLIENT','KREDIOVERBLOCK')=0
      begin
        ALTER TABLE KLIENT ADD KREDIOVERBLOCK Bit NULL
        Print 'Shtim fusha KREDIOVERBLOCK ne KLIENT: Bit'
      end;
   if dbo.Isd_FieldTableExists('KLIENT','KREDIMODBLOCK')=0
      begin
        ALTER TABLE KLIENT ADD KREDIMODBLOCK Int NULL
        Print 'Shtim fusha KREDIMODBLOCK ne KLIENT: Int'
      end;
   if dbo.Isd_FieldTableExists('KLIENT','KREDIWARNING')=0
      begin
        ALTER TABLE KLIENT ADD KREDIWARNING Float NULL
        Print 'Shtim fusha KREDIWARNING ne KLIENT: Float'
      end;
   if dbo.Isd_FieldTableExists('KLIENT','KODHISTORIK')=0
      begin
        ALTER TABLE KLIENT ADD KODHISTORIK Varchar(60) NULL
        Print 'Shtim fusha KODHISTORIK ne KLIENT: Varchar(60)'
      end;
   if dbo.Isd_FieldTableExists('KLIENT','KLASIFIKIM4')=0
      begin
        ALTER TABLE KLIENT ADD KLASIFIKIM4 Varchar(60) NULL
        Print 'Shtim fusha KLASIFIKIM4 ne KLIENT: Varchar(60)'
      end;
   if dbo.Isd_FieldTableExists('KLIENT','KLASIFIKIM5')=0
      begin
        ALTER TABLE KLIENT ADD KLASIFIKIM5 Varchar(60) NULL
        Print 'Shtim fusha KLASIFIKIM5 ne KLIENT: Varchar(60)'
      end;
   if dbo.Isd_FieldTableExists('KLIENT','KLASIFIKIM6')=0
      begin
        ALTER TABLE KLIENT ADD KLASIFIKIM6 Varchar(60) NULL
        Print 'Shtim fusha KLASIFIKIM6 ne KLIENT: Varchar(60)'
      end;
   if dbo.Isd_FieldTableExists('KLIENT','APLARTIKUJKTG')=0
      begin
        ALTER TABLE KLIENT ADD APLARTIKUJKTG Bit NULL
        Print 'Shtim fusha APLARTIKUJKTG ne KLIENT: Bit'
      end;
   if dbo.Isd_FieldTableExists('KLIENT','TIPNIPT')=0
      begin
        ALTER TABLE KLIENT ADD TIPNIPT Varchar(10) NULL
        Print 'Shtim fusha TIPNIPT ne KLIENT: Varchar(10)'
      end;


-- if dbo.Isd_FieldTableExists('KLIENT','CREATEFT')=0
--    begin
--      ALTER TABLE KLIENT ADD CREATEFT Int NULL
--      Print 'Shtim fusha CREATEFT ne KLIENT: Int'
--    end;
-- Perdoret per te testuar ne se duhet faturuar nje klient sipas konfigurimit:
-- KLIENT.CREATEFT: integer    0 - pa kufizim, 1 - vetem ata me oferte  2 - jo jashte ofertes etj. (3 mundesi)
-- perdoren Fusha: CREATEFT tek KLIENT
-- perdoren funksionet: Sales_PriceKlientArtikull dhe Sales_PriceOferteExists
-- ne program procedura TestKlientCreateDoc qe hidhet tek SysF5Sql.GetArtikuj

-- FURNITOR
   if dbo.Isd_FieldTableExists('FURNITOR','KODHISTORIK')=0
      begin
        ALTER TABLE FURNITOR ADD KODHISTORIK Varchar(60) NULL
        Print 'Shtim fusha KODHISTORIK ne FURNITOR: Varchar(60)'
      end;
   if dbo.Isd_FieldTableExists('FURNITOR','KLASIFIKIM4')=0
      begin
        ALTER TABLE FURNITOR ADD KLASIFIKIM4 Varchar(60) NULL
        Print 'Shtim fusha KLASIFIKIM4 ne FURNITOR: Varchar(60)'
      end;
   if dbo.Isd_FieldTableExists('FURNITOR','KLASIFIKIM5')=0
      begin
        ALTER TABLE FURNITOR ADD KLASIFIKIM5 Varchar(60) NULL
        Print 'Shtim fusha KLASIFIKIM5 ne FURNITOR: Varchar(60)'
      end;
   if dbo.Isd_FieldTableExists('FURNITOR','KLASIFIKIM6')=0
      begin
        ALTER TABLE FURNITOR ADD KLASIFIKIM6 Varchar(60) NULL
        Print 'Shtim fusha KLASIFIKIM6 ne FURNITOR: Varchar(60)'
      end;
   if dbo.Isd_FieldTableExists('FURNITOR','PRODUCTMANAGER')=0
      begin
        ALTER TABLE FURNITOR ADD PRODUCTMANAGER Varchar(60) NULL
        Print 'Shtim fusha PRODUCTMANAGER ne FURNITOR: Varchar(60)'
      end;   
   if dbo.Isd_FieldTableExists('FURNITOR','TIPNIPT')=0
      begin
        ALTER TABLE FURNITOR ADD TIPNIPT Varchar(10) NULL
        Print 'Shtim fusha TIPNIPT ne FURNITOR: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('FURNITOR','ACTIVCM')=0
      begin
        ALTER TABLE FURNITOR ADD ACTIVCM Bit NULL
        Print 'Shtim fusha ACTIVCM ne FURNITOR: Bit'
      end;

-- SHERBIM
   if dbo.Isd_FieldTableExists('SHERBIM','KODTVSH')=0
      begin
        ALTER TABLE SHERBIM ADD KODTVSH Varchar(30) NULL
        Print 'Shtim fusha KODTVSH ne SHERBIM: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('SHERBIM','LLOGB')=0
      begin
        ALTER TABLE SHERBIM ADD LLOGB Varchar(30) NULL
        Print 'Shtim fusha LLOGB ne SHERBIM: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('SHERBIM','CMB')=0
      begin
        ALTER TABLE SHERBIM ADD CMB Float NULL
        Print 'Shtim fusha CMB ne SHERBIM: Float'
      end;


-- DEPARTAMENT
   if dbo.Isd_FieldTableExists('DEPARTAMENT','KLASIFIKIM1')=0
      begin
        ALTER TABLE DEPARTAMENT ADD KLASIFIKIM1 Varchar(30) NULL
        Print 'Shtim fusha KLASIFIKIM1 ne DEPARTAMENT: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('DEPARTAMENT','KLASIFIKIM2')=0
      begin
        ALTER TABLE DEPARTAMENT ADD KLASIFIKIM2 Varchar(30) NULL
        Print 'Shtim fusha KLASIFIKIM2 ne DEPARTAMENT: Varchar(30)'
      end;


-- LISTE
   if dbo.Isd_FieldTableExists('LISTE','KLASIFIKIM1')=0
      begin
        ALTER TABLE LISTE ADD KLASIFIKIM1 Varchar(30) NULL
        Print 'Shtim fusha KLASIFIKIM1 ne LISTE: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('LISTE','KLASIFIKIM2')=0
      begin
        ALTER TABLE LISTE ADD KLASIFIKIM2 Varchar(30) NULL
        Print 'Shtim fusha KLASIFIKIM2 ne LISTE: Varchar(30)'
      end;


-- LLOGARI
   if dbo.Isd_FieldTableExists('LLOGARI','KODSUP')=0
      begin
        Exec (' ALTER TABLE LLOGARI ADD KODSUP VARCHAR(30) NULL
                Print ''Shtim fusha KODSUP ne LLOGARI: Varchar(30)'' ')
        Exec (' UPDATE LLOGARI SET KODSUP=ORIGJINA 
                UPDATE LLOGARI SET KODSUP=''0'' WHERE KODSUP=''$$$'' OR KODSUP='''' ')
      end;

-- LLOGARIRR
   if dbo.Isd_FieldTableExists('LLOGARIRR','KLASIFIKIM1')=0
      begin
        ALTER TABLE LLOGARIRR ADD KLASIFIKIM1 Varchar(30) NULL
        Print 'Shtim fusha KLASIFIKIM1 ne LLOGARIRR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('LLOGARIRR','KLASIFIKIM2')=0
      begin
        ALTER TABLE LLOGARIRR ADD KLASIFIKIM2 Varchar(30) NULL
        Print 'Shtim fusha KLASIFIKIM2 ne LLOGARIRR: Varchar(30)'
      end;


-- CONFIGMG --
      
   if dbo.Isd_FieldTableExists('CONFIGMG','KLS5PROMPT')=0
      begin
        ALTER TABLE CONFIGMG ADD KLS5PROMPT varchar (30) NULL
        Print 'Shtim fusha KLS5PROMPT ne CONFIGMG: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','KLS6PROMPT')=0
      begin
        ALTER TABLE CONFIGMG ADD KLS6PROMPT varchar (30) NULL
        Print 'Shtim fusha KLS6PROMPT ne CONFIGMG: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','KLS7PROMPT')=0
      begin
        ALTER TABLE CONFIGMG ADD KLS7PROMPT varchar (30) NULL
        Print 'Shtim fusha KLS7PROMPT ne CONFIGMG: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','KLS8PROMPT')=0
      begin
        ALTER TABLE CONFIGMG ADD KLS8PROMPT varchar (30) NULL
        Print 'Shtim fusha KLS8PROMPT ne CONFIGMG: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('CONFIGMG','KLS9PROMPT')=0
      begin
        ALTER TABLE CONFIGMG ADD KLS9PROMPT varchar (30) NULL
        Print 'Shtim fusha KLS9PROMPT ne CONFIGMG: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('CONFIGMG','KLS10PROMPT')=0
      begin
        ALTER TABLE CONFIGMG ADD KLS10PROMPT varchar (30) NULL
        Print 'Shtim fusha KLS10PROMPT ne CONFIGMG: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('CONFIGMG','FIRAPROMPT')=0
      begin
        ALTER TABLE CONFIGMG ADD FIRAPROMPT varchar (30) NULL
        Print 'Shtim fusha FIRAPROMPT ne CONFIGMG: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('CONFIGMG','FIRBPROMPT')=0
      begin
        ALTER TABLE CONFIGMG ADD FIRBPROMPT varchar (30) NULL
        Print 'Shtim fusha FIRBPROMPT ne CONFIGMG: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('CONFIGMG','FIRCPROMPT')=0
      begin
        ALTER TABLE CONFIGMG ADD FIRCPROMPT varchar (30) NULL
        Print 'Shtim fusha FIRCPROMPT ne CONFIGMG: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('CONFIGMG','FIRDPROMPT')=0
      begin
        ALTER TABLE CONFIGMG ADD FIRDPROMPT varchar (30) NULL
        Print 'Shtim fusha FIRDPROMPT ne CONFIGMG: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('CONFIGMG','FIREPROMPT')=0
      begin
        ALTER TABLE CONFIGMG ADD FIREPROMPT varchar (30) NULL
        Print 'Shtim fusha FIREPROMPT ne CONFIGMG: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('CONFIGMG','FIRFPROMPT')=0
      begin
        ALTER TABLE CONFIGMG ADD FIRFPROMPT varchar (30) NULL
        Print 'Shtim fusha FIRFPROMPT ne CONFIGMG: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('CONFIGMG','FIRGPROMPT')=0
      begin
        ALTER TABLE CONFIGMG ADD FIRGPROMPT varchar (30) NULL
        Print 'Shtim fusha FIRGPROMPT ne CONFIGMG: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('CONFIGMG','FIRHPROMPT')=0
      begin
        ALTER TABLE CONFIGMG ADD FIRHPROMPT varchar (30) NULL
        Print 'Shtim fusha FIRHPROMPT ne CONFIGMG: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('CONFIGMG','FIRIPROMPT')=0
      begin
        ALTER TABLE CONFIGMG ADD FIRIPROMPT varchar (30) NULL
        Print 'Shtim fusha FIRIPROMPT ne CONFIGMG: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('CONFIGMG','FIRJPROMPT')=0
      begin
        ALTER TABLE CONFIGMG ADD FIRJPROMPT varchar (30) NULL
        Print 'Shtim fusha FIRJPROMPT ne CONFIGMG: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('CONFIGMG','CASHPGFULLFJ')=0
      begin
        ALTER TABLE CONFIGMG ADD CASHPGFULLFJ Bit NULL
        Print 'Shtim fusha CASHPGFULLFJ ne CONFIGMG: Bit'
      end
   if dbo.Isd_FieldTableExists('CONFIGMG','CASHPGFULLFF')=0
      begin
        ALTER TABLE CONFIGMG ADD CASHPGFULLFF Bit NULL
        Print 'Shtim fusha CASHPGFULLFF ne CONFIGMG: Bit'
      end
   if dbo.Isd_FieldTableExists('CONFIGMG','TIPEFIROFH')=0
      begin
        ALTER TABLE CONFIGMG ADD TIPEFIROFH varchar (100) NULL
        Print 'Shtim fusha TIPEFIROFH ne CONFIGMG: Varchar(100)'
      end
   if dbo.Isd_FieldTableExists('CONFIGMG','TIPEFIROFD')=0
      begin
        ALTER TABLE CONFIGMG ADD TIPEFIROFD varchar (100) NULL
        Print 'Shtim fusha TIPEFIROFD ne CONFIGMG: Varchar(100)'
      end
   if dbo.Isd_FieldTableExists('CONFIGMG','TIPEFIROACTIV')=0
      begin
        ALTER TABLE CONFIGMG ADD TIPEFIROACTIV bit NULL
        Print 'Shtim fusha TIPEFIROACTIV ne CONFIGMG: bit'
      end
   if dbo.Isd_FieldTableExists('CONFIGMG','KASEACTIV')=0
      begin
        ALTER TABLE CONFIGMG ADD KASEACTIV bit NULL
        Print 'Shtim fusha KASEACTIV ne CONFIGMG: bit'
      end
   if dbo.Isd_FieldTableExists('CONFIGMG','KASEDIRECT')=0
      begin
        ALTER TABLE CONFIGMG ADD KASEDIRECT bit NULL
        Print 'Shtim fusha KASEDIRECT ne CONFIGMG: bit'
      end
   if dbo.Isd_FieldTableExists('CONFIGMG','TESTSASIGJLIM')=0
      begin
        ALTER TABLE CONFIGMG ADD TESTSASIGJLIM Int NULL
        Print 'Shtim fusha TESTSASIGJLIM ne CONFIGMG: Int'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','ACTIVFJLIKUJDIM')=0
      begin
        ALTER TABLE CONFIGMG ADD ACTIVFJLIKUJDIM Bit NULL
        Print 'Shtim fusha ACTIVFJLIKUJDIM ne CONFIGMG: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','PESHOREVLEREBC')=0
      begin
        ALTER TABLE CONFIGMG ADD PESHOREVLEREBC Bit NULL
        Print 'Shtim fusha PESHOREVLEREBC ne CONFIGMG: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','PESHOREDECIMAL')=0
      begin
        ALTER TABLE CONFIGMG ADD PESHOREDECIMAL Int NULL
        Print 'Shtim fusha PESHOREDECIMAL ne CONFIGMG: Int'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','INICKOLIFJ')=0
      begin
        ALTER TABLE CONFIGMG ADD INICKOLIFJ Float NULL
        Print 'Shtim fusha INICKOLIFJ ne CONFIGMG: Float'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','KASEVL1KUPTAT')=0
      begin
        ALTER TABLE CONFIGMG ADD KASEVL1KUPTAT Float NULL
        Print 'Shtim fusha KASEVL1KUPTAT ne CONFIGMG: Float'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','KASEVL2KUPTAT')=0
      begin
        ALTER TABLE CONFIGMG ADD KASEVL2KUPTAT Float NULL
        Print 'Shtim fusha KASEVL2KUPTAT ne CONFIGMG: Float'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','KASEVL1FATTAT')=0
      begin
        ALTER TABLE CONFIGMG ADD KASEVL1FATTAT Float NULL
        Print 'Shtim fusha KASEVL1FATTAT ne CONFIGMG: Float'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','KASEVL2FATTAT')=0
      begin
        ALTER TABLE CONFIGMG ADD KASEVL2FATTAT Float NULL
        Print 'Shtim fusha KASEVL2FATTAT ne CONFIGMG: Float'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','KLS1STATUS')=0
      begin
        ALTER TABLE CONFIGMG ADD KLS1STATUS Int NULL
        Print 'Shtim fusha KLS1STATUS ne CONFIGMG: Int'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','KLS2STATUS')=0
      begin
        ALTER TABLE CONFIGMG ADD KLS2STATUS Int NULL
        Print 'Shtim fusha KLS2STATUS ne CONFIGMG: Int'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','KLS3STATUS')=0
      begin
        ALTER TABLE CONFIGMG ADD KLS3STATUS Int NULL
        Print 'Shtim fusha KLS3STATUS ne CONFIGMG: Int'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','KLS4STATUS')=0
      begin
        ALTER TABLE CONFIGMG ADD KLS4STATUS Int NULL
        Print 'Shtim fusha KLS4STATUS ne CONFIGMG: Int'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','KLS5STATUS')=0
      begin
        ALTER TABLE CONFIGMG ADD KLS5STATUS Int NULL
        Print 'Shtim fusha KLS5STATUS ne CONFIGMG: Int'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','KLS6STATUS')=0
      begin
        ALTER TABLE CONFIGMG ADD KLS6STATUS Int NULL
        Print 'Shtim fusha KLS6STATUS ne CONFIGMG: Int'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','KLS7STATUS')=0
      begin
        ALTER TABLE CONFIGMG ADD KLS7STATUS Int NULL
        Print 'Shtim fusha KLS7STATUS ne CONFIGMG: Int'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','KLS8STATUS')=0
      begin
        ALTER TABLE CONFIGMG ADD KLS8STATUS Int NULL
        Print 'Shtim fusha KLS8STATUS ne CONFIGMG: Int'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','KLS9STATUS')=0
      begin
        ALTER TABLE CONFIGMG ADD KLS9STATUS Int NULL
        Print 'Shtim fusha KLS9STATUS ne CONFIGMG: Int'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','KLS10STATUS')=0
      begin
        ALTER TABLE CONFIGMG ADD KLS10STATUS Int NULL
        Print 'Shtim fusha KLS10STATUS ne CONFIGMG: Int'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','BLOCKKLIENTDOC')=0
      begin
        ALTER TABLE CONFIGMG ADD BLOCKKLIENTDOC Bit NULL
        Print 'Shtim fusha BLOCKKLIENTDOC ne CONFIGMG: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','BLOCKKLIENTFJT')=0
      begin
        ALTER TABLE CONFIGMG ADD BLOCKKLIENTFJT Bit NULL
        Print 'Shtim fusha BLOCKKLIENTFJT ne CONFIGMG: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','CMSHTVSH')=0
      begin
        ALTER TABLE CONFIGMG ADD CMSHTVSH Bit NULL
        Print 'Shtim fusha CMSHTVSH ne CONFIGMG: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','SMAPLTVSH')=0
      begin
        ALTER TABLE CONFIGMG ADD SMAPLTVSH Bit NULL
        Print 'Shtim fusha SMAPLTVSH ne CONFIGMG: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','SMPRINTGRUP')=0
      begin
        ALTER TABLE CONFIGMG ADD SMPRINTGRUP Bit NULL
        Print 'Shtim fusha SMPRINTGRUP ne CONFIGMG: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','SMLEDDISPL')=0
      begin
        ALTER TABLE CONFIGMG ADD SMLEDDISPL Bit NULL
        Print 'Shtim fusha SMLEDDISPL ne CONFIGMG: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','GRIDKODCLICK')=0
      begin
        ALTER TABLE CONFIGMG ADD GRIDKODCLICK Int NULL
        Print 'Shtim fusha GRIDKODCLICK ne CONFIGMG: Int'
        Exec ('UPDATE CONFIGMG SET GRIDKODCLICK=0');
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','GETROWSASIEXTRA')=0
      begin
        ALTER TABLE CONFIGMG ADD GETROWSASIEXTRA Bit NULL
        Print 'Shtim fusha GETROWSASIEXTRA ne CONFIGMG: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','SMIMPANALITIK')=0
      begin
        ALTER TABLE CONFIGMG ADD SMIMPANALITIK Bit NULL
        Print 'Shtim fusha SMIMPANALITIK ne CONFIGMG: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','BCFROMKOD')=0
      begin
        ALTER TABLE CONFIGMG ADD BCFROMKOD Bit NULL
        Print 'Shtim fusha BCFROMKOD ne CONFIGMG: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','NRLINKAPL1ACTIV')=0
      begin
        ALTER TABLE CONFIGMG ADD NRLINKAPL1ACTIV Bit NULL 
        Print 'Shtim fusha NRLINKAPL1ACTIV ne CONFIGMG: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','SHENIM3IMP')=0
      begin
        ALTER TABLE CONFIGMG ADD SHENIM3IMP Int NULL 
        Print 'Shtim fusha SHENIM3IMP ne CONFIGMG: Int'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','SERIALFJTEST')=0
      begin
        ALTER TABLE CONFIGMG ADD SERIALFJTEST bit NULL 
        Print 'Shtim fusha SERIALFJTEST ne CONFIGMG: bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','SERIALFJEMPTY')=0
      begin
        ALTER TABLE CONFIGMG ADD SERIALFJEMPTY bit NULL 
        Print 'Shtim fusha SERIALFJEMPTY ne CONFIGMG: bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','SERIALFJBLOCK')=0
      begin
        ALTER TABLE CONFIGMG ADD SERIALFJBLOCK Int NULL 
        Print 'Shtim fusha SERIALFJBLOCK ne CONFIGMG: Int'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','SERIALFFTEST')=0
      begin
        ALTER TABLE CONFIGMG ADD SERIALFFTEST bit NULL 
        Print 'Shtim fusha SERIALFFTEST ne CONFIGMG: bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','SERIALFFEMPTY')=0
      begin
        ALTER TABLE CONFIGMG ADD SERIALFFEMPTY bit NULL 
        Print 'Shtim fusha SERIALFFEMPTY ne CONFIGMG: bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','SERIALFFBLOCK')=0
      begin
        ALTER TABLE CONFIGMG ADD SERIALFFBLOCK Int NULL 
        Print 'Shtim fusha SERIALFFBLOCK ne CONFIGMG: Int'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','NRSERIALNRFD')=0
      begin
        ALTER TABLE CONFIGMG ADD NRSERIALNRFD bit NULL
        Print 'Shtim fusha NRSERIALNRFD ne CONFIGMG: bit'
      end
   if dbo.Isd_FieldTableExists('CONFIGMG','NRSERIALNRFH')=0
      begin
        ALTER TABLE CONFIGMG ADD NRSERIALNRFH bit NULL
        Print 'Shtim fusha NRSERIALNRFH ne CONFIGMG: bit'
      end
   if dbo.Isd_FieldTableExists('CONFIGMG','NRSERIALNRFF')=0
      begin
        ALTER TABLE CONFIGMG ADD NRSERIALNRFF bit NULL
        Print 'Shtim fusha NRSERIALNRFF ne CONFIGMG: bit'
      end
   if dbo.Isd_FieldTableExists('CONFIGMG','SERIALFDTEST')=0
      begin
        ALTER TABLE CONFIGMG ADD SERIALFDTEST bit NULL 
        Print 'Shtim fusha SERIALFDTEST ne CONFIGMG: bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','SERIALFDEMPTY')=0
      begin
        ALTER TABLE CONFIGMG ADD SERIALFDEMPTY bit NULL 
        Print 'Shtim fusha SERIALFDEMPTY ne CONFIGMG: bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','SERIALFDBLOCK')=0
      begin
        ALTER TABLE CONFIGMG ADD SERIALFDBLOCK Int NULL 
        Print 'Shtim fusha SERIALFDBLOCK ne CONFIGMG: Int'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','SERIALFHTEST')=0
      begin
        ALTER TABLE CONFIGMG ADD SERIALFHTEST bit NULL 
        Print 'Shtim fusha SERIALFHTEST ne CONFIGMG: bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','SERIALFHEMPTY')=0
      begin
        ALTER TABLE CONFIGMG ADD SERIALFHEMPTY bit NULL 
        Print 'Shtim fusha SERIALFHEMPTY ne CONFIGMG: bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','SERIALFHBLOCK')=0
      begin
        ALTER TABLE CONFIGMG ADD SERIALFHBLOCK Int NULL 
        Print 'Shtim fusha SERIALFHBLOCK ne CONFIGMG: Int'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','ORDERITEMSUSERMK')=0
      begin
        ALTER TABLE CONFIGMG ADD ORDERITEMSUSERMK Varchar(30) NULL 
        Print 'Shtim fusha ORDERITEMSUSERMK ne CONFIGMG: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','ORDERITEMSUSERDQ')=0
      begin
        ALTER TABLE CONFIGMG ADD ORDERITEMSUSERDQ Varchar(30) NULL 
        Print 'Shtim fusha ORDERITEMSUSERDQ ne CONFIGMG: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','ORDERITEMSUSERKL')=0
      begin
        ALTER TABLE CONFIGMG ADD ORDERITEMSUSERKL Varchar(30) NULL 
        Print 'Shtim fusha ORDERITEMSUSERKL ne CONFIGMG: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','ORDERITEMSCREATEFHMK')=0
      begin
        ALTER TABLE CONFIGMG ADD ORDERITEMSCREATEFHMK Bit NULL 
        Print 'Shtim fusha ORDERITEMSCREATEFHMK ne CONFIGMG: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','ORDERITEMSCREATEFHDQ')=0
      begin
        ALTER TABLE CONFIGMG ADD ORDERITEMSCREATEFHDQ Bit NULL 
        Print 'Shtim fusha ORDERITEMSCREATEFHDQ ne CONFIGMG: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','DISPLAYVLMAGINFJ')=0
      begin
        ALTER TABLE CONFIGMG ADD DISPLAYVLMAGINFJ Bit NULL 
        Print 'Shtim fusha DISPLAYVLMAGINFJ ne CONFIGMG: Bit'
      end;

   if dbo.Isd_FieldTableExists('CONFIGMG','TESTGJSM')=0
      begin
        ALTER TABLE CONFIGMG ADD TESTGJSM bit NULL
        Print 'Shtim fusha TESTGJSM ne CONFIGMG: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','STOPSASIZEROSM')=0
      begin
        ALTER TABLE CONFIGMG ADD STOPSASIZEROSM bit NULL
        Print 'Shtim fusha STOPSASIZEROSM ne CONFIGMG: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','TESTSASIGJLIMSM')=0
      begin
        ALTER TABLE CONFIGMG ADD TESTSASIGJLIMSM int NULL  
        Print 'Shtim fusha TESTSASIGJLIMSM ne CONFIGMG: int'
      end;   
   if dbo.Isd_FieldTableExists('CONFIGMG','DSTDEFAULT')=0
      begin
        ALTER TABLE CONFIGMG ADD DSTDEFAULT Varchar(30) NULL
        Print 'Shtim fusha DSTDEFAULT ne CONFIGMG: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','BLOCKLEVIZBRENDPAMG')=0
      begin
        ALTER TABLE CONFIGMG ADD BLOCKLEVIZBRENDPAMG bit NULL
        Print 'Shtim fusha BLOCKLEVIZBRENDPAMG ne CONFIGMG: Bit'
      end;


-- Me vone keto procedura te fshihen dhe te zevendesohen me ate me poshte.

   if dbo.Isd_FieldTableExists('CONFIGMG','FISNRKUFIP')=0
      begin
        ALTER TABLE CONFIGMG ADD FISNRKUFIP Bigint NULL;
        Print 'Shtim fusha FISNRKUFIP ne CONFIGMG: Bigint'
		if dbo.Isd_FieldTableExists('CONFND','FISNRKUFIP')=1 -- te fshihen sepse ne standart jane ne CONFND
		   begin
		     SET @sSql = 'UPDATE A SET A.FISNRKUFIP=ISNULL(B.FISNRKUFIP,0) FROM CONFIGMG A, CONFND B;
			              ALTER TABLE CONFND DROP COLUMN FISNRKUFIP';
			 EXEC (@sSql);
		   end;
      end;

   if dbo.Isd_FieldTableExists('CONFIGMG','FISNRKUFIS')=0
      begin
        ALTER TABLE CONFIGMG ADD FISNRKUFIS Bigint NULL
        Print 'Shtim fusha FISNRKUFIS ne CONFIGMG: Bigint'
		if dbo.Isd_FieldTableExists('CONFND','FISNRKUFIS')=1 -- te fshihen sepse ne standart jane ne CONFND
		   begin
		     SET @sSql = 'UPDATE A SET A.FISNRKUFIS=ISNULL(B.FISNRKUFIS,0) FROM CONFIGMG A, CONFND B;
			              ALTER TABLE CONFND DROP COLUMN FISNRKUFIS';
			 EXEC (@sSql);
		   end;
      end;

   if dbo.Isd_FieldTableExists('CONFIGMG','FISFJNRKUFIP')=0
      begin
        ALTER TABLE CONFIGMG ADD FISFJNRKUFIP Bigint NULL;
        Print 'Shtim fusha FISFJNRKUFIP ne CONFIGMG: Bigint'
		if dbo.Isd_FieldTableExists('CONFIGMG','FISNRKUFIP')=1 
		   begin
		      SET  @sSql = 'UPDATE CONFIGMG SET FISFJNRKUFIP=ISNULL(FISNRKUFIP,0);
			                ALTER TABLE CONFIGMG DROP COLUMN FISNRKUFIP';
			 EXEC (@sSql);
		   end;
      end;

   if dbo.Isd_FieldTableExists('CONFIGMG','FISFJNRKUFIS')=0
      begin
        ALTER TABLE CONFIGMG ADD FISFJNRKUFIS Bigint NULL
        Print 'Shtim fusha FISFJNRKUFIS ne CONFIGMG: Bigint'
		if dbo.Isd_FieldTableExists('CONFIGMG','FISNRKUFIS')=1 
		   begin
		     SET @sSql = 'UPDATE CONFIGMG SET FISFJNRKUFIS=ISNULL(FISNRKUFIS,0);
			              ALTER TABLE CONFIGMG DROP COLUMN FISNRKUFIS';
			 EXEC (@sSql);
		   end;
      end;


-- Kjo procedure te zevendesoje ato kater me siper
-- FISFJNRKUFIP,FISFJNRKUFIS,FISFFNRKUFIP,FISFFNRKUFIS tek CONFIGMG     

   Set @FieldsList = 'FISFJNRKUFIP,FISFJNRKUFIS,FISFFNRKUFIP,FISFFNRKUFIS';
   Set @sSql1 = '  
                      ALTER TABLE CONFIGMG ADD FISFJNRKUFIP BigInt NULL;
                      Print ''Shtim fusha FISFJNRKUFIP ne CONFIGMG: Bigint'';';
   Set @i = 1;
   Set @k = Len(@FieldsList) - Len(Replace(@FieldsList,',',''))+1;
   
   while @i<=@k
     begin 
       Set @sFieldName = dbo.Isd_StringInListStr(@FieldsList,@i,',');
	   Set @sSql = Replace(@sSql1,'FISFJNRKUFIP',@sFieldName);
       if  dbo.Isd_FieldTableExists('CONFIGMG',@sFieldName)=0
           Exec (@sSql);

       Set  @i = @i + 1;
     end;




     
      
---- Strukture Kod Artikull      

--   if dbo.Isd_FieldTableExists('CONFIGMG','KODARTMODEL')=0
--      begin
--        ALTER TABLE CONFIGMG ADD KODARTMODEL Int NULL 
--        Print 'Shtim fusha KODARTMODEL ne CONFIGMG: Int'
--      end;
--   if dbo.Isd_FieldTableExists('CONFIGMG','KODARTLENGTH')=0
--      begin
--        ALTER TABLE CONFIGMG ADD KODARTLENGTH Int NULL 
--        Print 'Shtim fusha KODARTLENGTH ne CONFIGMG: Int'
--      end;
--   if dbo.Isd_FieldTableExists('CONFIGMG','KODARTSTARTMOD')=0
--      begin
--        ALTER TABLE CONFIGMG ADD KODARTSTARTMOD Int NULL 
--        Print 'Shtim fusha KODARTSTARTMOD ne CONFIGMG: Int'
--      end;
--   if dbo.Isd_FieldTableExists('CONFIGMG','KODARTSTART')=0
--      begin
--        ALTER TABLE CONFIGMG ADD KODARTSTART Varchar(30) NULL 
--        Print 'Shtim fusha KODARTSTART ne CONFIGMG: Varchar(30)'
--      end;
--   if dbo.Isd_FieldTableExists('CONFIGMG','KODARTPARTSTARTMOD')=0
--      begin
--        ALTER TABLE CONFIGMG ADD KODARTPARTSTARTMOD Int NULL 
--        Print 'Shtim fusha KODARTPARTSTARTMOD ne CONFIGMG: Int'
--      end;
--   if dbo.Isd_FieldTableExists('CONFIGMG','KODARTPARTSTARTLEN')=0
--      begin
--        ALTER TABLE CONFIGMG ADD KODARTPARTSTARTLEN Int NULL 
--        Print 'Shtim fusha KODARTPARTSTARTLEN ne CONFIGMG: Int'
--      end;
--   if dbo.Isd_FieldTableExists('CONFIGMG','KODARTFORMAT')=0
--      begin
--        ALTER TABLE CONFIGMG ADD KODARTFORMAT Int NULL 
--        Print 'Shtim fusha KODARTFORMAT ne CONFIGMG: Int'
--      end;
----
      
   if dbo.Isd_FieldTableExists('CONFIGMG','PRICESHORTC')=0
      begin
        ALTER TABLE CONFIGMG ADD PRICESHORTC Varchar(20) NULL 
        Print 'Shtim fusha PRICESHORTC ne CONFIGMG: Varchar(20)'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','LISTEGRIDSHORTC')=0
      begin
        ALTER TABLE CONFIGMG ADD LISTEGRIDSHORTC Varchar(1000) NULL 
        Print 'Shtim fusha LISTEGRIDSHORTC ne CONFIGMG: Varchar(1000)'
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','NRSERIALDIGITFJ')=0
      begin
        ALTER TABLE CONFIGMG ADD NRSERIALDIGITFJ Int NULL; 
        Print 'Shtim fusha NRSERIALDIGITFJ ne CONFIGMG: Int';
        EXEC ('UPDATE CONFIGMG SET NRSERIALDIGITFJ=NRDIGITSERIAL;')
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','NRSERIALDIGITFF')=0
      begin
        ALTER TABLE CONFIGMG ADD NRSERIALDIGITFF Int NULL; 
        Print 'Shtim fusha NRSERIALDIGITFF ne CONFIGMG: Int';
        EXEC ('UPDATE CONFIGMG SET NRSERIALDIGITFF=NRDIGITSERIAL;')
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','NRSERIALDIGITFD')=0
      begin
        ALTER TABLE CONFIGMG ADD NRSERIALDIGITFD Int NULL; 
        Print 'Shtim fusha NRSERIALDIGITFD ne CONFIGMG: Int';
        EXEC ('UPDATE CONFIGMG SET NRSERIALDIGITFD=NRDIGITSERIAL;')
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','NRSERIALDIGITFH')=0
      begin
        ALTER TABLE CONFIGMG ADD NRSERIALDIGITFH Int NULL; 
        Print 'Shtim fusha NRSERIALDIGITFH ne CONFIGMG: Int';
        EXEC ('UPDATE CONFIGMG SET NRSERIALDIGITFH=NRDIGITSERIAL;')
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','KLASECMIMREFFT')=0
      begin
        ALTER TABLE CONFIGMG ADD KLASECMIMREFFT Varchar(10) NULL; 
        Print 'Shtim fusha KLASECMIMREFFT ne CONFIGMG: Varchar(10)';
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','AKTIVCMIMREFFT')=0
      begin
        ALTER TABLE CONFIGMG ADD AKTIVCMIMREFFT Bit NULL; 
        Print 'Shtim fusha AKTIVCMIMREFFT ne CONFIGMG: Bit';
      end;
   if dbo.Isd_FieldTableExists('CONFIGMG','MODELNDERTIMDOK')=0
      begin
        ALTER TABLE CONFIGMG ADD MODELNDERTIMDOK Varchar(10) NULL
        Print 'Shtim fusha MODELNDERTIMDOK ne CONFIGMG: Varchar(10)';
      end;


-- AFLISTE

   if dbo.Isd_FieldTableExists('AFLISTE','NRORDER')=0
      begin
        ALTER TABLE AFLISTE ADD NRORDER Int NULL
        Print 'Shtim fusha NRORDER ne AFLISTE: Int';
      end;
   if dbo.Isd_FieldTableExists('AFLISTE','DOKDST')=0
      begin
        ALTER TABLE AFLISTE ADD DOKDST Varchar(100) NULL
        Print 'Shtim fusha DOKDST ne AFLISTE: Varchar(100)';
      end;
   if dbo.Isd_FieldTableExists('AFLISTE','DOKORG')=0
      begin
        ALTER TABLE AFLISTE ADD DOKORG Varchar(100) NULL
        Print 'Shtim fusha DOKORG ne AFLISTE: Varchar(100)';
      end;
   if dbo.Isd_FieldTableExists('AFLISTE','WHERECONST')=0
      begin
        ALTER TABLE AFLISTE ADD WHERECONST nVarchar(MAX) NULL
        Print 'Shtim fusha WHERECONST ne AFLISTE: nVarchar(MAX)';
      end;
   if dbo.Isd_FieldTableExists('AFLISTE','WHERENEW')=0
      begin
        ALTER TABLE AFLISTE ADD WHERENEW nVarchar(MAX) NULL
        Print 'Shtim fusha WHERENEW ne AFLISTE: nVarchar(MAX)';
      end;
   if dbo.Isd_FieldTableExists('AFLISTE','PROMPTLIST')=0
      begin
        ALTER TABLE AFLISTE ADD PROMPTLIST Varchar(100) NULL
        Print 'Shtim fusha PROMPTLIST ne AFLISTE: Varchar(100)';
      end;


   --if dbo.Isd_FieldTableExists('CONFIGMG','KLS1AQPROMPT')=0
   --   begin
   --     ALTER TABLE CONFIGMG ADD KLS1AQPROMPT VARCHAR(30)
   --     Print 'Shtim fusha KLS1AQPROMPT ne CONFIGMG: VARCHAR(30)'
   --   end;
   --if dbo.Isd_FieldTableExists('CONFIGMG','KLS2AQPROMPT')=0
   --   begin
   --     ALTER TABLE CONFIGMG ADD KLS2AQPROMPT VARCHAR(30)
   --     Print 'Shtim fusha KLS2AQPROMPT ne CONFIGMG: VARCHAR(30)'
   --   end;
   --if dbo.Isd_FieldTableExists('CONFIGMG','KLS3AQPROMPT')=0
   --   begin
   --     ALTER TABLE CONFIGMG ADD KLS3AQPROMPT VARCHAR(30)
   --     Print 'Shtim fusha KLS3AQPROMPT ne CONFIGMG: VARCHAR(30)'
   --   end;
   --Exec (' UPDATE CONFIGMG SET KLS1AQPROMPT=CASE WHEN ISNULL(KLS1AQPROMPT,'''')='''' THEN ''aktiv klasifikim 1'' ELSE KLS1AQPROMPT END;
   --        UPDATE CONFIGMG SET KLS2AQPROMPT=CASE WHEN ISNULL(KLS2AQPROMPT,'''')='''' THEN ''aktiv klasifikim 2'' ELSE KLS2AQPROMPT END;
   --        UPDATE CONFIGMG SET KLS3AQPROMPT=CASE WHEN ISNULL(KLS3AQPROMPT,'''')='''' THEN ''aktiv klasifikim 3'' ELSE KLS3AQPROMPT END; ')

--   if dbo.Isd_FieldTableExists('CONFIGMG','PRIORITYKODSCRLM')=0
--      begin
--        ALTER TABLE CONFIGMG ADD PRIORITYKODSCRLM varchar (30) NULL
--        Print 'Shtim fusha PRIORITYKODSCRLM ne CONFIGMG: Varchar(30)'
--      end
--   if dbo.Isd_FieldTableExists('CONFIGMG','PRIORITYKODSCRMG')=0
--      begin
--        ALTER TABLE CONFIGMG ADD PRIORITYKODSCRMG varchar (30) NULL
--        Print 'Shtim fusha PRIORITYKODSCRMG ne CONFIGMG: Varchar(30)'
--      end

  
   Set @TablesList = '1,2,3,4,5,6'
   Set @sSql1 = '  
                      ALTER TABLE CONFIGMG ADD KLS1KLPROMPT VARCHAR(30) NULL ;
                      Print ''Shtim fusha KLS1KLPROMPT ne CONFIGMG: Varchar(30)'';';
   Set @sSql2 = '     UPDATE CONFIGMG SET KLS1KLPROMPT=''Klasifikim 1'' ;';


       Set @TableName  = 'CONFIGMG';
   
       Set @i = 1;
       Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;

   while @i<=@k
     begin 
     
       Set @sKlase     = dbo.Isd_StringInListStr(@TablesList,@i,',');
       Set @sFieldName = 'KLS'+@sKlase+'KLPROMPT';
       
       if  (@sKlase<>'') AND (dbo.Isd_FieldTableExists(@TableName,@sFieldName)=0)
            begin
              Set   @sSql  = Replace(@sSql1,'KLS1KLPROMPT',@sFieldName);
              Exec (@sSql);
           
              Set   @sSql  = Replace(@sSql2,'KLS1KLPROMPT',@sFieldName);
              Set   @sSql  = Replace(@sSql, 'Klasifikim 1','Klasifikim '+@sKlase);
              Exec (@sSql);
            end;
            
       Set     @i = @i + 1
     end;
     

       Set @i = 1;
   while @i<=@k
     begin 
     
       Set @sKlase     = dbo.Isd_StringInListStr(@TablesList,@i,',');
       Set @sFieldName = 'KLS'+@sKlase+'FUPROMPT';
       
       if  (@sKlase<>'') AND (dbo.Isd_FieldTableExists(@TableName,@sFieldName)=0)
            begin
              Set   @sSql  = Replace(@sSql1,'KLS1KLPROMPT',@sFieldName);
              Exec (@sSql);
           
              Set   @sSql  = Replace(@sSql2,'KLS1KLPROMPT',@sFieldName);
              Set   @sSql  = Replace(@sSql, 'Klasifikim 1','Klasifikim '+@sKlase);
              Exec (@sSql);
            end;
            
       Set     @i = @i + 1;
     end;



       Set @i = 1;
   while @i<=@k
     begin 
     
       Set @sKlase     = dbo.Isd_StringInListStr(@TablesList,@i,',');
       Set @sFieldName = 'KLS'+@sKlase+'AQPROMPT';
       
       if  (@sKlase<>'') AND (dbo.Isd_FieldTableExists(@TableName,@sFieldName)=0)
            begin
              Set   @sSql  = Replace(@sSql1,'KLS1KLPROMPT',@sFieldName);
              Exec (@sSql);
           
              Set   @sSql  = Replace(@sSql2,'KLS1KLPROMPT',@sFieldName);
              Set   @sSql  = Replace(@sSql, 'Klasifikim 1','Aktiv klasif '+@sKlase);
              Exec (@sSql);
            end;
            
       Set     @i = @i + 1;
     end;


-- ArtikujSist

   if dbo.Isd_FieldTableExists('ARTIKUJSIST','NRD')=0
      begin
        ALTER TABLE ARTIKUJSIST ADD NRD Int NULL
        Exec ('UPDATE      ARTIKUJSIST SET NRD=0 ')
        Print 'Shtim fusha NRD ne ARTIKUJSIST: Int'
      end
   if dbo.Isd_FieldTableExists('ARTIKUJSIST','KLASIF3')=0
      begin
        ALTER TABLE ARTIKUJSIST ADD KLASIF3 varchar (30) NULL
        Print 'Shtim fusha KLASIF3 ne ARTIKUJSIST: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('ARTIKUJSIST','KLASIF4')=0
      begin
        ALTER TABLE ARTIKUJSIST ADD KLASIF4 varchar (30) NULL
        Print 'Shtim fusha KLASIF4 ne ARTIKUJSIST: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('ARTIKUJSIST','KLASIF5')=0
      begin
        ALTER TABLE ARTIKUJSIST ADD KLASIF5 varchar (30) NULL
        Print 'Shtim fusha KLASIF5 ne ARTIKUJSIST: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('ARTIKUJSIST','KLASIF6')=0
      begin
        ALTER TABLE ARTIKUJSIST ADD KLASIF6 varchar (30) NULL
        Print 'Shtim fusha KLASIF6 ne ARTIKUJSIST: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('ARTIKUJSIST','KLASIF7')=0
      begin
        ALTER TABLE ARTIKUJSIST ADD KLASIF7 varchar (30) NULL
        Print 'Shtim fusha KLASIF7 ne ARTIKUJSIST: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('ARTIKUJSIST','KLASIF8')=0
      begin
        ALTER TABLE ARTIKUJSIST ADD KLASIF8 varchar (30) NULL
        Print 'Shtim fusha KLASIF8 ne ARTIKUJSIST: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('ARTIKUJSIST','KLASIF9')=0
      begin
        ALTER TABLE ARTIKUJSIST ADD KLASIF9 varchar (30) NULL
        Print 'Shtim fusha KLASIF9 ne ARTIKUJSIST: Varchar(30)'
      end
   if dbo.Isd_FieldTableExists('ARTIKUJSIST','VLERADIF')=0
      begin
        ALTER TABLE ARTIKUJSIST ADD VLERADIF Float NULL
        Print 'Shtim fusha VLERADIF ne ARTIKUJSIST: Float'
      end
   if dbo.Isd_FieldTableExists('ARTIKUJSIST','KOSTMESND')=0
      begin
        ALTER TABLE ARTIKUJSIST ADD KOSTMESND Float NULL
        Print 'Shtim fusha KOSTMESND ne ARTIKUJSIST: Float'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJSIST','KOSTMESMG')=0
      begin
        ALTER TABLE ARTIKUJSIST ADD KOSTMESMG Float NULL
        Print 'Shtim fusha KOSTMESMG ne ARTIKUJSIST: Float'
      end;

--   if dbo.Isd_FieldTableExists('ARTIKUJSIST','STATUS')=0
--      begin
--        ALTER TABLE ARTIKUJSIST ADD STATUS Int NULL
--        Print 'Shtim fusha STATUS ne ARTIKUJSIST: Int'
--      end
   if dbo.Isd_FieldTableExists('ARTIKUJSISTM','STATUSST')=0
      begin
        ALTER TABLE ARTIKUJSISTM ADD STATUSST Int NULL
        Print 'Shtim fusha STATUSST ne ARTIKUJSISTM: Int'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJSISTM','TRANNUMBER')=0
      begin
        ALTER TABLE ARTIKUJSISTM ADD TRANNUMBER Varchar(30) NULL
        Print 'Shtim fusha TRANNUMBER ne ARTIKUJSISTM: Varchar(30)'
      end;


--   if Not (Exists (SELECT name FROM sys.indexes Where name = N'IX_ARTIKUJSISTNRD'))
--	  begin
--		Create Index IX_ARTIKUJSISTNRD ON ARTIKUJSIST(NRD)
--		Print 'Krijim Index tek ARTIKUJSIST Kollona NRD'
--	  end

   if dbo.Isd_FieldTableExists('KLIENTCMIM','KOEFICENT1')=0
      begin
        ALTER TABLE KLIENTCMIM ADD KOEFICENT1 Float NULL
        Print 'Shtim fusha KOEFICENT1 ne KLIENTCMIM: Float'
      end;
   if dbo.Isd_FieldTableExists('KLIENTCMIM','ZGJIDH')=0
      begin
        ALTER TABLE KLIENTCMIM ADD ZGJIDH Bit NULL
        Print 'Shtim fusha ZGJIDH ne KLIENTCMIM: Bit'
      end;

      Set @sSql1 = '

          if ( SELECT Data_type
                 FROM information_schema.columns
                WHERE Table_Name = ''KLIENTCM''  And Column_Name=''CMSH'') = ''Real''
             begin
               ALTER TABLE KLIENTCM ALTER COLUMN CMSH FLOAT NULL;
               Print ''Alter Table KLIENTCM column CMSH Float'';
             end; '; 

    Exec (@sSql1);
    Exec ('USE CONFIG; ' + @sSql1);




  Exec (' USE DRH 


         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''DREJTA'') And (Name=''ARSHIVE''))
           begin
             ALTER TABLE DREJTA ADD ARSHIVE Bit NULL
             Print ''Shtim fusha ARSHIVE ne DRH..DREJTA: Bit''
           end;
         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''DREJTA'') And (Name=''KONFIRM''))
           begin
             ALTER TABLE DREJTA ADD KONFIRM Bit NULL
             Print ''Shtim fusha KONFIRM ne DRH..DREJTA: Bit''
           end;
         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''DREJTA'') And (Name=''STATROW''))
           begin
             ALTER TABLE DREJTA ADD STATROW Varchar(5) NULL
             Print ''Shtim fusha STATROW ne DRH..DREJTA: Varchar(5)''
           end;
         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''DREJTA'') And (Name=''ORDERSCR''))
           begin
             ALTER TABLE DREJTA ADD ORDERSCR Int NULL
             Print ''Shtim fusha ORDERSCR ne DRH..DREJTA: Int''
           end;


         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''USERS'') And (Name=''NOTEXPORT''))
           begin
             ALTER TABLE USERS ADD NOTEXPORT Bit NULL
             Print ''Shtim fusha NOTEXPORT ne DRH..USERS: Bit''
           end;
         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''USERS'') And (Name=''NOTPRINT''))
           begin
             ALTER TABLE USERS ADD NOTPRINT Bit NULL
             Print ''Shtim fusha NOTPRINT ne DRH..USERS: Bit''
           end;
         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''USERS'') And (Name=''NOTDISPLAY''))
           begin
             ALTER TABLE USERS ADD NOTDISPLAY Bit NULL
             Print ''Shtim fusha NOTDISPLAY ne DRH..USERS: Bit''
           end;

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''USERS'') And (Name=''ACTIVSCHED''))
           begin
             ALTER TABLE USERS ADD ACTIVSCHED Bit NULL
             Print ''Shtim fusha ACTIVSCHED ne DRH..USERS: Bit''
           end;
 
         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''CONFIG'') And (Name=''WRPRTFTPRD''))
           begin
             ALTER TABLE CONFIG ADD WRPRTFTPRD Int NULL
             Print ''Shtim fusha WRPRTFTPRD ne DRH..CONFIG: Int''
           end; 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''USERS'') And (Name=''KODKASE''))
           begin
             ALTER TABLE USERS ADD KODKASE Varchar(30) NULL
             Print ''Shtim fusha KODKASE ne DRH..USERS: Varchar(30)'';
             EXEC (''UPDATE USERS SET KODKASE = DRN'');
           end; 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''USERS'') And (Name=''IMPORTROWMG''))
           begin
             ALTER TABLE USERS ADD IMPORTROWMG Bit NULL
             Print ''Shtim fusha IMPORTROWMG ne DRH..USERS: Bit'';
             EXEC (''UPDATE USERS SET IMPORTROWMG = 1'');
           end; 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''USERS'') And (Name=''IMPORTROWLM''))
           begin
             ALTER TABLE USERS ADD IMPORTROWLM Bit NULL
             Print ''Shtim fusha IMPORTROWLM ne DRH..USERS: Bit'';
             EXEC (''UPDATE USERS SET IMPORTROWLM = 1'');
           end; 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''USERS'') And (Name=''TRANSFERMG''))
           begin
             ALTER TABLE USERS ADD TRANSFERMG Bit NULL
             Print ''Shtim fusha TRANSFERMG ne DRH..USERS: Bit'';
             EXEC (''UPDATE USERS SET TRANSFERMG = 1'');
           end; 

--         if Not Exists (Select Name
--                          From Sys.Columns
--                         Where Object_Id = Object_Id(''USERS'') And (Name=''ROWLISTCMDOC''))
--           begin
--             ALTER TABLE USERS ADD ROWLISTCMDOC Bit NULL
--             Print ''Shtim fusha ROWLISTCMDOC ne DRH..USERS: Bit''
--           end;
--         if Not Exists (Select Name
--                          From Sys.Columns
--                         Where Object_Id = Object_Id(''USERS'') And (Name=''ROWLISTCMFF''))
--           begin
--             ALTER TABLE USERS ADD ROWLISTCMFF Bit NULL
--             Print ''Shtim fusha ROWLISTCMFF ne DRH..USERS: Bit''
--           end;
--         if Not Exists (Select Name
--                          From Sys.Columns
--                         Where Object_Id = Object_Id(''USERS'') And (Name=''ROWLISTCMOF''))
--           begin
--             ALTER TABLE USERS ADD ROWLISTCMOF Bit NULL
--             Print ''Shtim fusha ROWLISTCMOF ne DRH..USERS: Bit''
--           end;
--         if Not Exists (Select Name
--                          From Sys.Columns
--                         Where Object_Id = Object_Id(''USERS'') And (Name=''ROWLISTCMART''))
--           begin
--             ALTER TABLE USERS ADD ROWLISTCMART Bit NULL
--             Print ''Shtim fusha ROWLISTCMART ne DRH..USERS: Bit''
--           end;

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''USERS'') And (Name=''NOTDESIGNRP''))
           begin
             ALTER TABLE USERS ADD NOTDESIGNRP Bit NULL
             Print ''Shtim fusha NOTDESIGNRP ne DRH..USERS: Bit'';
           end; 


         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''USERS'') And (Name=''USERSKNAME''))
           begin
             ALTER TABLE USERS ADD USERSKNAME Varchar(50) NULL
             Print ''Shtim fusha USERSKNAME ne DRH..USERS: Varchar(50)'';
           end; 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''USERS'') And (Name=''USERSKALWAYS''))
           begin
             ALTER TABLE USERS ADD USERSKALWAYS Bit NULL
             Print ''Shtim fusha USERSKALWAYS ne DRH..USERS: Bit'';
           end; 
           
         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''USERS'') And (Name=''FISKODOPERATOR''))
           begin
             ALTER TABLE USERS ADD FISKODOPERATOR Varchar(60) NULL
             Print ''Shtim fusha FISKODOPERATOR ne DRH..USERS: Varchar(60)'';
           end; 
           

		    if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''USERS'') And (Name=''CREATEORDERMK''))
           begin
             ALTER TABLE USERS ADD CREATEORDERMK BIT NULL
             Print ''Shtim fusha CREATEORDERMK ne DRH..USERS: Bit'';
           end; 
         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''USERS'') And (Name=''CREATEORDERDQ''))
           begin
             ALTER TABLE USERS ADD CREATEORDERDQ BIT NULL
             Print ''Shtim fusha CREATEORDERDQ ne DRH..USERS: Bit'';
           end; 
         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''USERS'') And (Name=''CREATEORDERKL''))
           begin
             ALTER TABLE USERS ADD CREATEORDERKL BIT NULL
             Print ''Shtim fusha CREATEORDERKL ne DRH..USERS: Bit'';
           end; 



-- NDUS
         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''NDUS'') And (Name=''USERSKNAME''))
           begin
             ALTER TABLE NDUS ADD USERSKNAME Varchar(50) NULL
             Print ''Shtim fusha USERSKNAME ne DRH..NDUS: Varchar(50)'';
           end; 
');



          IF NOT EXISTS(SELECT NRRENDOR FROM DRH..TABLEMODUL WHERE KOD='X') --  AND ISNULL(KOD,'')=''
             BEGIN
               INSERT  INTO DRH..TableModul
                      (KOD,PERSHKRIM, NRORDER,TROW,TAGNR)

               SELECT A1='X',A2='Aktivet',A3='04',A4=0,A5=0
             END;

          IF NOT EXISTS(SELECT NRRENDOR FROM DRH..TableRef WHERE MODUL='X' AND TABLENAME='AQKARTELA') 
             BEGIN
               INSERT  INTO DRH..TableRef
                      (NRORDER,KOD,PERSHKRIM, TABLENAME,TIP,MODUL,LIST,ORG,TROW,TAGNR)

               SELECT A1='0012',A2='AQKARTELA',A3='Aktive',A4='AQKARTELA',A5='',A6='X',A7='',A8='X',0,-1
             END;
             
             
             
             

-- CONFND ne DBRP
        Exec (' 
        
        USE DBRP 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''CONFIG'') And (Name=''LISTFOCUS''))
           begin
             ALTER TABLE CONFIG ADD LISTFOCUS Varchar(30) NULL --CONSTRAINT [DF_CONFIG_LISTFOCUS]  DEFAULT (''GR'')
             Print ''Shtim fusha LISTFOCUS ne DBRP..CONFIG: Varchar(30)''
             Exec('' UPDATE CONFIG SET LISTFOCUS=''''GR''''  '')     
           end 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''AFLISTE'') And (Name=''ORDERITEMINDEX''))
           begin
             ALTER TABLE AFLISTE ADD ORDERITEMINDEX Int NULL 
             Print ''Shtim fusha ORDERITEMINDEX ne DBRP..AFLISTE: Int''
             Exec (''UPDATE AFLISTE SET ORDERITEMINDEX=0 '')     
           end 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''CONFIG'') And (Name=''RPLINEACTIV''))
            begin
              ALTER TABLE CONFIG ADD RPLINEACTIV Bit NULL
              Print ''Shtim fusha RPLINEACTIV ne DBRP..CONFIG: Bit''
            end;

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''CONFIG'') And (Name=''RPLINENR''))
            begin
              ALTER TABLE CONFIG ADD RPLINENR Int NULL
              Print ''Shtim fusha RPLINENR ne DBRP..CONFIG: Int''
            end; 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''RAPORT'') And (Name=''KOMENT_TH1''))
            begin
              ALTER TABLE RAPORT ADD KOMENT_TH1 Varchar(200) NULL
              Print ''Shtim fusha KOMENT_TH1 ne DBRP..RAPORT: Varchar(200)''
            end; 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''RAPORT'') And (Name=''KOMENT_TH2''))
            begin
              ALTER TABLE RAPORT ADD KOMENT_TH2 Varchar(200) NULL
              Print ''Shtim fusha KOMENT_TH2 ne DBRP..RAPORT: Varchar(200)''
            end; 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''RAPORT'') And (Name=''KOMENT_THACT''))
            begin
              ALTER TABLE RAPORT ADD KOMENT_THACT Bit NULL
              Print ''Shtim fusha KOMENT_THACT ne DBRP..RAPORT: Bit''
            end; 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''RAPORT'') And (Name=''KOMENT_PH1''))
            begin
              ALTER TABLE RAPORT ADD KOMENT_PH1 Varchar(200) NULL
              Print ''Shtim fusha KOMENT_PH1 ne DBRP..RAPORT: Varchar(200)''
            end; 
         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''RAPORT'') And (Name=''KOMENT_PH2''))
            begin
              ALTER TABLE RAPORT ADD KOMENT_PH2 Varchar(200) NULL
              Print ''Shtim fusha KOMENT_PH2 ne DBRP..RAPORT: Varchar(200)''
            end; 
         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''RAPORT'') And (Name=''KOMENT_PHACT''))
            begin
              ALTER TABLE RAPORT ADD KOMENT_PHACT Bit NULL
              Print ''Shtim fusha KOMENT_PHACT ne DBRP..RAPORT: Bit''
            end; 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''RAPORT'') And (Name=''KOMENT_SF1''))
            begin
              ALTER TABLE RAPORT ADD KOMENT_SF1 Varchar(200) NULL
              Print ''Shtim fusha KOMENT_SF1 ne DBRP..RAPORT: Varchar(200)''
            end; 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''RAPORT'') And (Name=''KOMENT_SF2''))
            begin
              ALTER TABLE RAPORT ADD KOMENT_SF2 Varchar(200) NULL
              Print ''Shtim fusha KOMENT_SF2 ne DBRP..RAPORT: Varchar(200)''
            end; 
         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''RAPORT'') And (Name=''KOMENT_SFACT''))
            begin
              ALTER TABLE RAPORT ADD KOMENT_SFACT Bit NULL
              Print ''Shtim fusha KOMENT_SFACT ne DBRP..RAPORT: Bit''
            end; 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''RAPORT'') And (Name=''KOMENT_SFFPG''))
            begin
              ALTER TABLE RAPORT ADD KOMENT_SFFPG Bit NULL
              Print ''Shtim fusha KOMENT_SFFPG ne DBRP..RAPORT: Bit''
            end; 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''RAPORT'') And (Name=''KOMENT_SFLPG''))
            begin
              ALTER TABLE RAPORT ADD KOMENT_SFLPG Bit NULL
              Print ''Shtim fusha KOMENT_SFLPG ne DBRP..RAPORT: Bit''
            end; 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''RAPORT'') And (Name=''RPCUSTOM''))
            begin
              ALTER TABLE RAPORT ADD RPCUSTOM Bit NULL
              Print ''Shtim fusha RPCOSTUM ne DBRP..RAPORT: Bit''
            end; 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''RAPORT'') And (Name=''RPUSER''))
            begin
              ALTER TABLE RAPORT ADD RPUSER Bit NULL
              Print ''Shtim fusha RPUSER ne DBRP..RAPORT: Bit''
            end; 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''RAPORT'') And (Name=''RPFILTER''))
            begin
              ALTER TABLE RAPORT ADD RPFILTER Varchar(5000) NULL
              Print ''Shtim fusha RPFILTER ne DBRP..RAPORT: Varchar(5000)''
            end; 



         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''GRFONT'') And (Name=''GRBCKCOL''))
            begin
              ALTER TABLE GRFONT ADD GRBCKCOL Int NULL
              Print ''Shtim fusha GRBCKCOL ne DBRP..GRFONT: Int''
              Exec (''UPDATE GRFONT SET GRBCKCOL=-16777192'');
            end; 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''GRFONT'') And (Name=''GRROWBCKCOL''))
            begin
              ALTER TABLE GRFONT ADD GRROWBCKCOL Int NULL
              Print ''Shtim fusha GRROWBCKCOL ne DBRP..GRFONT: Int''
              Exec (''UPDATE GRFONT SET GRROWBCKCOL=15066597'');
            end; 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''GRFONT'') And (Name=''GRROWFONTCOL''))
            begin
              ALTER TABLE GRFONT ADD GRROWFONTCOL Int NULL
              Print ''Shtim fusha GRROWFONTCOL ne DBRP..GRFONT: Int''
              Exec (''UPDATE GRFONT SET GRROWFONTCOL=0'');
            end; 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''GRFONT'') And (Name=''GRROWNRCOL''))
            begin
              ALTER TABLE GRFONT ADD GRROWNRCOL Int NULL
              Print ''Shtim fusha GRROWNRCOL ne DBRP..GRFONT: Int''
              Exec (''UPDATE GRFONT SET GRROWNRCOL=2'');
            end; 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''GRFONT'') And (Name=''GRDRAWSTYLE''))
            begin
              ALTER TABLE GRFONT ADD GRDRAWSTYLE Int NULL
              Print ''Shtim fusha GRDRAWSTYLE ne DBRP..GRFONT: Int''
              Exec (''UPDATE GRFONT SET GRDRAWSTYLE=0'');
            end; 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''LISTA_FILTER'') And (Name=''ITEMS''))
            begin
              ALTER TABLE LISTA_FILTER ADD ITEMS Varchar(2000) NULL
              Print ''Shtim fusha ITEMS ne DBRP..LISTA_FILTER: Varchar(2000)''
            end;

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''LISTA_FILTER'') And (Name=''ITEMSVALUE''))
            begin
              ALTER TABLE LISTA_FILTER ADD ITEMSVALUE Varchar(200) NULL
              Print ''Shtim fusha ITEMSVALUE ne DBRP..LISTA_FILTER: Varchar(200)''
            end;

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''LISTA_FILTER'') And (Name=''ITEMINDEX''))
            begin
              ALTER TABLE LISTA_FILTER ADD ITEMINDEX Int NULL
              Print ''Shtim fusha ITEMINDEX ne DBRP..LISTA_FILTER: Int''
            end;

     UPDATE LISTA_FILTER
        SET ITEMS      = ISNULL(IT1,'''')+'',''+ISNULL(IT2,'''')+'',''+ISNULL(IT3,''''), 
            ITEMINDEX  = 0,
            ITEMSVALUE = ''0,1,''
      WHERE ISNULL(ITEMS,'''')='''' AND ISNULL(IT1,'''')<>'''' AND OBJ=''RG''

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''CONFIG'') And (Name=''RDONLYCOLOR''))
            begin
              ALTER TABLE CONFIG ADD RDONLYCOLOR Int NULL
              Print ''Shtim fusha RDONLYCOLOR ne DBRP..CONFIG: Int''
              Exec (''UPDATE CONFIG SET RDONLYCOLOR=-16777212'');
            end; 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''CONFIG'') And (Name=''RDONLYFONTCOLOR''))
            begin
              ALTER TABLE CONFIG ADD RDONLYFONTCOLOR Int NULL
              Print ''Shtim fusha RDONLYFONTCOLOR ne DBRP..CONFIG: Int''
              Exec (''UPDATE CONFIG SET RDONLYFONTCOLOR=16711935'');
            end;

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''CONFIG'') And (Name=''LISTACTIVORDER''))
            begin
              ALTER TABLE CONFIG ADD LISTACTIVORDER Bit NULL
              Print ''Shtim fusha LISTACTIVORDER ne DBRP..CONFIG: Bit''
            end; 
         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''CONFIG'') And (Name=''LISTACTIVSEARCH''))
            begin
              ALTER TABLE CONFIG ADD LISTACTIVSEARCH Bit NULL
              Print ''Shtim fusha LISTACTIVSEARCH ne DBRP..CONFIG: Bit''
            end; 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''CONFIG'') And (Name=''SHOWOUTLINEENABLED''))
            begin
              ALTER TABLE CONFIG ADD SHOWOUTLINEENABLED Bit NULL
              Print ''Shtim fusha SHOWOUTLINEENABLED ne DBRP..CONFIG: Bit''
            end; 
         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''CONFIG'') And (Name=''SHOWOUTLINEVISIBLE''))
            begin
              ALTER TABLE CONFIG ADD SHOWOUTLINEVISIBLE Bit NULL
              Print ''Shtim fusha SHOWOUTLINEVISIBLE ne DBRP..CONFIG: Bit''
            end; 
         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''CONFIG'') And (Name=''HIDETHUMBNAILSENABLED''))
            begin
              ALTER TABLE CONFIG ADD HIDETHUMBNAILSENABLED Bit NULL
              Print ''Shtim fusha HIDETHUMBNAILSENABLED ne DBRP..CONFIG: Bit''
            end; 
         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''CONFIG'') And (Name=''HIDETHUMBNAILSVISIBLE''))
            begin
              ALTER TABLE CONFIG ADD HIDETHUMBNAILSVISIBLE Bit NULL
              Print ''Shtim fusha HIDETHUMBNAILSVISIBLE ne DBRP..CONFIG: Bit''
            end; 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''RAPORT'') And (Name=''EDITBLOCKENTER''))
            begin
              ALTER TABLE RAPORT ADD EDITBLOCKENTER Varchar(200) NULL
              Print ''Shtim fusha EDITBLOCKENTER ne DBRP..CONFIG: Varchar(200)''
            end;

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''CONFIG'') And (Name=''SINGLEPAGEONLYENABLED''))
            begin
              ALTER TABLE CONFIG ADD SINGLEPAGEONLYENABLED Bit NULL
              Print ''Shtim fusha SINGLEPAGEONLYENABLED ne DBRP..CONFIG: Bit''
            end;

')

         SET @sSql = '
         USE [DBRP]

         SET ANSI_NULLS ON
         SET QUOTED_IDENTIFIER ON
         SET ANSI_PADDING ON

      CREATE TABLE [dbo].[ReportFilter](
	      [NrRendor] [int] IDENTITY(1,1) NOT NULL,
	      [NRD] [int] NULL,
	      [edName] [varchar](30) NULL,
	      [edNameKs] [varchar](30) NULL,
	      [edTop] [int] NULL,
	      [edLeft] [int] NULL,
	      [edWidth] [int] NULL,
	      [edHeight] [int] NULL,
	      [edParentName] [varchar](50) NULL,
	      [edClassName] [varchar](30) NULL,
	      [edAlias] [varchar](50) NULL,
	      [edDefaultValue] [varchar](50) NULL,
	      [edTabOrder] [int] NULL,
	      [edOrder] [varchar](5) NULL,
	      [edListKey] [varchar](10) NULL,
	      [edListCommand] [nchar](2000) NULL,
	      [lbName] [varchar](30) NULL,
	      [lbCaption] [varchar](30) NULL,
	      [lbCaptionShort] [varchar](10) NULL,
	      [lbTop] [int] NULL,
	      [lbLeft] [int] NULL,
	      [edVisible] [bit] NULL,
	      [edActive] [bit] NULL,
	      [TRow] [bit] NULL,
	      [TagNr] [int] NULL
     ) ON [PRIMARY]
     
      SET ANSI_PADDING OFF  ';

          IF OBJECT_ID('DBRP..ReportFilter') IS NULL
             EXEC (@sSql);



         SET @sSql = '
         USE DBRP
         SET ANSI_NULLS ON
         SET QUOTED_IDENTIFIER ON
         SET ANSI_PADDING ON

      CREATE TABLE [dbo].[ReportFilters](
	         [NrRendor] [int] IDENTITY(1,1) NOT NULL,
	         [Nrd] [int] NULL,
	         [Perdorues] [varchar](30) NULL,
	         [Pershkrim] [varchar](150) NULL,
	         [Koment] [varchar](300) NULL,
	         [Klasifikim] [varchar](30) NULL,
	         [Filters] [varchar](max) NULL,
	         [GrupOrder] [varchar](10) NULL,
	         [SetDefault] [bit] NULL,
	         [USI] [varchar](10) NULL,
	         [USM] [varchar](10) NULL,
	         [DateCreate] [datetime] NULL,
	         [DateEdit] [datetime] NULL,
	         [TRow] [bit] NULL,
	         [TagNr] [int] NULL
        ) ON [PRIMARY]

          SET ANSI_PADDING OFF
        ALTER TABLE [dbo].[ReportFilters] ADD  CONSTRAINT [DF_ReportFilters_DateCreate]  DEFAULT (getdate()) FOR [DateCreate]
        ALTER TABLE [dbo].[ReportFilters] ADD  CONSTRAINT [DF_ReportFilters_DateEdit]  DEFAULT (getdate()) FOR [DateEdit] ';

          IF OBJECT_ID('DBRP..ReportFilters') IS NULL
             EXEC (@sSql);





         SET @sSql = '
         SET ANSI_NULLS ON
         SET QUOTED_IDENTIFIER ON
         SET ANSI_PADDING ON

      CREATE TABLE [dbo].[Countries](
	         [NRRENDOR] [int] IDENTITY(1,1) NOT NULL,
	         [KOD] [varchar](60) NULL,
	         [PERSHKRIM] [varchar](100) NULL,
	         [KLASIFIKIM] [varchar](60) NULL,
	         [INTCOUNTRYKOD] [varchar](30) NULL,
	         [INTISOKOD] [varchar](30) NULL,
	         [INTCURRENCYKOD] [varchar](30) NULL,
			 [NOTACTIV] [bit] NULL,
	         [USI] [varchar](10) NULL,
	         [USM] [varchar](10) NULL,
	         [DATECREATE] [datetime] NULL,
	         [DATEEDIT] [datetime] NULL,
	         [TROW] [bit] NULL,
	         [TAGNR] [int] NULL
        ) ON [PRIMARY]

         SET ANSI_PADDING OFF
       ALTER TABLE [dbo].[Countries] ADD  CONSTRAINT [DF_Countries_DateCreate]  DEFAULT (getdate()) FOR [DateCreate]
       ALTER TABLE [dbo].[Countries] ADD  CONSTRAINT [DF_Countries_DateEdit]  DEFAULT (getdate()) FOR [DateEdit] 
	   PRINT ''Krijim tabele Countries'';';

	     SET @sSql1 = '
	  INSERT INTO Countries 
	        (KOD,PERSHKRIM,INTCOUNTRYKOD,INTISOKOD,INTCURRENCYKOD) 
	 VALUES (''ALB'',''ALBANIA'',''355'',''ALB'',''ALL'');';

          IF OBJECT_ID('Countries') IS NULL
		     BEGIN
               EXEC (@sSql);
			   EXEC (@sSql1);
             END;




-- FKSCR
   if dbo.Isd_FieldTableExists('FKSCR','KODREF')=0
      begin
        ALTER TABLE FKSCR ADD KODREF VARCHAR(60) NULL
        Print 'Shtim fusha KODREF ne FKSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FKSCR','TIPKLLREF')=0
      begin
        ALTER TABLE FKSCR ADD TIPKLLREF VARCHAR(10) NULL
        Print 'Shtim fusha TIPKLLREF ne FKSCR: Varchar(10)'
      end;

-- FKSTSCR
   if dbo.Isd_FieldTableExists('FKSTSCR','FAKLS')=0
      begin
        ALTER TABLE FKSTSCR ADD FAKLS VARCHAR(30) NULL
        Print 'Shtim fusha FAKLS ne FKSTSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FKSTSCR','FADESTIN')=0
      begin
        ALTER TABLE FKSTSCR ADD FADESTIN VARCHAR(30) NULL
        Print 'Shtim fusha FADESTIN ne FKSTSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FKSTSCR','FAART')=0
      begin
        ALTER TABLE FKSTSCR ADD FAART VARCHAR(30) NULL
        Print 'Shtim fusha FAART ne FKSTSCR: Varchar(30)'
      end;


-- CONFND
   if dbo.Isd_FieldTableExists('CONFND','EDITFROMCONTROL')=0
      begin
        ALTER TABLE CONFND ADD EDITFROMCONTROL VARCHAR(30) NULL
        Print 'Shtim fusha EditFromControl ne CONFND: Bit'
      end;

   if dbo.Isd_FieldTableExists('CONFND','STEPERRORLBL')=0      
      begin
        ALTER TABLE CONFND ADD STEPERRORLBL Float NULL
        Print 'Shtim fusha StepErrorLBL ne CONFND: Float'
      end;
   if dbo.Isd_FieldTableExists('CONFND','STEPERRORLSH')=0
      begin
        ALTER TABLE CONFND ADD STEPERRORLSH Float NULL
        Print 'Shtim fusha StepErrorLSH ne CONFND: Float'
      end;
   if dbo.Isd_FieldTableExists('CONFND','NMLLOGARI1')=0
      begin
        ALTER TABLE CONFND ADD NMLLOGARI1 Varchar(50) NULL
        Print 'Shtim fusha NMLlogari1 ne CONFND: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('CONFND','NMLLOGARI2')=0
      begin
        ALTER TABLE CONFND ADD NMLLOGARI2 Varchar(50) NULL
        Print 'Shtim fusha NMLlogari2 ne CONFND: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('CONFND','NMLLOGARI3')=0
      begin
        ALTER TABLE CONFND ADD NMLLOGARI3 Varchar(50) NULL
        Print 'Shtim fusha NMLlogari3 ne CONFND: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('CONFND','NMLLOGARI4')=0
      begin
        ALTER TABLE CONFND ADD NMLLOGARI4 Varchar(50) NULL
        Print 'Shtim fusha NMLlogari4 ne CONFND: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('CONFND','NMLLOGARI5')=0
      begin
        ALTER TABLE CONFND ADD NMLLOGARI5 Varchar(50) NULL
        Print 'Shtim fusha NMLlogari5 ne CONFND: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('CONFND','NMLLOGARI6')=0
      begin
        ALTER TABLE CONFND ADD NMLLOGARI6 Varchar(50) NULL
        Print 'Shtim fusha NMLlogari6 ne CONFND: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('CONFND','PERSHKRIMTREGETAR')=0
      begin
        ALTER TABLE CONFND ADD PERSHKRIMTREGETAR Varchar(100) NULL
        Print 'Shtim fusha PershkrimTregetar ne CONFND: Varchar(100)';
        Exec( 'UPDATE CONFND SET PERSHKRIMTREGETAR=PERSHKRIM');
      end;
   if dbo.Isd_FieldTableExists('CONFND','ListRefNotActiv')=0
      begin
        ALTER TABLE CONFND ADD ListRefNotActiv Int NULL
        Print 'Shtim fusha ListRefNotActiv ne CONFND: Int'
      end;
   if dbo.Isd_FieldTableExists('CONFND','DIRECTNRMAXREF')=0
      begin
        ALTER TABLE CONFND ADD DIRECTNRMAXREF Int NULL 
        Print 'Shtim fusha DIRECTNRMAXREF ne CONFND: Int'
      end;
   if dbo.Isd_FieldTableExists('CONFND','ACTIVMSGBACKUP')=0
      begin
        ALTER TABLE CONFND ADD ACTIVMSGBACKUP Bit NULL 
        Print 'Shtim fusha ACTIVMSGBACKUP ne CONFND: Bit'
      end;
   if dbo.Isd_FieldTableExists('CONFND','WEB')=0
      begin
        ALTER TABLE CONFND ADD WEB Varchar(150) NULL
        Print 'Shtim fusha WEB ne CONFND: Varchar(150)';
      end;
   if dbo.Isd_FieldTableExists('CONFND','VENDNDODHJE')=0
      begin
        ALTER TABLE CONFND ADD VENDNDODHJE Varchar(30) NULL 
        Print 'Shtim fusha VENDNDODHJE ne CONFND: Varchar(30)';
      end;


-- DITARVEPRIME
   if dbo.Isd_FieldTableExists('DITARVEPRIME','LGJOB')=0
      begin
        ALTER TABLE DITARVEPRIME ADD LGJOB VARCHAR(30) NULL
        Print 'Shtim fusha LGJOB ne DITARVEPRIME: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('DITARVEPRIME','KOMENT')=0
      begin
        ALTER TABLE DITARVEPRIME ADD KOMENT VARCHAR(100) NULL
        Print 'Shtim fusha KOMENT ne DITARVEPRIME: Varchar(100)'
      end;
   if dbo.Isd_FieldTableExists('DITARVEPRIME','DATECREATE')=0
      begin
        ALTER TABLE DITARVEPRIME ADD DATECREATE DATETIME NULL CONSTRAINT [DF_DITVEP_DATECREATE]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne DITARVEPRIME: DateTime'
      end;

-- FH
   if dbo.Isd_FieldTableExists('FH','VLEXTRA')=0
      begin
        ALTER TABLE FH ADD VLEXTRA FLOAT NULL
        Print 'Shtim fusha VLEXTRA ne FH: Float'
      end;
   if dbo.Isd_FieldTableExists('FH','EXTMGFIELD')=0
      begin
        ALTER TABLE FH ADD EXTMGFIELD INT NULL
        Print 'Shtim fusha EXTMGFIELD ne FH: Int'
      end;
   if dbo.Isd_FieldTableExists('FH','EXTMGVLORIGJ')=0
      begin
        ALTER TABLE FH ADD EXTMGVLORIGJ INT NULL
        Print 'Shtim fusha EXTMGVLORIGJ ne FH: Int'
      end;
   if dbo.Isd_FieldTableExists('FH','EXTMGFORME')=0
      begin
        ALTER TABLE FH ADD EXTMGFORME INT NULL
        Print 'Shtim fusha EXTMGFORME ne FH: Int'
      end;
   if dbo.Isd_FieldTableExists('FH','CMPRODCALCUL')=0
      begin
        ALTER TABLE FH ADD CMPRODCALCUL BIT NULL
        Print 'Shtim fusha CMPRODCALCUL ne FH: Bit'
      end;
   if dbo.Isd_FieldTableExists('FH','DATECREATE')=0
      begin
        ALTER TABLE FH ADD DATECREATE DATETIME NULL CONSTRAINT [DF_FH_DATECREATE]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne FH: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FH','DATEEDIT')=0
      begin
        ALTER TABLE FH ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_FH_DATEEDIT]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne FH: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FH','TAGRND')=0            
      begin
        ALTER TABLE FH ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne FH: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FH','NRRENDORORK')=0
      begin
        ALTER TABLE FH ADD NRRENDORORK Int NULL 
        Print 'Shtim fusha NRRENDORORK ne FH: Int'
      end;
   if dbo.Isd_FieldTableExists('FH','KONFIRM')=0
      begin
        ALTER TABLE FH ADD KONFIRM Bit NULL 
        Print 'Shtim fusha KONFIRM ne FH: Bit'
      end;


   if dbo.Isd_FieldTableExists('FD','CMPRODCALCUL')=0
      begin
        ALTER TABLE FD ADD CMPRODCALCUL BIT NULL
        Print 'Shtim fusha CMPRODCALCUL ne FD: Bit'
      end;
   if dbo.Isd_FieldTableExists('FD','DATECREATE')=0
      begin
        ALTER TABLE FD ADD DATECREATE DATETIME NULL CONSTRAINT [DF_FD_DATECREATE]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne FD: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FD','DATEEDIT')=0
      begin
        ALTER TABLE FD ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_FD_DATEEDIT]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne FD: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FD','TAGRND')=0            
      begin
        ALTER TABLE FD ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne FD: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FD','NRRENDORORK')=0
      begin
        ALTER TABLE FD ADD NRRENDORORK Int NULL 
        Print 'Shtim fusha NRRENDORORK ne FD: Int'
      end;
   if dbo.Isd_FieldTableExists('FD','KONFIRM')=0
      begin
        ALTER TABLE FD ADD KONFIRM Bit NULL 
        Print 'Shtim fusha KONFIRM ne FD: Bit'
      end;

-- FHSCR
   if dbo.Isd_FieldTableExists('FHSCR','PESHANET')=0
      begin
        ALTER TABLE FHSCR ADD PESHANET FLOAT NULL
        Print 'Shtim fusha PESHANET ne FHSCR: Float'
      end;
   if dbo.Isd_FieldTableExists('FHSCR','PESHABRT')=0
      begin
        ALTER TABLE FHSCR ADD PESHABRT FLOAT NULL
        Print 'Shtim fusha PESHABRT ne FHSCR: Float'
      end;
   if dbo.Isd_FieldTableExists('FHSCR','PROMOCKOD')=0
      begin
        ALTER TABLE FHSCR ADD PROMOCKOD Varchar(10) NULL
        Print 'Shtim fusha PROMOCKOD ne FHSCR: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('FHSCR','NRSERIAL')=0
      begin
        ALTER TABLE FHSCR ADD NRSERIAL Varchar(30) NULL
        Print 'Shtim fusha NRSERIAL ne FHSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FHSCR','GJENROWRVL')=0
      begin
        ALTER TABLE FHSCR ADD GJENROWRVL Bit NULL
        Print 'Shtim fusha GJENROWRVL ne FHSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('FHSCR','TAGRND')=0            
      begin
        ALTER TABLE FHSCR ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne FHSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FHSCR','CMIMUPDATE')=0            
      begin
        ALTER TABLE FHSCR ADD CMIMUPDATE Bit NULL 
        Print 'Shtim fusha CMIMUPDATE ne FHSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('FHSCR','ISAMB')=0
      begin
        ALTER TABLE FHSCR ADD ISAMB Bit NULL
        Print 'Shtim fusha ISAMB ne FHSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('FHSCR','PERSHKRIMKLF')=0
      begin
        ALTER TABLE FHSCR ADD PERSHKRIMKLF Varchar(100) NULL
        Print 'Shtim fusha PERSHKRIMKLF ne FHSCR: Varchar(100)'
      end;
   if dbo.Isd_FieldTableExists('FHSCR','DTDOK')=0
      begin
        ALTER TABLE FHSCR ADD DTDOK DateTime NULL
        Print 'Shtim fusha DTDOK ne FHSCR: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FHSCR','GJENROWAUTPRD')=0
      begin
        ALTER TABLE FHSCR ADD GJENROWAUTPRD bit NULL
        Print 'Shtim fusha GJENROWAUTPRD ne FHSCR: bit'
        SET @sSql = '   
           UPDATE B
              SET B.GJENROWAUTPRD=1
            FROM FH A INNER JOIN FHSCR  B  ON A.NRRENDOR=B.NRD
                      INNER JOIN FHSCR  C  ON A.NRRENDOR=C.NRD AND B.KARTLLG=C.KARTLLG AND ISNULL(C.GJENROWAUT,0)=0 
           WHERE ISNULL(B.GJENROWAUT,0)=1;
           PRINT ''Update fusha GJENROWAUTPRD ne FHSCR'';';
        EXEC (@sSql);   
      end;

    SELECT @i=Character_Maximum_Length    
      FROM Information_Schema.Columns  
     WHERE Table_Name = 'FHSCR' AND Column_Name='PROMOCTIP';
       SET @i = IsNull(@i,0);
        IF @i>0  And  @i<5
           ALTER TABLE FHSCR ALTER COLUMN PROMOCTIP VARCHAR(5) NULL;


-- FDSCR
   if dbo.Isd_FieldTableExists('FDSCR','PESHANET')=0
      begin
        ALTER TABLE FDSCR ADD PESHANET FLOAT NULL
        Print 'Shtim fusha PESHANET ne FDSCR: Float'
      end;
   if dbo.Isd_FieldTableExists('FDSCR','PESHABRT')=0
      begin
        ALTER TABLE FDSCR ADD PESHABRT FLOAT NULL
        Print 'Shtim fusha PESHABRT ne FDSCR: Float'
      end;
   if dbo.Isd_FieldTableExists('FDSCR','PROMOCKOD')=0
      begin
        ALTER TABLE FDSCR ADD PROMOCKOD Varchar(10) NULL
        Print 'Shtim fusha PROMOCKOD ne FDSCR: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('FDSCR','NRSERIAL')=0
      begin
        ALTER TABLE FDSCR ADD NRSERIAL Varchar(30) NULL
        Print 'Shtim fusha NRSERIAL ne FDSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FDSCR','GJENROWRVL')=0
      begin
        ALTER TABLE FDSCR ADD GJENROWRVL Bit NULL
        Print 'Shtim fusha GJENROWRVL ne FDSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('FDSCR','TAGRND')=0            
      begin
        ALTER TABLE FDSCR ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne FDSCR: Varchar(30)'
      end;

   if dbo.Isd_FieldTableExists('FDSCR','ISAMB')=0
      begin
        ALTER TABLE FDSCR ADD ISAMB Bit NULL
        Print 'Shtim fusha ISAMB ne FDSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('FDSCR','PERSHKRIMKLF')=0
      begin
        ALTER TABLE FDSCR ADD PERSHKRIMKLF Varchar(100) NULL
        Print 'Shtim fusha PERSHKRIMKLF ne FDSCR: Varchar(100)'
      end;
   if dbo.Isd_FieldTableExists('FDSCR','DTDOK')=0
      begin
        ALTER TABLE FDSCR ADD DTDOK DateTime NULL
        Print 'Shtim fusha DTDOK ne FDSCR: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FDSCR','GJENROWAUTPRD')=0
      begin
        ALTER TABLE FDSCR ADD GJENROWAUTPRD bit NULL
        Print 'Shtim fusha GJENROWAUTPRD ne FDSCR: bit'
        SET @sSql = '   
           UPDATE B
              SET B.GJENROWAUTPRD=1
            FROM FD A INNER JOIN FDSCR  B  ON A.NRRENDOR=B.NRD
                      INNER JOIN FDSCR  C  ON A.NRRENDOR=C.NRD AND B.KARTLLG=C.KARTLLG AND ISNULL(C.GJENROWAUT,0)=0 
           WHERE ISNULL(B.GJENROWAUT,0)=1;
           PRINT ''Update fusha GJENROWAUTPRD ne FDSCR'';';
        EXEC (@sSql);   
      end;

    SELECT @i=Character_Maximum_Length    
      FROM Information_Schema.Columns  
     WHERE Table_Name = 'FDSCR' AND Column_Name='PROMOCTIP';
       SET @i = IsNull(@i,0);
        IF @i>0  And  @i<5
           ALTER TABLE FDSCR ALTER COLUMN PROMOCTIP VARCHAR(5) NULL;

   if dbo.Isd_FieldTableExists('MAGAZINA','CMPRODCALCUL')=0
      begin
        ALTER TABLE MAGAZINA ADD CMPRODCALCUL BIT NULL
        Print 'Shtim fusha CMPRODCALCUL ne MAGAZINA: Bit'
      end;



-- FJ
   if dbo.Isd_FieldTableExists('FJ','IMPORTTAG')=0
      begin
        ALTER TABLE FJ ADD IMPORTTAG Varchar(5) NULL
        Print 'Shtim fusha IMPORTTAG ne FJ: Varchar(5)'
      end;
   if dbo.Isd_FieldTableExists('FJ','PAGESEARK')=0
      begin
        ALTER TABLE FJ ADD PAGESEARK Float NULL
        Print 'Shtim fusha PAGESEARK ne FJ: Float'
      end;
   if dbo.Isd_FieldTableExists('FJ','DATEARK')=0
      begin
        ALTER TABLE FJ ADD DATEARK Datetime NULL
        Print 'Shtim fusha DATEARK ne FJ: Datetime'
      end;
   if dbo.Isd_FieldTableExists('FJ','KLASIFIKIM1')=0
      begin
        ALTER TABLE FJ ADD KLASIFIKIM1 Varchar(30) NULL
        Print 'Shtim fusha KLASIFIKIM1 ne FJ: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FJ','DATECREATE')=0
      begin
        ALTER TABLE FJ ADD DATECREATE DATETIME NULL CONSTRAINT [DF_FJ_DATECREATE]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne FJ: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FJ','DATEEDIT')=0
      begin
        ALTER TABLE FJ ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_FJ_DATEEDIT]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne FJ: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FJ','KLASETVSH')=0
      begin
        ALTER TABLE FJ ADD KLASETVSH Varchar(10) NULL
        Print 'Shtim fusha KLASETVSH ne FJ: Varchar(10)'
        Exec (' UPDATE FJ SET KLASETVSH=CASE WHEN ISNULL(ISDG,0)=1 THEN ''SEXP'' ELSE ISNULL(KLASETVSH,'''') END;');
      end;
   if dbo.Isd_FieldTableExists('FJ','NRLINKAPL1')=0
      begin
        ALTER TABLE FJ ADD NRLINKAPL1 Varchar(30) NULL 
        Print 'Shtim fusha NRLINKAPL1 ne FJ: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FJ','NRRENDORFJT')=0
      begin
        ALTER TABLE FJ ADD NRRENDORFJT Int NULL 
        Print 'Shtim fusha NRRENDORFJT ne FJ: Int'
      end;

   if dbo.Isd_FieldTableExists('FJ','EXTIMPID')=0
      begin
        ALTER TABLE FJ ADD EXTIMPID Varchar(50) NULL 
        Print 'Shtim fusha EXTIMPID ne FJ: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('FJ','EXTIMPKOMENT')=0
      begin
        ALTER TABLE FJ ADD EXTIMPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTIMPKOMENT ne FJ: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FJ','EXTEXP')=0
      begin
        ALTER TABLE FJ ADD EXTEXP bit null 
        Print 'Shtim fusha EXTEXP ne FJ: bit'
      end;
   if dbo.Isd_FieldTableExists('FJ','EXTEXPKOMENT')=0
      begin
        ALTER TABLE FJ ADD EXTEXPKOMENT Varchar(30) null 
        Print 'Shtim fusha EXTEXPKOMENT ne FJ: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FJ','AGJENTSHITJELINK')=0
      begin
        ALTER TABLE FJ ADD AGJENTSHITJELINK Varchar(30) NULL
        Print 'Shtim fusha AGJENTSHITJELINK ne FJ: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FJ','KASEPRINT')=0
      begin
        ALTER TABLE FJ ADD KASEPRINT Bit NULL
        Print 'Shtim fusha KASEPRINT ne FJ: Bit'
      end;
   if dbo.Isd_FieldTableExists('FJ','KONFIRM')=0
      begin
        ALTER TABLE FJ ADD KONFIRM Bit NULL
        Print 'Shtim fusha KONFIRM ne FJ: Bit'
      end;
   if dbo.Isd_FieldTableExists('FJ','FISKODREASON')=0
      begin
        ALTER TABLE FJ ADD FISKODREASON Varchar(30) NULL
        Print 'Shtim fusha FISKODREASON ne FJ: Varchar(30)'
      end;


-- FJSCR
   --if dbo.Isd_FieldTableExists('FJSCR','PESHANET')=0
   --   begin
   --     ALTER TABLE FJSCR ADD PESHANET FLOAT NULL
   --     Print 'Shtim fusha PESHANET ne FJSCR: Float'
   --   end;
   --if dbo.Isd_FieldTableExists('FJSCR','PESHABRT')=0
   --   begin
   --     ALTER TABLE FJSCR ADD PESHABRT FLOAT NULL
   --     Print 'Shtim fusha PESHABRT ne FJSCR: Float'
   --   end;
   if dbo.Isd_FieldTableExists('FJSCR','KODTVSH')=0
      begin
        ALTER TABLE FJSCR ADD KODTVSH Varchar(30) NULL
        Print 'Shtim fusha KODTVSH ne FJSCR: Varchar(30)'
      end;

   if dbo.Isd_FieldTableExists('FJSCR','APLTVSH')=0
      begin
        ALTER TABLE FJSCR ADD APLTVSH Bit NULL
        Print 'Shtim fusha APLTVSH ne FJSCR: Bit';
        Exec (' UPDATE FJSCR SET APLTVSH=CASE WHEN ISNULL(VLTVSH,0)<>0 THEN 1 ELSE ISNULL(APLTVSH,0) END; ');
      end;
   if dbo.Isd_FieldTableExists('FJSCR','APLINVESTIM')=0
      begin
        ALTER TABLE FJSCR ADD APLINVESTIM Bit NULL
        Print 'Shtim fusha APLINVESTIM ne FJSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('FJSCR','CMSHREF')=0
      begin
        ALTER TABLE FJSCR ADD CMSHREF Float NULL
        Print 'Shtim fusha CMSHREF ne FJSCR: Float'
        Exec (' UPDATE FJSCR SET CMSHREF=CMSHZB0; ');
      end;
   if dbo.Isd_FieldTableExists('FJSCR','NRSERIAL')=0
      begin
        ALTER TABLE FJSCR ADD NRSERIAL Varchar(30) NULL
        Print 'Shtim fusha NRSERIAL ne FJSCR: Varchar(30)'
      end;

   if dbo.Isd_FieldTableExists('FJSCR','KODPRONESI')=0
      begin
        ALTER TABLE FJSCR ADD KODPRONESI Varchar(60) NULL
        Print 'Shtim fusha KODPRONESI ne FJSCR: Varchar(60)'
      end;
   if dbo.Isd_FieldTableExists('FJSCR','PERSHKRIMPRONESI')=0
      begin
        ALTER TABLE FJSCR ADD PERSHKRIMPRONESI Varchar(200) NULL
        Print 'Shtim fusha PERSHKRIMPRONESI ne FJSCR: Varchar(200)'
      end;
   if dbo.Isd_FieldTableExists('FJSCR','KODLOCATION')=0
      begin
        ALTER TABLE FJSCR ADD KODLOCATION Varchar(60) NULL
        Print 'Shtim fusha KODLOCATION ne FJSCR: Varchar(60)'
      end;
   if dbo.Isd_FieldTableExists('FJSCR','PERSHKRIMLOCATION')=0
      begin
        ALTER TABLE FJSCR ADD PERSHKRIMLOCATION Varchar(200) NULL
        Print 'Shtim fusha PERSHKRIMLOCATION ne FJSCR: Varchar(200)'
      end;
/* if dbo.Isd_FieldTableExists('FJSCR','KODFKL')=0
      begin
        ALTER TABLE FJSCR ADD KODFKL Varchar(60) NULL
        Print 'Shtim fusha KODFKL ne FJSCR: Varchar(60)'
      end;
   if dbo.Isd_FieldTableExists('FJSCR','PERSHKRIMFKL')=0
      begin
        ALTER TABLE FJSCR ADD PERSHKRIMFKL Varchar(200) NULL
        Print 'Shtim fusha PERSHKRIMFKL ne FJSCR: Varchar(200)'
      end; */
      
                                        
-- FF
   if dbo.Isd_FieldTableExists('FF','IMPORTTAG')=0
      begin
        ALTER TABLE FF ADD IMPORTTAG Varchar(5) NULL
        Print 'Shtim fusha IMPORTTAG ne FF: Varchar(5)'
      end;
   if dbo.Isd_FieldTableExists('FF','PAGESEARK')=0
      begin
        ALTER TABLE FF ADD PAGESEARK Float NULL
        Print 'Shtim fusha PAGESEARK ne FF: Float'
      end;
   if dbo.Isd_FieldTableExists('FF','DATEARK')=0
      begin
        ALTER TABLE FF ADD DATEARK Datetime NULL
        Print 'Shtim fusha DATEARK ne FF: Datetime'
      end;
   if dbo.Isd_FieldTableExists('FF','KLASIFIKIM1')=0
      begin
        ALTER TABLE FF ADD KLASIFIKIM1 Varchar(30) NULL
        Print 'Shtim fusha KLASIFIKIM1 ne FF: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FF','KLASETVSH')=0
      begin
        ALTER TABLE FF ADD KLASETVSH Varchar(10) NULL
        Print 'Shtim fusha KLASETVSH ne FF: Varchar(10)'
        Exec (' 
         UPDATE FF
            SET KLASETVSH=CASE WHEN ISNULL(DG.NRRENDORFAT,0)<>0 THEN ''FIMP'' ELSE ISNULL(KLASETVSH,'''') END
           FROM FF INNER JOIN DG ON FF.NRRENDOR=DG.NRRENDORFAT AND DG.TIPFT=''F''; ');
      end;
   if dbo.Isd_FieldTableExists('FF','NRRENDORFJT')=0
      begin
        ALTER TABLE FF ADD NRRENDORFJT Int NULL 
        Print 'Shtim fusha NRRENDORFJT ne FF: Int'
      end;
   if dbo.Isd_FieldTableExists('FF','EXTIMPID')=0
      begin
        ALTER TABLE FF ADD EXTIMPID Varchar(50) NULL 
        Print 'Shtim fusha EXTIMPID ne FF: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('FF','EXTIMPKOMENT')=0
      begin
        ALTER TABLE FF ADD EXTIMPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTIMPKOMENT ne FF: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FF','EXTEXP')=0
      begin
        ALTER TABLE FF ADD EXTEXP bit NULL 
        Print 'Shtim fusha EXTEXP ne FF: bit'
      end;
   if dbo.Isd_FieldTableExists('FF','EXTEXPKOMENT')=0
      begin
        ALTER TABLE FF ADD EXTEXPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTEXPKOMENT ne FF: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FF','DATECREATE')=0
      begin
        ALTER TABLE FF ADD DATECREATE DATETIME NULL CONSTRAINT [DF_FF_DATECREATE]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne FF: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FF','DATEEDIT')=0
      begin
        ALTER TABLE FF ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_FF_DATEEDIT]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne FF: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FF','TAGRND')=0            
      begin
        ALTER TABLE FF ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne FF: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FF','KONFIRM')=0            
      begin
        ALTER TABLE FF ADD KONFIRM Bit NULL 
        Print 'Shtim fusha KONFIRM ne FF: Bit'
      end;
      SELECT @Size = Character_Maximum_Length
        FROM Information_schema.columns
       WHERE Table_Name = 'FF'  And Column_Name='KLASIFIKIM';  
          if IsNull(@Size,0) < 25
             begin
               ALTER TABLE FF ALTER COLUMN KLASIFIKIM VARCHAR(25) Null;
               Print 'Ndryshim fusha KLASIFIKIM ne FF: Varchar(25)'
             end;

      SELECT @Size = Character_Maximum_Length
        FROM Information_schema.columns
       WHERE Table_Name = 'FF'  And Column_Name='NRSERIAL';  
          if IsNull(@Size,0) < 50
             begin
               ALTER TABLE FF ALTER COLUMN NRSERIAL VARCHAR(50) Null;
               Print 'Ndryshim fusha NRSERIAL ne FF: Varchar(50)'
             end;

      SELECT @Size = Character_Maximum_Length
        FROM Information_schema.columns
       WHERE Table_Name = 'FJ'  And Column_Name='NRSERIAL';  
          if IsNull(@Size,0) < 50
             begin
               ALTER TABLE FJ ALTER COLUMN NRSERIAL VARCHAR(50) Null;
               Print 'Ndryshim fusha NRSERIAL ne FJ: Varchar(50)'
             end;

      SELECT @Size = Character_Maximum_Length
        FROM Information_schema.columns
       WHERE Table_Name = 'FD'  And Column_Name='NRSERIAL';  
          if IsNull(@Size,0) < 50
             begin
               ALTER TABLE FD ALTER COLUMN NRSERIAL VARCHAR(50) Null;
               Print 'Ndryshim fusha NRSERIAL ne FD: Varchar(50)'
             end;

      SELECT @Size = Character_Maximum_Length
        FROM Information_schema.columns
       WHERE Table_Name = 'FH'  And Column_Name='NRSERIAL';  
          if IsNull(@Size,0) < 50
             begin
               ALTER TABLE FH ALTER COLUMN NRSERIAL VARCHAR(50) Null;
               Print 'Ndryshim fusha NRSERIAL ne FH: Varchar(50)'
             end;
    
-- FFSCR
   --if dbo.Isd_FieldTableExists('FFSCR','PESHANET')=0
   --   begin
   --     ALTER TABLE FFSCR ADD PESHANET FLOAT NULL
   --     Print 'Shtim fusha PESHANET ne FFSCR: Float'
   --   end;
   --if dbo.Isd_FieldTableExists('FFSCR','PESHABRT')=0
   --   begin
   --     ALTER TABLE FFSCR ADD PESHABRT FLOAT NULL
   --     Print 'Shtim fusha PESHABRT ne FFSCR: Float'
   --   end;
   if dbo.Isd_FieldTableExists('FFSCR','KODTVSH')=0
      begin
        ALTER TABLE FFSCR ADD KODTVSH Varchar(30) NULL
        Print 'Shtim fusha KODTVSH ne FFSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FFSCR','APLTVSH')=0
      begin
        ALTER TABLE FFSCR ADD APLTVSH Bit NULL
        Print 'Shtim fusha APLTVSH ne FFSCR: Bit'
        Exec (' UPDATE FFSCR SET APLTVSH=CASE WHEN ISNULL(VLTVSH,0)<>0 THEN 1 ELSE ISNULL(APLTVSH,0) END; ');
      end;
   if dbo.Isd_FieldTableExists('FFSCR','APLINVESTIM')=0
      begin
        ALTER TABLE FFSCR ADD APLINVESTIM Bit NULL
        Print 'Shtim fusha APLINVESTIM ne FFSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('FFSCR','CMSHREF')=0
      begin
        ALTER TABLE FFSCR ADD CMSHREF Float NULL
        Print 'Shtim fusha CMSHREF ne FFSCR: Float'
        Exec (' UPDATE FFSCR SET CMSHREF=CMSHZB0 ');
      end;
   if dbo.Isd_FieldTableExists('FFSCR','NRSERIAL')=0
      begin
        ALTER TABLE FFSCR ADD NRSERIAL Varchar(30) NULL
        Print 'Shtim fusha NRSERIAL ne FFSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FFSCR','TAGRND')=0            
      begin
        ALTER TABLE FFSCR ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne FFSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FFSCR','NRDITAR')=0            
      begin
        ALTER TABLE FFSCR ADD NRDITAR Int NULL 
        Print 'Shtim fusha NRDITAR ne FFSCR: Int'
      end;
   if dbo.Isd_FieldTableExists('FFSCR','NRDOKREF')=0       -- 9.
      begin
        ALTER TABLE FFSCR ADD NRDOKREF Varchar(30) NULL
        Print 'Shtim fusha NRDOKREF ne FFSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FFSCR','DATEDOKREF')=0     -- 10.
      begin
        ALTER TABLE FFSCR ADD DATEDOKREF Datetime NULL
        Print 'Shtim fusha DATEDOKREF ne FFSCR: Datetime'
      end;
   if dbo.Isd_FieldTableExists('FFSCR','TIPREF')=0         -- 11.
      begin
        ALTER TABLE FFSCR ADD TIPREF Varchar(10) NULL
        Print 'Shtim fusha TIPREF ne FFSCR: Varchar(10)'
      end;

   if dbo.Isd_FieldTableExists('FFSCR','KODPRONESI')=0
      begin
        ALTER TABLE FFSCR ADD KODPRONESI Varchar(60) NULL
        Print 'Shtim fusha KODPRONESI ne FFSCR: Varchar(60)'
      end;
   if dbo.Isd_FieldTableExists('FFSCR','PERSHKRIMPRONESI')=0
      begin
        ALTER TABLE FFSCR ADD PERSHKRIMPRONESI Varchar(200) NULL
        Print 'Shtim fusha PERSHKRIMPRONESI ne FFSCR: Varchar(200)'
      end;
   if dbo.Isd_FieldTableExists('FFSCR','KODLOCATION')=0
      begin
        ALTER TABLE FFSCR ADD KODLOCATION Varchar(60) NULL
        Print 'Shtim fusha KODLOCATION ne FFSCR: Varchar(60)'
      end;
   if dbo.Isd_FieldTableExists('FFSCR','PERSHKRIMLOCATION')=0
      begin
        ALTER TABLE FFSCR ADD PERSHKRIMLOCATION Varchar(200) NULL
        Print 'Shtim fusha PERSHKRIMLOCATION ne FFSCR: Varchar(200)'
      end;
/* if dbo.Isd_FieldTableExists('FFSCR','KODFKL')=0
      begin
        ALTER TABLE FFSCR ADD KODFKL Varchar(60) NULL
        Print 'Shtim fusha KODFKL ne FFSCR: Varchar(60)'
      end;
   if dbo.Isd_FieldTableExists('FFSCR','PERSHKRIMFKL')=0
      begin
        ALTER TABLE FFSCR ADD PERSHKRIMFKL Varchar(200) NULL
        Print 'Shtim fusha PERSHKRIMFKL ne FFSCR: Varchar(200)'
      end;*/


-- FJT
   if dbo.Isd_FieldTableExists('FJT','KLASIFIKIM1')=0
      begin
        ALTER TABLE FJT ADD KLASIFIKIM1 Varchar(30) NULL
        Print 'Shtim fusha KLASIFIKIM1 ne FJT: Varchar(25)'
      end;
   if dbo.Isd_FieldTableExists('FJT','KLASETVSH')=0
      begin
        ALTER TABLE FJT ADD KLASETVSH Varchar(10) NULL
        Print 'Shtim fusha KLASETVSH ne FJT: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('FJT','KONFIRM')=0
      begin
        ALTER TABLE FJT ADD KONFIRM Bit NULL
        Print 'Shtim fusha KONFIRM ne FJT: Bit'
      end;

      SELECT @Size = Character_Maximum_Length
        FROM Information_schema.columns
       WHERE Table_Name = 'FJT'  And Column_Name='KLASIFIKIM';  
          if IsNull(@Size,0) < 30
             begin
               ALTER TABLE FJT ALTER COLUMN KLASIFIKIM VARCHAR(30) Null;
               Print 'Ndryshim fusha KLASIFIKIM ne FJT: Varchar(30)'
             end;
      SELECT @Size = Character_Maximum_Length
        FROM Information_schema.columns
       WHERE Table_Name = 'FJT'  And Column_Name='KLASIFIKIM1';  
          if IsNull(@Size,0) < 30
             begin
               ALTER TABLE FJT ALTER COLUMN KLASIFIKIM1 VARCHAR(30) Null;
               Print 'Ndryshim fusha KLASIFIKIM1 ne FJT: Varchar(30)'
             end;
   if dbo.Isd_FieldTableExists('FJT','NRRENDORFJT')=0
      begin
        ALTER TABLE FJT ADD NRRENDORFJT Int NULL 
        Print 'Shtim fusha NRRENDORFJT ne FJT: Int'
      end;
   if dbo.Isd_FieldTableExists('FJT','NRRENDORFJT')=0
      begin
        ALTER TABLE FJT ADD NRRENDORFJT Int NULL 
        Print 'Shtim fusha NRRENDORFJT ne FJT: Int'
      end;
   if dbo.Isd_FieldTableExists('FJT','EXTIMPID')=0
      begin
        ALTER TABLE FJT ADD EXTIMPID Varchar(50) NULL 
        Print 'Shtim fusha EXTIMPID ne FJT: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('FJT','EXTIMPKOMENT')=0
      begin
        ALTER TABLE FJT ADD EXTIMPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTIMPKOMENT ne FJT: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FJT','EXTEXP')=0
      begin
        ALTER TABLE FJT ADD EXTEXP bit NULL 
        Print 'Shtim fusha EXTEXP ne FJT: bit'
      end;
   if dbo.Isd_FieldTableExists('FJT','EXTEXPKOMENT')=0
      begin
        ALTER TABLE FJT ADD EXTEXPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTEXPKOMENT ne FJT: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FJT','AGJENTSHITJELINK')=0
      begin
        ALTER TABLE FJT ADD AGJENTSHITJELINK Varchar(30) NULL
        Print 'Shtim fusha AGJENTSHITJELINK ne FJT: Varchar(30)'
      end;


-- FJTSCR
   --if dbo.Isd_FieldTableExists('FJTSCR','PESHANET')=0
   --   begin
   --     ALTER TABLE FJTSCR ADD PESHANET FLOAT NULL
   --     Print 'Shtim fusha PESHANET ne FJTSCR: Float'
   --   end;
   --if dbo.Isd_FieldTableExists('FJTSCR','PESHABRT')=0
   --   begin
   --     ALTER TABLE FJTSCR ADD PESHABRT FLOAT NULL
   --     Print 'Shtim fusha PESHABRT ne FJTSCR: Float'
   --   end;
   if dbo.Isd_FieldTableExists('FJTSCR','KODTVSH')=0
      begin
        ALTER TABLE FJTSCR ADD KODTVSH Varchar(30) NULL
        Print 'Shtim fusha KODTVSH ne FJTSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FJTSCR','APLTVSH')=0
      begin
        ALTER TABLE FJTSCR ADD APLTVSH Bit NULL
        Print 'Shtim fusha APLTVSH ne FJTSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('FJTSCR','APLINVESTIM')=0
      begin
        ALTER TABLE FJTSCR ADD APLINVESTIM Bit NULL
        Print 'Shtim fusha APLINVESTIM ne FJTSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('FJTSCR','CMSHREF')=0
      begin
        ALTER TABLE FJTSCR ADD CMSHREF Float NULL
        Print 'Shtim fusha CMSHREF ne FJTSCR: Float'
        Exec (' UPDATE FJTSCR SET CMSHREF=CMSHZB0 ');
      end;
   if dbo.Isd_FieldTableExists('FJTSCR','NRSERIAL')=0
      begin
        ALTER TABLE FJTSCR ADD NRSERIAL Varchar(30) NULL
        Print 'Shtim fusha NRSERIAL ne FJTSCR: Varchar(30)'
      end;


-- OFK
   if dbo.Isd_FieldTableExists('OFK','KLASIFIKIM1')=0
      begin
        ALTER TABLE OFK ADD KLASIFIKIM1 Varchar(30) NULL
        Print 'Shtim fusha KLASIFIKIM1 ne OFK: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('OFK','KLASETVSH')=0
      begin
        ALTER TABLE OFK ADD KLASETVSH Varchar(10) NULL
        Print 'Shtim fusha KLASETVSH ne OFK: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('OFK','AGJENTSHITJE')=0
      begin
        ALTER TABLE OFK ADD AGJENTSHITJE Varchar(30) NULL
        Print 'Shtim fusha AGJENTSHITJE ne OFK: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('OFK','AGJENTSHITJELINK')=0
      begin
        ALTER TABLE OFK ADD AGJENTSHITJELINK Varchar(30) NULL
        Print 'Shtim fusha AGJENTSHITJELINK ne OFK: Varchar(30)'
      end;

   if dbo.Isd_FieldTableExists('OFK','KONFIRM')=0
      begin
        ALTER TABLE OFK ADD KONFIRM Bit NULL
        Print 'Shtim fusha KONFIRM ne OFK: Bit'
      end;

      SELECT @Size = Character_Maximum_Length
        FROM Information_schema.columns
       WHERE Table_Name = 'OFK'  And Column_Name='KLASIFIKIM';  
          if IsNull(@Size,0) < 30
             begin
               ALTER TABLE OFK ALTER COLUMN KLASIFIKIM VARCHAR(30) Null;
               Print 'Ndryshim fusha KLASIFIKIM ne OFK: Varchar(30)'
             end;
      SELECT @Size = Character_Maximum_Length
        FROM Information_schema.columns
       WHERE Table_Name = 'OFK'  And Column_Name='KLASIFIKIM1';  
          if IsNull(@Size,0) < 30
             begin
               ALTER TABLE OFK ALTER COLUMN KLASIFIKIM1 VARCHAR(30) Null;
               Print 'Ndryshim fusha KLASIFIKIM1 ne OFK: Varchar(30)'
             end;
   if dbo.Isd_FieldTableExists('OFK','NRRENDORFJT')=0
      begin
        ALTER TABLE OFK ADD NRRENDORFJT Int NULL 
        Print 'Shtim fusha NRRENDORFJT ne OFK: Int'
      end;
   if dbo.Isd_FieldTableExists('OFK','EXTIMPID')=0
      begin
        ALTER TABLE OFK ADD EXTIMPID Varchar(50) NULL 
        Print 'Shtim fusha EXTIMPID ne OFK: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('OFK','EXTIMPKOMENT')=0
      begin
        ALTER TABLE OFK ADD EXTIMPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTIMPKOMENT ne OFK: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('OFK','EXTEXP')=0
      begin
        ALTER TABLE OFK ADD EXTEXP bit null 
        Print 'Shtim fusha EXTEXP ne OFK: bit'
      end;
   if dbo.Isd_FieldTableExists('OFK','EXTEXPKOMENT')=0
      begin
        ALTER TABLE OFK ADD EXTEXPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTEXPKOMENT ne OFK: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('OFK','DATECREATE')=0
      begin
        ALTER TABLE OFK ADD DATECREATE DATETIME NULL CONSTRAINT [DF_OFK_DATECREATE]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne OFK: DateTime'
      end;
   if dbo.Isd_FieldTableExists('OFK','DATEEDIT')=0
      begin
        ALTER TABLE OFK ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_OFK_DATEEDIT]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne OFK: DateTime'
      end;
   if dbo.Isd_FieldTableExists('OFK','TAGRND')=0            
      begin
        ALTER TABLE OFK ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne OFK: Varchar(30)'
      end;


-- OFKSCR
   --if dbo.Isd_FieldTableExists('OFKSCR','PESHANET')=0
   --   begin
   --     ALTER TABLE OFKSCR ADD PESHANET FLOAT NULL
   --     Print 'Shtim fusha PESHANET ne OFKSCR: Float'
   --   end;
   --if dbo.Isd_FieldTableExists('OFKSCR','PESHABRT')=0
   --   begin
   --     ALTER TABLE OFKSCR ADD PESHABRT FLOAT NULL
   --     Print 'Shtim fusha PESHABRT ne OFKSCR: Float'
   --   end;
   if dbo.Isd_FieldTableExists('OFKSCR','KODTVSH')=0
      begin
        ALTER TABLE OFKSCR ADD KODTVSH Varchar(30) NULL
        Print 'Shtim fusha KODTVSH ne OFKSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('OFKSCR','APLTVSH')=0
      begin
        ALTER TABLE OFKSCR ADD APLTVSH Bit NULL
        Print 'Shtim fusha APLTVSH ne OFKSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('OFKSCR','APLINVESTIM')=0
      begin
        ALTER TABLE OFKSCR ADD APLINVESTIM Bit NULL
        Print 'Shtim fusha APLINVESTIM ne OFKSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('OFKSCR','CMSHREF')=0
      begin
        ALTER TABLE OFKSCR ADD CMSHREF Float NULL
        Print 'Shtim fusha CMSHREF ne OFKSCR: Float'
        Exec (' UPDATE OFKSCR SET CMSHREF = CMSHZB0 ');
      end;
   if dbo.Isd_FieldTableExists('OFKSCR','NRSERIAL')=0
      begin
        ALTER TABLE OFKSCR ADD NRSERIAL Varchar(30) NULL
        Print 'Shtim fusha NRSERIAL ne OFKSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('OFKSCR','KOEFICIENT')=0
      begin
        ALTER TABLE OFKSCR ADD KOEFICIENT Float NULL
        Print 'Shtim fusha KOEFICIENT ne OFKSCR: Float'
      end;
   if dbo.Isd_FieldTableExists('OFKSCR','TAGRND')=0            
      begin
        ALTER TABLE OFKSCR ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne OFKSCR: Varchar(30)'
      end;


-- ORK
   if dbo.Isd_FieldTableExists('ORK','KLASIFIKIM1')=0
      begin
        ALTER TABLE ORK ADD KLASIFIKIM1 Varchar(30) NULL
        Print 'Shtim fusha KLASIFIKIM1 ne ORK: Varchar(25)'
      end;
   if dbo.Isd_FieldTableExists('ORK','KLASETVSH')=0
      begin
        ALTER TABLE ORK ADD KLASETVSH Varchar(10) NULL
        Print 'Shtim fusha KLASETVSH ne ORK: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('ORK','AGJENTSHITJE')=0
      begin
        ALTER TABLE ORK ADD AGJENTSHITJE Varchar(30) NULL
        Print 'Shtim fusha AGJENTSHITJE ne ORK: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('ORK','AGJENTSHITJELINK')=0
      begin
        ALTER TABLE ORK ADD AGJENTSHITJELINK Varchar(30) NULL
        Print 'Shtim fusha AGJENTSHITJELINK ne ORK: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('ORK','KONFIRM')=0
      begin
        ALTER TABLE ORK ADD KONFIRM Bit NULL
        Print 'Shtim fusha KONFIRM ne ORK: Bit'
      end;


      SELECT @Size = Character_Maximum_Length
        FROM Information_schema.columns
       WHERE Table_Name = 'ORK'  And Column_Name='KLASIFIKIM';  
          if IsNull(@Size,0) < 30
             begin
               ALTER TABLE ORK ALTER COLUMN KLASIFIKIM VARCHAR(30) Null;
               Print 'Ndryshim fusha KLASIFIKIM ne ORK: Varchar(30)'
             end;
      SELECT @Size = Character_Maximum_Length
        FROM Information_schema.columns
       WHERE Table_Name = 'ORK'  And Column_Name='KLASIFIKIM1';  
          if IsNull(@Size,0) < 30
             begin
               ALTER TABLE ORK ALTER COLUMN KLASIFIKIM1 VARCHAR(30) Null;
               Print 'Ndryshim fusha KLASIFIKIM1 ne ORK: Varchar(30)'
             end;
   if dbo.Isd_FieldTableExists('ORK','NRRENDORFJT')=0
      begin
        ALTER TABLE ORK ADD NRRENDORFJT Int NULL 
        Print 'Shtim fusha NRRENDORFJT ne ORK: Int'
      end;
   if dbo.Isd_FieldTableExists('ORK','EXTIMPID')=0
      begin
        ALTER TABLE ORK ADD EXTIMPID Varchar(50) NULL 
        Print 'Shtim fusha EXTIMPID ne ORK: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('ORK','EXTIMPKOMENT')=0
      begin
        ALTER TABLE ORK ADD EXTIMPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTIMPKOMENT ne ORK: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('ORK','EXTEXP')=0
      begin
        ALTER TABLE ORK ADD EXTEXP bit null
        Print 'Shtim fusha EXTEXP ne ORK: bit'
      end;
   if dbo.Isd_FieldTableExists('ORK','EXTEXPKOMENT')=0
      begin
        ALTER TABLE ORK ADD EXTEXPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTEXPKOMENT ne ORK: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('ORK','DATECREATE')=0
      begin
        ALTER TABLE ORK ADD DATECREATE DATETIME NULL CONSTRAINT [DF_ORK_DATECREATE]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne ORK: DateTime'
      end;
   if dbo.Isd_FieldTableExists('ORK','DATEEDIT')=0
      begin
        ALTER TABLE ORK ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_ORK_DATEEDIT]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne ORK: DateTime'
      end;
   if dbo.Isd_FieldTableExists('ORK','TAGRND')=0            
      begin
        ALTER TABLE ORK ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne ORK: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('ORK','CREATEPIVOTORD')=0            
      begin
        ALTER TABLE ORK ADD CREATEPIVOTORD Bit NULL 
        Print 'Shtim fusha CREATEPIVOTORD ne ORK: Bit'
      end;



-- ORKSCR

   --if dbo.Isd_FieldTableExists('ORKSCR','PESHANET')=0
   --   begin
   --     ALTER TABLE ORKSCR ADD PESHANET FLOAT NULL
   --     Print 'Shtim fusha PESHANET ne ORKSCR: Float'
   --   end;
   --if dbo.Isd_FieldTableExists('ORKSCR','PESHABRT')=0
   --   begin
   --     ALTER TABLE ORKSCR ADD PESHABRT FLOAT NULL
   --     Print 'Shtim fusha PESHABRT ne ORKSCR: Float'
   --   end;
   if dbo.Isd_FieldTableExists('ORKSCR','KODTVSH')=0
      begin
        ALTER TABLE ORKSCR ADD KODTVSH Varchar(30) NULL
        Print 'Shtim fusha KODTVSH ne ORKSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('ORKSCR','APLTVSH')=0
      begin
        ALTER TABLE ORKSCR ADD APLTVSH Bit NULL
        Print 'Shtim fusha APLTVSH ne ORKSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('ORKSCR','APLINVESTIM')=0
      begin
        ALTER TABLE ORKSCR ADD APLINVESTIM Bit NULL
        Print 'Shtim fusha APLINVESTIM ne ORKSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('ORKSCR','CMSHREF')=0
      begin
        ALTER TABLE ORKSCR ADD CMSHREF Float NULL
        Print 'Shtim fusha CMSHREF ne ORKSCR: Float'
        Exec (' UPDATE ORKSCR SET CMSHREF = CMSHZB0 ');
      end;
   if dbo.Isd_FieldTableExists('ORKSCR','NRSERIAL')=0
      begin
        ALTER TABLE ORKSCR ADD NRSERIAL Varchar(30) NULL
        Print 'Shtim fusha NRSERIAL ne ORKSCR: Varchar(30)'
      end;                               
   if dbo.Isd_FieldTableExists('ORKSCR','KOEFICIENT')=0
      begin
        ALTER TABLE ORKSCR ADD KOEFICIENT Float NULL
        Print 'Shtim fusha KOEFICIENT ne ORKSCR: Float'
      end;
   if dbo.Isd_FieldTableExists('ORKSCR','TAGRND')=0            
      begin
        ALTER TABLE ORKSCR ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne ORKSCR: Varchar(30)'
      end;


-- SM
   if dbo.Isd_FieldTableExists('SM','KLASIFIKIM1')=0
      begin
        ALTER TABLE SM ADD KLASIFIKIM1 Varchar(30) NULL
        Print 'Shtim fusha KLASIFIKIM1 ne SM: Varchar(25)'
      end;
   if dbo.Isd_FieldTableExists('SM','KLASETVSH')=0
      begin
        ALTER TABLE SM ADD KLASETVSH Varchar(10) NULL
        Print 'Shtim fusha KLASETVSH ne SM: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('SM','PAGESEARK')=0
      begin
        ALTER TABLE SM ADD PAGESEARK Float NULL
        Print 'Shtim fusha PAGESEARK ne SM: Float'
      end;
   if dbo.Isd_FieldTableExists('SM','DATEARK')=0
      begin
        ALTER TABLE SM ADD DATEARK Datetime NULL
        Print 'Shtim fusha DATEARK ne SM: Datetime'
      end;
   if dbo.Isd_FieldTableExists('SM','NRRENDORFJT')=0
      begin
        ALTER TABLE SM ADD NRRENDORFJT Int NULL 
        Print 'Shtim fusha NRRENDORFJT ne SM: Int'
      end;
   if dbo.Isd_FieldTableExists('SM','TAGRND')=0            
      begin
        ALTER TABLE SM ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne SM: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('SM','AGJENTSHITJELINK')=0
      begin
        ALTER TABLE SM ADD AGJENTSHITJELINK Varchar(30) NULL
        Print 'Shtim fusha AGJENTSHITJELINK ne SM: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('SM','KASEPRINT')=0
      begin
        ALTER TABLE SM ADD KASEPRINT Bit NULL
        Print 'Shtim fusha KASEPRINT ne SM: Bit'
      end;
   if dbo.Isd_FieldTableExists('SM','KONFIRM')=0
      begin
        ALTER TABLE SM ADD KONFIRM Bit NULL
        Print 'Shtim fusha KONFIRM ne SM: Bit'
      end;


-- SMSCR
   --if dbo.Isd_FieldTableExists('SMSCR','PESHANET')=0
   --   begin
   --     ALTER TABLE SMSCR ADD PESHANET FLOAT NULL
   --     Print 'Shtim fusha PESHANET ne SMSCR: Float'
   --   end;
   --if dbo.Isd_FieldTableExists('SMSCR','PESHABRT')=0
   --   begin
   --     ALTER TABLE SMSCR ADD PESHABRT FLOAT NULL
   --     Print 'Shtim fusha PESHABRT ne SMSCR: Float'
   --   end;
   if dbo.Isd_FieldTableExists('SMSCR','KODTVSH')=0
      begin
        ALTER TABLE SMSCR ADD KODTVSH Varchar(30) NULL
        Print 'Shtim fusha KODTVSH ne SMSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('SMSCR','APLTVSH')=0
      begin
        ALTER TABLE SMSCR ADD APLTVSH Bit NULL
        Print 'Shtim fusha APLTVSH ne SMSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('SMSCR','APLINVESTIM')=0
      begin
        ALTER TABLE SMSCR ADD APLINVESTIM Bit NULL
        Print 'Shtim fusha APLINVESTIM ne SMSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('SMSCR','CMSHREF')=0
      begin
        ALTER TABLE SMSCR ADD CMSHREF Float NULL
        Print 'Shtim fusha CMSHREF ne SMSCR: Float'
        Exec (' UPDATE SMSCR SET CMSHREF = CMSHZB0 ');
      end;
   if dbo.Isd_FieldTableExists('SMSCR','PROMOC')=0
      begin
        ALTER TABLE SMSCR ADD PROMOC Bit NULL
        Print 'Shtim fusha PROMOC ne SMSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('SMSCR','PROMOCTIP')=0
      begin
        ALTER TABLE SMSCR ADD PROMOCTIP Varchar(5) NULL
        Print 'Shtim fusha PROMOCTIP ne SMSCR: Varchar(5)'
      end;
   if dbo.Isd_FieldTableExists('SMSCR','PROMOCKOD')=0
      begin
        ALTER TABLE SMSCR ADD PROMOCKOD Varchar(10) NULL
        Print 'Shtim fusha PROMOCKOD ne SMSCR: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('SMSCR','TIMED')=0
      begin
        ALTER TABLE SMSCR ADD TIMED Datetime
        Print 'Shtim fusha TIMED ne SMSCR: Datetime'
      end;
   if dbo.Isd_FieldTableExists('SMSCR','TIMEI')=0
      begin
        ALTER TABLE SMSCR ADD TIMEI Datetime
        Print 'Shtim fusha TIMEI ne SMSCR: Datetime'
      end;
   if dbo.Isd_FieldTableExists('SMSCR','TIMEM')=0
      begin
        ALTER TABLE SMSCR ADD TIMEM Datetime
        Print 'Shtim fusha TIMEM ne SMSCR: Datetime'
      end;
   if dbo.Isd_FieldTableExists('SMSCR','NRSERIAL')=0
      begin
        ALTER TABLE SMSCR ADD NRSERIAL Varchar(30) NULL
        Print 'Shtim fusha NRSERIAL ne SMSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('SMSCR','TAGRND')=0            
      begin
        ALTER TABLE SMSCR ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne SMSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('SMSCR','VLERASM')=0            
      begin
        ALTER TABLE SMSCR ADD VLERASM Float NULL 
        Print 'Shtim fusha VLERASM ne SMSCR: Float'
      end;

      

-- SMBAK
   if dbo.Isd_FieldTableExists('SMBAK','KLASIFIKIM1')=0
      begin
        ALTER TABLE SMBAK ADD KLASIFIKIM1 Varchar(30) NULL
        Print 'Shtim fusha KLASIFIKIM1 ne SMBAK: Varchar(25)'
      end;
   if dbo.Isd_FieldTableExists('SMBAK','KLASETVSH')=0
      begin
        ALTER TABLE SMBAK ADD KLASETVSH Varchar(10) NULL
        Print 'Shtim fusha KLASETVSH ne SMBAK: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('SMBAK','PAGESEARK')=0
      begin
        ALTER TABLE SMBAK ADD PAGESEARK Float NULL
        Print 'Shtim fusha PAGESEARK ne SMBAK: Float'
      end;
   if dbo.Isd_FieldTableExists('SMBAK','DATEARK')=0
      begin
        ALTER TABLE SMBAK ADD DATEARK Datetime NULL
        Print 'Shtim fusha DATEARK ne SMBAK: Datetime'
      end;
   if dbo.Isd_FieldTableExists('SMBAK','NRRENDORFJT')=0
      begin
        ALTER TABLE SMBAK ADD NRRENDORFJT Int NULL 
        Print 'Shtim fusha NRRENDORFJT ne SMBAK: Int'
      end;
   if dbo.Isd_FieldTableExists('SMBAK','TAGRND')=0            
      begin
        ALTER TABLE SMBAK ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne SMBAK: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('SMBAK','KASEPRINT')=0
      begin
        ALTER TABLE SMBAK ADD KASEPRINT Bit NULL
        Print 'Shtim fusha KASEPRINT ne SMBAK: Bit'
      end;
   if dbo.Isd_FieldTableExists('SMBAK','AGJENTSHITJELINK')=0
      begin
        ALTER TABLE SMBAK ADD AGJENTSHITJELINK Varchar(30) NULL
        Print 'Shtim fusha AGJENTSHITJELINK ne SMBAK: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('SMBAK','KONFIRM')=0
      begin
        ALTER TABLE SMBAK ADD KONFIRM Bit NULL
        Print 'Shtim fusha KONFIRM ne SMBAK: Bit'
      end;
      

-- SMBAKSCR
   --if dbo.Isd_FieldTableExists('SMBAKSCR','PESHANET')=0
   --   begin
   --     ALTER TABLE SMBAKSCR ADD PESHANET FLOAT NULL
   --     Print 'Shtim fusha PESHANET ne SMBAKSCR: Float'
   --   end;
   --if dbo.Isd_FieldTableExists('SMBAKSCR','PESHABRT')=0
   --   begin
   --     ALTER TABLE SMBAKSCR ADD PESHABRT FLOAT NULL
   --     Print 'Shtim fusha PESHABRT ne SMBAKSCR: Float'
   --   end;
   if dbo.Isd_FieldTableExists('SMBAKSCR','KODTVSH')=0
      begin
        ALTER TABLE SMBAKSCR ADD KODTVSH Varchar(30) NULL
        Print 'Shtim fusha KODTVSH ne SMBAKSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('SMBAKSCR','APLTVSH')=0
      begin
        ALTER TABLE SMBAKSCR ADD APLTVSH Bit NULL
        Print 'Shtim fusha APLTVSH ne SMBAKSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('SMBAKSCR','APLINVESTIM')=0
      begin
        ALTER TABLE SMBAKSCR ADD APLINVESTIM Bit NULL
        Print 'Shtim fusha APLINVESTIM ne SMBAKSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('SMBAKSCR','CMSHREF')=0
      begin
        ALTER TABLE SMBAKSCR ADD CMSHREF Float NULL
        Print 'Shtim fusha CMSHREF ne SMBAKSCR: Float'
        Exec (' UPDATE SMBAKSCR SET CMSHREF = CMSHZB0 ');
      end;
   if dbo.Isd_FieldTableExists('SMBAKSCR','PROMOC')=0
      begin
        ALTER TABLE SMBAKSCR ADD PROMOC Bit NULL
        Print 'Shtim fusha PROMOC ne SMBAKSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('SMBAKSCR','PROMOCTIP')=0
      begin
        ALTER TABLE SMBAKSCR ADD PROMOCTIP Varchar(5) NULL
        Print 'Shtim fusha PROMOCTIP ne SMBAKSCR: Varchar(5)'
      end;
   if dbo.Isd_FieldTableExists('SMBAKSCR','PROMOCKOD')=0
      begin
        ALTER TABLE SMBAKSCR ADD PROMOCKOD Varchar(10) NULL
        Print 'Shtim fusha PROMOCKOD ne SMBAKSCR: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('SMBAKSCR','TIMED')=0
      begin
        ALTER TABLE SMBAKSCR ADD TIMED Datetime
        Print 'Shtim fusha TIMED ne SMBAKSCR: Datetime'
      end;
   if dbo.Isd_FieldTableExists('SMBAKSCR','TIMEI')=0
      begin
        ALTER TABLE SMBAKSCR ADD TIMEI Datetime
        Print 'Shtim fusha TIMEI ne SMBAKSCR: Datetime'
      end;
   if dbo.Isd_FieldTableExists('SMBAKSCR','TIMEM')=0
      begin
        ALTER TABLE SMBAKSCR ADD TIMEM Datetime
        Print 'Shtim fusha TIMEM ne SMBAKSCR: Datetime'
      end;
   if dbo.Isd_FieldTableExists('SMBAKSCR','NRSERIAL')=0
      begin
        ALTER TABLE SMBAKSCR ADD NRSERIAL Varchar(30) NULL
        Print 'Shtim fusha NRSERIAL ne SMBAKSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('SMBAKSCR','TAGRND')=0            
      begin
        ALTER TABLE SMBAKSCR ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne SMBAKSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('SMBAKSCR','VLERASM')=0            
      begin
        ALTER TABLE SMBAKSCR ADD VLERASM Float NULL 
        Print 'Shtim fusha VLERASM ne SMBAKSCR: Float'
      end;


-- ORF
   if dbo.Isd_FieldTableExists('ORF','KLASIFIKIM1')=0
      begin
        ALTER TABLE ORF ADD KLASIFIKIM1 Varchar(30) NULL
        Print 'Shtim fusha KLASIFIKIM1 ne ORF: Varchar(25)'
      end;
   if dbo.Isd_FieldTableExists('ORF','KLASETVSH')=0
      begin
        ALTER TABLE ORF ADD KLASETVSH Varchar(10) NULL
        Print 'Shtim fusha KLASETVSH ne ORF: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('ORF','KONFIRM')=0
      begin
        ALTER TABLE ORF ADD KONFIRM Bit NULL
        Print 'Shtim fusha KONFIRM ne ORF: Bit'
      end;

      SELECT @Size = Character_Maximum_Length
        FROM Information_schema.columns
       WHERE Table_Name = 'ORF'  And Column_Name='KLASIFIKIM';  
          if IsNull(@Size,0) < 30
             begin
               ALTER TABLE ORF ALTER COLUMN KLASIFIKIM VARCHAR(30) Null;
               Print 'Ndryshim fusha KLASIFIKIM ne ORF: Varchar(30)'
             end;
      SELECT @Size = Character_Maximum_Length
        FROM Information_schema.columns
       WHERE Table_Name = 'ORF'  And Column_Name='KLASIFIKIM1';  
          if IsNull(@Size,0) < 30
             begin
               ALTER TABLE ORF ALTER COLUMN KLASIFIKIM1 VARCHAR(30) Null;
               Print 'Ndryshim fusha KLASIFIKIM1 ne ORF: Varchar(30)'
             end;
   if dbo.Isd_FieldTableExists('ORF','NRRENDORFJT')=0
      begin
        ALTER TABLE ORF ADD NRRENDORFJT Int NULL 
        Print 'Shtim fusha NRRENDORFJT ne ORF: Int'
      end;
   if dbo.Isd_FieldTableExists('ORF','EXTIMPID')=0
      begin
        ALTER TABLE ORF ADD EXTIMPID Varchar(50) NULL 
        Print 'Shtim fusha EXTIMPID ne ORF: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('ORF','EXTIMPKOMENT')=0
      begin
        ALTER TABLE ORF ADD EXTIMPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTIMPKOMENT ne ORF: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('ORF','EXTEXP')=0
      begin
        ALTER TABLE ORF ADD EXTEXP bit null 
        Print 'Shtim fusha EXTEXP ne ORF: null'
      end;
   if dbo.Isd_FieldTableExists('ORF','EXTEXPKOMENT')=0
      begin
        ALTER TABLE ORF ADD EXTEXPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTEXPKOMENT ne ORF: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('ORF','DATECREATE')=0
      begin
        ALTER TABLE ORF ADD DATECREATE DATETIME NULL CONSTRAINT [DF_ORF_DATECREATE]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne ORK: DateTime'
      end;
   if dbo.Isd_FieldTableExists('ORF','DATEEDIT')=0
      begin
        ALTER TABLE ORF ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_ORF_DATEEDIT]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne ORK: DateTime'
      end;
   if dbo.Isd_FieldTableExists('ORF','TAGRND')=0            
      begin
        ALTER TABLE ORF ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne ORF: Varchar(30)'
      end;


-- ORFSCR
   --if dbo.Isd_FieldTableExists('ORFSCR','PESHANET')=0
   --   begin
   --     ALTER TABLE ORFSCR ADD PESHANET FLOAT NULL
   --     Print 'Shtim fusha PESHANET ne ORFSCR: Float'
   --   end;
   --if dbo.Isd_FieldTableExists('ORFSCR','PESHABRT')=0
   --   begin
   --     ALTER TABLE ORFSCR ADD PESHABRT FLOAT NULL
   --     Print 'Shtim fusha PESHABRT ne ORFSCR: Float'
   --   end;
   if dbo.Isd_FieldTableExists('ORFSCR','KODTVSH')=0
      begin
        ALTER TABLE ORFSCR ADD KODTVSH Varchar(30) NULL
        Print 'Shtim fusha KODTVSH ne ORFSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('ORFSCR','APLTVSH')=0
      begin
        ALTER TABLE ORFSCR ADD APLTVSH Bit NULL
        Print 'Shtim fusha APLTVSH ne ORFSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('ORFSCR','APLINVESTIM')=0
      begin
        ALTER TABLE ORFSCR ADD APLINVESTIM Bit NULL
        Print 'Shtim fusha APLINVESTIM ne ORFSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('ORFSCR','CMSHREF')=0
      begin
        ALTER TABLE ORFSCR ADD CMSHREF Float NULL
        Print 'Shtim fusha CMSHREF ne ORFSCR: Float'
        Exec (' UPDATE ORFSCR SET CMSHREF = CMSHZB0 ');
      end;
   if dbo.Isd_FieldTableExists('ORFSCR','NRSERIAL')=0
      begin
        ALTER TABLE ORFSCR ADD NRSERIAL Varchar(30) NULL
        Print 'Shtim fusha NRSERIAL ne ORFSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('ORFSCR','KOEFICIENT')=0
      begin
        ALTER TABLE ORFSCR ADD KOEFICIENT Float NULL
        Print 'Shtim fusha KOEFICIENT ne ORFSCR: Float'
      end;
   if dbo.Isd_FieldTableExists('ORFSCR','TAGRND')=0            
      begin
        ALTER TABLE ORFSCR ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne ORFSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('DG','TAGRND')=0            
      begin
        ALTER TABLE DG ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne DG: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('DG','DATECREATE')=0
      begin
        ALTER TABLE DG ADD DATECREATE DATETIME NULL CONSTRAINT [DF_DG_DATECREATE]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne DG: DateTime'
      end;
   if dbo.Isd_FieldTableExists('DG','DATEEDIT')=0
      begin
        ALTER TABLE DG ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_DG_DATEEDIT]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne DG: DateTime'
      end;
   if dbo.Isd_FieldTableExists('DG','KONFIRM')=0
      begin
        ALTER TABLE DG ADD KONFIRM Bit NULL 
        Print 'Shtim fusha KONFIRM ne DG: Bit'
      end;
   if dbo.Isd_FieldTableExists('DG','REGJIMDG')=0
      begin
        ALTER TABLE DG ADD REGJIMDG Varchar(30) NULL 
        Print 'Shtim fusha REGJIMDG ne DG: Varchar(30)'
      end;

-- DGSCR
   if dbo.Isd_FieldTableExists('DGSCR','APLINVESTIM')=0
      begin
        ALTER TABLE DGSCR ADD APLINVESTIM Bit NULL
        Print 'Shtim fusha APLINVESTIM ne DGSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('DGSCR','TAGRND')=0            
      begin
        ALTER TABLE DGSCR ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne DGSCR: Varchar(30)'
      end;




-- ARTIKUJ

   if dbo.Isd_FieldTableExists('ARTIKUJ','PESHORETREG')=0
      begin
        ALTER TABLE ARTIKUJ ADD PESHORETREG Varchar(10) NULL
        Print 'Shtim fusha PESHORETREG ne ARTIKUJ: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','PESHANET')=0
      begin
        ALTER TABLE ARTIKUJ ADD PESHANET Float NULL
        Print 'Shtim fusha PESHANET ne ARTIKUJ: Float'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','PESHABRT')=0
      begin
        ALTER TABLE ARTIKUJ ADD PESHABRT Float NULL
        Print 'Shtim fusha PESHABRT ne ARTIKUJ: Float'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','DENSITET')=0
      begin
        ALTER TABLE ARTIKUJ ADD DENSITET Float NULL
        Print 'Shtim fusha DENSITET ne ARTIKUJ: Float'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','DSCNTKLK')=0
      begin
        ALTER TABLE ARTIKUJ ADD DSCNTKLK Varchar(10) NULL
        Print 'Shtim fusha DSCNTKLK ne ARTIKUJ: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','DSCNTKLL')=0
      begin
        ALTER TABLE ARTIKUJ ADD DSCNTKLL Varchar(10) NULL
        Print 'Shtim fusha DSCNTKLL ne ARTIKUJ: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','DSCNTKLM')=0
      begin
        ALTER TABLE ARTIKUJ ADD DSCNTKLM Varchar(10) NULL
        Print 'Shtim fusha DSCNTKLM ne ARTIKUJ: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','DSCNTKLN')=0
      begin
        ALTER TABLE ARTIKUJ ADD DSCNTKLN Varchar(10) NULL
        Print 'Shtim fusha DSCNTKLN ne ARTIKUJ: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','DSCNTKLO')=0
      begin
        ALTER TABLE ARTIKUJ ADD DSCNTKLO Varchar(10) NULL
        Print 'Shtim fusha DSCNTKLO ne ARTIKUJ: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','DSCNTKLP')=0
      begin
        ALTER TABLE ARTIKUJ ADD DSCNTKLP Varchar(10) NULL
        Print 'Shtim fusha DSCNTKLP ne ARTIKUJ: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','DSCNTKLQ')=0
      begin
        ALTER TABLE ARTIKUJ ADD DSCNTKLQ Varchar(10) NULL
        Print 'Shtim fusha DSCNTKLQ ne ARTIKUJ: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','DSCNTKLR')=0
      begin
        ALTER TABLE ARTIKUJ ADD DSCNTKLR Varchar(10) NULL
        Print 'Shtim fusha DSCNTKLR ne ARTIKUJ: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','DSCNTKLS')=0
      begin
        ALTER TABLE ARTIKUJ ADD DSCNTKLS Varchar(10) NULL
        Print 'Shtim fusha DSCNTKLS ne ARTIKUJ: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','DSCNTKLT')=0
      begin
        ALTER TABLE ARTIKUJ ADD DSCNTKLT Varchar(10) NULL
        Print 'Shtim fusha DSCNTKLT ne ARTIKUJ: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','APLKMS')=0
      begin
        ALTER TABLE ARTIKUJ ADD APLKMS Bit NULL
        Print 'Shtim fusha APLKMS ne ARTIKUJ: Bit'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','PERQKMS')=0
      begin
        ALTER TABLE ARTIKUJ ADD PERQKMS Float NULL
        Print 'Shtim fusha PERQKMS ne ARTIKUJ: Float'
      end;
--
   if dbo.Isd_FieldTableExists('ARTIKUJ','CMSHMIN')=0
      begin
        ALTER TABLE ARTIKUJ ADD CMSHMIN Float NULL
        Print 'Shtim fusha CMSHMIN ne ARTIKUJ: Float'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','CMSHMAX')=0
      begin
        ALTER TABLE ARTIKUJ ADD CMSHMAX Float NULL
        Print 'Shtim fusha CMSHMAX ne ARTIKUJ: Float'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','CMSHLIMIT')=0
      begin
        ALTER TABLE ARTIKUJ ADD CMSHLIMIT Bit NULL
        Print 'Shtim fusha CMSHLIMIT ne ARTIKUJ: Bit'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','CMSHLIMITBLC')=0
      begin
        ALTER TABLE ARTIKUJ ADD CMSHLIMITBLC Bit NULL
        Print 'Shtim fusha CMSHLIMITBLC ne ARTIKUJ: Bit'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','CMBLMIN')=0
      begin
        ALTER TABLE ARTIKUJ ADD CMBLMIN Float NULL
        Print 'Shtim fusha CMBLMIN ne ARTIKUJ: Float'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','CMBLMAX')=0
      begin
        ALTER TABLE ARTIKUJ ADD CMBLMAX Float NULL
        Print 'Shtim fusha CMBLMAX ne ARTIKUJ: Float'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','CMBLLIMIT')=0
      begin
        ALTER TABLE ARTIKUJ ADD CMBLLIMIT Bit NULL
        Print 'Shtim fusha CMBLLIMIT ne ARTIKUJ: Bit'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','CMBLLIMITBLC')=0
      begin
        ALTER TABLE ARTIKUJ ADD CMBLLIMITBLC Bit NULL
        Print 'Shtim fusha CMBLLIMITBLC ne ARTIKUJ: Bit'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','NRSERIAL')=0
      begin
        ALTER TABLE ARTIKUJ ADD NRSERIAL Varchar(30) NULL
        Print 'Shtim fusha NRSERIAL ne ARTIKUJ: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','AMBAUTFJ')=0
      begin
        ALTER TABLE ARTIKUJ ADD AMBAUTFJ Bit NULL
        Print 'Shtim fusha AMBAUTFJ ne ARTIKUJ: Bit'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','AMBDETKLIENT')=0
      begin
        ALTER TABLE ARTIKUJ ADD AMBDETKLIENT Bit NULL
        Print 'Shtim fusha AMBDETKLIENT ne ARTIKUJ: Bit'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','NOTACTIVSH')=0
      begin
        ALTER TABLE ARTIKUJ ADD NOTACTIVSH Bit NULL
        Print 'Shtim fusha NOTACTIVSH ne ARTIKUJ: Bit'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','NOTACTIVBL')=0
      begin
        ALTER TABLE ARTIKUJ ADD NOTACTIVBL Bit NULL
        Print 'Shtim fusha NOTACTIVBL ne ARTIKUJ: Bit'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','UPDATELASTBL')=0
      begin
        ALTER TABLE ARTIKUJ ADD UPDATELASTBL Bit NULL
        Print 'Shtim fusha UPDATELASTBL ne ARTIKUJ: Bit'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','DATELASTBL')=0
      begin
        ALTER TABLE ARTIKUJ ADD DATELASTBL DateTime NULL
        Print 'Shtim fusha DATELASTBL ne ARTIKUJ: Datetime'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','GARANCI')=0
      begin
        ALTER TABLE ARTIKUJ ADD GARANCI Int NULL
        Print 'Shtim fusha GARANCI ne ARTIKUJ: Int'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','KODOLD')=0
      begin
        ALTER TABLE ARTIKUJ ADD KODOLD Varchar(60) NULL
        Print 'Shtim fusha KODOLD ne ARTIKUJ: Varchar(60)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','SHENIM1')=0
      begin
        ALTER TABLE ARTIKUJ ADD SHENIM1 nVarchar(Max) NULL
        Print 'Shtim fusha SHENIM1 ne ARTIKUJ: nVarchar(Max)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','SHENIM2')=0
      begin
        ALTER TABLE ARTIKUJ ADD SHENIM2 nVarchar(Max) NULL
        Print 'Shtim fusha SHENIM2 ne ARTIKUJ: nVarchar(Max)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','KOEFICENTAGJ')=0
      begin
        ALTER TABLE ARTIKUJ ADD KOEFICENTAGJ Float NULL
        Print 'Shtim fusha KOEFICENTAGJ ne ARTIKUJ: Float'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','KATEGORI')=0
      begin
        ALTER TABLE ARTIKUJ ADD KATEGORI Varchar(60) NULL
        Print 'Shtim fusha KATEGORI ne ARTIKUJ: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','APLKATEGORIAGJ')=0
      begin
        ALTER TABLE ARTIKUJ ADD APLKATEGORIAGJ Bit NULL
        Print 'Shtim fusha APLKATEGORIAGJ ne ARTIKUJ: Bit'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','APLKATEGORIKL')=0
      begin
        ALTER TABLE ARTIKUJ ADD APLKATEGORIKL Bit NULL
        Print 'Shtim fusha APLKATEGORIKL ne ARTIKUJ: Bit'
      end;

   if dbo.Isd_FieldTableExists('ARTIKUJ','ITEMGJATESI')=0
      begin
        ALTER TABLE ARTIKUJ ADD ITEMGJATESI Float NULL
        Print 'Shtim fusha ITEMGJATESI ne ARTIKUJ: Float'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','ITEMGJERESI')=0
      begin
        ALTER TABLE ARTIKUJ ADD ITEMGJERESI Float NULL
        Print 'Shtim fusha ITEMGJERESI ne ARTIKUJ: Float'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','ITEMLARTESI')=0
      begin
        ALTER TABLE ARTIKUJ ADD ITEMLARTESI Float NULL
        Print 'Shtim fusha ITEMLARTESI ne ARTIKUJ: Float'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','MAXSASILEVRIM')=0
      begin
        ALTER TABLE ARTIKUJ ADD MAXSASILEVRIM Float NULL
        Print 'Shtim fusha MAXSASILEVRIM ne ARTIKUJ: Float'
      end;

   if dbo.Isd_FieldTableExists('ARTIKUJ','CMRIMBURSIMPLOTE')=0
      begin
        ALTER TABLE ARTIKUJ ADD CMRIMBURSIMPLOTE Float NULL
        Print 'Shtim fusha CMRIMBURSIMPLOTE ne ARTIKUJ: Float'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','CMRIMBURSIMPJESE')=0
      begin
        ALTER TABLE ARTIKUJ ADD CMRIMBURSIMPJESE Float NULL
        Print 'Shtim fusha CMRIMBURSIMPJESE ne ARTIKUJ: Float'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','FISKAL')=0
      begin
        ALTER TABLE ARTIKUJ ADD FISKAL Bit NULL
        Print 'Shtim fusha FISKAL ne ARTIKUJ: Bit';
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','APLARTIKUJPALM')=0
      begin
        ALTER TABLE ARTIKUJ ADD APLARTIKUJPALM Bit NULL
        Print 'Shtim fusha APLARTIKUJPALM ne ARTIKUJ: Bit';
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','PRODUCTMANAGER')=0
      begin
        ALTER TABLE ARTIKUJ ADD PRODUCTMANAGER Varchar(30) NULL
        Print 'Shtim fusha PRODUCTMANAGER ne ARTIKUJ: Varchar(30)'
      end;


-- ARTIKUJBC

   if dbo.Isd_FieldTableExists('ARTIKUJBCSCR','SHENIM1')=0
      begin
        ALTER TABLE ARTIKUJBCSCR ADD SHENIM1 nVarchar(Max) NULL
        Print 'Shtim fusha SHENIM1 ne ARTIKUJBCSCR: nVarchar(Max)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJBCSCR','SHENIM2')=0
      begin
        ALTER TABLE ARTIKUJBCSCR ADD SHENIM2 nVarchar(Max) NULL
        Print 'Shtim fusha SHENIM2 ne ARTIKUJBCSCR: nVarchar(Max)'
      end;


-- ARTIKUJKTG

   if dbo.Isd_FieldTableExists('ARTIKUJKTG','KODSUP')=0
      begin
        ALTER TABLE ARTIKUJKTG ADD KODSUP Varchar(30) NULL
        Print 'Shtim fusha KODSUP ne ARTIKUJKTG: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJKTG','ISSUPERIOR')=0
      begin
        ALTER TABLE ARTIKUJKTG ADD ISSUPERIOR Bit NULL
        Print 'Shtim fusha ISSUPERIOR ne ARTIKUJKTG: Bit'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJKTG','DATEEDIT')=0
      begin
        ALTER TABLE ARTIKUJKTG ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_ARTIKUJKTG_DATEEDIT]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne ARTIKUJKTG: DateTime'
      end;


-- NJESI

   if dbo.Isd_FieldTableExists('NJESI','KODEIC')=0
      begin
        ALTER TABLE NJESI ADD KODEIC Varchar(10) NULL
        Print 'Shtim fusha KODEIC ne NJESI: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('NJESI','KODINT')=0
      begin
        ALTER TABLE NJESI ADD KODINT Varchar(10) NULL
        Print 'Shtim fusha KODINT ne NJESI: Varchar(10)'
      end;
      
      
-- AQSKEMELM

   if dbo.Isd_FieldTableExists('AQSKEMELM','LLOGSHPVLERMBET')=0
      begin
        ALTER TABLE AQSKEMELM ADD LLOGSHPVLERMBET Varchar(30) NULL
        Print 'Shtim fusha LLOGSHPVLERMBET ne AQSKEMELM: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('AQSKEMELM','LLOGPRONESI')=0
      begin
        ALTER TABLE AQSKEMELM ADD LLOGPRONESI Varchar(30) NULL
        Print 'Shtim fusha LLOGPRONESI ne AQSKEMELM: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('AQSKEMELM','LLOGPLUSVLERA')=0
      begin
        ALTER TABLE AQSKEMELM ADD LLOGPLUSVLERA Varchar(30) NULL
        Print 'Shtim fusha LLOGPLUSVLERA ne AQSKEMELM: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('AQSKEMELM','LLOGMINUSVLERA')=0
      begin
        ALTER TABLE AQSKEMELM ADD LLOGMINUSVLERA Varchar(30) NULL
        Print 'Shtim fusha LLOGMINUSVLERA ne AQSKEMELM: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('AQSKEMELM','DITARKONTABBLERJE')=0
      begin
        ALTER TABLE AQSKEMELM ADD DITARKONTABBLERJE Bit NULL
        Print 'Shtim fusha DITARKONTABBLERJE ne AQSKEMELM: Bit'
      end;
   if dbo.Isd_FieldTableExists('AQSKEMELM','DITARKONTABSHITJE')=0
      begin
        ALTER TABLE AQSKEMELM ADD DITARKONTABSHITJE Bit NULL
        Print 'Shtim fusha DITARKONTABSHITJE ne AQSKEMELM: Bit'
      end;



    SET @sSql1 = '

         SET ANSI_NULLS ON
         SET QUOTED_IDENTIFIER ON
         SET ANSI_PADDING ON

         CREATE TABLE [dbo].[ARTIKUJAMBSCR](
	      [NRRENDOR] [int] IDENTITY(1,1) NOT NULL,
	      [NRD] [int] NULL,
	      [KOD] [varchar](25) NULL,
	      [PERSHKRIM] [varchar](100) NULL,
	      [NJESI] [varchar](10) NULL,
	      [KOEFICIENT] [float] NULL,
	      [PROMOC] [bit] NULL,
	      [PROMOCTIP] [varchar](1) NULL,
	      [QKOSTO] [varchar](60) NULL,
	      [ORDERSCR] [int] NULL,
	      [TAG] [bit] NULL,
	      [TROW] [bit] NULL,
	      [TAGNR] [int] NULL,
	      [STATROW] [varchar](5) NULL
        ) ON [PRIMARY]

        SET ANSI_PADDING OFF
        Print ''Krijim tabele ''+DB_NAME()+''..ARTIKUJAMBSCR''; '

   if Object_Id('ARTIKUJAMBSCR') is null
      EXEC (@sSql1);

   if Object_Id('CONFIG..ARTIKUJAMBSCR') is null
      EXEC (' USE CONFIG; '+@sSql1)

  
   
  SET @Bit = 0;   Exec dbo.Isd_FieldTableDbExists 'CONFIG', 'TIPDOK', 'GRUP', @Bit Output;
   if @Bit=0        -- dbo.Isd_FieldTableExists('CONFIG..TIPDOK','GRUP')=0
      begin
         ALTER TABLE CONFIG..TIPDOK ADD GRUP Varchar(20) NULL
         Print 'Shtim fusha GRUP ne CONFIG..TIPDOK: Varchar(20)'
		   SET @sSql = 'UPDATE CONFIG..TIPDOK 
		                   SET GRUP=''FIS'' 
					     WHERE CHARINDEX('',''+UPPER(TIPDOK)+'','','',SKTV,FKTV,TVSHEFEKT,TVSHEIC,TVSHFIC,VEHOWNER,WTNOBJECT,WTNPROC,WTNTYPE,VEHOWNER,FURNNIPT,KLIENTNIPT,'')>0;' 
		 EXEC (@sSql);
      end;


  SET @Bit = 0;   Exec dbo.Isd_FieldTableDbExists 'CONFIG', 'TIPDOK', 'OBJEKT', @Bit Output;
   if @Bit=0        -- dbo.Isd_FieldTableExists('CONFIG..TIPDOK','OBJEKT')=0
      begin
         ALTER TABLE CONFIG..TIPDOK ADD OBJEKT Varchar(20) NULL
         Print 'Shtim fusha OBJEKT ne CONFIG..TIPDOK: Varchar(20)'
		 SET   @sSql = 'UPDATE CONFIG..TIPDOK SET OBJEKT=''FF'' WHERE CHARINDEX('',''+UPPER(TIPDOK)+'','','',FKTV,'')>0;
		                UPDATE CONFIG..TIPDOK SET OBJEKT=''FJ'' WHERE CHARINDEX('',''+UPPER(TIPDOK)+'','','',SKTV,'')>0;
		                UPDATE CONFIG..TIPDOK SET OBJEKT=''MG'' WHERE CHARINDEX('',''+UPPER(TIPDOK)+'','','',WTNOBJECT,WTNPROC,WTNTYPE,VEHOWNER,'')>0;';
		 EXEC (@sSql);
      end;


  SET @Bit = 0;   Exec dbo.Isd_FieldTableDbExists 'CONFIG', 'TIPDOK', 'MODUL', @Bit Output;
   if @Bit = 0      -- dbo.Isd_FieldTableExists('CONFIG..TIPDOK','MODUL')=0
      begin
         ALTER TABLE CONFIG..TIPDOK ADD MODUL Varchar(10) NULL
         Print 'Shtim fusha MODUL ne CONFIG..TIPDOK: Varchar(10)'
		   SET @sSql = 'UPDATE CONFIG..TIPDOK SET MODUL=''F''   WHERE CHARINDEX('',''+UPPER(TIPDOK)+'','','',FKTV,'')>0;
		                UPDATE CONFIG..TIPDOK SET MODUL=''S''   WHERE CHARINDEX('',''+UPPER(TIPDOK)+'','','',SKTV,'')>0;
					    UPDATE CONFIG..TIPDOK SET MODUL=''D''   WHERE CHARINDEX('',''+UPPER(TIPDOK)+'','','',WTNOBJECT,WTNPROC,WTNTYPE,VEHOWNER,'')>0;';
		 EXEC (@sSql);
      end;

  SET @Bit = 0;   Exec dbo.Isd_FieldTableDbExists 'CONFIG', 'TIPDOK', 'FISKALIZIM', @Bit Output;
   if @Bit = 0      -- dbo.Isd_FieldTableExists('CONFIG..TIPDOK','FISKALIZIM')=0
      begin
         ALTER  TABLE CONFIG..TIPDOK ADD FISKALIZIM Bit NULL
         Print  'Shtim fusha FISKALIZIM ne CONFIG..TIPDOK: Bit'
		   SET  @sSql = '
		             UPDATE CONFIG..TIPDOK 
		                SET FISKALIZIM=1   
					  WHERE (TIPDOK=''FKTV'' AND CHARINDEX('',''+KOD+'','','',FANG,ABROAD,AGREEMENT,DOMESTIC,OTHER,'')>0) OR 
					        (TIPDOK=''SKTV'' AND CHARINDEX('',''+KOD+'','','',SANG,AGREEMENT,OTHER,SELF,'')>0);';
		 EXEC (@sSql);
      end;



-- AQKartela,AQKategori,AQGrup,AQSkemeLM

        SET @sSql1 = '
   IF NOT EXISTS (SELECT * FROM CONFIG..TABLESNAME WHERE TABLENAME=''AQKARTELA'')
      BEGIN   
            USE CONFIG
         INSERT INTO CONFIG..TABLESNAME 
               (TABLESTR,NRORDER,KOD,PERSHKRIM,TABLENAME,MODUL,TIP,ORG,OBJEKT,STRUCTURE,LIST,ORDERLM,KALIMLM,TROW,TAGNR)
         SELECT TABLESTR,NRORDER=''00130'',KOD=''AQKARTELA'',PERSHKRIM=''Asete'',TABLENAME=''AQKARTELA'',MODUL=''T'',TIP=''X'',ORG=''T'',OBJEKT='''',STRUCTURE,LIST='''',ORDERLM=0,KALIMLM=0,TROW=0,TAGNR=-1
           FROM CONFIG..TABLESNAME
          WHERE TABLENAME=''ARTIKUJ'';
          PRINT ''Shtimi i reshtit AQKARTELA ne tabelen ''+DB_NAME()+''..TABLESNAME'';
      END; ';

   Set @TablesList = 'AQKARTELA,AQKATEGORI,AQGRUP,AQSKEMELM';
   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;
   while @i<=@k  
     begin 
       Set   @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
       Set   @sSql  = Replace(Replace(@sSql1,'AQKARTELA',@TableName),'00130','0013'+CAST(@i As Varchar));
     --Print @sSql;
       Exec (@sSql);
       Set   @i = @i + 1
     end;

-- AQHistori

   IF NOT EXISTS (SELECT * FROM CONFIG..TABLESNAME WHERE TABLENAME='AQHISTORI')
      BEGIN   
         INSERT INTO CONFIG..TABLESNAME 
               (TABLESTR,NRORDER,KOD,PERSHKRIM,TABLENAME,MODUL,TIP,ORG,OBJEKT,STRUCTURE,LIST,ORDERLM,KALIMLM,TROW,TAGNR)
         SELECT TABLESTR,NRORDER='T06',KOD='AQHISTORI',PERSHKRIM='Ditar historik asete',TABLENAME='AQHISTORI',MODUL='T',TIP='X',ORG='AQ',OBJEKT,STRUCTURE,LIST,ORDERLM+1,KALIMLM=0,TROW=0,TAGNR=-1
           FROM CONFIG..TABLESNAME
          WHERE TABLENAME='AQ';
          PRINT 'Shtimi i reshtit AQHISTORI ne tabelen CONFIG..TABLESNAME';
      END; ;



   
   IF NOT EXISTS ( SELECT * FROM X_FORMDISPL WHERE FORME='AQ')
      BEGIN   
         INSERT    INTO X_FORMDISPL 
                  (FORME,KOD,PERSHKRIM,		IDFORME,NRORDER,FIELD,		PROMPT,			WIDTH,	INGRID,	DISPLAY,[READONLY],BUTONSTYLE,	TROW,TAGNR)
         SELECT	   'AQ','AQ','Ditar aktive','AQ01',-1,		'',			'Ditar aktive',	0,		0,		0,		0,			0,			0,	-1
         UNION ALL  
         SELECT    'AQ','AQ','Kodaf',		'AQ01',	1,		'KODAF',	'Kodaf',		60,		1,		1,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQ','AQ','Pershkrim',	'AQ01',	2,		'PERSHKRIM','Pershkrim',	200,	1,		1,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQ','AQ','Njesi',		'AQ01',	3,		'NJESI',	'Njesi',		40,		1,		1,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQ','AQ','Sasi',		'AQ01',	4,		'SASI',		'Sasi',			80,		1,		1,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQ','AQ','Cmimbs',		'AQ01',	5,		'CMIMBS',	'Cmimbs',		80,		1,		1,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQ','AQ','Kodoper',		'AQ01',	6,		'KODOPER',	'Kodoper',		50,		1,		1,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQ','AQ','Dateoper',	'AQ01',	7,		'DATEOPER',	'Dateoper',		80,		1,		1,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQ','AQ','Normeam',		'AQ01',	17,		'NORMEAM',	'Normeam',		60,		1,		1,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQ','AQ','Vlerabs',		'AQ01',	18,		'VLERABS',	'Vlerabs',		80,		1,		1,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQ','AQ','Vleraam',		'AQ01',	20,		'VLERAAM',	'Vleraam',		80,		1,		1,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQ','AQ','Koment',		'AQ01',	100,	'KOMENT',	'Koment',		120,	1,		1,		0,			0,			0,	-1;
        
         PRINT 'Shtimi i reshtit AQ ne X_FORMDISPL ';
      END;


   IF NOT EXISTS (SELECT * FROM CONFIG..X_FORMDISPL WHERE FORME='AQ')
      BEGIN   
         INSERT INTO CONFIG..X_FORMDISPL 
               (FORME,KOD,PERSHKRIM,IDFORME,NRORDER,FIELD,PROMPT,WIDTH,INGRID,DISPLAY,[READONLY],BUTONSTYLE,TROW,TAGNR)
         SELECT	FORME,KOD,PERSHKRIM,IDFORME,NRORDER,FIELD,PROMPT,WIDTH,INGRID,DISPLAY,[READONLY],BUTONSTYLE,TROW,TAGNR
           FROM X_FORMDISPL  
          WHERE FORME='AQ'
       ORDER BY NRORDER; 
          PRINT 'Shtimi i reshtit AQ ne CONFIG..X_FORMDISPL ';
      END;


   IF NOT EXISTS (SELECT * FROM DRH..FUNKSION WHERE MODUL='AQ' AND ISNULL(TROW,0)=1) -- Do te dihej me sakte 'X' jo 'AQ' por me 'X' kemi referencat ....!!!???
      BEGIN
        INSERT INTO [DRH].[dbo].[Funksion]
              (NRPROGRAM,NRORDER,PERSHKRIM,M1,V1,P1,GJ1,NR1,DT1,NIV,MODUL,TIPDOK,TIPACTION,[ACTION],ACTIONCAPTION,KOMENT,TROW,TAGNR)
        SELECT 0,'00','Moduli Aktive',1,1,1,1,1,1,1,'AQ','','',NULL,'','',1,0 
      END;
      


-- Konfigurimi i segmenteve per AQ --


-- Kujdes: Me poshte (shiko SG_SEGMENTSL) behet unifikimi i tabeles se Config me ato te nd/jes aktive,
-- Ketu behet vetem per database CONFIG


   IF NOT EXISTS (SELECT * FROM CONFIG..SG_LIBRAT WHERE LIBER='LAQ')
      BEGIN   
        INSERT INTO CONFIG..SG_LIBRAT 
              (PERSHKRIM,NRSEGL,NRSEGD,LIBER,DITAR,TIP,TROW,TAGNR)
        SELECT 'Aktivet',5,5,'LAQ','AQSCR','X',0,-1      
      END;
    
     
      SELECT @i=NRRENDOR FROM CONFIG..SG_LIBRAT WHERE LIBER='LAQ';
   
          
   IF (@i>0) AND (NOT EXISTS (SELECT * FROM CONFIG..SG_SEGMENTSL WHERE KOD='AQ01'))
      BEGIN
        INSERT INTO CONFIG..SG_SEGMENTSL
              (USC, NRD, CODE, KOD,   S_NAME,     [Desc],            NR, DISPLAYED, [REQUIRED], VAL_TYPE, VAL_SIZE, HEMODE,  SKEDARI)
        SELECT 1,   0,   @i,   'AQ01','AQKARTELA','Kartele aktivi',  1,  1,         1,          'Char',   10,       'Asgje', 'AQKARTELA'
      END; 
   IF (@i>0) AND (NOT EXISTS (SELECT * FROM CONFIG..SG_SEGMENTSL WHERE KOD='AQ02'))
      BEGIN
        INSERT INTO CONFIG..SG_SEGMENTSL
              (USC, NRD, CODE, KOD,   S_NAME,        [Desc],         NR, DISPLAYED, [REQUIRED], VAL_TYPE, VAL_SIZE, HEMODE,  SKEDARI)
        SELECT 2,   0,   @i,   'AQ02','DEPARTAMENT', 'Departamente', 2,  1,         0,          'Char',   15,       'Asgje', 'DEPARTAMENT'
      END; 
   IF (@i>0) AND (NOT EXISTS (SELECT * FROM CONFIG..SG_SEGMENTSL WHERE KOD='AQ03'))
      BEGIN
        INSERT INTO CONFIG..SG_SEGMENTSL
              (USC, NRD, CODE, KOD,   S_NAME,        [Desc],         NR, DISPLAYED, [REQUIRED], VAL_TYPE, VAL_SIZE, HEMODE,  SKEDARI)
        SELECT 3,   0,   @i,   'AQ03','LISTE',       'Liste',        3,  1,         0,          'Char',   15,       'Asgje', 'LISTE'
      END; 
   IF (@i>0) AND (NOT EXISTS (SELECT * FROM CONFIG..SG_SEGMENTSL WHERE KOD='AQ04'))
      BEGIN
        INSERT INTO CONFIG..SG_SEGMENTSL
              (USC, NRD, CODE, KOD,   S_NAME,        [Desc],         NR, DISPLAYED, [REQUIRED], VAL_TYPE, VAL_SIZE, HEMODE,  SKEDARI)
        SELECT 4,   0,   @i,   'AQ04','MAGAZINA',    'Magazine',     4,  1,         0,          'Char',   10,       'Asgje', 'MAGAZINA'
      END; 
   IF (@i>0) AND (NOT EXISTS (SELECT * FROM CONFIG..SG_SEGMENTSL WHERE KOD='AQ05'))
      BEGIN
        INSERT INTO CONFIG..SG_SEGMENTSL
              (USC, NRD, CODE, KOD,   S_NAME,        [Desc],         NR, DISPLAYED, [REQUIRED], VAL_TYPE, VAL_SIZE, HEMODE,  SKEDARI)
        SELECT 5,   0,   @i,   'AQ05','MONEDHA',     'Monedhe',      5,  0,         0,          'Char',   10,       'Asgje', 'MONEDHA'
      END; 
-- Fund konfigurimi i segmenteve per AQ --



-- AQSCR

   if dbo.Isd_FieldTableExists('AQSCR','VLERAFAT')=0
      begin
        ALTER TABLE AQSCR ADD VLERAFAT   Float NULL                       -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020. Ketu u lejua MM per ndonje rast te vjeter
        Print 'Shtim fusha VLERAFAT ne AQSCR: Float'
         Exec ('UPDATE AQSCR 
                   SET VLERAFAT = CASE WHEN CHARINDEX(UPPER('',''+ISNULL(KODOPER,'''')+'',''),'',BL,MM,RK,CE,SH,'')>0  
                                       THEN VLERABS 
                                       ELSE 0 
                                  END  ');
        
      end;   
   if dbo.Isd_FieldTableExists('AQSCR','VLERAFATMV')=0
      begin
        ALTER TABLE AQSCR ADD VLERAFATMV Float NULL                       -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020. Ketu u lejua MM per ndonje rast te vjeter
        Print 'Shtim fusha VLERAFATMV ne AQSCR: Float'
         Exec ('UPDATE AQSCR 
                   SET VLERAFATMV = CASE WHEN CHARINDEX(UPPER('',''+ISNULL(KODOPER,'''')+'',''),'',BL,MM,RK,CE,SH,'')>0 
                                         THEN CASE WHEN ISNULL(KMON,'''')='''' OR (KURS1=1 AND KURS2=1) OR (ISNULL(KURS1,0)=0 OR ISNULL(KURS2,0)=0)
                                                   THEN VLERABS 
                                                   ELSE ROUND((VLERABS*KURS2)/KURS1,2) 
                                              END 
                                         ELSE 0     
                                    END ');
        
      end;
   if dbo.Isd_FieldTableExists('AQSCR','VLERAEXTMV')=0
      begin
        ALTER TABLE AQSCR ADD VLERAEXTMV Float NULL
        Print 'Shtim fusha VLERAEXTMV ne AQSCR: Float'
      end;
      
   if dbo.Isd_FieldTableExists('AQSCR','KURS1')=0
      begin
        ALTER TABLE AQSCR ADD KURS1 Float NULL
        Print 'Shtim fusha Kurs1 ne AQSCR: Float'
     -- Exec ('UPDATE AQSCR SET KURS1 = 1 ');
      end;
   if dbo.Isd_FieldTableExists('AQSCR','KURS2')=0
      begin
        ALTER TABLE AQSCR ADD KURS2 Float NULL
        Print 'Shtim fusha Kurs2 ne AQSCR: Float'
     --  Exec ('UPDATE AQSCR SET KURS2 = 1 ');
      end;
   if dbo.Isd_FieldTableExists('AQSCR','KODPRONESI')=0
      begin
        ALTER TABLE AQSCR ADD KODPRONESI Varchar(60) NULL
        Print 'Shtim fusha KODPRONESI ne AQSCR: Varchar(60)'
      end;
   if dbo.Isd_FieldTableExists('AQSCR','PERSHKRIMPRONESI')=0
      begin
        ALTER TABLE AQSCR ADD PERSHKRIMPRONESI Varchar(200) NULL
        Print 'Shtim fusha PERSHKRIMPRONESI ne AQSCR: Varchar(200)'
      end;
   if dbo.Isd_FieldTableExists('AQSCR','KODLOCATION')=0
      begin
        ALTER TABLE AQSCR ADD KODLOCATION Varchar(60) NULL
        Print 'Shtim fusha KODLOCATION ne AQSCR: Varchar(60)'
      end;
   if dbo.Isd_FieldTableExists('AQSCR','PERSHKRIMLOCATION')=0
      begin
        ALTER TABLE AQSCR ADD PERSHKRIMLOCATION Varchar(200) NULL
        Print 'Shtim fusha PERSHKRIMLOCATION ne AQSCR: Varchar(200)'
      end;

--


      SELECT @Size = Character_Maximum_Length
        FROM Information_schema.columns
       WHERE Table_Name = 'X_FORMDISPL'  And Column_Name='FORME';  
          if IsNull(@Size,0) < 50
             begin
               ALTER TABLE X_FORMDISPL ALTER COLUMN FORME VARCHAR(50) Null;
               Print 'Ndryshim size fusha FORME ne X_FORMDISPL: Varchar(50)'
             end;


   IF NOT EXISTS ( SELECT * FROM X_FORMDISPL WHERE FORME='AQHISTORI')
      BEGIN   
         INSERT    INTO X_FORMDISPL 
                  (FORME,	      KOD,   PERSHKRIM,		    IDFORME,	NRORDER,  FIELD,				PROMPT,				WIDTH,	INGRID,	DISPLAY,[READONLY],BUTONSTYLE,	TROW,TAGNR)
         SELECT	   'AQHISTORI',  'AQHISTORI',  'Histori aktive',	'AQH01',	-1,		  '',					'Histori aktive',	0,		0,		0,		0,			0,			0,	-1
         UNION ALL   
         SELECT    'AQHISTORI',  'AQHISTORI',  'Veprimi',			'AQH01',	1,		  'KODOPER',			'Veprimi',			50,		1,		1,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQHISTORI',  'AQHISTORI',  'Date veprimi',		'AQH01',	2,		  'DATEOPER',			'Dt veprimi',		100,	1,		1,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQHISTORI',  'AQHISTORI',  'Sasi',				'AQH01',	4,		  'SASI',				'Sasi',				80,		1,		1,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQHISTORI',  'AQHISTORI',  'Sasi',				'AQH01',	5,		  'NJESI',				'Njesi',			40,		1,		1,		0,			0,			0,	-1
         UNION ALL			
         SELECT    'AQHISTORI',  'AQHISTORI',  'Vlera',				'AQH01',	18,		  'VLERABS',			'Vlera',			80,		1,		1,		0,			0,			0,	-1
         UNION ALL  
         SELECT    'AQHISTORI',  'AQHISTORI',  'Normeam',			'AQH01',	17,		  'NORMEAM',			'NormeAm',			60,		1,		1,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQHISTORI',  'AQHISTORI',  'Vleraam',			'AQH01',	20,		  'VLERAAM',			'VleraAm',			80,		1,		1,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQHISTORI',  'AQHISTORI',  'Koment',			'AQH01',	50,	      'KOMENT',				'Koment',			120,	1,		1,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQHISTORI',  'AQHISTORI',  'Kod vendndodhje',	'AQH01',	51,	      'KODLOCATION',		'Kod vendndodhje',	80,		1,		1,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQHISTORI',  'AQHISTORI',  'Vendndodhje',		'AQH01',	52,	      'PERSHKRIMLOCATION',	'vendndodhje',		120,	0,		0,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQHISTORI',  'AQHISTORI',  'Kod perdorues',		'AQH01',	53,	      'KODPRONESI',			'Kod perdorues',	80,		1,		1,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQHISTORI',  'AQHISTORI',  'Perdorues',			'AQH01',	53,	      'PERSHKRIMPRONESI',	'Perdorues',		120,	0,		0,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQHISTORI',  'AQHISTORI',  'Kod bleres',		'AQH01',	55,	      'KODFKL',				'Kod Bleres',		80,		1,		1,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQHISTORI',  'AQHISTORI',  'Pershkrim bleres',	'AQH01',	55,	      'PERSHKRIMFKL',		'Bleres',			120,	0,		0,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQHISTORI',  'AQHISTORI',  'Monedhe',			'AQH01',	60,		  'KMON',				'Monedhe',			40,		0,		0,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQHISTORI',  'AQHISTORI',  'Kurs1',				'AQH01',	61,		  'KURS1',				'Kurs1',			40,		0,		0,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQHISTORI',  'AQHISTORI',  'Kurs2',				'AQH01',	62,		  'KURS2',				'Kurs2',			40,		0,		0,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQHISTORI',  'AQHISTORI',  'Vlera fat',			'AQH01',	65,		  'VLERAFAT',			'Vlerafat',			80,		0,		0,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQHISTORI',  'AQHISTORI',  'Vlera fatMv',		'AQH01',	66,		  'VLERAFATMV',			'Vlera Mv',			80,		0,		0,		0,			0,			0,	-1
         UNION ALL 
         SELECT    'AQHISTORI',  'AQHISTORI',  'Vlera shtese',		'AQH01',	67,		  'VLERAEXTMV',			'Vlera shtese',		80,		0,		0,		0,			0,			0,	-1
        
         PRINT 'Shtimi i reshtave AQHistori ne X_FORMDISPL ';
      END;


      SELECT @Size = Character_Maximum_Length
        FROM CONFIG.Information_schema.columns
       WHERE Table_Name = 'X_FORMDISPL'  And Column_Name='FORME';  
          if IsNull(@Size,0) < 50
             begin
               ALTER TABLE CONFIG..X_FORMDISPL ALTER COLUMN FORME VARCHAR(50) Null
               Print 'Ndryshim size fusha FORME ne CONFIG..X_FORMDISPL: Varchar(50)'
             end;

   IF NOT EXISTS ( SELECT * FROM CONFIG..X_FORMDISPL WHERE FORME='AQHISTORI')
      BEGIN   
         INSERT INTO CONFIG..X_FORMDISPL 
                (FORME,KOD,PERSHKRIM,IDFORME,NRORDER,FIELD,PROMPT,WIDTH,INGRID,DISPLAY,[READONLY],BUTONSTYLE,TROW,TAGNR)
         SELECT  FORME,KOD,PERSHKRIM,IDFORME,NRORDER,FIELD,PROMPT,WIDTH,INGRID,DISPLAY,[READONLY],BUTONSTYLE,TROW,TAGNR
           FROM X_FORMDISPL
          WHERE FORME='AQHISTORI' 
       ORDER BY NRORDER
          PRINT 'Shtimi i reshtave AQHistori ne CONFIG..X_FORMDISPL ';
      END; 
          
--



-- ARTIKUJCMF
   if dbo.Isd_FieldTableExists('ARTIKUJCMF','CMKLK')=0
      begin
        ALTER TABLE ARTIKUJCMF ADD CMKLK Varchar(40) NULL
        Print 'Shtim fusha CMKLK ne ARTIKUJCMF: Varchar(40)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJCMF','CMKLL')=0
      begin
        ALTER TABLE ARTIKUJCMF ADD CMKLL Varchar(40) NULL
        Print 'Shtim fusha CMKLL ne ARTIKUJCMF: Varchar(40)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJCMF','CMKLM')=0
      begin
        ALTER TABLE ARTIKUJCMF ADD CMKLM Varchar(40) NULL
        Print 'Shtim fusha CMKLM ne ARTIKUJCMF: Varchar(40)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJCMF','CMKLN')=0
      begin
        ALTER TABLE ARTIKUJCMF ADD CMKLN Varchar(40) NULL
        Print 'Shtim fusha CMKLN ne ARTIKUJCMF: Varchar(40)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJCMF','CMKLO')=0
      begin
        ALTER TABLE ARTIKUJCMF ADD CMKLO Varchar(40) NULL
        Print 'Shtim fusha CMKLO ne ARTIKUJCMF: Varchar(40)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJCMF','CMKLP')=0
      begin
        ALTER TABLE ARTIKUJCMF ADD CMKLP Varchar(40) NULL
        Print 'Shtim fusha CMKLP ne ARTIKUJCMF: Varchar(40)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJCMF','CMKLQ')=0
      begin
        ALTER TABLE ARTIKUJCMF ADD CMKLQ Varchar(40) NULL
        Print 'Shtim fusha CMKLQ ne ARTIKUJCMF: Varchar(40)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJCMF','CMKLR')=0
      begin
        ALTER TABLE ARTIKUJCMF ADD CMKLR Varchar(40) NULL
        Print 'Shtim fusha CMKLR ne ARTIKUJCMF: Varchar(40)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJCMF','CMKLS')=0
      begin
        ALTER TABLE ARTIKUJCMF ADD CMKLS Varchar(40) NULL
        Print 'Shtim fusha CMKLS ne ARTIKUJCMF: Varchar(40)'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJCMF','CMKLT')=0
      begin
        ALTER TABLE ARTIKUJCMF ADD CMKLT Varchar(40) NULL
        Print 'Shtim fusha CMKLT ne ARTIKUJCMF: Varchar(40)'
      end;


-- ArtikujLot

   IF NOT EXISTS (SELECT * FROM CONFIG..TABLESNAME WHERE TABLENAME='ARTIKUJLOT')
      BEGIN   
         INSERT INTO CONFIG..TABLESNAME 
               (TABLESTR,NRORDER,KOD,PERSHKRIM,TABLENAME,MODUL,TIP,ORG,OBJEKT,STRUCTURE,LIST,ORDERLM,KALIMLM,TROW,TAGNR)
          
         SELECT TABLESTR,
                NRORDER=(SELECT CASE WHEN COUNT(*)+1<=9 THEN '00' ELSE '0' END + CAST(COUNT(*)+1 AS VARCHAR)
                           FROM CONFIG..TablesName
                          WHERE TableName Like '%ARTIKUJ%' ),
                KOD='ARTIKUJLOT',PERSHKRIM='Artikuj lot/skadence',TABLENAME='ARTIKUJLOT',MODUL='M',TIP,ORG,OBJEKT,STRUCTURE,LIST,ORDERLM,KALIMLM=0,TROW=0,TAGNR=-1
           FROM CONFIG..TABLESNAME
          WHERE TABLENAME='ARTIKUJ';
                    
          PRINT 'Shtimi i reshtit ARTIKUJLOT ne tabelen CONFIG..TABLESNAME';
      END; ;



-- DRHUSER

   if dbo.Isd_FieldTableExists('DRHUSER','DOKPAMG')=0
      begin
        ALTER TABLE DRHUSER ADD DOKPAMG Bit NULL
        Print 'Shtim fusha DOKPAMG ne DRHUSER: Bit'
        if dbo.Isd_FieldTableExists('DRHUSER','NOTDOKPAMG')=1
           Exec (' 
             UPDATE DRHUSER 
                SET DOKPAMG = CASE WHEN MODUL=''F'' OR MODUL=''S'' 
                                   THEN CASE WHEN ISNULL(NOTDOKPAMG,0)=0 THEN 1 ELSE 0 END 
                                   ELSE 0 END')
        else
           Exec (' 
             UPDATE DRHUSER SET DOKPAMG = CASE WHEN MODUL=''F'' OR MODUL=''S'' THEN 1 ELSE 0 END ');
      end;

   if dbo.Isd_FieldTableExists('DRHUSER','LISTCM')=0
      begin
        ALTER TABLE DRHUSER ADD LISTCM Bit NULL
        Print 'Shtim fusha LISTCM ne DRHUSER: Bit'
        if dbo.Isd_FieldTableExists('DRHUSER','NOTLISTCM')=1
           Exec ('
             UPDATE DRHUSER 
                SET LISTCM = CASE WHEN MODUL=''F'' OR MODUL=''S''
                                  THEN CASE WHEN ISNULL(NOTLISTCM,0)=0 THEN 1 ELSE 0 END 
                                  ELSE 0 
                             END ')
        else
           Exec ('UPDATE DRHUSER SET LISTCM = CASE WHEN MODUL=''F'' OR MODUL=''S'' THEN 1 ELSE 0 END ');
      end;
   if dbo.Isd_FieldTableExists('DRHUSER','DSCNTROW')=0
      begin
        ALTER TABLE DRHUSER ADD DSCNTROW Bit NULL
        Print 'Shtim fusha DSCNTROW ne DRHUSER: Bit'
         Exec ('UPDATE DRHUSER SET DSCNTROW = CASE WHEN MODUL=''F'' OR MODUL=''S'' THEN 1 ELSE 0 END ');
      end;
   if dbo.Isd_FieldTableExists('DRHUSER','KMSROW')=0
      begin
        ALTER TABLE DRHUSER ADD KMSROW Bit NULL
        Print 'Shtim fusha KMSROW ne DRHUSER: Bit'
--      Exec ('UPDATE DRHUSER SET KMSROW=CASE WHEN MODUL=''S'' THEN 1 ELSE 0 END ');
      end;

   if dbo.Isd_FieldTableExists('DRHUSER','ROWLISTCMART')=0
      begin
        ALTER TABLE DRHUSER ADD ROWLISTCMART Bit NULL
        Print 'Shtim fusha ROWLISTCMART ne DRHUSER: Bit'
         Exec ('UPDATE DRHUSER SET ROWLISTCMART = CASE WHEN MODUL=''F'' OR MODUL=''S'' OR MODUL=''M'' THEN 1 ELSE 0 END ');
      end;
   if dbo.Isd_FieldTableExists('DRHUSER','ROWLISTCMDOC')=0
      begin
        ALTER TABLE DRHUSER ADD ROWLISTCMDOC Bit NULL
        Print 'Shtim fusha ROWLISTCMDOC ne DRHUSER: Bit'
         Exec ('UPDATE DRHUSER SET ROWLISTCMDOC = CASE WHEN MODUL=''F'' OR MODUL=''S'' OR MODUL=''M'' THEN 1 ELSE 0 END ');
      end;
   if dbo.Isd_FieldTableExists('DRHUSER','ROWLISTCMFF')=0
      begin
        ALTER TABLE DRHUSER ADD ROWLISTCMFF Bit NULL
        Print 'Shtim fusha ROWLISTCMFF ne DRHUSER: Bit'
         Exec ('UPDATE DRHUSER SET ROWLISTCMFF =  CASE WHEN MODUL=''F'' OR MODUL=''S'' OR MODUL=''M'' THEN 1 ELSE 0 END ');
      end;
   if dbo.Isd_FieldTableExists('DRHUSER','ROWLISTCMOF')=0
      begin
        ALTER TABLE DRHUSER ADD ROWLISTCMOF Bit NULL
        Print 'Shtim fusha ROWLISTCMOF ne DRHUSER: Bit'
         Exec ('UPDATE DRHUSER SET ROWLISTCMOF =  CASE WHEN MODUL=''F'' OR MODUL=''S'' OR MODUL=''M'' THEN 1 ELSE 0 END ');
      end;

   if dbo.Isd_FieldTableExists('DRHUSER','ROWCMSHREF')=0
      begin
        ALTER TABLE DRHUSER ADD ROWCMSHREF Bit NULL
        Print 'Shtim fusha ROWCMSHREF ne DRHUSER: Bit'
      end;


   if dbo.Isd_FieldTableExists('DRHUSER','PRICEMODIFSH')=0
      begin
        ALTER TABLE DRHUSER ADD PRICEMODIFSH Bit NULL
        Print 'Shtim fusha PRICEMODIFSH ne DRHUSER: Bit'
         Exec ('UPDATE DRHUSER SET PRICEMODIFSH = CASE WHEN (MODUL=''F'' OR MODUL=''S'') AND TIPDOK<>''DG'' THEN 1 ELSE 0 END ');
      end;

   if dbo.Isd_FieldTableExists('DRHUSER','DSCNTROWSH')=0
      begin
        ALTER TABLE DRHUSER ADD DSCNTROWSH Bit NULL
        Print 'Shtim fusha DSCNTROWSH ne DRHUSER: Bit'
         Exec ('UPDATE DRHUSER SET DSCNTROWSH  = CASE WHEN (MODUL=''F'' OR MODUL=''S'') AND TIPDOK<>''DG'' THEN 1 ELSE 0 END ');
      end;
--   if dbo.Isd_FieldTableExists('DRHUSER','NIPTDOCUPDATE')=0
--      begin
--        ALTER TABLE DRHUSER ADD NIPTDOCUPDATE Bit NULL
--        Print 'Shtim fusha NIPTDOCUPDATE ne DRHUSER: Bit'
--         Exec ('UPDATE DRHUSER SET NIPTDOCUPDATE = CASE WHEN (MODUL=''F'' OR MODUL=''S'') AND TIPDOK<>''DG'' THEN 1 ELSE 0 END ');
--      end;


-- ARKA

   if dbo.Isd_FieldTableExists('ARKA','LNKDOK')=0
      begin
        ALTER TABLE ARKA ADD LNKDOK Varchar(10) NULL
        Print 'Shtim fusha LNKDOK ne ARKA: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('ARKA','LNKNRRENDOR')=0
      begin
        ALTER TABLE ARKA ADD LNKNRRENDOR Int NULL
        Print 'Shtim fusha LNKNRRENDOR ne ARKA: Int'
      end;
   if dbo.Isd_FieldTableExists('ARKA','IMPORTTAG')=0
      begin
        ALTER TABLE ARKA ADD IMPORTTAG Varchar(5) NULL
        Print 'Shtim fusha IMPORTTAG ne ARKA: Varchar(5)'
      end;
   if dbo.Isd_FieldTableExists('ARKA','EXTIMPID')=0
      begin
        ALTER TABLE ARKA ADD EXTIMPID Varchar(50) NULL 
        Print 'Shtim fusha EXTIMPID ne ARKA: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('ARKA','EXTIMPKOMENT')=0
      begin
        ALTER TABLE ARKA ADD EXTIMPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTIMPKOMENT ne ARKA: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('ARKA','EXTEXP')=0
      begin
        ALTER TABLE ARKA ADD EXTEXP bit null 
        Print 'Shtim fusha EXTEXP ne ARKA: bit'
      end;
   if dbo.Isd_FieldTableExists('ARKA','EXTEXPKOMENT')=0
      begin
        ALTER TABLE ARKA ADD EXTEXPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTEXPKOMENT ne ARKA: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('ARKA','TAGRND')=0            
      begin
        ALTER TABLE ARKA ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne ARKA: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('ARKA','DATECREATE')=0
      begin
        ALTER TABLE ARKA ADD DATECREATE DATETIME NULL CONSTRAINT [DF_ARKA_DATECREATE]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne ARKA: DateTime'
      end;
   if dbo.Isd_FieldTableExists('ARKA','DATEEDIT')=0
      begin
        ALTER TABLE ARKA ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_ARKA_DATEEDIT]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne ARKA: DateTime'
      end;
   if dbo.Isd_FieldTableExists('ARKA','KONFIRM')=0
      begin
        ALTER TABLE ARKA ADD KONFIRM Bit NULL 
        Print 'Shtim fusha KONFIRM ne ARKA: Bit'
      end;

-- ARKASCR
   if dbo.Isd_FieldTableExists('ARKASCR','IMPORTKODAF')=0
      begin
        ALTER TABLE ARKASCR ADD IMPORTKODAF Varchar(60) NULL
        Print 'Shtim fusha IMPORTKODAF ne ARKASCR: Varchar(60)'
      end;
   if dbo.Isd_FieldTableExists('ARKASCR','TAGRND')=0            
      begin
        ALTER TABLE ARKASCR ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne ARKASCR: Varchar(30)'
      end;



-- BANKA

   if dbo.Isd_FieldTableExists('BANKA','LNKDOK')=0
      begin
        ALTER TABLE BANKA ADD LNKDOK Varchar(10) NULL
        Print 'Shtim fusha LNKDOK ne BANKA: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('BANKA','LNKNRRENDOR')=0
      begin
        ALTER TABLE BANKA ADD LNKNRRENDOR Int NULL
        Print 'Shtim fusha LNKNRRENDOR ne BANKA: Int'
      end;
   if dbo.Isd_FieldTableExists('BANKA','IMPORTTAG')=0
      begin
        ALTER TABLE BANKA ADD IMPORTTAG Varchar(5) NULL
        Print 'Shtim fusha IMPORTTAG ne BANKA: Varchar(5)'
      end;
   if dbo.Isd_FieldTableExists('BANKA','EXTIMPID')=0
      begin
        ALTER TABLE BANKA ADD EXTIMPID Varchar(50) NULL 
        Print 'Shtim fusha EXTIMPID ne BANKA: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('BANKA','EXTIMPKOMENT')=0
      begin
        ALTER TABLE BANKA ADD EXTIMPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTIMPKOMENT ne BANKA: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('BANKA','EXTEXP')=0
      begin
        ALTER TABLE BANKA ADD EXTEXP bit null 
        Print 'Shtim fusha EXTEXP ne BANKA: bit'
      end;
   if dbo.Isd_FieldTableExists('BANKA','EXTEXPKOMENT')=0
      begin
        ALTER TABLE BANKA ADD EXTEXPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTEXPKOMENT ne BANKA: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('BANKA','TAGRND')=0            
      begin
        ALTER TABLE BANKA ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne BANKA: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('BANKA','DATECREATE')=0
      begin
        ALTER TABLE BANKA ADD DATECREATE DATETIME NULL CONSTRAINT [DF_BANKA_DATECREATE]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne BANKA: DateTime'
      end;
   if dbo.Isd_FieldTableExists('BANKA','DATEEDIT')=0
      begin
        ALTER TABLE BANKA ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_BANKA_DATEEDIT]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne BANKA: DateTime'
      end;
   if dbo.Isd_FieldTableExists('BANKA','KONFIRM')=0
      begin
        ALTER TABLE BANKA ADD KONFIRM Bit NULL 
        Print 'Shtim fusha KONFIRM ne BANKA: Bit'
      end;

-- BANKASCR

   if dbo.Isd_FieldTableExists('BANKASCR','IMPORTKODAF')=0
      begin
        ALTER TABLE BANKASCR ADD IMPORTKODAF Varchar(60) NULL
        Print 'Shtim fusha IMPORTKODAF ne BANKASCR: Varchar(60)'
      end;
   if dbo.Isd_FieldTableExists('BANKASCR','TAGRND')=0            
      begin
        ALTER TABLE BANKASCR ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne BANKASCR: Varchar(30)'
      end;


-- FK

   if dbo.Isd_FieldTableExists('FK','EXTIMPID')=0
      begin
        ALTER TABLE FK ADD EXTIMPID Varchar(50) NULL 
        Print 'Shtim fusha EXTIMPID ne FK: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('FK','EXTIMPKOMENT')=0
      begin
        ALTER TABLE FK ADD EXTIMPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTIMPKOMENT ne FK: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FK','EXTEXP')=0
      begin
        ALTER TABLE FK ADD EXTEXP bit null 
        Print 'Shtim fusha EXTEXP ne FK: bit'
      end;
   if dbo.Isd_FieldTableExists('FK','EXTEXPKOMENT')=0
      begin
        ALTER TABLE FK ADD EXTEXPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTEXPKOMENT ne FK: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FK','TAGRND')=0            
      begin
        ALTER TABLE FK ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne FK: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FK','DATECREATE')=0
      begin
        ALTER TABLE FK ADD DATECREATE DATETIME NULL CONSTRAINT [DF_FK_DATECREATE]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne FK: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FK','DATEEDIT')=0
      begin
        ALTER TABLE FK ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_FK_DATEEDIT]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne FK: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FK','KONFIRM')=0
      begin
        ALTER TABLE FK ADD KONFIRM Bit NULL 
        Print 'Shtim fusha KONFIRM ne FK: Bit'
      end;

-- FKSCR

   if dbo.Isd_FieldTableExists('FKSCR','TAGRND')=0            
      begin
        ALTER TABLE FKSCR ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne FKSCR: Varchar(30)'
      end;

-- VS

   if dbo.Isd_FieldTableExists('VS','EXTIMPID')=0
      begin
        ALTER TABLE VS ADD EXTIMPID Varchar(50) NULL 
        Print 'Shtim fusha EXTIMPID ne VS: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('VS','EXTIMPKOMENT')=0
      begin
        ALTER TABLE VS ADD EXTIMPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTIMPKOMENT ne VS: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('VS','EXTEXP')=0
      begin
        ALTER TABLE VS ADD EXTEXP bit null 
        Print 'Shtim fusha EXTEXP ne VS: bit'
      end;
   if dbo.Isd_FieldTableExists('VS','EXTEXPKOMENT')=0
      begin
        ALTER TABLE VS ADD EXTEXPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTEXPKOMENT ne VS: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('VS','TAGRND')=0            
      begin
        ALTER TABLE VS ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne VS: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('VS','DATECREATE')=0
      begin
        ALTER TABLE VS ADD DATECREATE DATETIME NULL CONSTRAINT [DF_VS_DATECREATE]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne VS: DateTime'
      end;
   if dbo.Isd_FieldTableExists('VS','DATEEDIT')=0
      begin
        ALTER TABLE VS ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_VS_DATEEDIT]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne VS: DateTime'
      end;
   if dbo.Isd_FieldTableExists('VS','KONFIRM')=0
      begin
        ALTER TABLE VS ADD KONFIRM Bit NULL 
        Print 'Shtim fusha KONFIRM ne VS: Bit'
      end;

-- VSSCR

   if dbo.Isd_FieldTableExists('VSSCR','TAGRND')=0            
      begin
        ALTER TABLE VSSCR ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne VSSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('VSSCR','KODAGJENT')=0            
      begin
        ALTER TABLE VSSCR ADD KODAGJENT Varchar(30) NULL 
        Print 'Shtim fusha KODAGJENT ne VSSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('VSSCR','DTAF')=0            
      begin
        ALTER TABLE VSSCR ADD DTAF Int NULL 
        Print 'Shtim fusha DTAF ne VSSCR: Int'
      end;


-- FKST

   if dbo.Isd_FieldTableExists('FKST','EXTIMPID')=0
      begin
        ALTER TABLE FKST ADD EXTIMPID Varchar(50) NULL 
        Print 'Shtim fusha EXTIMPID ne FKST: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('FKST','EXTIMPKOMENT')=0
      begin
        ALTER TABLE FKST ADD EXTIMPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTIMPKOMENT ne FKST: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FKST','EXTEXP')=0
      begin
        ALTER TABLE FKST ADD EXTEXP bit null 
        Print 'Shtim fusha EXTEXP ne FKST: bit'
      end;
   if dbo.Isd_FieldTableExists('FKST','EXTEXPKOMENT')=0
      begin
        ALTER TABLE FKST ADD EXTEXPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTEXPKOMENT ne FKST: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FKST','TAGRND')=0            
      begin
        ALTER TABLE FKST ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne FKST: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FKST','DATECREATE')=0
      begin
        ALTER TABLE FKST ADD DATECREATE DATETIME NULL CONSTRAINT [DF_FKST_DATECREATE]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne FKST: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FKST','DATEEDIT')=0
      begin
        ALTER TABLE FKST ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_FKST_DATEEDIT]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne FKST: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FKST','KONFIRM')=0
      begin
        ALTER TABLE FKST ADD KONFIRM Bit NULL 
        Print 'Shtim fusha KONFIRM ne FKST: Bit'
      end;

-- FKSTSCR

   if dbo.Isd_FieldTableExists('FKSTSCR','TAGRND')=0            
      begin
        ALTER TABLE FKSTSCR ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne FKSTSCR: Varchar(30)'
      end;


-- VSST

   if dbo.Isd_FieldTableExists('VSST','EXTIMPID')=0
      begin
        ALTER TABLE VSST ADD EXTIMPID Varchar(50) NULL 
        Print 'Shtim fusha EXTIMPID ne VSST: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('VSST','EXTIMPKOMENT')=0
      begin
        ALTER TABLE VSST ADD EXTIMPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTIMPKOMENT ne VSST: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('VSST','EXTEXP')=0
      begin
        ALTER TABLE VSST ADD EXTEXP bit null 
        Print 'Shtim fusha EXTEXP ne VSST: bit'
      end;
   if dbo.Isd_FieldTableExists('VSST','EXTEXPKOMENT')=0
      begin
        ALTER TABLE VSST ADD EXTEXPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTEXPKOMENT ne VSST: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('VSST','TAGRND')=0            
      begin
        ALTER TABLE VSST ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne VSST: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('VSST','DATECREATE')=0
      begin
        ALTER TABLE VSST ADD DATECREATE DATETIME NULL CONSTRAINT [DF_VSST_DATECREATE]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne VSST: DateTime'
      end;
   if dbo.Isd_FieldTableExists('VSST','DATEEDIT')=0
      begin
        ALTER TABLE VSST ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_VSST_DATEEDIT]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne VSST: DateTime'
      end;
   if dbo.Isd_FieldTableExists('VSST','KONFIRM')=0
      begin
        ALTER TABLE VSST ADD KONFIRM Bit NULL 
        Print 'Shtim fusha KONFIRM ne VSST: Bit'
      end;
      

-- VSSTSCR

   if dbo.Isd_FieldTableExists('VSSTSCR','TAGRND')=0            
      begin
        ALTER TABLE VSSTSCR ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne VSSTSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('VSSTSCR','KODAGJENT')=0            
      begin
        ALTER TABLE VSSTSCR ADD KODAGJENT Varchar(30) NULL 
        Print 'Shtim fusha KODAGJENT ne VSSTSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('VSSTSCR','DTAF')=0            
      begin
        ALTER TABLE VSSTSCR ADD DTAF Int NULL 
        Print 'Shtim fusha DTAF ne VSSTSCR: Int'
      end;
      

-- OrderItems

   if dbo.Isd_FieldTableExists('ORDERITEMS','LISTORDERCOLMK')=0
      begin
        ALTER TABLE ORDERITEMS ADD LISTORDERCOLMK Varchar(5000) NULL
        Print 'Shtim fusha LISTORDERCOLMK ne ORDERITEMS: Varchar(5000)'
      end;

   if dbo.Isd_FieldTableExists('ORDERITEMS','LISTORDERCOLDQ')=0
      begin
        ALTER TABLE ORDERITEMS ADD LISTORDERCOLDQ Varchar(5000) NULL
        Print 'Shtim fusha LISTORDERCOLDQ ne ORDERITEMS: Varchar(5000)'
      end;
   if dbo.Isd_FieldTableExists('ORDERITEMS','LISTORDERCOLKL')=0
      begin
        ALTER TABLE ORDERITEMS ADD LISTORDERCOLKL Varchar(5000) NULL
        Print 'Shtim fusha LISTORDERCOLKL ne ORDERITEMS: Varchar(5000)'
      end;


--   if dbo.Isd_FieldTableExists('DRHUSER','NOTDOKPAMG')=0
--      begin
--        ALTER TABLE DRHUSER ADD NOTDOKPAMG Bit NULL
--        Print 'Shtim fusha NOTDOKPAMG ne DRHUSER: Bit'
--      end;
--   if dbo.Isd_FieldTableExists('DRHUSER','NOTLISTCM')=0
--      begin
--        ALTER TABLE DRHUSER ADD NOTLISTCM Bit NULL
--        Print 'Shtim fusha NOTLISTCM ne DRHUSER: Bit'
--      end;




         IF NOT EXISTS ( SELECT * FROM CONFIG.Information_Schema.Columns WHERE Table_Name='TIPDOK' AND Column_Name='SHENIM1')   
            ALTER TABLE CONFIG..TIPDOK ADD SHENIM1 VARCHAR(150) NULL

         IF NOT EXISTS ( SELECT * FROM CONFIG.Information_Schema.Columns WHERE Table_Name='TIPDOK' AND Column_Name='KLASIFIKIM1') 
            BEGIN  
              ALTER TABLE CONFIG..TIPDOK ADD KLASIFIKIM1 VARCHAR(150) NULL;
            END;  


        if IsNull((SELECT Character_Maximum_Length FROM CONFIG.information_schema.columns WHERE Table_Name = 'TIPDOK'  And Column_Name='TIPDOK'),0) < 30
           begin
             ALTER TABLE CONFIG..TIPDOK ALTER COLUMN TIPDOK VARCHAR(30) Null;
           end;


        if IsNull((SELECT Character_Maximum_Length FROM CONFIG.information_schema.columns WHERE Table_Name = 'TIPDOK'  And Column_Name='KOD'),0)    < 30
           begin
             ALTER TABLE CONFIG..TIPDOK ALTER COLUMN KOD VARCHAR(30) Null;
           end;

        if IsNull((SELECT Character_Maximum_Length FROM CONFIG.information_schema.columns WHERE Table_Name = 'TIPDOK'  And Column_Name='KODTD'),0)  < 30
           begin
             ALTER TABLE CONFIG..TIPDOK ALTER COLUMN KODTD VARCHAR(30) Null;
           end;



          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='H' AND ISNULL(KOD,'')='')
             begin
               SET    @Tip = 'H'
               UPDATE CONFIG..TIPDOK
                  SET PERSHKRIM='Pa klasifikuar'
                WHERE TIPDOK=@Tip AND KOD='NO';

               INSERT INTO CONFIG..TIPDOK
                     (TIPDOK, KOD,    PERSHKRIM,    NRORD,           KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               SELECT @Tip,   KOD='', PERSHKRIM='', NRORD=@Tip+'00', KODNUM, KODTD, VISIBLE, TROW, TAGNR
                 FROM CONFIG..TIPDOK
                WHERE TIPDOK=@Tip AND KOD='NO'
             end;

          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='D' AND ISNULL(KOD,'')='')
             begin

               SET    @Tip = 'D'

               UPDATE CONFIG..TIPDOK
                  SET PERSHKRIM='Pa klasifikuar'
                WHERE TIPDOK=@Tip AND KOD='NO';

               INSERT INTO CONFIG..TIPDOK
                     (TIPDOK, KOD,    PERSHKRIM,    NRORD,           KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               SELECT @Tip,   KOD='', PERSHKRIM='', NRORD=@Tip+'00', KODNUM, KODTD, VISIBLE, TROW, TAGNR
                 FROM CONFIG..TIPDOK
                WHERE TIPDOK=@Tip AND KOD='NO'
             end;


          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='D' AND ISNULL(KOD,'')='FR')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES ('D','FR','Firo Malli','D20', '0','',1,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='D' AND ISNULL(KOD,'')='KA')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES ('D','KA','Kthim amballazhi','D23', '0','',1,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='D' AND ISNULL(KOD,'')='MB')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES ('D','MB','Mbeturina','D24', '0','',1,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='D' AND ISNULL(KOD,'')='LA')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES ('D','LA','Larje produkt','D25', '0','',1,0,-1)
             end;


          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='H' AND ISNULL(KOD,'')='FR')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES ('H','FR','Firo malli','H20', '0','',1,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='H' AND ISNULL(KOD,'')='KA')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES ('H','KA','Kthim amballazhi','H23', '0','',1,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='H' AND ISNULL(KOD,'')='MB')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES ('H','MB','Mbeturina','H24', '0','',1,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='H' AND ISNULL(KOD,'')='LA')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES ('H','LA','Larje produkti','H25', '0','',1,0,-1)
             end;



          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='F' AND ISNULL(KOD,'')='')
             begin
               Set    @Tip = 'F'
               UPDATE CONFIG..TIPDOK
                  SET PERSHKRIM='Pa klasifikuar'
                WHERE TIPDOK=@Tip AND KOD='NO';

               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@Tip,   '', '',        @Tip+'00', '',     '',    1,       0,    -1)
             end;

          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='S' AND ISNULL(KOD,'')='')
             begin
               Set    @Tip = 'S'
               UPDATE CONFIG..TIPDOK
                  SET PERSHKRIM='Pa klasifikuar'
                WHERE TIPDOK=@Tip AND KOD='NO';

               INSERT INTO CONFIG..TIPDOK
                     (TIPDOK, KOD,    PERSHKRIM,    NRORD,           KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               SELECT @Tip,   KOD='', PERSHKRIM='', NRORD=@Tip+'00', KODNUM, KODTD, VISIBLE, TROW, TAGNR
                 FROM CONFIG..TIPDOK
                WHERE TIPDOK=@Tip AND KOD='NO'
             end;

          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='LFJ' AND ISNULL(KOD,'')='KN')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES ('LFJ','KN','Sherbime kontrate','LFJ25', '0','',1,0,-1)
             end;

          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='LFJ' AND ISNULL(KOD,'')='FR')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES ('LFJ','FR','Shkarkim firo malli','LFJ07', '0','',1,0,-1)
             end;




          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='LFF' AND ISNULL(KOD,'')='0')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES ('LFF','0','Lloji fatures','LFF00', '0','',0,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='LFF' AND ISNULL(KOD,'')='')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES ('LFF','','Fature','LFF01', '0','',1,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='LFF' AND ISNULL(KOD,'')='BL')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES ('LFF','BL','Blerje te trete','LFF02', '0','',1,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='LFF' AND ISNULL(KOD,'')='KN')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES ('LFF','KN','Sherbime kontrate','LFF03', '0','',1,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='LFF' AND ISNULL(KOD,'')='SH')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES ('LFF','SH','Sherbime te  tjera','LFF04', '0','',1,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='LFF' AND ISNULL(KOD,'')='T')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES ('LFF','T','Stornim dokumenti','LFF06', '0','',1,0,-1)
             end;




          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='OBJKL') -- AND ISNULL(KOD,'')='')
             begin
               SET  @Tip = 'OBJKL'

               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD, PERSHKRIM,             NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@Tip, '-1', 'Objekt Klienti',    @Tip+'00', '',     '',    1,       0,    -1)

               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD, PERSHKRIM,             NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@Tip, '0',      'Standart',          @Tip+'01', '',     '',    1,       0,    -1)

               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD, PERSHKRIM,             NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@Tip, '1',     'Magazine levizese', @Tip+'02', '',     '',    1,       0,    -1)

               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD, PERSHKRIM,             NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@Tip, '2',     'Dyqan',             @Tip+'03', '',     '',    1,       0,    -1)
             end;


          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='KRDBLC') -- AND ISNULL(KOD,'')='')
             begin
               SET  @Tip = 'KRDBLC'

               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD, PERSHKRIM,               NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@Tip, '-1', 'Testim kredi Klient',    @Tip+'00', '',     '',    1,       0,    -1)

               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD, PERSHKRIM,               NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@Tip, '0',      'Gjendje - Kredi',    @Tip+'01', '',     '',    1,       0,    -1)

               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD, PERSHKRIM,               NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@Tip, '1',     'Afat fature - Kredi', @Tip+'02', '',     '',    1,       0,    -1)
             end;



          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='GARSTAT') --  AND ISNULL(KOD,'')=''
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)

               SELECT A1='GARSTAT',A2='GARSTAT',A3='Gjendje garancie',A4='GARSTAT00', A5='0',A6='',A7=0,A8=0,A9=-1
            UNION ALL   
               SELECT 'GARSTAT','AKT','Aktive',  'GARSTAT01', '1','',1,0,-1
            UNION ALL   
               SELECT 'GARSTAT','MBY','Mbyllur', 'GARSTAT02', '2','',1,0,-1
            UNION ALL   
               SELECT 'GARSTAT','BLK','Blokuar', 'GARSTAT03', '3','',1,0,-1
            UNION ALL   
               SELECT 'GARSTAT','RIN','Rinovuar','GARSTAT04', '4','',1,0,-1

             end;

          IF NOT EXISTS(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='AQ') 
             BEGIN
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM,			NRORD, KODNUM,  KODTD, VISIBLE,  TROW, TAGNR)

               SELECT 'AQ', 'AQ', 'Veprime me Aktivet', 'AQ',  '0',		'AQ', 0,		0,-1
            UNION ALL   
               SELECT 'AQ', 'BL', 'Blerje',             'AQ01','1',		'',   1,		0,-1
            UNION ALL   
               SELECT 'AQ', 'AM', 'Amortizim',          'AQ02','2',		'',   1,		0,-1
            UNION ALL   
               SELECT 'AQ', 'RK', 'Riparim kapital',    'AQ03','3',		'',   1,		0,-1
            UNION ALL   
               SELECT 'AQ', 'RV', 'Rivleresim',         'AQ04','4',	    '',   1,		0,-1
            UNION ALL   
               SELECT 'AQ', 'SR', 'Sherbim',            'AQ05','5',	    '',   1,		0,-1
            UNION ALL   
               SELECT 'AQ', 'SH', 'Shitje',             'AQ06','6',		'',   1,		0,-1
            UNION ALL
               SELECT 'AQ', 'CE', 'Celje',              'AQ07','7',		'',   1,		0,-1   
            UNION ALL   
               SELECT 'AQ', 'SI', 'Sistemim',           'AQ08','8',		'',   1,		0,-1
            UNION ALL   
               SELECT 'AQ', 'NP', 'Nderrim Pronesie',   'AQ09','9',		'',   1,		0,-1
            UNION ALL
               SELECT 'AQ', 'JP', 'Jashte perdorimi',   'AQ10','10',	'',   1,		0,-1  
            UNION ALL
               SELECT 'AQ', 'CR', 'Cregjistrim aktivi', 'AQ11','11',	'',   1,		0,-1  
               
             END;
             
          IF NOT EXISTS (SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='AQ' AND KOD='RV') 
             BEGIN
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD,    VISIBLE, TROW, TAGNR)
               SELECT 'AQ', 'RV', 'Rivleresim',          'AQ04','4','',    1,0,-1;
             END;
          IF NOT EXISTS (SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='AQ' AND KOD='SR') 
             BEGIN
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD,    VISIBLE, TROW, TAGNR)
               SELECT 'AQ', 'SR', 'Sherbim',             'AQ05','5','',    1,0,-1;
             END;
          IF NOT EXISTS (SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='AQ' AND KOD='CR') 
             BEGIN
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD,    VISIBLE, TROW, TAGNR)
               SELECT 'AQ', 'CR', 'Cregjistrim',         'AQ10', '11','',   1,0,-1;
             END;
             
                                                                                        -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
          IF EXISTS (SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='AQ' AND KOD='MM')-- AND (PERSHKRIM LIKE '%Mirembajtje%')) 
             BEGIN
               UPDATE CONFIG..TIPDOK
                  SET KOD       = 'RK', 
                      PERSHKRIM = REPLACE(PERSHKRIM,'Mirembajtje','Riparim Kapital')
                WHERE TIPDOK='AQ' AND KOD='MM'; --AND PERSHKRIM LIKE '%Mirembajtje%'
             END;
             
          IF EXISTS (SELECT NRRENDOR FROM AQSCR WHERE KODOPER='MM')                     -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
             BEGIN
               UPDATE AQSCR SET KODOPER='RK' WHERE KODOPER='MM';  
             END;

             
-- Fiskalizimi

         SET @sString = 'KLIENTNIPT';    
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@sString AND ISNULL(KOD,'')=@sString)
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@sString,@sString,'Klasifikim Nipt', 'K00', '0','',1,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@sString AND ISNULL(KOD,'')='NUIS')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@sString,'NUIS',      'NIPT (numur)',    'K01', '0','',1,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@sString AND ISNULL(KOD,'')='ID')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@sString,'ID',        'Karte Identiteti','K02', '0','',1,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@sString AND ISNULL(KOD,'')='PASS')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@sString,'PASS',      'Pashaporte',      'K03', '0','',1,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@sString AND ISNULL(KOD,'')='VAT')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@sString,'VAT',       'VAT numur',       'K04', '0','',1,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@sString AND ISNULL(KOD,'')='TAX')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@sString,'TAX',       'TAX numur',       'K05', '0','',1,0,-1)
             end;
             
             
         SET @sString = 'FURNNIPT'; 
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@sString AND ISNULL(KOD,'')=@sString)
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@sString,@sString,'Klasifikim Nipt', 'K00', '0','',1,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@sString AND ISNULL(KOD,'')='NUIS')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@sString,'NUIS',      'NIPT (numur)',    'K01', '0','',1,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@sString AND ISNULL(KOD,'')='ID')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@sString,'ID',        'Karte Identiteti','K02', '0','',1,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@sString AND ISNULL(KOD,'')='PASS')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@sString,'PASS',      'Pashaporte',      'K03', '0','',1,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@sString AND ISNULL(KOD,'')='VAT')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@sString,'VAT',       'VAT numur',       'K04', '0','',1,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@sString AND ISNULL(KOD,'')='TAX')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@sString,'TAX',       'TAX numur',       'K05', '0','',1,0,-1)
             end;             

          SET @sString='FKTV';
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@sString AND ISNULL(KOD,'')='DOMESTIC')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@sString,'DOMESTIC', 'Blerje nga fermer vendas (fis)',     'F08', '0','FF',1,0,-1)
             end;             
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@sString AND ISNULL(KOD,'')='ABROAD')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@sString,'ABROAD',   'Blerje sherbimi jashte vendit (Fis)','F09', '0','FF',1,0,-1)
             end;     
		  if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@sString AND ISNULL(KOD,'')='AGREEMENT')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@sString,'AGREEMENT',   'Mareveshje midis paleve (Fis)','F10', '0','FF',1,0,-1)
             end; 
		  if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@sString AND ISNULL(KOD,'')='OTHER')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@sString,'OTHER',    'Te tjera (Fis)',                    'F11', '0','FF',1,0,-1)
             end;             
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@sString AND ISNULL(KOD,'')='FFRM')
			 begin
			   UPDATE CONFIG..TIPDOK SET VISIBLE=0 WHERE TIPDOK=@sString AND ISNULL(KOD,'')='FFRM'
			 end;
			         

          SET @sString='SKTV';
          --if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@sString AND ISNULL(KOD,'')='AGREEMENT')
          --   begin
          --     INSERT  INTO CONFIG..TIPDOK
          --            (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
          --     VALUES (@sString,'AGREEMENT', 'Mareveshje midis paleve (Fis)',    'S07', '0','FJ',1,0,-1)
          --   end;             
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@sString AND ISNULL(KOD,'')='SELF')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@sString,'SELF',     'Shitje vet vetes (Fis)',             'S08', '0','FJ',1,0,-1)
             end;             
          --if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@sString AND ISNULL(KOD,'')='OTHER')
          --   begin
          --     INSERT  INTO CONFIG..TIPDOK
          --            (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
          --     VALUES (@sString,'OTHER',    'Te tjera (Fis)',                    'S09', '0','FJ',1,0,-1)
          --   end;             

          SELECT @NrRendor=NRRENDOR FROM CONFIG..TIPDOK WHERE ISNULL(KOD,'')='SANG' AND TIPDOK='SKTV' AND CHARINDEX('ABROAD',UPPER(LTRIM(RTRIM(ISNULL(PERSHKRIM,'')))))=0;
		  if ISNULL(@NrRendor,0)>0
             begin
               UPDATE A 
			      SET PERSHKRIM='Autongarkese - ABROAD (fis)'
                 FROM CONFIG..TIPDOK  A 
                WHERE NRRENDOR=@NrRendor;
             end;             

          SELECT @NrRendor=NRRENDOR FROM CONFIG..TIPDOK WHERE ISNULL(KOD,'')='FANG' AND TIPDOK='FKTV' AND CHARINDEX('ABROAD',UPPER(LTRIM(RTRIM(ISNULL(PERSHKRIM,'')))))=0;
		  if ISNULL(@NrRendor,0)>0
             begin
               UPDATE A 
			      SET PERSHKRIM='Autongarkese - ABROAD (fis)'
                 FROM CONFIG..TIPDOK  A 
                WHERE NRRENDOR=@NrRendor;
             end;             



--             
             
                                                                                        -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
         SET @sSql = '
             IF EXISTS(SELECT NRRENDOR 
                         FROM CONFIG..TIPDOK 
                        WHERE TIPDOK=''AQ'' AND CHARINDEX('',''+KOD+'','','',BL,MM,RK,SR,'')>0 AND CHARINDEX('',FF,'','',''+ISNULL(KLASIFIKIM1,'''')+'','')=0)
                BEGIN
                  UPDATE CONFIG..TIPDOK
                     SET KLASIFIKIM1=ISNULL(KLASIFIKIM1,'''')+'',FF'' 
                   WHERE TIPDOK=''AQ'' AND CHARINDEX('',''+KOD+'','','',BL,MM,RK,SR,'')>0 AND CHARINDEX('',FF,'','',''+ISNULL(KLASIFIKIM1,'''')+'','')=0;
                END; ';
        EXEC (@sSql);
        
        
          -- Rregullimi i orderit per veprimet me asetet
          
      UPDATE CONFIG..TIPDOK                                                             -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
         SET 
             NRORD  = 'AQ'+CASE WHEN  (CHARINDEX(KOD,'BL,AM,RK,RV,SR,SH,CE,SI,NP,JP,CR')+2)/3 > 9
                                THEN ''
                                ELSE '0'
                           END + CAST((CHARINDEX(KOD,'BL,AM,RK,RV,SR,SH,CE,SI,NP,JP,CR')+2)/3 AS VARCHAR),
             KODNUM = (CHARINDEX(KOD,'BL,AM,RK,RV,SR,SH,CE,SI,NP,JP,CR')+2)/3
        FROM CONFIG..TIPDOK 
       WHERE TIPDOK='AQ' AND KODNUM<>0 AND 
            ((Replace(Replace(NRORD,'AQ0',''),'AQ','')<>(CHARINDEX(KOD,'BL,AM,RK,RV,SR,SH,CE,SI,NP,JP,CR')+2)/3) 
             OR
             KODNUM<>(CHARINDEX(KOD,'BL,AM,RK,RV,SR,SH,CE,SI,NP,JP,CR')+2)/3);
        

 

         SET @Tip = 'MG';
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@Tip AND ISNULL(KOD,'')=@Tip)
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD, PERSHKRIM,              NRORD,      KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@Tip,  @Tip,   'Njesi administrative', '',         '0','',1,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@Tip AND ISNULL(KOD,'')='00')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD, PERSHKRIM,             NRORD,      KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@Tip,  '00', '',                    '00',       '0','',1,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@Tip AND ISNULL(KOD,'')='01')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD, PERSHKRIM,             NRORD,      KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@Tip,  '01', 'Magazine',            '01',       '0','',1,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@Tip AND ISNULL(KOD,'')='02')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD, PERSHKRIM,             NRORD,      KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@Tip,  '02', 'Dyqan',               '02',       '0','',1,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@Tip AND ISNULL(KOD,'')='03')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD, PERSHKRIM,             NRORD,      KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@Tip,  '03', 'Makine',              '03',       '0','',1,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@Tip AND ISNULL(KOD,'')='10')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD, PERSHKRIM,             NRORD,      KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@Tip,  '10', 'Njesi tregetare',     '10',       '0','',1,0,-1)
             end;
          if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@Tip AND ISNULL(KOD,'')='50')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD, PERSHKRIM,             NRORD,      KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@Tip,  '50', 'Shkolle',             '50',       '0','',1,0,-1)
             end;
          IF NOT EXISTS(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@Tip AND ISNULL(KOD,'')='51')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD, PERSHKRIM,             NRORD,      KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@Tip,  '51', 'Universitet',         '51',       '0','',1,0,-1)
             end;
          IF NOT EXISTS(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@Tip AND ISNULL(KOD,'')='52')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD, PERSHKRIM,             NRORD,      KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@Tip,  '52', 'Kopesht',             '52',       '0','',1,0,-1)
             end;             
          IF NOT EXISTS(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK=@Tip AND ISNULL(KOD,'')='53')
             begin
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD, PERSHKRIM,             NRORD,      KODNUM, KODTD, VISIBLE, TROW, TAGNR)
               VALUES (@Tip,  '53', 'Cerdhe',              '53',       '0','',1,0,-1)
             end;           
             
             

          IF NOT EXISTS(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='TVSHFIC')      -- Fiskalizimi
             BEGIN
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD, KODNUM, KODTD, VISIBLE, TROW, TAGNR)

               SELECT 'TVSHFIC', 'TVSHFIC',         'Tvsh fiskalizimi',          'FIC',  '0',		'',   0,		0,-1
            UNION ALL   
               SELECT 'TVSHFIC', 'VAT',             'Furnizim me zero',          'FIC01','1',		'',   1,		0,-1
            UNION ALL   
               SELECT 'TVSHFIC', 'TYPE_1',          'Exempt type 1',             'FIC02','2',		'',   1,		0,-1
            UNION ALL   
               SELECT 'TVSHFIC', 'TYPE_2',          'Exempt type 2',             'FIC03','3',		'',   1,		0,-1
            UNION ALL   
               SELECT 'TVSHFIC', 'TAX-FREE',        'Tax free amount',           'FIC04','4',	    '',   1,		0,-1
            UNION ALL   
               SELECT 'TVSHFIC', 'MARGIN_SCHEME',   'Travel agjent VAT scheme',  'FIC05','5',	    '',   1,		0,-1
            UNION ALL   
               SELECT 'TVSHFIC', 'EXPORT_OF_GOODS', 'Export of goods, NO VAT',   'FIC06','6',		'',   1,		0,-1
             END;

          IF NOT EXISTS(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='TVSHEIC')      -- Fatura elektronike EIC
             BEGIN
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD, KODNUM, KODTD, VISIBLE, TROW, TAGNR)

               SELECT 'TVSHEIC', 'TVSHEIC',  'Tvsh fature elektronike',                         'EIC',  '0',		'',   0,		0,-1
            UNION ALL   
               SELECT 'TVSHEIC', 'S',        'Per TVSH 20,10,6',                                'EIC01','1',		'',   1,		0,-1
            UNION ALL   
               SELECT 'TVSHEIC', 'K',        'Per Exporte brenda BE',                           'EIC02','2',		'',   1,		0,-1
            UNION ALL   
               SELECT 'TVSHEIC', 'G',        'Per exporte jashte BE',                           'EIC03','3',		'',   1,		0,-1
            UNION ALL   
               SELECT 'TVSHEIC', 'E',        'Perjashtim nga taksa',                            'EIC04','4',	    '',   1,		0,-1
            UNION ALL   
               SELECT 'TVSHEIC', 'AE',       'Auto ngarkese e TVSH-se',                         'EIC05','5',	    '',   1,		0,-1
            UNION ALL   
               SELECT 'TVSHEIC', 'Z',        'Norma zero',                                      'EIC06','6',		'',   1,		0,-1
            UNION ALL   
               SELECT 'TVSHEIC', 'O',        'Jashte fushes se TVSH-se',                        'EIC07','7',		'',   1,		0,-1
            UNION ALL   
               SELECT 'TVSHEIC', 'L',        'IGIC Ishujt Kanarie',                             'EIC08','8',		'',   1,		0,-1
            UNION ALL   
               SELECT 'TVSHEIC', 'M',        'IPSI Taksa Ceute dhe melille (Reklama & Tabela)', 'EIC09','9',		'',   1,		0,-1
             END;

          IF NOT EXISTS(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='TVSHEFEKT')    -- Percaktimi i kohes efektive te TVSH-se
             BEGIN
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD, KODNUM, KODTD, VISIBLE, TROW, TAGNR)

               SELECT 'TVSHEFEKT', 'TVSHEFEKT', 'Tvsh efektive',                                'EFEKT',  '0',	    '',   0,		0,-1
            UNION ALL   
               SELECT 'TVSHEFEKT', '35',        'Date e dorezimi/koha,aktuale',                 'EFEKT01','1',	    '',   1,		0,-1
            UNION ALL   
               SELECT 'TVSHEFEKT', '432',       'Date e leshimit te fatures ',                  'EFEKT02','2',	    '',   1,		0,-1
            UNION ALL   
               SELECT 'TVSHEFEKT', 'G',         'Paguar deri me sot',                           'EFEKT03','3',	    '',   1,		0,-1
             END;



      INSERT INTO SG_LIBRAT
            (PERSHKRIM,NRSEGL,NRSEGD,LIBER,DITAR,TIP,TROW,TAGNR)

      SELECT PERSHKRIM,NRSEGL,NRSEGD,LIBER,DITAR,TIP,TROW,TAGNR
        FROM CONFIG.dbo.SG_LIBRAT A
       WHERE NOT EXISTS (SELECT * FROM SG_LIBRAT B WHERE A.LIBER=B.LIBER)
    ORDER BY LIBER; 

      INSERT INTO SG_SEGMENTSL
            ([USC],[NRD],[CODE],[KOD],[S_NAME],[DESC],[NR],[DISPLAYED],[INDEXED],[VAL_DEFAULT],[REQUIRED],[SIZE_DISPLAY],[SIZE_DESC],[SIZE_SHORTDESC],[T],[SECURITY],
             [VAL_TYPE],[VAL_NO],[VAL_UCO],[VAL_RIGHT],[VAL_SIZE],[VAL_MIN],[VAL_MAX],[HEMODE],[HESTR],[MANUALE],[SKEDARI],[LEVIZ],[MERPJESE],[TROW],[TAGNR])

      SELECT [USC],[NRD],[CODE],[KOD],[S_NAME],[DESC],[NR],[DISPLAYED],[INDEXED],[VAL_DEFAULT],[REQUIRED],[SIZE_DISPLAY],[SIZE_DESC],[SIZE_SHORTDESC],[T],[SECURITY],
             [VAL_TYPE],[VAL_NO],[VAL_UCO],[VAL_RIGHT],[VAL_SIZE],[VAL_MIN],[VAL_MAX],[HEMODE],[HESTR],[MANUALE],[SKEDARI],[LEVIZ],[MERPJESE],[TROW],[TAGNR]
        FROM CONFIG.[dbo].[SG_SEGMENTSL] A
       WHERE NOT EXISTS (SELECT * FROM SG_SEGMENTSL B WHERE A.CODE=B.CODE AND A.KOD=B.KOD)
    ORDER BY CODE,KOD; 
    

          if DB_Name()<>'CONFIG'
             begin
               Insert Into Decimals
                     (TABLENAME,PERSHKRIM,SASI,CMIM,VLEFTE,CMIMVL,VLEFTEVL,MODUL,TIP,NRORDER,USI,USM,TROW,TAGNR)
               Select TABLENAME,PERSHKRIM,SASI,CMIM,VLEFTE,CMIMVL,VLEFTEVL,MODUL,TIP,NRORDER,USI,USM,TROW,TAGNR 
                 From Config..Decimals A
                Where Not Exists (SELECT NRRENDOR From Decimals Where TableName=A.TableName)
             end;

         SET @sSql1 = '

               SET ANSI_NULLS ON
               SET QUOTED_IDENTIFIER ON
               SET ANSI_PADDING ON
               CREATE TABLE [dbo].[LLOGSHPZ](
	             [NRRENDOR] [int] IDENTITY(1,1) NOT NULL,
	             [KOD] [varchar](30) NULL,
	             [PERSHKRIM] [varchar](100) NULL,
	             [TIP] [varchar](10) NULL,
	             [USI] [varchar](10) NULL,
	             [USM] [varchar](10) NULL,
	             [TROW] [bit] NULL,
	             [TAGNR] [int] NULL
                 ) ON [PRIMARY]
               SET ANSI_PADDING OFF

               Print ''Krijim tabele ''+DB_NAME()+''..LLOGSHPZ'' '
 

          if Object_Id('LLOGSHPZ') is null
             EXEC(@sSql1);

          if Object_Id('CONFIG..LLOGSHPZ') is null
             EXEC ('USE CONFIG; ' + @sSql1)

          if dbo.Isd_FieldTableExists('LLOGSHPZ','TIP')=0
             begin
               ALTER TABLE LLOGSHPZ ADD TIP Varchar(10) NULL
               Print 'Shtim fusha TIP ne LLOGSHPZ: Varchar(10)'
             end;

          if Config.dbo.Isd_FieldTableExists('LLOGSHPZ','TIP')=0
             begin
               ALTER TABLE CONFIG.dbo.LLOGSHPZ ADD TIP Varchar(10) NULL
               Print 'Shtim fusha TIP ne CONFIG.dbo.LLOGSHPZ: Varchar(10)'
             end;



          if not Exists(SELECT NRRENDOR FROM NJESI WHERE ISNULL(KOD,'')='MUAJ')
             begin
               INSERT  INTO NJESI (KOD,PERSHKRIM) VALUES ('MUAJ','Muaj');
             end;
          if not Exists(SELECT NRRENDOR FROM NJESI WHERE ISNULL(KOD,'')='VIT')
             begin
               INSERT  INTO NJESI (KOD,PERSHKRIM) VALUES ('VIT','Vit');
             end;
          if not Exists(SELECT NRRENDOR FROM NJESI WHERE ISNULL(KOD,'')='JAVE')
             begin
               INSERT  INTO NJESI (KOD,PERSHKRIM) VALUES ('JAVE','Jave');
             end;

             
-- Cmimet e Shitjes te rejat

  Declare @sSqlArtCm1 Varchar(Max),
          @sSqlArtCm2 Varchar(Max);


      Set @sSql  = '';

      Set @sSql2 = '
          if dbo.Isd_FieldTableExists(''ARTIKUJ'',''CMSH10'')=0
             begin
               ALTER TABLE ARTIKUJ ADD CMSH10 Float NULL
               Print ''Shtim fusha CMSH10 ne ARTIKUJ: Float''
             end; ';
      Set @i = 10;
    While @i<=19
      begin
        Set @sSql = @sSql + Replace(@sSql2,'CMSH10','CMSH'+Cast(@i As Varchar(10)));
        Set @i = @i + 1;
      end;
      Set @sSqlArtCm1 = @sSql;


      Set @sSql = '';

      Set @sSql2 = '
          	     CMSH10 = CASE WHEN ISNULL(CMSH10,0)=0 AND ISNULL(CMSH9,0)=0 THEN CMSH
							   WHEN ISNULL(CMSH10,0)=0                       THEN CMSH9
							   ELSE ISNULL(CMSH10,0)
							   END';
      Set @i = 10;
    While @i<=19
      begin
        Set @sSql = @sSql + Replace(@sSql2,'CMSH10','CMSH'+Cast(@i As Varchar(10)))
         if @i<19
            Set @sSql = @sSql + ',';
        Set @i = @i + 1;
      end;


      Set @sSqlArtCm2 = '
		  UPDATE ARTIKUJ 
             SET ' + @sSql + ';';


-- ARTIKUJ   
   if dbo.Isd_FieldTableExists('ARTIKUJ','CMSH10')=0
      begin
        Set   @sSql = @sSqlArtCm1;
        Exec (@sSql);
        Set   @sSql = @sSqlArtCm2;
        Exec (@sSql);
      end;

-- ARTIKUJSIST
   if dbo.Isd_FieldTableExists('ARTIKUJSIST','CMSH10')=0
      begin
        Set   @sSql = Replace(@sSqlArtCm1,'ARTIKUJ','ARTIKUJSIST');
        Exec (@sSql);
        Set   @sSql = Replace(@sSqlArtCm2,'ARTIKUJ','ARTIKUJSIST');
        Exec (@sSql);
      end;

-- ARTIKUJCM
   if dbo.Isd_FieldTableExists('ARTIKUJCM','CMSH10')=0
      begin
        Set   @sSql = Replace(@sSqlArtCm1,'ARTIKUJ','ARTIKUJCM');
        Exec (@sSql);
        Set   @sSql = Replace(@sSqlArtCm2,'ARTIKUJ','ARTIKUJCM');
        Exec (@sSql);
      end;

-- KlientCmimArt
   if dbo.Isd_FieldTableExists('KlientCmimArt','CMSH10')=0
      begin
        Set   @sSql = Replace(@sSqlArtCm1,'ARTIKUJ','KlientCmimArt');
        Exec (@sSql);
        Set   @sSql = Replace(@sSqlArtCm2,'ARTIKUJ','KlientCmimArt');
        Exec (@sSql);
      end;

    SELECT @i=Character_Maximum_Length    
      FROM Information_Schema.Columns  
     WHERE Table_Name = 'KlientCmimArt' AND Column_Name='PERSHKRIM';
       SET @i = IsNull(@i,0);
        IF @i>0  And  @i<150
           BEGIN
             ALTER TABLE KlientCmimArt ALTER COLUMN PERSHKRIM VARCHAR(150) NULL;
             PRINT 'Modifikim fusha PERSHKRIM ne KLIENTCMIMART: Length(150)';
           END;

    SELECT @i=Character_Maximum_Length    
      FROM Information_Schema.Columns  
     WHERE Table_Name = 'KlientCmimKL'  AND Column_Name='PERSHKRIM';
       SET @i = IsNull(@i,0);
        IF @i>0  And  @i<150
           BEGIN
             ALTER TABLE KlientCmimKL ALTER COLUMN PERSHKRIM VARCHAR(150) NULL;
             PRINT 'Modifikim fusha PERSHKRIM ne KLIENTCMIMKL: Length(150)';
           END;


-- ArtikujCmime ???

      Set @sSql = Replace(@sSqlArtCm1,'ARTIKUJ','ARTIKUJCMIME');

      Set @i = 10;
    While @i<=19
      begin
        Set @sSql = Replace(@sSql,'CMSH'+Cast(@i As Varchar(10)),'CMSH'+Cast(@i As Varchar(10))+'OLD');
        Set @i = @i + 1;
      end;

      Set @sSqlArtCm2 = @sSql+'
          '+
          Replace(@sSql,'OLD','NEW');


      Set @sSql = '';

      Set @sSql2 = '
          	     CMSH10OLD = CASE WHEN ISNULL(CMSH10OLD,0)=0 AND ISNULL(CMSH9OLD,0)=0 THEN CMSHOLD
							      WHEN ISNULL(CMSH10OLD,0)=0                          THEN CMSH9OLD
							      ELSE ISNULL(CMSH10OLD,0)
							      END,
          	     CMSH10NEW = CASE WHEN ISNULL(CMSH10NEW,0)=0 AND ISNULL(CMSH9NEW,0)=0 THEN CMSHNEW
							      WHEN ISNULL(CMSH10NEW,0)=0                          THEN CMSH9NEW
							      ELSE ISNULL(CMSH10NEW,0)
							      END';
      Set @i = 10;
    While @i<=19
      begin
        Set @sSql = @sSql + Replace(@sSql2,'CMSH10','CMSH'+Cast(@i As Varchar(10)))
         if @i<19
            Set @sSql = @sSql + ',';
        Set @i = @i + 1;
      end;

      Set @sSql = '

		  UPDATE ARTIKUJCMIME 
             SET ' + @sSql + ';';


   if dbo.Isd_FieldTableExists('ARTIKUJCMIME','CMSH10OLD')=0
      begin
        Set   @sSql = @sSqlArtCm1;

        Exec (@sSql);
        Set   @sSql = @sSqlArtCm2;
        Exec (@sSql);
      end;


-- Tek CONFIG futen Klasat e Klient, Magazina etje
 
      Declare @sKod     Varchar(30),
              @sList    Varchar(30);

          Set @i      = 1;
          Set @sList  = 'KLMNOPQRST';

      while @i<=10 
        begin
          Set @sKod = Substring(@sList,@i,1);
           if Not Exists (SELECT *
                            FROM CONFIG..TIPDOK 
                           WHERE (TIPDOK='Y') AND (KOD=@sKod))
              Insert Into CONFIG..TIPDOK
                    (TIPDOK,KOD,PERSHKRIM,NRORD,KODNUM)
              Select TIPDOK    = 'Y', 
                     KOD       = @sKod, 
                     PERSHKRIM = 'Grupi '+@sKod, 
                     NRORD     = 'Y'+CAST(@i+10 As Varchar), 
                     KODNUM    = @i+10;
          Set @i = @i + 1; 
        end;


-- Cmimet e Shitjes te rejat - Fund


    SELECT @i=Character_Maximum_Length    
      FROM Information_Schema.Columns  
     WHERE Table_Name = 'ARTIKUJ' AND Column_Name='KODORG';

       SET @i = IsNull(@i,0);
        IF @i>0  And  @i<129
           ALTER TABLE ARTIKUJ ALTER COLUMN KODORG VARCHAR(120) NULL;



-- Fusha STATROW

   if dbo.Isd_FieldTableExists('FJSCR','STATROW')=0
      begin
        Set @TablesList   = 'FHSCR,FDSCR,FJSCR,FFSCR,DGSCR,FJTSCR,OFKSCR,ORKSCR,ORFSCR,SMSCR,SMBAKSCR,FJPG,'+
                            'ARKASCR,BANKASCR,FKSCR,VSSCR,FKSTSCR,VSSTSCR,'+
                            'ARTIKUJBCSCR,ARTIKUJFIR,ARTIKUJKFSCR,ORDERITEMSSCR,ARTIKUJSCR,ARTIKUJSIST,'+
                            'DRHUSER,'+
                            'KLIENTCM,KLIENTCMIMART,KLIENTCMIMCM,KLIENTCMIMKL,ORDERITEMSSORTSCR,LISTFIROD';
        Set @sSql = '  
                      ALTER TABLE FHSCR ADD STATROW Varchar(5) NULL;
                      Print ''Shtim fusha STATROW ne FHSCR: Varchar(5)''; ';
        Set @i = 1;
        Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;
        while @i<=@k
          begin 
            Set   @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
            Set   @sSql1  = Replace(@sSql,'FHSCR',@TableName);
            Exec (@sSql1);
            Set   @i = @i + 1
          end; 
      end;



-- Pjesa Amballazh

   if dbo.Isd_FieldTableExists('ARTIKUJ','ISAMB')=0
      begin
        ALTER TABLE ARTIKUJ ADD ISAMB Bit NULL
        Print 'Shtim fusha ISAMB ne ARTIKUJ: Bit'
      end;

   if dbo.Isd_FieldTableExists('CONFIGMG','KMAGAMB')=0
      begin
        ALTER TABLE CONFIGMG ADD KMAGAMB Varchar(10) NULL
        Print 'Shtim fusha KMAGAMB ne CONFIGMG: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('CONFIGLM','LLOGAMBRJET')=0
      begin
        ALTER TABLE CONFIGLM ADD LLOGAMBRJET Varchar(30) NULL
        Print 'Shtim fusha LLOGAMBRJET ne CONFIGLM: Varchar(30)'
      end;

   if dbo.Isd_FieldTableExists('FJ','NRRENDORAMB')=0
      begin
        ALTER TABLE FJ ADD NRRENDORAMB Int NULL
        Print 'Shtim fusha NRRENDORAMB ne FJ: Int'
      end;
   if dbo.Isd_FieldTableExists('FF','NRRENDORAMB')=0
      begin
        ALTER TABLE FF ADD NRRENDORAMB Int NULL
        Print 'Shtim fusha NRRENDORAMB ne FF: Int'
      end;
   if dbo.Isd_FieldTableExists('FJSCR','ISAMB')=0
      begin
        ALTER TABLE FJSCR ADD ISAMB Bit NULL
        Print 'Shtim fusha ISAMB ne FJSCR: Bit'
      end;

   if dbo.Isd_FieldTableExists('FD','ISAMB')=0  -- A duhet ??
      begin
        ALTER TABLE FD ADD ISAMB Bit NULL
        Print 'Shtim fusha ISAMB ne FD: Bit'
      end;
   if dbo.Isd_FieldTableExists('FD','NRRENDORFATAMB')=0  
      begin
        ALTER TABLE FD ADD NRRENDORFATAMB Int NULL
        Print 'Shtim fusha NRRENDORFATAMB ne FD: Int'
      end;


   if dbo.Isd_FieldTableExists('FH','ISAMB')=0  -- A duhet ??
      begin
        ALTER TABLE FH ADD ISAMB Bit NULL
        Print 'Shtim fusha ISAMB ne FH: Bit'
      end;
   if dbo.Isd_FieldTableExists('FH','NRRENDORFATAMB')=0  
      begin
        ALTER TABLE FH ADD NRRENDORFATAMB Int NULL
        Print 'Shtim fusha NRRENDORFATAMB ne FH: Int'
      end;

   if dbo.Isd_FieldTableExists('FJTSCR','ISAMB')=0
      begin
        ALTER TABLE FJTSCR ADD ISAMB Bit NULL
        Print 'Shtim fusha ISAMB ne FJTSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('OFKSCR','ISAMB')=0
      begin
        ALTER TABLE OFKSCR ADD ISAMB Bit NULL
        Print 'Shtim fusha ISAMB ne OFKSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('ORKSCR','ISAMB')=0
      begin
        ALTER TABLE ORKSCR ADD ISAMB Bit NULL
        Print 'Shtim fusha ISAMB ne ORKSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('SMSCR','ISAMB')=0
      begin
        ALTER TABLE SMSCR ADD ISAMB Bit NULL
        Print 'Shtim fusha ISAMB ne SMSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('SMBAKSCR','ISAMB')=0
      begin
        ALTER TABLE SMBAKSCR ADD ISAMB Bit NULL
        Print 'Shtim fusha ISAMB ne SMBAKSCR: Bit'
      end;

   if dbo.Isd_FieldTableExists('FFSCR','ISAMB')=0
      begin
        ALTER TABLE FFSCR ADD ISAMB Bit NULL
        Print 'Shtim fusha ISAMB ne FFSCR: Bit'
      end;
   if dbo.Isd_FieldTableExists('ORFSCR','ISAMB')=0
      begin
        ALTER TABLE ORFSCR ADD ISAMB Bit NULL
        Print 'Shtim fusha ISAMB ne ORFSCR: Bit'
      end;
   if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='H' AND KOD='SH')
      begin
        INSERT INTO CONFIG..TIPDOK
              (TIPDOK,KOD,PERSHKRIM,NRORD,KODNUM,KODTD,VISIBLE,TROW,TAGNR)
        SELECT 'H',   'SH', 'Amballazh rjet',     'H41',      '',     '',    1,       0,    -1
      end;

-- Fund amballazh



-- Pike shitje 
     if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='PGPS')
        begin
          Set     @Tip = 'PGPS'
          INSERT  INTO CONFIG..TIPDOK
                 (TIPDOK,KOD,PERSHKRIM,NRORD,KODNUM,KODTD,VISIBLE,TROW,TAGNR)
          SELECT @Tip,   @Tip, 'Form Pagese',     @Tip,      '',     '',    1,       0,    -1
       UNION ALL
          SELECT @Tip,   'CA', 'Pagese ne dore',  @Tip+'01', '',     '',    1,       0,    -1
       UNION ALL
          SELECT @Tip,   'CR', 'Karte krediti',   @Tip+'02', '',     '',    1,       0,    -1
       UNION ALL
          SELECT @Tip,   'BA', 'Banke',           @Tip+'03', '',     '',    1,       0,    -1
       UNION ALL
          SELECT @Tip,   'PK', 'Pike grumbullar', @Tip+'04', '',     '',    1,       0,    -1
       UNION ALL
          SELECT @Tip,   'ET', 'etj',             @Tip+'50', '',     '',    1,       0,    -1

        end;

     if not Exists(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='PGCR')      -- Fiskalizim
        begin
          Set     @Tip = 'PGCR'
          INSERT  INTO CONFIG..TIPDOK
                 (TIPDOK,KOD,PERSHKRIM,NRORD,KODNUM,KODTD,VISIBLE,TROW,TAGNR)
          SELECT @Tip,   @Tip,   'Form likujdimi',   @Tip,      '',     '',    1,       0,    -1
       UNION ALL
          SELECT @Tip,   '',     '',                 @Tip+'0 ', '',     '',    1,       0,    -1
       UNION ALL
          SELECT @Tip,   'CRCD', 'Credit Card',      @Tip+'00', '',     '',    1,       0,    -1
       UNION ALL
          SELECT @Tip,   'AMEX', 'American Express', @Tip+'01', '',     '',    1,       0,    -1
       UNION ALL
          SELECT @Tip,   'BOFA', 'Bank of America',  @Tip+'02', '',     '',    1,       0,    -1
       UNION ALL
          SELECT @Tip,   'BARC', 'BarclayCard US',   @Tip+'03', '',     '',    1,       0,    -1
       UNION ALL
          SELECT @Tip,   'CONE', 'Capital One',      @Tip+'04', '',     '',    1,       0,    -1
       UNION ALL
          SELECT @Tip,   'CHAS', 'Chase',            @Tip+'05', '',     '',    1,       0,    -1
       UNION ALL
          SELECT @Tip,   'CITI', 'Citi Bank',        @Tip+'06', '',     '',    1,       0,    -1
       UNION ALL
          SELECT @Tip,   'DISC', 'Discover',         @Tip+'07', '',     '',    1,       0,    -1
       UNION ALL
          SELECT @Tip,   'MAST', 'MasterCard',       @Tip+'08', '',     '',    1,       0,    -1
       UNION ALL
          SELECT @Tip,   'PNC',  'PNC',              @Tip+'09', '',     '',    1,       0,    -1
       UNION ALL
          SELECT @Tip,   'USAA', 'USAA',             @Tip+'10', '',     '',    1,       0,    -1
       UNION ALL
          SELECT @Tip,   'USB',  'U.S.Bank',         @Tip+'11', '',     '',    1,       0,    -1
       UNION ALL
          SELECT @Tip,   'VISA', 'Visa',             @Tip+'12', '',     '',    1,       0,    -1
       UNION ALL
          SELECT @Tip,   'WFAR', 'Wells Fargo',      @Tip+'13', '',     '',    1,       0,    -1
        end;


-- Fiskalizimi WTN (Magazina dokumenti shoqerues)

          IF NOT EXISTS(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='WTNTYPE')      -- Fiskalizimi WTN Type
             BEGIN
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD, KODNUM, KODTD, VISIBLE, TROW, TAGNR)

               SELECT 'WTNTYPE', 'WTNTYPE',     'Tipe dokumenti shoqerues',       'WTNTYPE',    '0',		'',   1,		0,-1
            UNION ALL   
               SELECT 'WTNTYPE', '',            '',                               'WTNTYPE01',  '1',		'',   1,		0,-1
            UNION ALL   
               SELECT 'WTNTYPE', 'WTN',         'Dok.shoq. pa ndryshim pronesi',  'WTNTYPE02',  '1',		'',   1,		0,-1
            UNION ALL   
               SELECT 'WTNTYPE', 'SALE',        'Dok transport shitje karburant', 'WTNTYPE03',  '2',		'',   1,		0,-1

             END;

          IF NOT EXISTS(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='WTNPROC')      -- Fiskalizimi WTN Proces
             BEGIN
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD, KODNUM, KODTD, VISIBLE, TROW, TAGNR)

               SELECT 'WTNPROC', 'WTNPROC',     'Procese dokumenti shoqerues',    'WTNPROC',    '0',		'',   0,		0,-1
            UNION ALL   
               SELECT 'WTNPROC', '',            '',                               'WTNPROC01',  '1',		'',   1,		0,-1
            UNION ALL   
               SELECT 'WTNPROC', 'SALE',        'Trans. Shitje karburant',        'WTNPROC02',  '2',		'',   1,		0,-1
            UNION ALL   
               SELECT 'WTNPROC', 'EXAMINATION', 'Trans. Examinim karburant',      'WTNPROC03',  '3',		'',   1,		0,-1
            UNION ALL   
               SELECT 'WTNPROC', 'TRANSFER',    'Transferim',                     'WTNPROC04',  '4',		'',   1,		0,-1
            UNION ALL   
               SELECT 'WTNPROC', 'DOOR',        'Shitje dere me dere',            'WTNPROC05',  '5',		'',   1,		0,-1

             END;

          IF NOT EXISTS(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='VEHOWNER')      -- Fiskalizimi WTN VehOwner Pronesi makine
             BEGIN
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD, KODNUM, KODTD, VISIBLE, TROW, TAGNR)

               SELECT 'VEHOWNER', 'VEHOWNER',   'Pronesi makine e drejtuesit',    'VEHOWNER',    '0',		'',   0,		0,-1
            UNION ALL   
               SELECT 'VEHOWNER', '',           '',                               'VEHOWNER01',  '1',		'',   1,		0,-1
            UNION ALL   
               SELECT 'VEHOWNER', 'OWNER',      'Leshuesi pronar automjetit',     'VEHOWNER02',  '2',		'',   1,		0,-1
            UNION ALL   
               SELECT 'VEHOWNER', 'THIRDPARTY', 'Pale trete pronar automjeti',    'VEHOWNER03',  '3',		'',   1,		0,-1

             END;

          IF NOT EXISTS(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='WTNOBJECT')      -- Fiskalizimi WTN Qellimi magazines
             BEGIN
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD, KODNUM, KODTD, VISIBLE, TROW, TAGNR)

               SELECT 'WTNOBJECT', 'WTNOBJECT', 'Qellim magazine',                'WTNOBJECT',    '0',		'',   0,		0,-1
            UNION ALL   
               SELECT 'WTNOBJECT', '',          '',                               'WTNOBJECT01',  '1',		'',   1,		0,-1
            UNION ALL   
               SELECT 'WTNOBJECT', 'WAREHOUSE', 'Magazine',                       'WTNOBJECT02',  '2',		'',   1,		0,-1
            UNION ALL   
               SELECT 'WTNOBJECT', 'EXHIBITION','Ekspozite',                      'WTNOBJECT03',  '3',		'',   1,		0,-1
            UNION ALL   
               SELECT 'WTNOBJECT', 'STORE',     'Dyqan',                          'WTNOBJECT04',  '4',		'',   1,		0,-1
            UNION ALL   
               SELECT 'WTNOBJECT', 'SALE',      'Pike shitje',                    'WTNOBJECT05',  '5',		'',   1,		0,-1
            UNION ALL   
               SELECT 'WTNOBJECT', 'ANOTHER',   'Magazine e personi tjeter',      'WTNOBJECT06',  '6',		'',   1,		0,-1
            UNION ALL   
               SELECT 'WTNOBJECT', 'CUSTOMS',   'Magazine doganore',              'WTNOBJECT07',  '7',		'',   1,		0,-1
            UNION ALL   
               SELECT 'WTNOBJECT', 'OTHER',     'Tjeter',                         'WTNOBJECT08',  '8',		'',   1,		0,-1

             END;

          IF NOT EXISTS(SELECT NRRENDOR FROM CONFIG..TIPDOK WHERE TIPDOK='IDTYPE')      -- Fiskalizimi ID Type
             BEGIN
               INSERT  INTO CONFIG..TIPDOK
                      (TIPDOK, KOD,PERSHKRIM, NRORD, KODNUM, KODTD, VISIBLE, TROW, TAGNR)

               SELECT 'IDTYPE',    'IDTYPE',    'Identifikimi transportues',      'IDTYPE',       '0',		'',   0,		0,-1
            UNION ALL   
               SELECT 'IDTYPE',    '',          '',                               'IDTYPE01',     '1',		'',   1,		0,-1
            UNION ALL   
               SELECT 'IDTYPE',    'NUIS',      'Nipt (numer)',                   'IDTYPE02',     '2',		'',   1,		0,-1
            UNION ALL   
               SELECT 'IDTYPE',    'ID',        'Karte Identiteti',               'IDTYPE03',     '3',		'',   1,		0,-1
             END;



   if dbo.Isd_FieldTableExists('SM','PGFORM')=0
      begin
        ALTER TABLE SM ADD PGFORM Varchar(10) NULL
        Print 'Shtim fusha PGFORM ne SM: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('SM','PGLIKUJ')=0
      begin
        ALTER TABLE SM ADD PGLIKUJ Varchar(10) NULL
        Print 'Shtim fusha PGLIKUJ ne SM: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('SM','PGSHENIM1')=0
      begin
        ALTER TABLE SM ADD PGSHENIM1 Varchar(100) NULL
        Print 'Shtim fusha PGSHENIM1 ne SM: Varchar(100)'
      end;
   if dbo.Isd_FieldTableExists('SM','PGSHENIM2')=0
      begin
        ALTER TABLE SM ADD PGSHENIM2 Varchar(100) NULL
        Print 'Shtim fusha PGSHENIM2 ne SM: Varchar(100)'
      end;

   if dbo.Isd_FieldTableExists('SM','EXTIMPID')=0
      begin
        ALTER TABLE SM ADD EXTIMPID Varchar(50) NULL 
        Print 'Shtim fusha EXTIMPID ne SM: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('SM','EXTIMPKOMENT')=0
      begin
        ALTER TABLE SM ADD EXTIMPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTIMPKOMENT ne SM: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('SM','EXTEXP')=0
      begin
        ALTER TABLE SM ADD EXTEXP bit null 
        Print 'Shtim fusha EXTEXP ne SM: bit'
      end;
   if dbo.Isd_FieldTableExists('SM','EXTEXPKOMENT')=0
      begin
        ALTER TABLE SM ADD EXTEXPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTEXPKOMENT ne SM: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('SM','DATECREATE')=0
      begin
        ALTER TABLE SM ADD DATECREATE DATETIME NULL CONSTRAINT [DF_SM_DATECREATE]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne SM: DateTime'
      end;
   if dbo.Isd_FieldTableExists('SM','DATEEDIT')=0
      begin
        ALTER TABLE SM ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_SM_DATEEDIT]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne SM: DateTime'
      end;


   if dbo.Isd_FieldTableExists('SMBAK','PGFORM')=0
      begin
        ALTER TABLE SMBAK ADD PGFORM Varchar(10) NULL
        Print 'Shtim fusha PGFORM ne SMBAK: Bit'
      end;
   if dbo.Isd_FieldTableExists('SMBAK','PGLIKUJ')=0
      begin
        ALTER TABLE SMBAK ADD PGLIKUJ Varchar(10) NULL
        Print 'Shtim fusha PGLIKUJ ne SMBAK: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('SMBAK','PGSHENIM1')=0
      begin
        ALTER TABLE SMBAK ADD PGSHENIM1 Varchar(100) NULL
        Print 'Shtim fusha PGSHENIM1 ne SMBAK: Varchar(100)'
      end;
   if dbo.Isd_FieldTableExists('SMBAK','PGSHENIM2')=0
      begin
        ALTER TABLE SMBAK ADD PGSHENIM2 Varchar(100) NULL
        Print 'Shtim fusha PGSHENIM2 ne SMBAK: Varchar(100)'
      end;
   if dbo.Isd_FieldTableExists('SMBAK','EXTIMPID')=0
      begin
        ALTER TABLE SMBAK ADD EXTIMPID Varchar(50) NULL 
        Print 'Shtim fusha EXTIMPID ne SMBAK: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('SMBAK','EXTIMPKOMENT')=0
      begin
        ALTER TABLE SMBAK ADD EXTIMPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTIMPKOMENT ne SMBAK: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('SMBAK','EXTEXP')=0
      begin
        ALTER TABLE SMBAK ADD EXTEXP bit null 
        Print 'Shtim fusha EXTEXP ne SMBAK: bit'
      end;
   if dbo.Isd_FieldTableExists('SMBAK','EXTEXPKOMENT')=0
      begin
        ALTER TABLE SMBAK ADD EXTEXPKOMENT Varchar(30) NULL 
        Print 'Shtim fusha EXTEXPKOMENT ne SMBAK: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('SMBAK','DATECREATE')=0
      begin
        ALTER TABLE SMBAK ADD DATECREATE DATETIME NULL CONSTRAINT [DF_SMBAK_DATECREATE]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne SMBAK: DateTime'
      end;
   if dbo.Isd_FieldTableExists('SMBAK','DATEEDIT')=0
      begin
        ALTER TABLE SMBAK ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_SMBAK_DATEEDIT]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne SMBAK: DateTime'
      end;


-- FABuxhet
   if dbo.Isd_FieldTableExists('FABUXHET','KLASIFIKIM2')=0
      begin
        ALTER TABLE FABUXHET ADD KLASIFIKIM2 Varchar(30) NULL
        Print 'Shtim fusha KLASIFIKIM2 ne FABUXHET: Varchar(30)'
      end;


--      Select @Tip = Data_type
--        From CONFIG.information_schema.columns
--       Where Table_Name = 'FK'  And Column_Name='NUMDOK'; 
--          if (IsNull(@Tip,'')<>'') And (@Tip<>'Bigint')
--             begin
--               ALTER TABLE FK ALTER COLUMN NUMDOK BigInt NULL
--             end;

--      Select @Tip = Data_type
--        From CONFIG.information_schema.columns
--       Where Table_Name = 'FK'  And Column_Name='NRDOK'; 
--          if (IsNull(@Tip,'')<>'') And (@Tip<>'Bigint')
--             begin
--               ALTER TABLE FK ALTER COLUMN NRDOK BigInt NULL
--             end;
--
--      Select @Tip = Data_type
--        From CONFIG.information_schema.columns
--       Where Table_Name = 'FK'  And Column_Name='NRDFK'; 
--          if (IsNull(@Tip,'')<>'') And (@Tip<>'Bigint')
--             begin
--               ALTER TABLE FK ALTER COLUMN NRDFK BigInt NULL
--             end;


--

--  
   if dbo.Isd_FieldTableExists('FJSCR','CMSHZB0MV')=0
      begin
        Set @TablesList   = 'FJSCR,FFSCR,FJTSCR,OFKSCR,ORKSCR,ORFSCR,SMSCR,SMBAKSCR';
        Set @sSql1 = '  
                      ALTER TABLE FJSCR ADD CMSHZB0MV Float NULL;
                      Print ''Shtim fusha CMSHZB0MV ne FJSCR: Float'';';
        Set @sSql2 = '  
                      UPDATE B
                         SET CMSHZB0MV = CASE WHEN (ISNULL(KMON,'''')='''') OR 
                                                   (NOT (TIPKLL=''K'' OR TIPKLL=''R'')) OR 
                                                   (ISNULL(A.KURS1,0)=0) OR 
                                                   (ISNULL(B.CMIMBS,0)<=0)
                                              THEN CMSHZB0
                                              WHEN (ROUND(B.CMSHZB0/B.CMIMBS,2)>100) -- CMSHZB0 e pa konvertuar ne monedhe
                                              THEN CMSHZB0
                                              ELSE ROUND((A.KURS2*B.CMSHZB0)/A.KURS1,2) END
                        FROM FJ A INNER JOIN FJSCR B ON A.NRRENDOR=B.NRD;';
        Set @i = 1;
        Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;
        while @i<=@k
          begin 
            Set   @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
            Set   @sSql  = Replace(@sSql1,'FJSCR',@TableName);
            Set   @sSql  = Replace(@sSql, 'FJ',Replace(@TableName,'SCR',''));
            Exec (@sSql);
            Set   @sSql  = Replace(@sSql2,'FJSCR',@TableName);
            Set   @sSql  = Replace(@sSql, 'FJ',Replace(@TableName,'SCR',''));
            Exec (@sSql);
            Set   @i = @i + 1
          end; 
      end;



   Set @TablesList = 'FJSCR,FFSCR,FJTSCR,OFKSCR,ORKSCR,ORFSCR,SMSCR,SMBAKSCR';
   Set @sSql1 = '  
                      ALTER TABLE FJSCR ADD CMIMBSTVSH Float NULL;
                      Print ''Shtim fusha CMIMBSTVSH ne FJSCR: Float'';';
   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;
   while @i<=@k
     begin 
       Set  @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
       if   dbo.Isd_FieldTableExists(@TableName,'CMIMBSTVSH')=0
            begin
              Set   @sSql  = Replace(@sSql1,'FJSCR',@TableName);
           -- Set   @sSql  = Replace(@sSql, 'FJ',Replace(@TableName,'SCR',''));
              Exec (@sSql);
              Set   @sSql2 = '  
                      UPDATE A
                         SET CMIMBSTVSH = ROUND(A.CMIMBS + 
                                                CASE WHEN ISNULL(A.PERQTVSH,0)>0 
                                                     THEN (A.CMIMBS * A.PERQTVSH) / 100
                                                     ELSE 0
                                                END, 3) 
                        FROM FJSCR A ;';
              Set   @sSql  = Replace(@sSql2,'FJSCR',@TableName);
              Exec (@sSql);
            end;
            Set     @i = @i + 1
     end;
 


   Set @TablesList = 'FJSCR,FFSCR,FJTSCR,OFKSCR,ORKSCR,ORFSCR,SMSCR,SMBAKSCR';
   Set @sSql1 = '  
                      ALTER TABLE FJSCR ADD KONVERTART Float NULL;
                      Print ''Shtim fusha KONVERTART ne FJSCR: Float'';';
   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;
   while @i<=@k
     begin 
       Set  @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
       if   dbo.Isd_FieldTableExists(@TableName,'KONVERTART')=0
            begin
              Set   @sSql  = Replace(@sSql1,'FJSCR',@TableName);
              Exec (@sSql);
            end;
            Set     @i = @i + 1
     end;



   Set @TablesList = 'FJSCR,FFSCR,FJTSCR,OFKSCR,ORKSCR,ORFSCR,SMSCR,SMBAKSCR';
   Set @sSql1 = '  
                      ALTER TABLE FJSCR ADD KODAGJENT Varchar(60) NULL;
                      Print ''Shtim fusha KODAGJENT ne FJSCR: Varchar(60)'';';
   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;
   while @i<=@k
     begin 
       Set  @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
       if   dbo.Isd_FieldTableExists(@TableName,'KODAGJENT')=0
            begin
              Set   @sSql  = Replace(@sSql1,'FJSCR',@TableName);
              Exec (@sSql);
            end;
            Set     @i = @i + 1
     end;
     
 /*Set @TablesList = 'FJSCR,FFSCR,FJTSCR,OFKSCR,ORKSCR,ORFSCR,SMSCR,SMBAKSCR';
   Set @sSql1 = '  
                      ALTER TABLE FJSCR ADD KODOPER Varchar(10) NULL;
                      Print ''Shtim fusha KODOPER ne FJSCR: Varchar(10)'';';
   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;
   while @i<=@k
     begin 
       Set  @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
       if   dbo.Isd_FieldTableExists(@TableName,'KODOPER')=0
            begin
              Set   @sSql  = Replace(@sSql1,'FJSCR',@TableName);
              Exec (@sSql);
            end;
            Set     @i = @i + 1
     end;*/


   if dbo.Isd_FieldTableExists('FJTSCR','CMIMKLASEREF')=0 OR dbo.Isd_FieldTableExists('FJTSCR','VLKLASEREF')=0
      begin
        Set @TablesList   = 'FJSCR,FFSCR,FJTSCR,OFKSCR,ORKSCR,ORFSCR,SMSCR,SMBAKSCR';
        Set @sSql1 = '  
                      ALTER TABLE FJTSCR ADD CMIMKLASEREF Float NULL;
                      Print ''Shtim fusha CMIMKLASEREF ne FJTSCR: Float'';
                      ALTER TABLE FJTSCR ADD VLKLASEREF Float NULL;
                      Print ''Shtim fusha VLKLASEREF ne FJTSCR: Float'';';

        Set @sSql2 = '  
                      UPDATE B SET CMIMKLASEREF = B.CMSHZB0               FROM FJT A INNER JOIN FJTSCR B ON A.NRRENDOR=B.NRD;
                      UPDATE B SET VLKLASEREF = ROUND(B.CMSHZB0*B.SASI,2) FROM FJT A INNER JOIN FJTSCR B ON A.NRRENDOR=B.NRD;';
        Set @i = 1;
        Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;
        while @i<=@k
          begin 
            Set   @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
            Set   @sSql  = Replace(@sSql1,'FJTSCR',@TableName);
            Set   @sSql  = Replace(@sSql, 'FJT',Replace(@TableName,'SCR',''));
            Exec (@sSql);
            Set   @sSql  = Replace(@sSql2,'FJTSCR',@TableName);
            Set   @sSql  = Replace(@sSql, 'FJT',Replace(@TableName,'SCR',''));
            Exec (@sSql);
            Set   @i = @i + 1
          end; 
      end;



   SET @sSql1 ='

        SET ANSI_NULLS ON
        SET QUOTED_IDENTIFIER ON
        SET ANSI_PADDING ON
        CREATE TABLE [dbo].[ARTIKUJNRSERIAL](
	        [NRRENDOR] [int] IDENTITY(1,1) NOT NULL,
	        [NRD] [int] NULL,
	        [KOD] [varchar](30) NULL,
	        [NRSERIAL] [varchar](30) NULL,
	        [PERSHKRIM] [varchar](100) NULL,
	        [KLASIFIKIM1] [varchar](30) NULL,
	        [KLASIFIKIM2] [varchar](30) NULL,
	        [ACTIV] [bit] NULL,
	        [ORDERSCR] [int] NULL,
            [STATROW] [varchar](5) NULL,
	        [USI] [varchar](10) NULL,
	        [USM] [varchar](10) NULL,
	        [TROW] [bit] NULL,
	        [TAGNR] [int] NULL
        ) ON [PRIMARY]
        SET ANSI_PADDING OFF

        ALTER TABLE [dbo].[ARTIKUJNRSERIAL]  WITH NOCHECK ADD  CONSTRAINT [FK_ARTIKUJNRSERIAL_ARTIKUJ] FOREIGN KEY([NRD])
        REFERENCES [dbo].[ARTIKUJ] ([NRRENDOR])
        ON UPDATE CASCADE
        ON DELETE CASCADE
        ALTER TABLE [dbo].[ARTIKUJNRSERIAL] CHECK CONSTRAINT [FK_ARTIKUJNRSERIAL_ARTIKUJ]

        Print ''Krijim tabele ''+DB_NAME()+''..ARTIKUJNRSERIAL''; ';

   if Object_Id('ARTIKUJNRSERIAL') is null
      EXEC (@sSql1);


   if Object_Id('CONFIG..ARTIKUJNRSERIAL') is null
      EXEC ('USE CONFIG; '+@sSql1);


if Object_Id('DRH..ACTLIST') is null

   begin
    
     Exec (' 

      USE DRH 

      SET ANSI_NULLS ON
      SET QUOTED_IDENTIFIER ON
      SET ANSI_PADDING ON
      CREATE TABLE [dbo].[ACTLIST](
	     [NRRENDOR] [int] IDENTITY(1,1) NOT NULL,
	     [OWNNAME] [varchar](30) NULL,
	     [FRMNAME] [varchar](30) NULL,
	     [ALSNAME] [varchar](30) NULL,
	     [ACTNAME] [varchar](30) NULL,
	     [SHCNAME] [varchar](30) NULL,
	     [USI] [varchar](10) NULL,
	     [USM] [varchar](10) NULL,
	     [TROW] [bit] NULL,
	     [TAGNR] [int] NULL
      ) ON [PRIMARY]

      SET ANSI_PADDING OFF  ' );
    Print 'Shtim tabele DRH..ACTLIST'

   end;




-- FJSHOQERUES
   if dbo.Isd_FieldTableExists('FJSHOQERUES','NGARKIM')=0
      begin
        ALTER TABLE FJSHOQERUES ADD NGARKIM Varchar(50) NULL
        Print 'Shtim fusha NGARKIM ne FJSHOQERUES: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('FJSHOQERUES','SHKARKIM')=0
      begin
        ALTER TABLE FJSHOQERUES ADD SHKARKIM Varchar(50) NULL
        Print 'Shtim fusha SHKARKIM ne FJSHOQERUES: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('FJSHOQERUES','AGJENSIDG1')=0
      begin
        ALTER TABLE FJSHOQERUES ADD AGJENSIDG1 Varchar(50) NULL
        Print 'Shtim fusha AGJENSIDG1 ne FJSHOQERUES: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('FJSHOQERUES','AGJENSIDG2')=0
      begin
        ALTER TABLE FJSHOQERUES ADD AGJENSIDG2 Varchar(50) NULL
        Print 'Shtim fusha AGJENSIDG2 ne FJSHOQERUES: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('FJSHOQERUES','SASINGARKIM')=0
      begin
        ALTER TABLE FJSHOQERUES ADD SASINGARKIM Varchar(20) NULL
        Print 'Shtim fusha SASINGARKIM ne FJSHOQERUES: Varchar(20)'
      end;
   if dbo.Isd_FieldTableExists('FJSHOQERUES','NJESINGARKIM')=0
      begin
        ALTER TABLE FJSHOQERUES ADD NJESINGARKIM Varchar(10) NULL
        Print 'Shtim fusha NJESINGARKIM ne FJSHOQERUES: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('FJSHOQERUES','KOMENT')=0
      begin
        ALTER TABLE FJSHOQERUES ADD KOMENT Varchar(50) NULL
        Print 'Shtim fusha KOMENT ne FJSHOQERUES: Varchar(50)'
      end;

-- FJTSHOQERUES
   if dbo.Isd_FieldTableExists('FJTSHOQERUES','NGARKIM')=0
      begin
        ALTER TABLE FJTSHOQERUES ADD NGARKIM Varchar(50) NULL
        Print 'Shtim fusha NGARKIM ne FJTSHOQERUES: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('FJTSHOQERUES','SHKARKIM')=0
      begin
        ALTER TABLE FJTSHOQERUES ADD SHKARKIM Varchar(50) NULL
        Print 'Shtim fusha SHKARKIM ne FJTSHOQERUES: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('FJTSHOQERUES','AGJENSIDG1')=0
      begin
        ALTER TABLE FJTSHOQERUES ADD AGJENSIDG1 Varchar(50) NULL
        Print 'Shtim fusha AGJENSIDG1 ne FJTSHOQERUES: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('FJTSHOQERUES','AGJENSIDG2')=0
      begin
        ALTER TABLE FJTSHOQERUES ADD AGJENSIDG2 Varchar(50) NULL
        Print 'Shtim fusha AGJENSIDG2 ne FJTSHOQERUES: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('FJTSHOQERUES','SASINGARKIM')=0
      begin
        ALTER TABLE FJTSHOQERUES ADD SASINGARKIM Varchar(20) NULL
        Print 'Shtim fusha SASINGARKIM ne FJTSHOQERUES: Varchar(20)'
      end;
   if dbo.Isd_FieldTableExists('FJTSHOQERUES','NJESINGARKIM')=0
      begin
        ALTER TABLE FJTSHOQERUES ADD NJESINGARKIM Varchar(10) NULL
        Print 'Shtim fusha NJESINGARKIM ne FJTSHOQERUES: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('FJTSHOQERUES','KOMENT')=0
      begin
        ALTER TABLE FJTSHOQERUES ADD KOMENT Varchar(50) NULL
        Print 'Shtim fusha KOMENT ne FJTSHOQERUES: Varchar(50)'
      end;


-- MGSHOQERUES
   if dbo.Isd_FieldTableExists('MGSHOQERUES','NGARKIM')=0
      begin
        ALTER TABLE MGSHOQERUES ADD NGARKIM Varchar(50) NULL
        Print 'Shtim fusha NGARKIM ne MGSHOQERUES: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('MGSHOQERUES','SHKARKIM')=0
      begin
        ALTER TABLE MGSHOQERUES ADD SHKARKIM Varchar(50) NULL
        Print 'Shtim fusha SHKARKIM ne MGSHOQERUES: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('MGSHOQERUES','AGJENSIDG1')=0
      begin
        ALTER TABLE MGSHOQERUES ADD AGJENSIDG1 Varchar(50) NULL
        Print 'Shtim fusha AGJENSIDG1 ne MGSHOQERUES: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('MGSHOQERUES','AGJENSIDG2')=0
      begin
        ALTER TABLE MGSHOQERUES ADD AGJENSIDG2 Varchar(50) NULL
        Print 'Shtim fusha AGJENSIDG2 ne MGSHOQERUES: Varchar(50)'
      end;
   if dbo.Isd_FieldTableExists('MGSHOQERUES','SASINGARKIM')=0
      begin
        ALTER TABLE MGSHOQERUES ADD SASINGARKIM Varchar(20) NULL
        Print 'Shtim fusha SASINGARKIM ne MGSHOQERUES: Varchar(20)'
      end;
   if dbo.Isd_FieldTableExists('MGSHOQERUES','NJESINGARKIM')=0
      begin
        ALTER TABLE MGSHOQERUES ADD NJESINGARKIM Varchar(10) NULL
        Print 'Shtim fusha NJESINGARKIM ne MGSHOQERUES: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('MGSHOQERUES','KOMENT')=0
      begin
        ALTER TABLE MGSHOQERUES ADD KOMENT Varchar(50) NULL
        Print 'Shtim fusha KOMENT ne MGSHOQERUES: Varchar(50)'
      end;

-- TRANSPORT
   if dbo.Isd_FieldTableExists('TRANSPORT','SASINGARKIM')=0
      begin
        ALTER TABLE TRANSPORT ADD SASINGARKIM Varchar(50) NULL
        Print 'Shtim fusha SASINGARKIM ne TRANSPORT: Varchar(20)'
      end;
   if dbo.Isd_FieldTableExists('TRANSPORT','NJESINGARKIM')=0
      begin
        ALTER TABLE TRANSPORT ADD NJESINGARKIM Varchar(10) NULL
        Print 'Shtim fusha NJESINGARKIM ne TRANSPORT: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('TRANSPORT','LISTMAGAZINA')=0
      begin
        ALTER TABLE TRANSPORT ADD LISTMAGAZINA Varchar(1000) NULL
        Print 'Shtim fusha LISTMAGAZINA ne TRANSPORT: Varchar(1000)'
      end;




-- Fusha Shtese tek FJT sipas FJ

   if dbo.Isd_FieldTableExists('FJT','ACTIVFJKOMENT')=0     -- 1.
      begin
        ALTER TABLE FJT ADD ACTIVFJKOMENT bit NULL
        Print 'Shtim fusha ACTIVFJKOMENT ne FJT: bit'
      end;
   if dbo.Isd_FieldTableExists('FJT','GRUP')=0              -- 2.
      begin
        ALTER TABLE FJT ADD GRUP Varchar(10) NULL
        Print 'Shtim fusha GRUP ne FJT: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('FJT','KODARK')=0            -- 3.
      begin
        ALTER TABLE FJT ADD KODARK Varchar(30) NULL
        Print 'Shtim fusha KODARK ne FJT: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FJT','KODKART')=0
      begin
        ALTER TABLE FJT ADD KODKART Varchar(30) NULL
        Print 'Shtim fusha KODKART ne FJT: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FJT','LLOJDOK')=0
      begin
        ALTER TABLE FJT ADD LLOJDOK Varchar(10) NULL
        Print 'Shtim fusha LLOJDOK ne FJT: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('FJT','TIPFT')=0
      begin
        ALTER TABLE FJT ADD TIPFT Varchar(10) NULL
        Print 'Shtim fusha TIPFT ne FJT: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('FJT','PAGESEARK')=0         -- 7.
      begin
        ALTER TABLE FJT ADD PAGESEARK Float NULL
        Print 'Shtim fusha PAGESEARK ne FJT: Float'
      end;
   if dbo.Isd_FieldTableExists('FJT','DATEARK')=0
      begin
        ALTER TABLE FJT ADD DATEARK Datetime NULL
        Print 'Shtim fusha DATEARK ne FJT: Datetime'
      end;
   if dbo.Isd_FieldTableExists('FJT','VLKASE')=0             -- 8.
      begin
        ALTER TABLE FJT ADD VLKASE Float NULL
        Print 'Shtim fusha VLKASE ne FJT: Float'
      end;
   if dbo.Isd_FieldTableExists('FJT','ISPERMBLEDHES')=0     -- 9.
      begin
        ALTER TABLE FJT ADD ISPERMBLEDHES bit NULL
        Print 'Shtim fusha ISPERMBLEDHES ne FJT: bit'
      end;
   if dbo.Isd_FieldTableExists('FJT','PRINTKOMENT')=0       -- 10.
      begin
        ALTER TABLE FJT ADD PRINTKOMENT bit NULL
        Print 'Shtim fusha PRINTKOMENT ne FJT: bit'
      end;
   if dbo.Isd_FieldTableExists('FJT','NRLINKAPL1')=0        -- 11.
      begin
        ALTER TABLE FJT ADD NRLINKAPL1 Varchar(30) NULL
        Print 'Shtim fusha NRLINKAPL1 ne FJT: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FJT','IMPORTTAG')=0         -- 12.
      begin
        ALTER TABLE FJT ADD IMPORTTAG Varchar(10) NULL
        Print 'Shtim fusha IMPORTTAG ne FJT: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('FJT','NRDITARPRMC')=0       -- 13.
      begin
        ALTER TABLE FJT ADD NRDITARPRMC Int NULL
        Print 'Shtim fusha NRDITARPRMC ne FJT: Int'
      end;
   if dbo.Isd_FieldTableExists('FJT','NRRENDORAR')=0        -- 14.
      begin
        ALTER TABLE FJT ADD NRRENDORAR Int NULL
        Print 'Shtim fusha NRRENDORAR ne FJT: Int'
      end;
   if dbo.Isd_FieldTableExists('FJT','NRRENDORAQ')=0        -- 15.
      begin
        ALTER TABLE FJT ADD NRRENDORAQ Int NULL
        Print 'Shtim fusha NRRENDORAQ ne FJT: Int'
      end;
   if dbo.Isd_FieldTableExists('FJT','NRRENDORAMB')=0       -- 16.
      begin
        ALTER TABLE FJT ADD NRRENDORAMB Int NULL
        Print 'Shtim fusha NRRENDORAMB ne FJT: Int'
      end;
   if dbo.Isd_FieldTableExists('FJT','NRRENDORORGFJ')=0     -- 17.
      begin
        ALTER TABLE FJT ADD NRRENDORORGFJ Int NULL
        Print 'Shtim fusha NRRENDORORGFJ ne FJT: Int'
      end;
   if dbo.Isd_FieldTableExists('FJT','DATECREATE')=0            -- 18.
      begin
        ALTER TABLE FJT ADD DATECREATE DATETIME NULL CONSTRAINT [DF_FJT_DATECREATE]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne FJT: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FJT','DATEEDIT')=0            -- 19.
      begin
        ALTER TABLE FJT ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_FJT_DATEEDIT]  DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne FJT: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FJT','TAGLM')=0             -- 20.
      begin
        ALTER TABLE FJT ADD TAGLM bit NULL 
        Print 'Shtim fusha TAGLM ne FJT: bit'
      end;
   if dbo.Isd_FieldTableExists('FJT','TAGRND')=0            -- 21.
      begin
        ALTER TABLE FJT ADD TAGRND Varchar(30) NULL 
        Print 'Shtim fusha TAGRND ne FJT: Varchar(30)'
      end;


-- Fusha Shtese tek FJTSCR sipas FJSCR

   if dbo.Isd_FieldTableExists('FJTSCR','FBARS')=0          -- 1.
      begin
        ALTER TABLE FJTSCR ADD FBARS float NULL
        Print 'Shtim fusha FBARS ne FJTSCR: float'
      end;
   if dbo.Isd_FieldTableExists('FJTSCR','FCOLOR')=0       -- 2.
      begin
        ALTER TABLE FJTSCR ADD FCOLOR Varchar(25) NULL
        Print 'Shtim fusha [COLOR ne FJTSCR: Varchar(25)'
      end;
   if dbo.Isd_FieldTableExists('FJTSCR','FLENGTH')=0        -- 3.
      begin
        ALTER TABLE FJTSCR ADD FLENGTH Varchar(25) NULL
        Print 'Shtim fusha FLENGTH ne FJTSCR: Varchar(25)'
      end;
   if dbo.Isd_FieldTableExists('FJTSCR','FPROFIL')=0        -- 4.
      begin
        ALTER TABLE FJTSCR ADD FPROFIL Varchar(25) NULL
        Print 'Shtim fusha FPROFIL ne FJTSCR: Varchar(25)'
      end;
   if dbo.Isd_FieldTableExists('FJTSCR','KLSART')=0         -- 5.
      begin
        ALTER TABLE FJTSCR ADD KLSART Varchar(60) NULL
        Print 'Shtim fusha KLSART ne FJTSCR: Varchar(60)'
      end;
   if dbo.Isd_FieldTableExists('FJTSCR','KOEFICIENT')=0     -- 6.
      begin
        ALTER TABLE FJTSCR ADD KOEFICIENT float NULL
        Print 'Shtim fusha KOEFICIENT ne FJTSCR: float'
      end;
-- if dbo.Isd_FieldTableExists('FJTSCR','KONVERTART')=0     -- 7.
--    begin
--      ALTER TABLE FJTSCR ADD KONVERTART float NULL
--      Print 'Shtim fusha KONVERTART ne FJTSCR: float'
--    end;
   if dbo.Isd_FieldTableExists('FJTSCR','DATEDOKREF')=0     -- 8.
      begin
        ALTER TABLE FJTSCR ADD DATEDOKREF Datetime NULL
        Print 'Shtim fusha DATEDOKREF ne FJTSCR: Datetime'
      end;
   if dbo.Isd_FieldTableExists('FJTSCR','NRDOKREF')=0       -- 9.
      begin
        ALTER TABLE FJTSCR ADD NRDOKREF Varchar(30) NULL
        Print 'Shtim fusha NRDOKREF ne FJTSCR: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('FJTSCR','TIPREF')=0         -- 10.
      begin
        ALTER TABLE FJTSCR ADD TIPREF Varchar(10) NULL
        Print 'Shtim fusha TIPREF ne FJTSCR: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('FJTSCR','TIPKTH')=0         -- 11.
      begin
        ALTER TABLE FJTSCR ADD TIPKTH Varchar(2) NULL
        Print 'Shtim fusha TIPKTH ne FJTSCR: Varchar(2)'
      end;
   if dbo.Isd_FieldTableExists('FJTSCR','GJENDJE')=0         -- 12.
      begin
        ALTER TABLE FJTSCR ADD GJENDJE Float NULL
        Print 'Shtim fusha GJENDJE ne FJTSCR: Float'
      end;
   if dbo.Isd_FieldTableExists('FJTSCR','NRDITAR')=0         -- 13.
      begin
        ALTER TABLE FJTSCR ADD NRDITAR Int NULL
        Print 'Shtim fusha NRDITAR ne FJTSCR: Int'
      end;
   if dbo.Isd_FieldTableExists('FJTSCR','TAGRND')=0          -- 14.
      begin
        ALTER TABLE FJTSCR ADD TAGRND Varchar(30) NULL
        Print 'Shtim fusha TAGRND ne FJTSCR: Varchar(30)'
      end;


-- OBJECTSLINK

   if dbo.Isd_FieldTableExists('OBJECTSLINK','PDFOBJEKT')=0     
      begin
        ALTER TABLE OBJECTSLINK ADD PDFOBJEKT Varchar(MAX) NULL
        Print 'Shtim fusha PDFOBJEKT ne OBJECTSLINK: Varchar(MAX)'
      end;
   if dbo.Isd_FieldTableExists('OBJECTSLINK','PDFOBJEKTPATHLOCATION')=0     
      begin
        ALTER TABLE OBJECTSLINK ADD PDFOBJEKTPATHLOCATION Varchar(300) NULL
        Print 'Shtim fusha PDFOBJEKTPATHLOCATION ne OBJECTSLINK: Varchar(300)'
      end;
   if dbo.Isd_FieldTableExists('OBJECTSLINK','PDFOBJEKTPATHLOADED')=0     
      begin
        ALTER TABLE OBJECTSLINK ADD PDFOBJEKTPATHLOADED Varchar(300) NULL
        Print 'Shtim fusha PDFOBJEKTPATHLOADED ne OBJECTSLINK: Varchar(300)'
      end;
   if dbo.Isd_FieldTableExists('OBJECTSLINK','PDFOBJEKTEXT')=0     
      begin
        ALTER TABLE OBJECTSLINK ADD PDFOBJEKTEXT Varchar(20) NULL
        Print 'Shtim fusha PDFOBJEKTEXT ne OBJECTSLINK: Varchar(20)'
      end;



-- Gjenerimi i DATEEDIT,DATECREATE per referencat ....
--        Set  @TablesList   = 'FH,FD,FJ,FF,FJT,DG,ORK,OFK,ORF,SM,SMBAK,ARKA,BANKA,FK,VS,VSST,FKST,'+
--                             'AGJENTSHITJE,ARKAT,ARTIKUJ,ARTIKUJKLS1,ARTIKUJKLS2,ARTIKUJKLS3,ARTIKUJKLS4,ARTIKUJKLS5,ARTIKUJKLS6,'+
--                             'BANKAT,DEPARTAMENT,FURNITOR,GRUPIMFT,KASE,KATEGORI,KLIENT,LISTE,LLOGARI,MAGAZINA,MONEDHA,NIPT,NJESI,PERSONEL,'+
--                             'PROMOC,RAJON,SHERBIM,SKEMELM,TATIM,TIPNJESI,VENDNDODHJE,ZBRITJE,FJSHOQERUES,FJTSHOQERUES,INSTALATOR,KlasaTatim,'+
--                             'KlientCmim,MgShoqerues,NENDITAR,OBJECTSLINK,OBJEKTINST,SERIALS,TRANSPORT,FABUXHET,FAFO,FAHFC,SISTEMIMMG,LOCALS';
--        Exec dbo.Isd_AlterTables '',@TablesList,'DATECREATE,DATECREATE','DateTime','null','';
--        Exec dbo.Isd_AlterTables '',@TablesList,'DATECREATE','DateTime','null','';
-- Zgjidh konstraints

   if dbo.Isd_FieldTableExists('AGJENTSHITJE','DATECREATE')=0
      begin
        ALTER TABLE AGJENTSHITJE ADD DATECREATE DATETIME NULL CONSTRAINT [DF_AGJSH_DATECREATE] DEFAULT (GETDATE());
        Print 'Shtim fusha DATECREATE ne AGJENTSHITJE: DateTime';
      end;
   if dbo.Isd_FieldTableExists('AGJENTSHITJE','DATEEDIT')=0
      begin
        ALTER TABLE AGJENTSHITJE ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_AGJSH_DATEEDIT] DEFAULT (GETDATE());
        Print 'Shtim fusha DATEEDIT ne AGJENTSHITJE: DateTime';
      end;
   if dbo.Isd_FieldTableExists('ARKAT','DATECREATE')=0
      begin
        ALTER TABLE ARKAT ADD DATECREATE DATETIME NULL CONSTRAINT [DF_ARK_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne ARKAT: DateTime'
      end;
   if dbo.Isd_FieldTableExists('ARKAT','DATEEDIT')=0
      begin
        ALTER TABLE ARKAT ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_ARK_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne ARKAT: DateTime'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','DATECREATE')=0
      begin
        ALTER TABLE ARTIKUJ ADD DATECREATE DATETIME NULL CONSTRAINT [DF_ART_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne ARTIKUJ: DateTime'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJ','DATEEDIT')=0
      begin
        ALTER TABLE ARTIKUJ ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_ART_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne ARTIKUJ: DateTime'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJKLS1','DATECREATE')=0
      begin
        ALTER TABLE ARTIKUJKLS1 ADD DATECREATE DATETIME NULL CONSTRAINT [DF_AKLS1_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne ARTIKUJKLS1: DateTime'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJKLS1','DATEEDIT')=0
      begin
        ALTER TABLE ARTIKUJKLS1 ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_AKLS1_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne ARTIKUJKLS1: DateTime'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJKLS2','DATECREATE')=0
      begin
        ALTER TABLE ARTIKUJKLS2 ADD DATECREATE DATETIME NULL CONSTRAINT [DF_AKLS2_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne ARTIKUJKLS2: DateTime'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJKLS2','DATEEDIT')=0
      begin
        ALTER TABLE ARTIKUJKLS2 ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_AKLS2_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne ARTIKUJKLS2: DateTime'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJKLS2','DATECREATE')=0
      begin
        ALTER TABLE ARTIKUJKLS2 ADD DATECREATE DATETIME NULL CONSTRAINT [DF_AKLS2_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne ARTIKUJKLS2: DateTime'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJKLS2','DATEEDIT')=0
      begin
        ALTER TABLE ARTIKUJKLS2 ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_AKLS2_DATEEIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne ARTIKUJKLS2: DateTime'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJKLS3','DATECREATE')=0
      begin
        ALTER TABLE ARTIKUJKLS3 ADD DATECREATE DATETIME NULL CONSTRAINT [DF_AKLS3_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne ARTIKUJKLS3: DateTime'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJKLS3','DATEEDIT')=0
      begin
        ALTER TABLE ARTIKUJKLS3 ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_AKLS3_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne ARTIKUJKLS3: DateTime'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJKLS4','DATECREATE')=0
      begin
        ALTER TABLE ARTIKUJKLS4 ADD DATECREATE DATETIME NULL CONSTRAINT [DF_AKLS4_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne ARTIKUJKLS4: DateTime'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJKLS4','DATEEDIT')=0
      begin
        ALTER TABLE ARTIKUJKLS4 ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_AKLS4_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne ARTIKUJKLS4: DateTime'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJKLS5','DATECREATE')=0
      begin
        ALTER TABLE ARTIKUJKLS5 ADD DATECREATE DATETIME NULL CONSTRAINT [DF_AKLS5_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne ARTIKUJKLS5: DateTime'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJKLS5','DATEEDIT')=0
      begin
        ALTER TABLE ARTIKUJKLS5 ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_AKLS5_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne ARTIKUJKLS5: DateTime'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJKLS6','DATECREATE')=0
      begin
        ALTER TABLE ARTIKUJKLS6 ADD DATECREATE DATETIME NULL CONSTRAINT [DF_AKLS6_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne ARTIKUJKLS6: DateTime'
      end;
   if dbo.Isd_FieldTableExists('ARTIKUJKLS6','DATEEDIT')=0
      begin
        ALTER TABLE ARTIKUJKLS6 ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_AKLS6_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne ARTIKUJKLS6: DateTime'
      end;
   if dbo.Isd_FieldTableExists('BANKAT','DATECREATE')=0
      begin
        ALTER TABLE BANKAT ADD DATECREATE DATETIME NULL CONSTRAINT [DF_BAN_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne BANKAT: DateTime'
      end;
   if dbo.Isd_FieldTableExists('BANKAT','DATEEDIT')=0
      begin
        ALTER TABLE BANKAT ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_BAN_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEIT ne BANKAT: DateTime'
      end;
   if dbo.Isd_FieldTableExists('DEPARTAMENT','DATECREATE')=0
      begin
        ALTER TABLE DEPARTAMENT ADD DATECREATE DATETIME NULL CONSTRAINT [DF_DEP_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne DEPARTAMENT: DateTime'
      end;
   if dbo.Isd_FieldTableExists('DEPARTAMENT','DATEEDIT')=0
      begin
        ALTER TABLE DEPARTAMENT ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_DEP_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne DEPARTAMENT: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FURNITOR','DATECREATE')=0
      begin
        ALTER TABLE FURNITOR ADD DATECREATE DATETIME NULL CONSTRAINT [DF_FUR_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne FURNITOR: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FURNITOR','DATEEDIT')=0
      begin
        ALTER TABLE FURNITOR ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_FUR_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne FURNITOR: DateTime'
      end;
   if dbo.Isd_FieldTableExists('GRUPIMFT','DATECREATE')=0
      begin
        ALTER TABLE GRUPIMFT ADD DATECREATE DATETIME NULL CONSTRAINT [DF_GRFT_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne GRUPIMFT: DateTime'
      end;
   if dbo.Isd_FieldTableExists('GRUPIMFT','DATEEDIT')=0
      begin
        ALTER TABLE GRUPIMFT ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_GRFT_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne GRUPIMFT: DateTime'
      end;
   if dbo.Isd_FieldTableExists('KASE','DATECREATE')=0
      begin
        ALTER TABLE KASE ADD DATECREATE DATETIME NULL CONSTRAINT [DF_KAS_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne KASE: DateTime'
      end;
   if dbo.Isd_FieldTableExists('KASE','DATEEDIT')=0
      begin
        ALTER TABLE KASE ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_KAS_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne KASE: DateTime'
      end;
   if dbo.Isd_FieldTableExists('KATEGORI','DATECREATE')=0
      begin
        ALTER TABLE KATEGORI ADD DATECREATE DATETIME NULL CONSTRAINT [DF_KTG_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne KATEGORI: DateTime'
      end;
   if dbo.Isd_FieldTableExists('KATEGORI','DATEEDIT')=0
      begin
        ALTER TABLE KATEGORI ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_KTG_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne KATEGORI: DateTime'
      end;
   if dbo.Isd_FieldTableExists('KLIENT','DATECREATE')=0
      begin
        ALTER TABLE KLIENT ADD DATECREATE DATETIME NULL CONSTRAINT [DF_KLI_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne KLIENT: DateTime'
      end;
   if dbo.Isd_FieldTableExists('KLIENT','DATEEDIT')=0
      begin
        ALTER TABLE KLIENT ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_KLI_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne KLIENT: DateTime'
      end;
   if dbo.Isd_FieldTableExists('LISTE','DATECREATE')=0
      begin
        ALTER TABLE LISTE ADD DATECREATE DATETIME NULL CONSTRAINT [DF_LIS_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne LISTE: DateTime'
      end;
   if dbo.Isd_FieldTableExists('LISTE','DATEEDIT')=0
      begin
        ALTER TABLE LISTE ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_LIS_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne LISTE: DateTime'
      end;
   if dbo.Isd_FieldTableExists('LLOGARI','DATECREATE')=0
      begin
        ALTER TABLE LLOGARI ADD DATECREATE DATETIME NULL CONSTRAINT [DF_LLG_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne LLOGARI: DateTime'
      end;
   if dbo.Isd_FieldTableExists('LLOGARI','DATEEDIT')=0
      begin
        ALTER TABLE LLOGARI ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_LLG_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne LLOGARI: DateTime'
      end;
   if dbo.Isd_FieldTableExists('MAGAZINA','DATECREATE')=0
      begin
        ALTER TABLE MAGAZINA ADD DATECREATE DATETIME NULL CONSTRAINT [DF_MAG_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne MAGAZINA: DateTime'
      end;
   if dbo.Isd_FieldTableExists('MAGAZINA','DATEEDIT')=0
      begin
        ALTER TABLE MAGAZINA ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_MAG_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne MAGAZINA: DateTime'
      end;
   if dbo.Isd_FieldTableExists('MONEDHA','DATECREATE')=0
      begin
        ALTER TABLE MONEDHA ADD DATECREATE DATETIME NULL CONSTRAINT [DF_MON_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne MONEDHA: DateTime'
      end;
   if dbo.Isd_FieldTableExists('MONEDHA','DATEEDIT')=0
      begin
        ALTER TABLE MONEDHA ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_MON_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne MONEDHA: DateTime'
      end;
   if dbo.Isd_FieldTableExists('NIPT','DATECREATE')=0
      begin
        ALTER TABLE NIPT ADD DATECREATE DATETIME NULL CONSTRAINT [DF_NPT_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne NIPT: DateTime'
      end;
   if dbo.Isd_FieldTableExists('NIPT','DATEEDIT')=0
      begin
        ALTER TABLE NIPT ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_NPT_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne NIPT: DateTime'
      end;
   if dbo.Isd_FieldTableExists('NJESI','DATECREATE')=0
      begin
        ALTER TABLE NJESI ADD DATECREATE DATETIME NULL CONSTRAINT [DF_NJS_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne NJESI: DateTime'
      end;
   if dbo.Isd_FieldTableExists('NJESI','DATEEDIT')=0
      begin
        ALTER TABLE NJESI ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_NJS_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne NJESI: DateTime'
      end;
   if dbo.Isd_FieldTableExists('PERSONEL','DATECREATE')=0
      begin
        ALTER TABLE PERSONEL ADD DATECREATE DATETIME NULL CONSTRAINT [DF_PRS_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne PERSONEL: DateTime'
      end;
   if dbo.Isd_FieldTableExists('PERSONEL','DATEEDIT')=0
      begin
        ALTER TABLE PERSONEL ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_PRS_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne PERSONEL: DateTime'
      end;
   if dbo.Isd_FieldTableExists('PROMOC','DATECREATE')=0
      begin
        ALTER TABLE PROMOC ADD DATECREATE DATETIME NULL CONSTRAINT [DF_PRC_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne PROMOC: DateTime'
      end;
   if dbo.Isd_FieldTableExists('PROMOC','DATEEDIT')=0
      begin
        ALTER TABLE PROMOC ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_PRC_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne PROMOC: DateTime'
      end;
   if dbo.Isd_FieldTableExists('RAJON','DATECREATE')=0
      begin
        ALTER TABLE RAJON ADD DATECREATE DATETIME NULL CONSTRAINT [DF_RAJ_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne RAJON: DateTime'
      end;
   if dbo.Isd_FieldTableExists('RAJON','DATEEDIT')=0
      begin
        ALTER TABLE RAJON ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_RAJ_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne RAJON: DateTime'
      end;
   if dbo.Isd_FieldTableExists('SHERBIM','DATECREATE')=0
      begin
        ALTER TABLE SHERBIM ADD DATECREATE DATETIME NULL CONSTRAINT [DF_SHR_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne SHERBIM: DateTime'
      end;
   if dbo.Isd_FieldTableExists('SHERBIM','DATEEDIT')=0
      begin
        ALTER TABLE SHERBIM ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_SHR_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne SHERBIM: DateTime'
      end;
   if dbo.Isd_FieldTableExists('SKEMELM','DATECREATE')=0
      begin
        ALTER TABLE SKEMELM ADD DATECREATE DATETIME NULL CONSTRAINT [DF_SLM_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne SKEMELM: DateTime'
      end;
   if dbo.Isd_FieldTableExists('SKEMELM','DATEEDIT')=0
      begin
        ALTER TABLE SKEMELM ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_SLM_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne SKEMELM: DateTime'
      end;
   if dbo.Isd_FieldTableExists('TATIM','DATECREATE')=0
      begin
        ALTER TABLE TATIM ADD DATECREATE DATETIME NULL CONSTRAINT [DF_TTM_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne TATIM: DateTime'
      end;
   if dbo.Isd_FieldTableExists('TATIM','DATEEDIT')=0
      begin
        ALTER TABLE TATIM ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_TTM_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne TATIM: DateTime)'
      end;
   if dbo.Isd_FieldTableExists('TIPNJESI','DATECREATE')=0
      begin
        ALTER TABLE TIPNJESI ADD DATECREATE DATETIME NULL CONSTRAINT [DF_TNJ_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne TIPNJESI: DateTime'
      end;
   if dbo.Isd_FieldTableExists('TIPNJESI','DATEEDIT')=0
      begin
        ALTER TABLE TIPNJESI ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_TNJ_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne TIPNJESI: DateTime'
      end;
   if dbo.Isd_FieldTableExists('VENDNDODHJE','DATECREATE')=0
      begin
        ALTER TABLE VENDNDODHJE ADD DATECREATE DATETIME NULL CONSTRAINT [DF_VND_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne VENDNDODHJE: DateTime'
      end;
   if dbo.Isd_FieldTableExists('VENDNDODHJE','DATEEDIT')=0
      begin
        ALTER TABLE VENDNDODHJE ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_VND_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne VENDNDODHJE: DateTime'
      end;
   if dbo.Isd_FieldTableExists('ZBRITJE','DATECREATE')=0
      begin
        ALTER TABLE ZBRITJE ADD DATECREATE DATETIME NULL CONSTRAINT [DF_ZBD_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne ZBRITJE: DateTime'
      end;
   if dbo.Isd_FieldTableExists('ZBRITJE','DATEEDIT')=0
      begin
        ALTER TABLE ZBRITJE ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_ZBD_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne ZBRITJE: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FJSHOQERUES','DATECREATE')=0
      begin
        ALTER TABLE FJSHOQERUES ADD DATECREATE DATETIME NULL CONSTRAINT [DF_FJSH_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne FJSHOQERUES: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FJSHOQERUES','DATEEDIT')=0
      begin
        ALTER TABLE FJSHOQERUES ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_FJSH_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne FJSHOQERUES: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FJTSHOQERUES','DATECREATE')=0
      begin
        ALTER TABLE FJTSHOQERUES ADD DATECREATE DATETIME NULL CONSTRAINT [DF_FJTSH_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne FJTSHOQERUES: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FJTSHOQERUES','DATEEDIT')=0
      begin
        ALTER TABLE FJTSHOQERUES ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_FJTSH_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne FJTSHOQERUES: DateTime'
      end;
   if dbo.Isd_FieldTableExists('INSTALATOR','DATECREATE')=0
      begin
        ALTER TABLE INSTALATOR ADD DATECREATE DATETIME NULL CONSTRAINT [DF_INS_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne INSTALATOR: DateTime'
      end;
   if dbo.Isd_FieldTableExists('INSTALATOR','DATEEDIT')=0
      begin
        ALTER TABLE INSTALATOR ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_INS_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne INSTALATOR: DateTime'
      end;
   if dbo.Isd_FieldTableExists('KlasaTatim','DATECREATE')=0
      begin
        ALTER TABLE KlasaTatim ADD DATECREATE DATETIME NULL CONSTRAINT [DF_KTA_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne KlasaTatim: DateTime'
      end;
   if dbo.Isd_FieldTableExists('KlasaTatim','DATEEDIT')=0
      begin
        ALTER TABLE KlasaTatim ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_KTA_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne KlasaTatim: DateTime'
      end;
   if dbo.Isd_FieldTableExists('KlientCmim','DATECREATE')=0
      begin
        ALTER TABLE KlientCmim ADD DATECREATE DATETIME NULL CONSTRAINT [DF_KLC_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne KlientCmim: DateTime'
      end;
   if dbo.Isd_FieldTableExists('KlientCmim','DATEEDIT')=0
      begin
        ALTER TABLE KlientCmim ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_KLC_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne KlientCmim: DateTime'
      end;
   if dbo.Isd_FieldTableExists('MgShoqerues','DATECREATE')=0
      begin
        ALTER TABLE MgShoqerues ADD DATECREATE DATETIME NULL CONSTRAINT [DF_MGSH_DATECRAETE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne MgShoqerues: DateTime'
      end;
   if dbo.Isd_FieldTableExists('MgShoqerues','DATEEDIT')=0
      begin
        ALTER TABLE MgShoqerues ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_MGSH_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne MgShoqerues: DateTime'
      end;
   if dbo.Isd_FieldTableExists('NENDITAR','DATECREATE')=0
      begin
        ALTER TABLE NENDITAR ADD DATECREATE DATETIME NULL CONSTRAINT [DF_NND_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne NENDITAR: DateTime'
      end;
   if dbo.Isd_FieldTableExists('NENDITAR','DATEEDIT')=0
      begin
        ALTER TABLE NENDITAR ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_NND_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne NENDITAR: DateTime'
      end;
   if dbo.Isd_FieldTableExists('OBJECTSLINK','DATECREATE')=0
      begin
        ALTER TABLE OBJECTSLINK ADD DATECREATE DATETIME NULL CONSTRAINT [DF_OLN_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne OBJECTSLINK: DateTime'
      end;
   if dbo.Isd_FieldTableExists('OBJECTSLINK','DATEEDIT')=0
      begin
        ALTER TABLE OBJECTSLINK ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_OLN_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEIT ne OBJECTSLINK: DateTime'
      end;
   if dbo.Isd_FieldTableExists('OBJEKTINST','DATECREATE')=0
      begin
        ALTER TABLE OBJEKTINST ADD DATECREATE DATETIME NULL CONSTRAINT [DF_OIN_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne OBJEKTINST: DateTime'
      end;
   if dbo.Isd_FieldTableExists('OBJEKTINST','DATEEDIT')=0
      begin
        ALTER TABLE OBJEKTINST ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_OIN_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne OBJEKTINST: DateTime'
      end;
   if dbo.Isd_FieldTableExists('SERIALS','DATECREATE')=0
      begin
        ALTER TABLE SERIALS ADD DATECREATE DATETIME NULL CONSTRAINT [DF_SER_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne SERIALS: DateTime'
      end;
   if dbo.Isd_FieldTableExists('SERIALS','DATEEDIT')=0
      begin
        ALTER TABLE SERIALS ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_SER_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne SERIALS: DateTime'
      end;
   if dbo.Isd_FieldTableExists('TRANSPORT','DATECREATE')=0
      begin
        ALTER TABLE TRANSPORT ADD DATECREATE DATETIME NULL CONSTRAINT [DF_TRA_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne TRANSPORT: DateTime'
      end;
   if dbo.Isd_FieldTableExists('TRANSPORT','DATEEDIT')=0
      begin
        ALTER TABLE TRANSPORT ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_TRA_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne TRANSPORT: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FABUXHET','DATECREATE')=0
      begin
        ALTER TABLE FABUXHET ADD DATECREATE DATETIME NULL CONSTRAINT [DF_FABU_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne FABUXHET: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FABUXHET','DATEEDIT')=0
      begin
        ALTER TABLE FABUXHET ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_FABU_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne FABUXHET: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FAFO','DATECREATE')=0
      begin
        ALTER TABLE FAFO ADD DATECREATE DATETIME NULL CONSTRAINT [DF_FAFO_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne FAFO: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FAFO','DATEEDIT')=0
      begin
        ALTER TABLE FAFO ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_FAFO_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne FAFO: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FAHFC','DATECREATE')=0
      begin
        ALTER TABLE FAHFC ADD DATECREATE DATETIME NULL CONSTRAINT [DF_FAHFC_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne FAHFC: DateTime'
      end;
   if dbo.Isd_FieldTableExists('FAHFC','DATEEDIT')=0
      begin
        ALTER TABLE FAHFC ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_FAHFC_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne FAHFC: DateTime'
      end;
   if dbo.Isd_FieldTableExists('SISTEMIMMG','DATECREATE')=0
      begin
        ALTER TABLE SISTEMIMMG ADD DATECREATE DATETIME NULL CONSTRAINT [DF_SISTEMIMMG_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne SISTEMIMMG: DateTime'
      end;
   if dbo.Isd_FieldTableExists('SISTEMIMMG','DATEEDIT')=0
      begin
        ALTER TABLE SISTEMIMMG ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_SISTEMIMMG_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne SISTEMIMMG: DateTime'
      end;
   if dbo.Isd_FieldTableExists('LOCALS','DATECREATE')=0
      begin
        ALTER TABLE LOCALS ADD DATECREATE DATETIME NULL CONSTRAINT [DF_LOCALS_DATECREATE] DEFAULT (GETDATE())
        Print 'Shtim fusha DATECREATE ne LOCALS: DateTime'
      end;
   if dbo.Isd_FieldTableExists('LOCALS','DATEEDIT')=0
      begin
        ALTER TABLE LOCALS ADD DATEEDIT DATETIME NULL CONSTRAINT [DF_LOCALS_DATEEDIT] DEFAULT (GETDATE())
        Print 'Shtim fusha DATEEDIT ne LOCALS: DateTime'
      end;


-- NotActiv

-- EXECUTE sys.sp_MSforeachtable 'ALTER TABLE ? ADD PRIMARY KEY(NRRENDOR)'

   Set @TablesList = 'KASE,KLIENTCMIM,KLIENTCM,NIPT,TRANSPORT,MONEDHA,NENDITAR,NJESI,LLOGARI,'+
                     'ARTIKUJKLS1,ARTIKUJKLS2,ARTIKUJKLS3,ARTIKUJKLS4,ARTIKUJKLS5,ARTIKUJKLS6,'+
                     'FABUXHET,FAFO,FAHFC,INSTALATOR,OBJECTSLINK,OBJEKTINST,MGSHOQERUES,'+
                     'DEPARTAMENT,LISTE,LLOGARIRR,AQKARTELA,AQKATEGORI,AQGRUP,TIPNJESI';
   Set @sSql1 = '  
                      ALTER TABLE KASE ADD NOTACTIV Bit NULL;
                      Print ''Shtim fusha NOTACTIV ne KASE: Bit'';';
   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;
   while @i<=@k
     begin 
       Set  @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
       if   dbo.Isd_FieldTableExists(@TableName,'NOTACTIV')=0
            begin
              Set   @sSql  = Replace(@sSql1,'KASE',@TableName);
              Exec (@sSql);
            end;
       Set  @i = @i + 1;
     end;

-- Fushat per rimbursimin dhe Garanci

   Set @TablesList = 'FJ,FF,FJT,ORK,ORF,OFK,FH,FD,SM,SMBAK,DG';
   Set @sSql1 = '  
                      ALTER TABLE FJSCR ADD CMRIMBURSIM Float NULL;
                      Print ''Shtim fusha CMRIMBURSIM ne FJSCR: Float'';';
   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;

   while @i<=@k
     begin 
       Set   @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',')+'SCR';
       Set   @j = 1;
       while @j<=3
         begin
           Set @sFieldName = dbo.Isd_StringInListStr('CMRIMBURSIM,VLRIMBURSIM,GARANCI',@j,',');  
           if  dbo.Isd_FieldTableExists(@TableName,@sFieldName)=0
               begin
                 Set   @sSql  = Replace(@sSql1,'FJSCR',       @TableName);
                 Set   @sSql  = Replace(@sSql, 'CMRIMBURSIM', @sFieldName);
                  if   @sFieldName='GARANCI' --And (@TableName<>'DGSCR')
                       Set @sSql = Replace(@sSql, 'Float','Int');
                 Exec (@sSql);
               end;
           Set @j = @j + 1;
         end;  
         
       Set  @i = @i + 1;
     end;

   --if dbo.Isd_FieldTableExists('ARTIKUJ','CMRIMBURSIM')=0
   --   begin
   --     ALTER TABLE ARTIKUJ ADD CMRIMBURSIM Float NULL;
   --     Print 'Shtim fusha CMRIMBURSIM ne ARTIKUJ: Float';
   --   end;




   Exec (' USE DRH 

         if Not Exists (Select Name
                          From Sys.Columns
                         Where Object_Id = Object_Id(''USERS'') And (Name=''NOTACTIV''))
           begin
             ALTER TABLE USERS ADD NOTACTIV Bit NULL
             Print ''Shtim fusha NOTACTIV ne DRH..USERS: Bit''
           end; ');
-- Fund NotActiv


-- Shtimi i reshtave tek OrdRowsCfg

     Declare @sKods         Varchar(200),
             @sPershkrims   Varchar(2000);

         Set @sKods       = ',D,DK,DKL,DL,DLK,K,KD,KDL,KL,KLD,L,LD,LDK,LK,LKD';
         Set @sPershkrims = 'Natyral,Departament,Departament - Kod,Departament - Kod - Liste,Departament - Liste,Departament - Liste - Kod,Kod,Kod - Departament,Kod - Departament - Liste,Kod - Liste,Kod - Liste - Departament,Liste,Liste - Departament,Liste - Departament - Kod,Liste - Kod,Liste - Kod - Departament';

     Declare --@i      Int,
             @sText1 Varchar(100),
             @sText2 Varchar(200);

         Set @i = 1
         Set @j = Len(@sKods)-Len(Replace(@sKods,',',''))

          if Object_Id('OrdRowsCfg') is null
             Set @j = 0;

       while @i<=@j
           begin
             Set @sText1 = dbo.Isd_StringInListStr(@sKods,@i,',')
             Set @sText2 = dbo.Isd_StringInListStr(@sPershkrims,@i,',')

             if not Exists (Select Kod From ORDROWSCFG Where Kod=@sText1)
                begin
                  INSERT  INTO ORDROWSCFG
                         (KOD,PERSHKRIM,MODUL)
                  VALUES (@sText1,@sText2,'T')
                end;
             if not Exists (Select Kod From CONFIG..ORDROWSCFG Where Kod=@sText1)
                begin
                  INSERT  INTO CONFIG..ORDROWSCFG
                         (KOD,PERSHKRIM,MODUL)
                  VALUES (@sText1,@sText2,'T')
                end;

             Set @i = @i + 1;
           end;
--

/*         -- U Zevendesua me ate te Config....
Declare @Tip Varchar(5)

if not Exists(SELECT NRRENDOR FROM TIPDOK WHERE TIPDOK='H' AND ISNULL(KOD,'')='')
   begin
     SET    @Tip = 'H'
     UPDATE TIPDOK
        SET PERSHKRIM='Pa klasifikuar'
      WHERE TIPDOK=@Tip AND KOD='NO';

     INSERT INTO TIPDOK
           (TIPDOK, KOD,    PERSHKRIM,    NRORD,           KODNUM, KODTD, VISIBLE, TROW, TAGNR)
     SELECT @Tip,   KOD='', PERSHKRIM='', NRORD=@Tip+'00', KODNUM, KODTD, VISIBLE, TROW, TAGNR
       FROM TIPDOK
      WHERE TIPDOK=@Tip AND KOD='NO'
   end;

if not Exists(SELECT NRRENDOR FROM TIPDOK WHERE TIPDOK='D' AND ISNULL(KOD,'')='')
   begin

     SET    @Tip = 'D'

     UPDATE TIPDOK
        SET PERSHKRIM='Pa klasifikuar'
      WHERE TIPDOK=@Tip AND KOD='NO';

     INSERT INTO TIPDOK
           (TIPDOK, KOD,    PERSHKRIM,    NRORD,           KODNUM, KODTD, VISIBLE, TROW, TAGNR)
     SELECT @Tip,   KOD='', PERSHKRIM='', NRORD=@Tip+'00', KODNUM, KODTD, VISIBLE, TROW, TAGNR
       FROM TIPDOK
      WHERE TIPDOK=@Tip AND KOD='NO'
   end;

if not Exists(SELECT NRRENDOR FROM TIPDOK WHERE TIPDOK='F' AND ISNULL(KOD,'')='')
   begin
     Set    @Tip = 'F'
     UPDATE TIPDOK
        SET PERSHKRIM='Pa klasifikuar'
      WHERE TIPDOK=@Tip AND KOD='NO';

     INSERT  INTO TIPDOK
            (TIPDOK, KOD,PERSHKRIM, NRORD,     KODNUM, KODTD, VISIBLE, TROW, TAGNR)
     VALUES (@Tip,   '', '',        @Tip+'00', '',     '',    1,       0,    -1)
   end;

if not Exists(SELECT NRRENDOR FROM TIPDOK WHERE TIPDOK='S' AND ISNULL(KOD,'')='')
   begin
     Set    @Tip = 'S'
     UPDATE TIPDOK
        SET PERSHKRIM='Pa klasifikuar'
      WHERE TIPDOK=@Tip AND KOD='NO';

     INSERT INTO TIPDOK
           (TIPDOK, KOD,    PERSHKRIM,    NRORD,           KODNUM, KODTD, VISIBLE, TROW, TAGNR)
     SELECT @Tip,   KOD='', PERSHKRIM='', NRORD=@Tip+'00', KODNUM, KODTD, VISIBLE, TROW, TAGNR
       FROM TIPDOK
      WHERE TIPDOK=@Tip AND KOD='NO'
   end;

*/



    SET @sSql1 = '

        SET ANSI_NULLS ON
        SET QUOTED_IDENTIFIER ON
        SET ANSI_PADDING ON
        CREATE TABLE [dbo].[SISTEMIMMG](
	      [NRRENDOR] [int] IDENTITY(1,1) NOT NULL,
	      [KOD] [varchar](30) NULL,
	      [KMAG] [varchar](10) NULL,
	      [DATEDOK] [datetime] NULL,
	      [NRDOK] [float] NULL,
	      [NRFRAKS] [int] NULL,
	      [PERSHKRIM] [varchar](150) NULL,
	      [SHENIM1] [varchar](150) NULL,
	      [DATEFILLIM] [datetime] NULL,
	      [DATEFUND] [datetime] NULL,
	      [QKOSTO] [varchar](30) NULL,
	      [DST] [varchar](10) NULL,
	      [STATUS] [varchar](30) NULL,
	      [ACTIV] [bit] NULL,
	      [STATUSST] [int] NULL,
	      [TRANNUMBER] [varchar](30) NULL,
	      [DATECREATE] [varchar](30) NULL CONSTRAINT [DF_SISTEMIMMG_DATECREATE]  DEFAULT (GETDATE()),
	      [DATEEDIT] [varchar](30) NULL CONSTRAINT [DF_SISTEMIMMG_DATEEIT]  DEFAULT ((CONVERT([varchar](10),getdate(),(104))+''  '')+CONVERT([varchar](8),getdate(),(108))),
	      [TAG] [bit] NULL,
	      [TROW] [bit] NULL,
	      [TAGNR] [int] NULL, 
        CONSTRAINT [PK_SISTEMIMMG] PRIMARY KEY CLUSTERED 
        (
	      [NRRENDOR] ASC
         )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

         ) ON [PRIMARY]

        SET ANSI_PADDING OFF

        PRINT ''Krijim tabele ''+DB_NAME()+''..SISTEMIMMG''; ';


    SET @sSql2 = '

        SET ANSI_NULLS ON
        SET QUOTED_IDENTIFIER ON
        SET ANSI_PADDING ON
        CREATE TABLE [dbo].[SISTEMIMMGSCR](
	      [NRRENDOR] [int] IDENTITY(1,1) NOT NULL,
	      [KOD] [varchar](30) NULL,
	      [PERSHKRIM] [varchar](100) NULL,
	      [NJESI] [varchar](10) NULL,
	      [KLASIF] [varchar](30) NULL,
	      [KLASIF2] [varchar](30) NULL,
	      [KLASIF3] [varchar](30) NULL,
	      [KLASIF4] [varchar](30) NULL,
	      [KLASIF5] [varchar](30) NULL,
	      [KLASIF6] [varchar](30) NULL,
	      [KLASIF7] [varchar](30) NULL,
	      [KLASIF8] [varchar](30) NULL,
	      [KLASIF9] [varchar](30) NULL,
	      [KOSTMES] [float] NULL,
	      [CMIMART] [float] NULL,
	      [KMAG] [varchar](10) NULL,
	      [CMB] [float] NULL,
	      [CMSH] [float] NULL,
	      [CMSH1] [float] NULL,
	      [CMSH2] [float] NULL,
	      [CMSH3] [float] NULL,
	      [CMSH4] [float] NULL,
	      [CMSH5] [float] NULL,
	      [CMSH6] [float] NULL,
	      [CMSH7] [float] NULL,
	      [CMSH8] [float] NULL,
	      [CMSH9] [float] NULL,
	      [CMSH10] [float] NULL,
	      [CMSH11] [float] NULL,
	      [CMSH12] [float] NULL,
	      [CMSH13] [float] NULL,
	      [CMSH14] [float] NULL,
	      [CMSH15] [float] NULL,
	      [CMSH16] [float] NULL,
	      [CMSH17] [float] NULL,
	      [CMSH18] [float] NULL,
	      [CMSH19] [float] NULL,
	      [CMSHPLM1] [float] NULL,
	      [CMSHPLM2] [float] NULL,
	      [BC] [varchar](30) NULL,
	      [POZIC] [varchar](30) NULL,
	      [DATEDOK] [datetime] NULL,
	      [NRDOK] [float] NULL,
	      [NRFRAKS] [int] NULL,
	      [ACTIV] [bit] NULL,
	      [QKOSTO] [varchar](30) NULL,
	      [SHENIM1] [varchar](100) NULL,
	      [VLERADIF] [float] NULL,
	      [SASIOLD] [float] NULL,
	      [CMIMOLD] [float] NULL,
	      [VLERAOLD] [float] NULL,
	      [SASINEW] [float] NULL,
	      [CMIMNEW] [float] NULL,
	      [VLERANEW] [float] NULL,
	      [KOSTMESND] [float] NULL,
	      [KOSTMESMG] [float] NULL,
	      [STATUSST] [int] NULL,
	      [STATROW] [varchar](5) NULL,
	      [NRD] [int] NOT NULL CONSTRAINT [DF_SISTEMIMMG_NRD]  DEFAULT ((0)),
	      [NRRENDKLLG] [int] NULL,
	      [TAG] [bit] NULL,
	      [TROW] [bit] NULL,
	      [TAGNR] [int] NULL

        ) ON [PRIMARY]

        SET ANSI_PADDING OFF

        ALTER TABLE [dbo].[SISTEMIMMGSCR]  WITH NOCHECK ADD  CONSTRAINT [FK_SISTEMIMMGSCR_SIST] FOREIGN KEY([NRD])
        REFERENCES [dbo].[SISTEMIMMG] ([NRRENDOR])
        ON UPDATE CASCADE
        ON DELETE CASCADE

        ALTER TABLE [dbo].[SISTEMIMMGSCR] CHECK CONSTRAINT [FK_SISTEMIMMGSCR_SIST]

        PRINT ''Krijim tabele ''+DB_NAME()+''..SISTEMIMMGSCR''; ';


   if Object_Id('SISTEMIMMG') is null
      Exec (@sSql1);
   if Object_Id('SISTEMIMMGSCR') is null
      Exec (@sSql2);

   if Object_Id('CONFIG..SISTEMIMMG') is null
      Exec ('USE CONFIG; ' + @sSql1);

   if Object_Id('CONFIG..SISTEMIMMGSCR') is null
      Exec ('USE CONFIG; ' + @sSql2);


  Set @sSql = '
  IF  dbo.Isd_FieldTableExists(''TableConfigs'',''FIELDSEARCH2'')=0
      BEGIN
        ALTER TABLE TableConfigs ADD FIELDSEARCH2 Varchar(50) Null
        PRINT ''Shtim fusha FIELDSEARCH2 ne ''+DB_NAME()+''..TableConfigs: Varchar(50)''
      END;
  IF  dbo.Isd_FieldTableExists(''TableConfigs'',''FIELDSEARCH2PROMPT'')=0
      BEGIN
        ALTER TABLE TableConfigs ADD FIELDSEARCH2PROMPT Varchar(20) Null
        PRINT ''Shtim fusha FIELDSEARCH2PROMPT ne ''+DB_NAME()+''..TableConfigs: Varchar(20)''
      END;
  IF  dbo.Isd_FieldTableExists(''TableConfigs'',''FIELDSEARCH2ACTIV'')=0
      BEGIN
        ALTER TABLE TableConfigs ADD FIELDSEARCH2ACTIV Bit Null
        PRINT ''Shtim fusha FIELDSEARCH2ACTIV ne ''+DB_NAME()+''..TableConfigs: Bit''
      END;';
 Exec (@sSql);
 Set   @sSql = 'USE CONFIG;'+@sSql
 Exec (@sSql);



    SET @sSql1 = '

        SET ANSI_NULLS ON
        SET QUOTED_IDENTIFIER ON
        SET ANSI_PADDING ON
        CREATE TABLE [dbo].[CONFIGUS](
	        [NRRENDOR] [int] IDENTITY(1,1) NOT NULL,
	        [KODUS]    [varchar](30) NULL,
	        [ACOLOR]   [int] NULL,
	        [BCOLOR]   [int] NULL,
	        [LCOLOR]   [int] NULL,
	        [SCOLOR]   [int] NULL,
	        [FCOLOR]   [int] NULL,
	        [KCOLOR]   [int] NULL,
	        [RCOLOR]   [int] NULL,
	        [ACOLORACT]    [bit] NULL,
	        [BCOLORACT]    [bit] NULL,
	        [LCOLORACT]    [bit] NULL,
	        [SCOLORACT]    [bit] NULL,
	        [FCOLORACT]    [bit] NULL,
	        [KCOLORACT]    [bit] NULL,
	        [RCOLORACT]    [bit] NULL,
            [ACTIVCOLROWS] [bit] NULL,
            [DATECREATE]   [datetime] NULL CONSTRAINT [DF_CFGUS_DATECREATE]  DEFAULT (getdate()),
            [DATEEDIT]     [datetime] NULL CONSTRAINT [DF_CFGUS_DATEEDIT]  DEFAULT (getdate()),
	        [USI]   [varchar](10) NULL,
	        [USM]   [varchar](10) NULL,
	        [TAG]   [bit] NULL,
	        [TROW]  [bit] NULL,
	        [TAGNR] [int] NULL
        ) ON [PRIMARY]

        SET ANSI_PADDING OFF 

        PRINT ''Krijim tabele ''+DB_NAME()+''..CONFIGUS''; '

   if Object_Id('CONFIGUS') is null
      Exec (@sSql1);

   if Object_Id('CONFIG..CONFIGUS') is null
      Exec ('USE CONFIG; ' + @sSql1);


-- Shtim i promptit per produktin AP (jave,vit)
   Set @TablesList = 'FJ,FF,FJT,OFK,ORK,ORF,SM,SMBAK,FH,FD';
   Set @sSql1 = '  
                      ALTER TABLE FJSCR ADD PROMPTPROD1 Varchar(20) NULL;
                      Print ''Shtim fusha PROMPTPROD1 ne FJSCR: Varchar(20)'';';
   Set @sSql2 = '  
                      ALTER TABLE FJSCR ADD SASIKONV Float NULL;
                      Print ''Shtim fusha SASIKONV ne FJSCR: Float'';';
   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;
   while @i<=@k
     begin 
       Set  @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
       if   dbo.Isd_FieldTableExists(@TableName+'SCR','PROMPTPROD1')=0
            begin
              Set   @sSql  = Replace(@sSql1,'FJ',@TableName);
              Exec (@sSql);
            end;
       if   dbo.Isd_FieldTableExists(@TableName+'SCR','SASIKONV')=0
            begin
              Set   @sSql  = Replace(@sSql2,'FJ',@TableName);
              Exec (@sSql);
            end;
       Set  @i = @i + 1
     end;



-- Shtim fusha per AQ

   Set @TablesList = 'AQKARTELA,AQKATEGORI,AQGRUP';
   Set @sSql1 = '  
                      ALTER TABLE AQKARTELA ADD USI Varchar(10) NULL;
                      Print ''Shtim fusha USI ne AQKARTELA: Varchar(10)'';';
   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;
   while @i<=@k
     begin 
       Set  @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
       if   dbo.Isd_FieldTableExists(@TableName,'USI')=0
            begin
              Set   @sSql  = Replace(@sSql1,'AQKARTELA',@TableName);
              Exec (@sSql);
            end;
       if   dbo.Isd_FieldTableExists(@TableName,'USM')=0
            begin
              Set   @sSql  = Replace(@sSql1,'AQKARTELA',@TableName);
              Set   @sSql  = Replace(@sSql, 'USI','USM');
              Exec (@sSql);
            end;
            
       Set     @i = @i + 1
     end;


   if dbo.Isd_FieldTableExists('AQKATEGORI','VLEREMINAM')=0
      begin
        ALTER TABLE AQKATEGORI ADD VLEREMINAM Float
        Print 'Shtim fusha VLEREMINAM ne AQKATEGORI: Float'
      end;
   if dbo.Isd_FieldTableExists('AQKATEGORI','PERQINDMINAM')=0
      begin
        ALTER TABLE AQKATEGORI ADD PERQINDMINAM Float
        Print 'Shtim fusha PERQINDMINAM ne AQKATEGORI: Float'
      end;
   if dbo.Isd_FieldTableExists('AQKATEGORI','APLVLEREMINAM')=0   -- VLEREMINAM
      begin
        ALTER TABLE AQKATEGORI ADD APLVLEREMINAM Int
        Print 'Shtim fusha APLVLEREMINAM ne AQKATEGORI: Int'
      end;

   if dbo.Isd_FieldTableExists('AQKATEGORI','NORMEAM2')=0
      begin
        ALTER TABLE AQKATEGORI ADD NORMEAM2 Float
        Print 'Shtim fusha NORMEAM2 ne AQKATEGORI: Float'
      end;
   if dbo.Isd_FieldTableExists('AQKATEGORI','NRTIMEAM2')=0
      begin
        ALTER TABLE AQKATEGORI ADD NRTIMEAM2 Int
        Print 'Shtim fusha NRTIMEAM2 ne AQKATEGORI: Int'
      end;
   if dbo.Isd_FieldTableExists('AQKATEGORI','ACTIVAM2')=0
      begin
        ALTER TABLE AQKATEGORI ADD ACTIVAM2 Bit
        Print 'Shtim fusha ACTIVAM2 ne AQKATEGORI: Bit'
      end;
   if dbo.Isd_FieldTableExists('AQKATEGORI','AMVLEREMBET')=0
      begin
        ALTER TABLE AQKATEGORI ADD AMVLEREMBET Bit
        Print 'Shtim fusha AMVLEREMBET ne AQKATEGORI: Bit'
      end;
   if dbo.Isd_FieldTableExists('AQKATEGORI','AMVLEREMBET2')=0
      begin
        ALTER TABLE AQKATEGORI ADD AMVLEREMBET2 Bit
        Print 'Shtim fusha AMVLEREMBET2 ne AQKATEGORI: Bit'
      end;
   if dbo.Isd_FieldTableExists('AQKATEGORI','VLEREMINAM2')=0
      begin
        ALTER TABLE AQKATEGORI ADD VLEREMINAM2 Float
        Print 'Shtim fusha VLEREMINAM2 ne AQKATEGORI: Float'
      end;
   if dbo.Isd_FieldTableExists('AQKATEGORI','PERQINDMINAM2')=0
      begin
        ALTER TABLE AQKATEGORI ADD PERQINDMINAM2 Float
        Print 'Shtim fusha PERQINDMINAM ne AQKATEGORI2: Float'
      end;
   if dbo.Isd_FieldTableExists('AQKATEGORI','APLVLEREMINAM2')=0
      begin
        ALTER TABLE AQKATEGORI ADD APLVLEREMINAM2 Int
        Print 'Shtim fusha APLVLEREMINAM2 ne AQKATEGORI: Int'
      end;



-- AQKARTELA

   if dbo.Isd_FieldTableExists('AQKARTELA','KODORIGJINE')=0
      begin
        ALTER TABLE AQKARTELA ADD KODORIGJINE Varchar(60)
        Print 'Shtim fusha KODORIGJINE ne AQKARTELA: Varchar(60)'
      end;

-- AQKARTELA Te gjitha duhen hequr sepse duhet vetem ditar: shiko View Isd.AQLastOperation 
      
   if dbo.Isd_FieldTableExists('AQKARTELA','AQSTATUS')=0  -- ndoshta dhe AQStatus mund te hiqet
      begin
        ALTER TABLE AQKARTELA ADD AQSTATUS Int
        Print 'Shtim fusha AQSTATUS ne AQKARTELA: Int'
      end;
   if dbo.Isd_FieldTableExists('AQKARTELA','AQSTATUSDATE')=0
      begin
        ALTER TABLE AQKARTELA ADD AQSTATUSDATE DateTime
        Print 'Shtim fusha AQSTATUSDATE ne AQKARTELA: DateTime'
      end;
      
 /*if dbo.Isd_FieldTableExists('AQKARTELA','AQPERDORUES')=0
      begin
        ALTER TABLE AQKARTELA ADD AQPERDORUES Varchar(30)
        Print 'Shtim fusha AQPERDORUES ne AQKARTELA: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('AQKARTELA','AQLOCATION')=0
      begin
        ALTER TABLE AQKARTELA ADD AQLOCATION Varchar(150)
        Print 'Shtim fusha AQLOCATION ne AQKARTELA: Varchar(150)'
      end;
   if dbo.Isd_FieldTableExists('AQKARTELA','AQAMORTPROGRES')=0
      begin
        ALTER TABLE AQKARTELA ADD AQAMORTPROGRES Float
        Print 'Shtim fusha AQAMORTPROGRES ne AQKARTELA: Flat'
      end;
   if dbo.Isd_FieldTableExists('AQKARTELA','AQVLEFTEPROGRES')=0
      begin
        ALTER TABLE AQKARTELA ADD AQVLEFTEPROGRES Float
        Print 'Shtim fusha AQVLEFTEPROGRES ne AQKARTELA: Flat'
      end;
   if dbo.Isd_FieldTableExists('AQKARTELA','AQBLERJEVLEFTE')=0
      begin
        ALTER TABLE AQKARTELA ADD AQBLERJEVLEFTE Float
        Print 'Shtim fusha AQBLERJEVLEFTE ne AQKARTELA: Flat'
      end;
   if dbo.Isd_FieldTableExists('AQKARTELA','AQBLERJEDATE')=0
      begin
        ALTER TABLE AQKARTELA ADD AQBLERJEDATE DateTime
        Print 'Shtim fusha AQBLERJEDATE ne AQKARTELA: DateTime'
      end;
   if dbo.Isd_FieldTableExists('AQKARTELA','AQBLERJEMON')=0
      begin
        ALTER TABLE AQKARTELA ADD AQBLERJEMON Varchar(10)
        Print 'Shtim fusha AQBLERJEMON ne AQKARTELA: Varchar(10)'
      end;
   if dbo.Isd_FieldTableExists('AQKARTELA','AQBLERJEKURS1')=0
      begin
        ALTER TABLE AQKARTELA ADD AQBLERJEKURS1 Float
        Print 'Shtim fusha AQBLERJEKURS1 ne AQKARTELA: Flat'
      end;
   if dbo.Isd_FieldTableExists('AQKARTELA','AQBLERJEKURS2')=0
      begin
        ALTER TABLE AQKARTELA ADD AQBLERJEKURS2 Float
        Print 'Shtim fusha AQBLERJEKURS2 ne AQKARTELA: Flat'
      end;*/
      
   if dbo.Isd_FieldTableExists('AQKARTELA','AMDATESTART')=0
      begin
        ALTER TABLE AQKARTELA ADD AMDATESTART Datetime
        Print 'Shtim fusha AMDATESTART ne AQKARTELA: Datetime'
      end;
   if dbo.Isd_FieldTableExists('AQKARTELA','AMDATESTARTAPLIKIM')=0
      begin
        ALTER TABLE AQKARTELA ADD AMDATESTARTAPLIKIM Bit
        Print 'Shtim fusha AMDATESTARTAPLIKIM ne AQKARTELA: Bit'
      end;


   if dbo.Isd_FieldTableExists('KlasaTatim','KODTVSHFIC')=0
      begin
        ALTER TABLE KlasaTatim ADD KODTVSHFIC VARCHAR(30) NULL 
        Print 'Shtim fusha KODTVSHFIC ne KlasaTatim: Varchar(30)'
      end;
   if dbo.Isd_FieldTableExists('KlasaTatim','KODTVSHEIC')=0
      begin
        ALTER TABLE KlasaTatim ADD KODTVSHEIC VARCHAR(30) NULL 
        Print 'Shtim fusha KODTVSHEIC ne KlasaTatim: Varchar(30)'
      end;



   Set @sSql1 = '  
                      ALTER TABLE AQKARTELA ADD DATECREATE DATETIME NULL CONSTRAINT [DF_AQKARTELA_DATECREATE]  DEFAULT (GETDATE());
                      Print ''Shtim fusha DATECREATE ne AQKARTELA: DateTime'';';
   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;
   while @i<=@k
     begin 
       Set  @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
       if   dbo.Isd_FieldTableExists(@TableName,'DATECREATE')=0
            begin
              Set   @sSql  = Replace(@sSql1,'AQKARTELA',@TableName);
              Exec (@sSql);
            end;
       if   dbo.Isd_FieldTableExists(@TableName,'DATEEDIT')=0
            begin
              Set   @sSql  = Replace(@sSql1,'AQKARTELA',@TableName);
              Set   @sSql  = Replace(@sSql, 'DATECREATE','DATEEDIT');
              Exec (@sSql);
            end;
            
       Set     @i = @i + 1
     end;


   Set @TablesList = 'ARKASCR,BANKASCR,VSSCR';
   Set @sSql1 = '  
                      ALTER TABLE ARKASCR ADD KODAGJ Varchar(30) NULL;
                      Print ''Shtim fusha KODAGJ ne ARKASCR: Varchar(30)'';';
   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;
   while @i<=@k
     begin 
       Set  @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
       if   dbo.Isd_FieldTableExists(@TableName,'KODAGJ')=0
            begin
              Set   @sSql  = Replace(@sSql1,'ARKASCR',@TableName);
              Exec (@sSql);
            end;
       Set @i = @i + 1
     end;


   Set @TablesList = 'FJ,FJT,ORK,OFK,SM,SMBAK,FF,ORF';
   Set @sSql1 = '
   
     DECLARE @Size Int; 
     
      SELECT @Size = Character_Maximum_Length
        FROM Information_schema.columns
       WHERE Table_Name=''FJ''  And Column_Name=''LLOJDOK'';  
       
          if (dbo.Isd_FieldTableExists(''FJ'',''LLOJDOK'')=1) and (IsNull(@Size,0) < 10)
             begin
               ALTER TABLE FJ ALTER COLUMN LLOJDOK VARCHAR(10) Null;
               Print ''Ndryshim fusha LLOJDOK ne FJ: Varchar(10)''
             end;  
             
             ';

   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;
   while @i<=@k
     begin 
       Set   @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
       Set   @sSql  = Replace(@sSql1,'FJ',@TableName);
    -- Print @sSql;
       Exec (@sSql);
       Set   @i = @i + 1
     end;
     
     

-- Fusha ISNOTFIRO ne SCR
     
   Set @TablesList = 'FHSCR,FDSCR,FJSCR,FFSCR,DGSCR,FJTSCR,OFKSCR,ORKSCR,ORFSCR,SMSCR,SMBAKSCR';
   Set @sSql1 = '  
                      ALTER TABLE FHSCR ADD ISNOTFIRO Bit NULL;
                      Print ''Shtim fusha ISNOTFIRO ne FHSCR: Bit'';';
                      
   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;
   while @i<=@k
     begin 
       Set  @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
       if   dbo.Isd_FieldTableExists(@TableName,'ISNOTFIRO')=0
            begin
              Set   @sSql  = Replace(@sSql1,'FHSCR',@TableName);
              Exec (@sSql);
            end; 
       Set @i = @i + 1
     end;
     

-- Fusha KODKLF ne SCR
     
   Set @TablesList = 'FHSCR,FDSCR,FJSCR,FFSCR,DGSCR,FJTSCR,OFKSCR,ORKSCR,ORFSCR,SMSCR,SMBAKSCR';
   Set @sSql1 = '  
                      ALTER TABLE FHSCR ADD KODKLF Varchar(30) NULL;
                      Print ''Shtim fusha KODKLF ne FHSCR: Varchar(30)'';';
                      
   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;
   while @i<=@k
     begin 
       Set  @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
       if   dbo.Isd_FieldTableExists(@TableName,'KODKLF')=0
            begin
              Set   @sSql  = Replace(@sSql1,'FHSCR',@TableName);
              Exec (@sSql);
            end; 
       Set @i = @i + 1
     end;     



-- PESHANET,PESHABRT,PERQKMS,VLERAKMS,KOEFICENTARTAGJ,KOEFICENTARTKL tek dokumentat

   Set @TablesList = 'FJSCR,FFSCR,FJTSCR,ORKSCR,ORFSCR,OFKSCR,SMSCR,SMBAKSCR';
   Set @sSql1 = '  
                      ALTER TABLE FJSCR ADD PERQKMS Float NULL;
                      Print ''Shtim fusha PERQKMS ne FJSCR: Float'';';
   Set @sSql2 = '  
                      ALTER TABLE FJSCR ADD KODAQ Varchar(60) NULL;
                      Print ''Shtim fusha KODAQ ne FJSCR: Varchar'';';

   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;

   while @i<=@k
     begin 
       Set   @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
       Set   @j = 1;
       while @j<=6
          begin
            Set @sFieldName = dbo.Isd_StringInListStr('PESHANET,PESHABRT,PERQKMS,VLERAKMS,KOEFICENTARTAGJ,KOEFICENTARTKL',@j,',');  
            if  dbo.Isd_FieldTableExists(@TableName,@sFieldName)=0
                begin
                  Set   @sSql  = Replace(@sSql1,'FJSCR',       @TableName);
                  Set   @sSql  = Replace(@sSql, 'PERQKMS',     @sFieldName);
                  Exec (@sSql);
                end;
               
            Set @j = @j + 1;
          end;  
         
       if dbo.Isd_FieldTableExists(@TableName,'KODAQ')=0
          begin
            Set @sSql  = Replace(@sSql2,'FJSCR', @TableName);
            Exec (@sSql);
          end;
          
       Set  @i = @i + 1;
     end;


   if dbo.Isd_FieldTableExists('FJSCR','PERQKMS')=0
      begin
        ALTER TABLE FJSCR ADD PERQKMS Float NULL
        Print 'Shtim fusha PERQKMS ne FJSCR: Float'
      end;
   if dbo.Isd_FieldTableExists('FJSCR','VLERAKMS')=0
      begin
        ALTER TABLE FJSCR ADD VLERAKMS Float NULL
        Print 'Shtim fusha VLERAKMS ne FJSCR: Float'
      end;


-- KODPACIENT,KODDOCTEGZAM,KODDOCTREFER tek dokumentat

   Set @TablesList = 'FJ,FJT,FD,FH';
   Set @sSql1 = '  
                      ALTER TABLE FJ ADD KODPACIENT VARCHAR(30) NULL;
                      Print ''Shtim fusha KODPACIENT ne FJ: Varchar(30)'';';
   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;

   while @i<=@k
     begin 
       Set   @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
       Set   @j = 1;
       while @j<=3
         begin
           Set @sFieldName = dbo.Isd_StringInListStr('KODPACIENT,KODDOCTEGZAM,KODDOCTREFER',@j,',');  
           if  dbo.Isd_FieldTableExists(@TableName,@sFieldName)=0
               begin
                 Set   @sSql  = Replace(@sSql1,'FJ',         @TableName);
                 Set   @sSql  = Replace(@sSql, 'KODPACIENT', @sFieldName);
                 Exec (@sSql);
               end;
           Set @j = @j + 1;
         end;  
         
       Set  @i = @i + 1;
     end;
          

-- SWIFTKOD,LLOGARIBANKE2,SWIFTKOD2 tek KLIENT/FURNITOR

   Set @TablesList = 'KLIENT,FURNITOR';
   Set @sSql1 = '  
                      ALTER TABLE KLIENT ADD SWIFTKOD VARCHAR(100) NULL;
                      Print ''Shtim fusha SWIFTKOD ne KLIENT: Varchar(100)'';';
   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;
   
-- PRINT @sSql1;

   while @i<=@k
     begin 
       Set   @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
       Set   @j = 1;
       while @j<=3
         begin
           Set @sFieldName = dbo.Isd_StringInListStr('SWIFTKOD,LLOGARIBANKE2,SWIFTKOD2',@j,',');  
           if  dbo.Isd_FieldTableExists(@TableName,@sFieldName)=0
               begin
                 Set   @sSql  = Replace(@sSql1,'KLIENT',   @TableName);
                 Set   @sSql  = Replace(@sSql, 'SWIFTKOD', @sFieldName);
              -- Print @TableName;
              -- Print @sSql;
                 Exec (@sSql);
               end;
           Set @j = @j + 1;
         end;  
         
       Set  @i = @i + 1;
     end;


-- Fusha CMSHREFAP ne FJSCR etj                                           

   Set @TablesList = 'FJSCR,FFSCR,FJTSCR,OFKSCR,ORKSCR,ORFSCR,SMSCR,SMBAKSCR';
   Set @sSql1 = '  
                      ALTER TABLE FJTSCR ADD CMSHREFAP Float NULL; 
                      Print ''Shtim fusha CMSHREFAP ne FJTSCR: Float'';';
                      
   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;
   while @i<=@k
     begin 
       Set @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
       if  dbo.Isd_FieldTableExists(@TableName,'CMSHREFAP')=0
           begin
             Set   @sSql = Replace(@sSql1,'FJTSCR',  @TableName);
          -- PRINT @sSql
             Exec (@sSql);
             
             Set   @sSql2 = '  
                      UPDATE B SET CMSHREFAP = B.CMIMBS FROM FJT A INNER JOIN FJTSCR B ON A.NRRENDOR=B.NRD;';
             
             Set   @sSql  = Replace(@sSql2,'FJTSCR',@TableName);
             Set   @sSql  = Replace(@sSql, 'FJT',Replace(@TableName,'SCR',''));
             Exec (@sSql);
           end;

       if  dbo.Isd_FieldTableExists(@TableName,'CMSHREFAP2')=0
           begin
             Set   @sSql  = Replace(@sSql1,'FJTSCR',  @TableName);
             Set   @sSql  = Replace(@sSql, 'CMSHREFAP','CMSHREFAP2'); 
           --PRINT @sSql
             Exec (@sSql);
           end;

       Set @i = @i + 1
     end;




   Set @TablesList = 'FJSCR,FJTSCR,ORKSCR,OFKSCR,SMSCR,SMBAKSCR';
   Set @sSql1 = '  
                      ALTER TABLE FJSCR ADD CMKOSTMES Float NULL;
                      Print ''Shtim fusha CMKOSTMES ne FJSCR: Float'';';
   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;

   while @i<=@k
     begin 
       Set   @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
       Set   @j = 1;
       while @j<=4
         begin
           Set @sFieldName = dbo.Isd_StringInListStr('CMKOSTMES,CMKOSTMESMV,VLKOSTMES,MARZH',@j,',');  
           if  dbo.Isd_FieldTableExists(@TableName,@sFieldName)=0
               begin
                 Set   @sSql  = Replace(@sSql1,'FJSCR',       @TableName);
                 Set   @sSql  = Replace(@sSql, 'CMKOSTMES',   @sFieldName);
              -- Print @sSql;
                 Exec (@sSql);
               end;
           Set @j = @j + 1;
         end;  
         
       Set  @i = @i + 1;
     end;


   Set @sFieldName = 'DTPRODHIM';
   Set @TablesList = 'FFSCR,FJSCR,FJTSCR,ORKSCR,OFKSCR,SMSCR,SMBAKSCR,ORFSCR,FHSCR,FDSCR';
   Set @sSql1 = '  
                      ALTER TABLE FFSCR ADD DTPRODHIM Datetime NULL;
                      Print ''Shtim fusha DTPRODHIM ne FFSCR: Datetime'';';
   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;

   while @i<=@k
     begin 
       Set @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
       if  dbo.Isd_FieldTableExists(@TableName,@sFieldName)=0
           begin
             Set   @sSql  = Replace(@sSql1,'FFSCR',@TableName);  -- Print @sSql;
             Exec (@sSql);
           end;  
       Set  @i = @i + 1;
     end;




   Set @sFieldName = 'JOBCREATE';
   Set @TablesList = 'FF,FJ,FJT,ORK,OFK,SM,SMBAK,ORF,DG,FH,FD,ARKA,BANKA,VS,FK,VSST,FKST';
   Set @sSql1 = '  
                      ALTER TABLE FF ADD JOBCREATE Varchar(10) NULL;
                      Print ''Shtim fusha JOBCREATE ne FF: Varchar(10)'';';
   Set @sSql2 = '  
                      ALTER TABLE FF ADD SHENIME Varchar(500) NULL;
                      Print ''Shtim fusha SHENIME ne FF: Varchar(500)'';';
   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;

   while @i<=@k
     begin 
       Set @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
       if  dbo.Isd_FieldTableExists(@TableName,@sFieldName)=0
           begin
             Set   @sSql  = Replace(@sSql1,'FF',@TableName);  -- Print @sSql;
             Exec (@sSql);
           end;  
       if  dbo.Isd_FieldTableExists(@TableName,'SHENIME')=0
           begin
             Set   @sSql  = Replace(@sSql2,'FF',@TableName);  -- Print @sSql;
             Exec (@sSql);
           end;  
       Set  @i = @i + 1;
     end;

   
   Set @TablesList = 'FJSHOQERUES,MGSHOQERUES,FFSHOQERUES,FJTSHOQERUES';
   Set @sSql1 = '  
                      ALTER TABLE FJSHOQERUES ADD AGJENT Varchar(30) NULL;
                      Print ''Shtim fusha AGJENT ne FJSHOQERUES: Varchar(30)'';';
   Set @sSql2 = '  
                      ALTER TABLE FJSHOQERUES ADD ZONA Varchar(150) NULL;
                      Print ''Shtim fusha ZONA ne FJSHOQERUES: Varchar(150)'';';
   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;

   while @i<=@k
     begin 
       Set @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
       if  dbo.Isd_FieldTableExists(@TableName,'AGJENT')=0
           begin
             Set   @sSql  = Replace(@sSql1,'FJSHOQERUES',@TableName);               -- Print @sSql;
             Exec (@sSql);
           end;  
           
       if  dbo.Isd_FieldTableExists(@TableName,'ZONA')=0
           begin
             Set   @sSql  = Replace(@sSql2,'FJSHOQERUES',@TableName);               -- Print @sSql;
             Exec (@sSql);
           end;
           
       Set  @i = @i + 1;
     end;



-- Fusha KODDETAJ tek ARKASCR,BANKASCR,VSSCR

   Set @TablesList   = 'ARKASCR,BANKASCR,VSSCR,VSSTSCR,FJSCR,FFSCR,ORKSCR,ORFSCR,OFKSCR,FJTSCR';
   Set @sSql = '  
                      ALTER TABLE ARKASCR ADD KODDETAJ Varchar(60) NULL;
                      Print ''Shtim fusha KODDETAJ ne ARKASCR: Varchar(60)''; ';
   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;
   while @i<=@k
     begin 
       Set @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
       Set @sSql1  = Replace(@sSql,'ARKASCR',@TableName);
       if  dbo.Isd_FieldTableExists(@TableName,'KODDETAJ')=0
           Exec (@sSql1);
       Set @i = @i + 1
     end; 


--  DET1,DET2,DET3,DET4,etc tek Ditaret

   Set @TablesList = 'DAR,DBA,DFU,DKL';
   Set @sSql1 = '  
                      ALTER TABLE DAR ADD DET1 VARCHAR(30) NULL;
                      Print ''Shtim fusha DET1 ne DAR: Varchar(30)'';';
   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;
   
   while @i<=@k
     begin 
       Set @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
	   Set @sSql2 = Replace(@sSql1,'DAR',@TableName);

       Set @sSql  = Replace(@sSql2,'DET1','KODREF');
       if  dbo.Isd_FieldTableExists(@TableName,'KODREF')=0
           Exec (@sSql); 

	   Set @j = 1;
	   While @j<=5
	     begin
           Set @sSql = Replace(@sSql2,'DET1','DET'+CAST(@j AS Varchar(1)));
           if  dbo.Isd_FieldTableExists(@TableName,'DET'+CAST(@j AS Varchar(1)))=0
               Exec (@sSql); -- Print @sSql;
               
           Set @j = @j + 1;
		 end;


       Set  @i = @i + 1;
     end;




--
-- FISDATEPARE,FISDATEFUND,FISTVSHEFEKT tek faturimet

   Set @TablesList = 'FF,FJ,FJT,ORK,OFK,SM,SMBAK,ORF,DG';
   Set @sSql1 = '  
                      ALTER TABLE FJT ADD FISDATEPARE DATETIME NULL;
                      Print ''Shtim fusha FISDATEPARE ne FJT: DateTime'';';
   Set @sSql2 = '  
                      ALTER TABLE FJT ADD FISTVSHEFEKT Varchar(10) NULL;
                      Print ''Shtim fusha FISTVSHEFEKT ne FJT: Varchar(10)'';';
   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;
   
   while @i<=@k
     begin 
       Set @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
	   Set @sSql = Replace(@sSql1,'FJT',@TableName);
       if  dbo.Isd_FieldTableExists(@TableName,'FISDATEPARE')=0
           begin
             Exec (@sSql);
           end;
       if  dbo.Isd_FieldTableExists(@TableName,'FISDATEFUND')=0
           begin
             Set   @sSql  = Replace(@sSql, 'FISDATEPARE', 'FISDATEFUND');
             Exec (@sSql);
           end;

       Set @sSql = Replace(@sSql2,'FJT', @TableName);
       if  dbo.Isd_FieldTableExists(@TableName,'FISTVSHEFEKT')=0
           begin
             Exec (@sSql);
           end;

       Set  @i = @i + 1;
     end;

--

-- ISDOCFISCAL tek FH,FD     -- ndoshta duhet bere me strukture si tek Faturat e shitjes

   Set @TablesList = 'FH,FD';
   Set @sSql1 = '  
                      ALTER TABLE FD ADD ISDOCFISCAL BIT NULL;
                      Print ''Shtim fusha ISDOCFISCAL ne FD: Bit'';';
   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;
   
   while @i<=@k
     begin 
       Set @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
	   Set @sSql = Replace(@sSql1,'FD',@TableName);
       if  dbo.Isd_FieldTableExists(@TableName,'ISDOCFISCAL')=0
           Exec (@sSql);

       Set  @i = @i + 1;
     end;



-- FISKALIZUAR tek FJ,FF,SM,SMBAK,FH,FD     

   Set @TablesList = 'FJ,FF,SM,SMBAK,FH,FD,ARKA,BANKA';
   Set @sSql1 = '  
                      ALTER TABLE FJ ADD FISKALIZUAR BIT NULL;
                      Print ''Shtim fusha FISKALIZUAR ne FJ: Bit'';';
   Set @i = 1;
   Set @k = Len(@TablesList) - Len(Replace(@TablesList,',',''))+1;
   
   while @i<=@k
     begin 
       Set @TableName = dbo.Isd_StringInListStr(@TablesList,@i,',');
	   Set @sSql = Replace(@sSql1,'FJ',@TableName);
       if  dbo.Isd_FieldTableExists(@TableName,'FISKALIZUAR')=0
           Exec (@sSql);

       Set  @i = @i + 1;
     end;

--


   --if dbo.Isd_FieldTableExists('FJSHOQERUES','AGJENT')=0  
   --   begin
   --     ALTER TABLE FJSHOQERUES ADD AGJENT Varchar(30)
   --     Print 'Shtim fusha AGJENT ne FJSHOQERUES: Varchar(30)'
   --   end;
   --if dbo.Isd_FieldTableExists('MGSHOQERUES','AGJENT')=0  
   --   begin
   --     ALTER TABLE MGSHOQERUES ADD AGJENT Varchar(30)
   --     Print 'Shtim fusha AGJENT ne MGSHOQERUES: Varchar(30)'
   --   end;
   --if dbo.Isd_FieldTableExists('FFSHOQERUES','AGJENT')=0  
   --   begin
   --     ALTER TABLE FFSHOQERUES ADD AGJENT Varchar(30)
   --     Print 'Shtim fusha AGJENT ne FFSHOQERUES: Varchar(30)'
   --   end;
   --if dbo.Isd_FieldTableExists('FJSHOQERUES','ZONE')=0  
   --   begin
   --     ALTER TABLE FJSHOQERUES ADD ZONE Varchar(150)
   --     Print 'Shtim fusha ZONE ne FJSHOQERUES: Varchar(150)'
   --   end;
   --if dbo.Isd_FieldTableExists('MGSHOQERUES','ZONE')=0  
   --   begin
   --     ALTER TABLE MGSHOQERUES ADD ZONE Varchar(150)
   --     Print 'Shtim fusha ZONE ne MGSHOQERUES: Varchar(150)'
   --   end;
   --if dbo.Isd_FieldTableExists('FFSHOQERUES','ZONE')=0  
   --   begin
   --     ALTER TABLE FFSHOQERUES ADD ZONE Varchar(150)
   --     Print 'Shtim fusha ZONE ne FFSHOQERUES: Varchar(150)'
   --   end;
      
      
      
      

    SET @sSql1 = '

        SET ANSI_NULLS ON
        SET QUOTED_IDENTIFIER ON
        SET ANSI_PADDING ON

        CREATE TABLE [dbo].[ArtikujCmBl](
	        [NRRENDOR] [int] IDENTITY(1,1) NOT NULL,
	        [NRD] [Int] NULL,
	        [KOD] [varchar](60) NULL,
	        [CMBL1] [float] NULL,
	        [CMBL2] [float] NULL,
	        [CMBL3] [float] NULL,
	        [CMBL4] [float] NULL,
	        [CMBL5] [float] NULL,
	        [CMBL6] [float] NULL,
	        [CMBL7] [float] NULL,
	        [CMBL8] [float] NULL,
	        [CMBL9] [float] NULL,
	        [CMBL10] [float] NULL,
	        [CMBL11] [float] NULL,
	        [CMBL12] [float] NULL,
	        [CMBL13] [float] NULL,
	        [CMBL14] [float] NULL,
	        [CMBL15] [float] NULL,
	        [CMBL16] [float] NULL,
	        [CMBL17] [float] NULL,
	        [CMBL18] [float] NULL,
	        [CMBL19] [float] NULL,
	        [CMBL20] [float] NULL,
	        [USI] [varchar](10) NULL,
	        [USM] [varchar](10) NULL,
	        [DATECREATE] [datetime] NULL,
	        [DATEEDIT] [datetime] NULL,
	        [TROW] [bit] NULL,
	        [TAGNR] [int] NULL
        ) ON [PRIMARY]


        SET ANSI_PADDING OFF
        ALTER TABLE [dbo].[ArtikujCmBl] ADD  CONSTRAINT [DF_ArtikujCmBl_DATECRATE]  DEFAULT (getdate()) FOR [DATECREATE]
        ALTER TABLE [dbo].[ArtikujCmBl] ADD  CONSTRAINT [DF_ArtikujCmBl_DATEEDIT]  DEFAULT (getdate()) FOR [DATEEDIT] 
        PRINT ''Krijim tabele ''+DB_NAME()+''..[ArtikujCmBl]''; ';

   IF Object_Id('[ArtikujCmBl]') is NULL
      BEGIN
        SET   @OkEx = 1;
        EXEC (@sSql1);
      END;
   IF Object_Id('CONFIG..[ArtikujCmBl]') is NULL
      BEGIN
        SET   @OkEx = 1;
        EXEC ('USE CONFIG; ' + @sSql1);
      END;




--
    SET @sSql1 = '
        SET ANSI_NULLS ON
        SET QUOTED_IDENTIFIER ON
        SET ANSI_PADDING ON
        CREATE TABLE [dbo].[DRHUSERFRM](
	        [NRRENDOR] [int] IDENTITY(1,1) NOT NULL,
	        [NRD] [int] NULL,
	        [KODUS] [varchar](30) NULL,
	        [FORMNAME] [varchar](30) NULL,
	        [KODREF] [varchar](30) NULL,
	        [FIELDS] [varchar](3000) NULL,
	        [TIPDOK] [varchar](30) NULL,
	        [ACTIV] [bit] NULL,
	        [TROW] [bit] NULL,
	        [TAGNR] [int] NULL
        ) ON [PRIMARY]
        SET ANSI_PADDING OFF

        Print ''Create Table DRHUSERFRM''; '

   if Object_Id('DRHUSERFRM') is null
      Exec (@sSql1);

   if Object_Id('CONFIG..DRHUSERFRM') is null
      Exec ('USE CONFIG; ' + @sSql1);




-- Tabelat e reja per Save Filter, dy tabela

    SET @OkEx = 0;
    
    SET @sSql1 = '

        SET ANSI_NULLS ON
        SET QUOTED_IDENTIFIER ON
        SET ANSI_PADDING ON
        
        CREATE TABLE [dbo].[USER_FORM_FILTERS](
	        [NRRENDOR] [INT] IDENTITY(1,1) NOT NULL,
	        [USERNAME] [NVARCHAR](255) NOT NULL,
	        [FORM_NAME] [NVARCHAR](255) NOT NULL,
	        [FILTER_NAME] [NVARCHAR](255) NOT NULL,
	        [FILTER_DATA] [VARBINARY](MAX) NULL,
        PRIMARY KEY CLUSTERED 
        (
	        [NRRENDOR] ASC
        )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
        ) ON [PRIMARY]
        
        SET ANSI_PADDING OFF 

        PRINT ''Krijim tabele ''+DB_NAME()+''..USER_FORM_FILTERS''; '

   if Object_Id('USER_FORM_FILTERS') is NULL
      BEGIN
        SET   @OkEx = 1;
        EXEC (@sSql1);
      END;

   if Object_Id('CONFIG..USER_FORM_FILTERS') is NULL
      BEGIN 
        SET   @OkEx = 1;
        EXEC ('USE CONFIG; ' + @sSql1);
      END;
      

    SET @sSql1 = '

        SET ANSI_NULLS ON
        SET QUOTED_IDENTIFIER ON
        SET ANSI_PADDING ON
        
        CREATE TABLE [dbo].[USER_STORAGE](
	        [NRRENDOR] [INT] IDENTITY(1,1) NOT NULL,
	        [USERNAME] [VARCHAR](255) NULL,
	        [NAME] [NVARCHAR](255) NOT NULL,
	        [DATA] [NTEXT] NULL,
        PRIMARY KEY CLUSTERED 
        (
	        [NRRENDOR] ASC,
	        [NAME] ASC
        )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
        ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
        
        SET ANSI_PADDING OFF 

        PRINT ''Krijim tabele ''+DB_NAME()+''..[USER_STORAGE]''; ';

   IF Object_Id('[USER_STORAGE]') is NULL
      BEGIN
        SET   @OkEx = 1;
        EXEC (@sSql1);
      END;

   IF Object_Id('CONFIG..[USER_STORAGE]') is NULL
      BEGIN
        SET   @OkEx = 1;
        EXEC ('USE CONFIG; ' + @sSql1);
      END;

  IF @OkEx=1
     BEGIN
       SET @sSql1 = '
        EXECUTE sys.sp_MSforeachtable ''ALTER TABLE ? ADD PRIMARY KEY(NRRENDOR)''; 
        PRINT ''Krijim NRRENDOR Celes Primary per cdo tabele ne ''+DB_NAME(); ';
        EXEC (@sSql1);
        EXEC ('USE CONFIG; ' + @sSql1);
     END




-- Shtim i reshtave per tabelen GRUMBULLIM
   Insert Into DRHUser
        (KodUs,Nrd,Modul,TipDok,KodRef,NrKufiP,NrKufiS,ActivModul,ActivKufij,TRow,TagNr)

   Select Distinct KodUs,NrD=0,Modul='F',TipDok='GRM',KodRef='GRM',NrKufiP=1,NrKufiS=999999999,ActivModul=0,ActivKufij=1,TRow=0,TagNr=0 
     From DRHUser A
    Where Modul='F' AND TipDok='ORF' AND
         (Not Exists ( SELECT * FROM DRHUser B WHERE B.KodUS=A.KodUS AND B.Modul='F' AND B.TipDok='GRM' AND B.KodRef='GRM')) 
 Order By A.KodUS,Modul,TipDok;
 
 --  
 Insert Into CONFIG..TablesName
       (TABLESTR, NRORDER, KOD, PERSHKRIM, TABLENAME, MODUL, TIP, ORG, OBJEKT, STRUCTURE, LIST, ORDERLM, KALIMLM, TROW, TAGNR)
 SELECT TABLESTR='DOC',	NRORDER='S05',KOD='GRUMBULLIM',PERSHKRIM='Grumbullim malli',TableName='GRUMBULLIM',Modul='F',TIP='GRM',ORG='GRM',Objekt='',STRUCTURE='MD',LIST='GRM', ORDERLM='', KALIMLM=0, TROW=0, TAGNR=0
   WHERE NOT EXISTS (SELECT * FROM CONFIG..TablesName WHERE KOD='GRUMBULLIM')

 
 
   if EXISTS (SELECT TOP 1 NRRENDOR FROM FISMENPAGESE) 
      begin

         SELECT @Size = Character_Maximum_Length
           FROM Information_schema.columns
          WHERE Table_Name = 'FISMENPAGESE'  And Column_Name='KODREFERENCE';  

             if IsNull(@Size,0) < 1000
                begin
                  ALTER TABLE FISMENPAGESE ALTER COLUMN KODREFERENCE VARCHAR(1000) Null;
                  Print 'Ndryshim fusha KODREFERENCE ne FISMENPAGESE: Varchar(1000)'
                end;

      end;



-- Fund Tabelat e reja per Save Filter, dy tabela      


Exec [dbo].[Isd_InicTablePromoc] 

Set NoCount On


Print 'Fund';




GO
