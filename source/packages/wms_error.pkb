create or replace package body wms_error as

   c_scope                 constant wms_const.pkg_name := lower($$plsql_unit) || '.';

   g_exceptions                     t_exceptions_list;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ PRIVATE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   /*!
   Is used to parse package specification to get all framework related messages to global variable.
   */
   procedure init_error_messages is

      l_error_code            number;
      l_error_message         exception_message_text;

   begin

      for i in (with
                  cte_exceptions as (select
                                          ltrim(text)                                     as error_code,
                                          lead(ltrim(text), 1, 0) over (order by line)    as error_message
                                       from user_source
                                       where 1 = 1
                                       and name = rtrim(upper(c_scope), '.')
                                       and (ltrim(text) like 'err_wms%'
                                          or ltrim(text) like 'txt_wms%'))
               select *
               from cte_exceptions
               where 1 = 1
               and error_code like 'err_wms%')
      loop

         l_error_code := 0 - regexp_replace(i.error_code, '[^0-9]');
         l_error_message := regexp_substr(i.error_message, '[^"]+', 1, 2);
         l_error_message := replace(l_error_message, q'['']', chr(39));

         g_exceptions(l_error_code) := l_error_message;

      end loop;

   end init_error_messages;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ PUBLIC ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   procedure raise_error(
      p_err_code           in pls_integer,
      p_err_msg_inputs     in t_exception_params      default null,
      p_scope              in logger_logs.scope%type  default null,
      p_params             in logger.tab_param        default logger.gc_empty_tab_param) is

      l_message               exception_message_text;
      l_sql                   varchar(4000);

   begin

      --In case error messages were not yet initialized, we want to initiaze them.
      if (g_exceptions.count = 0) THEN
         init_error_messages;
      end if;

      --We want to determine if we are dealing with user defined exception
      --or some Oracle core exception
      if (not g_exceptions.exists(p_err_code)
            or g_exceptions.exists(p_err_code) is null) then
         l_message := 'ORA' || p_err_code || ': [1]';
      else
         l_message := g_exceptions(p_err_code);
      end if;

      -- replace placeholders
      if (p_err_msg_inputs is not null) then
         for i in 1..p_err_msg_inputs.count
         loop
            l_message := replace(l_message,
                                 '[' || i || ']',
                                 p_err_msg_inputs(i));
         end loop;
      end if;

      logger.log_error(p_text => l_message,
                       p_scope => p_scope,
                       p_extra => null,
                       p_params => p_params);

      --raise error
      if (p_err_code between -20999 and -20000) then
         raise_application_error(p_err_code, l_message, false);
      else
         l_sql := 'declare tmp_exc exception; pragma exception_init(tmp_exc, '
                  || p_err_code
                  || '); begin raise tmp_exc; end;';

         execute immediate l_sql;
      end if;

   end raise_error;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   procedure raise_error(
      p_err_code        in pls_integer,
      p_variable1       in varchar2,
      p_scope           in logger_logs.scope%type,
      p_params          in logger.tab_param) is
   begin
      raise_error(p_err_code => p_err_code,
                  p_err_msg_inputs => t_exception_params(p_variable1),
                  p_scope => p_scope,
                  p_params => p_params);
   end raise_error;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   procedure raise_error(
      p_err_code        in pls_integer,
      p_variable1       in varchar2,
      p_variable2       in varchar2,
      p_scope           in logger_logs.scope%type,
      p_params          in logger.tab_param) is
   begin
      raise_error(p_err_code => p_err_code,
                  p_err_msg_inputs => t_exception_params(p_variable1, p_variable2),
                  p_scope => p_scope,
                  p_params => p_params);
   end raise_error;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   procedure raise_error(
      p_err_msg         in varchar2,
      p_scope           in logger_logs.scope%type,
      p_params          in logger.tab_param) is

      l_error_code         pls_integer;
      l_error_message      exception_message_text;
   begin

      l_error_code := replace(substr(p_err_msg, 1, instr(p_err_msg,':') - 1), 'ORA', null);
      l_error_message := substr(p_err_msg, instr(p_err_msg,':') + 2);

      raise_error(p_err_code => l_error_code,
                  p_err_msg_inputs => t_exception_params(l_error_message),
                  p_scope => p_scope,
                  p_params => p_params);
   end raise_error;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

end wms_error;
