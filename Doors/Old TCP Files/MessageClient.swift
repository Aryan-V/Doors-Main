//
//  MessageClient.swift
//  Doors
//
//  Created by Aryan Vaswani on 12/13/21.
//

import UIKit

protocol MessageClientDelegate: AnyObject {
  func received(message: String)
}

class MessageClient: NSObject {
    
    weak var delegate: MessageClientDelegate?
    
    let defaults = UserDefaults.standard
    
    var inputStream: InputStream!
    var outputStream: OutputStream!

    var username: String = ""

    let maxReadLength = 4096
    
    func setupNetworkCommunication() {
      var readStream: Unmanaged<CFReadStream>?
      var writeStream: Unmanaged<CFWriteStream>?

      CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                         "34.66.77.238" as CFString,
                                         8080,
                                         &readStream,
                                         &writeStream)
        
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        
        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)
        
        inputStream.open()
        outputStream.open()
    }
    
    func joinChat() {
        let data = "iam:\(self.defaults.string(forKey: "userName") ?? "")".data(using: .utf8)!
      
      //2
        self.username = self.defaults.string(forKey: "userName") ?? ""

        data.withUnsafeBytes {
        guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
          print("Error connecting")
          return
        }
        //4
        outputStream.write(pointer, maxLength: data.count)
      }
    }
    
    func send(message: String) {
      let data = "msg:\(message)".data(using: .utf8)!

        data.withUnsafeBytes {
        guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
          print("Error connecting")
          return
        }
        outputStream.write(pointer, maxLength: data.count)
      }
    }
    
    func stopMessageClient() {
      inputStream.close()
      outputStream.close()
    }


}

extension MessageClient: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
            readAvailableBytes(stream: aStream as! InputStream)
          print("new message received")
        case .endEncountered:
            stopMessageClient()
          print("new message received")
        case .errorOccurred:
          print("error occurred")
        case .hasSpaceAvailable:
          print("has space available")
        default:
          print("some other event...")
        }
    }
    
    private func readAvailableBytes(stream: InputStream) {
      let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)

      while stream.hasBytesAvailable {
        let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)

        if numberOfBytesRead < 0, let error = stream.streamError {
          print(error)
          break
        }

          if let message =
              processedMessageString(buffer: buffer, length: numberOfBytesRead) {

              delegate?.received(message: message)
          }
      }
    }
    
    private func processedMessageString(buffer: UnsafeMutablePointer<UInt8>,
                                        length: Int) -> String? {
      guard
        let stringArray = String(
          bytesNoCopy: buffer,
          length: length,
          encoding: .utf8,
          freeWhenDone: true)?.components(separatedBy: ":"),
        let name = stringArray.first,
        let message = stringArray.last
        else {
          return nil
      }

        return name + " is at " + message
    }
    
    
}
