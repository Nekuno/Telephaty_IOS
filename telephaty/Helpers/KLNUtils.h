//
//  KLNUtils.h
//  Guachapp
//
//  Created by Eduardo K. Palenzuela Darias on 04/02/14.
//  Copyright (c) 2014 kiliannet. All rights reserved.
//

#import <Foundation/Foundation.h>

// Import pods
#import "Ionicons.h" // es necesario modificar el .plist para incluir las fuentes "Fonts provided by application: ionicons.ttf"

/**
 *  KLNUtils es una clase abstracta que proporciona métodos muy útiles para soluciones comunes en el desarrollo de aplicaciones iOS.
 */
@interface KLNUtils : NSObject

#pragma mark - Factory methods
/**
 *  Factory method que crea un UIBarButtonItem de 30x30 px con el nombre de la imagen indicada agregándole además, un target y un action para el evento UIControlEventTouchUpInside.
 *
 *  @param imageNamed Nombre de la imagen del UIBarButton. Debe ser una imagen de 30x30 px.
 *  @param target     Objeto que recibirá el evento del action.
 *  @param action     Método SEL que se invocará al lanzar el evento UIControlEventTouchUpInside.
 *
 *  @return UIBarButtonItem listo para agregarse a un UINavigationBar.
 */
+ (UIBarButtonItem *)barButtonItemWithImageNamed:(NSString *)imageNamed target:(id)target action:(SEL)action;

/**
 *  Factory method que crea un UIBarButtonItem de 30x30 px con la imagen indicada agregándole además, un target y un action para el evento UIControlEventTouchUpInside.
 *
 *  @param image  Imagen del UIBarButton. Debe ser una imagen de 30x30 px.
 *  @param target Objeto que recibirá el evento del action.
 *  @param action Método SEL que se invocará al lanzar el evento UIControlEventTouchUpInside.
 *
 *  @return UIBarButtonItem listo para agregarse a un UINavigationBar.
 */
+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image target:(id)target action:(SEL)action;

/**
 *  Factory method que crea un UIBarButtonItem de 30x30 px con un activity indicator del color indicado por parámetro.
 *
 *  @param color UIColor del activity indicator.
 *
 *  @return UIBarButtonItem listo para agregarse a un UINavigationBar.
 */
+ (UIBarButtonItem *)barButtonItemWithActivityIndicatorWithColor:(UIColor *)color;

/**
 *  Factory method que devuelve un NSString sin espacios ni al principio ni al final de la cadena.
 *
 *  @param text NSString al que le aplicaremos el trim.
 *
 *  @return NSString sin espacios.
 */
+ (NSString *)stringByTrimText:(NSString *)text;

/**
 *  Crea un NSAttributedString con un rango de texto coloreado y subrayado según los parámetros.
 *
 *  @param text            Texto que vamos a aplicar el NSAttributedString.
 *  @param range           Rango donde se aplicará el subrayado y el color.
 *  @param foregroundColor Color que se aplicará al texto que entre dentro del rango
 *
 *  @return NSAttributedString con el texto subrayado y coloreado según los parámetros.
 */
+ (NSAttributedString *)attributedStringByText:(NSString *)text withUnderlineStyleInRange:(NSRange)range foregroundColor:(UIColor *)foregroundColor;

/**
 *  Crea un NSAttributedString con un rango de texto subrayado según los parámetros.
 *
 *  @param text  Texto que vamos a aplicar el NSAttributedString.
 *  @param range Rango donde se aplicará el subrayado.
 *
 *  @return NSAttributedString con el texto subrayado según los parámetros.
 */
+ (NSAttributedString *)attributedStringByText:(NSString *)text withUnderlineStyleInRange:(NSRange)range;

#pragma mark - Public class methods
/**
 *  Muestra notificaciones al usuario.
 *
 *  @param message        Mensaje de error.
 *  @param viewController UIViewController donde se mostrará el mensaje.
 */
+ (void)showNotificationWithMessage:(NSString *)message inViewController:(UIViewController *)viewController;


