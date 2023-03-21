SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   PROCEDURE [dbo].[Isd_GetDocOrderRows]
(
  @pTableName   Varchar(30),
  @pOrder       Varchar(200) Output,
  @pEditMode    Int          Output
 )


As

BEGIN

--  Declare @pOrder       Varchar(200),
--          @pEditMode    Int;
--     EXEC dbo.Isd_GetDocOrderRows 'FK', @pOrder Output, @pEditMode Output;
-- Print @pOrder;
-- PRINT @pEditMode;


     DECLARE @Kod          Varchar(20),
             @Result       Varchar(200),
             @EditMode     Int,
             @TableName    Varchar(30);

         SET @TableName  = @pTableName;


      SELECT @Kod        = KOD, 
             @EditMode   = CASE WHEN ISNULL(EDITMODE,0)=0 THEN 0 ELSE 1 END 
        FROM ORDROWSDOC 
       WHERE DOC=@TableName;


         SET @Kod = ISNULL(@Kod,'');

               IF @Kod=''
                  SET @Result = 'NRD,NRRENDOR'

          ELSE IF @Kod='K'
                  SET @Result = 'NRD,LLOGARIPK,NRRENDOR'
          ELSE IF @Kod='KD'
                  SET @Result = 'NRD,LLOGARIPK,dbo.Isd_SegmentFind(KOD,0,2),NRRENDOR'
          ELSE IF @Kod='KDL'
                  SET @Result = 'NRD,LLOGARIPK,dbo.Isd_SegmentFind(KOD,0,2),dbo.Isd_SegmentFind(KOD,0,3),NRRENDOR'
          ELSE IF @Kod='KL'
                  SET @Result = 'NRD,LLOGARIPK,dbo.Isd_SegmentFind(KOD,0,3),NRRENDOR'
          ELSE IF @Kod='KLD'
                  SET @Result = 'NRD,LLOGARIPK,dbo.Isd_SegmentFind(KOD,0,3),dbo.Isd_SegmentFind(KOD,0,2),NRRENDOR'

          ELSE IF @Kod='D'
                  SET @Result = 'NRD,dbo.Isd_SegmentFind(KOD,0,2),NRRENDOR'
          ELSE IF @Kod='DK'
                  SET @Result = 'NRD,dbo.Isd_SegmentFind(KOD,0,2),LLOGARIPK,NRRENDOR'
          ELSE IF @Kod='DKL'
                  SET @Result = 'NRD,dbo.Isd_SegmentFind(KOD,0,2),LLOGARIPK,dbo.Isd_SegmentFind(KOD,0,3),NRRENDOR'
          ELSE IF @Kod='DL'
                  SET @Result = 'NRD,dbo.Isd_SegmentFind(KOD,0,2),dbo.Isd_SegmentFind(KOD,0,3),NRRENDOR'
          ELSE IF @Kod='DLK'
                  SET @Result = 'NRD,dbo.Isd_SegmentFind(KOD,0,2),dbo.Isd_SegmentFind(KOD,0,3),LLOGARIPK,NRRENDOR'

          ELSE IF @Kod='L'
                  SET @Result = 'NRD,dbo.Isd_SegmentFind(KOD,0,3),NRRENDOR'
          ELSE IF @Kod='LK'
                  SET @Result = 'NRD,dbo.Isd_SegmentFind(KOD,0,3),LLOGARIPK,NRRENDOR'
          ELSE IF @Kod='LKD'
                  SET @Result = 'NRD,dbo.Isd_SegmentFind(KOD,0,3),LLOGARIPK,dbo.Isd_SegmentFind(KOD,0,2),NRRENDOR'
          ELSE IF @Kod='LD'
                  SET @Result = 'NRD,dbo.Isd_SegmentFind(KOD,0,3),dbo.Isd_SegmentFind(KOD,0,2),NRRENDOR'
          ELSE IF @Kod='LDK'
                  SET @Result = 'NRD,dbo.Isd_SegmentFind(KOD,0,3),dbo.Isd_SegmentFind(KOD,0,2),LLOGARIPK,NRRENDOR';

          IF NOT (@TableName='FK' OR @TableName='FKST') 
             BEGIN
               SET @Result = Replace(@Result,'dbo.Isd_SegmentFind(KOD,0,2)','CASE WHEN TIPKLL=''T'' THEN dbo.Isd_SegmentFind(KOD,0,2) ELSE '''' END');
               SET @Result = Replace(@Result,'dbo.Isd_SegmentFind(KOD,0,3)','CASE WHEN TIPKLL=''T'' THEN dbo.Isd_SegmentFind(KOD,0,3) ELSE '''' END');
             END;
          IF (@TableName='ARKA' OR @TableName='BANKA') 
             BEGIN
               SET @Result = Replace(@Result,'NRD,','NRD,RRAB DESC,');
             END;
             
          IF @TableName='AQHISTORISCR' 
             BEGIN
               SET @Result = Replace(@Result,'NRD,','ORDERSCR,');
             END;

     SET @pOrder    = Replace(@Result,'NRD,','');

     SET @pEditMode = ISNULL(@EditMode,0);

END
GO
