Telephaty IOS
===============

**API that allows you send broadcast and direct messages using bluetooth without paring devices**


Supported OS & SDK Versions
-----------------------------

* Supported build target - iOS 8.1 / Mac OS 10.10 (Xcode 6.1, Apple LLVM compiler 6.0)
* Earliest supported deployment target - iOS 7.0


Installation
--------------

To install Telepahty into your app, drag the Telephaty_APi into your project.

iRate typically requires no configuration at all and will simply run automatically, using the application's bundle ID to look the app ID up on the App Store.


Configuration
--------------

To configure Telephaty, there are a number of values of the KNConfigurationService class that you must provide:
	
Needed UUID for the service. This identifies the service to listen for app.	
	TELEPHATY_SERVICE_UUID   

UUID for the characteristic where the app will write and send the message.
	TELEPHATY_CHARACTERISTIC_UUID  

Indicate how much old will be the messages that will be removed from DB periodically.
	REMOVE_MESSAGES_OLDER_THAN_MINUTES  15

Key used to AES 256-bit encryption in broadcast messages
	PASS_AES_ENCRYPTION

Public key for RSA encryption in direct messages 1024 bits. The Api implements RSA Encryption for directs messages but it's not beein used at the moment
since the System no allow to send more than 132 bytes updating the value for a characteristic of a bluetooth service. So you not needed to provide 
this values at the moment.

	RSA_PUBLIC_KEY   
	RSA_PRIVATE_KEY
	

Methods
--------------

Besides configuration, Telephaty has the following methods:

	- (void)startWatch;

Starts listening for messages.

	- (void)startEmit;

Start advertising of device.

	- (void)sendMessage:(NSString *)message withJumps:(NSInteger)jumps;

Send a message to be recieved for all devices listening the service. Jumps allow a value (0-9), indicate the number of times that the
message will be resend.

	- (void)sendMessage:(NSString *)message withJumps:(NSInteger)jumps to:(NSString *)to;

Send a message to device indentified by its ID.


- (void)resendMessage:(MessageData *)message;

Resend a meesage received decrementing jumps by 1.


- (NSString *)decryptedMessage:(MessageData *)messageToDecrypt;

Return the decrypted message



Delegate methods
---------------

The KNTelephatyServiceDelegate protocol provides the following method that is used to inform about the reception of a new message:

    - (void)telephatyServiceDidReceiveMessage:(MessageData *)message;



Example Project
---------------

The best way to see how to use this Api is to run the sample project provided. This is a simple chat.
To do the sample project we've use the JQMessage library create by Jesse Squires http://www.jessesquires.com

Documentation
	http://cocoadocs.org/docsets/JSQMessagesViewController

GitHub
	https://github.com/jessesquires/JSQMessagesViewController


## Contact

[Someone](http://www.site.com)

For more info contact us in mail@mail.com

## Licence

Telephaty Api IOS is available under the AGPL-3.0 licence. See the LICENCE file for more info.


Release Notes
-----------------

Version 1.0

- Initial release.