//
//  Particle.swift
//  IPMenuletExample
//
//  Created by Chris Nielubowicz on 11/10/15.
//
//

import Foundation
import SwiftyJSON
import Keys

enum DeviceStatus: String {
    case Uninitialized
    case Occupied
    case Vacant
    case Error
    
    var image: NSImage {
        switch self {
        case .Uninitialized: return NSImage(named: "gray-circle")!
        case .Occupied: return NSImage(named: "red-circle")!
        case .Vacant: return NSImage(named: "green-circle")!
        case .Error: return NSImage(named: "warning-triangle")!
        }
    }
    
    init(deviceStatus: Int) {
        switch deviceStatus {
        case 0: self = .Vacant
        case 1: self = .Occupied
        default: self = .Error
        }
    }
}

struct ParticleDevice {
    
    var deviceID = "", deviceName = ""
    var status : DeviceStatus = .Uninitialized
    init(deviceJSON: Dictionary<String,JSON>) {
        deviceID = (deviceJSON["id"]?.string)!
        deviceName = (deviceJSON["name"]?.string)!
    }

}

extension ParticleDevice : Equatable { }

func ==(lhs: ParticleDevice, rhs: ParticleDevice) -> Bool {
    return lhs.deviceID == rhs.deviceID
}


class Particle {
    
    static let sharedInstance = Particle()

    private var OAuthToken : String?
    
    var OAuthClientId : String?
    var OAuthClientSecret : String?

    var timer : NSTimer?
    let authToken = WaterclosetmenuKeys().oAuthToken()

    func deviceStatus(device: ParticleDevice, completion: (deviceStatus: DeviceStatus) -> Void) -> Void {
        let deviceRequest = url(ParticleEndpoints.Variable(deviceName: device.deviceName,
            authToken: authToken,variableName: "ocupado"))
        let dataTask = NSURLSession.sharedSession().dataTaskWithURL(deviceRequest) { (data, _, error) -> Void in
            if (error != nil) {
                completion(deviceStatus: DeviceStatus.Error)
            }
            
            let deviceStatus = JSON(data: data!)
            let result = deviceStatus["result"]
            completion(deviceStatus: DeviceStatus(deviceStatus: result.intValue))
        }
        dataTask.resume()
    }
    
    func devices(completion: (devices: [ParticleDevice]?) -> Void) {
        let devicesRequest = url(ParticleEndpoints.Devices(authToken: authToken))
        let dataTask = NSURLSession.sharedSession().dataTaskWithURL(devicesRequest) { (data, _, error) -> Void in
            if (error != nil) {
                completion(devices: nil)
            }
            
            let devices = JSON(data:data!).arrayValue
            var deviceArray = Array<ParticleDevice>()
            for device in devices {
                let d = ParticleDevice(deviceJSON: device.dictionaryValue)
                deviceArray.append(d)
            }
            completion(devices: deviceArray)
        }
        dataTask.resume()
    }

    typealias DeviceStatusCompletion = (deviceStatus: DeviceStatus) -> Void
    var deviceStatusCompletion : DeviceStatusCompletion?
    var eventHandlerDevice : ParticleDevice?
    
    func subscribeEventHandler(timer: NSTimer) {
        if let device = eventHandlerDevice {
            deviceStatus(device, completion: deviceStatusCompletion!)
        }
    }
    
    func subscribeToDevice(device: ParticleDevice, completion:(deviceStatus: DeviceStatus) -> Void) -> Void {
        timer?.invalidate()
        deviceStatusCompletion = completion
        eventHandlerDevice = device
        if (timer == nil) {
            timer = NSTimer.scheduledTimerWithTimeInterval(5, target:self, selector: Selector("subscribeEventHandler:"), userInfo: nil, repeats: true)
        }
    }
    
    // MARK : Porting
    // MARK : Onboarding
    //-(void)loginWithUser:(NSString *)user password:(NSString *)password completion:(void (^)(NSError *error))completion;
    func login(withUser: String, password: String, completion: (error: NSError) -> Void) {
        let loginURL = url(ParticleEndpoints.Login(username: withUser, password: password))
        let loginRequest = NSMutableURLRequest(URL: loginURL)
        loginRequest.HTTPMethod = "POST"
        let postTask = NSURLSession.sharedSession().dataTaskWithRequest(loginRequest) { (data, response, error) -> Void in
           print(data)
            print(error)
        }
        
        postTask.resume()
    }
    
    //-(void)signupWithUser:(NSString *)user password:(NSString *)password completion:(void (^)(NSError *error))completion;
    //-(void)signupWithCustomer:(NSString *)email password:(NSString *)password orgSlug:(NSString *)orgSlug completion:(void (^)(NSError *))completion;
    //-(void)logout;

