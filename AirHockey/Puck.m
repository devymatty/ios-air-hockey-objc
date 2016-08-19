//
//  Puck.m
//  AirHockey
//
//  Created by Mikhail on 19.08.16.
//  Copyright © 2016 iDevelopment Mikey's. All rights reserved.
//

#import "Puck.h"

@implementation Puck

@synthesize maxSpeed, speed, dx, dy, winner;

-(instancetype)initWithPuck:(UIView *)puck boundary:(CGRect)boundary goal1:(CGRect)goal1 goal2:(CGRect)goal2 maxSpeed:(float)max {
    self = [super init];
    if (self) {
        // граница собственной реализации
        view = puck;
        rect[0] = boundary;
        rect[1] = goal1;
        rect[2] = goal2;
        maxSpeed = max;
    }
    return self;
}

// сброс к начальной позиции
- (void)reset {
    // выбор случайной позиции, в которой окажется шайба
    float x = rect[1].origin.x + arc4random() % (int)rect[1].size.width;
    float y = rect[0].origin.x + rect[0].size.height / 2;
    view.center = CGPointMake(x, y);
    
    box = 0;
    speed = 0;
    dx = 0;
    dy = 0;
    winner = 0;
}

- (CGPoint)center {
    return view.center;
}

- (BOOL)animate {
    // если победитель определился, то всякая анимация прекращается
    if (winner != 0) {
        return NO;
    }
    
    BOOL hit = NO;
    
    // замедляем шайбу, так как это обусловлено трением о поверхность поля,
    // но после первого удара она уже не останавливается насовсем,
    // иначе она может застрять на кромке ворот одного из игроков
    if (speed > 0) {
        speed = speed * 0.99;
        if (speed < 0.1) {
            speed = 0.1;
        }
    }
    
    // перемещаем шайбу в новую позицию в зависимости от текущего направления и скорости
    CGPoint pos = CGPointMake(view.center.x + dx * speed, view.center.y + dy * speed);
    
    // проверяем, не оказалась ли шайба в воротах
    if (box == 0 && CGRectContainsPoint(rect[1], pos)) {
        // сейчас шайба в воротах box 1
        box = 1;
    } else if (box == 0 && CGRectContainsPoint(rect[2], pos)) {
        // сейчас шайба в воротах box 2
        box = 2;
    } else if (CGRectContainsPoint(rect[box], pos) == NO) {
        // обрабатываем соударения со стенками в том поле, где сейчас находиться шайба
//        if (view.center.x < rect[box].origin.x) {
        if (pos.x < rect[box].origin.x) {
            pos.x = rect[box].origin.x;
            dx = fabs(dx);
            hit = YES;
        } else if (pos.x > rect[box].origin.x + rect[box].size.width) {
            pos.x = rect[box].origin.x + rect[box].size.width;
            dx = -fabs(dx);
            hit = YES;
        }
        
        if (pos.y < rect[box].origin.y) {
            pos.y = rect[box].origin.y;
            dy = fabs(dy);
            hit = YES;
            // проверяем, не определился ли победитель
            if (box == 1) {
                winner = 2;
            }
        } else if (pos.y > rect[box].origin.y + rect[box].size.height) {
            pos.y = rect[box].origin.y + rect[box].size.height;
            dy = - fabs(dy);
            hit = YES;
            // проверяем, не определилься ли победитель
            if (box == 2) {
                winner = 1;
            }
        }
    }
    
    // шайба ставиться в новую позицию
    view.center = pos;
    
    return hit;
}

// проверяем, произошло ли столкновение шайбы с клюшкой
// если так, меняем направление движения шайбы
- (BOOL)handleCollision:(Paddle *)paddle {
    // максимальное расстояние, на котором могут столкнуться клюшка и шайба, равно сумме их радиусов
    // TODO радиус клюшки 64x64 равен 32 и радиус шайбы 40х40 равен 20
    // в результате имеем максимальное расстояние 52 точки
    static float maxDistance = 52;
    
    // получаем актуальное расстояние от центральной точки прямоугольника
    float currentDistance = [paddle distance:view.center];
    
    // проверяем, произошел ли контакт на самом деле
    if (currentDistance <= maxDistance) {
        // изменяем направление движения шайбы
        dx = (view.center.x - paddle.center.x) / 32.0;
        dy = (view.center.y - paddle.center.y) / 32.0;
        
        // корректируем скорость шайбы, чтобы она отражала
        // актуальную скорость плюс скорость клюшки
        speed = 0.2 + speed / 2.0 + paddle.speed;
        
        // ограничиваем скорость движения значением максимальной скорости
        if (speed > maxSpeed) {
            speed = maxSpeed;
        }
        
        // перемещаем шайбу так, чтобы она оказалась вне радиуса клюшки,
        // чтобы мы снова не ударили по шайбе
        float r = atan2(dy, dx);
        float x = paddle.center.x + cos(r) * (maxDistance + 1);
        float y = paddle.center.y + sin(r) * (maxDistance + 1);
        view.center = CGPointMake(x, y);
        
        return YES;
    }
    return NO;
}

@end
