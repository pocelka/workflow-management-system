create or replace package wms_app authid current_user is

   /**
   # Application Management

   This package provides utilities and APIs to manage applications using WMS framework.
   **/

   procedure create_app(
      p_alias        in wms_application.alias%type,                                 -- application alias
      p_name         in wms_application.name%type,                                  -- application name
      p_desc         in wms_application.description%type);                          -- application description
   /**
   Creates a new application to be used with WMS framework
   **/

   function get_app_id(
         p_alias in wms_application.alias%type) return wms_application.id%type;     -- application alias
   /**
   Used to determine application ID based on the specified alias.
   **/

end wms_app;
/
