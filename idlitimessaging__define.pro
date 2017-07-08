; $Id: //depot/idl/releases/IDL_80/idldir/lib/itools/framework/idlitimessaging__define.pro#1 $
;
; Copyright (c) 2000-2010, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;----------------------------------------------------------------------------
;+
; CLASS_NAME:
;   IDLitIMessaging
;
; PURPOSE:
;   This file implements the set of methods that provide a consistent
;   programming interface to the iTools developer. The methods
;   defined by this class are always available as methods on the
;   exposed framework classes.
;
;   It is intended that other framework objects will sub-class from
;   this and thus provide this simple messaging interface to the
;   framework user. This class should not be created directly.
;
; CATEGORY:
;   IDL Tools
;
; SUPERCLASSES:
;    None.
;-
;---------------------------------------------------------------------------
; Lifecycle Routines
;---------------------------------------------------------------------------
; IDLitIMessaging::Init
;
; Purpose:
;   Constructor for this class.
;
; Parameters:
;   None.
;
; Keywords:
;   TOOL   - Used to pass in the tool object for this interface.
;
function IDLitIMessaging::Init, TOOL=TOOL

    compile_opt idl2, hidden

    if (keyword_set(TOOL)) then begin
        self.__oTool  = TOOL
        self.tool = TOOL
    endif

    return, 1
end


;---------------------------------------------------------------------------
; Methods to get/set tool
;---------------------------------------------------------------------------
; IDLitIMessaging::_SetTool
;
; Purpose:
;   Called by the framework internals to set the tool that this
;   interface can communcate with. Without this connection
;   established, nothing (well, almost nothing) will operate in this
;   class.
;
;   At the object interface exposed to the user, they are not aware
;   of this method. This is normally called by the object description
;   system when framework objects are accessed/created.
;
; Parameters
;    oTool    - The operating environment for this session
;
PRO IDLitIMessaging::_SetTool, oTool
    compile_opt idl2, hidden

    self.__oTool = oTool
    self.tool = oTool
end


;---------------------------------------------------------------------------
; IDLitIMessaging::GetTool
;
; Purpose:
;    Used to get access to the Tool object.
;
; Parameters:
;    None.
;
; Keywords:
;    None.
;
; Return Value:
;   - The tool object or NULL if the tool hasn't been registered.
;
function IDLitIMessaging::GetTool

    compile_opt idl2, hidden

    return, self.__oTool
end


;---------------------------------------------------------------------------
; IDLitIMessaging::DoOnNotify
;
; Purpose:
;    Used to send OnNotify messages to the Tool object. When called,
;    this will trigger the broadcast of OnNotify messages in the tool
;    object hierarchy at and the UI level.
;
; Parameters:
;    strID      - ID of the tool item that had its state change.
;
;    message    - The type of message sent.
;
;    messparam  - A parameter that is assocaited with the message.
;
; Keywords:
;    None.
;
pro IDLitIMessaging::DoOnNotify, strID, messageIn, uvalue

    compile_opt idl2, hidden

    if (OBJ_VALID(self.__oTool)) then $
        self.__oTool->DoOnNotify, strID, messageIn, uvalue
end


;-------------------------------------------------------------------------
; IDLitIMessaging::PromptUserYesNo
;
; Purpose:
;   High level method that can be called to trigger an interactive
;   "boolean" prompt of the user.
;
; Return Value
;    0 - Error
;    1 - okay
;
; Parameters:
;    strPrompt  - The prompt for the user
;
;    Title      - I title for the UI. It's use is up to the UI.
;
;    answer     - Output 0 -> no, 1 - yes
;
function IDLitIMessaging::PromptUserYesNo, strPrompt, TITLE=TITLE, answer, $
    _REF_EXTRA=_extra


   compile_opt idl2, hidden

@idlit_catch
   if(iErr ne 0)then begin
       catch, /cancel
       return,0
   end
   if(n_elements(title) eq 0)then title = "Prompt"

   if(not obj_valid(self.__oTool))then $
     return, 0

   ; fill in a prompt object and send it to the UI
   oMsg = obj_new("IDLitPrompt", $
        TITLE=TITLE, PROMPT=strPrompt, _EXTRA=_extra)

   iStatus = self.__oTool->SendMessageToUI(oMsg)
   if(iStatus ne 1)then begin
       obj_destroy,oMsg
       ; Log an error here
       return, 0
   endif
   oMsg->getProperty, ANSWER=answer
   obj_destroy,oMsg

   return, 1
