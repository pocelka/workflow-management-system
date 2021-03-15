create or replace package wms_error authid definer is
   /**
   # Error Handling

   This package provides utilities to handle errors through the framework. It is also a single point of referrence for
   exception messages raised through framework.

   Additionally provides an API for raising errors in user defined applications.
   **/

   --2048 bytes is oracle max for custom error message from -20000 to -20999
   subtype exception_message_text is varchar2(2048);                                   --Exception message description.
   type t_exceptions_list is table of exception_message_text index by pls_integer;     --List of all application errors from this package

   subtype exceptions_parameters is varchar2(2048);                                    --Exception parameter values defined in exception as [1], [2] etc.
   type t_exception_params is varray(100) of exceptions_parameters;                    --List of substitution variables/values for exception message parameters

   --I want to define "complete" error specification in package spec, since in the body we have a procedure which will parse
   --this spec and initialize global variable with all exceptions defined in package specification. I assume that if
   --anybody will modify this spec in future he will use the same standards for defining constants.
   --User can define substitution variables which will be replaced during processing raise by defining [1] or [2] in message text.
   wms_default_exception      exception;
   err_wms_default_exception  constant number := -20000;
   txt_wms_default_exception  constant exception_message_text := '"[1]"';
   pragma exception_init(wms_default_exception, -20000);

   wms_app_already_exists     exception;
   err_wms_app_already_exists constant number := -20001;
   txt_wms_app_already_exists constant exception_message_text := '"Application with alias ''[1]'' is already configured in the framework."';
   pragma exception_init(wms_app_already_exists, -20001);

   wms_app_not_found          exception;
   err_wms_app_not_found      constant number := -20002;
   txt_wms_app_not_found      constant exception_message_text := '"Application with alias ''[1]'' does not exist."';
   pragma exception_init(wms_app_not_found, -20002);
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   procedure raise_error(
      p_err_code           in pls_integer,                                                --Error code to be raise; user defined or oracle internal code
      p_err_msg_inputs     in t_exception_params      default null,                       --List of substitution variables for the message text
      p_scope              in logger_logs.scope%type  default null,                       --Procedure in which error occured
      p_params             in logger.tab_param        default logger.gc_empty_tab_param); --Parameters from procedure to be logged
   /**
   Procedure is used to call logging procedure to insert error message into log table. If error code is not defined in
   this framework (from -20000 to -20999) then error code without ORA- prefix is expected.
   **/

   procedure raise_error(
      p_err_code        in pls_integer,                                                   --Error code to be raise; user defined or oracle internal code
      p_variable1       in varchar2,                                                      --Substitution variable 1 for message text
      p_scope           in logger_logs.scope%type     default null,                       --Procedure in which error occured
      p_params          in logger.tab_param           default logger.gc_empty_tab_param); --Parameters from procedure to be logged
   /**
   This is a helper procedure. User will send error code and substitution variable and procedure will call main procedure
   with list of substitution variables.
   **/

   procedure raise_error(
      p_err_code        in pls_integer,                                                   --Error code to be raise; user defined or oracle internal code
      p_variable1       in varchar2,                                                      --Substitution variable 1 for message text
      p_variable2       in varchar2,                                                      --Substitution variable 2 for message text
      p_scope           in logger_logs.scope%type     default null,                       --Procedure in which error occured
      p_params          in logger.tab_param           default logger.gc_empty_tab_param); --Parameters from procedure to be logged
   /**
   This is a helper procedure. User will send error code and substitution variables and procedure will call main procedure
   with list of substitution variables.
   **/

   procedure raise_error(
      p_err_msg         in varchar2,                                                      --Error message containing ORA- prefix
      p_scope           in logger_logs.scope%type     default null,                       --Procedure in which error occured
      p_params          in logger.tab_param           default logger.gc_empty_tab_param); --Parameters from procedure to be logged
   /**
   This is a helper procedure should be used when user wants to send just SQLERRM. Procedure will parse this message and
   it will ensure that the main procedure is called with proper parameters.
   **/

end wms_error;
