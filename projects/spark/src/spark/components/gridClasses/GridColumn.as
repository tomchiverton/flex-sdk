////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components.supportClasses
{
import flash.events.Event;
import flash.events.EventDispatcher;

import mx.core.ClassFactory;
import mx.core.IFactory;
import mx.core.Singleton;
import mx.core.mx_internal;

import spark.components.DataGrid;
import spark.components.Grid;
import spark.components.gridClasses.TextGridItemEditor;

use namespace mx_internal;

/**
 *  A non-visual object that defines the mapping from each dataProvider item to a Grid column.
 *  Each dataProvider item corresponds to one Grid row and this object specifies the item property
 *  whose value is to be displayed in one column, the item renderer to display that value, the editor
 *  that's used to change the value, and so on.
 */   
public class GridColumn extends EventDispatcher
{
    include "../../core/Version.as";    
    
    /**
     *  The return value for itemToLabel() or itemToDataTip() if resolving the corresponding
     *  property name (path) fails.  The value of this constant is a single space: <code>" "</code>.
     * 
     *  @see itemToLabel
     *  @see itemToDataTip
     */
    public static const ERROR_TEXT:String = new String(" ");
    
    /**
     *  @private
     */   
    private static var _defaultItemEditorFactory:IFactory;
    
    mx_internal static function get defaultItemEditorFactory():IFactory
    {
        if (!_defaultItemEditorFactory)
            _defaultItemEditorFactory = new ClassFactory(TextGridItemEditor);
        return _defaultItemEditorFactory;
    }

    public function GridColumn()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  grid
    //----------------------------------
    
    private var _grid:Grid = null;
    
    /** 
     *  @private
     *  Set by the Grid when this column is added to grid.columns, set
     *  to null when the column is removed.
     */
    mx_internal function setGrid(value:Grid):void
    {
        if (_grid == value)
            return;
        
        _grid = value;
        dispatchChangeEvent("gridChanged");        
    }

    [Bindable("gridChanged")]    
    
    /**
     *  The Grid this whose list of columns contains this Column, or null.
     */
    public function get grid():Grid
    {
        return _grid;
    }
    
    //----------------------------------
    //  columnIndex
    //----------------------------------
    
    private var _columnIndex:int = -1;
    
    /** 
     *  @private
     *  Set by the Grid when this column is added to the grid.columns, set
     *  to -1 when the column is removed.
     */
    mx_internal function setColumnIndex(value:int):void
    {
        if (_columnIndex == value)
            return;
        
        _columnIndex = value;
        dispatchChangeEvent("columnIndexChanged");        
    }
    
    [Bindable("columnIndexChanged")]    
    
    /**
     *  The position of this column in the grid's column list, or -1 if this column's grid is null.
     */
    public function get columnIndex():int
    {
        return _columnIndex;
    }   
    
    //----------------------------------
    //  dataField
    //----------------------------------
    
    private var _dataField:String = null;
    private var dataFieldPath:Array = [];
    
    [Bindable("dataFieldChanged")]    
    
    /**
     *  Names the dataProvider property whose value is used to initialize item renderer's 
     *  label string. In other words, the value of the itemRenderer's label property 
     *  for the row at <code>rowIndex</code> in this column is: 
     *  <code>grid.dataProvider.getItemAt(rowIndex).dataField.toString()</code>.
     *  
     *  <p>If this column or its grid specifies a <code>labelFunction</code>, then the
     *  dataField is not used.</p>
     * 
     *  @default null
     * 
     *  @see itemToLabel
     *  @see labelFunction
     */
    public function get dataField():String
    {
        return _dataField;
    }
    
    /**
     *  @private
     */
    public function set dataField(value:String):void
    {
        if (_dataField == value)
            return;
        
        _dataField = value;
        
        if (value == null)
        {
            dataFieldPath = [];
        }
        else if (value.indexOf( "." ) != -1) 
        {
            dataFieldPath = value.split(".");
            // TBD(hmuller): deal with the sortCompareFunction, as in DataGridColumn set dataField
        }
        else
        {
            dataFieldPath = [value];
        }
        
        invalidateGrid();
        if (grid)
            grid.clearGridLayoutCache(true);
        
        dispatchChangeEvent("dataFieldChanged");
    }
    
    
    //----------------------------------
    //  dataGrid (private, read-only)
    //----------------------------------
    
    /**
     *  @private
     */
    private function get dataGrid():spark.components.DataGrid
    {
        return (grid) ? grid.gridOwner as DataGrid : null;
    }
    
    //----------------------------------
    //  dataTipField
    //----------------------------------
    
    private var _dataTipField:String = null;
    
    [Bindable("dataTipFieldChanged")]    
    
    /**
     *  The property of the dataProvider item to display as the dataTip for this column.
     *  By default, if <code>showDataTips=true</code>, the itemRenderer's label is displayed
     *  as the dataTip.  This property, which is similar to <code>dataField</code>, can 
     *  be specified to show a different value for the dataTip.
     * 
     *  <p>If this column or its grid specifies a <code>dataTipFunction</code>, then the
     *  dataTipField is not used.</p>
     * 
     *  @default null
     *  @see dataTipFunction
     *  @see itemToDataTip
     */
    public function get dataTipField():String
    {
        return _dataTipField;
    }
    
    /**
     *  @private
     */
    public function set dataTipField(value:String):void
    {
        if (_dataTipField == value)
            return;
        
        _dataTipField = value;
        
        if (grid)
            grid.invalidateDisplayList();
        
        dispatchChangeEvent("dataTipFieldChanged");
    }
    
    //----------------------------------
    //  dataTipFunction
    //----------------------------------
    
    private var _dataTipFunction:Function = null;
    
    [Bindable("dataTipFunctionChanged")]
    
    /**
     *  A function that converts a dataProvider item into a column-specific string
     *  which will be displayed as a dataTip, if <code>showDataTips=true</code>.
     *  A dataTipFunction can be use to combine the values of several dataProvider item
     *  properties into a single string.  If specified, this property is used by the 
     *  <code>itemToDataTip()</code> method.
     *
     *  <p>The dataTipFunction's signature must match the following:
     * 
     *  <pre>dataTipFunction(item:Object, column:GridColumn):String</pre>
     *
     *  The item parameter is the dataProvider item for an entire row; it's 
     *  the value of <code>grid.dataProvider.getItemAt(rowIndex)</code>.  The second
     *  parameter is this column.</p>
     *
     *  <p>A typical dataTipFunction might concatenate the item's firstName and
     *  lastName properties, or do some custom formatting on a Date valued
     *  item property.</p>
     * 
     *  @default null
     * 
     *  @see itemToDataTip
     *  @see dataTipField
     */
    public function get dataTipFunction():Function
    {
        return _dataTipFunction;
    }
    
    /**
     *  @private
     */
    public function set dataTipFunction(value:Function):void
    {
        if (_dataTipFunction == value)
            return;
        
        _dataTipFunction = value;
        
        if (grid)
            grid.invalidateDisplayList();
        
        dispatchChangeEvent("dataTipFunctionChanged");
    }
    
    //----------------------------------
    //  editable
    //----------------------------------
    
    private var _editable:Boolean = true;
    
    [Inspectable(category="General")]
    
    /**
     *  A flag that indicates whether the items in the column are editable.
     *  If <code>true</code>, and the DataGrid's <code>editable</code>
     *  property is also <code>true</code>, the items in a column are 
     *  editable and can be individually edited
     *  by clicking on a selected item or by navigating to the item and 
     *  pressing the F2 key.
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get editable():Boolean
    {
        return _editable;
    }
    
    /**
     *  @private
     */
    public function set editable(value:Boolean):void
    {
        _editable = value;
    }
    
    //----------------------------------
    //  headerRenderer
    //----------------------------------
    
    private var _headerRenderer:IFactory = null;
    
    [Bindable("headerRendererChanged")]
    
    /**
     *  A factory for the IGridItemRenderer used as the header for this column.  If null,
     *  the value of the DataGrid headerRenderer property is returned. 
     * 
     *  @default null
     *
     *  @see #headerText
     *  @see IGridItemRenderer
     */
    public function get headerRenderer():IFactory
    {
        if (_headerRenderer)
            return _headerRenderer;
        
        const dataGrid:DataGrid = dataGrid;
        return (dataGrid) ? dataGrid.headerRenderer : null;
    }
    
    /**
     *  @private
     */
    public function set headerRenderer(value:IFactory):void
    {
        if (_headerRenderer == value)
            return;
        
        _headerRenderer = value;
        
        // TBD(hmuller) invalidate CHB
        
        dispatchChangeEvent("headerRendererChanged");
    }
    
    //----------------------------------
    //  headerText
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the headerText property.
     */
    private var _headerText:String;
    
    [Bindable("headerTextChanged")]
    
    /**
     *  Text for the header of this column. By default, the Grid
     *  control uses the value of the <code>dataField</code> property 
     *  as the header text.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2
     *  @productversion Flex 4.5
     */
    public function get headerText():String
    {
        return (_headerText != null) ? _headerText : dataField;
    }
    
    /**
     *  @private
     */
    public function set headerText(value:String):void
    {
        _headerText = value;
        
        // Todo: invalidate just the ColumnHeaderBar not the entire grid?
        if (grid)
            grid.invalidateDisplayList();

        dispatchEvent(new Event("headerTextChanged"));
    }
   
    //----------------------------------
    //  itemEditor
    //----------------------------------
    
    private var _itemEditor:IFactory = null;
    
    [Bindable("itemEditorChanged")]
    
    /**
     *  A factory for IGridItemEditors used to edit individual grid cells.
     *  This property is only applies to grid columns that are used with
     *  DataGrids.
     * 
     *  <p>If a column is editable this property determines the editor that
     *  will be used. If this property is not specified, then the <code>
     *  itemEditor</code> property of the DataGrid will be used. If the
     *  DataGrid does not supply and editor then the <code>TextGridItemEditor
     *  </code> will be used.
     * </p>
     * 
     *  @default null
     *
     */
    public function get itemEditor():IFactory
    {
        return _itemEditor;
    }
    
    /**
     *  @private
     */
    public function set itemEditor(value:IFactory):void
    {
        if (_itemEditor == value)
            return;
        
        _itemEditor = value;
        
        dispatchChangeEvent("itemEditorChanged");
    }

    //----------------------------------
    //  itemRenderer
    //----------------------------------

    private var _itemRenderer:IFactory = null;
    
    [Bindable("itemRendererChanged")]
    
    /**
     *  A factory for IGridItemRenderers used to render invidual grid cells.  If not specified, 
     *  the grid's <code>itemRenderer</code> is returned.
     * 
     *  <p>The default item renderer just displays the value of its <code>label</code> property, 
     *  which is based on the dataProvider item for the cell's row, and on the column's dataField 
     *  property.  Custom item renderers that derive more values from the data item and include 
     *  more complex visuals are easily created by subclassing <code>GridItemRenderer</code>.</p>
     * 
     *  @default The value of the grid's itemRenderer, or null.
     *
     *  @see #dataField 
     *  @see GridItemRenderer
     */
    public function get itemRenderer():IFactory
    {
        return (_itemRenderer) ? _itemRenderer : grid.itemRenderer;
    }
    
    /**
     *  @private
     */
    public function set itemRenderer(value:IFactory):void
    {
        if (_itemRenderer == value)
            return;
        
        _itemRenderer = value;

        invalidateGrid();
        if (grid)
            grid.clearGridLayoutCache(true);
        
        dispatchChangeEvent("itemRendererChanged");
    }
    
    //----------------------------------
    //  itemRendererFunction
    //----------------------------------
    
    private var _itemRendererFunction:Function = null;
    
    [Bindable("itemRendererFunctionChanged")]
    
    /**
     *  If specified, the value of this property must be an idempotent function 
     *  that returns an item renderer IFactory based on its dataProvider item 
     *  and column parameters.  Specifying an itemRendererFunction makes it possible to 
     *  employ more than one item renderer in this column.
     * 
     *  <p>The itemRendererFunction's signature must match the following:
     *
     *  <pre>itemRendererFunction(item:Object, column:GridColumn):IFactory</pre>
     *
     *  The item parameter is the dataProvider item for an entire row; it's 
     *  the value of <code>grid.dataProvider.getItemAt(rowIndex)</code>.  The second
     *  parameter is this column.</p> 
     * 
     *  <p>Here's an example of an itemRendererFunction:</p>
     *  <pre>
     *  function myItemRendererFunction(item:Object, column:GridColumn):IFactory
     *  {
     *      return (item is Array) ? myArrayItemRenderer : myItemRenderer;
     *  }
     *  </pre>
     *  
     *  @default null
     */
    public function get itemRendererFunction():Function
    {
        return _itemRendererFunction;
    }
    
    /**
     *  @private
     */
    public function set itemRendererFunction(value:Function):void
    {
        if (_itemRendererFunction == value)
            return;

        _itemRendererFunction = value;
        
        invalidateGrid();
        if (grid)
            grid.clearGridLayoutCache(true);
        
        dispatchChangeEvent("itemRendererFunctionChanged");
    }
    
    //----------------------------------
    //  labelFunction
    //----------------------------------
    
    private var _labelFunction:Function = null;
    
    [Bindable("labelFunctionChanged")]
    
    /**
     *  An idempotent function that converts a dataProvider item into a column-specific string
     *  that's used to initialize the item renderer's <code>label</code> property.
     * 
     *  <p>A labelFunction can be use to combine the values of several dataProvider item
     *  properties into a single string.  If specified, this property is used by the 
     *  <code>itemToLabel()</code> method, which computes the value of each item 
     *  renderer's label property in this column.</p>
     *
     *  <p>The labelFunction's signature must match the following:</p>
     *
     *  <pre>labelFunction(item:Object, column:GridColumn):String</pre>
     *
     *  <p>The item parameter is the dataProvider item for an entire row; it's 
     *  the value of <code>grid.dataProvider.getItemAt(rowIndex)</code>.  The second
     *  parameter is this column.</p>
     *
     *  <p>A typical labelFunction might concatenate the item's firstName and
     *  lastName properties, or do some custom formatting on a Date valued
     *  item property.</p>
     * 
     *  @default null
     * 
     *  @see itemToLabel
     *  @see dataField
     */
    public function get labelFunction():Function
    {
        return _labelFunction;
    }
    
    /**
     *  @private
     */
    public function set labelFunction(value:Function):void
    {
        if (_labelFunction == value)
            return;

        _labelFunction = value;
        
        invalidateGrid();
        if (grid)
            grid.clearGridLayoutCache(true);
        
        dispatchChangeEvent("labelFunctionChanged");
    }
    
    //----------------------------------
    //  width
    //---------------------------------- 
    
    private var _width:Number = NaN;
    
    [Bindable("widthChanged")]    
    
    /**
     *  The width of this column in pixels. If specified, the grid's layout will ignore its
     *  typicalItem and this column's minWidth and maxWidth.
     * 
     *  @default NaN
     */
    public function get width():Number
    {
        return _width;
    }
    
    /**
     *  @private
     */
    public function set width(value:Number):void
    {
        if (_width == value)
            return;
        
        _width = value;
        
        invalidateGrid();
        
        // Reset content size so scroller's viewport can be resized.  There
        // is loop-prevention logic in the scroller which may not allow the
        // width/height to be reduced if there are automatic scrollbars.
        // See ScrollerLayout/measure().
        if (grid)
            grid.setContentSize(0, 0);
        
        dispatchChangeEvent("widthChanged");
    }
    
    //----------------------------------
    //  minWidth
    //---------------------------------- 
    
    private var _minWidth:Number = 20;
    
    [Bindable("minWidthChanged")]    
    
    /**
     *  The minimum width of this column in pixels. If specified, the grid's layout will
     *  make the column's layout width the larger of the typicalItem's width and the minWidth.
     *  If this column is resizable, this property limits how small the user can make this column.
     *  Setting this property will not change the width or maxWidth properties.
     *  
     *  @default 20
     */
    public function get minWidth():Number
    {
        return _minWidth;
    }
    
    /**
     *  @private
     */
    public function set minWidth(value:Number):void
    {
        if (_minWidth == value)
            return;
        
        _minWidth = value;
        
        invalidateGrid();

        // Reset content size so scroller's viewport can be resized.  There
        // is loop-prevention logic in the scroller which may not allow the
        // width/height to be reduced if there are automatic scrollbars.
        // See ScrollerLayout/measure().
        if (grid)
            grid.setContentSize(0, 0);
        
        dispatchChangeEvent("minWidthChanged");
    }    
       
    //----------------------------------
    //  maxWidth
    //---------------------------------- 
    
    private var _maxWidth:Number = NaN;
    
    [Bindable("maxWidthChanged")]    
    
    /**
     *  The maximum width of this column in pixels. If specified, the grid's layout will make
     *  the column's layout width the smaller of the typicalItem's width and the maxWidth.
     *  If this column is resizable, this property limits how wide the user can make this column.
     *  Setting this property will not change the width or minWidth properties.
     *
     *  @default NaN
     */
    public function get maxWidth():Number
    {
        return _maxWidth;
    }
    
    /**
     *  @private
     */
    public function set maxWidth(value:Number):void
    {
        if (_maxWidth == value)
            return;
        
        _maxWidth = value;
        
        invalidateGrid();

        // Reset content size so scroller's viewport can be resized.  There
        // is loop-prevention logic in the scroller which may not allow the
        // width/height to be reduced if there are automatic scrollbars.
        // See ScrollerLayout/measure().
        if (grid)
            grid.setContentSize(0, 0);
        
        dispatchChangeEvent("maxWidthChanged");
    }
    
    //----------------------------------
    //  renderIsEditable
    //----------------------------------
    
    private var _renderIsEditable:Boolean = false;
    
    /**
     *  Determines whether any of the item renderer's controls are editable.
     *  If the column is editable, the focusable controls in the item renderer
     *  will be given keyboard focus when the user starts editing the item
     *  renderer.
     * 
     *  @default false
     */
    public function get renderIsEditable():Boolean
    {
        return _renderIsEditable;
    }
    
    /**
     *  @private
     */
    public function set renderIsEditable(value:Boolean):void
    {
        _renderIsEditable = value;
    }
    
    //----------------------------------
    //  resizable
    //----------------------------------
    
    private var _resizable:Boolean = true;
    
    [Bindable("resizableChanged")]    
    
    /**
     *  Enable interactive resizing of this column's width.
     * 
     *  @default true
     */
    public function get resizable():Boolean
    {
        return _resizable;
    }
    
    /**
     *  @private
     */
    public function set resizable(value:Boolean):void
    {
        if (_resizable == value)
            return;
        
        _resizable = value;
        dispatchChangeEvent("resizableChanged");
        // TBD invalidate grid
    }
    
    //----------------------------------
    //  showDataTips
    //----------------------------------
    
    private var _showDataTips:* = undefined;
    
    [Bindable("showDataTipsChanged")]  
    
    /**
     *  Show dataTips for the cells in this column.   
     * 
     *  <p>If this property's value is undefined(the default), then the grid's showDataTips
     *  property determines if dataTips will be shown.   If this property is set, then 
     *  the grid's showDataTips property is ignored. </p>
     * 
     *  @default undefined
     * 
     *  @see #getShowDataTips
     */
    public function get showDataTips():*
    {
        return _showDataTips;
    }
    
    /**
     *  @private
     */
    public function set showDataTips(value:*):void
    {
        if (_showDataTips === value)
            return;

        _showDataTips = value;
        
        if (grid)
            grid.invalidateDisplayList();
        
        dispatchChangeEvent("showDataTipsChanged");        
    }
    

    mx_internal function getShowDataTips():Boolean
    {
        return (showDataTips === undefined) ? grid && grid.showDataTips : showDataTips;    
    }
    
    //----------------------------------
    //  sortable
    //----------------------------------
    
    private var _sortable:Boolean = true;
    
    [Bindable("sortableChanged")]  
    
    /**
     *  TBD
     * 
     *  @default true
     */
    public function get sortable():Boolean
    {
        return _sortable;
    }
    
    /**
     *  @private
     */
    public function set sortable(value:Boolean):void
    {
        if (_sortable == value)
            return;
        
        _sortable = value;
        dispatchChangeEvent("sortableChanged");        
    }
    
    //----------------------------------
    //  visible
    //----------------------------------
    
    private var _visible:Boolean = true;
    
    [Bindable("visibleChanged")]  
    
    /**
     *  If true, then display this column.  If false, no space will be allocated 
     *  for this column; it will not be included in the layout.
     * 
     *  @default true
     */
    public function get visible():Boolean
    {
        return _visible;
    }
    
    /**
     *  @private
     */
    public function set visible(value:Boolean):void
    {
        if (_visible == value)
            return;
        
        _visible = value;
        dispatchChangeEvent("visibleChanged");        
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Common logic for itemToLabel(), dataTipToLabel().   Logically this code is
     *  similar to (not the same as) LabelUtil.itemToLabel().
     *  This function will pass the item and the column, if provided, to the labelFunction.
     */
    mx_internal static function itemToString(item:Object, labelPath:Array, labelFunction:Function, column:GridColumn = null):String
    {
        if (!item)
            return ERROR_TEXT;
        
        if (labelFunction != null)
        {
            if (column != null)
                return labelFunction(item, column);
            else
                return labelFunction(item);
        }
        
        try 
        {
            var itemData:Object = item;
            for each (var pathElement:String in labelPath)
                itemData = itemData[pathElement];

            if (itemData != null)
                return itemData.toString();
        }
        catch(ignored:Error) { }
        
        return ERROR_TEXT;
    }
    
    /**
     *  Convert the specified dataProvider item to a column-specific String.   
     *  The value of this method is used to initialize item renderers' label property.
     * 
     *  <p>If labelFunction is null, and dataField is a string that does not contain "." 
     *  field name separator characters, then this method is equivalent to:
     *  <code>item[dataField].toString()</code>.   If dataField is a "." separated
     *  path, then this method looks up each successive path element.  For example if
     *  <code>="foo.bar.baz"</code> then this method would return
     *  the value of <code>item.foo.bar.baz</code>.   If resolving the item's dataField
     *  causes an error to be thrown, ERROR_TEXT is returned.</p>
     * 
     *  <p>If item and labelFunction are not null then this method returns 
     *  <code>labelFunction(item, this)</code>, where the second argument is
     *  this GridColumn.</p> 
     *
     *  @param item The value of <code>grid.dataProvider.getItemAt(rowIndex)</code>
     * 
     *  @return A column-specific string for the specified dataProvider item or ERROR_TEXT.
     */
    public function itemToLabel(item:Object):String
    {
        return GridColumn.itemToString(item, dataFieldPath, labelFunction, this);
    }

    /**
     *  Convert the specified dataProvider item to a column-specific dataTip String. 
     * 
     *  <p>This method uses the values dataTipField and dataTipFunction and if
     *  they're null, it uses the corresponding Grid properties.  If both dataTipField
     *  properties are null then the dataField property is used.</p>
     * 
     *  <p>If dataTipFunction is null, then this method is equivalent to:
     *  <code>item[dataTipField].toString()</code>.   If resolving the item's dataField
     *  causes an error to be thrown, ERROR_TEXT is returned.</p>
     * 
     *  <p>If item and dataTipFunction are not null then this method returns 
     *  <code>dataTipFunction(item, this)</code>, where the second argument is
     *  this GridColumn.</p> 
     *
     *  @param item The value of <code>grid.dataProvider.getItemAt(rowIndex)</code>
     * 
     *  @return A column-specific string for the specified dataProvider item or ERROR_TEXT.
     */
    public function itemToDataTip(item:Object):String
    {
        const tipFunction:Function = (dataTipFunction != null) ? dataTipFunction : grid.dataTipFunction;
        const tipField:String = (dataTipField) ? dataTipField : grid.dataTipField;
        const tipPath:Array = (tipField) ? [tipField] : dataFieldPath;
        
        return itemToString(item, tipPath, tipFunction);      
    }
    
    /**
     *  Convert the specified dataProvider item to a column-specific item renderer factory.
     *  By default this method calls the <code>itemRendererFunction</code> if it's 
     *  non-null, otherwise it just returns the value of the column's <code>itemRenderer</code> 
     *  property.
     *
     *  @param item The value of <code>grid.dataProvider.getItemAt(rowIndex)</code>
     * 
     *  @return A column-specific item renderer factory for the specified dataProvider item.
     */    
    public function itemToRenderer(item:Object):IFactory
    {
        const itemRendererFunction:Function = itemRendererFunction;
        return (itemRendererFunction != null) ? itemRendererFunction(item, this) : itemRenderer;
    }
    
    /**
     *  @private
     */
    private function dispatchChangeEvent(type:String):void
    {
        if (hasEventListener(type))
            dispatchEvent(new Event(type));
    }
    
    /**
     *  @private
     */
    private function invalidateGrid():void
    {
        if (grid)
        {
            grid.invalidateSize();
            grid.invalidateDisplayList();
        }
    }
}
}

