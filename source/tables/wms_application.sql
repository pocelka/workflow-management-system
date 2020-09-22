prompt creating table wms_application...

declare
   l_cnt    pls_integer;
begin
   select count(*) into l_cnt from user_tables where table_name = upper('wms_application');

   if (l_cnt > 0) then
      execute immediate 'drop table wms_application cascade constraints purge';
   end if;
end;
/

create table wms_application(
   id                integer not null,
   alias             varchar2(30 char) not null,
   name              varchar2(100 char) not null,
   description       varchar2(4000 char) not null
)
cache;

comment on table wms_application is 'List of the applications that should be used by the framework.';
comment on column wms_application.id is 'Surrogate key for this table.';
comment on column wms_application.alias is 'Short alias that represents application. Used to logicaly separate records in the framework tables.';
comment on column wms_application.name is 'Descriptive name for the application.';
comment on column wms_application.description is 'In-depth description of the application, its purpose, sponsors, information stewards, etc.';

alter table wms_application add (
   constraint wms_application__pk
   primary key (id)
   using index
);

create unique index wms_application__alias on wms_application(alias);
create unique index wms_application__name on wms_application(name);
