//
//  EndpointProtocols.swift
//  IPMenuletExample
//
//  Created by Chris Nielubowicz on 11/10/15.
//
//

import Foundation

protocol Path {
    var path: String { get }
    var query: String? { get }
}

protocol BaseURL : Path {
    var baseURL: NSURL { get }
}

func url(route: BaseURL) -> NSURL {
    let baseURL = route.baseURL.URLByAppendingPathComponent(route.path)
    let components = NSURLComponents(URL: baseURL, resolvingAgainstBaseURL: true)
    components?.query = route.query
    
    return (components?.URL)!
}