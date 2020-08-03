//
//  Main.swift
//  asn1swift
//
//  Created by Pavel Tikhonenko on 27.07.2020.
//

import Foundation

struct BMask: OptionSet
{
	let rawValue: UInt8
	
	static let pepperoni    = BMask(rawValue: 1 << 0)
}

enum BMasks: UInt8
{
	case all 
	case none
}
class A
{
	var str: String = "12321#"
	var str2: String = "1232132432#"
}

struct B
{
	var shorInt: UInt8 = 8
	var str: String = "12321#"
	var shorInt2: UInt8 = 9
	var int: Int = 10
	
	var str2: String = "1232132432#"
	var c: Character = "C"
}

struct ReceiptPayload: ASN1Decodable
{
	static var template: ASN1Template
	{
		return ASN1Template.contextSpecific(0).constructed().explicit(tag: ASN1Identifier.Tag.octetString).explicit(tag: ASN1Identifier.Tag.set).constructed()
	}
	
	var attributes: [ReceiptAttribute]

	init(from decoder: Decoder) throws
	{
		var container = try decoder.unkeyedContainer()
		
		var attr: [ReceiptAttribute] = []
		while !container.isAtEnd
		{
			do
			{
				let element = try container.decode(ReceiptAttribute.self)
				attr.append(element)
			}catch{
				assertionFailure("Something wrong here")
			}
		}
		
		attributes = attr
	}
}

struct ReceiptAttribute: ASN1Decodable
{
	static var template: ASN1Template
	{
		return ASN1Template.universal(ASN1Identifier.Tag.sequence).constructed()
	}
	
	var type: Int
	var version: Int
	var value: Data
	
	enum CodingKeys: ASN1CodingKey
	{
		case type
		case version
		case value
		
		
		var template: ASN1Template
		{
			switch self
			{
			case .type:
				return .universal(ASN1Identifier.Tag.integer)
			case .version:
				return .universal(ASN1Identifier.Tag.integer)
			case .value:
				return .universal(ASN1Identifier.Tag.octetString)
			}
		}
	}
}

struct PKCS7: ASN1Decodable
{
	static var template: ASN1Template
	{
		return ASN1Template.universal(16).constructed()
	}

	struct SignedData: ASN1Decodable
	{
		static var template: ASN1Template
		{
			return ASN1Template.contextSpecific(0).constructed().explicit(tag: 16).constructed()
		}
	
		struct ContentData: ASN1Decodable
		{
			static var template: ASN1Template
			{
				return ASN1Template.universal(ASN1Identifier.Tag.sequence).constructed()
			}
			
			var oid: ASN1SkippedField
			var payload: ReceiptPayload
			
			enum CodingKeys: ASN1CodingKey
			{
				case oid
				case payload
				
				var template: ASN1Template
				{
					switch self
					{
					case .oid:
						return .universal(ASN1Identifier.Tag.objectIdentifier)
					case .payload:
						return ReceiptPayload.template
					}
				}
			}
		}
		
		var version: Int
		var alg: ASN1SkippedField
		var data: ContentData
		
		enum CodingKeys: ASN1CodingKey
		{
			case version
			case alg
			case data
			
			var template: ASN1Template
			{
				switch self
				{
				case .version:
					return .universal(ASN1Identifier.Tag.integer)
				case .alg:
					return ASN1Template.universal(ASN1Identifier.Tag.set).constructed()
				case .data:
					return ContentData.template
				}
			}
		}
	}
	
	var oid: ASN1SkippedField
	var signedData: SignedData
	
	enum CodingKeys: ASN1CodingKey
	{
		case oid
		case signedData
		
		var template: ASN1Template
		{
			switch self
			{
			case .oid:
				return .universal(ASN1Identifier.Tag.objectIdentifier)
			case .signedData:
				return SignedData.template
			}
		}
	}
}

struct DecodedStruct: ASN1Decodable
{
	static var template: ASN1Template
	{
		return ASN1Template.universal(16).constructed()
	}
	
	var a: Int
//	var b: Int
//	var inner: Inner
	
	enum CodingKeys: ASN1CodingKey
	{
		case a
//		case b
//		case inner
		
		var template: ASN1Template
		{
			switch self
			{
			case .a:
				return .universal(ASN1Identifier.Tag.integer)
				//		case .b:
				//			return 0x04
				//		case .inner:
				//			return 0x33
			}
		}
	}
}


func start()
{
	var bytes: [UInt8] = [0x02, 0x01, 0xa0];
	
	let asn1Decoder = ASN1Decoder()
	let integer = try! asn1Decoder.decode(Int.self, from: Data(bytes))
	
	bytes = [0x30, 0x03, 0x02, 0x01, 0xa0];
	
	let obj = try! asn1Decoder.decode(DecodedStruct.self, from: Data(bytes))
	print("coool", integer, obj)
}

