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
