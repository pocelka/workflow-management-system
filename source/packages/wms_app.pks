create or replace package wms_app authid current_user is
   /**
   # Application Management

   This package provides utilities and APIs to manage applications using WMS framework.
   **/

   procedure create_app(
      p_alias        in wms_application.alias%type,                                 --Application alias
      p_name         in wms_application.name%type,                                  --Application name
      p_desc         in wms_application.description%type);                          --Application description
   /**
   Creates a new application to be used with WMS framework
   **/

   function get_app_id(
      p_alias in wms_application.alias%type) return wms_application.id%type;     --Application alias
   /**
   Used to determine application ID based on the specified alias.
   **/

end wms_app;
/
