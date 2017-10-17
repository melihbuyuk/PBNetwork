//
//  Serializable.swift
//  NOCore
//
//  Created by Kasper Welner on 22/01/15.
//  Copyright (c) 2015 Nodes. All rights reserved.
//

import Foundation

// MARK: - Serializable -

public protocol Serializable: Decodable, Encodable {}

// MARK: - Encodable -

public protocol Encodable {
    func encodableRepresentation() -> NSCoding
}

// MARK: - Decodable -

public protocol Decodable {
    init(dictionary:NSDictionary?)
}

public extension Decodable {
    public static func array(_ source: Any?) -> [Self] {
        guard let source = source as? [NSDictionary] else {
            return [Self]()
        }
        return source.map {
            Self(dictionary: ($0))
        }
    }
}

public extension Decodable {

    public func mapped<T>(_ dictionary: NSDictionary?, key: String) -> T? where T:Decodable {

        guard let dict = dictionary else { return nil }
        let sourceOpt = dict[key]

        if sourceOpt != nil && sourceOpt is NSDictionary {
            return T(dictionary: (sourceOpt as! NSDictionary))
        }
        return nil
    }
    
    public func mapped<T>(_ dictionary: NSDictionary?, key: String) -> T? where T:Sequence, T.Iterator.Element: Decodable {
        guard let dict = dictionary, let sourceOpt = dict[key] else { return nil }

        if sourceOpt is [NSDictionary] {
            let source = (sourceOpt as! [NSDictionary])
            let finalArray = source.map { T.Iterator.Element.init(dictionary: $0) } as? T
            return finalArray
        }
        return nil
    }
    
    public func mapped<T>(_ dictionary: NSDictionary?, key: String) -> T? {

        guard let dict = dictionary else { return nil }
        let sourceOpt = dict[key]

        if let match = sourceOpt as? T {
            return match
        }

        switch sourceOpt {

        case (is String) where T.self is Int.Type:
            let source = (sourceOpt as! String)
            return Int(source) as? T

        case (is String) where T.self is Double.Type:
            let source = (sourceOpt as! String)
            return Double(source) as? T

        case (is NSString) where T.self is Bool.Type:
            let source = (sourceOpt as! NSString)
            return source.boolValue as? T

        case (is String) where T.self is Character.Type:
            let source = (sourceOpt as! String)
            return Character(source) as? T

        case (is NSNumber) where T.self is String.Type:
            let source = (sourceOpt as! NSNumber)
			return String(describing: source) as? T

        default:
            return nil
        }
    }

    public func mapped<T:StringInitializable>(_ dictionary: NSDictionary?, key: String) -> T? {
        if let dict = dictionary, let source = dict[key] as? String , source.isEmpty == false {
            return T.fromString(source)
        }
        return nil
    }

    public func mapped<T:RawRepresentable>(_ dictionary: NSDictionary?, key: String) -> T? {
        guard let source: T.RawValue = self.mapped(dictionary, key: key) else {
            return nil
        }
        return T(rawValue: source)
    }

    public func mapped<T>(_ dictionary: NSDictionary?, key: String) -> T? where T:Sequence, T.Iterator.Element: RawRepresentable {
        if let dict = dictionary, let source = dict[key] as? [T.Iterator.Element.RawValue] {
            let finalArray = source.map { T.Iterator.Element.init(rawValue: $0)! }
            return (finalArray as! T)
        }
        return nil
    }

	public func mapped<T: HexInitializable>(_ dictionary: NSDictionary?, key: String) -> T? {
		guard let dict = dictionary, let source = dict[key] else {
			return nil
		}
		if let hexString = source as? String , hexString.isEmpty == false {
			return T.fromHexString(hexString)
		}
		return source as? T
	}	
}
