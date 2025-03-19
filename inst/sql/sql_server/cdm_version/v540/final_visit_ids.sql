
if object_id('@cdm_schema.FINAL_VISIT_IDS', 'U') is not null drop table @cdm_schema.FINAL_VISIT_IDS;

CREATE TABLE @cdm_schema.FINAL_VISIT_IDS
(
	encounter_id varchar(1000),
	VISIT_OCCURRENCE_ID_NEW int
)

insert into @cdm_schema.FINAL_VISIT_IDS
(
	encounter_id,
	VISIT_OCCURRENCE_ID_NEW
)
SELECT encounter_id, VISIT_OCCURRENCE_ID_NEW
FROM (
SELECT *,
    ROW_NUMBER() OVER (PARTITION BY encounter_id ORDER BY PRIORITY) AS RN
FROM (
    SELECT *,
        CASE
            WHEN encounterclass IN ('emergency', 'urgent') THEN
                CASE
                    WHEN VISIT_TYPE = 'inpatient' AND VISIT_OCCURRENCE_ID_NEW IS NOT NULL THEN 1
                    WHEN VISIT_TYPE IN ('emergency', 'urgent') AND VISIT_OCCURRENCE_ID_NEW IS NOT NULL THEN 2
                    ELSE 99
                END
            WHEN encounterclass IN ('ambulatory', 'wellness', 'outpatient') THEN
                CASE
                    WHEN VISIT_TYPE = 'inpatient' AND VISIT_OCCURRENCE_ID_NEW IS NOT NULL THEN 1
                    WHEN VISIT_TYPE IN ('ambulatory', 'wellness', 'outpatient') AND VISIT_OCCURRENCE_ID_NEW IS NOT NULL THEN 2
                    ELSE 99
                END
            WHEN encounterclass = 'inpatient' AND VISIT_TYPE = 'inpatient' AND VISIT_OCCURRENCE_ID_NEW IS NOT NULL THEN 1
            ELSE 99
        END AS PRIORITY
    FROM @cdm_schema.ASSIGN_ALL_VISIT_IDS
) T1
) RankedVisits
WHERE RN = 1;
