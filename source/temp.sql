begin
   app_test;
end;
/


truncate table wms_log;

select *
from wms_log
where 1 = 1
order by 1 desc
;