    // MARK :
    //-(void)getDevices:(void (^)(NSArray *sparkDevices, NSError *error))completion;
    //-(void)getDevice:(NSString *)deviceID completion:(void (^)(SparkDevice *, NSError *))completion;
    //// Not available yet
    ////-(void)publishEvent:(NSString *)eventName data:(NSData *)data;
    //-(void)claimDevice:(NSString *)deviceID completion:(void(^)(NSError *))completion;
    //-(void)generateClaimCode:(void(^)(NSString *claimCode, NSArray *userClaimedDeviceIDs, NSError *error))completion;
    //-(void)generateClaimCodeForOrganization:(NSString *)orgSlug andProduct:(NSString *)productSlug withActivationCode:(NSString *)activationCode completion:(void(^)(NSString *claimCode, NSArray *userClaimedDeviceIDs, NSError *error))completion;

}

//
//  SparkCloud.h
//  Particle iOS Cloud SDK
//
//  Created by Ido Kleinman
//  Copyright 2015 Particle
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//#import <Foundation/Foundation.h>
//#import "SparkDevice.h"
//#import "SparkEvent.h"
//
//extern NSString *const kSparkAPIBaseURL;
//
//@interface SparkCloud : NSObject
//
///**
//*  Currently loggeed in user name, nil if no session exists
//*/
//@property (nonatomic, strong, readonly) NSString* loggedInUsername;
//@property (nonatomic, readonly) BOOL isLoggedIn;
///**
//*  Current session access token string
//*/
//@property (nonatomic, strong, readonly) NSString *accessToken;

