//
//  NSObject+ParseToDic.swift
//  touzhong
//
//  Created by zerlinda on 16/9/6.
//  Copyright © 2016年 zerlinda. All rights reserved.
//

import Foundation

extension NSObject{
    var keyValues:[String:AnyObject]?{                   //获取一个模型对应的字典
        get{
            var result = [String: AnyObject]()           //保存结果
            var classType:AnyClass = self.classForCoder
            while("NSObject" !=  "\(classType)" ){
                var count:UInt32 = 0
                let properties = class_copyPropertyList(classType, &count)
                for i in 0..<count{
                    let property = properties?[Int(i)]
                    var propertyKey = String(cString: property_getName(property))         //模型中属性名称
                    if propertyKey == "desc" {
                        propertyKey = "description"
                    }
                    let propertyType = String(cString: property_getAttributes(property))  //模型中属性类型
                    
                    let tempValue:AnyObject!  = self.value(forKey: propertyKey) as AnyObject!
                    if  tempValue == nil { continue }
                    
                    if let _ =  HEFoundation.getType(propertyType) {         //1,自定义的类
                        result[propertyKey] = tempValue.keyValues as AnyObject?
                    }else if (propertyType.contains("NSArray")){       //2, 数组, 将数组中的模型转成字典
                        result[propertyKey] = tempValue.keyValuesArray as AnyObject?       //3， 基本数据
                    }else{
                        result[propertyKey] = tempValue
                    }
                }
                free(properties)
                classType = classType.superclass()!
            }
            if result.count == 0{
                return nil
            }else{
                return result
            }
            
        }
    }
}

extension NSArray{  //数组的拓展
    var keyValuesArray:[AnyObject]?{
        get{
            var result = [AnyObject]()
            for item in self{
                if !HEFoundation.isClassFromFoundation((item as AnyObject).classForCoder){ //1,自定义的类
                    let subKeyValues:[String:AnyObject]! = (item as AnyObject).keyValues
                    if  subKeyValues == nil {continue}
                    result.append(subKeyValues as AnyObject)
                }else if (item as AnyObject).classForCoder == NSArray.classForCoder(){    //2, 如果item 是数组
                    let subKeyValues:[AnyObject]! = (item as AnyObject).keyValuesArray
                    if  subKeyValues == nil {continue}
                    result.append(subKeyValues as AnyObject)
                }else{                                                     //3, 基本数据类型
                    result.append(item as AnyObject)
                }
            }
            if result.count == 0{
                return nil
            }else{
                return result
            }
            
        }
    }
}
