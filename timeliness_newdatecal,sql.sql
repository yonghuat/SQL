CREATE OR REPLACE FUNCTION WdayDiff(start_date IN DATE, end_date IN DATE)
  RETURN  number 
IS 
  diff number;
  BEGIN 
    SELECT ROUND(CASE 
            WHEN  to_char(start_date, 'D') IN (7,1) AND to_char(end_date, 'D') NOT IN (7,1)  -- start weekend, end weekday
              THEN 
                end_date -trunc(next_day(start_date, 'MONDAY'))  
                 - ( (TRUNC(end_date,'D') - TRUNC(next_day(start_date, 'MONDAY'),'D'))/7*2)
            WHEN to_char(start_date, 'D') NOT IN (7,1) AND to_char(end_date, 'D') IN (7,1)  -- start weekday, end weekend
              THEN
                trunc(next_day(end_date -6, 'SATURDAY')) - start_date 
                - ((TRUNC(end_date,'IW') - TRUNC(start_date,'IW'))/7 * 2)
                
                -- day difference minus week difference (start monday) * 2 days
            WHEN 
                to_char(start_date, 'D') IN (7,1) AND to_char(end_date, 'D') IN (7,1)  -- start weekend, end weekend
              THEN
                  ((TRUNC(end_date,'IW') - TRUNC(start_date,'IW'))/7 * 5)--return weekdays in between two days
              ELSE 
                end_date-start_date -  ((TRUNC(end_date,'D')-  trunc(start_date,'D'))/7*2) 
          END,2) INTO diff FROM DUAL;
    RETURN diff;
  END WdayDiff;
  
SELECT 
WdayDiff(TO_DATE('20150209 23:00:00','YYYYMMDD HH24:MI:SS'), TO_DATE('20150210 11:00:00','YYYYMMDD HH24:MI:SS')) 
  AS a1_wkday_wkday, --starts weekday, ends weekday
WdayDiff(TO_DATE('20141230 23:00:00','YYYYMMDD HH24:MI:SS'), TO_DATE('20150106 11:00:00','YYYYMMDD HH24:MI:SS')) 
  AS a2_wkday_wkday_week,  -- starts weekday, ends weekday, different week
WdayDiff(TO_DATE('20150213 23:00:00','YYYYMMDD HH24:MI:SS'), TO_DATE('20150215 11:00:00','YYYYMMDD HH24:MI:SS')) 
  AS b1_wkday_wkend, --starts weekday, ends weekend
WdayDiff(TO_DATE('20141230 23:00:00','YYYYMMDD HH24:MI:SS'), TO_DATE('20150110 11:00:00','YYYYMMDD HH24:MI:SS')) 
  AS b2_wkday_wkendweek, --starts weekday, ends weekend, different week
WdayDiff(TO_DATE('20150214 23:00:00','YYYYMMDD HH24:MI:SS'), TO_DATE('20150216 11:00:00','YYYYMMDD HH24:MI:SS')) 
  AS c1_wkend_wkday,  --starts weekend, ends weekday
WdayDiff(TO_DATE('20141227 23:00:00','YYYYMMDD HH24:MI:SS'), TO_DATE('20150102 11:00:00','YYYYMMDD HH24:MI:SS')) 
  AS c2_wkend_wkday_week, --starts weekend, ends weekday, different week
WdayDiff(TO_DATE('20150214 23:00:00','YYYYMMDD HH24:MI:SS'), TO_DATE('20150215 11:00:00','YYYYMMDD HH24:MI:SS')) 
  AS d1_wkend_wkend,  --starts weekend, ends weekend
WdayDiff(TO_DATE('20141227 23:00:00','YYYYMMDD HH24:MI:SS'), TO_DATE('20150111 11:00:00','YYYYMMDD HH24:MI:SS')) 
  AS d2_wkend_wkend_week --starts weekend, ends weekend, different week
FROM DUAL;  

SELECT 
  assets.workflow_id,
  asins.sample_id,
  assets.asset_id,
  assets.marketplace_id,
  assets.marketplace_name,
  assets.studio,
  assets.gl_product_group_id AS gl_id,
  assets.gl_product_group_name AS gl_name,
  assets.category,
  assets.subcategory,
  assets.asin,
  asins.transfer_request, 
  asins.received AS p2_received, -- received into p2
  assets.retouch_requested_first,--uploaded for retouch added 1/6/2014
  assets.publication_pending_first, -- submitted by retouch
  assets.published_first, -- p2 has received notification that the asset was published to MSA
  wdaydiff(asins.received, assets.retouch_requested_first) AS studio_cycle_time,
  wdaydiff(assets.retouch_requested_first, assets.publication_pending_first) AS retouch_cycle_time,
  wdaydiff(assets.publication_pending_first, assets.published_first) AS publish_cycle_time,
  wdaydiff(asins.received,assets.published_first) AS imaging_cycle_time
FROM picture2_ddl.d_photo_studio_assets assets 
JOIN picture2_ddl.d_photo_studio_asins asins 
  ON asins.workflow_id = assets.workflow_id
WHERE 
asset_type = 'IMAGE_ASSET'
AND assets.variant IN ('MAIN','GLMR')
AND assets.source_type_id IN (5400,5405)
AND assets.erroneous IS NULL
AND (assets.problem IS NULL OR assets.problem < assets.published_first) 
AND asins.received IS NOT NULL 
AND assets.retouch_requested_first IS NOT NULL 
AND assets.publication_pending_first IS NOT NULL ;
