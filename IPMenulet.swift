//
//  IPMenulet.swift
//  IPMenuletExample
//
//  Created by Chris Nielubowicz on 11/10/15.
//
//

import AppKit

class IPMenulet : NSObject {
    
    @IBOutlet var menuletMenu : NSMenu?
    var dataSource : DeviceDataSource?
    
    let particleService = Particle()
    var devices = Array<ParticleDevice>()
    var selectedDevice : ParticleDevice?
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    func updateDevice(var device: ParticleDevice, completion: (ParticleDevice) -> Void) {
        particleService.deviceStatus (device) { (deviceStatus) -> Void in
            device.status = deviceStatus
            completion(device)
        }
    }
    
    override func awakeFromNib() {
        menuletMenu?.autoenablesItems = false
        menuletMenu?.delegate = self
        statusItem.highlightMode = true
        statusItem.enabled = true
        statusItem.toolTip = "IPMenulet"
        statusItem.target = self
        statusItem.menu = menuletMenu
        statusItem.image = DeviceStatus.Uninitialized.image
        
        particleService.devices {(devices) -> Void in
            self.dataSource = DeviceDataSource(objects: [])
            self.dataSource?.reloadClosure = {(indexes) in
                self.menuletMenu?.update()
            }
            self.dataSource?.insertClosure = {(indexes) in
                self.menuletMenu?.update()
            }
            
            self.devices = devices!
            for device in self.devices {
                self.dataSource?.parseDevice(device)
            }
            
            self.selectedDevice = self.devices.first!
            self.updateDevice(self.selectedDevice!) { (device) in
                self.statusItem.image = device.status.image
            }

            self.particleService.subscribeToDevice(self.devices.first!) { (deviceStatus) -> Void in
                self.statusItem.image = deviceStatus.image
            }
        }
    }
    
    @IBAction func updateIPAddress(sender: AnyObject?) {
        if (devices.isEmpty == false) {
            updateDevice(devices.first!) { (device) in
                self.statusItem.image = device.status.image
            }
        }
    }
    
    @IBAction func updateSelectedDevice(sender: AnyObject) {
        print(sender)
    }
    
    @IBAction func updateDevices(sender: AnyObject?) {
        particleService.devices {(devices) -> Void in
            self.devices = devices!
            for device in self.devices {
                self.dataSource?.parseDevice(device)
            }
        }
    }
    
    @IBAction func quitAction(sender: AnyObject?) {
        NSApplication.sharedApplication().terminate(sender)
    }
}

extension IPMenulet : NSMenuDelegate {
    func numberOfItemsInMenu(menu: NSMenu) -> Int {
        return self.devices.count + 3
    }
    
    func menuNeedsUpdate(menu: NSMenu) {
        for device in self.devices {
            if (menu.itemWithTag(device.deviceID.hash) == nil) {
                let menuItem = NSMenuItem(title: device.deviceName, action: "updateSelectedDevice:", keyEquivalent: "")
                menuItem.tag = device.deviceID.hash
                menuItem.target = self
                menuItem.enabled = true
                menuItem.image = device.status.image
                self.menuletMenu?.insertItem(menuItem, atIndex: 3)
            }
        }
    }
    
    func menu(menu: NSMenu, updateItem item: NSMenuItem, atIndex index: Int, shouldCancel: Bool) -> Bool {
        
        return true
    }
    
}