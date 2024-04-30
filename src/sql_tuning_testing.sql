-- P1
-- Question: Write a SQL Query to find all the conferences held in 2018 that have published at least 200 papers in a single decade.

-- P1
-- Query
WITH confs_2018 AS
(SELECT DISTINCT
 booktitle
FROM
 inproceedings
WHERE
 year = '2018'),

paper_counts AS
(SELECT
	inp.booktitle
	, substr(year,3,1) as decade_num
	, count(*) as papers
FROM
 inproceedings inp
INNER JOIN
 confs_2018 c
 ON inp.booktitle = c.booktitle
GROUP BY
	inp.booktitle
	, decade_num)
	
SELECT DISTINCT
	booktitle
FROM
	paper_counts
WHERE
	papers >= 200;

-- P1
-- Index Generation
CREATE INDEX idx_year_inproceedings ON inproceedings(year);

-- P2
-- Write a SQL Query to find all the authors who published at least 10 PVLDB papers and at least 10 SIGMOD papers.
WITH author_sigmod AS
(SELECT
 author
FROM
  inproceedings
WHERE
 booktitle IN ('1999 ACM SIGMOD Workshop on Research Issues in Data Mining and Knowledge Discovery',
			 'ACM SIGMOD Workshop on Research Issues in Data Mining and Knowledge Discovery',
			 'aiDM@SIGMOD','BeyondMR@SIGMOD','BiDEDE@SIGMOD','DanaC@SIGMOD','DataEd@SIGMOD',
			 'DBTest@SIGMOD','DEBT@SIGMOD','DEC@SIGMOD','DEEM@SIGMOD','DSMM@SIGMOD','DyNetMM@SIGMOD',
			 'ExploreDB@SIGMOD/PODS','GeoRich@SIGMOD','GRADES-NDA@SIGMOD','GRADES/NDA@SIGMOD/PODS',
			 'GRADES@SIGMOD/PODS','HILDA@SIGMOD','NDA@SIGMOD','SBD@SIGMOD','SIGMOD Conference',
			 'SIGMOD Conference Companion','SIGMOD PhD Symposium','SIGMOD Workshop, Vol. 1','SIGMOD Workshop, Vol. 2',
			 'SIGMOD/PODS Ph.D. Symposium','SIGMOD/PODS PhD Symposium','SIGSMALL/SIGMOD Symposium',
			 'SiMoD@SIGMOD','SWEET@SIGMOD','SWIM@SIGMOD Conference','VDBS@SIGMOD')
UNION ALL
SELECT
 author
FROM
 article
WHERE
 journal IN ('ACM SIGMOD Anthology','ACM SIGMOD Digit. Rev.','ACM SIGMOD Digit. Symp. Collect.',
			   'FDT Bull. ACM SIGFIDET SIGMOD','SIGMOD Rec.')
),

author_vldb AS
(SELECT
 author
FROM
  inproceedings
WHERE
 booktitle IN ('ADMS/IMDM@VLDB','ADMS@VLDB','AIDB@VLDB','BD3@VLDB','BiDu-Posters@VLDB','BiDU@VLDB',
			   'Big-O(Q)/DMAH@VLDB','BPOE@ASPLOS/VLDB','CDMS@VLDB','CSW@VLDB','Data4U@VLDB',
			   'DBRank@VLDB','DEco@VLDB','DI2KG@VLDB','DMAH@VLDB','IMDM@VLDB','IMDM@VLDB (Revised Selected Papers)',
			   'LADaS@VLDB','MATES@VLDB','PhD@VLDB','Poly/DMAH@VLDB','SEA-Data@VLDB','SFDI/LSGDA@VLDB',
			   'SSW@VLDB','VLDB','VLDB PhD Workshop','VLDB Surveys','VLDB Workshops')
UNION ALL
SELECT
 author
FROM
 article
WHERE
 journal IN ('ACM SIGMOD Anthology','ACM SIGMOD Digit. Rev.','ACM SIGMOD Digit. Symp. Collect.',
			   'FDT Bull. ACM SIGFIDET SIGMOD','SIGMOD Rec.')
),

sigmod_counts AS
(SELECT
 author
FROM
 author_sigmod
GROUP BY
 author
HAVING
 COUNT(*) >= 10
),

vldb_counts AS
(SELECT
 author
FROM
 author_vldb
GROUP BY
 author
HAVING
 COUNT(*) >= 10
)

SELECT
 author
FROM
 sigmod_counts
WHERE
 author IS NOT NULL
INTERSECT
SELECT
 author
FROM
 vldb_counts
LIMIT 20;

-- Index Generation
CREATE INDEX idx_journal_article ON article(journal);
CREATE INDEX idx_booktitle_inproceedings ON inproceedings(booktitle);