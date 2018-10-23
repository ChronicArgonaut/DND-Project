--(LocalDb)\MSSQLLocalDB

CREATE DATABASE DND
GO
--Drop Database DND

USE DND
GO

CREATE TABLE MonsterBase (MonsterID UNIQUEIDENTIFIER Not Null, name varchar(50),type varchar(20),alignment varchar(20),size varchar(20), CR dec(6,3), AC varchar (10), Hp varchar (10), [Exp] int, [Spellcasting?] varchar(3), page varchar(20), book varchar(100), ChangedDate Datetime default CURRENT_TIMESTAMP, Primary Key (MonsterID))
GO
CREATE INDEX NameIndex on MonsterBase(name)
GO

--Drop Table MonsterBase

CREATE TABLE MonsterStats (MonsterID UNIQUEIDENTIFIER FOREIGN KEY REFERENCES MonsterBase(MonsterID), STR int, DEX int, CON int, INT int, WIS int, CHA int, ChangedDate Datetime default CURRENT_TIMESTAMP)
GO
CREATE CLUSTERED INDEX IDIndex on MonsterStats(MonsterID)
GO 

--Drop Table MonsterStats

CREATE TABLE MonsterLocations (MonsterID UNIQUEIDENTIFIER FOREIGN KEY REFERENCES MonsterBase(MonsterID), Arctic varchar(3), coast varchar(3), desert varchar(3), forest varchar(3), grassland varchar(3), hill varchar(3), mountain varchar(3), swamp varchar(3), underdark varchar(3), underwater varchar(3), urban varchar(3),ChangedDate Datetime default CURRENT_TIMESTAMP)
GO
CREATE CLUSTERED INDEX IDIndex on MonsterLocations(MonsterID)
GO 

--Drop Table MonsterLocations

CREATE TABLE MonsterAttacks (MonsterID UNIQUEIDENTIFIER  FOREIGN KEY REFERENCES MonsterBase(MonsterID), AttackName varchar(100), ToHit int, AttackDamage varchar(100),ChangedDate Datetime default CURRENT_TIMESTAMP)
GO
CREATE CLUSTERED INDEX IDIndex on MonsterAttacks(MonsterID)
go

create view MonsterAllView(MonsterID ,NAME ,Type,Alignment ,Size,CR,AC, HP, [Exp],[Spellcasting?],STR,DEX,CON,INT,WIS,CHA ,Attack1,Attack2 ,book,page,Arctic,Coast,desert,forest,grassland,hill,mountain,swamp,underdark,underwater,urban)
as
Select mb.MonsterID,mb.NAME,mb.Type,mb.Alignment,mb.Size,mb.CR,mb.AC,mb.HP,mb.Exp,mb.[Spellcasting?],ms.STR,ms.DEX,ms.CON,ms.INT,ms.WIS,ms.CHA,a1.Attack1,a2.Attack2,mb.book,mb.page,ml.Arctic,ml.Coast,ml.desert,ml.forest,ml.grassland,ml.hill,ml.mountain,ml.swamp,ml.underdark,ml.underwater,ml.urban  from dnd.dbo.MonsterBase mb (nolock)
join dnd.dbo.MonsterLocations ml (nolock)
on mb.MonsterID=ml.MonsterID
join dnd.dbo.MonsterStats MS (nolock)
on mb.MonsterID=MS.MonsterID
left join (Select  MonsterID, min(AttackDamage) as Attack1 from dnd.dbo.monsterattacks (nolock)
group by monsterid) as A1
on A1.MonsterID=MB.MonsterID
Left Join (Select  MonsterID, max(AttackDamage) as Attack2 from dnd.dbo.monsterattacks (nolock)
group by monsterid) as A2
on A2.MonsterID=mb.MonsterID
go

Create Table Backgrounds ([Name] varchar(100), Book varchar(100), Skills varchar(150), Languages varchar(100), Tools varchar(100))

Create Table dnd.dbo.ExpToCR (CR dec(6,3), Exp int)

Create Table dnd.dbo.ExpDiffMultiplier (NumCreatures int, Multiplier dec(3,1))
go


create trigger dbo.UpdateTimestampMB on dbo.monsterbase
After Update
as
Update mb
Set ChangedDate=getdate()
from MonsterBase mb
join inserted i on i.monsterid=mb.monsterid
GO

create trigger dbo.UpdateTimestampMA on dbo.MonsterAttacks
After Update
as
Update ma
Set ChangedDate=getdate()
from MonsterAttacks mA
join inserted i on i.monsterid=ma.monsterid
GO

create trigger dbo.UpdateTimestampMS on dbo.MonsterStats
After Update
as
Update ms
Set ChangedDate=getdate()
from MonsterStats ms
join inserted i on i.monsterid=ms.monsterid
go

create trigger dbo.UpdateTimestampML on dbo.MonsterLocations
After Update
as
Update ML
Set ChangedDate=getdate()
from MonsterLocations ml
join inserted i on i.monsterid=ml.monsterid
go



/*
use master
Drop Database DND
Drop Table dnd.dbo.MonsterBase
Drop Table dnd.dbo.MonsterAttacks
Drop Table dnd.dbo.MonsterLocations
Drop Table dnd.dbo.MonsterAttacks
Drop Table dnd.dbo.Backgrounds
*/



--use dnd
--SELECT 
--     sysobjects.name AS trigger_name 
--    ,USER_NAME(sysobjects.uid) AS trigger_owner 
--    ,s.name AS table_schema 
--    ,OBJECT_NAME(parent_obj) AS table_name 
--    ,OBJECTPROPERTY( id, 'ExecIsUpdateTrigger') AS isupdate 
--    ,OBJECTPROPERTY( id, 'ExecIsDeleteTrigger') AS isdelete 
--    ,OBJECTPROPERTY( id, 'ExecIsInsertTrigger') AS isinsert 
--    ,OBJECTPROPERTY( id, 'ExecIsAfterTrigger') AS isafter 
--    ,OBJECTPROPERTY( id, 'ExecIsInsteadOfTrigger') AS isinsteadof 
--    ,OBJECTPROPERTY(id, 'ExecIsTriggerDisabled') AS [disabled] 
--FROM sysobjects 

--INNER JOIN sysusers 
--    ON sysobjects.uid = sysusers.uid 

--INNER JOIN sys.tables t 
--    ON sysobjects.parent_obj = t.object_id 

--INNER JOIN sys.schemas s 
--    ON t.schema_id = s.schema_id 

--WHERE sysobjects.type = 'TR'