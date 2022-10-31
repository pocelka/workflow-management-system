whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

set define '&'

set verify off

spool install_dba_create_user.log

prompt
prompt
prompt ====
prompt Workflow Management System - create schema script.
prompt You will be prompted for a username, tablespace, temporary tablespace and password.
prompt ====
prompt
prompt


define wms_owner=wms
accept wms_owner char default &wms_owner prompt 'Name of the WMS schema to create       [&wms_owner] :'

define wms_tablespace=users
accept wms_tablespace char default &wms_tablespace prompt 'Tablespace for the WMS           [&wms_tablespace] :'

define temp_tablespace=TEMP
accept temp_tablespace char default &temp_tablespace prompt 'Temporary Tablespace for the WMS  [&temp_tablespace] :'

accept PASSWD CHAR prompt 'Enter a password for the WMS              [] :' HIDE

create user &wms_owner identified by &PASSWD default tablespace &wms_tablespace temporary tablespace &temp_tablespace;

alter user &wms_owner quota unlimited on &wms_tablespace;

grant
   create session,
   create sequence,
   create procedure,
   create type,
   create table,
   create view,
   create synonym,
   debug connect session,
   alter session,
   create job,
   manage scheduler
to &wms_owner;

grant execute on sys.dbms_lock to &wms_owner;
grant select on sys.v_$session to &wms_owner;
grant execute on sys.dbms_scheduler to &wms_owner;
grant execute on sys.dbms_debug_jdwp to &wms_owner;

begin
   sys.dbms_rule_adm.grant_system_privilege(privilege => sys.dbms_rule_adm.create_rule_set_obj,
                                             grantee => '&wms_owner',
                                             grant_option => false);

   sys.dbms_rule_adm.grant_system_privilege(privilege => sys.dbms_rule_adm.create_evaluation_context_obj,
                                             grantee => '&wms_owner',
                                             grant_option => false);

   sys.dbms_rule_adm.grant_system_privilege(privilege => sys.dbms_rule_adm.create_rule_obj,
                                             grantee => '&wms_owner',
                                             grant_option => false);
end;
/

declare
   l_par_value          v$parameter.value%type;
begin

   select value
   into l_par_value
   from v$parameter
   where 1 = 1
   and name = 'cluster_database';

   if (l_par_value = 'TRUE') then
      execute immediate 'grant select on sys.gv_$session to &wms_owner';
   end if;

   exception
     when no_data_found then
       null;
end;
/

prompt
prompt
prompt ====
prompt User &wms_owner successfully created for Execution Framework
prompt ====
prompt
prompt

spool off

exit
