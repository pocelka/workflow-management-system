create or replace package body wms_logger as

   c_scope                 constant wms_const.pkg_name := lower($$plsql_unit) || '.';
   c_date_format           constant varchar2(30) := 'DD-MON-YYYY HH24:MI:SS';
   c_timestamp_format      constant varchar2(30) := c_date_format || ':FF';
   c_timezone_format       constant varchar2(30) := c_timestamp_format || ' TZR';

   type t_log_levels is table of pls_integer index by varchar2(30);

   type t_log_setup_rec is record(
      application_id                wms_log.application_id%type,
      procedure_id                  wms_log.procedure_id%type,
      log_level                     wms_log.log_level%type,
      log_parameters                boolean                    default false,
      session_info                  boolean                    default false);

   g_log_setup                      t_log_setup_rec;
   g_log_levels                     t_log_levels;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ PRIVATE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   function get_log_level(
      p_level_name      in varchar2) return wms_log.log_level%type is

   begin

      return g_log_levels(p_level_name);

   end get_log_level;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   function get_parameters(
      p_parameters      in parameters_nt) return clob is

      l_return             clob;
   begin

      l_return := '*** Parameters ***' ||
                  wms_const.c_eol;

      if (p_parameters.count > 0) then

         <<parameters_extraction>>
         for idx in p_parameters.first..p_parameters.last
         loop
            l_return := l_return ||
                        p_parameters(idx).par_name ||
                        ': ' ||
                        p_parameters(idx).par_value ||
                        wms_const.c_eol;
         end loop parameters_extraction;

      else
         l_return := l_return ||
                     'No Parameters Logged';

      end if;

      return l_return;

   end get_parameters;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   /*!
   Is used to get several session level informations
   */
   function get_session_info return varchar2 is

      l_session_info             wms_log.session_info%type;

   begin

      l_session_info := 'Terminal: ' || sys_context('userenv','terminal') || wms_const.c_eol ||
                        'Session ID: ' || sys_context('userenv','sessionid') || wms_const.c_eol ||
                        'Current User: ' || sys_context('userenv','current_user') || wms_const.c_eol ||
                        'Session User: ' || sys_context('userenv','session_user') || wms_const.c_eol ||
                        'DB Name: ' || sys_context('userenv','db_name') || wms_const.c_eol ||
                        'DB Instance: ' || sys_context('userenv','instance') || wms_const.c_eol ||
                        'Host: ' || sys_context('userenv','host') || wms_const.c_eol ||
                        'OS User: ' || sys_context('userenv','os_user') || wms_const.c_eol ||
                        'Client Identifier: ' || sys_context('userenv','client_identifier');

      return l_session_info;

   end get_session_info;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   procedure log_internal(
      p_log_text           in wms_log.log_text%type,                       --Message to be logged
      p_log_type           in wms_log.log_type%type,                       --Log Type
      p_log_level          in wms_log.log_level%type,                      --Log Level
      p_extra              in wms_log.extra%type         default null,     --Extra information to be logged; i.e. information about parameters
      p_call_stack         in wms_log.call_stack%type    default null,     --Call Stack Information
      p_error_stack        in wms_log.error_stack%type   default null,     --Error Stack Information
      p_parameters         in parameters_nt              default c_empty_param_nt) is  --Parameters passed from application
      pragma autonomous_transaction;

      l_session_info          wms_log.session_info%type;
      l_extra                 clob;

   begin

      if (g_log_setup.log_parameters) then
         l_extra := get_parameters(p_parameters => p_parameters);
      end if;

      l_extra := l_extra || p_extra;

      if (g_log_setup.session_info) then
         l_session_info := get_session_info;
      end if;

      insert into wms_log (
         id,
         application_id,
         log_type,
         procedure_id,
         log_text,
         log_level,
         call_stack,
         error_stack,
         session_info,
         extra)
      values (
         wms_log_seq.nextval,             --id
         g_log_setup.application_id,      --application_id
         p_log_type,                      --log_type
         g_log_setup.procedure_id,        --procedure_id
         p_log_text,                      --log_text
         p_log_level,                     --log_level
         p_call_stack,                    --call_stack
         p_error_stack,                   --error_stack
         l_session_info,                  --session_info
         l_extra);                        --extra
      commit;

   end log_internal;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ PUBLIC ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   procedure add_parameter(
      p_params             in out nocopy parameters_nt,
      p_name               in varchar2,
      p_val                in varchar2) is

      l_param              parameter_rec;
   begin

      l_param.par_name := p_name;
      l_param.par_value := p_val;
      p_params(p_params.count + 1) := l_param;

   end add_parameter;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   procedure add_parameter(
      p_params             in out nocopy parameters_nt,
      p_name               in varchar2,
      p_val                in number) is
   begin

      add_parameter(p_params => p_params,
                    p_name => p_name,
                    p_val => to_char(p_val));

   end add_parameter;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   procedure add_parameter(
      p_params             in out nocopy parameters_nt,
      p_name               in varchar2,
      p_val                in date) is
   begin

      add_parameter(p_params => p_params,
                    p_name => p_name,
                    p_val => to_char(p_val, c_date_format));

   end add_parameter;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   procedure add_parameter(
      p_params             in out nocopy parameters_nt,
      p_name               in varchar2,
      p_val                in timestamp) is
   begin

      add_parameter(p_params => p_params,
                    p_name => p_name,
                    p_val => to_char(p_val, c_timestamp_format));

   end add_parameter;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   procedure add_parameter(
      p_params             in out nocopy parameters_nt,
      p_name               in varchar2,
      p_val                in timestamp with time zone) is
   begin

      add_parameter(p_params => p_params,
                    p_name => p_name,
                    p_val => to_char(p_val, c_timezone_format));

   end add_parameter;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   procedure add_parameter(
      p_params             in out nocopy parameters_nt,
      p_name               in varchar2,
      p_val                in timestamp with local time zone) is
   begin

      add_parameter(p_params => p_params,
                    p_name => p_name,
                    p_val => to_char(p_val, c_timezone_format));

   end add_parameter;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   procedure add_parameter(
      p_params             in out nocopy parameters_nt,
      p_name               in varchar2,
      p_val                in boolean) is

      l_val                varchar2(5) := 'FALSE';
   begin

      if (p_val)  then
         l_val := 'TRUE';
      end if;

      add_parameter(p_params => p_params,
                    p_name => p_name,
                    p_val => l_val);

   end add_parameter;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   procedure setup_logging(
      p_app_id          in wms_log.application_id%type,
      p_proc_id         in wms_log.procedure_id%type,
      p_level_name      in varchar2) is

   begin

      g_log_setup.application_id := p_app_id;
      g_log_setup.procedure_id := p_proc_id;
      g_log_setup.log_level := g_log_levels(upper(p_level_name));

      exception
         when no_data_found then
            g_log_setup.log_level := g_log_levels('INFO');

   end setup_logging;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   procedure logging_attributes(
      p_log_parameters     in boolean,
      p_log_session_info   in boolean) is
   begin

      g_log_setup.log_parameters := p_log_parameters;
      g_log_setup.session_info := p_log_session_info;

   end logging_attributes;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   procedure log_msg(
      p_type               in varchar2,
      p_log_text           in wms_log.log_text%type,
      p_log_type           in wms_log.log_type%type,
      p_extra              in wms_log.extra%type,
      p_params             in parameters_nt) is

      l_log_level             wms_log.log_level%type := get_log_level(p_type);

      l_call_stack            wms_const.varchar2_max_sql;
      l_error_stack           wms_const.varchar2_max_sql;

   begin

      if (l_log_level >= g_log_setup.log_level) then

         --for messages on level ERROR or CRITICAL I want to include additional information for debugging purposes
         if (l_log_level >= get_log_level('ERROR')) then
            l_call_stack := substr(sys.dbms_utility.format_call_stack, 1, 4000);
            l_error_stack := substr(sys.dbms_utility.format_error_backtrace, 1, 4000);
         end if;

         log_internal(p_log_text => p_log_text,
                      p_log_type => p_log_type,
                      p_log_level => l_log_level,
                      p_extra => p_extra,
                      p_parameters => p_params,
                      p_call_stack => l_call_stack,
                      p_error_stack => l_error_stack);

      end if;

   end log_msg;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

begin

   g_log_levels('DEBUG') := 10;
   g_log_levels('INFO') := 20;
   g_log_levels('WARNING') := 30;
   g_log_levels('ERROR') := 40;
   g_log_levels('CRITICAL') := 50;

end wms_logger;