end


;-------------------------------------------------------------------------
; IDLitIMessaging::PromptUserText
;
; Purpose:
;   High level method that can be called to trigger an interactive
;   "text" prompt of the user
;
; Return Value
;    0 - Error
;    1 - okay
;
; Parameters:
;    strPrompt  - The prompt for the user
;
;    answer     - the answer entered by the user
;
; Keyword:
;    Title      - Title for the UI. It's use is up to the UI.
;
function IDLitIMessaging::PromptUserText, strPrompt, TITLE=TITLE, answer

   compile_opt idl2, hidden

   if(not obj_valid(self.__oTool))then $
     return, 0

@idlit_catch
   if(iErr ne 0)then begin
       catch, /cancel
       return,0
   end
   if(n_elements(title) eq 0)then title = "Prompt"

   ; fill in a prompt object and send it to the UI
   oMsg = obj_new("IDLitPromptText", TITLE=TITLE, PROMPT=strPrompt)

   iStatus = self.__oTool->SendMessageToUI(oMsg)
   if(iStatus ne 1)then begin
       obj_destroy,oMsg
       ; Log an error here
       return, iStatus
   endif
   oMsg->getProperty, ANSWER=answer
   obj_destroy,oMsg

   return, 1
end


;-------------------------------------------------------------------------
; IDLitIMessaging::ErrorMessage
;
; Purpose:
;    Abstracted routine to post an synch. error message to the
;    user. When called, the message is propagated to the UI.
;
;    When this method returns, the user has ack'd the error message.
;
;  Paramaters:
;    strMessage   - The error message
;
;  Keywords
;    TITLE      - The title for the error presentation.
;
;    SEVERITY   - The severity of the message.
;                   0 - Informational
;                   1 - Warning
;                   2 - Error
;
;    USE_LAST_ERROR - Use the error registered with the system.
;
PRO IDLitIMessaging::ErrorMessage, strMessage, TITLE=TITLE, $
                       SEVERITY=SEVERITY, USE_LAST_ERROR=use_last

   compile_opt idl2, hidden

   if(not obj_valid(self.__oTool))then $
     return

   ; Use the last error?
   if(keyword_set(USE_LAST))then begin
       self.__oTool->GetLastErrorInfo, description=lastmessage, $
                                       severity=lastseverity

       if(keyword_set(lastmessage))then $
         strMessage=lastmessage

       if(n_elements(lastseverity) gt 0)then $
         severity = lastseverity
   endif

   if(n_elements(severity) eq 0)then severity = 0

    if (N_ELEMENTS(title) eq 0) then begin
        case severity of
            1: title = IDLitLangCatQuery('Error:Warning:Title')
            2: title = IDLitLangCatQuery('Error:Error:Title')
            else: title = IDLitLangCatQuery('Error:Message:Title')
        endcase
    endif

   ; fill in a prompt object and send it to the UI
   oMsg = obj_new("IDLitError", description=strMessage, $
                  message=title, severity=severity)

   iStatus = self.__oTool->SendMessageToUI(oMsg)
   obj_destroy, oMsg

   if(iStatus ne 1)then begin
       self->IDLitIMessaging::SignalError, $
        IDLitLangCatQuery('Error:Framework:ErrorMessage')
   endif

end


;-------------------------------------------------------------------------
; IDLitIMessaging::StatusMessage
;
; Purpose:
;    Abstracted routine to post a status message. When called,
;    the message is propagated to the UI and any other location that
;    is interested in status messages.
;
;
;  Paramaters:
;    strMessage   - The error message
;
;  Keywords:
;    SEGMENT_IDENTIFIER - Set this keyword to a string representing
;      the identifier of the status bar segment in which the message
;      is to be displayed.  The default is 'MESSAGE'.
;
PRO IDLitIMessaging::StatusMessage, strMessage, $
    SEGMENT_IDENTIFIER=segmentIdentifier


   compile_opt idl2, hidden

@idlit_catch
   if(iErr ne 0)then begin
       catch, /cancel
       return
   end
   if (~obj_valid(self.__oTool)) then $
     return

    self.__oTool->DoOnNotify, $
        self.__oTool->GetFullIdentifier() + '/STATUS_BAR/' + $
        (KEYWORD_SET(segmentIdentifier) ? segmentIdentifier : 'MESSAGE'), $
        'MESSAGE', strMessage
