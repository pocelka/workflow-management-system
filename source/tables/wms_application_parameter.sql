prompt creating table wms_application_parameter...

declare
   l_cnt    pls_integer;
begin
   select count(*) into l_cnt from user_tables where table_name = upper('wms_application_parameter');

   if (l_cnt > 0) then
      execute immediate 'drop table wms_application_parameter cascade constraints purge';
   end if;
end;
/

create table wms_application_parameter(
   id                integer not null,
   application_id    integer not null,
   parameter_id      integer not null,
   parameter_value   varchar2(4000 char)
)
cache;

comment on table wms_application_parameter is 'Stores the application-specific parameters and configuration values used by the applications.';
comment on column wms_application_parameter.id is 'Surrogate key for this table';
comment on column wms_application_parameter.application_id is 'Application to which this parameter belongs.';
comment on column wms_application_parameter.parameter_id is 'Parameter assigned to application.';
comment on column wms_application_parameter.parameter_value is 'The value of the parameter.';

alter table wms_application_parameter add (
   constraint wms_app_param__pk
   primary key (id)
   using index
);

alter table wms_application_parameter add (
   constraint wms_app_param__app_id_fk
   foreign key (application_id)
   references wms_application(id)
);

alter table wms_application_parameter add (
   constraint wms_app_param__param_id_fk
   foreign key (parameter_id)
   references wms_parameter(id)
);

create unique index wms_app_param__uk on wms_application_parameter(application_id, parameter_id);
