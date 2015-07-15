/*
 Copyright aswing.org, see the LICENCE.txt.
*/

package org.aswing;


import haxe.Timer;
import nativetext.event.NativeTextEvent;
import org.aswing.geom.IntPoint;
import nativetext.NativeTextFieldReturnKeyType;
import nativetext.NativeTextFieldKeyboardType;
import nativetext.NativeTextFieldAlignment;
import nativetext.NativeTextFieldConfig;
import nativetext.NativeTextField;
import org.aswing.event.AWEvent;
import motion.easing.Linear;
import motion.Actuate;
import org.aswing.event.FocusKeyEvent;
import flash.events.FocusEvent;
import flash.events.Event;
import flash.events.TextEvent;
import flash.display.InteractiveObject;
import org.aswing.error.Error;
#if(flash9)
import flash.events.TextEvent;
#end
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;

import org.aswing.AWKeyboard;

import org.aswing.geom.IntDimension;
import org.aswing.geom.IntRectangle;

/**
 * JTextComponent is the base class for text components. 
 * <p>
 * <code>JTextComponent</code> can be formated by <code>ASFont</code>, 
 * but some times you need complex format,then <code>ASFont</code> is 
 * not enough, so you can set a <code>EmptyFont</code> instance to the 
 * <code>JTextComponent</code>, it will do nothing for the format, then 
 * you can call <code>this.setTextFormat</code>, <code>this.defaultTextFormat</code>
 * to format the text with <code>TextFormat</code> instances. And don't forgot 
 * to call <code>Component.revalidate</code> if you think the component size should be
 * change after that. Because these method will not call <code>Component.revalidate</code>
 * automatically.
 * </p>
 * 
 * @author paling
 * @see #setTextFormat()
 * @see EmptyFont
 * @see JTextField
 * @see JTextArea
 */
class JTextComponent extends Component  implements EditableComponent{

    /**
	 * The internal <code>TextField</code> instance.
	 */
	public var textField(default, null):TextField;

    public var nativeTextField: NativeTextField;

    public var keyboardType(get, set): NativeTextFieldKeyboardType;
    private var _keyboardType: NativeTextFieldKeyboardType;
    private function get_keyboardType(): NativeTextFieldKeyboardType {
        return _keyboardType;
    }
    private function set_keyboardType(v: NativeTextFieldKeyboardType): NativeTextFieldKeyboardType {
        _keyboardType = v;
        if (null != nativeTextField) {
            nativeTextField.Configure({ keyboardType: _keyboardType });
        }
        return v;
    }

    @bindable public var nativeTextFieldVisibility(get, set): Bool;
    private var _nativeTextFieldVisibility: Bool;
    private function get_nativeTextFieldVisibility(): Bool { return _nativeTextFieldVisibility; }
    private function set_nativeTextFieldVisibility(v: Bool): Bool {
        _nativeTextFieldVisibility = v;
        updateNativeTextFieldVisibility();
        return v;
    }
    private function updateNativeTextFieldVisibility() {
        nativeTextField.Configure({visible: nativeTextFieldVisibility && visible && isOnStage()});
    }
	/**
    * @see TextField.wordWrap
    **/
    public var wordWrap(get, set): Bool;
    private function get_wordWrap(): Bool { return isWordWrap(); }
    private function set_wordWrap(v: Bool): Bool { setWordWrap(v); return v; }

    /**
    * @see TextField.defaultTextFormat
    **/
    public var defaultTextFormat(get, set): TextFormat;
    private var _defaultTextFormat: TextFormat;
    private function get_defaultTextFormat(): TextFormat { return getDefaultTextFormat(); }
    private function set_defaultTextFormat(v: TextFormat): TextFormat { setDefaultTextFormat(v); return v; }

    public var editable(get, set): Bool;
    private var _editable: Bool;
    private function get_editable(): Bool { return isEditable(); }
    private function set_editable(v: Bool): Bool { setEditable(v); return v; }
	
	private var columnWidth:Int;
	private var rowHeight:Int;
	private var widthMargin:Int;
	private var heightMargin:Int;
	private var columnRowCounted:Bool;

	@bindable public var text(get, set): String;
    private function get_text(): String { return getText();  }
    private function set_text(val: String): String { setText(val); return val; }

