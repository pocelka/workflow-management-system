prompt creating table wms_workflow...

declare
   l_cnt    pls_integer;
begin
   select count(*) into l_cnt from user_tables where table_name = upper('wms_workflow');

   if (l_cnt > 0) then
      execute immediate 'drop table wms_workflow cascade constraints purge';
   end if;
end;
/

create table wms_workflow (
   id                   integer              not null,
   application_id       integer              not null,
   name                 varchar2(30 byte)    not null,
   desc_text            varchar2(4000 byte)
)
cache
;

comment on table wms_workflow is 'Contains list of defined workflows for given application';
comment on column wms_workflow.id is 'Surrogate key for this table.';
comment on column wms_workflow.application_id is 'FK to wms_application.';
comment on column wms_workflow.name is 'Workflow name.';
comment on column wms_workflow.desc_text is 'Text describing workflow.';


alter table wms_workflow add (
   constraint wms_workflow__pk
   primary key (id)
   using index
);

alter table wms_workflow add (
   constraint wms_workflow__app_id_fk
   foreign key (application_id)
   references wms_application(id)
);

create unique index wms_workflow__name on wms_workflow(name);
create index wms_workflow__app_id on wms_workflow(application_id);
