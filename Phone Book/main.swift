//
//  main.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 11/20/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit

UIApplicationMain(CommandLine.argc,
                  UnsafeMutableRawPointer(CommandLine.unsafeArgv)
                    .bindMemory(
                        to: UnsafeMutablePointer<Int8>.self,
                        capacity: Int(CommandLine.argc)),
                  NSStringFromClass(TimerUIApplication.self),
                  NSStringFromClass(AppDelegate.self))