    public var htmlText(get, set): String;
    private var _htmlText: String;
    private function get_htmlText(): String { return getHtmlText(); }
    private function set_htmlText(v: String): String { setHtmlText(v); return v; }

    /**
    * @see TextField.displayAsPassword
    **/
    public var displayAsPassword(get, set): Bool;
    private function get_displayAsPassword(): Bool { return isDisplayAsPassword(); }
    private function set_displayAsPassword(v: Bool): Bool { setDisplayAsPassword(v); return v; }

    /**
    * @see TextField.length
    **/
    public var length(get, null): Int;
    private function get_length(): Int { return getLength(); }

    /**
    * @see TextField.maxChars
    **/
    public var maxChars(get, set): Int;
    private function get_maxChars(): Int { return getMaxChars(); }
    private function set_maxChars(v: Int): Int { setMaxChars(v); return v; }

    /**
    * @see TextField.restrict
    **/
    public var restrict(get, set): String;
    private function get_restrict(): String { return getRestrict(); }
    private function set_restrict(v: String): String { setRestrict(v); return v; }

    /**
    * @see TextField.selectionBeginIndex
    **/
    public var selectionBeginIndex(get, null): Int;
    private function get_selectionBeginIndex(): Int { return getSelectionBeginIndex(); }

    /**
    * @see TextField.selectionEndIndex
    **/
    public var selectionEndIndex(get, null): Int;
    private function get_selectionEndIndex(): Int { return getSelectionEndIndex(); }

    public function new(){
		super();
		
		textField = new TextField();
		textField.type = TextFieldType.INPUT;
		textField.autoSize = TextFieldAutoSize.NONE;
		textField.background = false;
		_editable = true;
		columnRowCounted = false;
		//addChild(textField);

        textField.addEventListener(Event.CHANGE, function(e) {
            bindx.Bind.notify(this.text);
        });

        keyboardType = NativeTextFieldKeyboardType.Default;

        var config:NativeTextFieldConfig = {
            x: 0,
            y: 0,
            width: 0,
            height: 0,
            visible: false,
            enabled: true,
            placeholder: "",
            fontSize: 36,
            fontColor: 0x333333,
            textAlignment: NativeTextFieldAlignment.Left,
            keyboardType: _keyboardType,
            returnKeyType: NativeTextFieldReturnKeyType.Default
        };

        nativeTextField = new NativeTextField(config);
        nativeTextField.addEventListener(NativeTextEvent.CHANGE, function(e) {
            Timer.delay(function() {
                bindx.Bind.notify(this.text);
            }, 10); });

        nativeTextField.addEventListener(NativeTextEvent.FOCUS_IN, function(e) { requestFocus(); });

        addEventListener(Event.ADDED_TO_STAGE, function(e) {
            updateNativeTextFieldVisibility();
        });

        addEventListener(Event.REMOVED_FROM_STAGE, function(e) {
            updateNativeTextFieldVisibility();
        });

        addEventListener(AWEvent.FOCUS_GAINED, function(e) {
            nativeTextField.SetFocus();
            doFocusTransition();
        });

        addEventListener(AWEvent.FOCUS_LOST, function(e) {
            nativeTextField.ClearFocus();
            doFocusTransition();
        });

        #if(flash9)
        textField.addEventListener(TextEvent.TEXT_INPUT, __onTextComponentTextInput);
        #end
	}

    inline private function updateTextForeground() {
        var color: ASColor = foreground;
        if (!editable || !enabled) {
            color = color.offsetHLS(0, 0.4, -0.5);
        }
        textField.textColor = color.rgb;
        if (null != nativeTextField) {
            nativeTextField.Configure({
                fontColor: color.rgb
            });
        }
    }

    @:dox(hide)
	public function setDefaultTextFormat(dtf:TextFormat):Void{
	 	getTextField().defaultTextFormat = dtf;
        nativeTextField.Configure({
            fontSize: Std.int(dtf.size),
            fontColor: dtf.color
        });
	}

    @:dox(hide)
	public function getDefaultTextFormat():TextFormat{
		return getTextField().defaultTextFormat;
	}

	@:dox(hide)
    public function setWordWrap(b:Bool):Void{
		getTextField().wordWrap = b;
		if(isAutoSize()){
			revalidate();
		}
	}

