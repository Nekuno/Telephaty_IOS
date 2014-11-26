//
//  KNConfigurationService.h
//  Telephaty
//
//  Created by PEDRO MUÑOZ CABRERA on 12/11/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Needed UUID for the service. This identifies the service to listen for app.
 */

#define TELEPHATY_SERVICE_UUID              @"00001101-0000-1000-8000-00805F9B34FB"

/**
 *  UUID for the characteristic where the app will write and send the message.
 */

#define TELEPHATY_CHARACTERISTIC_UUID       @"00001101-0000-1000-8000-00805F9B34FA"

/**
 *  Indicate how much old will be the messages that will be removed from DB periodically.
 */
#define REMOVE_MESSAGES_OLDER_THAN_MINUTES  15

//Encryption

/**
 * Key used to AES 256-bit encryption in broadcast messages
 */
#define PASS_AES_ENCRYPTION @"ATlQgbCTLBLmZEQNtBASBESswuAule6U8XRo9KhZyZL"

/**
 * Public key for RSA encryption in direct messages 1024 bits
 */

#define RSA_PUBLIC_KEY @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDBm8yuHmd0P6scl48DEi+xp47wXVZaKWRygGKtA2XkdRuCU99f0Tq07Llcgf8XuR+Wnk+z2CdMMFMzOGhCePblVIAn33dcBVlDokpBF7AnTClsaLcixxZw1LIUiaPaBdN7oG8vt3G2caLHRrrkoEnccY+6GadfH7iuHdcVsz1mowIDAQAB"

/**
 * Private key for RSA encryption in direct messages 1024 bits
 */

#define RSA_PRIVATE_KEY @"MIICXgIBAAKBgQDBm8yuHmd0P6scl48DEi+xp47wXVZaKWRygGKtA2XkdRuCU99f0Tq07Llcgf8XuR+Wnk+z2CdMMFMzOGhCePblVIAn33dcBVlDokpBF7AnTClsaLcixxZw1LIUiaPaBdN7oG8vt3G2caLHRrrkoEnccY+6GadfH7iuHdcVsz1mowIDAQABAoGAWEt1TPMQuzNOFfwIfJ4OojaIOZZXi0bVSGLEnaKvFUFTCly1wjzpSRmsb0PZ0jfa8BXCw4IQae6gAvv2kFoaPjAiohDRzsNL7r5VfWqYh2rvXM7FEa5Zl6EvhHm1MdLVgqKW2gAN5N1dBqpRvzo0H8zEcbqH7a4gAyQivaxGXgECQQDz59utDOP1VS5LVVnr57M4x99/lrxHNuiTmKdwKtjhB2bZQy2R5SPC7xHF5lFfMOW35tg/6ZjCeEC/KvPYZXNNAkEAyzV4KKcL4+7S7AZ7LcmraYY2UHFAyGkS/RBVLLaTcGIZOyrw9PezM+S8kRERO7lblStcptCd4leTtPXY0X1prwJBAOiqk7bXZhmg4SGB0N6lzyRqHfzDGOXCLkilxYvNg8fd3LGCUNUsxVlt3wFufM8WgPxWHJGTT2KrffAelDAoTr0CQQCA9DSFb8Ru596340EGBIWfmIkdMVGQHIXtTBERJ+eWmNo0HwL8Ibh6BPzY/kC2auFAX10Tiy22NidI3f6yqmiHAkEA1H/bkwBulMSoo1ylLCF1m482ucOY7wWnJ77ARc3Xf5KJtsWSDfQiHP1UyJrnlZz+JLWH4fWuFm1ZPHZca38eBg=="


//Keys 512 bits

//#define RSA_PUBLIC_KEY @"MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAKlfCpymreLxf5AabYygBaA9Jt/kXDZe9V+YPRUrlwt3+coaqp2l9qaO3ZN7LAFyg+ZA2BjL7yrbpvZPJKKdPNkCAwEAAQ=="
//#define RSA_PRIVATE_KEY @"MIIBOQIBAAJBAKlfCpymreLxf5AabYygBaA9Jt/kXDZe9V+YPRUrlwt3+coaqp2l9qaO3ZN7LAFyg+ZA2BjL7yrbpvZPJKKdPNkCAwEAAQJAGRF8HJt++SwNWWLP/BRjQMhMTK8cBuAfKTr7L3r4LDYUT6iwM1CMiPdfufihRvRd96VQUPHajVqQpQii29A9QQIhAaPm/pUaJTTG/GolAvy1bljRBhaIe9OUXKZWL1emzNStAiBnQoQSPbQRHTnBnwVZAcJgLsuzW67rk2e5luf1Z2kiXQIhAO4wwolh42kk11p+1Er1wDqxl3qAwX0r08KncQOPovGhAiAKMBPbwN69OYbzRX8/kt7cooFSht8xOu/m7a6hFbzXuQIgHTErMm7erTHf4FkEt3WagNchDRFhdvJaTyIeo30md7o="

@interface KNConfigurationService : NSObject

@end
