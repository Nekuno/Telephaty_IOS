//
//  KLNUtils.m
//  Guachapp
//
//  Created by Eduardo K. Palenzuela Darias on 04/02/14.
//  Copyright (c) 2014 kiliannet. All rights reserved.
//

#import "KLNUtils.h"
#import "CSNotificationView.h"

@implementation KLNUtils

#pragma mark - Factory methods
+ (UIBarButtonItem *)barButtonItemWithImageNamed:(NSString *)imageNamed target:(id)target action:(SEL)action {
    UIImage *image = [UIImage imageNamed:imageNamed];
    
    return [KLNUtils barButtonItemWithImage:image target:target action:action];
}
+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image target:(id)target action:(SEL)action {
    // Creamos un botón con la imagen correspondiente
    UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [imageButton setFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
    [imageButton setImage:image forState:UIControlStateNormal];
    
    // Le agregamos el action
    [imageButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    // Creamos y devolvemos el barButtonItem
    UIBarButtonItem *newBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:imageButton];
    
    return newBarButtonItem;
}
+ (UIBarButtonItem *)barButtonItemWithActivityIndicatorWithColor:(UIColor *)color {
    UIActivityIndicatorView * activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
    [activityView setColor:color];
    [activityView sizeToFit];
    [activityView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    [activityView startAnimating];
    UIBarButtonItem *newBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    
    return newBarButtonItem;
}

+ (NSString *)stringByTrimText:(NSString *)text {
    NSString *newText = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return newText;
}

+ (NSAttributedString *)attributedStringByText:(NSString *)text withUnderlineStyleInRange:(NSRange)range
                               foregroundColor:(UIColor *)foregroundColor {
    // Inicialización con el texto pasado
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    
    // Subrayado
    [attributedString addAttribute:NSUnderlineStyleAttributeName
                             value:[NSNumber numberWithInt:NSUnderlineStyleSingle]
                             range:range];
    
    // Color de la fuente
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:foregroundColor
                             range:range];
    
    return [attributedString copy];
}

+ (NSAttributedString *)attributedStringByText:(NSString *)text withUnderlineStyleInRange:(NSRange)range {
    // Inicialización con el texto pasado
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    
    // Subrayado
    [attributedString addAttribute:NSUnderlineStyleAttributeName
                             value:[NSNumber numberWithInt:NSUnderlineStyleSingle]
                             range:range];
    
    return [attributedString copy];
}

#pragma mark - Other methods
+ (void)showNotificationWithMessage:(NSString *)message inViewController:(UIViewController *)viewController {
    [CSNotificationView showInViewController:viewController
                                   tintColor:[UIColor redColor]
                                        font:[UIFont systemFontOfSize:14.0f]
                               textAlignment:NSTextAlignmentLeft
                                       image:[UIImage imageNamed:@"notifications-exclamation-icon"]
                                     message:message
                                    duration:kCSNotificationViewDefaultShowDuration];
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:message
                          delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil, nil];
    
    [alert show];
}

+ (void)customizeNavigationBar:(UINavigationBar *)navigationBar withFontColor:(UIColor *)fontColor backgroundColor:(UIColor *)backgroundColor {
    // Personalizamos la navigationBar
    [navigationBar setTintColor:fontColor];
    [navigationBar setBarTintColor:backgroundColor];
    [navigationBar setBackgroundColor:backgroundColor];
    
    NSDictionary *dictionary = @{NSForegroundColorAttributeName: fontColor};
    [navigationBar setTitleTextAttributes:dictionary];
}

+ (UIImage *)imageAddWatermark:(UIImage *)watermark toImage:(UIImage *)image {
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
//    [watermark drawInRect:CGRectMake(image.size.width - watermark.size.width - 20,
//                                          image.size.height - watermark.size.height - 20,
//                                          watermark.size.width,
//                                          watermark.size.height)];
    [watermark drawInRect:CGRectMake(20.0f,
                                     image.size.height - watermark.size.height - 20.0f,
                                     watermark.size.width,
                                     watermark.size.height)];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

+ (NSString *)stringByTimereleaseFormat:(NSDate *)date {
    
    NSDate *now = [NSDate date];
    NSTimeInterval interval = [now timeIntervalSinceDate:date];
    
    //    NSInteger seconds = interval;
    //    NSInteger minutes = seconds / 60;
    //    NSInteger hours = minutes / 60;
    //    NSInteger days = hours / 24;
    //    NSInteger weeks = days / 7;
    
    NSInteger seconds = abs((int) interval);
    NSInteger minutes = abs(seconds / 60.0f);
    NSInteger hours = abs(minutes / 60.0f);
    NSInteger days = abs(hours / 24.0f);
    NSInteger weeks = abs(days / 7.0f);
    
    if (weeks > 0) {
        return [NSString stringWithFormat:@"%li%@", (long)weeks, NSLocalizedString(@"w", nil)];
    }
    if (days > 0) {
        return [NSString stringWithFormat:@"%li%@", (long)days, NSLocalizedString(@"d", nil)];
    }
    if (hours > 0) {
        return [NSString stringWithFormat:@"%lih", (long)hours];
    }
    if (minutes > 0) {
        return [NSString stringWithFormat:@"%limin", (long)minutes];
    }
    
    return [NSString stringWithFormat:@"%liseg", (long)seconds];
}
+ (NSString *)stringByNumberFormatToMoney:(NSNumber *)number withCurrencyCode:(NSString *)currencyCode {
    // Comprobamos si se ha pasado el precio.
    if ([number doubleValue] == 0) {
        return nil;
    }
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:currencyCode];
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    numberFormatter.locale = locale;
    
    NSNumber *newNumber = [NSNumber numberWithDouble:[number doubleValue]];
    
    return [numberFormatter stringFromNumber:newNumber];
}

