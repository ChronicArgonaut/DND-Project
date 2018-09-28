Declare  @Rolls Table (Num int)
Declare  @Final Table (Stat int)
Declare @Counter int = 6

while @Counter > 0
Begin

Insert into @Rolls
Select convert(int,rand() * 6) + 1
Insert into @Rolls
Select convert(int,rand() * 6) + 1
Insert into @Rolls
Select convert(int,rand() * 6) + 1
Insert into @Rolls
Select convert(int,rand() * 6) + 1

Delete top (1) from @Rolls
where Num = (Select min(num) from @Rolls)

Insert into @Final
Select Sum(num) from @Rolls

Delete from @Rolls

set @Counter = @Counter - 1

End

Select * from @Final
