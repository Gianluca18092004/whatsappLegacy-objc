//
//  CocoaFetch.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 28/07/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "CocoaFetch.h"
#import "JSONKit.h"
#import "Reachability.h"
#include <arpa/inet.h>

@implementation CocoaFetch

+ (NSDictionary *)fetchJSON:(NSString *)urlString withMethod:(NSString *)method {
    NSError *error;
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Autorelease gestionará la liberación del objeto más tarde
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    
    [request setHTTPMethod:method];
    [request setURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSData *finalDataToDisplay = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    NSMutableDictionary *abc = [finalDataToDisplay objectFromJSONData];
    
    return abc;
}

+ (NSString *)formattedDateFromTimestamp:(NSTimeInterval)timestamp {
    // Crear objeto NSDate a partir del timestamp
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDate *now = [NSDate date];
    
    // Crear formateadores para fechas y horas
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    
    // Configurar formateador de tiempo
    [timeFormatter setDateFormat:@"HH:mm"];
    
    // Configurar formateador de fecha completa
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    
    // Obtener el calendario actual
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // Separar componentes del "ahora" y de la "fecha" del mensaje
    NSDateComponents *nowComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:now];
    
    // Crear el "inicio del día" para hoy y ayer manualmente
    NSDate *startOfToday = [calendar dateFromComponents:nowComponents];
    
    // Para restar un día, usamos los componentes y restamos manualmente 1 día
    NSDateComponents *yesterdayComponents = [[NSDateComponents alloc] init];
    yesterdayComponents.day = -1;
    NSDate *startOfYesterday = [calendar dateByAddingComponents:yesterdayComponents toDate:startOfToday options:0];
    
    // Comparar si la fecha es hoy
    if ([date compare:startOfToday] == NSOrderedDescending || [date compare:startOfToday] == NSOrderedSame) {
        return [timeFormatter stringFromDate:date];  // Si es hoy, muestra solo la hora
    }
    // Comparar si la fecha es ayer
    else if ([date compare:startOfYesterday] == NSOrderedDescending) {
        return @"Yesterday";  // Si es ayer, muestra "Yesterday"
    } else {
        // Para fechas anteriores a ayer, mostrar la fecha completa
        return [dateFormatter stringFromDate:date];
    }
}

+ (NSString *)formattedDateHourFromTimestamp:(NSTimeInterval)timestamp {
    // Crear objeto NSDate a partir del timestamp
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDate *now = [NSDate date];
    
    // Crear formateadores para fechas y horas
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    
    // Configurar formateador de tiempo
    [timeFormatter setDateFormat:@"HH:mm"];
    
    // Obtener el calendario actual
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // Separar componentes del "ahora" y de la "fecha" del mensaje
    NSDateComponents *nowComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:now];
    
    // Crear el "inicio del día" para hoy y ayer manualmente
    NSDate *startOfToday = [calendar dateFromComponents:nowComponents];
    
    // Para restar un día, usamos los componentes y restamos manualmente 1 día
    NSDateComponents *yesterdayComponents = [[NSDateComponents alloc] init];
    yesterdayComponents.day = -1;
    NSDate *startOfYesterday = [calendar dateByAddingComponents:yesterdayComponents toDate:startOfToday options:0];
    
    // Comparar si la fecha es hoy
    if ([date compare:startOfToday] == NSOrderedDescending || [date compare:startOfToday] == NSOrderedSame) {
        return [NSString stringWithFormat:@"Today at %@", [timeFormatter stringFromDate:date]];  // Si es hoy, muestra solo la hora
    }
    // Comparar si la fecha es ayer
    else if ([date compare:startOfYesterday] == NSOrderedDescending) {
        return [NSString stringWithFormat:@"Yesterday at %@", [timeFormatter stringFromDate:date]];  // Si es ayer, muestra "Yesterday"
    } else {
        return nil;
    }
}

+ (BOOL)isDifferentDayWithTimestamp:(NSTimeInterval)timestamp previousTimestamp:(NSTimeInterval)previousTimestamp {
    // Crear objetos NSDate a partir de los timestamps
    NSDate *date1 = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:previousTimestamp];
    
    // Obtener el calendario actual
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // Extraer los componentes de año, mes y día de ambas fechas
    NSDateComponents *components1 = [calendar components:(kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay) fromDate:date1];
    NSDateComponents *components2 = [calendar components:(kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay) fromDate:date2];
    
    // Comparar los componentes de año, mes y día
    if (components1.year != components2.year ||
        components1.month != components2.month ||
        components1.day != components2.day) {
        // Si alguno de los componentes es diferente, es un día diferente
        return YES;
    } else {
        // Si los componentes son iguales, es el mismo día
        return NO;
    }
}


