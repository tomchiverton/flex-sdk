
package mx.accessibility
{

import flash.accessibility.Accessibility;
import flash.events.Event;
import mx.accessibility.AccConst;
import mx.collections.CursorBookmark;
import mx.collections.IViewCursor;
import mx.controls.ComboBase;
import mx.core.UIComponent;
import mx.core.mx_internal;

use namespace mx_internal;

/**
 *  ComboBaseAccImpl is a subclass of AccessibilityImplementation
 *  which implements accessibility for the ComboBase class.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class ComboBaseAccImpl extends AccImpl
{
    include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  Enables accessibility in the ComboBase class.
	 * 
	 *  <p>This method is called by application startup code
	 *  that is autogenerated by the MXML compiler.
	 *  Afterwards, when instances of ComboBase are initialized,
	 *  their <code>accessibilityImplementation</code> property
	 *  will be set to an instance of this class.</p>
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static function enableAccessibility():void
	{
		ComboBase.createAccessibilityImplementation =
			createAccessibilityImplementation;
	}
	
	/**
	 *  @private
	 *  Creates a ComboBase's AccessibilityImplementation object.
	 *  This method is called from UIComponent's
	 *  initializeAccessibility() method.
	 */
	mx_internal static function createAccessibilityImplementation(
								component:UIComponent):void
	{
		component.accessibilityImplementation =
			new ComboBaseAccImpl(component);
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 *
	 *  @param master The UIComponent instance that this AccImpl instance
	 *  is making accessible.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function ComboBaseAccImpl(master:UIComponent)
	{
		super(master);

		role = AccConst.ROLE_SYSTEM_COMBOBOX
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden properties: AccImpl
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  eventsToHandle
	//----------------------------------

	/**
	 *  @private
	 *	Array of events that we should listen for from the master component.
	 */
	override protected function get eventsToHandle():Array
	{
		return super.eventsToHandle.concat([ "change", "valueCommit" ]);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods: AccessibilityImplementation
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Gets the role for the component.
	 *
	 *  @param childID uint.
	 */
	override public function get_accRole(childID:uint):uint
	{
		return childID == 0 ? role : AccConst.ROLE_SYSTEM_LISTITEM;
	}

	/**
	 *  @private
	 *  IAccessible method for returning the value of the ComboBase
	 *  (which would be the text of the item selected).
	 *  The ComboBase should return the content of the TextField as the value.
	 *
	 *  @param childID uint
	 *
	 *  @return Value String
	 */
	override public function get_accValue(childID:uint):String
	{
		if (childID == 0)
			return ComboBase(master).text;

		return null;
	}

	/**
	 *  @private
	 *  IAccessible method for returning the state of the ListItem
	 *  (basically to remove 'not selected').
	 *  States are predefined for all the components in MSAA.
	 *  Values are assigned to each state.
	 *  Depending upon the listItem being Selected, Selectable,
	 *  Invisible, Offscreen, a value is returned.
	 *
	 *  @param childID uint
	 *
	 *  @return State uint
	 */
	override public function get_accState(childID:uint):uint
	{
		var accState:uint = getState(childID);
		
		if (childID > 0)
		{
			accState |= AccConst.STATE_SYSTEM_SELECTABLE;
		
			if (ComboBase(master).selectedIndex == childID - 1)
				accState |= AccConst.STATE_SYSTEM_SELECTED | AccConst.STATE_SYSTEM_FOCUSED;
		}

		return accState;
	}

	/**
	 *  @private
	 *  Method to return an array of childIDs.
	 *
	 *  @return Array
	 */
	override public function getChildIDArray():Array
	{
		var n:int = ComboBase(master).dataProvider ?
					ComboBase(master).dataProvider.length :
					0;

		return createChildIDArray(n);
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden event handlers: AccImpl
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Override the generic event handler.
	 *  All AccImpl must implement this to listen for events
	 *  from its master component. 
	 */
	override protected function eventHandler(event:Event):void
	{
		// Let AccImpl class handle the events
		// that all accessible UIComponents understand.
		$eventHandler(event);
		
		switch (event.type)
		{
			case "change":
			{
				var index:int = ComboBase(master).selectedIndex;
				
				if (index >= 0)
				{
					var childID:uint = index + 1;
					
					Accessibility.sendEvent(master, childID,
											AccConst.EVENT_OBJECT_SELECTION);
					
					Accessibility.sendEvent(master, 0, 
											AccConst.EVENT_OBJECT_VALUECHANGE);
				}
				break;
			}

			case "valueCommit":
			{
				Accessibility.sendEvent(master, 0, AccConst.EVENT_OBJECT_VALUECHANGE);
				break;
			}
		}
	}
}

}
