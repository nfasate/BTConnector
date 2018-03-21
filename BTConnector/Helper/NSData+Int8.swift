import Foundation

extension Data {
    static func dataWithValue(value: String) -> Data {
        var variableValue = value
        return Data(buffer: UnsafeBufferPointer(start: &variableValue, count: 1))
    }

    func int8Value() -> Int8 {
        return Int8(bitPattern: self[0])
    }
}
