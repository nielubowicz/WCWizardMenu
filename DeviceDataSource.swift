//
//  DeviceDataSource.swift
//  WaterClosetWizard
//
//  Created by Chris Nielubowicz on 11/8/15.
//  Copyright © 2015 Mobiquity, Inc. All rights reserved.
//

import AppKit
import Particle_SDK

enum DeviceStatus: Int {
    case Uninitialized = -1,
    Vacant = 0,
    Occupied = 1
}

protocol StatusImage {
    var image: NSImage { get }
}

extension DeviceStatus: StatusImage {
    var image: NSImage {
        switch self {
        case .Uninitialized:
            return NSImage(named: "gray-circle")!
        case .Vacant:
            return NSImage(named: "green-circle")!
        case .Occupied:
            return NSImage(named: "red-circle")!
        }
    }
}

class DeviceDataSource : NSObject {
    
    var objects = [ParticleDevice]()
    var reloadClosure: ((indexes:[Int]) -> ())?
    var insertClosure: ((indexes:[Int]) -> ())?
 
    init(objects: [ParticleDevice]) {
        self.objects = objects
    }
    
    func parseDevice(device: ParticleDevice!) {
        if (objects.contains(device)) {
            updateObject(device)
        } else {
            insertNewObject(device)
        }
    }
    
    func insertNewObject(device: ParticleDevice!) {
        objects.insert(device, atIndex: 0)
        let indexPath = 0
        insertClosure?(indexes: [indexPath])
    }
    
    func updateObject(device: ParticleDevice!) {
        guard let deviceIndex = objects.indexOf(device) else { return }
        
        objects[deviceIndex] = device;
        let indexPath = 0
        reloadClosure?(indexes: [indexPath])
    }
    
    func removeObject(device: ParticleDevice!) {
        guard let deviceIndex = objects.indexOf(device) else { return }
        
        objects.removeAtIndex(deviceIndex)
        let indexPath = deviceIndex
        
        reloadClosure?(indexes: [indexPath])
    }
}