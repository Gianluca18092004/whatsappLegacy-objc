//
//  StatusPreviewItem.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 25/10/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "StatusPreviewItem.h"

@implementation StatusPreviewItem
@synthesize circularProgressView, profileName, profileTimestamp, largeImage, contactNumber, totalCount, unreadCount;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (self.circularProgressView == nil){
        
        // Configure the view for the selected state
        self.circularProgressView = [[CircularProgressView alloc] initWithFrame:CGRectMake(7, 7, 56, 56)];
        // Establecer la imagen de fondo
        self.circularProgressView.backgroundImage = self.largeImage;
        
        // Establecer colores para bloques completados y restantes
        self.circularProgressView.completedColor = [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0]; // Azul oscuro
        self.circularProgressView.remainingColor = [UIColor colorWithRed:0.6 green:0.8 blue:1.0 alpha:1.0]; // Azul claro
        
        // Establecer el número de bloques completados y totales
        self.circularProgressView.totalBlocks = self.totalCount; // Por ejemplo, 10 bloques
        self.circularProgressView.completedBlocks = self.unreadCount; // 3 bloques completados
        
        // Añadir la vista al controlador
        [self addSubview:self.circularProgressView];
    }
}

@end
