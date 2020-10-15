use D0136_00_Flaven
declare @SQL as nvarchar(max)
declare @meny_import as nvarchar(255)
set @meny_import = 'tblMeny_import2' --Hier de tabelnaam ingeven
-- aanvullen meetreeks en meetpunt
--BEGIN TRAN T1

set @sql = 'update '+ parsename(@meny_import, 1) +'
set [meetreeks] = iif( charindex(''_1_'', meetpunt_import) >0 , LEFT(meetpunt_import, charindex(''_1_'', meetpunt_import)-1), iif( charindex(''_1 '', meetpunt_import) >0 , LEFT(meetpunt_import, charindex(''_1 '', meetpunt_import)-1), meetpunt_import))
	, [meetpunt] = LEFT(meetpunt_import, 7);'
exec(@SQL)

set @SQL = 'update '+ parsename(@meny_import, 1) +'
set [simulatienr] = iif( substring([meetpunt_import], Len([meetpunt_import])-2, 1) = ''('', Left(Right([meetpunt_import],2) ,1), Left(Right([meetpunt_import],3) ,2)) 
where meetpunt_import <> meetreeks ;'
exec(@SQL)

set @SQL = 'update '+ parsename(@meny_import, 1) +'
set [simulatienr] = 0
where [simulatienr] is null;'
exec(@SQL)

set @SQL = 'SELECT Count(*) FROM '+ parsename(@meny_import, 1)
exec(@SQL)

--rollback TRAN T1
--COMMIT TRAN T1




--BEGIN TRAN T1
drop table if exists temp_veldmetingen;
drop table if exists tbl_meetreeksen_sim
drop table if exists temp_veldmetingen_in_simreeks;
drop table if exists temp_nieuwe_veldmetingen;

--tabel met veldmetingen maken

set @SQL = 'select *
into temp_veldmetingen
from '+ parsename(@meny_import, 1) +'
where meetpunt_import = meetreeks'
exec(@SQL)

-- merken van de metingen in de sim-reeksen die overeenstemmen met een veldmeting
set @SQL = 'update bron
set bron.[is_veldmeting] = 1 
from '+ parsename(@meny_import, 1) +' as bron inner join temp_veldmetingen as t on (bron.[meetreeks] = t.[meetreeks] and bron.dag = t.dag)'
exec(@SQL)

set @SQL = 'update bron
set bron.[is_veldmeting] = 0
from '+ parsename(@meny_import, 1) +' as bron 
where bron.[is_veldmeting] IS NULL'
exec(@SQL)

-- tijdelijke tabel van de veldmetingen binnen een sim-reeks maken
set @SQL = 'SELECT bron.meetpunt_import, bron.dag 
INTO temp_veldmetingen_in_simreeks
FROM '+ parsename(@meny_import, 1) +' as bron
WHERE bron.is_veldmeting = 1 and bron.meetpunt_import <> bron.meetreeks'
exec(@SQL)

-- tabel met de simulatiereeksen gekoppeld aan een meetreeks
set @SQL = 'SELECT meetpunt_import, meetreeks 
INTO tbl_meetreeksen_sim
FROM '+ parsename(@meny_import, 1) +'
GROUP BY meetpunt_import, meetreeks;'
exec(@SQL)

DELETE tbl_meetreeksen_sim
WHERE tbl_meetreeksen_sim.meetpunt_import = tbl_meetreeksen_sim.meetreeks

--veldmetingen toevoegen aan simulatiereeksen

set @SQL = 'select count(*)
from '+ parsename(@meny_import, 1) +'
where [is_veldmeting] = 1 '
exec(@SQL)

set @SQL = 'SELECT reeksen.meetpunt_import, metingen.meting_TAW, metingen.meetpunt, metingen.meetreeks, metingen.dag
INTO temp_nieuwe_veldmetingen
FROM tbl_meetreeksen_sim as reeksen INNER JOIN '+ parsename(@meny_import, 1) +' as metingen ON reeksen.meetreeks = metingen.meetpunt_import; '
exec(@SQL)


set @SQL = 'INSERT '+ parsename(@meny_import, 1) +' ( meetpunt_import, meting_TAW, meetpunt, meetreeks, dag, is_veldmeting )
SELECT temp.meetpunt_import, temp.meting_TAW, temp.meetpunt, temp.meetreeks, temp.dag, 1
FROM temp_nieuwe_veldmetingen as temp LEFT JOIN temp_veldmetingen_in_simreeks as veldmetingen
  ON temp.meetpunt_import = veldmetingen.meetpunt_import and temp.dag = veldmetingen.dag
WHERE veldmetingen.dag is null;'
exec(@SQL)


-- markeren van simulatiemetingen die dichter dan 7 dagen liggen t.a.v. een veldmeting (sonde of handmatig).
-- Waarom 7: omdat zo aan een tijdreeks met alleen maandelijkse veldmetingen een tweewekelijkse simulatiemeting wordt toegevoegd (en dan kan voldoen aan het minimum aantalscriterium van 20 metingen per jaar
use D0136_00_Flaven
set @SQL = 'UPDATE men
SET men.is_veldmeting = 0
FROM '+ parsename(@meny_import, 1) +' men
where men.is_veldmeting = -1;'
exec(@SQL)

set @SQL = 'UPDATE men
SET men.is_veldmeting = -1
FROM temp_veldmetingen veld INNER JOIN '+ parsename(@meny_import, 1) +' men ON veld.meetpunt = men.meetpunt
WHERE (men.is_veldmeting = 0) AND (ABS(CONVERT(int, men.dag) - CONVERT(int, veld.dag)) < 7);'
exec(@SQL)

--rollback TRAN T1
--commit TRAN T1

drop table if exists temp_veldmetingen;
drop table if exists tbl_meetreeksen_sim
drop table if exists temp_veldmetingen_in_simreeks;
drop table if exists temp_nieuwe_veldmetingen;