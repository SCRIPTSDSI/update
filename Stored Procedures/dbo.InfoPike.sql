SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[InfoPike](@nrd as int)
as
select pe.nrrendor,
                'Emer' = case when isnull(ltrim(rtrim(a.emer)),'')='' then 'Pa Plotesuar' else a.emer end,
                'Mbiemer' = case when isnull(ltrim(rtrim(a.mbiemer)),'')='' then 'Pa Plotesuar' else a.mbiemer end,
                pe.datedok as Data,
                'Kod' = case when isnull(ltrim(rtrim(pe.kartllg)),'')= '' then 'Te Mbartura' else pe.kartllg end,
                'Pershkrim' = case when isnull(ltrim(rtrim(pe.pershkrim)),'')='' then 'Shitje te Vjetra' else pe.pershkrim end,
                'Dyqani' = case when isnull(ltrim(rtrim(pe.Dyqani)),'')='' or len(pe.dyqani)<3 then 'Te Mbartura' else pe.Dyqani end,
                'Sasi' = case when isnull(pe.sasi,0)=0 then 1 else pe.sasi end,
                'Vlefta' = case when isnull(pe.vlpatvsh,0)>0 then isnull(pe.vlpatvsh,0) else floor(isnull(pe.pike,0) / ((kt.pikesh)/(kt.lekesh))) end,
                floor(isnull(pe.pike,0)) as Pike 
                 from KARTEANTARESIE..pikeekzistuese as pe left join KARTEANTARESIE..scr as s on s.barcode = pe.barcode 
                 left join KARTEANTARESIE..karta_tip as kt on kt.nrrendor = s.karta_tip 
                 left join KARTEANTARESIE..anetaresim as a on a.nrrendor = s.nrd 
                 where a.nrrendor = @nrd 
                 order by pe.datedok desc
GO
