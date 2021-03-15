create or replace package wms_proc authid current_user is
   /**
   # Procedure Management

   This package provides utilities and APIs to manage procedures / programs to be executed with WMS framework.
   **/

   procedure create_procedure(
      p_app_alias          in wms_application.alias%type,                                 --Application Alias
      p_statement          in wms_procedure.statement%type,                               --Statement to be executed
      p_proc_name          in wms_procedure.procedure_name%type      default null,        --User defined procedure name
      p_proc_group         in wms_procedure_group.name%type          default 'General',   --Procedure group
      p_enabled            in wms_procedure.enabled%type             default 'Y'          --Enabled / Disabled flag
   );
   /**
   Creates new procedure / program to be used with WMS framework
   **/

end wms_proc;
