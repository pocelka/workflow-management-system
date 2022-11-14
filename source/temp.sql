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



condition: "EXT_CUSTOMER" COMPLETED
action: START "EXT_CONTACT"



condition: "EXT_ADDRESS" SUCCEEDED and "EXT_SR" SUCCEEDED and "EXT_CONTACT" SUCCEEDED
action: START "EXT_ASSET"
