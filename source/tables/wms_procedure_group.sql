prompt creating table wms_procedure_group...

declare
   l_cnt    pls_integer;
begin
   select count(*) into l_cnt from user_tables where table_name = upper('wms_procedure_group');

   if (l_cnt > 0) then
      execute immediate 'drop table wms_procedure_group cascade constraints purge';
   end if;
end;
/

create table wms_procedure_group (
   id                integer              not null,
   name              varchar2(50 char)    not null
)
cache
;

comment on table wms_procedure_group is 'Contains list of groups which can be assigned to procedures';
comment on column wms_procedure_group.id is 'Surrogate key for this table.';
comment on column wms_procedure_group.name is 'Name of the group; i.e. general, validation, transformation etc.';

alter table wms_procedure_group add (
   constraint wms_procedure_group__pk
   primary key (id)
   using index
);

create unique index wms_procedure_group__name on wms_procedure_group(name);
