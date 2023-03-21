SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[Isd_FrmInfWrite]  -- Vetem ne CONFIG, ska nevoje per FINBAZA
(
 @PAppName Varchar(30),
 @PModName Varchar(30),
 @PFrmName Varchar(30),
 @PPrdName Varchar(30),
 @PTop     Int,
 @PLeft    Int,
 @PHeight  Int,
 @PWidth   Int
)

As

--Declare @PAppName Varchar(30),
--        @PModName Varchar(30),
--        @PFrmName Varchar(30),
--        @PPrdName Varchar(30),
--        @PTop     Int,
--        @PLeft    Int,
--        @PHeight  Int,
--        @PWidth   Int
--    Set @PAppName = 'MAINMP'
--    Set @PModName = 'MAINMP'
--    Set @PFrmName = 'FORMFD'
--    Set @PPrdName = 'ADMIN'
--    Set @PTop     = 35
--    Set @PLeft    = 590
--    Set @PHeight  = 520
--    Set @PWidth   = 800
--Exec CONFIG.dbo.Isd_FrmInfWrite @PAppName='MAINMP', @PModName='MAINMP', @PFrmName='FORMFD', @PPrdName='ADMIN',
--                                @PTop=35, @PLeft=590, @PHeight=520, @PWidth=900


  Set NoCount On

  if not Exists( SELECT NRRENDOR 
                   FROM CONFIG..FRMINF 
                  WHERE APPNAME=@PAppName AND MODNAME=@PModName AND FRMNAME=@PFrmName AND PRDNAME=@PPrdName)
     begin
       INSERT INTO CONFIG..FRMINF
              (APPNAME,MODNAME,FRMNAME,PRDNAME,FRMTOP,FRMLEFT,FRMHEIGHT,FRMWIDTH)
       VALUES (@PAppName,@PModName,@PFrmName,@PPrdName,@PTop,@PLeft,@PHeight,@PWidth)
     end
  else
     begin
       UPDATE CONFIG..FRMINF
          SET FRMTOP=@PTop,FRMLEFT=@PLeft,FRMHEIGHT=@PHeight,FRMWIDTH=@PWidth
        WHERE APPNAME=@PAppName AND MODNAME=@PModName AND FRMNAME=@PFrmName AND PRDNAME=@PPrdName
     end
GO
