-- P1
--/*Question: Write a SQL Query to find all the conferences held in 2018 that have published at least 200 papers in a single decade.*/

--/*Query:*/
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

--/*Indexing:*/
CREATE INDEX idx_year_inproceedings ON inproceedings(year);
CREATE INDEX idx_booktitledec_inproceedings ON inproceedings(booktitle, substr(year,3,1))

--/*Cleanup:*/
DROP INDEX idx_year_inproceedings;
DROP INDEX idx_booktitledec_inproceedings;

-- P2
--/*Question: Write a SQL Query to find all the authors who published at least 10 PVLDB papers and at least 10 SIGMOD papers.*/

--/*Query:*/
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
 vldb_counts;

--/*Indexing:*/
CREATE INDEX idx_journal_article ON article(journal);
CREATE INDEX idx_booktitle_inproceedings ON inproceedings(booktitle);

--/*Cleanup:*/
DROP INDEX idx_journal_article;
DROP INDEX idx_booktitle_inproceedings;

-- P3
--/*Question: Write a SQL Query to find the total number of conference publications for each decade, starting from 1970 and ending in 2019.*/

--/*Query:*/
WITH decs AS
(SELECT
	SUBSTR(year, 3, 1) AS decade
FROM
	proceedings),
	
dec_counts AS
(SELECT
	decade
	, COUNT(*)
FROM decs
GROUP BY decade)

SELECT * FROM dec_counts WHERE decade IN ('7','8','9','0','1');

--/*Indexing:*/
CREATE INDEX idx_decade_proceedings ON proceedings(substr(year,3,1));

--/*Cleanup:*/
DROP INDEX idx_decade_proceedings;

-- P4
--/*Question: Write a SQL Query to find the top 10 authors publishing in journals and conferences whose titles contain the word data.*/

--/*Query:*/
WITH authors_article AS
(SELECT
 author
FROM
 article
WHERE
 TO_TSVECTOR('simple', title) @@ TO_TSQUERY('data')
 AND author IS NOT NULL),
 
authors_conf AS
(SELECT
 author
FROM
 inproceedings
WHERE
 TO_TSVECTOR('simple', title) @@ TO_TSQUERY('data')
 AND author IS NOT NULL),

authors_combined AS
(SELECT * FROM authors_article UNION ALL
SELECT * FROM authors_conf),

paper_counts AS
(SELECT
 author
 , COUNT(*) AS papers
FROM
 authors_combined
GROUP BY
 author)
 
SELECT * FROM paper_counts WHERE author IS NOT NULL ORDER BY papers DESC LIMIT 10;

--/*Indexing:*/
CREATE INDEX idx_title_article ON article USING GIN (TO_TSVECTOR('simple', title));
CREATE INDEX idx_title_inproceedings ON inproceedings USING GIN (TO_TSVECTOR('simple', title));

--/*Cleanup:*/
DROP INDEX idx_title_article;
DROP INDEX idx_title_inproceedings;

-- P5
--/*Question: Write a SQL query to find the names of all conferences, happening in June, where the proceedings contain more than 100 publications.*/

--/*Query:*/
WITH june_conf_papers AS
(SELECT 
 a.title
FROM
 proceedings a
INNER JOIN
 inproceedings b
 ON a.booktitle = b.booktitle
 AND a.year = b.year
WHERE
 TO_TSVECTOR('simple', a.title) @@ TO_TSQUERY('june')
),

paper_counts AS
(SELECT
 title
 , COUNT(*) AS papers
FROM
 june_conf_papers
GROUP BY
 title
)

SELECT * FROM paper_counts WHERE papers >= 100
LIMIT 10;

--/*Indexing:*/
CREATE INDEX idx_booktitle_proceedings ON proceedings(booktitle);
CREATE INDEX idx_booktitle_inproceedings ON inproceedings(booktitle);

--/*Cleanup:*/
DROP INDEX idx_booktitle_proceedings;
DROP INDEX idx_booktitle_inproceedings;