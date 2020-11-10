prompt creating table wms_procedure...

declare
   l_cnt    pls_integer;
begin
   select count(*) into l_cnt from user_tables where table_name = upper('wms_procedure');

   if (l_cnt > 0) then
      execute immediate 'drop table wms_procedure cascade constraints purge';
   end if;
end;
/

create table wms_procedure (
   id                integer              not null,
   application_id    integer              not null,
   procedure_name    varchar2(30 char),
   procedure_group   varchar2(50 char),
   statement         varchar2(128 char)   not null,
   enabled           varchar2(1 char)     default 'Y' not null constraint wms_pocedure__enabled check (enabled in ('Y','N')),
   generated_name    varchar2(30 char)    not null
)
cache
;

comment on table wms_procedure is 'Contains list of procedures for given application';
comment on column wms_procedure.id is 'Surrogate key for this table.';
comment on column wms_procedure.application_id is 'FK to wms_application.';
comment on column wms_procedure.procedure_name is 'User defined short name for procedure.';
comment on column wms_procedure.procedure_group is 'Free text to specify to which group procedure belongs. I.e. general, validation, transformation etc. .';
comment on column wms_procedure.statement is 'Statement to be exececuted in WMS.';
comment on column wms_procedure.enabled is 'Indicates whether procedure is enabled / visible.';
comment on column wms_procedure.generated_name is 'Generated unique name for procedure.';

alter table wms_procedure add (
   constraint wms_procedure__pk
   primary key (id)
   using index
);

alter table wms_procedure add (
   constraint wms_procedure__app_id_fk
   foreign key (application_id)
   references wms_application(id)
);

create unique index wms_procedure__generated on wms_procedure(generated_name);
