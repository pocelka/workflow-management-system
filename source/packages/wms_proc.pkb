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

   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ PUBLIC ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   procedure create_procedure(
      p_app_alias          in wms_application.alias%type,
      p_statement          in wms_procedure.statement%type,
      p_proc_name          in wms_procedure.procedure_name%type,
      p_proc_group         in wms_procedure.procedure_group%type,
      p_enabled            in wms_procedure.enabled%type) is

      c_proc_name             constant wms_const.proc_name := c_scope || 'create_procedure';

      l_app_id                         wms_application.id%type;
      l_generated_name                 wms_procedure.generated_name%type;

   begin

      l_app_id := wms_app.get_app_id(p_alias => p_app_alias);
      l_generated_name := generate_program_name;

      insert into wms_procedure(
         id,
         application_id,
         procedure_name,
         procedure_group,
         statement,
         enabled,
         generated_name
      )
      values (
         wms_procedure_seq.nextval,
         l_app_id,
         p_proc_name,
         p_proc_group,
         p_statement,
         p_enabled,
         l_generated_name
      );

      commit;

      exception
         when no_data_found then
            wms_error.raise_error(p_err_code => wms_error.err_wms_app_not_found,
                                  p_variable1 => p_app_alias);

         when others then
            wms_error.raise_error(p_err_msg => sqlerrm);
   end create_procedure;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

end wms_proc;
/
