////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package flex.component
{

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

/**
 *  Dispatched when the value of the control changes
 *  as a result of user interaction.
 *
 *  @eventType flash.events.Event
 */
[Event(name="change", type="flash.events.Event")]

/**
 *  Skin states for this component.
 */
[SkinStates("normal", "disabled")]

/**
 *  TrackBase is a base class for components with a track
 *  and one or more thumbs such as Slider and ScrollBar. It
 *  declares two required SkinParts, <code>thumb</code> and
 *  <code>track</code>. TrackBase also provides the code for
 *  thumb dragging which is shared by Slider and ScrollBar.
 * 
 *  @see flex.component.Range
 *  @see flex.component.Slider
 *  @see flex.component.ScrollBar
 */
public class TrackBase extends Range
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     */
    public function TrackBase():void
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    // Skins
    //
    //--------------------------------------------------------------------------

    [SkinPart]
    
    /**
     *  <code>thumb</code> is a SkinPart that defines a button
     *  that can be dragged along the track to increase or
     *  decrease the slider's <code>value</code> property.
     *  Updates to the <code>value</code> through other means
     *  will automatically update the position of the thumb
     *  with respect to the track.
     */
    public var thumb:Button;
    
    [SkinPart]
    
    /**
     *  <code>track</code> is a SkinPart that defines a button
     *  that, when  pressed, will set the <code>value</code>
     *  to the value corresponding with that position.
     */
    public var track:Button; 


    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    private var tempTrackSize:Number = NaN;

    //--------------------------------------------------------------------------
    //
    //  Overridden properties: UIComponent, Range
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Enable/disable this component. This also enables/disables any of the 
     *  skin parts for this component.
     */
    override public function set enabled(value:Boolean):void
    {
        super.enabled = value;
        enableSkinParts(value);
        invalidateSkinState();
    }
    
    override public function set maximum(value:Number):void
    {
        super.maximum = value;
        invalidateDisplayList();
    }

    override public function set minimum(value:Number):void
    {
        super.minimum = value;
        invalidateDisplayList();
    }
    
    override public function set value(newValue:Number):void
    {
        super.value = newValue;
        invalidateDisplayList();
    }
    
    override protected function setValue(value:Number):void
    {
        super.setValue(value);
        invalidateDisplayList();
    }
    
    //--------------------------------------------------------------------------
    //
    // Properties
    //
    //--------------------------------------------------------------------------

    //---------------------------------
    // clickOffset
    //---------------------------------
    
    private var _clickOffset:Point;
    
    /**
     *  The clickOffset is the point in the local coordinates of 
     *  the thumb where the last mouse down event occurred. This
     *  is used by calculateNewValue() to determine what value
     *  the thumb has been dragged to.
     */
    protected function get clickOffset():Point
    {
        return _clickOffset;
    }

    //---------------------------------
    // trackSize
    //---------------------------------
    
    /**
     *  This method returns the size of the logical track. 
     *  Subclasses need to override this method to return 
     *  an appropriate value. Note that this number can 
     *  represent any system of units, but those units must 
     *  be consistent with the values returned by
     *  pointToPosition, thumbSize, and valueToPosition.
     */
    protected function get trackSize():Number
    {
        return 0;
    }
    
    //---------------------------------
    // thumbSize
    //---------------------------------
    
    private var _thumbSize:Number = 0;
    
    /**
     *  The size of the thumb on the logical track in the 
     *  units of the subclass, which must be consistent with 
     *  trackSize, pointToPosition and valueToPosition. The 
     *  default thumbSize on the logical track is 0.
     * 
     *  @default 0
     */
    protected function get thumbSize():Number
    {
        return _thumbSize;
    }
    
    protected function set thumbSize(value:Number):void
    {
        if (value == _thumbSize)
            return;

        _thumbSize = value;
    }
    
    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, 
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        thumbSize = calculateThumbSize();
        sizeThumb(thumbSize);

        positionThumb(valueToPosition(value));
    }

    /**
     *  @inheritDoc
     */
	override protected function getUpdatedSkinState():String
	{
		return enabled ? "normal" : "disabled";
	}
	
    /**
     *  Adds event handlers to the track and thumb for mouse events.
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        if (instance == thumb)
        {
            thumb.addEventListener(MouseEvent.MOUSE_DOWN,
                                   thumb_mouseDownHandler);
            thumb.stickyHighlighting = true;
        }
        else if (instance == track)
        {
            track.addEventListener(MouseEvent.MOUSE_DOWN,
                                   track_mouseDownHandler);
            track.addEventListener("updateComplete", 
                                   track_updateCompleteHandler);
            
        }
        
        enableSkinParts(enabled);
    }

    /**
     *  Remove event handlers from skin parts.
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        if (instance == thumb)
        {
            thumb.removeEventListener(MouseEvent.MOUSE_DOWN, 
                                      thumb_mouseDownHandler);
        }
        else if (instance == track)
        {
            track.removeEventListener(MouseEvent.MOUSE_DOWN, 
                                      track_mouseDownHandler);
            track.removeEventListener("updateComplete", 
                                      track_updateCompleteHandler);
        }
    }

    /**
     *  Make the skins reflect the enabled state of TrackBase
     */
    protected function enableSkinParts(value:Boolean):void
    {
        if (thumb)
            thumb.enabled = value;
        if (track)
            track.enabled = value;
    }
    
    /**
     *  Utility method which returns the Range value for a given
     *  position on the track. The Range value is calculated by
     *  finding what fraction of the logical track the position
     *  represents and then multiplying that by the Range.
     */
    protected function positionToValue(position:Number):Number
    {
        var posRange:Number = trackSize - thumbSize;

        if (posRange == 0) // Divide by 0 error.
            return minimum;

        var range:Number = maximum - minimum;
        var value:Number = minimum + position * (range / posRange);
        return value;
    }
    
    /**
     *  Utility function to calculate the thumb's position
     *  corresponding to the given value. The thumb position
     *  is calculated by finding what fraction of the range
     *  the value represents, and then multiplying that by
     *  the logical track size minus the logical thumb size.
     */
    protected function valueToPosition(value:Number):Number
    {
        var range:Number = maximum - minimum;
        
        if (range == 0) // Divide by 0 error.
            return 0;
            
        var posRange:Number = trackSize - thumbSize;
        var thumbPos:Number = (value - minimum) * (posRange / range);
        return thumbPos;
    }
    
    /**
     *  This function returns a position on the slider relative to its
     *  orientation and shape. The <code>localX</code> and <code>localY</code>
     *  values represent the location in the local coordinate system of the
     *  track. Subclasses must override this method and return the
     *  appropriate value for their situation. Values should not be clamped to
     *  the ends of the track, as that clamping will happen later, prior
     *  to setting the thumb position.
     */
    protected function pointToPosition(localX:Number, localY:Number):Number
    {
        return 0;
    }

    /**
     *  This method positions the thumb button correctly, given
     *  the position. Subclasses should override this method to position 
     *  the thumb appropriately for their situation.
     */
    protected function positionThumb(thumbPos:Number):void {}
    
    /**
     *  This method sizes the thumb button correctly, given
     *  the thumbSize. Subclasses should override this method to size 
     *  the thumb appropriately for their situation.
     */
    protected function sizeThumb(thumbSize:Number):void {}

    /**
     *  This utility method calculates an appropriate size for the thumb
     *  button, given the current range, pageSize, and trackSize settings.
     *  Subclasses should override this to calculate the correct size in
     *  the units of position.
     * 
     *  @default 0
     */
    protected function calculateThumbSize():Number
    {
        return 0;
    }

    /**
     *  Given a MouseEvent that contains where the thumb was dragged to and
     *  the previous value of the thumb, calculateNewValue() returns a new
     *  value based on the difference calculated in the mouseDown handler
     *  and the new position. The value is also restricted to the allowed
     *  values here. This method usually should not be overridden.
     */
    protected function calculateNewValue(prevValue:Number, event:MouseEvent):Number
    {
        var pt:Point = new Point(event.stageX, event.stageY);
        pt = track.globalToLocal(pt);
        var movePos:Number = pointToPosition(pt.x - _clickOffset.x, 
                                             pt.y - _clickOffset.y);
        var newValue:Number = positionToValue(movePos);
        var roundedValue:Number = nearestValidValue(newValue, stepSize);
        return roundedValue;
    }

    //--------------------------------------------------------------------------
    // 
    // Event Handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Force the component to set itself up correctly now that the
     *  track is completely loaded.
     */
    protected function track_updateCompleteHandler(event:Event):void
    {
        //TODO: Consider the case where the track moves (like the move
        //effect). Perhaps this handler should run every time... 
        if (trackSize != tempTrackSize)
        {
            thumbSize = calculateThumbSize();
            sizeThumb(thumbSize);
            positionThumb(valueToPosition(value));
            tempTrackSize = trackSize;
        }
    }

    //---------------------------------
    // Thumb dragging handlers
    //---------------------------------
    
    /**
     *  Handle mouse-down events on the scroll thumb. Records 
     *  the mouse down point in clickOffset.
     */
    protected function thumb_mouseDownHandler(event:MouseEvent):void
    {
        // TODO (chaase): We might want a different event mechanism eventually
        // which would push this enabled check into the child/skin components
        if (!enabled)
            return;

        addSystemHandlers(MouseEvent.MOUSE_MOVE, system_mouseMoveHandler, 
                stage_mouseMoveHandler);
        addSystemHandlers(MouseEvent.MOUSE_UP, system_mouseUpHandler, 
                stage_mouseUpHandler);
                            
        // Record the location where this mouse-down event occurred; we will
        // use this in later drag operations to determine how much to move the
        // thumb button
        var pt:Point = new Point(event.stageX, event.stageY);
        var pt2:Point = track.globalToLocal(pt);
        pt = thumb.globalToLocal(pt);
        _clickOffset = pt;
    }
    
    /**
     *  @private
     *  Capture mouse-move events on the thumb anywhere on the stage
     */
    private function stage_mouseMoveHandler(event:MouseEvent):void
    {
        if (event.target != stage)
            return;

        system_mouseMoveHandler(event);
    }

    /**
     *  Capture mouse-move events anywhere on or off the stage.
     *  First, we calculate the new value based on the new position
     *  using calculateNewValue(). Then, we move the thumb to 
     *  the new value's position. Last, we set the value and
     *  dispatch a "change" event if the value changes. 
     */
    protected function system_mouseMoveHandler(event:MouseEvent):void
    {
        var newValue:Number = calculateNewValue(value, event);

        positionThumb(valueToPosition(newValue));
        
        if (newValue != value)
        {
            setValue(newValue);
            dispatchEvent(new Event("change"));   
        }
        
        event.updateAfterEvent();
    }
    
    /**
     *  @private
     *  Handle mouse-up events anywhere on the stage.
     */
    private function stage_mouseUpHandler(event:MouseEvent):void
    {
        if (event.target != stage)
            return;

        system_mouseUpHandler(event);
    }

    /**
     *  Handle mouse-up events anywhere on or off the stage.
     */
    protected function system_mouseUpHandler(event:MouseEvent):void
    {
        removeSystemHandlers(MouseEvent.MOUSE_MOVE, system_mouseMoveHandler, 
                stage_mouseMoveHandler);
        removeSystemHandlers(MouseEvent.MOUSE_UP, system_mouseUpHandler, 
                stage_mouseUpHandler);
    }

    //---------------------------------
    // Track down handlers
    //---------------------------------
    
    /**
     *  Handle mouse-down events for the scroll track. Subclasses
     *  should override this method if they want the track to
     *  recognize mouse clicks on the track.
     */
    protected function track_mouseDownHandler(event:MouseEvent):void {}
}

}