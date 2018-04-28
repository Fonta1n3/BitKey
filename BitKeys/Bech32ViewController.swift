//
//  Bech32ViewController.swift
//  BitKeys
//
//  Created by Peter on 4/28/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit

class Bech32ViewController: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        <#code#>
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class bech32 {
        typealias StringCharacterByte = UInt8
        
        
        let CHARSET = byteConvert(string: "qpzry9x8gf2tvdw0s3jn54khce6mua7l")
        let GENERATOR = [0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3]
        
        
        func polymod(_ values: [Int]) -> Int {
            return values.reduce(1) { chk, value in
                let top = chk >> 25
                
                return (Int()..<5).reduce((chk & 0x1ffffff) << 5 ^ value) { chk, i in
                    guard (top >> i) & 1 > Int() else { return chk }
                    
                    return chk ^ GENERATOR[i]
                }
            }
        }
        
        func hrpExpand(_ hrp: [StringCharacterByte]) -> [StringCharacterByte] {
            return (Int()..<hrp.count).map { hrp[$0] >> 5 } + [StringCharacterByte()] + (Int()..<hrp.count).map { hrp[$0] & 31 }
        }
        
        func verifyChecksum(hrp: [StringCharacterByte], data: [StringCharacterByte]) -> Bool {
            return polymod((hrpExpand(hrp) + data).map { Int($0) }) == 1
        }
        
        func createChecksum(hrp: [StringCharacterByte], data: [StringCharacterByte]) -> [StringCharacterByte] {
            let values = (hrpExpand(hrp) + data + Array(repeating: StringCharacterByte(), count: 6)).map { Int($0) }
            let mod: Int = polymod(values) ^ 1
            
            return (Int()..<6).map { (mod >> (5 * (5 - $0))) & 31 }.map { StringCharacterByte($0) }
        }
        
        func byteConvert(string: String) -> [StringCharacterByte] {
            return string.characters.map { String($0).unicodeScalars.first?.value }.flatMap { $0 }.map { StringCharacterByte($0) }
        }
        
        func stringConvert(bytes: [StringCharacterByte]) -> String {
            return bytes.reduce(String(), { $0 + String(format: "%c", $1)})
        }
        
        func encode(hrp: [StringCharacterByte], data: [StringCharacterByte]) -> String {
            let checksum = createChecksum(hrp: hrp, data: data)
            
            return stringConvert(bytes: hrp) + "1" + stringConvert(bytes: (data + checksum).map { CHARSET[Int($0)] })
        }
        
        enum DecodeBech32Error: Error {
            case caseMixing
            case inconsistentHrp
            case invalidAddress
            case invalidBits
            case invalidCharacter(String)
            case invalidChecksum
            case invalidPayToHashLength
            case invalidVersion
            case missingSeparator
            case missingVersion
            
            var localizedDescription: String {
                switch self {
                case .caseMixing:
                    return "Mixed case characters are not allowed"
                    
                case .inconsistentHrp:
                    return "Internally inconsistent HRP"
                    
                case .invalidAddress:
                    return "Address is not a valid type"
                    
                case .invalidBits:
                    return "Bits are not valid"
                    
                case .invalidCharacter(let char):
                    return "Character \"\(char)\" is not valid"
                    
                case .invalidChecksum:
                    return "Checksum failed to verify data"
                    
                case .invalidPayToHashLength:
                    return "Unknown hash length for encoded output payload hash"
                    
                case .invalidVersion:
                    return "Invalid version number"
                    
                case .missingSeparator:
                    return "Missing address data separator"
                    
                case .missingVersion:
                    return "Missing address version"
                }
            }
        }
        
        func decode(bechString: String) throws -> (hrp: [StringCharacterByte], data: [StringCharacterByte]) {
            let bechBytes = byteConvert(string: bechString)
            
            guard !(bechBytes.contains() { $0 < 33 && $0 > 126 }) else { throw DecodeBech32Error.invalidCharacter(bechString) }
            
            let hasLower = bechBytes.contains() { $0 >= 97 && $0 <= 122 }
            let hasUpper = bechBytes.contains() { $0 >= 65 && $0 <= 90 }
            
            if hasLower && hasUpper { throw DecodeBech32Error.caseMixing }
            
            let bechString = bechString.lowercased()
            
            guard let pos = bechString.lastIndex(of: "1") else { throw DecodeBech32Error.missingSeparator }
            
            if pos < 1 || pos + 7 > bechString.characters.count || bechString.characters.count > 90 {
                throw DecodeBech32Error.missingSeparator
            }
            
            let bechStringBytes = byteConvert(string: bechString)
            let hrp = byteConvert(string: bechString.substring(to: bechString.index(bechString.startIndex, offsetBy: pos)))
            
            let data: [StringCharacterByte] = try ((pos + 1)..<bechStringBytes.count).map { i in
                guard let d = CHARSET.index(of: bechStringBytes[i]) else {
                    throw DecodeBech32Error.invalidCharacter(stringConvert(bytes: [bechStringBytes[i]]))
                }
                
                return UInt8(d)
            }
            
            guard verifyChecksum(hrp: hrp, data: data) else { throw DecodeBech32Error.invalidChecksum }
            
            return (hrp: hrp, data: Array(data[Int()..<data.count - 6]))
        }
        
        func convertbits(data: [StringCharacterByte], fromBits: Int, toBits: Int, pad: Bool) throws -> [StringCharacterByte] {
            var acc = Int()
            var bits = StringCharacterByte()
            let maxv = (1 << toBits) - 1
            
            let converted: [[Int]] = try data.map { value in
                if (value < 0 || (StringCharacterByte(Int(value) >> fromBits)) != 0) {
                    throw DecodeBech32Error.invalidCharacter(stringConvert(bytes: [value]))
                }
                
                acc = (acc << fromBits) | Int(value)
                bits += StringCharacterByte(fromBits)
                
                var values = [Int]()
                
                while bits >= StringCharacterByte(toBits) {
                    bits -= UInt8(toBits)
                    values += [(acc >> Int(bits)) & maxv]
                }
                
                return values
            }
            
            let padding = pad && bits > StringCharacterByte() ? [acc << (toBits - Int(bits)) & maxv] : []
            
            if !pad && (bits >= StringCharacterByte(fromBits) || acc << (toBits - Int(bits)) & maxv > Int()) {
                throw DecodeBech32Error.invalidBits
            }
            
            return ((converted.flatMap { $0 }) + padding).map { StringCharacterByte($0) }
        }
        
        func encode(hrp: [StringCharacterByte], version: UInt8, program: [UInt8]) throws -> String {
            let address = try encode(hrp: hrp, data: [version] + convertbits(data: program, fromBits: 8, toBits: 5, pad: true))
            
            // Confirm encoded address parses without error
            let _ = try decodeAddress(hrp: hrp, address: address)
            
            return address
        }
        
        func decodeAddress(hrp: [StringCharacterByte], address: String) throws -> (version: UInt8, program: [UInt8]) {
            let decoded = try decode(bechString: address)
            
            // Confirm decoded address matches expected type
            guard stringConvert(bytes: decoded.hrp) == stringConvert(bytes: hrp) else { throw DecodeBech32Error.inconsistentHrp }
            
            // Confirm version byte is present
            guard let versionByte = decoded.data.first else { throw DecodeBech32Error.missingVersion }
            
            // Confirm version byte is within the acceptable range
            guard !decoded.data.isEmpty && versionByte <= 16 else { throw DecodeBech32Error.invalidVersion }
            
            let program = try convertbits(data: Array(decoded.data[1..<decoded.data.count]), fromBits: 5, toBits: 8, pad: false)
            
            // Confirm program is a valid length
            guard program.count > 1 && program.count < 41 else { throw DecodeBech32Error.invalidAddress }
            
            if versionByte == UInt8() {
                // Confirm program is a known byte length (20 for pkhash, 32 for scripthash)
                guard program.count == 20 || program.count == 32 else { throw DecodeBech32Error.invalidPayToHashLength }
            }
            
            return (version: versionByte, program: program)
        }
        
        func segwitScriptPubKey(version: UInt8, program: [UInt8]) -> [UInt8] {
            return [version > UInt8() ? version + 0x50 : UInt8(), UInt8(program.count)] + program
        }

    }
    
   

}

extension String {
    func lastIndex(of string: String) -> Int? {
        guard let range = self.range(of: string, options: .backwards) else { return nil }
        
        return characters.distance(from: startIndex, to: range.lowerBound)
    }
}
