SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE     Procedure [dbo].[Isd_ListCmimeShDoc]
(
  @Kod    Varchar(100),
  @TipRef Varchar(10),
  @KodKF  Varchar(10),
  @Table  Varchar(10),
  @Round  Int
)

AS

-- Afishimi i cmimeve sipas dokumentit, KodKLF dhe Artikullit ose Cdo Tipi

-- Exec dbo.Isd_ListCmimeShDoc 'A001', 'K', 'D001', 'FJ', 4


--          if @Round<=-1
--             Set @Round = 0
--          else
--          if @Round>9
--             Set @Round = 4


     Declare @i Int,
             @Sql        Varchar(Max),
             @TabRef     Varchar(30),
             @TabRefKF   Varchar(30),
             @Prompt     Varchar(30),
             @CmimGrup   Varchar(Max),
             @iRound     Int;

         Set @iRound    = @Round;

          if @Round<=-1
             begin
               Select @iRound = Cmim From Decimals Where TableName='FJ';
                  Set @iRound = IsNull(@iRound,@Round);
             end;


-- 1.
         Set @i      = dbo.Isd_StringInListInd('K,R,L,S',@TipRef,',')
         Set @TabRef = dbo.Isd_StringInListStr('ARTIKUJ,SHERBIM,LLOGARI,KLIENT',@i,',')
         if  @i>=3
             Set @CmimGrup = '1'
         else
         if  @i>=2
             Set @CmimGrup = '
                         Max(Case When C.GRUP=''A'' Then D.CMSH 
                                  When C.GRUP=''B'' Then D.CMSH1 
                                  When C.GRUP=''C'' Then D.CMSH2 
                                  When C.GRUP=''D'' Then D.CMSH3 
                                  When C.GRUP=''E'' Then D.CMSH4 
                                  When C.GRUP=''F'' Then D.CMSH5 
                                  When C.GRUP=''G'' Then D.CMSH6 
                                  When C.GRUP=''H'' Then D.CMSH7 
                                  When C.GRUP=''I'' Then D.CMSH8 
                                  When C.GRUP=''J'' Then D.CMSH9
                                  Else                   D.CMSH End) '
         else
             Set @CmimGrup = '
                         Max(Case When C.GRUP=''A'' Then D.CMSH 
                                  When C.GRUP=''B'' Then D.CMSH1 
                                  When C.GRUP=''C'' Then D.CMSH2 
                                  When C.GRUP=''D'' Then D.CMSH3 
                                  When C.GRUP=''E'' Then D.CMSH4 
                                  When C.GRUP=''F'' Then D.CMSH5 
                                  When C.GRUP=''G'' Then D.CMSH6 
                                  When C.GRUP=''H'' Then D.CMSH7 
                                  When C.GRUP=''I'' Then D.CMSH8 
                                  When C.GRUP=''J'' Then D.CMSH9
                                  When C.GRUP=''K'' Then D.CMSH10 
                                  When C.GRUP=''L'' Then D.CMSH11 
                                  When C.GRUP=''M'' Then D.CMSH12 
                                  When C.GRUP=''N'' Then D.CMSH13 
                                  When C.GRUP=''O'' Then D.CMSH14 
                                  When C.GRUP=''P'' Then D.CMSH15 
                                  When C.GRUP=''Q'' Then D.CMSH16 
                                  When C.GRUP=''R'' Then D.CMSH17 
                                  When C.GRUP=''S'' Then D.CMSH18 
                                  When C.GRUP=''T'' Then D.CMSH19
                                  Else                   D.CMSH End) ';