+ (NSNumber *)numberByPrice:(NSNumber *)price withDiscount:(double)discount {
    // Nuevo precio calculado según el porcentaje de descuento
    double result = [price doubleValue] * (discount / 100.0f);
    return [NSNumber numberWithDouble: ([price doubleValue] - result)];
}

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        
        NSString *codeLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
        NSLocale *currentLocale = [[NSLocale alloc] initWithLocaleIdentifier:codeLanguage];
        [dateFormatter setLocale:currentLocale];
    });
    
    return dateFormatter;
}

#pragma mark - Validations
+ (BOOL)isValidEmail:(NSString *)email error:(NSError *__autoreleasing *)error {
    // Error domain
    static NSString *domain = @"Email";
    
    // Hacemos un trim del email
    NSString *emailString = [KLNUtils stringByTrimText:email];
    
    if ([emailString length] == 0) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Empty email", nil)};
        *error = [NSError errorWithDomain:domain code:-1 userInfo:userInfo];
        
        return NO;
    }
    
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    
//    NSLog(@"%lu", (unsigned long)regExMatches);
    
    if (regExMatches == 0) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Wrong email", nil)};
        *error = [NSError errorWithDomain:domain code:-2 userInfo:userInfo];
        
        return NO;
    } else {
        return YES;
    }
}
+ (BOOL)isValidUsername:(NSString *)username error:(NSError *__autoreleasing *)error {
    // Error domain
    static NSString *domain = @"Username";
    
    // Hacemos un trim del username
    NSString *usernameTrim = [KLNUtils stringByTrimText:username];
    
    // - Propiedad obligatoria
    if ([usernameTrim length] == 0) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Empty username", nil)};
        *error = [NSError errorWithDomain:domain code:-1 userInfo:userInfo];
        
        return NO;
    }
    
    // - No puede tener más de 15 caracteres.
    if ([usernameTrim length] > 15) {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Username with more than %i characters", nil), 15];
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: message};
        *error = [NSError errorWithDomain:domain code:-2 userInfo:userInfo];
        
        return NO;
    }
    
    // - El nombre de usuario no puede contener la palabra Shoppiic o Admin.
    NSRange rangeAdmin = [usernameTrim rangeOfString:@"admin" options:NSCaseInsensitiveSearch];
    NSRange rangeShoppiic = [usernameTrim rangeOfString:@"shoppiic" options:NSCaseInsensitiveSearch];
    
    if ((rangeAdmin.length > 0) || (rangeShoppiic.length > 0)) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Username contains reserved words", nil)};
        *error = [NSError errorWithDomain:domain code:-3 userInfo:userInfo];
        
        return NO;
    }
    
    // - Sólo pueden tener caracteres alfanuméricos (letras a-z, A-Z y números 0-9) con la excepción de los guiones bajos (_)
    NSString *filter = @"^[a-zA-Z0-9_]*$";
    NSPredicate *regularExpresion = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", filter];
    
    if (![regularExpresion evaluateWithObject:usernameTrim]) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Username contains illegal characters", nil)};
        *error = [NSError errorWithDomain:domain code:-3 userInfo:userInfo];
        
        return NO;
    }
    
    return YES;
}
+ (BOOL)isValidPassword:(NSString *)password error:(NSError *__autoreleasing *)error {
    // Error domain
    static NSString *domain = @"Password";
    
    // Hacemos un trim del password
    NSString *passwordTrim = [KLNUtils stringByTrimText:password];
    
    // Obligatorio
    if ([passwordTrim length] == 0) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Empty password", nil)};
        *error = [NSError errorWithDomain:domain code:-1 userInfo:userInfo];
        
        return NO;
    }
    
    // No puede tener menos de 6 caracteres
    if ([passwordTrim length] < 6) {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Password must be longer than %i characters", nil), 6];
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: message};
        *error = [NSError errorWithDomain:domain code:-2 userInfo:userInfo];
        
        return NO;
    }
    
    return YES;
}
+ (BOOL)isValidPrice:(NSString *)price {
    NSDecimal decimalValue;
    NSScanner *sc = [NSScanner scannerWithString:price];
    [sc scanDecimal:&decimalValue];
    return [sc isAtEnd];
}

@end