    @:dox(hide)
	public function isWordWrap():Bool{
		return getTextField().wordWrap;
	}
	 
	/**
	 * Returns the internal <code>TextField</code> instance.
	 * @return the internal <code>TextField</code> instance.
	 */
    @:dox(hide)
	public function getTextField():TextField{
		return textField;
	}
	
	/**
	 * Subclass override this method to do right counting.
	 */
	private function isAutoSize():Bool{
		return false;
	}
	
	@:dox(hide)
    override public function setEnabled(b:Bool):Void{
        super.setEnabled(b);
		getTextField().selectable = b;
		getTextField().mouseEnabled = b;
        nativeTextField.Configure({enabled: _editable && _enabled});
        updateTextForeground();
	}
	
	@:dox(hide)
    public function setEditable(b:Bool):Void {
	 
		if(b != _editable){
			_editable = b;
			if(b)	{
				getTextField().type = TextFieldType.INPUT;
			}else{
				getTextField().type = TextFieldType.DYNAMIC;
			}
            updateTextForeground();
			invalidate();
			invalidateColumnRowSize();
			repaint();
		}
        nativeTextField.Configure({enabled: _editable && _enabled});
    }
	
	@:dox(hide)
    public function isEditable():Bool {
		return _editable;
	}
		/**
	 * Sets the default textFormat to the text.
	 * <p>
	 * You should set a <code>EmptyFont</code> instance to be the component 
	 * font before this call to make sure the textFormat will be effective.
	 * </p>
	 * @param dtf the default textformat.
	 * @see #setFont()
	 */
	/**
	 * Sets the font to the text component.
	 * @param f the font.
	 * @see EmptyFont
	 */
    @:dox(hide)
	override public function setFont(f:ASFont):Void {
	#if (flash9 || cpp || html5)
		super.setFont(f);
		setFontValidated(true);
		if (getFont() != null) {
			getFont().apply(getTextField());
            if (nativeTextField != null) {
                nativeTextField.Configure({
                    fontSize: font.size,
                    fontAsset: font.family
                });
            }
			invalidateColumnRowSize();
		}
		#end
	}


    @:dox(hide)
	override public function setForeground(c:ASColor):Void{
		super.setForeground(c);
		if (getForeground() != null) {
    		getTextField().textColor = getForeground().getRGB();
    		getTextField().alpha = getForeground().getAlpha();
            nativeTextField.Configure({fontColor: getForeground().getRGB()});
  		}
	}

    @:dox(hide)
	public function setText(text:String):Void{
        if (null == text) text = "";

        if (null != nativeTextField) {
            if(nativeTextField.GetText() != text){
                nativeTextField.SetText(text);
            }
        }

        if(getTextField().text != text){
			getTextField().text = text;
			if(isAutoSize()){
				revalidate();
			}
			bindx.Bind.notify(this.text);
		}
	}

    @:dox(hide)
    override public function setVisible(v:Bool):Void {
        updateNativeTextFieldVisibility();
        super.setVisible(v);
    }

    @:dox(hide)
	public function getText():String{
		return if (null != nativeTextField) nativeTextField.GetText() else getTextField().text;
	}
	
	@:dox(hide)
    public function setHtmlText(ht:String):Void{
		getTextField().htmlText = ht;
		if(isAutoSize()){
			revalidate();
		}
	}
	
	@:dox(hide)
    public function getHtmlText():String{
		return getTextField().htmlText;
	}
	
	public function appendText(newText:String):Void{
		getTextField().text+=newText;
		if(isAutoSize()){
			revalidate();
		}
	}
	
	//-------------------------------------------------------------
	
	/**
	 * JTextComponent need count preferred size itself.
	 */
	override private function countPreferredSize():IntDimension{
		throw new Error("Subclass of JTextComponent need implement this method : countPreferredSize!");
		return null;
	}
	
	/**
	 * Invalidate the column and row size, make it will be recount when need it next time.
	 */
	private function invalidateColumnRowSize():Void{
		columnRowCounted = false;
	}	
	
