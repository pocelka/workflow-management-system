create or replace package body wms_wf as

   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   -- Constants
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   c_scope           constant wms_const.pkg_name := lower($$plsql_unit) || '.';

   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ PRIVATE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ PUBLIC ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   procedure create_workflow(
      p_app_alias          in wms_application.alias%type,
      p_wf_name            in wms_workflow.name%type,
      p_desc_text          in wms_workflow.desc_text%type) is

      e_already_exists        exception;
      pragma exception_init(e_already_exists, -1);

      c_proc_name             constant wms_const.proc_name := c_scope || 'create_workflow';

      l_params                         logger.tab_param;
      l_app_id                         wms_application.id%type;

   begin

      logger.append_param(l_params, 'p_app_alias', p_app_alias);
      logger.append_param(l_params, 'p_wf_name', p_wf_name);

      l_app_id := wms_app.get_app_id(p_alias => p_app_alias);

      insert into wms_workflow(
         id,
         application_id,
         name,
         desc_text
      )
      values (
         wms_workflow_seq.nextval,
         l_app_id,
         p_wf_name,
         p_desc_text
      );

      commit;

      exception
         when no_data_found then
            wms_error.raise_error(p_err_code => wms_error.err_wms_app_not_found,
                                  p_variable1 => p_app_alias,
                                  p_scope => c_proc_name);

         when e_already_exists then
            wms_error.raise_error(p_err_code => wms_error.err_wms_wf_already_exists,
                                  p_variable1 => p_app_alias,
                                  p_scope => c_proc_name);

         when others then
            wms_error.raise_error(p_err_msg => sqlerrm,
                                  p_scope => c_proc_name,
                                  p_params => l_params);
   end create_workflow;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   function get_wf_id(
      p_app_alias          in wms_application.alias%type,                           --Application alias
      p_wf_name            in wms_workflow.name%type) return wms_workflow.id%type is

      l_wf_id                 wms_workflow.id%type;
      l_app_id                wms_application.id%type;

   begin

      l_app_id := wms_app.get_app_id(p_alias => p_app_alias);

      select id
      into l_wf_id
      from wms_workflow
      where 1 = 1
      and application_id = l_app_id
      and name = p_wf_name;

      return l_wf_id;

   end get_wf_id;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

end wms_wf;
