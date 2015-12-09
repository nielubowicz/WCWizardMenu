//
//  ParticleURLs.swift
//  IPMenuletExample
//
//  Created by Chris Nielubowicz on 11/10/15.
//
//

import Foundation

enum ParticleEndpoints {
    case Login(username:String, password:String)
    case Devices(authToken:String)
    case Variable(deviceName:String, authToken:String, variableName:String)
    case SubscribeToEvents(authToken:String)
}

extension ParticleEndpoints : Path {
    var path: String {
        switch self {
        case .Login(_, _):
            return "/oauth/token"
        case .Devices(_):
            return "/devices/"
        case .Variable(let deviceName, _, let variableName):
            return "/devices/\(deviceName)/\(variableName)"
        case .SubscribeToEvents(_):
            return "/events/occupancy-change"
        }
    }
    
    var query: String? {
        switch self {
        case .Login(let username, let password):
            return "username=\(username)&password=\(password)"
        case .Devices(let authToken):
            return "access_token=\(authToken)"
        case .Variable(_, let authToken, _):
            return "access_token=\(authToken)"
        case .SubscribeToEvents(let authToken):
            return "access_token=\(authToken)"
        }
    }
}

extension ParticleEndpoints : BaseURL {
    var baseURL: NSURL { return (NSURL(string:"https://api.particle.io/v1"))! }
}

