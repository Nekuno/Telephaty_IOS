//
//  PPEncrypt.m
//  PPEncrypt
//
//  Created by Juan on 3/3/14.
//  Copyright (c) 2014 Alvarez Productions. All rights reserved.
//

#import "PPEncrypt.h"

#import <CommonCrypto/CommonCrypto.h>

#import "NSData+Digest.h"
#import "NSData+Base64.h"

@import Security;

@interface PPEncrypt ()

@end

@implementation PPEncrypt


#pragma mark - AddingKeys

+ (NSData *)stripPublicKeyHeader:(NSData *)d_key
{
  // Skip ASN.1 public key header
  if (d_key == nil) return(nil);
  
  unsigned int len = [d_key length];
  if (!len) return(nil);
  
  unsigned char *c_key = (unsigned char *)[d_key bytes];
  unsigned int  idx    = 0;
  
  if (c_key[idx++] != 0x30) return(nil);
  
  if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
  else idx++;
  
  // PKCS #1 rsaEncryption szOID_RSA_RSA
  static unsigned char seqiod[] =
  { 0x30,   0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
    0x01, 0x05, 0x00 };
  if (memcmp(&c_key[idx], seqiod, 15)) return(nil);
  
  idx += 15;
  
  if (c_key[idx++] != 0x03) return(nil);
  
  if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
  else idx++;
  
  if (c_key[idx++] != '\0') return(nil);
  
  // Now make a new NSData from this buffer
  return([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}


+ (SecKeyRef)addKey:(NSString *)key withTag:(NSString *)tag public:(BOOL)public{
  NSString *s_key = key;
  
  if (s_key.length == 0) return(FALSE);
  
  // This will be base64 encoded, decode it.
  NSData *d_key = [NSData base64DataFromString:key];
  if (public) {
    d_key = [self stripPublicKeyHeader:d_key];
  }
  
  if (d_key == nil) return(FALSE);
  
  NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];
  
  // Delete any old lingering key with the same tag
  NSMutableDictionary *dictionaryKey = [[NSMutableDictionary alloc] init];
  [dictionaryKey setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
  [dictionaryKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
  [dictionaryKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
  SecItemDelete((__bridge CFDictionaryRef)dictionaryKey);
  
  CFTypeRef persistKey = nil;
  
  // Add persistent version of the key to system keychain
  [dictionaryKey setObject:d_key forKey:(__bridge id)kSecValueData];
  if (public) {
    [dictionaryKey setObject:(__bridge id) kSecAttrKeyClassPublic forKey:(__bridge id)kSecAttrKeyClass];
  } else {
    [dictionaryKey setObject:(__bridge id) kSecAttrKeyClassPrivate forKey:(__bridge id)kSecAttrKeyClass];
  }
  
  [dictionaryKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnPersistentRef];
  
  OSStatus secStatus = SecItemAdd((__bridge CFDictionaryRef)dictionaryKey, &persistKey);
  if (persistKey != nil) CFRelease(persistKey);
  
  if ((secStatus != noErr) && (secStatus != errSecDuplicateItem)) {
    return nil;
  }
  
  // Now fetch the SecKeyRef version of the key
  SecKeyRef keyRef = nil;
  
  [dictionaryKey removeObjectForKey:(__bridge id)kSecValueData];
  [dictionaryKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
  [dictionaryKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
  [dictionaryKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
  SecItemCopyMatching((__bridge CFDictionaryRef)dictionaryKey, (CFTypeRef *)&keyRef);
  
  if (keyRef == nil) return nil;
  
  return keyRef;
}


#pragma mark - Encryption Methods

+ (NSString *)encrypt:(NSString *)string withKey:(SecKeyRef)publicKey
{
    if (string == nil || publicKey == nil) {
        return nil;
    }
    
  //  SecKeyRef publicKey = pair.publicKeyRef;
    
    uint8_t *nonce = (uint8_t *)[string UTF8String];
    size_t cipherBufferSize = SecKeyGetBlockSize(publicKey);
    uint8_t *cipherBuffer = malloc(cipherBufferSize);
    
//    Length of plainText in bytes, this must be less than
//    or equal to the value returned by SecKeyGetBlockSize().
    if (cipherBufferSize < sizeof(nonce)) {
        NSString *reason = [NSString stringWithFormat:@"String length is too long to sign with this key, max length is %ld and actual length is %ld", cipherBufferSize, strlen((char *)nonce)];
        NSLog(@"%@", reason);
        
        return nil;
    }
    
    NSData *encryptedData;
    
    OSStatus status = SecKeyEncrypt(publicKey,
                                    kSecPaddingPKCS1,
                                    nonce,
                                    strlen((char *)nonce),
                                    &cipherBuffer[0],
                                    &cipherBufferSize);
    
    if (status == errSecSuccess) {
        encryptedData = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];
    }
    
    free(cipherBuffer);
    
    return [encryptedData base64EncodedStringWithOptions:0];
}

#pragma mark - Decryption Methods

+ (NSString *)decrypt:(NSString *)cipherText withKey:(SecKeyRef)privateKey
{
    if (cipherText == nil || privateKey == nil) {
        return nil;
    }
    
    size_t plainBufferSize = SecKeyGetBlockSize(privateKey);
    uint8_t *plainBuffer = malloc(plainBufferSize);
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:cipherText options:0];
    
    uint8_t *cipherBuffer = (uint8_t*)[data bytes];
    size_t cipherBufferSize = SecKeyGetBlockSize(privateKey);
    
    if (plainBufferSize < cipherBufferSize) {
        NSString *reason = [NSString stringWithFormat:@"Cipher size is too long to sign with this key, max length is %ld and actual length is %ld", plainBufferSize, (unsigned long)cipherText.length];
        
        NSLog(@"%@", reason);
        
        return nil;
    }
    
    OSStatus status = SecKeyDecrypt(privateKey,
                                    kSecPaddingPKCS1,
                                    cipherBuffer,
                                    cipherBufferSize,
                                    plainBuffer,
                                    &plainBufferSize);
    
    NSString *decryptedString;
    
    if (status == errSecSuccess) {
        NSData *bufferData = [NSData dataWithBytesNoCopy:plainBuffer length:plainBufferSize freeWhenDone:YES];
        
        decryptedString = [[NSString alloc] initWithData:bufferData encoding:NSUTF8StringEncoding];
    }
    
    return decryptedString;
}

#pragma mark - Signing Methods

+ (NSData *)signData:(NSData *)data withPadding:(SecPadding)padding andIdentifier:(NSString *)identifier
{
    if (data == nil || identifier == nil) {
        return nil;
    }
    SecKeyRef privateKey = [self keyRefWithTag:identifier error:nil];
    
    NSData *signedData;
    
    if (privateKey) {
        NSData *digest = [self digestForData:data withPadding:padding];
        
//        When PKCS1 padding is performed, the maximum length of data that can
//        be signed is the value returned by SecKeyGetBlockSize() - 11.
        size_t maxLength = SecKeyGetBlockSize(privateKey);
        
        // if hash type is not none, then PKCS1 padding will be done
        if ([self isPaddingPKCS1:padding]) {
            maxLength -= 11;
        }
        
        if ([digest length] > maxLength) {
            NSString *reason = [NSString stringWithFormat:@"Digest is too long to sign with this key, max length is %ld and actual length is %ld", maxLength, (unsigned long)data.length];
            
            NSLog(@"%@", reason);
            
            return nil;
        }
        
        uint8_t *plainBuffer = (uint8_t *)[digest bytes];
        size_t plainBufferSize = [digest length];
        size_t cipherBufferSize = SecKeyGetBlockSize(privateKey);
        uint8_t *cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
        
        OSStatus status = SecKeyRawSign(privateKey,
                                        padding,
                                        plainBuffer,
                                        plainBufferSize,
                                        &cipherBuffer[0],
                                        &cipherBufferSize);
        
        if (status == errSecSuccess) {
            signedData = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];
        }
        
        free(cipherBuffer);
    }
    
    return signedData;
}

+ (BOOL)verifyData:(NSData *)data againstSignature:(NSData *)signature withPadding:(SecPadding)padding andPublicKey:(SecKeyRef)publicKey
{
    if (!signature) {
        return NO;
    }
  
    if (publicKey) {
        NSData *dataToVerify = [self digestForData:data withPadding:padding];
        
        OSStatus status = SecKeyRawVerify(publicKey,
                                          padding,
                                          dataToVerify.bytes,
                                          dataToVerify.length,
                                          signature.bytes,
                                          signature.length);
        
        return (status == errSecSuccess);
    }
    
    return NO;
}

#pragma mark - Private Methods

+ (BOOL)isPaddingPKCS1:(SecPadding)padding
{
    return (padding == kSecPaddingPKCS1SHA1 ||
            padding == kSecPaddingPKCS1SHA224 ||
            padding == kSecPaddingPKCS1SHA256 ||
            padding == kSecPaddingPKCS1SHA384 ||
            padding == kSecPaddingPKCS1SHA512);
}

+ (NSData *)digestForData:(NSData *)data withPadding:(SecPadding)padding
{
    switch (padding) {
        case kSecPaddingPKCS1SHA1:
            return [data SHA1Digest];
            break;
            
        case kSecPaddingPKCS1SHA224:
            return [data SHA224Digest];
            break;
            
        case kSecPaddingPKCS1SHA256:
            return [data SHA256Digest];
            break;
            
        case kSecPaddingPKCS1SHA384:
            return [data SHA384Digest];
            break;
            
        case kSecPaddingPKCS1SHA512:
            return [data SHA512Digest];
            break;
            
        default:
            return data;
            break;
    }
    
    return nil;
}


#pragma mark - Keychain Methods

+ (NSData *)keyDataWithTag:(NSString *)tag error:(NSError **)error
{
    NSMutableDictionary *queryKey = [self keyQueryDictionary:tag];
    [queryKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnData];
    
    SecKeyRef key = NULL;
    OSStatus err = SecItemCopyMatching((__bridge CFDictionaryRef)queryKey, (CFTypeRef *)&key);
    
    if (err != noErr || !key) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:@"" code:0 userInfo:nil];
        }
        
        return nil;
    }
    
    return (__bridge NSData *)key;
}


+ (SecKeyRef)keyRefWithTag:(NSString *)tag error:(NSError **)error
{
    NSMutableDictionary *queryKey = [self keyQueryDictionary:tag];
    [queryKey setObject:@YES forKey:(__bridge id)kSecReturnRef];
    
    SecKeyRef key = NULL;
    OSStatus err = SecItemCopyMatching((__bridge CFDictionaryRef)queryKey, (CFTypeRef *)&key);
    
    if (err != noErr) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:@"" code:0 userInfo:nil];
        }
        
        return nil;
    }
    
    return key;
}

+ (BOOL)removeKey:(NSString *)tag error:(NSError **)error
{
    NSDictionary *queryKey = [self keyQueryDictionary:tag];
    OSStatus secStatus = SecItemDelete((__bridge CFDictionaryRef)queryKey);
    
    if ((secStatus != noErr) && (secStatus != errSecDuplicateItem))
    {
        if (error != NULL) {
            *error = [NSError errorWithDomain:@"" code:0 userInfo:nil];
        }
        
        return NO;
    }
    
    return YES;
}


+ (NSMutableDictionary *)keyQueryDictionary:(NSString *)tag
{
    NSData *keyTag = [tag dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [result setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [result setObject:keyTag forKey:(__bridge id)kSecAttrApplicationTag];
    [result setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
    
    return result;
}

#pragma mark - Identifier Methods

+ (NSString *)publicKeyIdentifierWithTag:(NSString *)tag
{
    NSString *identifier = [NSString stringWithFormat:@"%@.publicKey", tag];
    
    return identifier;
}

+ (NSString *)privateKeyIdentifierWithTag:(NSString *)tag
{
    NSString *identifier = [NSString stringWithFormat:@"%@.privateKey", tag];
    
    return identifier;
}

@end
