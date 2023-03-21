SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE   FUNCTION [dbo].[DRHMaster]
(
 @PUser          Varchar(30),
 @PTableName     Varchar(50),
 @PFilterMaster  Varchar(Max)           -- NrRendor Master
)
Returns Varchar(Max)

As

Begin
  
     Declare @User        Varchar(30),
             @TableName   Varchar(50),
             @Filter      Varchar(Max),
             @Where       Varchar(Max),
             @Where1      Varchar(Max),
             @DtUser      VarChar(20),
             @TName       VarChar(20),
             @Tip         VarChar(10),
             @ReferName   Varchar(20),
             @DokPaMg     Bit;

         Set @User      = @PUser
         Set @TableName = @PTableName
         Set @Filter    = @PFilterMaster;

         Set @DokPaMg   = 0;
         Set @Where     = '';
         Set @Where1    = '';
         Set @ReferName = '';

      Select @DokPaMg   = IsNull(DOKPAMG,0)
        From DRHUser
       Where KodUs = @User And KodRef=@TableName;

    --Print @DokPaMg
        Set @DokPaMg    = IsNull(@DokPaMg,0)
         if @DokPaMg    = 0
            Set @Where1 = ' IsNull(KMAG,'''')<>'''' AND ';

        Set @TName      = @TableName;
        Set @DtUser     = Dbo.DRHDateKP(@User,@TName);
        Set @Tip        = '';

         if @TableName  = 'FH'
            Set @Tip    = 'H'
         else
         if @TableName  = 'FD'
            Set @Tip    = 'D'
         else
         if @TableName  = 'ARKA'
            Set @Tip    = 'A'
         else
         if @TableName  = 'BANKA'
            Set @Tip    = 'B';
            
            
         if @TableName  = 'GRUMBULLIM'   
            begin
              Set @TableName = 'GRM';
              Set @TName     = 'GRM';
            end;

        Set @Tip        = QuoteName(@Tip,'''');
        Set @User       = QuoteName(@User,'''');
        Set @TableName  = QuoteName(@TableName,'''');
      
            
              

         if @Filter<>''
            Set @Filter=@Filter+' AND ';


         if CharIndex(','+@TName+',',',FJ,FJT,OFK,ORK,SM,')>0
            Set @ReferName = 'KLIENT'
         else
         if CharIndex(','+@TName+',',',FF,OFF,')>0
            Set @ReferName = 'FURNITOR';


         if CharIndex(','+@TName+',',',FJ,FJT,SM,FF,OFF,OFK,ORK,')>0 -- ORK,  
                                                                     -- u hoq ORK sepse nuk punonte dot nje perdorues me magazina te kufizuara tek Porosite 
                                                                     -- (per magazina te ndryshme jo te lejuara) dhe na pengonte tek korigjimi dhe shperndarja e porosive.
                                                                     -- Te perpunohet me vone qe te lejohet vetem per porosite ose ofertat edhe keto magazina te kufizuara

            Set @Where = 
         
 ' WHERE A.DATEDOK>=DBO.DATEVALUE('''+@DtUser+''')  AND '+@Where1+'
        (Exists (SELECT 1
                   FROM DRHUSER B
                  WHERE B.KODREF='+@TableName+' AND KODUS='+@User+' AND A.NRDOK>=B.NRKUFIP AND A.NRDOK<=B.NRKUFIS)) 

         And 

        (Not (Exists ( SELECT 1
                        FROM DRHUSERKUFI
                       WHERE KODUS='+@User+' AND 
                           ((REFERENCE='''+@ReferName+'''   AND KODFKL>=KUFIP AND KODFKL<=KUFIS) OR
                            (REFERENCE=''MAGAZINA'' AND KMAG  >=KUFIP AND KMAG  <=KUFIS)) ) ))'


         else


         if CharIndex(','+@TName+',',',FK,DG,FKST,VS,VSST,GRM,')>0

            Set @Where = 

 ' WHERE A.DATEDOK>=DBO.DATEVALUE('''+@DtUser+''')  AND 
        (Exists (SELECT 1
                  FROM DRHUSER B
                 WHERE B.KODREF='+@TableName+' AND KODUS='+@User+' AND A.NRDOK>=B.NRKUFIP AND A.NRDOK<=B.NRKUFIS)) '


         else


         if CharIndex(','+@TName+',',',ARKA,BANKA,')>0

            Set @Where = 

 ' WHERE '+@Filter+' A.DATEDOK>=DBO.DATEVALUE('''+@DtUser+''') '

--' WHERE '+@Filter+'
--         A.DATEDOK>=DBO.DATEVALUE('''+@DtUser+''')  AND 
--       ((Exists (SELECT 1
--                  FROM DRHUSER B
--                 WHERE B.KODREF=A.KODAB AND KODUS='+@User+' AND A.NUMDOK>=B.NRKUFIP AND A.NUMDOK<=B.NRKUFIS)) 
--          OR NOT Exists (SELECT 1
--                           FROM DRHUSER B
--                          WHERE B.KODREF=A.KODAB AND KODUS='+@User+'))'

         else

         if CharIndex(','+@TName+',',',FH,FD,')>0

            Set @Where = 

 ' WHERE '+@Filter+'
         A.DATEDOK>=DBO.DATEVALUE('''+@DtUser+''')  AND 
       ( (Exists (SELECT 1
                  FROM DRHUSER B
                 WHERE B.KODREF=A.KMAG AND TIPDOK='+@Tip+' AND KODUS='+@User+' AND A.NRDOK>=B.NRKUFIP AND A.NRDOK<=B.NRKUFIS)) 
          OR NOT Exists (SELECT 1
                           FROM DRHUSER B
                          WHERE B.KODREF=A.KMAG AND KODUS='+@User+'))'

  Return @Where

end



GO
