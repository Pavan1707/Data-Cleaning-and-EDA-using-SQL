-- Data Cleaning
SELECT * FROM pavan.laptopdata;

SELECT count(*) FROM laptopdata;

-- create backup
CREATE TABLE laptops_backup LIKE laptopdata;


INSERT INTO laptops_backup
SELECT * FROM laptopdata;

-- info and memory occupation of table
SELECT DATA_LENGTH/1024  FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'pavan'
AND TABLE_NAME = 'laptopdata';

-- Drop non important columns
-- DROP null values

DELETE FROM laptopdata
WHERE 'index' IN (SELECT 'Index' FROM laptopdata
WHERE Company IS NULL AND TypeName IS NULL AND Inches IS NULL
AND ScreenResolution IS NULL AND Cpu IS NULL AND Ram IS NULL AND 
Memory IS NULL AND Gpu IS NULL AND OpSys IS NULL AND Weight IS NULL AND Price IS NULL);


SELECT COUNT(*) FROM laptopdata;


-- Drop duplicates
SELECT DISTINCT Company FROM laptopdata;

ALTER TABLE laptopdata MODIFY COLUMN Inches DECIMAL(10,1);

UPDATE laptopdata l1
SET Ram = (SELECT REPLACE(Ram,'GB','') FROM laptopdata l2 WHERE l2.index = l1.index);


ALTER TABLE laptopdata MODIFY COLUMN Ram INTEGER;


UPDATE laptopdata l1
SET Weight  = (SELECT REPLACE(Weight,'kg','') FROM laptopdata l2 WHERE l2.index = l1.index);

UPDATE laptopdata l1
SET Price  = (SELECT ROUND(Price) FROM laptopdata l2 WHERE l2.index = l1.index);

ALTER TABLE laptopdata MODIFY COLUMN Price INTEGER;

-- macOS
-- No OS
-- Windows 10
-- Mac OS X
-- Linux
-- Windows 10 S
-- Chrome OS
-- Windows 7
-- Android

SELECT OpSys,
CASE	
    WHEN OpSys LIKE '%mac%' THEN 'macos'
    WHEN OpSys LIKE 'windows%' THEN 'windows'
    WHEN OpSys LIKE '%linux%' THEN 'linux'
    WHEN OpSys = 'No Os' THEN 'N/A'
    ELSE 'other'
END As 'os_brand'
FROM laptopdata;


UPDATE laptopdata 
SET OpSys = 
CASE	
    WHEN OpSys LIKE '%mac%' THEN 'macos'
    WHEN OpSys LIKE 'windows%' THEN 'windows'
    WHEN OpSys LIKE '%linux%' THEN 'linux'
    WHEN OpSys = 'No Os' THEN 'N/A'
    ELSE 'other'
END;

SELECT * FROM laptopdata;



ALTER TABLE laptopdata 
ADD COLUMN Gpu_brand VARCHAR(255) AFTER Gpu,
ADD COLUMN Gpu_nmae VARCHAR(255) AFTER Gpu_brand;


UPDATE laptopdata l1
SET gpu_brand = (SELECT SUBSTRING_INDEX(Gpu,' ',1) FROM laptopdata l2 WHERE l2.index = l1.index);

UPDATE laptopdata l1
SET Gpu_name = (SELECT REPLACE(Gpu,Gpu_brand,'') FROM laptopdata l2 WHERE l2.index = l1.index);


ALTER TABLE laptopdata DROP COLUMN Gpu;





ALTER TABLE laptopdata 
ADD COLUMN cpu_brand VARCHAR(255) AFTER cpu,
ADD COLUMN cpu_name VARCHAR(255) AFTER cpu_brand,
ADD COLUMN cpu_speed DECIMAL(10,1)  AFTER cpu_name;
 
SELECT *  FROM laptopdata;


UPDATE laptopdata l1 
SET cpu_brand = (SELECT SUBSTRING_INDEX(Cpu,' ',1) FROM laptopdata l2
WHERE l2.index = l1.index);



SELECT CAST(REPLACE(SUBSTRING_INDEX(Cpu, ' ' ,-1),'GHz',' ') AS DECIMAL(10,2)) FROM laptopdata;

UPDATE laptopdata l1 
SET cpu_speed = (SELECT CAST(REPLACE(SUBSTRING_INDEX(Cpu, ' ' ,-1),'GHz',' ')
                 AS DECIMAL(10,2)) FROM laptopdata l2 
                 WHERE l2.index = l1.index);