//
//#pragma mark User onboarding functions
//// --------------------------------------------------------------------------------------------------------------------------------------------------------
//// User onboarding functions
//// --------------------------------------------------------------------------------------------------------------------------------------------------------
//
///**
//*  Login with existing account credentials to Spark cloud
//*
//*  @param user       User name, must be a valid email address
//*  @param password   Password
//*  @param completion Completion block will be called when login finished, NSError object will be passed in case of an error, nil if success
//*/
//-(void)loginWithUser:(NSString *)user password:(NSString *)password completion:(void (^)(NSError *error))completion;
//
///**
//*  Sign up with new account credentials to Spark cloud
//*
//*  @param user       Required user name, must be a valid email address
//*  @param password   Required password
//*  @param completion Completion block will be called when sign-up finished, NSError object will be passed in case of an error, nil if success
//*/
//-(void)signupWithUser:(NSString *)user password:(NSString *)password completion:(void (^)(NSError *error))completion;
//
//
///**
//*  Sign up with new account credentials to Spark cloud
//*
//*  @param email      Required user name, must be a valid email address
//*  @param password   Required password
//*  @param orgSlug    Organization string to include in cloud API endpoint URL
//*  @param completion Completion block will be called when sign-up finished, NSError object will be passed in case of an error, nil if success
//*/
//-(void)signupWithCustomer:(NSString *)email password:(NSString *)password orgSlug:(NSString *)orgSlug completion:(void (^)(NSError *))completion;
//
///**
//*  Logout user, remove session data
//*/
//-(void)logout;
//
///**
//*  Request password reset for user or customer (organization mode)
//*  command generates confirmation token and sends email to customer using org SMTP settings
//*
//*  @param email      user email
//*  @param completion Completion block with NSError object if failure, nil if success
//*/
//-(void)requestPasswordResetForCustomer:(NSString *)orgSlug email:(NSString *)email completion:(void(^)(NSError *))completion;
//-(void)requestPasswordResetForUser:(NSString *)email completion:(void(^)(NSError *))completion;
//
//#pragma mark Device management functions
//// --------------------------------------------------------------------------------------------------------------------------------------------------------
//// Device management functions
//// --------------------------------------------------------------------------------------------------------------------------------------------------------
//
///**
//*  Get an array of instances of all user's claimed devices
//*  offline devices will contain only partial data (no info about functions/variables)
//*
//*  @param completion Completion block with the device instances array in case of success or with NSError object if failure
//*/
//-(void)getDevices:(void (^)(NSArray *sparkDevices, NSError *error))completion;
//
///**
//*  Get a specific device instance by its deviceID. If the device is offline the instance will contain only partial information the cloud has cached,
//*  notice that the the request might also take quite some time to complete for offline devices.
//*
//*  @param deviceID   required deviceID
//*  @param completion Completion block with first arguemnt as the device instance in case of success or with second argument NSError object if operation failed
//*/
//-(void)getDevice:(NSString *)deviceID completion:(void (^)(SparkDevice *, NSError *))completion;
//
//// Not available yet
////-(void)publishEvent:(NSString *)eventName data:(NSData *)data;
//
///**
//*  Claim the specified device to the currently logged in user (without claim code mechanism)
//*
//*  @param deviceID   required deviceID
//*  @param completion Completion block with NSError object if failure, nil if success
//*/
//-(void)claimDevice:(NSString *)deviceID completion:(void(^)(NSError *))completion;
//
///**
//*  Get a short-lived claiming token for transmitting to soon-to-be-claimed device in soft AP setup process
//*
//*  @param completion Completion block with claimCode string returned (48 random bytes base64 encoded to 64 ASCII characters), second argument is a list of the devices currently claimed by current session user and third is NSError object for failure, nil if success
//*/
//-(void)generateClaimCode:(void(^)(NSString *claimCode, NSArray *userClaimedDeviceIDs, NSError *error))completion;
//
//
///**
//*  Get a short-lived claiming token for transmitting to soon-to-be-claimed device in soft AP setup process for specific product and organization (different API endpoints)
//*  @param orgSlug - the organization slug string in URL
//*  @param productSlug - the product slug string in URL
//*  @param activationCode - optional (can be nil) activation code string for products in private-beta mode - see Particle Dashboard for product creators
//*
//*  @param completion Completion block with claimCode string returned (48 random bytes base64 encoded to 64 ASCII characters), second argument is a list of the devices currently claimed by current session user and third is NSError object for failure, nil if success
//*/
//-(void)generateClaimCodeForOrganization:(NSString *)orgSlug andProduct:(NSString *)productSlug withActivationCode:(NSString *)activationCode completion:(void(^)(NSString *claimCode, NSArray *userClaimedDeviceIDs, NSError *error))completion;
//
//
//#pragma mark Events subsystem functions
//// --------------------------------------------------------------------------------------------------------------------------------------------------------
//// Events subsystem:
//// --------------------------------------------------------------------------------------------------------------------------------------------------------
//
///**
//*  Subscribe to the firehose of public events, plus private events published by devices one owns
//*
//*  @param eventHandler SparkEventHandler event handler method - receiving NSDictionary argument which contains keys: event (name), data (payload), ttl (time to live), published_at (date/time emitted), coreid (device ID). Second argument is NSError object in case error occured in parsing the event payload.
//*  @param eventName    Filter only events that match name eventName, if nil is passed any event will trigger eventHandler
//*  @return eventListenerID function will return an id type object as the eventListener registration unique ID - keep and pass this object to the unsubscribe method in order to remove this event listener
//*/
//-(id)subscribeToAllEventsWithPrefix:(NSString *)eventNamePrefix handler:(SparkEventHandler)eventHandler;
///**
//*  Subscribe to all events, public and private, published by devices one owns
//*
//*  @param eventHandler     Event handler function that accepts the event payload dictionary and an NSError object in case of an error
//*  @param eventNamePrefix  Filter only events that match name eventNamePrefix, for exact match pass whole string, if nil/empty string is passed any event will trigger eventHandler
//*  @return eventListenerID function will return an id type object as the eventListener registration unique ID - keep and pass this object to the unsubscribe method in order to remove this event listener
//*/
//-(id)subscribeToMyDevicesEventsWithPrefix:(NSString *)eventNamePrefix handler:(SparkEventHandler)eventHandler;
//
///**
//*  Subscribe to events from one specific device. If the API user has the device claimed, then she will receive all events, public and private, published by that device.
//*  If the API user does not own the device she will only receive public events.
//*
//*  @param eventNamePrefix  Filter only events that match name eventNamePrefix, for exact match pass whole string, if nil/empty string is passed any event will trigger eventHandler
//*  @param deviceID         Specific device ID. If user has this device claimed the private & public events will be received, otherwise public events only are received.
//*  @param eventHandler     Event handler function that accepts the event payload dictionary and an NSError object in case of an error
//*  @return eventListenerID function will return an id type object as the eventListener registration unique ID - keep and pass this object to the unsubscribe method in order to remove this event listener
//*/
//-(id)subscribeToDeviceEventsWithPrefix:(NSString *)eventNamePrefix deviceID:(NSString *)deviceID handler:(SparkEventHandler)eventHandler;
//
///**
//*  Unsubscribe from event/events.
//*
//*  @param eventListenerID The eventListener registration unique ID returned by the subscribe method which you want to cancel
//*/
//-(void)unsubscribeFromEventWithID:(id)eventListenerID;
//
///**
//*  Subscribe to events from one specific device. If the API user has the device claimed, then she will receive all events, public and private, published by that device.
//*  If the API user does not own the device she will only receive public events.
//*
//*  @param eventName    Publish event named eventName
//*  @param data         A string representing event data payload, you can serialize any data you need to represent into this string and events listeners will get it
//*  @param private      A boolean flag determining if this event is private or not (only users's claimed devices will be able to listen to it)
//*  @param ttl          TTL stands for Time To Live. It it the number of seconds that the event data is relevant and meaningful. For example, an outdoor temperature reading with a precision of integer degrees Celsius might have a TTL of somewhere between 600 (10 minutes) and 1800 (30 minutes).
//*                      The geolocation of a large piece of farm equipment that remains stationary most of the time but may be moved to a different field once in a while might have a TTL of 86400 (24 hours). After the TTL has passed, the information can be considered stale or out of date.
//*/
//-(void)publishEventWithName:(NSString *)eventName data:(NSString *)data isPrivate:(BOOL)isPrivate ttl:(NSUInteger)ttl completion:(void (^)(NSError *))completion;
//
//
//@end