end


;-------------------------------------------------------------------------
; IDLitIMessaging::ProbeStatusMessage
;
; Purpose:
;    Abstracted routine to post a data status message. When called,
;    the message is propagated to the UI and any other location that
;    is interested in status messages.
;
;    Normally this is used to communicate data location ..etc
;
;  Paramaters:
;    strMessage   - The error message
;
PRO IDLitIMessaging::ProbeStatusMessage, strMessage


   compile_opt idl2, hidden

@idlit_catch
   if(iErr ne 0)then begin
       catch, /cancel
       return
   end

    if (~obj_valid(self.__oTool)) then $
        return

    self.__oTool->DoOnNotify, $
        self.__oTool->GetFullIdentifier() + '/STATUS_BAR/PROBE', $
        'MESSAGE', strMessage

end


;---------------------------------------------------------------------------
; IDLitIMessaging::ProgressBar
;
; Purpose:
;    Used to cause the system to display and update a progress bar.
;
; Parameters:
;   strMsg   - The message to be displayed in the progress bar.
;
; Keywords:
;    PERCENT  - The amount of progress to show in the bar.
;
;    SHUTDOWN - If set, the progress bar is shutdown (or destroyed)
;               if it is present.
;
function IDLitIMessaging::ProgressBar, strMsg, _REF_EXTRA=_extra

    compile_opt idl2, hidden

@idlit_catch
    if (iErr ne 0) then begin
        catch, /cancel
        return, 0
    end

    if (~OBJ_VALID(self.__oTool)) then $
        return, 0

    return, self.__oTool->ProgressBar(strMsg, _EXTRA=_extra)

end


;-------------------------------------------------------------------------
; IDLitIMessaging::SignalError
;
; Purpose:
;   Used to set an error in the system.
;
;  Paramaters:
;    strMessage   - The error message
;
;  Keywords
;    CODE       - An error code
;
;    SEVERITY   - The severity of the message.
;                   0 - Informational
;                   1 - Warning
;                   2 - Error
;
PRO IDLitIMessaging::SignalError, strMessage, $
                   code=code, severity=severity, _EXTRA=_extra


   compile_opt idl2, hidden

@idlit_catch
   if(iErr ne 0)then begin
       catch, /cancel
       return
   end
   if(not keyword_set(code))then code =0
   if(not keyword_set(severity))then severity =0

   self.__oTool->_SetError, code=code, severity=severity, $
     DESCRIPTION=(keyword_set(strMessage) ? strMessage : ""), $
     _extra=_extra

end


;---------------------------------------------------------------------------
; IDLitIMessaging::AddOnNotifyObserver
;
; Purpose:
;   Used to register as being interested in receiving notifications
;   from a specific identifier.
;
; Parameters:
;    strObID       - Identifier of the observer object
;
;    strID         - The identifier of the object that it is
;                    interested in.
;
pro IDLitIMessaging::AddOnNotifyObserver, strObID, strID

   compile_opt idl2, hidden
   if(obj_valid(self.__oTool))then $
     self.__oTool->AddOnNotifyObserver, strObID, strID

end


;---------------------------------------------------------------------------
; IDLitIMessaging::RemoveOnNotifyObserver
;
; Purpose:
;   Remove an entry from the OnNotify dispatch table.
;
; Parameters:
;    strObID       - Id of the observer
;
;    strID         - The identifier of the object that it is
;                    interested in.
;
pro IDLitIMessaging::RemoveOnNotifyObserver, strObID, strID

   compile_opt idl2, hidden
   if(obj_valid(self.__oTool))then $
     self.__oTool->RemoveOnNotifyObserver, strObID, strID
end


;---------------------------------------------------------------------------
; IDLitIMessaging::OnNotify
;
; Purpose:
;   A notification callback stub. This routine defines what this
;   routine looks like.
;
; Parameters:
;   strID    - The identifier of the underlying tool
;
;   message  - The message that is being sent.
;
;   userdata - Data associated with the message

pro IDLitIMessaging::OnNotify, strID, message, userdata
   compile_opt hidden, idl2

; no-op
end


;---------------------------------------------------------------------------
; IDLitMessaging__define
;
; Define the class
;
pro IDLitIMessaging__define

    compile_opt idl2, hidden

    void = {IDLitIMessaging, $
        __oTool : obj_new() }
end
