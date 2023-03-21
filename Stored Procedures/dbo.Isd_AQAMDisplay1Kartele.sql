SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE         procedure [dbo].[Isd_AQAMDisplay1Kartele]
(

  @pDateEnd        Varchar(20),                      
  @pDateDok        Varchar(20),
  @pShenim1        Varchar(150),
  @pShenim2        Varchar(150),
  @pWhere          Varchar(Max),
  @pDepKart        Int,                 
  @pListKart       Int,
  @pModelAM        Int,                 
  @pUser           Varchar(30),
  @pTableTmp       Varchar(30)
)

AS

--      EXEC dbo.Isd_AQAMDisplay1Kartele '31/12/2022','31/12/2018','Amortizim xxxx','Amortizim yyyy','R1.KOD=''X01000001''',0,0,0,'ADMIN','##AA';


         SET NOCOUNT ON;

     DECLARE @DateEnd         Varchar(20),                      
             @DateDok         Varchar(20),
             @Shenim1         Varchar(150),
             @Shenim2         Varchar(150),
             @Where           Varchar(Max),
             @DepKart         Int,                 
             @ListKart        Int,
             @User            Varchar(30),
             @ModelAM         Int,
             @TableName       Varchar(50),
             @sSql1           nVarchar(MAX),
             @sExec           Varchar(100);

         SET @DateEnd       = @pDateEnd;
         SET @DateDok       = @pDateDok;
         SET @Shenim1       = @pShenim1;
         SET @Shenim2       = @pShenim2;
         SET @Where         = @pWhere;
         SET @DepKart       = @pDepKart;                 
         SET @ListKart      = @pListKart;
         SET @ModelAM       = @pModelAM;
         SET @User          = @pUser;
         
         SET @TableName     = IsNull(@pTableTmp,''); 

          IF OBJECT_ID('Tempdb..'+@TableName) IS NOT NULL
             BEGIN
               SET   @sExec = 'DROP TABLE '+@TableName;
               EXEC (@sExec);
             END;
             
        
        EXEC dbo.Isd_AQAMDisplay @DateEnd,@DateDok,@Shenim1,@Shenim2,@Where,'NOTDISPL',@DepKart,@ListKart,@ModelAM,@User,'##AQTmp_AM';  


-- Ne se duhet @TableName
          IF @TableName<>''
             BEGIN
                 SET @sSql1 = 'SELECT * INTO '+@TableName+' FROM ##AQTmp_AM;';
               EXEC (@sSql1);
             END;
        


/*    SELECT Kartela     = Kod,
             Pershkrim   = PershkrimAM + Case When IsNull(PershkrimAM,'')<>'' AND ISNULL(KomentAM,'')<>'' THEN '/' ELSE '' END + IsNull(KomentAM,''),
             Koment      = KomentAM,
             VlereAktivi = AQVleraCum,
             Amortizim   = VleraAM,
             VlereMbetur = AQVleraMbet 
        FROM ##AQTmp_AM 
       WHERE TIPROW='D';  */
       

      SELECT Pershkrim = Substring(Pershkrim+Space(20),1,20), [Te dhena] = Substring(A.Value+Space(70),1,70), 
             TRow = Cast(0 As Bit), TagNr = 0, NrRendor = 0

        FROM
        
       (

             SELECT Pershkrim = 'Kartela',             Value = Kod
               FROM ##AQTmp_AM 
              WHERE TIPROW='D'
  
          UNION ALL     
  
             SELECT Pershkrim = 'Periudhe amortizimi', Value = PershkrimAM + CASE WHEN IsNull(PershkrimAM,'')<>'' AND ISNULL(KomentAM,'')<>'' THEN '/' ELSE '' END + IsNull(KomentAM,'')
               FROM ##AQTmp_AM 
              WHERE TIPROW='D'
  
          UNION ALL     
  
             SELECT Pershkrim = 'Vlefte Aktivi',       Value = Convert(Varchar,Cast(AQVleraCum As Money),1) 
               FROM ##AQTmp_AM 
              WHERE TIPROW='D'
  
          UNION ALL     
  
             SELECT Pershkrim = 'Vlefte Amortizim',    Value = Convert(Varchar,Cast(VleraAM As Money),1)
               FROM ##AQTmp_AM 
              WHERE TIPROW='D'
  
          UNION ALL     
  
             SELECT Pershkrim = 'Vlefte Mbetur',       Value = Convert(Varchar,Cast(AQVleraMbet As Money),1)
               FROM ##AQTmp_AM 
              WHERE TIPROW='D'

       ) A;        
                  
                  
GO
