import Foundation

public struct UserData: Codable {
    public var userId: String?
    public var email: String?
    public var name: String?
    public var metadata: [String: JSONValue]?
    
    public init(
        userId: String? = nil,
        email: String? = nil,
        name: String? = nil,
        metadata: [String: JSONValue]? = nil
    ) {
        self.userId = userId
        self.email = email
        self.name = name
        self.metadata = metadata
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case name
        case metadata
    }
}

public enum JSONValue: Codable, Equatable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case null
    case array([JSONValue])
    case object([String: JSONValue])
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .null
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let double = try? container.decode(Double.self) {
            self = .number(double)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([JSONValue].self) {
            self = .array(array)
        } else if let dictionary = try? container.decode([String: JSONValue].self) {
            self = .object(dictionary)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid JSON value"
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        case .array(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        }
    }
}

extension JSONValue {
    public init(_ value: String) {
        self = .string(value)
    }
    
    public init(_ value: Int) {
        self = .number(Double(value))
    }
    
    public init(_ value: Double) {
        self = .number(value)
    }
    
    public init(_ value: Bool) {
        self = .bool(value)
    }
    
    public init(_ value: [JSONValue]) {
        self = .array(value)
    }
    
    public init(_ value: [String: JSONValue]) {
        self = .object(value)
    }
}

extension UserData {
    func asDictionary() throws -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(self)
        
        guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ChatError.bridgeError("Failed to convert UserData to dictionary")
        }
        
        return dictionary
    }
}
