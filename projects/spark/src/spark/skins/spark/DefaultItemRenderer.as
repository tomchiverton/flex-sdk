<?xml version="1.0" encoding="utf-8"?>

<!--

	ADOBE SYSTEMS INCORPORATED
	Copyright 2008 Adobe Systems Incorporated
	All Rights Reserved.

	NOTICE: Adobe permits you to use, modify, and distribute this file
	in accordance with the terms of the license agreement accompanying it.

-->

<ItemRenderer xmlns="http://ns.adobe.com/mxml/2009">
	
    <states>
		<State name="normal"/>			
		<State name="hovered"/>
		<State name="selected"/>
	</states>
	
    <content>
		<Rect left="0" right="0" top="0" bottom="0">
			<fill>
				<SolidColor color="0x00FFFF"
                            alpha="0" alpha.hovered="0.2" alpha.selected="0.8" />
			</fill>
		</Rect>
		<Group id="contentHolder" content="{data}"
               left="0" right="0" top="0" bottom="0"
               layout="flex.layout.HorizontalLayout" />
	</content>

</ItemRenderer>
