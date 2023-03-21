SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   FUNCTION [dbo].[Isd_TestKlaseTvDoc]
(
  @PTable      Varchar(30),
  @PKlase      Varchar(10),
  @PNrRow      Int,
  @PNrRowTv    Int,
  @PNrRowTt    Int,
  @PNrRendor   Int
)

Returns Varchar(200) 

As

Begin            -- Select A=dbo.Isd_TestKlaseTvDoc('FJ','SVND',3,3,1,567734) 


-- Kjo te kthehet ne store procedure ku variablat @NrRow etj te llogariten ne tabelen temporare.(#FjScr,#FfScr etj)


     Declare @NrRendor    Int,

             @TvshFix     Int,
             @List        Varchar(100),
             @NrRow       Int,
             @NrRowTv     Int,
             @NrRowTt     Int,
             @Pershkrim   Varchar(50),
             @Result      Varchar(200);

         Set @NrRendor  = @PNrRendor;
         Set @NrRow     = @PNrRow;
         Set @NrRowTv   = @PNrRowTv;
         Set @NrRowTt   = @PNrRowTt;

         Set @List      = ',FFRM,FBKQ,SEXP,SAGJ,SBKQ,';  -- FREG,u hoq date 14.02.2017, FANG,SANG u hoq date 12.03.2019,
         Set @TvshFix   = -1;
         Set @Result    = '';

          if CharIndex(','+@PKlase+',',',SEXP,FIMP,')>0  -- Export,Import
             Set @TvshFix = 0
          else
          if CharIndex(','+@PKlase+',',@List)>0
             Set @TvshFix = 20;
/*
         SET @NrRow     = @PNrRow;         -- keto te dhena kalkulohen tek tabela temporare prandaj vijne si parametra ....
         SET @NrRowTv   = @PNrRowTv;
         SET @NrRowTt   = @PNrRowTt;
          IF @PTable='FJ'
             SELECT @NrRow   = COUNT(CASE WHEN ISNULL(VLPATVSH,0)<>0 AND ISNULL(VLTVSH,0)<>0 THEN 1 ELSE 0 END),
                    @NrRowTv = SUM(  CASE WHEN ISNULL(VLTVSH,0)<>0                           THEN 1 ELSE 0 END),
                    @NrRowTt = SUM(  CASE WHEN ISNULL(APLTVSH,0)=0   AND ISNULL(VLTVSH,0)<>0 THEN 1 ELSE 0 END)
               FROM FJScr 
              WHERE NRD=@PNrRendor;


          IF @PTable='FF'
             SELECT @NrRow   = COUNT(CASE WHEN ISNULL(VLPATVSH,0)<>0 AND ISNULL(VLTVSH,0)<>0 THEN 1 ELSE 0 END),
                    @NrRowTv = SUM(  CASE WHEN ISNULL(VLTVSH,0)<>0                           THEN 1 ELSE 0 END),
                    @NrRowTt = SUM(  CASE WHEN ISNULL(APLTVSH,0)=0   AND ISNULL(VLTVSH,0)<>0 THEN 1 ELSE 0 END)
               FROM FJScr 
              WHERE NRD=@PNrRendor;

         SET @NrRow     = ISNULL(@NrRow,0);
         SET @NrRowTv   = ISNULL(@NrRowTv,0);
         SET @NrRowTt   = ISNULL(@NrRowTt,0);
*/

          
          if @PTable='FF'
             begin
               Select @Pershkrim = PERSHKRIM 
                 From CONFIG..TIPDOK 
                Where TIPDOK='FKTV' AND KOD=@PKlase;

               Set @NrRowTt = 0;
             end;

          if @PTable='FJ'
             begin
               Select @Pershkrim = PERSHKRIM 
                 From CONFIG..TIPDOK 
                Where TIPDOK='SKTV' AND KOD=@PKlase;
             end;
          
         Set @Pershkrim = IsNull(@Pershkrim,'');

          if (@TvshFix=0) And (@NrRowTv>0)
             Set @Result  = 'Dokumenti duhet me elemente me Tvsh zero ..!'
          else
          if (@TvshFix>0) And (@NrRow<>@NrRowTv)
             Set @Result  = 'Dokumenti ka elemente me Tvsh zero. Duhet te gjithe elementet me Tvsh <> zero ..!'
          else
          if @NrRowTt>0
             Set @Result  = 'Dokumenti ka elemente pa tatueshem dhe Tvsh <> zero ..!';

          if (@Result<>'') And (@Pershkrim<>'')
             Set @Result = @Result + ' / '+@Pershkrim;

          if @Result<>''
             Set @Result = @Result + ';BLOK';

      Return (@Result);

End;
GO
