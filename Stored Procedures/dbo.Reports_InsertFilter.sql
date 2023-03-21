SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[Reports_InsertFilter]
(
	@ReportId int, 
	@Label varchar(50),
	@InputName varchar(50),
	@InputName2 varchar(50),
	@InputType varchar(50),
	@DefaultValue varchar(50),
	@DefaultValue2 varchar(50),
	@ComparisonField varchar(50),
	@ComparisonField2 varchar(50),
	@Operation varchar(50), 
	@Operation2 varchar(50), 
	@DataSetQuery nvarchar(max),
	@NGroup  int, 
	@NOrder int,
	@DoubleType bit
 )
As
Insert Into [dbo].[ReportsFilters]
           ([ReportId]
           ,[Label]
           ,[InputName]
           ,[InputName2]
           ,[InputType]
           ,[DefaultValue]
           ,[DefaultValue2]
		   ,[ComparisonField]
		   ,[ComparisonField2]
           ,[Operation]
           ,[Operation2]
           ,[DatasetQuery]
           ,[NGroup]
           ,[NOrder]
           ,[DoubleType])
Select      @ReportId
           ,@Label
           ,@InputName
           ,@InputName2
           ,@InputType
           ,@DefaultValue
           ,@DefaultValue2
		   ,@ComparisonField
		   ,@ComparisonField2
           ,@Operation
		   ,@Operation2
           ,@DatasetQuery
           ,@NGroup
           ,@NOrder
           ,@DoubleType
GO
