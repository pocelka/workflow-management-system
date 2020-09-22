prompt creating table wms_parameter...

declare
   l_cnt    pls_integer;
begin
   select count(*) into l_cnt from user_tables where table_name = upper('wms_parameter');

   if (l_cnt > 0) then
      execute immediate 'drop table wms_parameter cascade constraints purge';
   end if;
end;
/

create table wms_parameter (
   id             integer not null,
   name           varchar2(500 char) not null,
   display_name   varchar2(256 char),
   type           varchar2(1 char) not null constraint wms_parameter__type check (type in ('U','F')),
   comments       varchar2(4000 char)
)
cache
;

comment on table wms_parameter is 'Stores the parameters and configuration values used by the applications.';
comment on column wms_parameter.id is 'Surrogate key for this table.';
comment on column wms_parameter.name is 'Unique name of the parameter. Enforcing a unique constraint on this column reduces redundancy.';
comment on column wms_parameter.display_name is 'Optional text used when the parameter is shown in the UI.';
comment on column wms_parameter.type is 'U - User Defined; F - Framework core parameter';
comment on column wms_parameter.comments is 'Any notes about a parameter that have business value.';

alter table wms_parameter add (
   constraint wms_parameter__pk
   primary key (id)
   using index
);

create unique index wms_parameter__param_name on wms_parameter(name);