+ (NSString *)stringWithDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    [dateFormatter release]; // Si no estás usando ARC
    
    return dateString;
}

+ (NSString *)stringWithTime:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSString *timeString = [dateFormatter stringFromDate:date];
    [dateFormatter release]; // Si no estás usando ARC
    
    return timeString;
}

+ (NSInteger)singleDigitFromString:(NSString*)inputString {
    int sum = 0;
    
    // Recorre cada carácter en la cadena y suma sus valores ASCII
    for (NSUInteger i = 0; i < [inputString length]; i++) {
        unichar character = [inputString characterAtIndex:i];
        sum += (int)character; // Convierte unichar a int y suma
    }
    
    // Reduce la suma a un solo dígito (0-9) usando módulo
    int singleDigit = sum % 10;
    
    return singleDigit;
}

+ (void)saveDictionaryToJSON:(NSDictionary *)dictionary withFileName:(NSString *)fileName {
    // Serializar el NSDictionary a JSON usando JSONKit
    NSString *jsonString = [dictionary JSONString];
    
    if (jsonString) {
        // Obtener la ruta del archivo JSON con el nombre personalizado
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", fileName]];
        
        // Guardar el JSON en un archivo
        NSError *error;
        BOOL success = [jsonString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        if (!success) {
            NSLog(@"Error saving JSON to file: %@", error.localizedDescription);
        }
    } else {
        NSLog(@"Error serializing dictionary to JSON.");
    }
}

+ (void)deleteJSONWithFileName:(NSString *)fileName {
    // Obtener la ruta del archivo JSON con el nombre personalizado
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", fileName]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Verificar si el archivo existe antes de eliminarlo
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        
        // Intentar eliminar el archivo
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
        
        if (!success) {
            NSLog(@"Error deleting JSON file: %@", error.localizedDescription);
        } else {
            NSLog(@"File %@.json deleted successfully", fileName);
        }
    } else {
        NSLog(@"File %@.json not found", fileName);
    }
}

+ (NSDictionary *)loadDictionaryFromJSONWithFileName:(NSString *)fileName {
    // Obtener la ruta del archivo JSON con el nombre personalizado
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", fileName]];
    
    // Leer el contenido del archivo JSON como una cadena
    NSError *error;
    NSString *jsonString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    if (jsonString) {
        // Deserializar la cadena JSON a un NSDictionary usando JSONKit
        NSDictionary *dictionary = [jsonString objectFromJSONString];
        return dictionary;
    } else {
        NSLog(@"Error reading JSON file: %@", error.localizedDescription);
        return nil;
    }
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (NSString *)formattedTimeFromSeconds:(int)totalSeconds {
    int minutes = totalSeconds / 60;
    int seconds = totalSeconds % 60;
    
    // Formatear la cadena como m:ss (por ejemplo, 0:03)
    NSString *formattedTime = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    return formattedTime;
}

+ (CGSize)resizeToWidth:(CGFloat)targetWidth fromSize:(CGSize)originalSize {
    CGFloat scaleFactor = targetWidth / originalSize.width;
    CGFloat targetHeight = originalSize.height * scaleFactor;
    return CGSizeMake(roundf(targetWidth), roundf(targetHeight));
}

+ (NSString *)stringFromByteCount:(NSInteger)byteCount {
    double convertedValue = (double)byteCount;
    int multiplyFactor = 0;
    NSArray *tokens = [NSArray arrayWithObjects:@"B", @"KB", @"MB", @"GB", @"TB", nil];
    
    while (convertedValue >= 1024 && multiplyFactor < (tokens.count - 1)) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    return [NSString stringWithFormat:@"%.2f %@", convertedValue, [tokens objectAtIndex:multiplyFactor]];
}

+ (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

+ (BOOL)connectedToServers {
    struct sockaddr_in address;
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
    address.sin_port = htons(80);
    address.sin_addr.s_addr = inet_addr("google.com");
    Reachability* reach = [Reachability reachabilityWithAddress:&address];
    NetworkStatus hostStatus = [reach currentReachabilityStatus];
    if(hostStatus != NotReachable){
    #if DEBUG
        NSLog(@"Internet Detected");
    #endif
        return YES;
    }
    #if DEBUG
        NSLog(@"Internet not Detected");
    #endif
    return NO;
}

@end