SELECT  REPLACE(REPLACE(Cpu,cpu_brand,' '), SUBSTRING_INDEX(REPLACE(Cpu, cpu_brand,' '),' ',-1),' ') FROM laptopdata;

UPDATE laptopdata l1 
SET cpu_name = (SELECT  REPLACE(REPLACE(Cpu,cpu_brand,' '), SUBSTRING_INDEX(REPLACE(Cpu, cpu_brand,' '),' ',-1),' ')
                FROM laptopdata l2
                 WHERE l2.index = l1.index);



ALTER TABLE laptopdata DROP COLUMN Cpu;

SELECT * FROM laptopdata;


SELECT ScreenResolution,
SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1), 'x',1),
SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1), 'x',-1)
FROM laptopdata;


ALTER TABLE laptopdata ADD COLUMN resolution_width INTEGER AFTER ScreenResolution,
ADD COLUMN resolution_height INTEGER AFTER resolution_width;

SELECT * FROM laptopdata;

UPDATE laptopdata
SET resolution_width = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1), 'x',1),
resolution_height = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1), 'x',-1);

ALTER TABLE laptopdata ADD COLUMN touchscreen INTEGER AFTER resolution_height;

SELECT ScreenResolution LIKE '%Touch%' FROM laptopdata;

UPDATE laptopdata
SET touchscreen =  ScreenResolution LIKE '%Touch%';

SELECT * FROM laptopdata;

ALTER TABLE laptopdata DROP COLUMN ScreenResolution;

SELECT cpu_name, SUBSTRING_INDEX(TRIM(cpu_name),' ',2)
FROM laptopdata;

UPDATE laptopdata 
SET cpu_name = SUBSTRING_INDEX(TRIM(cpu_name),' ',2);

 ALTER TABLE laptopdata
 ADD COLUMN memory_type VARCHAR(255) AFTER Memory,
 ADD COLUMN primary_storage INTEGER  AFTER memory_type,
 ADD COLUMN secondary_storage INTEGER AFTER primary_storage;
 
 
 SELECT Memory, 
 CASE 
     WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
     WHEN Memory LIKE '%SSD%' THEN 'SSD'
     WHEN Memory LIKE '%HDD%'  THEN 'HDD'
     WHEN Memory LIKE '%Flash Storage'THEN 'Flash Storage'
     WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
     WHEN Memory LIKE '%Flash Storage' AND Memory LIKE '%HDD%' THEN 'Hybrid'
     ELSE NULL 
END AS 'memory_type'
FROM laptopdata;


UPDATE laptopdata
SET memory_type = 
 CASE 
     WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
     WHEN Memory LIKE '%SSD%' THEN 'SSD'
     WHEN Memory LIKE '%HDD%'  THEN 'HDD'
     WHEN Memory LIKE '%Flash Storage'THEN 'Flash Storage'
     WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
     WHEN Memory LIKE '%Flash Storage' AND Memory LIKE '%HDD%' THEN 'Hybrid'
     ELSE NULL
 END;
 
 SELECT Memory,
 REGEXP_SUBSTR(SUBSTRING_INDEX(Memory, '+',1),'[0-9]+'),
 CASE 
    WHEN Memory LIKE '%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 
END
FROM laptopdata;

UPDATE laptopdata
SET primary_storage = REGEXP_SUBSTR(SUBSTRING_INDEX(Memory, '+',1),'[0-9]+'),
secondary_storage = CASE 
WHEN Memory LIKE '%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 
END;


SELECT 
primary_storage,
CASE 
    WHEN primary_storage <= 2 THEN primary_storage * 1024 
    ELSE primary_storage END,
secondary_storage,
CASE 
    WHEN  secondary_storage<=2 THEN  secondary_storage*1024
    ELSE secondary_storage END 
FROM laptopdata;

UPDATE laptopdata
SET primary_storage = CASE 
    WHEN primary_storage <= 2 THEN primary_storage * 1024 
    ELSE primary_storage END,
    secondary_storage = CASE 
    WHEN  secondary_storage<=2 THEN  secondary_storage*1024
    ELSE secondary_storage END;


ALTER TABLE laptopdata DROP COLUMN Memory;


