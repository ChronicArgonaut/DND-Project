use DND
Go

Create Table #MonstersFinal (MonsterID uniqueidentifier, CR dec(6,3),Counter int, [Exp] Int)
Create Table #CRS (CR varchar(100))

Declare @MaxCR Dec(6,3)
Declare @counter int = 1
Declare @MaxCounter int
Declare @Locations varchar(500)
Declare @ExplicitCreatures varchar(1000)
Declare @CRsToExclude varchar (100)
Declare @AlignmentsToExclude varchar (100)
Declare @SQL1 varchar(max)=''
Declare @SQL2 varchar(max)=''
Declare @CR Dec(6,3)
Declare @TypesToExclude varchar(100)
Declare @MonstersToExclude varchar(200)
Declare @ExplicitTypes varchar(100)
Declare @MaxExp int
Declare @Exp int
Declare @PartyLevel int
Declare @ExpCalc int
Declare @ExpVar varchar (100)
Declare @MonsterCount int



-------------------------------------------------------------------

--Set @MaxCR =20
Set @PartyLevel=10
Set @Locations=''
Set @ExplicitCreatures = ''
Set @ExplicitTypes =''
Set @CRsToExclude='0,1/8,1/4'
Set @AlignmentsToExclude=''
Set @TypesToExclude =''
Set @MonstersToExclude = 'Humanoid'
Set @Maxcounter = 14


-------------------------------------------------------------------




Set @MaxExp =(select [exp] from dnd.dbo.ExpToCR E (nolock)
where CR = case when @PartyLevel = 1 then 0.175 when @PartyLevel = 2 then 0.250 when @PartyLevel = 3 then 0.500 when @PartyLevel > 3 then @PartyLevel -3 end)

Set @ExpCalc = @MaxExp

Set @MaxExp = @MaxExp + (@MaxExp * (rand() * - 4)/5) 



Select * into #MonsterList from MonsterAllView (nolock) 

Set @Exp=@MaxExp

Set @CRsToExclude=replace(Replace(Replace(@CRsToExclude,'1/8','0.125'),'1/4','0.250'),'1/2','0.500')

If @TypesToExclude !=''
Begin
Delete ml 
from #MonsterList ml
cross apply STRING_SPLIT(@TypesToExclude, ',') SS
where  ss.value=ml.type-- in (SELECT Value FROM STRING_SPLIT(@TypesToExclude, ','))
end

If @ExplicitTypes!='' and exists(select * from MonsterBase where type in (SELECT Value FROM STRING_SPLIT(@ExplicitTypes, ',')))
Begin
Delete from #MonsterList

Insert into #MonsterList
Select MV.* from MonsterAllView MV
Cross APply STRING_SPLIT(@ExplicitTypes, ',') SS
WHere MV.type =SS.Value
End

If @CRsToExclude !=''  and exists(select * from MonsterBase where CR in (SELECT convert(decimal(6,3),Value) FROM STRING_SPLIT(@CrsToExclude, ',')))
Begin
Delete ML
from #MonsterList ML
cross apply STRING_SPLIT(@CrsToExclude, ',') as SS
where ML.CR= convert(decimal(6,3),SS.Value) 
end

SELECT Value as [Alignment] into #Alignments FROM STRING_SPLIT(@AlignmentsToExclude, ',')

Select I.COLUMN_NAME as [Location] into #Locations from dnd.INFORMATION_SCHEMA.COLUMNS I(nolock)
Cross apply STRING_SPLIT(@Locations,',') as S where I.COLUMN_NAME=S.Value
and I.COLUMN_NAME Not in ('MonsterID','CreatedDate') and I.TABLE_NAME='MonsterLocations'

Select @Sql1 +='
Delete from #MonsterList
where CHARINDEX('''+[Alignment]+''',Alignment,1)>0
' from #Alignments

Exec (@Sql1)

If @Locations!='' 
Begin
Select @Sql2 += 'Delete from #MonsterList
where '+[Location]+' = ''No''
' from #Locations
end

Exec (@Sql2)



If @MonstersToExclude !=''
Begin
Delete ML
from #MonsterList ML
Cross Apply STRING_SPLIT(@MonstersToExclude, ',') as SS
where  ML.Name=SS.Value
end

If @ExplicitCreatures!=''
Begin
Insert into #MonstersFinal
Select MV.Monsterid, MV.CR, '0',[Exp] from MonsterAllView MV (nolock)
Cross Apply STRING_SPLIT(@ExplicitCreatures, ',') SS
where MV.name = ss.Value 

Set @Exp = @MaxExp - (Select isnull(sum(Exp),0) from #MonstersFinal)
End

While @Exp > 0 and @Counter < @MaxCounter
Begin

Insert into #MonstersFinal
Select top 1 MonsterId, CR, @Counter as [Counter],[Exp]  from #MonsterList (nolock)
where [Exp] <= @Exp
Order by newid()

Set @Exp = @Exp - (Select Top 1 [Exp] from #MonstersFinal order by Counter desc)

Set @Counter = @Counter + 1

End

If @MaxExp>=(select sum(isnull(Exp,0)) from #MonstersFinal)
Select t.counter,MV.* from #MonstersFinal t (nolock)
join dnd.dbo.monsterallview MV (nolock)
on t.MonsterID=MV.MonsterID
else
select 'oops'

Set @MonsterCount=(Select Count(*) from #MonstersFinal)

Set @ExpCalc = (Select (e.multiplier * @MaxExp) from  dnd.dbo.ExpDiffMultiplier E
where e.NumCreatures = @MonsterCount) 

Select 'Encounter is ' + convert(varchar(100),convert(dec (8,2),@ExpCalc)/[EXP] * 100) + '% of a level '+ convert(varchar(100),@PartyLevel) + ' party Encounter' from dnd.dbo.ExpToCR CR
where CR = case when @PartyLevel = 1 then 0.175 when @PartyLevel = 2 then 0.250 when @PartyLevel = 3 then 0.500 when @PartyLevel > 3 then @PartyLevel -3 end



Drop Table #MonstersFinal
Drop Table #MonsterList
Drop Table #CRS
Drop table #Alignments
Drop table #Locations



