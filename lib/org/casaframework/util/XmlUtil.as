/*
	CASA Framework for ActionScript 2.0
	Copyright (C) 2006  CASA Framework
	http://casaframework.org
	
	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.
	
	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.
	
	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

import org.casaframework.util.TypeUtil;

/**
	@author Aaron Clinger
	@author Mike Creighton
	@version 12/14/06
*/

class org.casaframework.util.XmlUtil {
	
	/**
		Traverses through the child nodes and returns the first node it finds that matches specified name.
		
		@param context: Node that contains the child nodes you are searching.
		@param name: Name of the target node.
		@return Returns the first node that matched specified name.
	*/
	public static function getChildNodeByName(context:XMLNode, name:String):XMLNode {
		var i:Number = -1;
		var childNode:XMLNode;
		
		while (++i < context.childNodes.length) {
			childNode = context.childNodes[i];
			
			if (childNode.nodeName == name)
				return childNode;
		}
		
		return undefined;
	}
	
	/**
		Traverses through the child nodes and returns all nodes it finds that matches specified name.
		
		@param context: Node that contains the child nodes you are searching.
		@param name: Name of the target nodes.
		@return Returns an Array comprised of nodes that matched specified name.
	*/
	public static function getChildNodesByName(context:XMLNode, name:String): /*XMLNode*/ Array {
		var i:Number                 = -1;
		var nodes: /*XMLNode*/ Array = new Array();
		var childNode:XMLNode;
		
		while (++i < context.childNodes.length) {
			childNode = context.childNodes[i];
			
			if (childNode.nodeName == name)
				nodes.push(childNode);
		}
		
		return nodes;
	}
	
	/**
		Traverses through the child nodes and returns the text content of the first node it finds that matches specified name.
		
		@param context: Node that contains the child nodes you are searching.
		@param name: Name of the target node.
		@return Returns the text value of the node.
	*/
	public static function getTextOfChildNodeByName(context:XMLNode, name:String):String {
		var node:XMLNode = XmlUtil.getChildNodeByName(context, name);
		
		if (node.firstChild.nodeType == 3)
			return node.firstChild.nodeValue;
		
		return undefined;
	}
	
	/**
		Traverses through the child nodes and returns the text content of the first node it finds that matches specified name.
		
		@param context: Node that contains the child nodes you are searching.
		@param name: Name of the target nodes.
		@return Returns an Array comprised of the text values of the nodes that matched specified name.
	*/
	public static function getTextOfChildNodesByName(context:XMLNode, name:String): /*String*/ Array {
		var nodes: /*XMLNode*/ Array    = XmlUtil.getChildNodesByName(context, name);
		var textNodes: /*String*/ Array = new Array();
		var i:Number                    = -1;
		var node:XMLNode;
		
		while (++i < nodes.length) {
			node = nodes[i];
			
			if (node.firstChild.nodeType == 3)
				textNodes.push(node.firstChild.nodeValue);
		}
		
		return textNodes;
	}
	
	/**
		Returns an easily navigable object from XML.
		
		@param xmlData: Defined or loaded XML to be coverted.
		@param convertNumbers: <strong>[optional]</strong> Indicates to either convert number strings to numbers <code>true</code>, or leave all numbers as strings <code>false</code>; defaults to <code>true</code>.
		@param convertBooleans: <strong>[optional]</strong> Indicates to either convert <code>"true"</code>/<code>"false"</code> strings to proper booleans <code>true</code>, or leave all booleans as strings <code>false</code>; defaults to <code>true</code>.
		@return An Object comprised of Arrays.
		@example
			<code>
				var birthdayXml:XML = new XML("<birthday><people><person><name>Aaron Clinger</name><birthdate month=\"January\" day=\"11\" /></person><person><name>John Doe</name><birthdate month=\"April\" day=\"21\" /></person></people></birthday>");
				
				var xmlObject:Object = XmlUtil.xmlToObject(this.birthdayXml);
				
				trace("Name is " + this.xmlObject.birthday[0].people[0].person[1].name[0]);
				trace("Day born is " + this.xmlObject.birthday[0].people[0].person[1].birthdate[0].day);
			</code>
	*/
	public static function xmlToObject(xmlData:XML, convertNumbers:Boolean, convertBooleans:Boolean):Object {
		var obj:Object = new Object();
		
		XmlUtil.$createChildNodeObjects(obj, xmlData.childNodes, (convertNumbers == undefined) ? true : convertNumbers, (convertBooleans == undefined) ? true : convertBooleans);
		
		return obj;
	}
	
