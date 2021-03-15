create or replace package body wms_app as

   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   -- Constants
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   c_scope           constant wms_const.pkg_name := lower($$plsql_unit) || '.';

   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ PRIVATE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ PUBLIC ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   procedure create_app(
      p_alias        in wms_application.alias%type,
      p_name         in wms_application.name%type,
      p_desc         in wms_application.description%type) is

      c_proc_name       constant wms_const.proc_name := c_scope || 'create_app';
      l_params                   logger.tab_param;

      e_app_exists      exception;
      pragma exception_init(e_app_exists, -1);

   begin

      logger.append_param(l_params, 'p_alias', p_alias);
      logger.append_param(l_params, 'p_name', p_name);
      logger.append_param(l_params, 'p_desc', p_desc);

      insert into wms_application (id, alias, name, description)
      values (wms_application_seq.nextval, p_alias, p_name, p_desc);
      commit;

      exception
         when e_app_exists then
            wms_error.raise_error(p_err_code => wms_error.err_wms_app_already_exists,
                                  p_variable1 => p_alias,
                                  p_scope => c_proc_name);

         when others then
            wms_error.raise_error(p_err_msg => sqlerrm,
                                  p_scope => c_proc_name,
                                  p_params => l_params);
   end create_app;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   function get_app_id(
         p_alias in wms_application.alias%type) return wms_application.id%type is

      l_app_id          wms_application.id%type;

   begin

      select id
      into l_app_id
      from wms_application
      where 1 = 1
      and alias = p_alias;

      return l_app_id;

   end get_app_id;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

end wms_app;
