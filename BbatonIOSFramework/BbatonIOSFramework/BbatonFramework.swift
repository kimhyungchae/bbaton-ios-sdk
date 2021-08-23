//
//  BBatonFramework.swift
//  BbatonIOSFramework
//
//  Created by Wony Cho on 2021/08/20.
//

import Foundation

public class BbatonFramework: NSObject {
    
    public let clientId: String
    public let clientSecret: String
    public let redirectUrl: String
    
    
    public init(clientId: String, clientSecret: String, redirectUrl: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectUrl = redirectUrl
    }
    
    public func testShow(name: String) {
        print("**************")
        print("Welcome \(name)!!")
        print("CLIENT ID :: \(self.clientId)")
        print("CLIENT SECRET :: \(self.clientSecret)")
        print("REDIRECT URL :: \(self.redirectUrl)")
        print("**************")
    }
}
