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
                trunc(next_day(end_date -6, 'SATURDAY')) - start_date -((TO_CHAR(TRUNC(end_date,'IW'),'W') - TO_CHAR(TRUNC(start_date,'IW'),'W'))*2)
                -- day difference minus week difference (start monday) * 2 days
            WHEN 
                to_char(start_date, 'D') IN (7,1) AND to_char(end_date, 'D') IN (7,1)  -- start weekend, end weekend
              THEN
                  ((TO_CHAR(end_date,'IW') - TO_CHAR(start_date,'IW'))) * 5 --return weekdays in between two days
              ELSE 
                end_date-start_date -  ((TRUNC(end_date,'D')-  trunc(start_date,'D'))/7*2) 
          END,2) INTO diff FROM DUAL;
    RETURN diff;
  END WdayDiff;
  
SELECT 
WdayDiff(TO_DATE('20150209 23:00:00','YYYYMMDD HH24:MI:SS'), TO_DATE('20150210 11:00:00','YYYYMMDD HH24:MI:SS')) AS a1_weekday_weeday, 
WdayDiff(TO_DATE('20150202 23:00:00','YYYYMMDD HH24:MI:SS'), TO_DATE('20150210 11:00:00','YYYYMMDD HH24:MI:SS')) AS a2_weekday_weeday_diff_week, 
WdayDiff(TO_DATE('20150213 23:00:00','YYYYMMDD HH24:MI:SS'), TO_DATE('20150215 11:00:00','YYYYMMDD HH24:MI:SS')) AS b1_weekday_weekend, 
WdayDiff(TO_DATE('20150206 23:00:00','YYYYMMDD HH24:MI:SS'), TO_DATE('20150215 11:00:00','YYYYMMDD HH24:MI:SS')) AS b2_weekday_weekend_diff_week,
WdayDiff(TO_DATE('20150214 23:00:00','YYYYMMDD HH24:MI:SS'), TO_DATE('20150216 11:00:00','YYYYMMDD HH24:MI:SS')) AS c1_weekend_weekday, 
WdayDiff(TO_DATE('20150207 23:00:00','YYYYMMDD HH24:MI:SS'), TO_DATE('20150216 11:00:00','YYYYMMDD HH24:MI:SS')) AS c2_weekend_weekday_diff_week,
WdayDiff(TO_DATE('20150214 23:00:00','YYYYMMDD HH24:MI:SS'), TO_DATE('20150215 11:00:00','YYYYMMDD HH24:MI:SS')) AS c1_weekend_weekend, 
WdayDiff(TO_DATE('20150207 23:00:00','YYYYMMDD HH24:MI:SS'), TO_DATE('20150215 11:00:00','YYYYMMDD HH24:MI:SS')) AS c2_weekend_weekend_diff_week
FROM DUAL;  
  