	/**
	 * Returns the column width. The meaning of what a column is can be considered a fairly weak notion for some fonts.
	 * This method is used to define the width of a column. 
	 * By default this is defined to be the width of the character m for the font used.
	 * if the font size changed, the invalidateColumnRowSize will be called,
	 * then next call get method about this will be counted first.
	 */
	private function getColumnWidth():Int{
		if(columnRowCounted!=true) countColumnRowSize();
		return columnWidth;
	}
	
	/**
	 * Returns the row height. The meaning of what a column is can be considered a fairly weak notion for some fonts.
	 * This method is used to define the height of a row. 
	 * By default this is defined to be the height of the character m for the font used.
	 * if the font size changed, the invalidateColumnRowSize will be called,
	 * then next call get method about this will be counted first.
	 */
	private function getRowHeight():Int{
		if(columnRowCounted!=true) countColumnRowSize();
		return rowHeight;
	}
	
	/**
	 * @see #getColumnWidth()
	 */
	private function getWidthMargin():Int{
		if(columnRowCounted!=true) countColumnRowSize();
		return widthMargin;
	}
	
	/**
	 * @see #getRowHeight()
	 */	
	private function getHeightMargin():Int{
		if(columnRowCounted!=true) countColumnRowSize();
		return heightMargin;
	}
	
	private function getTextFieldAutoSizedSize(forceWidth:Int=0, forceHeight:Int=0):IntDimension{
		var tf:TextField = getTextField();
        var oldSize:IntDimension = new IntDimension(Std.int(tf.textWidth), Std.int(tf.textHeight));
        #if(flash9 || cpp || html5)
        oldSize = new IntDimension(Std.int(tf.width), Std.int(tf.height));
        #end
		var old:TextFieldAutoSize = tf.autoSize;
		if(forceWidth != 0){
			tf.width = forceWidth;
		}
		if(forceHeight != 0){
			tf.height = forceHeight;
		}
		tf.autoSize = TextFieldAutoSize.LEFT;
		var size:IntDimension = new IntDimension(Std.int(tf.textWidth), Std.int(tf.textHeight));
		#if(flash9 || cpp || html5)
		size = new IntDimension(Std.int(tf.width), Std.int(tf.height));
		#end		
		tf.autoSize = old;
		tf.width = oldSize.width;
		tf.height = oldSize.height;
		if(forceWidth != 0){
			size.width = forceWidth;
		}
		if(forceHeight != 0){
			size.height = forceHeight;
		}
		return size;
	}
	
	private function countColumnRowSize():Void{
		var str:String= "Mmmmm";
		var tf:TextFormat = getFont().getTextFormat();
		var textFieldSize:IntDimension = AsWingUtils.computeStringSizeWithFont(getFont(), str, true);
		var textSize:IntDimension = AsWingUtils.computeStringSizeWithFont(getFont(), str, false);
		if(tf.font == "NSimSun"){
			columnWidth = Math.round(textSize.width/4 + Std.int(tf.size)/6);
		}else{
			columnWidth = Std.int(textSize.width/5);
		}
		rowHeight = textSize.height;
		widthMargin = textFieldSize.width - textSize.width;
		heightMargin = textFieldSize.height - textSize.height;
		columnRowCounted = true;
	}
	
    /**
     * Returns the text field to receive the focus for this component.
     * @return the object to receive the focus.
     */
    @:dox(hide)
    override public function getInternalFocusObject():InteractiveObject{
    	return this;
    }
	
	override private function paint(b:IntRectangle):Void{
		super.paint(b);
		applyBoundsToText(b);
	}
	
    private function applyBoundsToText(b:IntRectangle):Void{
		var t:TextField = getTextField();
		t.x = b.x;
		t.y = b.y;
		t.width = b.width;
		t.height = b.height;
        var global = getGlobalLocation();
        nativeTextField.Configure({
            x: global.x + b.x,
            y: global.y + b.y,
            width: b.width,
            height: b.height
        });
    }

	public function setSelection(beginIndex:Int, endIndex:Int):Void {
		getTextField().setSelection(beginIndex, endIndex);
	}

	public function selectAll():Void {
        #if(!cpp)
		getTextField().setSelection(0, getTextField().length);
        #end
	}

