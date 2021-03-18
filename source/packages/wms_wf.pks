create or replace package wms_wf authid current_user is
   /**
   # Workflow Management

   This package provides utilities and APIs to manage workflows.
   **/

   procedure create_workflow(
      p_app_alias          in wms_application.alias%type,
      p_wf_name            in wms_workflow.name%type,
      p_desc_text          in wms_workflow.desc_text%type);
   /**
   Procedure is used to create new workflow for application.
   **/

   function get_wf_id(
      p_app_alias          in wms_application.alias%type,                           --Application alias
      p_wf_name            in wms_workflow.name%type) return wms_workflow.id%type;  --Workflow name
   /**
   Used to determine application ID based on the specified alias.
   **/
end wms_wf;
