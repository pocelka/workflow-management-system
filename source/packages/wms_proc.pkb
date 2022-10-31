create or replace package body wms_proc as

   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   -- Constants
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   c_scope           constant wms_const.pkg_name := lower($$plsql_unit) || '.';

   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ PRIVATE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   /*!
   This function is used to generate unique name for each procedure. We need this as procedures have to have unique name
   when using Oracle's chain functionality. Without this we can't ensure that two applications won't have the same names.
   */
   function generate_program_name return wms_procedure.generated_name%type is

      l_generated_name        wms_procedure.generated_name%type;
      l_generate              boolean := true;
      l_dummy                 pls_integer;
   begin

      while l_generate
      loop

         --program_name in dbms_scheduler.create_program must be unique in the sql name space
         l_generated_name := dbms_random.string('u', 30);

         --check that generated name is really unique
         select max(1)
         into l_dummy
         from user_objects
         where 1 = 1
         and object_name = l_generated_name;

         if (l_dummy is null) then
            l_generate := false;
         end if;

      end loop generate_name;

      return l_generated_name;

   end generate_program_name;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   /*!
   Procedure is used to create LOV for procedure groups
   */
   function create_procedure_group(
      p_group_name         in wms_procedure_group.name%type) return wms_procedure_group.id%type is

      c_proc_name             constant wms_const.proc_name := c_scope || 'create_procedure_group';
      l_group_id                       wms_procedure_group.id%type;

   begin

      -- TODO: change to begin end block with dup_val_on_index exception block
      select max(id)
      into l_group_id
      from wms_procedure_group
      where 1 = 1
      and name = p_group_name;

      if (l_group_id is null) then
         insert into wms_procedure_group(
            id,
            name)
         values (
            wms_procedure_group_seq.nextval,
            p_group_name)
         returning id into l_group_id;
      end if;

      return l_group_id;

   end create_procedure_group;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ PUBLIC ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   procedure create_procedure(
      p_app_alias          in wms_application.alias%type,
      p_statement          in wms_procedure.statement%type,
      p_proc_name          in wms_procedure.procedure_name%type,
      p_proc_group         in wms_procedure_group.name%type,
      p_enabled            in wms_procedure.enabled%type) is

      c_proc_name             constant wms_const.proc_name := c_scope || 'create_procedure';

      l_params                         logger.tab_param;
      l_app_id                         wms_application.id%type;
      l_generated_name                 wms_procedure.generated_name%type;
      l_group_id                       wms_procedure_group.id%type;

   begin

      logger.append_param(l_params, 'p_app_alias', p_app_alias);
      logger.append_param(l_params, 'p_statement', p_statement);
      logger.append_param(l_params, 'p_proc_name', p_proc_name);
      logger.append_param(l_params, 'p_proc_group', p_proc_group);
      logger.append_param(l_params, 'p_enabled', p_enabled);

      l_app_id := wms_app.get_app_id(p_alias => p_app_alias);
      l_generated_name := generate_program_name;

      if (p_proc_group is not null) then
         l_group_id := create_procedure_group(p_group_name => p_proc_group);
      end if;

      insert into wms_procedure(
         id,
         application_id,
         procedure_name,
         procedure_group_id,
         statement,
         enabled,
         generated_name
      )
      values (
         wms_procedure_seq.nextval,
         l_app_id,
         p_proc_name,
         l_group_id,
         p_statement,
         p_enabled,
         l_generated_name
      );

      commit;

      exception
         when no_data_found then
            wms_error.raise_error(p_err_code => wms_error.err_wms_app_not_found,
                                  p_variable1 => p_app_alias,
                                  p_scope => c_proc_name);

         when others then
            wms_error.raise_error(p_err_msg => sqlerrm,
                                  p_scope => c_proc_name,
                                  p_params => l_params);
   end create_procedure;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

end wms_proc;