	/**
	 * Sets the textFormat to the specified range.
	 * <p>
	 * You should set a <code>EmptyFont</code> instance to be the component
	 * font before this call to make sure the textFormat will be effective.
	 * </p>
	 * @param tf the default textformat.
	 * @param beginIndex the begin index.
	 * @param endIndex the end index.
	 * @see Component.font
	 */
	public function setTextFormat(tf:TextFormat, beginIndex:Int= -1, endIndex:Int= -1):Void{
		getTextField().setTextFormat(tf, beginIndex, endIndex);
	}

	public function getTextFormat(beginIndex:Int = -1, endIndex:Int = -1):TextFormat {
		return getTextField().getTextFormat(beginIndex, endIndex);
	}

	@:dox(hide)
    public function setDisplayAsPassword(b:Bool):Void {
		getTextField().displayAsPassword = b;
        if (null != nativeTextField) {
            nativeTextField.Configure({
                isPassword: b,
                keyboardType: if (!b) keyboardType else NativeTextFieldKeyboardType.Password
            });
        }
	}

    @:dox(hide)
	public function isDisplayAsPassword():Bool {
		return getTextField().displayAsPassword;
	}

	@:dox(hide)
    public function getLength():Int {
		#if (!cpp)
        return getTextField().length;
        #else
        return 0;
        #end
	}

	@:dox(hide)
    public function setMaxChars(n:Int):Void {
		getTextField().maxChars = n;
	}

    @:dox(hide)
	public function getMaxChars():Int {
		return getTextField().maxChars;
	}

	@:dox(hide)
    public function setRestrict(res:String):Void {
        #if (!cpp)
		getTextField().restrict = res;
        #end
	}

    @:dox(hide)
	public function getRestrict():String {
        #if (!cpp)
    	return getTextField().restrict;
        #else
        return "";
        #end
	}

    @:dox(hide)
	public function getSelectionBeginIndex():Int {
        #if (!cpp)
        return getTextField().selectionBeginIndex;
        #else
        return 0;
        #end
	}

    @:dox(hide)
	public function getSelectionEndIndex():Int {
        #if (!cpp)
        return getTextField().selectionEndIndex;
        #else
        return 0;
        #end
	}

	#if (flash9)
	private function __onTextComponentTextInput(e:TextEvent):Void {
	
    	if(!getTextField().multiline){ //fix the bug that fp in interenet browser single line TextField Ctrl+Enter will entered a newline bug
    		var text:String= e.text;
    		var km:KeyboardManager = getKeyboardManager();
    		if(km!=null)	{
	    		if(km.isKeyDown(AWKeyboard.CONTROL) && km.isKeyDown(AWKeyboard.ENTER)){
					if(text.length == 1 && text.charCodeAt(0) == 10){
						
						e.preventDefault();
					}
	    		}
    		}
    	}

	}

	/**
	 * Append text implemented by <code>replaceText</code> to avoid the 
	 * <code>appendText()</code> method bug(the bug will make the text not be append at 
	 * the end of the text, some times it appends to a middle position).
	 * @param newText the text to be append to the end of the text field.
	 */
    @:dox(hide)
	public function appendByReplace(newText:String):Void{
		var n:Int = getLength();
		getTextField().replaceText(n, n, newText);
	}
	
    @:dox(hide)
	public function replaceSelectedText(value:String):Void {
		getTextField().replaceSelectedText(value);
	}
	
    @:dox(hide)
	public function replaceText(beginIndex:Int, endIndex:Int, newText:String):Void {
		getTextField().replaceText(beginIndex, endIndex, newText);
	}
	
    @:dox(hide)
	public function setCondenseWhite(b:Bool):Void {
		if(getTextField().condenseWhite != b){
			getTextField().condenseWhite = b;
			revalidate();
		}
	}
	
    @:dox(hide)
	public function isCondenseWhite():Bool {
		return getTextField().condenseWhite;
	}
	 
    @:dox(hide)
	public function setCSS(css:Dynamic):Void {
		getTextField().styleSheet = css;
			
		if(isAutoSize()){
			revalidate();
		} 
	}
	
    @:dox(hide)
	public function getCSS():Dynamic {
		return getTextField().styleSheet;
	}
	

    @:dox(hide)
	public function setUseRichTextClipboard(b:Bool):Void {
		getTextField().useRichTextClipboard = b;
	}
	
    @:dox(hide)
	public function isUseRichTextClipboard():Bool {
		return getTextField().useRichTextClipboard;
	}
	#end
}