package nativetext.events;

import flash.events.Event;

class SoftKeyboardEvent extends Event{

    public static var SOFT_KEYBOARD_ACTIVATE = "nativetext_soft_keyboard_activate";
    public static var SOFT_KEYBOARD_DEACTIVATE = "nativetext_soft_keyboard_deactivate";

    public function new(type:String) {
        super(type);
    }
}
