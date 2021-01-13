create or replace package wms_logger authid current_user is
   /**
   # Logging

   This package provides utilities and APIs to for logging purposes.

   This package can be used by applications run through this framework.

   The main features of this instrumentalization are:

   - Multiple levels of errors (DEBUG, INFO, WARNING, ERROR, CRITICAL). Each level has assigned priority. Debug is the
     lowest. Framework will log messages set to the same or bigger level. This means that when user will setup log level
     to DEBUG only debug messages will be logged even if info messages are called. When log level is set-up to INFO,
     both info and debug messages will be logged.
   - Handling of logging input parameters with simple API.

   **/

   -- used to store information about parameters to be logged into log table
   type parameter_rec is record(
      par_name          varchar2(255),                            -- parameter name
      par_value         varchar2(4000));                          -- parameter value

   type parameters_nt is table of parameter_rec index by binary_integer;

   type t_log_level is table of pls_integer index by varchar2(30);

   c_empty_param_nt           parameters_nt;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   procedure add_parameter(
      p_params             in out nocopy parameters_nt,           --List of parameters
      p_name               in varchar2,                           --Parameter name
      p_val                in varchar2);                          --Parameter value
   /**
   This procedure will add text parameter into the list of parameters. This information can be than inserted into log
   table.
   **/

   procedure add_parameter(
      p_params             in out nocopy parameters_nt,           --List of parameters
      p_name               in varchar2,                           --Parameter name
      p_val                in number);                            --Parameter value
   /**
   This procedure will add number parameter into the list of parameters. This information can be than inserted into log
   table.
   **/

   procedure add_parameter(
      p_params             in out nocopy parameters_nt,           --List of parameters
      p_name               in varchar2,                           --Parameter name
      p_val                in date);                              --Parameter value
   /**
   This procedure will add date parameter into the list of parameters. This information can be than inserted into log
   table.
   **/

   procedure add_parameter(
      p_params             in out nocopy parameters_nt,           --List of parameters
      p_name               in varchar2,                           --Parameter name
      p_val                in timestamp);                         --Parameter value
   /**
   This procedure will add timestamp parameter into the list of parameters. This information can be than inserted into
   log table.
   **/

   procedure add_parameter(
      p_params             in out nocopy parameters_nt,           --List of parameters
      p_name               in varchar2,                           --Parameter name
      p_val                in timestamp with time zone);          --Parameter value
   /**
   This procedure will add timestamp with time zone parameter into the list of parameters. This information can be than
   inserted into log table.
   **/

   procedure add_parameter(
      p_params             in out nocopy parameters_nt,           --List of parameters
      p_name               in varchar2,                           --Parameter name
      p_val                in timestamp with local time zone);    --Parameter value
   /**
   This procedure will add timestamp with local time zone parameter into the list of parameters. This information can be
   than inserted into log table.
   **/

   procedure add_parameter(
      p_params             in out nocopy parameters_nt,           --List of parameters
      p_name               in varchar2,                           --Parameter name
      p_val                in boolean);                           --Parameter value
   /**
   This procedure will add boolean parameter into the list of parameters. This information can be than inserted into log
   table.
   **/

   procedure setup_logging(
      p_app_id          in wms_log.application_id%type,                 --Application ID
      p_proc_id         in wms_log.procedure_id%type,                   --Procedure ID
      p_level_name      in varchar2);                                   --Text representation for log level
   /**
   Used to setup global logging parameters. In order to use logging framework user should always call this procedure at
   the beggining.
   **/

   procedure logging_attributes(
      p_log_parameters     in boolean  default false,    --If set to true, parameters added by add_parameter will be logged
      p_log_session_info   in boolean  default false);   --If set to true, session information will be logged
   /**
   Used to setup additional attributes to enhance logging information.
   **/

   procedure log_msg(
      p_type               in varchar2,                                                      --Type for logged message - INFO/WARNING/DEBUG/ERROR/CRITICAL
      p_log_text           in wms_log.log_text%type,                                         --Message to be logged
      p_log_type           in wms_log.log_type%type      default wms_const.c_log_type_user,  --Identification if log row created user application or core framework,
      p_extra              in wms_log.extra%type         default null,                       --Extra information to be logged
      p_params             in parameters_nt              default c_empty_param_nt);          --Information about parameters
   /**
   Logs messages with the specific type level or above log level.
   **/

end wms_logger;
