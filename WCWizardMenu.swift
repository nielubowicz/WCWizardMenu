//
//  WCWizardMenu.swift
//  WCWizardMenu
//
//  Created by Chris Nielubowicz on 11/10/15.
//
//

import AppKit
import Keys
import Particle_SDK

class WCWizardMenu : NSObject {
    
    @IBOutlet var menuletMenu : NSMenu?
    var dataSource : DeviceDataSource?
    
    let particleService = Particle.sharedInstance
    var selectedDeviceStatus : DeviceStatus?
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    func updateDevice(device: ParticleDevice, completion: (DeviceStatus) -> Void) {
        device.getVariable("ocupado", completion: { (value, error) -> Void in
            guard value != nil else { self.dataSource?.removeObject(device); completion(DeviceStatus.Uninitialized); return }
            completion(DeviceStatus(rawValue: (value as? Int)!)!)
        })
    }
    
    override func awakeFromNib() {
        let keys = WaterclosetmenuKeys()
        particleService.OAuthClientId = keys.oAuthClientId()
        particleService.OAuthClientSecret = keys.oAuthSecret()
        particleService.OAuthToken = keys.oAuthToken()

        menuletMenu?.autoenablesItems = false
        menuletMenu?.delegate = self
        statusItem.highlightMode = true
        statusItem.enabled = true
        statusItem.target = self
        statusItem.menu = menuletMenu
        statusItem.image = DeviceStatus.Uninitialized.image
        
        particleService.getDevices { (devices, error) -> Void in
            self.dataSource = DeviceDataSource(objects: [])
            self.dataSource?.reloadClosure = {(indexes) in
                self.menuletMenu?.update()
            }
            self.dataSource?.insertClosure = {(indexes) in
                self.menuletMenu?.update()
            }
            
            for device in devices {
                self.dataSource?.parseDevice(device)
            }
            
            guard let device = devices.first else { return }
            self.updateDevice(device) { (deviceStatus) in
                self.statusItem.image = deviceStatus.image
                self.statusItem.toolTip = device.deviceName
            }
        }
    }
    
    @IBAction func updateSelectedDevice(sender: AnyObject) {
        guard let menuItem = sender as? NSMenuItem else { return }
        guard let device = menuItem.representedObject as? ParticleDevice else { return }
        updateDevice(device) { (deviceStatus) in
            self.statusItem.image = deviceStatus.image
            menuItem.image = deviceStatus.image
            self.statusItem.toolTip = device.deviceName
        }
    }
    
    @IBAction func updateDevices(sender: AnyObject?) {
        particleService.getDevices { (devices, error) -> Void in
            for device in devices {
                self.dataSource?.parseDevice(device)
            }
        }
    }
    
    @IBAction func quitAction(sender: AnyObject?) {
        NSApplication.sharedApplication().terminate(sender)
    }
}

extension WCWizardMenu : NSMenuDelegate {
    func numberOfItemsInMenu(menu: NSMenu) -> Int {
        guard let dataSource = self.dataSource else { return 2 }
        return dataSource.objects.count + 2
    }
    
    func menuNeedsUpdate(menu: NSMenu) {
        guard let dataSource = self.dataSource else { return }
        for device in dataSource.objects {
            if (menu.itemWithTag(device.id.hash) == nil) {
                let menuItem = NSMenuItem(title: device.deviceName, action: "updateSelectedDevice:", keyEquivalent: "")
                menuItem.representedObject = device
                menuItem.tag = device.id.hash
                menuItem.target = self
                menuItem.enabled = true
                menuItem.image = DeviceStatus.Uninitialized.image
                self.menuletMenu?.insertItem(menuItem, atIndex: 3)
                updateSelectedDevice(menuItem)
            }
        }
    }
    
    func menu(menu: NSMenu, updateItem item: NSMenuItem, atIndex index: Int, shouldCancel: Bool) -> Bool {
        return true
    }
}