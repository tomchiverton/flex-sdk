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

package mx.skins.spark
{

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.IBitmapDrawable;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.components.baseClasses.FxComponent;
import mx.components.FxCheckBox;
import mx.components.FxRadioButton;
import mx.core.UIComponent;
import mx.core.mx_internal;

/**
 *  Focus skins for Fx components.
 */
public class FxFocusSkin extends UIComponent
{
    include "../../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    // TODO: Make this a style property?
    private const FOCUS_THICKNESS:int = 2;
    
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------
    
    private static var colorTransform:ColorTransform = new ColorTransform(
                1.01, 1.01, 1.01, 2);
    private static var glowFilter:GlowFilter = new GlowFilter(
                0x70B2EE, 0.85, 5, 5, 3, 1, false, true);
    private static var rect:Rectangle = new Rectangle();;
    private static var filterPt:Point = new Point();
                 
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    public function FxFocusSkin()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Bitmap capture of the focused component. This bitmap includes a glow
     *  filter that shows the focus glow.
     */
    private var bitmap:Bitmap;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // Grab a bitmap of the focused object
        var focusObject:Object = focusManager.getFocus();
        var bitmapData:BitmapData = new BitmapData(
                    focusObject.width + (FOCUS_THICKNESS * 2), 
                    focusObject.height + (FOCUS_THICKNESS * 2), true, 0);
        var m:Matrix = new Matrix();
        
        // If the focus object already has a focus skin, make sure it is hidden.
        if (focusObject is FxComponent && focusObject.mx_internal::focusObj)
            focusObject.mx_internal::focusObj.visible = false;
       
        // Temporary solution for focus drawing on CheckBox and RadioButton components.
        // Hide the label before drawing the focus. 
        // TODO: Figure out a better solution.
        var hidLabelField:Boolean = false;
        if ((focusObject is FxCheckBox || focusObject is FxRadioButton)
             && focusObject.labelField)
        {
            focusObject.labelField.displayObject.visible = false;
            hidLabelField = true;
        }
            
        m.tx = FOCUS_THICKNESS;
        m.ty = FOCUS_THICKNESS;
        bitmapData.draw(focusObject as IBitmapDrawable, m);
        
        // Show the focus skin, if needed.
        if (focusObject is FxComponent && focusObject.mx_internal::focusObj)
            focusObject.mx_internal::focusObj.visible = true;
        
        // Show the label, if needed.
        if (hidLabelField)
            focusObject.labelField.displayObject.visible = true;
             
        // Transform the color to remove the transparency. The GlowFilter has the "knockout" property
        // set to true, which removes this image from the final display, leaving only the outer glow.
        rect.x = rect.y = FOCUS_THICKNESS;
        rect.width = focusObject.width;
        rect.height = focusObject.height;
        bitmapData.colorTransform(rect, colorTransform);
        
        // Apply the glow filter
        rect.x = rect.y = 0;
        rect.width = bitmapData.width;
        rect.height = bitmapData.height;
        bitmapData.applyFilter(bitmapData, rect, filterPt, glowFilter); 
               
        if (!bitmap)
        {
            bitmap = new Bitmap();
            addChild(bitmap);
            bitmap.x = bitmap.y = -FOCUS_THICKNESS;
        }
        
        bitmap.bitmapData = bitmapData;
    }
}
}        