/**
 *  Muesta un NSAlert.
 *
 *  @param title   Título del NSAlert.
 *  @param message Menseje del NSAlert.
 */
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;

/**
 *  Personaliza la barra de navegación según los colores indicados.
 *
 *  @param navigationBar   UINavigationBar que se va a personalizar.
 *  @param fontColor       UIColor que tendrán los textos y objetos de la UINavigationBar.
 *  @param backgroundColor UIColor que tendrá de fondo la UINavigationBar.
 */
+ (void)customizeNavigationBar:(UINavigationBar *)navigationBar withFontColor:(UIColor *)fontColor backgroundColor:(UIColor *)backgroundColor;

/**
 *  Crea una marca de agua a una imagen.
 *
 *  @param watermark Imagen de marca de agua.
 *  @param image     Imagen donde se creará la marca de agua.
 *
 *  @return Devuelve la imagen con la marca de agua.
 */
+ (UIImage *)imageAddWatermark:(UIImage *)watermark toImage:(UIImage *)image;

/**
 *  Devuelve el tiempo transcurrido desde la fecha pasada como parámetro con respecto a hoy en formato corto (ej. 3sem).
 *
 *  @param date Fecha desde donde queremos calcular.
 *
 *  @return Tiempo transcurrido en formato corto y en el lenguaje correspondiente.
 */
+ (NSString *)stringByTimereleaseFormat:(NSDate *)date;

/**
 *  Devuelve un precio en el formato establecido dependiendo del código de la moneda.
 *
 *  @param number       Número que queremos formatar.
 *  @param currencyCode Código de la moneda en la que queremos formatear.
 *
 *  @return Precio formateado.
 */
+ (NSString *)stringByNumberFormatToMoney:(NSNumber *)number withCurrencyCode:(NSString *)currencyCode;

/**
 *  Devuelve un número con el descuento aplicado.
 *
 *  @param price    Precio original.
 *  @param discount Descuento a aplicar.
 *
 *  @return Precio con el descuento aplicado.
 */
+ (NSNumber *)numberByPrice:(NSNumber *)price withDiscount:(double)discount;

/**
 *  Formato de salida de una fecha a corde con el current location del móvil.
 *
 *  @return DateFormatter preparado para formatear una fecha.
 */
+ (NSDateFormatter *)dateFormatter;

#pragma mark - Validations
/**
 *  Comprueba si un email es correcto.
 *
 *  @param email Email a comprobar.
 *  @param error En caso de no ser un email correcto, indica qué error tiene.
 *
 *  @return Devuelve YES en caso de que sea correcto o NO en caso contrario.
 */
+ (BOOL)isValidEmail:(NSString *)email error:(NSError **)error;

/**
 *  Comprueba si un username es correcto.
 *
 *  @param username Username a comprobar.
 *  @param error    En caso de no ser un username correcto, indica qué error tiene.
 *
 *  @return Devuelve YES en caso de que sea correcto o NO en caso contrario.
 *
 *  @discussion La validación para el nombre de usuario es: obligatorio, no puede tener más de 15 caracteres, no puede contener las palabras reservadas "shoppiic" ni "admin" y sólo puede tener caracteres alfanuméricos (letras a-z, A-Z y números 0-9) con la excepción de los guiones bajos (_).
 */
+ (BOOL)isValidUsername:(NSString *)username error:(NSError **)error;

/**
 *  Comprueba si una contraseña es correcta.
 *
 *  @param password Contraseña a comprobar.
 *  @param error    En caso de no ser una contraseña correcta, indicará qué error tiene.
 *
 *  @return Devuelve YES en caso de que sea correcto o NO en caso contrario.
 *
 *  @discussion La validación para la contraseña es: obligatorio y no puede tener menos de 6 caracteres.
 */
+ (BOOL)isValidPassword:(NSString *)password error:(NSError **)error;

/**
 *  Comprueba si el precio es correcto.
 *
 *  @param price Precio a comprobar.
 *
 *  @return Devuelve YES en caso de que sea correcto o NO en caso contrario.
 */
+ (BOOL)isValidPrice:(NSString *)price;

@end
