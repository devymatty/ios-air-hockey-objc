//
//  Paddle.m
//  AirHockey
//
//  Created by Mikhail on 18.08.16.
//  Copyright © 2016 iDevelopment Mikey's. All rights reserved.
//

#import "Paddle.h"

@implementation Paddle

@synthesize touch;
@synthesize speed;
@synthesize maxSpeed;

- (instancetype)initWithView:(UIView *)paddle boundary:(CGRect)rect maxSpeed:(float)max {
    self = [super init];
    if (self) {
        // наша собственная инициализация
        view = paddle;
        boundary = rect;
        maxSpeed = max;
    }
    return self;
}

// возвращаемся к стартовой позиции
- (void)reset {
    pos.x = boundary.origin.x + boundary.size.width / 2;
    pos.y = boundary.origin.y + boundary.size.height / 2;
    view.center = pos;
}

// задаем, куда должна переместиться клюшка
- (void)move:(CGPoint)pt {
    // корректируем положение по оси X, чтобы клюшка оставалась в заданных границах
    if (pt.x < boundary.origin.x) {
        pt.x = boundary.origin.x;
    
    } else if (pt.x > boundary.origin.x + boundary.size.width) {
        pt.x = boundary.origin.x + boundary.size.width;
    }
    // корректируем положение по оси Y, чтобы клюшка оставалась в заданных границах
    if (pt.y < boundary.origin.y) {
        pt.y = boundary.origin.y;
    } else if (pt.y > boundary.origin.y + boundary.size.height) {
        pt.y = boundary.origin.y + boundary.size.height;
    }
    
    // обновляем положение
    pos = pt;
}

// центральная точка клюшки
- (CGPoint)center {
    return view.center;
}

// проверяем, пересекается ли клюшка с прямоугольником
-(BOOL)intersects:(CGRect)rect {
    return CGRectIntersectsRect(view.frame, rect);
}

// получаем расстояние между нужной нам точкой и актуальной позицией клюшки
-(float)distance:(CGPoint)pt {
    float diffx = view.center.x - pt.x;
    float diffy = view.center.y - pt.y;
    return sqrt(diffx*diffx + diffy*diffy);
}

// анимированное перемещение в назначенную позицию, без превышения максимальной скорости
- (void)animate {
    // проверяем, требуется ли движение
    if (CGPointEqualToPoint(view.center, pos) == NO) {
        // вычисляем расстояние, на которое необходимо переместиться
        float d = [self distance:pos];
        
        // проверяем максимальное расстояние, на которое может передвинуться клюшка
        if (d > maxSpeed) {
            // изменяем позицию на максимальную допустимую
            float r = atan2(pos.y - view.center.y, pos.x - view.center.x);
            float x = view.center.x + cos(r) * maxSpeed;
            float y = view.center.y + sin(r) * maxSpeed;
            view.center = CGPointMake(x, y);
        } else {
            // задаем положение клюшки, если она не превысила максимальную скорость
            view.center = pos;
            speed = d;
        }
    } else {
        // движения нет
        speed = 0;
    }
}

@end
