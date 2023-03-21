SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   PROCEDURE [dbo].[Isd_GetGridListReference]

(
  @pTableName Varchar(60)
)


As

-- EXEC dbo.Isd_GetGridListReference 'ARTIKUJ'

-- Percaktimi i renditjes dhe fushave per afishim ne grid te referencave


     DECLARE @sListFields   Varchar(Max),
             @sListEx       Varchar(Max),
             @sTableName    Varchar(100);
--           @sFieldName    Varchar(50),
--           @i             Int,
--           @j             Int;

         SET @sTableName  = @pTableName;
         SET @sListEx     = 'NRRENDOR, KODNEW, USI, USM, TAG, TAGNR, TROW, TAGRND';
         SET @sListFields = '';


         IF  @sTableName='ARTIKUJ'
             BEGIN
               SET @sListFields = '
                   NRRENDOR,
                   KOD, PERSHKRIM, PERSHKRIMSH, NJESI, TIP, BC,POZIC,
                   KLASIF, KLASIF2, KLASIF3, KLASIF4, KLASIF5, KLASIF6,
                   KOSTMES, KOSTPLAN, MINI, MAKS, NOTNEG=NEGST,
                   TATIM, KODLM, KODTVSH, VLTAX, DEP, LIST, ORG, ISAMB, AMBAUTFJ, APLKMS, PERQKMS,  
                   KONV1, KONV2, KONVNJESI, KONVKOLITR,  
                   NJESB, KOEFB, CMB, NJESSH, KOEFSH, 
                   CMSH,   CMSH1,  CMSH2,  CMSH3,  CMSH4,  CMSH5,  CMSH6,  CMSH7,  CMSH8,  CMSH9, 
                   CMSH10, CMSH11, CMSH12, CMSH13, CMSH14, CMSH15, CMSH16, CMSH17, CMSH18, CMSH19, CMSHPLM1, CMSHPLM2, 
                   DSCNTKLA, DSCNTKLB, DSCNTKLC, DSCNTKLD, DSCNTKLE, DSCNTKLF, DSCNTKLG, DSCNTKLH, DSCNTKLI, DSCNTKLJ, 
                   DSCNTKLK, DSCNTKLL, DSCNTKLM, DSCNTKLN, DSCNTKLO, DSCNTKLP, DSCNTKLQ, DSCNTKLR, DSCNTKLS, DSCNTKLT, 

                   PESHA, PESHANET, PESHABRT, VOLUM, PESHORETREG, KOEFICPERB,  RIMBURSIM,
                   KODORG, DOGANEKOD, FURNKOD, FURNARTKOD, FURNARTPERSHKRIM, FAGARANCI, STATUSSPEC, GARANCI, 
                   CMSHMIN, CMSHMAX, CMSHLIMIT, CMBLMIN, CMBLMAX, CMBLLIMIT, CMSHLIMITBLC, CMBLLIMITBLC, 
                   NRSERIAL, UPDATELASTBL, DATELASTBL, 
                   AUTOSHKLPFJ, AUTOSHKLPFDBR, 
                   KOEFICENT, PERSHKRIMF, KOEFICBONUS, 
                   NOTACTIVSH, NOTACTIVBL, NOTACTIV, KODNEW, 
                   DATECREATE, DATEEDIT, USI, USM, TAG, TAGNR, TROW ';
             END;

      SELECT LISTFIELDS     = Replace(Replace(Replace(@sListFields,CHAR(13),''),CHAR(10),''),' ',''), 
             LISTNOTVISIBLE = Replace(Replace(Replace(@sListEx,    CHAR(13),''),CHAR(10),''),' ','')

     
--   EXEC ('SELECT '+@sListFields+' FROM ARTIKUJ ORDER BY KOD ');
        
--         SET @j  = Len(@sListEx)-Len(Replace(@sListEx,',',''))+1
--         SET @i  = 1
--
--         WHILE @i <= @j
--			 BEGIN
--               SET @sFieldName  = LTrim(RTrim(dbo.Isd_StringInListStr(@sListEx,@i,',')));
--               SET @sListFields = Replace(@sListFields, @sFieldName+',', '');     
--               SET @i = @i + 1;
--             END
GO