	/**
		Returns XML converted from an Object.
		
		@param objectData: Basic Object to be coverted. 
		@return XML Object comprised of passed Object's data.
		@example
			<code>
				var xmlObject:Object = new Object();
				this.xmlObject.wrapper = new Object();
				this.xmlObject.wrapper.group = "friends";
				this.xmlObject.wrapper.name = new Array("Greg", "Jose", "Dave", "Toby");
				
				var xmlData:XML = XmlUtil.objectToXml(this.xmlObject);
				
				trace(this.xmlData);
			</code>
		@usageNote {@link #objectToXml} ignores <code>function</code>, <code>Button</code>, <code>TextField</code> and <code>MovieClip</code>.
	*/
	public static function objectToXml(objectData:Object):XML {
		return XmlUtil.$createXMLNodesFromObject(objectData);
	}
	
	/**
		Traverses recursively through an XMLNode and its children returning the value of all text within.
		
		@param node: XMLNode to be traversed.
		@return String containing all text nodes' nodeValues concatenated together.
	*/
	public static function extractText(node:XMLNode):String {
		var outputStr:String = '';
		
		switch(node.nodeType) {
			case 3: // Text node here.
				outputStr += node.nodeValue;
				break;
			case 1: // Element node
				if (node.hasChildNodes()) {
					var c:Number = -1;
					while(++c < node.childNodes.length)
						outputStr += XmlUtil.extractText(node.childNodes[c]);
				}
				break;
		}
		
		return outputStr;
	}
	
	private static function $createXMLNodesFromObject(targetObj:Object, containerName:String, areAttributes:Boolean):XML {
		var x:XML = new XML();
		var node:XMLNode;
		
		if (areAttributes)
			node = x.createElement(containerName);
		
		for (var i:String in targetObj) {
			switch (TypeUtil.getTypeOf(targetObj[i])) {
			case 'string' :
			case 'number' :
			case 'boolean' :
				if (areAttributes)
					node.attributes[i] = targetObj[i];
				else {
					node = x.createElement(isNaN(i) ? i : containerName);
					node.appendChild(x.createTextNode(targetObj[i]));
					x.appendChild(node);
				}
				break;
			case 'array' :
				if (areAttributes)
					node.appendChild(XmlUtil.$createXMLNodesFromObject(targetObj[i], i));
				else
					x.appendChild(XmlUtil.$createXMLNodesFromObject(targetObj[i], i));
				break;
			case 'object' :
				if (areAttributes)
					node.appendChild(XmlUtil.$createXMLNodesFromObject(targetObj[i], i, true));
				else
					x.appendChild(XmlUtil.$createXMLNodesFromObject(targetObj[i], i, true));
				break;
			}
		}
		
		if (areAttributes)
			x.appendChild(node);
		
		return x;
	}
	
	private static function $createChildNodeObjects(targetObj:Object, nodeList:Array, convertNumbers:Boolean, convertBooleans:Boolean):Void {
		var nName:String;
		
		for (var i:String in nodeList) {
			nName = nodeList[i].nodeName;
			
			if (nName == null)
				break;
			
			if (targetObj[nName] == undefined)
				targetObj[nName] = new Array();
			
			targetObj[nName].splice(0, 0, XmlUtil.$getNodeObject(nodeList[i], convertNumbers, convertBooleans));
		}
	}
	
	private static function $getNodeObject(xmlNode:Object, convertNumbers:Boolean, convertBooleans:Boolean):Object {
		var nodeObject:Object = new Object();
		var xmlProperty:String;
		
		for (var p:String in xmlNode.attributes) {
			xmlProperty = xmlNode.attributes[p].toString();
			
			if (convertBooleans && xmlProperty == 'true' || xmlProperty == 'false') {
				nodeObject[p] = (xmlProperty == 'true') ? true : false;
				break;
			}
			
			if (convertNumbers && !isNaN(xmlProperty)) {
				nodeObject[p] = Number(xmlProperty);
				break;
			}
			
			nodeObject[p] = xmlProperty;
		}
		
		var firstChildValue:Object = xmlNode.firstChild.nodeValue;
		
		if (firstChildValue != null) {
			if (convertBooleans && firstChildValue == 'true' || firstChildValue == 'false')
				firstChildValue = (firstChildValue == 'true') ? true : false;
			
			if (convertNumbers && !isNaN(firstChildValue))
				firstChildValue = Number(firstChildValue);
			
			nodeObject = firstChildValue;
		} else {
			XmlUtil.$createChildNodeObjects(nodeObject, xmlNode.childNodes, convertNumbers, convertBooleans);
		}
		
		return nodeObject;
	}
	
	private function XmlUtil() {} // Prevents instance creation
}
