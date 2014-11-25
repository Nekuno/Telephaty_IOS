//
//  PPKeyPair.m
//  PPEncrypt
//
//  Created by Juan Alvarez on 5/8/14.
//  Copyright (c) 2014 Alvarez Productions. All rights reserved.
//

#import "PPKeyPair.h"

#import <CommonCrypto/CommonCrypto.h>

// Inspiration from https://github.com/kuapay/iOS-Certificate--Key--and-Trust-Sample-Project

static unsigned char oidSequence [] = { 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00 };

@interface PPKeyPair ()

@end

@implementation PPKeyPair

- (instancetype)initWithIdentifier:(NSString *)identifier
                         publicKey:(SecKeyRef)publicKey
                        privateKey:(SecKeyRef)privateKey
{
    NSParameterAssert(identifier != nil);
    NSParameterAssert(publicKey != nil);
    NSParameterAssert(privateKey != nil);
    
    self = [super init];
    
    _identifier = identifier;
    _publicKeyRef = publicKey;
    _privateKeyRef = privateKey;
    
    return self;
}

- (NSString *)X509FormattedPublicKeyString
{
    return [PPKeyPair X509FormattedPublicKey:self.publicKeyRef error:nil];
}

- (NSString *)PEMFormattedPrivateKeyString
{
    return [PPKeyPair PEMFormattedPrivateKey:self.privateKeyRef error:nil];
}

#pragma mark - Private

+ (NSString *)X509FormattedPublicKey:(SecKeyRef)key error:(NSError **)error
{
    NSError *keyDataError;
    NSData *publicKeyData = [self dataFromKey:key error:&keyDataError];
    
    if (keyDataError)
    {
        *error = keyDataError;
        
        return nil;
    }
    
    unsigned char builder[15];
    unsigned long bitstringEncLength;
    if  ([publicKeyData length] + 1  < 128 )
    {
        bitstringEncLength = 1 ;
    }
    else
    {
        bitstringEncLength = (([publicKeyData length ] + 1)/256) + 2;
    }
    
    builder[0] = 0x30;
    
    size_t i = sizeof(oidSequence) + 2 + bitstringEncLength + [publicKeyData length];
    size_t j = [self encode:&builder[1]
                     length:i];
    
    NSMutableData *encodedKey = [[NSMutableData alloc] init];
    
    [encodedKey appendBytes:builder
                     length:j + 1];
    
    [encodedKey appendBytes:oidSequence
                     length:sizeof(oidSequence)];
    
    builder[0] = 0x03;
    j = [self encode:&builder[1]
              length:[publicKeyData length] + 1];
    
    builder[j+1] = 0x00;
    [encodedKey appendBytes:builder
                     length:j + 2];
    
    [encodedKey appendData:publicKeyData];
    
    NSString *returnString = [NSString stringWithFormat:@"%@\n%@\n%@",
                              [self X509PublicHeader],
                              [encodedKey base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength],
                              [self X509PublicFooter]];
  
    returnString =  [encodedKey base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    return returnString;
}

+ (NSString *)PEMFormattedPrivateKey:(SecKeyRef)key error:(NSError **)error
{
    NSError *keyDataError;
    NSData *privateKeyData = [self dataFromKey:key error:&keyDataError];
    
    if (keyDataError) {
        *error = keyDataError;
        
        return nil;
    }
    
    NSString *result = [NSString stringWithFormat:@"%@\n%@\n%@",
                        [self PEMPrivateHeader],
                        [privateKeyData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength],
                        [self PEMPrivateFooter]];
    
    return result;
}

+ (NSData *)dataFromKey:(SecKeyRef)key error:(NSError **)error
{
  
  static const uint8_t publicKeyIdentifier[] = "com.qnow.telepahty.publickey";
  NSData *publicTag = [[NSData alloc] initWithBytes:publicKeyIdentifier length:sizeof(publicKeyIdentifier)];
  
  OSStatus sanityCheck = noErr;
  NSData * publicKeyBits = nil;
  
  NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
  [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
  [queryPublicKey setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
  [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
  
  // Temporarily add key to the Keychain, return as data:
  NSMutableDictionary * attributes = [queryPublicKey mutableCopy];
  [attributes setObject:(__bridge id)key forKey:(__bridge id)kSecValueRef];
  [attributes setObject:@YES forKey:(__bridge id)kSecReturnData];
  CFTypeRef result;
  sanityCheck = SecItemAdd((__bridge CFDictionaryRef) attributes, &result);
  if (sanityCheck == errSecSuccess) {
    publicKeyBits = CFBridgingRelease(result);
    
    // Remove from Keychain again:
    (void)SecItemDelete((__bridge CFDictionaryRef) queryPublicKey);
  }
  
  return publicKeyBits;
  
  
//  OSStatus sanityCheck = noErr;
//  NSData * publicKeyBits = nil;
//  
//  NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
//  
//  // Set the public key query dictionary.
//  [queryPublicKey setObject:(id)kSecClassKey forKey:(id)kSecClass];
//  [queryPublicKey setObject:publicTag forKey:(id)kSecAttrApplicationTag];
//  [queryPublicKey setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
//  [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnData];
//  
//  // Get the key bits.
//  sanityCheck = SecItemCopyMatching((CFDictionaryRef)queryPublicKey, (CFTypeRef *)&publicKeyBits);
//  
//  if (sanityCheck != noErr)
//  {
//    publicKeyBits = nil;
//  }
//  
//  [queryPublicKey release];
//  
//  return publicKeyBits;
}

#pragma mark - RSA Key Anatomy

+ (NSString *)X509PublicHeader
{
    return @"-----BEGIN PUBLIC KEY-----";
}

+ (NSString *)X509PublicFooter
{
    return @"-----END PUBLIC KEY-----";
}

+ (NSString *)PKCS1PublicHeader
{
    return  @"-----BEGIN RSA PUBLIC KEY-----";
}

+ (NSString *)PKCS1PublicFooter
{
    return @"-----END RSA PUBLIC KEY-----";
}

+ (NSString *)PEMPrivateHeader
{
    return @"-----BEGIN RSA PRIVATE KEY-----";
}

+ (NSString *)PEMPrivateFooter
{
    return @"-----END RSA PRIVATE KEY-----";
}

#pragma mark - Helper

+ (size_t)encode:(unsigned char *)buffer length:(size_t)length
{
    if (length < 128)
    {
        buffer[0] = length;
        return 1;
    }
    
    size_t i = (length / 256) + 1;
    buffer[0] = i + 0x80;
    for (size_t j = 0 ; j < i; ++j)
    {
        buffer[i - j] = length & 0xFF;
        length = length >> 8;
    }
    
    return i + 1;
}

@end