-- 2.
         Set @i       = dbo.Isd_StringInListInd('FJ,FJT,ORK,OFK,FF,ORF',@Table,',');
         Set @Prompt  = dbo.Isd_StringInListStr('Shitje,Proforme,Porosi,Oferte,Blerje,Porosi',@i,',');

         Set @TabRefKF = 'KLIENT';
          if dbo.Isd_StringInListInd('FF,ORF',@Table,',')>0
             Set @TabRefKF = 'FURNITOR';

         Set @Sql    = '
	  Select Dokument  = ''' + @Prompt + ''',
             KODFKL    = A.KODFKL, 
			 KOD       = B.KARTLLG,
			 CMIM      = Round(B.CMIMBS,'+Cast(@iRound As Varchar(10))+'),
             KMON      = IsNull(A.KMON,''''),
			 EMERTIM   = Max(C.PERSHKRIM),
			 PERSHKRIM = Max(D.PERSHKRIM),
             KOMENT    = '''+@Table+'''+'' ''+Cast(Cast(Max(NRDOK) As BigInt) As Varchar)+'', ''+
                         Convert(Varchar,Max(DATEDOK),104)+'',  ''+
                         A.KODFKL+'' - ''+Max(IsNull(A.SHENIM2,'''')),
             GRUP      = Max(C.GRUP),
             CMIMGRUP  = Round('+@CmimGrup+','+Cast(@iRound As Varchar(10))+'),
             TAGNR     = 0,
             TROW      = CAST(0 AS BIT)

		From '+@Table+' A Inner Join '+@Table+'SCR   B On A.NRRENDOR=B.NRD
				  Left  Join '+@TabRefKF+'  C On A.KODFKL=C.KOD
				  Left  JOIN '+@TabRef  +'  D On D.KOD=B.KARTLLG
	   Where A.KODFKL='''+@KodKF+''' And B.KARTLLG='''+@Kod+''' And TIPKLL='''+@TipRef+'''
	Group By A.KODFKL, IsNull(A.KMON,''''), B.KARTLLG, Round(B.CMIMBS,'+Cast(@iRound As Varchar(10))+')
	Order By KMON,CMIM '

     Print @Sql;


          if @i<>0
             Exec (@Sql)


--
--
--
--
--
--        Set @CmimGrup = '    Case When C.GRUP=''A'' Then D.CMSH 
--                                  When C.GRUP=''B'' Then D.CMSH1 
--                                  When C.GRUP=''C'' Then D.CMSH2 
--                                  When C.GRUP=''D'' Then D.CMSH3 
--                                  When C.GRUP=''E'' Then D.CMSH4 
--                                  When C.GRUP=''F'' Then D.CMSH5 
--                                  When C.GRUP=''G'' Then D.CMSH6 
--                                  When C.GRUP=''H'' Then D.CMSH7 
--                                  When C.GRUP=''I'' Then D.CMSH8 
--                                  When C.GRUP=''J'' Then D.CMSH9
--                                  Else                   D.CMSH End '
--
--
--    Set @Sql    = '
--	  Select Dokument  = ''' + @Prompt + ''',
--             KODFKL    = A.KODFKL, 
--			 KOD       = B.KARTLLG,
--			 CMIM      = Round(B.CMIMBS,'+Cast(@Round As Varchar(10))+'),
--             KMON      = IsNull(A.KMON,''''),
--			 EMERTIM   = C.PERSHKRIM,
--			 PERSHKRIM = D.PERSHKRIM,
--             GRUP      = C.GRUP,
--             CMIMGRUP  = '+@CmimGrup+',
--             TAGNR     = 0,
--             TROW      = CAST(0 AS BIT)
--
--		From '+@Table+' A Inner Join '+@Table+'SCR   B On A.NRRENDOR=B.NRD
--				  Left  Join KLIENT  C On A.KODFKL=C.KOD
--				  Left  JOIN '+@TabRef+' D On D.KOD=B.KARTLLG
--	   Where A.KODFKL='''+@KodKF+''' And B.KARTLLG='''+@Kod+''' And TIPKLL='''+@TipRef+'''
--	--Group By A.KODFKL, IsNull(A.KMON,''''), B.KARTLLG, Round(B.CMIMBS,'+Cast(@Round As Varchar(10))+')
--	Order By KMON,CMIM '
--
--Print @Sql
--
--if @i<>0
--   Exec (@Sql)
GO
