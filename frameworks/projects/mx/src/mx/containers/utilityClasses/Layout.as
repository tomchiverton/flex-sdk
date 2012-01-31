
package mx.containers.utilityClasses
{

import mx.core.Container;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;

[ExcludeClass]

/**
 *  @private
 */
public class Layout
{
	include "../../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function Layout()
	{
		super();
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Used for accessing localized error messages.
	 */
	protected var resourceManager:IResourceManager =
									ResourceManager.getInstance();

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  target
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the target property.
	 */
	private var _target:Container;

	/**
	 *  The container associated with this layout.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get target():Container
	{
		return _target;
	}
	
	/**
	 *  @private
	 */
	public function set target(value:Container):void
	{
		_target = value;
	}

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public function measure():void
	{
	}

	/**
	 *  @private
	 */
	public function updateDisplayList(unscaledWidth:Number,
									  unscaledHeight:Number):void
	{
	}
}

}
