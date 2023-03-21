SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[F_TABLE_NUMBER_RANGE]
(
	@START_NUMBER		int,
	@END_NUMBER		int
)
/*
This function returns an integer table containing all integers
in the range of@START_NUMBER through @END_NUMBER, inclusive.
The maximum number of rows that this function can return
is 16777216.
*/

returns table 
as

return
(
select	top 100 percent
	NUMBER = (a.NUMBER+b.NUMBER)+
	-- Add the starting number for the final result set
	-- The case is needed, because the start and end 
	-- numbers can be passed in any order
	case
	when @START_NUMBER <= @END_NUMBER
	then @START_NUMBER
	else @END_NUMBER
	end
from
	(
	Select	top 100 percent
		NUMBER = convert(int,N01+N02+N03)
	From
		-- Cross rows from 3 tables based on powers of 16
		-- Maximum number of rows from cross join is 4096, 0 to 4095
		( select N01 = 0 union all select  1 union all select  2 union all
		  select       3 union all select  4 union all select  5 union all
		  select       6 union all select  7 union all select  8 union all
		  select       9 union all select 10 union all select 11 union all
		  select      12 union all select 13 union all select 14 union all
		  select      15 ) n01
		cross join
		( select N02 = 0 union all select  16 union all select  32 union all
		  select      48 union all select  64 union all select  80 union all
		  select      96 union all select 112 union all select 128 union all
		  select     144 union all select 160 union all select 176 union all
		  select     192 union all select 208 union all select 224 union all
		  select     240 ) n02
		cross join
		( select N03 = 0 union all select  256 union all select  512 union all
		  select     768 union all select 1024 union all select 1280 union all
		  select    1536 union all select 1792 union all select 2048 union all
		  select    2304 union all select 2560 union all select 2816 union all
		  select    3072 union all select 3328 union all select 3584 union all
		  select    3840 ) n03
	where
		-- Minimize the number of rows crossed by selecting only rows
		-- with a value less the the square root of rows needed.
		N01+N02+N03 <
		-- Square root of total rows rounded up to next whole number
		convert(int,ceiling(sqrt(abs(@START_NUMBER-@END_NUMBER)+1)))
	order by
		1
	) a
	cross join
	(
	Select	top 100 percent
		NUMBER = 
		convert(int,
		(N01+N02+N03) *
		-- Square root of total rows rounded up to next whole number
		convert(int,ceiling(sqrt(abs(@START_NUMBER-@END_NUMBER)+1)))
		)
	From 
		-- Cross rows from 3 tables based on powers of 16
		-- Maximum number of rows from cross join is 4096, 0 to 4095
		( select N01 = 0 union all select  1 union all select  2 union all
		  select       3 union all select  4 union all select  5 union all
		  select       6 union all select  7 union all select  8 union all
		  select       9 union all select 10 union all select 11 union all
		  select      12 union all select 13 union all select 14 union all
		  select      15 ) n01
		cross join
		( select N02 = 0 union all select  16 union all select  32 union all
		  select      48 union all select  64 union all select  80 union all
		  select      96 union all select 112 union all select 128 union all
		  select     144 union all select 160 union all select 176 union all
		  select     192 union all select 208 union all select 224 union all
		  select     240 ) n02
		cross join
		( select N03 = 0 union all select  256 union all select  512 union all
		  select     768 union all select 1024 union all select 1280 union all
		  select    1536 union all select 1792 union all select 2048 union all
		  select    2304 union all select 2560 union all select 2816 union all
		  select    3072 union all select 3328 union all select 3584 union all
		  select    3840 ) n03
	where
		-- Minimize the number of rows crossed by selecting only rows
		-- with a value less the the square root of rows needed.
		N01+N02+N03 <
		-- Square root of total rows rounded up to next whole number
		convert(int,ceiling(sqrt(abs(@START_NUMBER-@END_NUMBER)+1)))
	order by
		1
	) b
where
	a.NUMBER+b.NUMBER < 
	-- Total number of rows
	abs(@START_NUMBER-@END_NUMBER)+1	and
	-- Check that the number of rows to be returned
	-- is less than or equal to the maximum of 16777216
	case
	when abs(@START_NUMBER-@END_NUMBER)+1 <= 16777216
	then 1
	else 0
	end = 1
order by
	1
)
GO
