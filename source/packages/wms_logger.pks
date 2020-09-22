create or replace package wms_logger authid current_user is

   /**
   # Logging

   This package provides utilities and APIs to for logging purposes.
   **/

   type parameter_rec is record(
      par_name          varchar2(255),
      par_value         varchar2(4000));

   type parameters_nt is table of parameter_rec index by binary_integer;

   type t_log_level is table of pls_integer index by varchar2(30);

   c_empty_param_nt           parameters_nt;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   procedure add_parameter(
      p_params             in out nocopy parameters_nt,           --List of parameters
      p_name               in varchar2,                           --Parameter name
      p_val                in varchar2);                          --Parameter value
   /**
   Adds text parameter into the list of parameter values.
   **/

   procedure add_parameter(
      p_params             in out nocopy parameters_nt,           --List of parameters
      p_name               in varchar2,                           --Parameter name
      p_val                in number);                            --Parameter value
   /**
   Adds number parameter into the list of parameter values.
   **/

   procedure add_parameter(
      p_params             in out nocopy parameters_nt,           --List of parameters
      p_name               in varchar2,                           --Parameter name
      p_val                in date);                              --Parameter value
   /**
   Adds date parameter into the list of parameter values.
   **/

   procedure add_parameter(
      p_params             in out nocopy parameters_nt,           --List of parameters
      p_name               in varchar2,                           --Parameter name
      p_val                in timestamp);                         --Parameter value
   /**
   Adds timestamp parameter into the list of parameter values.
   **/

   procedure add_parameter(
      p_params             in out nocopy parameters_nt,           --List of parameters
      p_name               in varchar2,                           --Parameter name
      p_val                in timestamp with time zone);          --Parameter value
   /**
   Adds timestamp with time zone parameter into the list of parameter values.
   **/

   procedure add_parameter(
      p_params             in out nocopy parameters_nt,           --List of parameters
      p_name               in varchar2,                           --Parameter name
      p_val                in timestamp with local time zone);    --Parameter value
   /**
   Adds timestamp with local time zone parameter into the list of parameter values.
   **/

   procedure add_parameter(
      p_params             in out nocopy parameters_nt,           --List of parameters
      p_name               in varchar2,                           --Parameter name
      p_val                in boolean);                           --Parameter value
   /**
   Adds boolean parameter into the list of parameter values.
   **/

   procedure setup_logging(
      p_app_id          in wms_log.application_id%type,                 --Application ID
      p_proc_id         in wms_log.procedure_id%type,                   --Proceudre ID
      p_level_name      in varchar2);                                   --Text representation for log level
   /**
   Used to setup global logging parameters. In order to use logging framework
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
