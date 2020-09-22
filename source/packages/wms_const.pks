create or replace package wms_const authid current_user is

   /**
   Global constants used accross the framework
   **/

   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   -- Constants
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   c_eol                   constant varchar2(5 char) := chr(10);  -- end of line character, used when concatenating values
   c_app_id                constant pls_integer := 0;             -- default Application ID representing framework

   -- Parameter Types
   c_param_user            constant varchar2(1 char) := 'U';      -- parameter defined by user
   c_param_fmw             constant varchar2(1 char) := 'F';      -- core framework parameter

   c_log_type_fmw          constant wms_log.log_type%type := 'F';
   c_log_type_user         constant wms_log.log_type%type := 'U';

   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   -- Generic Subtypes
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   subtype varchar2_max_plsql is varchar2(32767 char);      -- Maximum allowed varchar2 length in PL/SQL
   subtype varchar2_max_sql is varchar2(4000 char);         -- Maximum allowed varchar2 length in SQL
   subtype ora_object_name is varchar2(30 char);            -- Maximum allowed length of oracle objects (pre-12c compatibility)

   subtype pkg_name is varchar2(31 char);                   -- To store information in format <package_name.>
   subtype proc_name is varchar2(61 char);                  -- To store fully qualified procedure name; i.e. in format <package_name.procedure_name>

end wms_const;
