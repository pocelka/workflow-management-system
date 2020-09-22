prompt creating table wms_log...

declare
   l_cnt    pls_integer;
begin
   select count(*) into l_cnt from user_tables where table_name = upper('wms_log');

   if (l_cnt > 0) then
      execute immediate 'drop table wms_log cascade constraints purge';
   end if;
end;
/

create table wms_log(
   id                   integer not null,
   application_id       integer not null,
   log_type             varchar2(1 char) default 'U' not null,
   log_dt               timestamp with time zone default systimestamp not null,
   procedure_id         varchar2(128 char),
   log_text             varchar2(4000 char),
   log_level            integer not null,
   extra                clob,
   session_info         varchar2(4000 char),
   error_stack          varchar2(4000 char),
   call_stack           varchar2(4000 char)
)
;

comment on table  wms_log is 'Logging table. All logging goes to this table by default.';
comment on column wms_log.id is 'Surrogate key for this table.';
comment on column wms_log.application_id is 'FK to WMS_APPLICATIONS. The application which "owns" the logged row.';
comment on column wms_log.log_type is 'Identifies who logged message. U - User; F - Framework';
comment on column wms_log.log_dt is 'Timestamp of log entry.';
comment on column wms_log.log_text is 'Column of free-form text for logging, debugging and informational/context recording.';
comment on column wms_log.log_level is 'This column classifies the log/message entries in varying degrees of severity.';
comment on column wms_log.call_stack is 'The full call stack. Content may vary depending on Oracle 11g / 12c+';
comment on column wms_log.error_stack is 'The full error stack and backtrace. Will be empty if no error is present at the time of logging.';
comment on column wms_log.session_info is 'Information: Optional usefull identifiers for the end user.';
comment on column wms_log.extra is 'Dedicated information which did not fit standard columns.';

alter table wms_log add(
   constraint wms_log__pk
   primary key (id)
   using index
);


alter table wms_log add(
   constraint wms_log__app_id_fk
   foreign key (application_id)
   references wms_application(id)
);

create index wms_log__app_id on wms_log(application_id);
