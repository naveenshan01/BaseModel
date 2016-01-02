//
//  BaseModel.swift
//  <>
//
//  Created by Naveen Shan.
//  Copyright © 2015. All rights reserved.
//

import Foundation

public class BaseModel: NSObject {
    private var propertyNames: Array<String>?
    
    required public init(content: Dictionary<String, AnyObject>) {
        super.init()
        self.setContents(content)
    }
    
    //MARK: -

    public class func arrayClassMapping() -> Dictionary<String, AnyClass>? {
        return nil
    }
    
    public class func dictionaryClassMapping() -> Dictionary<String, AnyClass>? {
        return nil
    }
    
    public class func privateProperties() -> Array<String>? {
        return nil
    }
    
    public class func propertiesMap() -> Dictionary<String, String>? {
        return nil
    }
    
    //MARK: -

    func allPropertyNames() -> Array<String>? {
        if self.propertyNames != nil {
            return self.propertyNames!
        }
        
        var currentClass: AnyClass = self.dynamicType
        var propertyValues: Array<String> = []

        repeat {
            var count: UInt32 = 0
            let properties = class_copyPropertyList(currentClass, &count);
            for var i = 0; i < Int(count); i++ {
                let property = properties[Int(i)];
                // retrieve the property name by calling property_getName function
                let cname = property_getName(property);
                // covert the c string into a Swift string
                let name = String.fromCString(cname);
                propertyValues.append(name!);
            }
            
            let pvtProperties = currentClass.privateProperties()
            
            propertyValues = propertyValues.filter({ (value: String) -> Bool in
                return !(pvtProperties!.contains(value))
            })
            
            free(properties)
            
            currentClass = currentClass.superclass()!

        } while currentClass != BaseModel.self
        self.propertyNames = propertyValues
        
        return self.propertyNames
    }
    
    
//    func allPropertyNames() -> Array<String>? {
//        if self.propertyNames != nil {
//            return self.propertyNames!
//        }
//        
//        var count: UInt32 = 0
//        let properties = class_copyPropertyList(self.dynamicType, &count);
//        var propertyValues: Array<String> = []
//        for var i = 0; i < Int(count); i++ {
//            let property = properties[Int(i)];
//            // retrieve the property name by calling property_getName function
//            let cname = property_getName(property);
//            // covert the c string into a Swift string
//            let name = String.fromCString(cname);
//            propertyValues.append(name!);
//        }
//        
//        let pvtProperties = self.dynamicType.privateProperties()
//        
//        propertyValues = propertyValues.filter({ (value: String) -> Bool in
//            return !(pvtProperties!.contains(value))
//        })
//        
//        free(properties);
//
//        self.propertyNames = propertyValues
//        return self.propertyNames
//    }
    
    func convertValueDataTypeToKVOIfRequired(var value: AnyObject?) -> AnyObject? {
        if value == nil  {
            return value
        }
        if let aValue = value as? Array<AnyObject> {
            value = self.dynamicType.arrayWithModel(aValue)
        }
        else if let aValue = value as? BaseModel {
            value = aValue.dictionary()
        }
        return value
    }
    
    func convertValueDataTypeFromKVOIfRequired(var value: AnyObject?, property: String) -> AnyObject? {
        if value == nil {
            return value
        }
        if let aValue = value as? Array<AnyObject> {
            let arrayMapping = self.dynamicType.arrayClassMapping()
            let classType: AnyClass = (arrayMapping?[property])!

            if let aClassType = classType as? BaseModel.Type {
                value = aClassType.arrayWithArray(aValue)
            }
        }
        else if let aValue = value as? Dictionary<String, AnyObject> {
            let arrayMapping = self.dynamicType.dictionaryClassMapping()
            let classType: AnyClass = (arrayMapping?[property])!
            
            if let aClassType = classType as? BaseModel.Type {
                value = aClassType.init(content: aValue)
            }
        }
        return value
    }
    
    func setContents(content: Dictionary<String, AnyObject>) {
        let propertyNames = self.allPropertyNames()
        
        for property in propertyNames! {
            var propertiesMapKey = self.dynamicType.propertiesMap()?[property]
            if propertiesMapKey == nil {
                propertiesMapKey = property
            }
            
            let value: AnyObject? = content[propertiesMapKey!]
            
            if (value != nil && !(value is NSNull)) {

                self.setValue(value, forKey: property)
            }
        }
    }
    
    //MARK: -
    
    public func dictionary() -> Dictionary<String, AnyObject> {
        let propertyNames = self.allPropertyNames()
        var contents = Dictionary<String, AnyObject>(minimumCapacity: propertyNames!.count)
        for property in propertyNames! {
            var value = self.valueForKey(property)
            value =  self.convertValueDataTypeToKVOIfRequired(value)
            
            if value != nil && !(value is NSNull) {
                var propertiesMapKey = self.dynamicType.propertiesMap()?[property]
                if propertiesMapKey == nil {
                    propertiesMapKey = property
                }
                contents[propertiesMapKey!] = value
            }
        }
        return contents
    }

    public class func arrayWithArray(contents: Array<AnyObject>) -> Array<AnyObject>? {
        var array: Array<AnyObject> = []
        for content in contents {
            let dict = content as? Dictionary<String, AnyObject>
            let object = BaseModel(content: dict!)
            array.append(object)
        }
        return array
    }
    
    class func arrayWithModel(contents: Array<AnyObject>) -> Array<AnyObject>? {
        var array: Array<AnyObject> = []
        for content in contents {
            let model = content as? BaseModel
            if model?.dictionary != nil {
                array.append(model!.dictionary())
            }
            else {
                array.append(content)
            }
        }
        return array
    }
    
    public class func objectFromDictionary(dictionary: Dictionary<String, AnyObject>) -> Self {
        return self.init(content: dictionary)
    }
    

    
}







