# Wallaby Clarity - IOS/UI and BLE
### Capstone Project | University of San Diego | Class of 2026 Sponsor: Tom Lupfer, Clarity Design

A Note to the Next Team
This app already has a strong UI foundation, BLE connection establishment with the hardware, and simulated data demonstrating the intended patient experience. The biggest opportunity moving forward is transforming the app from a functional prototype into a truly patient-centered healthcare application.
My biggest recommendation is to work directly with healthcare providers throughout the design process. If I were continuing this project, I would push even further into designing around patient psychology, recovery behavior, compliance motivation, and accessibility. Talk with providers one-on-one for UI design and use their suggestions. 
In terms of functionality, Bluetooth communication is established and working. The app successfully connects to the firmware board through BLE, and live sensor data is already visible in the Xcode console. However, that live data is not yet dynamically displayed onto the UI graphs themselves. Most graph visualizations currently use hardcoded demonstration data to simulate what the final experience would look like. The next major milestone is integrating live BLE sensor values directly into the graphing system and activity tracking interface.
Please do not underestimate how important it is to become comfortable with Xcode and SwiftUI before making major changes. Understanding SwiftUI and BLE architecture will save you a massive amount of debugging time later.
This project has a lot of potential!!!
— Parisa Hariri, iOS App/UI Lead, 2025-2026

## Project Overview
The Wallaby Clarity iOS App is designed to work alongside the wearable wrist range-of-motion monitoring device developed by the Wallaby Clarity capstone team. The app connects to the hardware through Bluetooth Low Energy (BLE) and is intended to help patients recovering from wrist injuries or surgeries monitor unsafe wrist movements during rehabilitation.
The application focuses heavily on user experience and accessibility. The interface provides compliance tracking, warning notifications, wrist movement visualizations, recovery summaries, and healthcare-approved educational resources related to ergonomics, carpal tunnel syndrome recovery, and wrist safety.
Current UI features include:
- BLE connection status monitoring
- Activity and compliance tracking
- Emoji-based recovery calendar
- Warning notifications
- Wrist movement graph demonstrations
- Daily recovery summaries
- Healthcare article integration
- Simulated long-term patient recovery data

## Current State of the App
What Works
BLE connection to the firmware board
- Detection of the TOF_Sensor
- Live sensor data output in Xcode console
- User interface and navigation system
- Simulated graph visualizations
- Compliance tracking system

## What Still Needs Work
- Real-time graph updates from live BLE data
- Dynamic UI updates using actual sensor values
- Improved graph accuracy and smoothing
- Long-term patient testing
- Expanded healthcare-provider feedback

## Getting Started
Requirements
- MacBook capable of running modern versions of Xcode
- iPhone compatible with Xcode deployment
- Apple Developer account (recommended)
- Basic understanding of Swift and SwiftUI

## Running the App
Download and open the project files in Xcode.
Connect your iPhone to your MacBook via cable.
Select your iPhone as the build target in Xcode.
Run the project.
The app should install directly onto your phone.
When the firmware device is powered on:
Xcode console will print BLE connection updates
The app should connect to TOF_Sensor
Bluetooth connection status will appear in the app Settings page
You can now navigate through the UI and test the existing prototype functionality.

## Bluetooth / Firmware Connection
The app communicates with the firmware board through Bluetooth Low Energy (BLE). Connection establishment is already functional and was tested extensively during development.
When connected successfully:
Xcode console prints connection confirmation
Live sensor values appear in the console
Settings page displays Bluetooth as connected
For detailed firmware setup and BLE architecture information, refer to the firmware repository:
Wallaby Firmware Repository


## Contact
Parisa Hariri — iOS App/UI Lead
Wallaby Clarity, USD Class of 2026
LinkedIn:  https://www.linkedin.com/in/parisahariri  
If you continue this project and have questions about the UI structure, BLE setup, SwiftUI navigation, or design process, feel free to reach out.