SELECT * FROM laptopdata ;
    
ALTER TABLE laptopdata DROP COLUMN gpu_name;


-- Exploratory Data Analysis Using MySQl 

-- Head, tail and sample
 SELECT * FROM laptopdata
 ORDER BY 'Unnamed:0' LIMIT 5;
 
 SELECT * FROM laptopdata
 ORDER BY 'Unnamed:0' DESC LIMIT 5;
 
 SELECT * FROM laptopdata
 ORDER BY rand() LIMIT 5;
 
 -- Analysis on numerical column 'Price'
 SELECT count(Price) OVER(), 
 MIN(Price) OVER(),
 MAX(Price) OVER(),
 AVG(Price) OVER(), 
 STD(Price) OVER(),
 PERCENTILE_COUNT(0.25) WITHIN GROUP(ORDER BY Price) OVER()  AS 'Q1',
 PERCENTILE_COUNT(0.5) WITHIN GROUP(ORDER BY Price) OVER()  AS 'Median',
 PERCENTILE_COUNT(0.75) WITHIN GROUP(ORDER BY Price) OVER()  AS 'Q3'
 FROM laptopdata
 ORDER BY 'Unnamed:0' LIMIT 1;
 
 -- Missing Value check
 SELECT COUNT(Price) FROM laptopdata
 WHERE Price IS NULL;
 
 
-- Outlier Detection
SELECT * FROM (SELECT *, 
PERCENTILE_COUNT(0.25) WITHIN GROUP(ORDER BY Price) OVER()  AS 'Q1',
PERCENTILE_COUNT(0.75) WITHIN GROUP(ORDER BY Price) OVER()  AS 'Q3'
FROM laptopdata)t 
WHERE t.Price < t.Q1-(1.5*(t.Q3-t.Q1)) OR t.Price > t.Q3 +(1.5*(t.Q3-t.Q1));

-- Histogram 
SELECT t.buckets, REPEAT('*',COUNT(*)/5) FROM (SELECT price,
CASE
WHEN price BETWEEN 0 AND 25000 THEN '0-25k'
WHEN price BETWEEN 25001 AND 50000 THEN '25k-50k'
WHEN price BETWEEN 50001 AND 75000 THEN '50k-75k'
WHEN price BETWEEN 75001 AND 100000 THEN '75k-100k'
ELSE '>100k'
END AS 'buckets'
FROM laptopdata) t
GROUP BY t.buckets;


-- categorical columns 
SELECT Company,count(*) FROM laptopdata
GROUP BY Company;


SELECT OpSys,count(*) FROM laptopdata
GROUP BY OpSys;

-- numerical, numerical columns -> scatter plot-> plot using excel
SELECT cpu_speed, Price FROM laptopdata;

-- categorical - categorical columns 

SELECT Company,
SUM(CASE WHEN Touchscreen = 1 THEN 1 ELSE 0 END) AS 'Touchscreen_yes',
SUM(CASE WHEN Touchscreen = 0 THEN 1 ELSE 0 END) AS 'Touchscreen_no'
FROM laptopdata
GROUP BY Company;

-- Dealing with missing values
SELECT * FROM laptopdata
WHERE Price IS NULL;

-- REplace missing values with mean of price
SELECT AVG(price) FROM laptopdata;

UPDATE laptopdata
SET price = (SELECT AVG(price) FROM laptopdata) 
WHERE price IS NULL;

-- Feature Engineering
ALTER TABLE laptopdata ADD COLUMN Screen_size VARCHAR(255) AFTER Inches;

UPDATE laptopdata
SET Screen_size = 
CASE
 WHEN Inches < 14.0  THEN 'samll'
 WHEN Inches >= 14.0 AND Inches < 17.0 THEN 'medium'
 ELSE 'large'
END;

-- One hot Encoding -> on categorical column 
SELECT gpu_brand,
CASE WHEN gpu_brand = 'Intel' THEN 1 ELSE 0  END AS 'intel',
CASE WHEN gpu_brand = 'AMD' THEN 1 ELSE 0  END AS 'Amd',
CASE WHEN gpu_brand = 'nvidia' THEN 1 ELSE 0  END AS 'nvidia',
CASE WHEN gpu_brand = 'arm' THEN 1 ELSE 0  END AS 'arm'
FROM laptopdata;
  
  
  
 
 
 
 
 
 






     
 

