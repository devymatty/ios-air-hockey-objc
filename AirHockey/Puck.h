//
//  Puck.h
//  AirHockey
//
//  Created by Mikhail on 19.08.16.
//  Copyright © 2016 iDevelopment Mikey's. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Paddle.h"

@interface Puck : NSObject {
    UIView *view; // вид шайбы, управляемый данным объектом
    CGRect rect[3]; // содержит ограничивающие прямоугольники, а так же ворота goal1 и goal2
    int box; // рамка, к которой относится шайба (индекс в rect)
    float maxSpeed; // максимальная скорость шайбы
    float speed; // текущая скорость шайбы
    float dx, dy; //  текущее направление шайбы
    int winner; // объявленный победитель (0-отсутствует, 1-очко заработал первый игрок, 2-очко заработал 2й игрок
}

// свойства шайбы, доступные только для чтения
@property (readonly) float maxSpeed;
@property (readonly) float speed;
@property (readonly) float dx;
@property (readonly) float dy;
@property (readonly) int winner;

// инициализация объекта
- (instancetype)initWithPuck:(UIView *)puck boundary:(CGRect)boundary goal1:(CGRect)goal1 goal2:(CGRect)goal2 maxSpeed:(float)max;

// сбрасываем положение шайбы, устанавливаем ее в центре ограничивающего прямоугольника
- (void)reset;

// возвращает актуальную центральную позицию шайбы
- (CGPoint)center;

// анимируем шайбу и возвращаем YES, если шайба ударилась о стену
- (BOOL)animate;

// проверяем, произошло ли соударение с клюшкой, если так - изменяем направление движения шайбы
- (BOOL)handleCollision:(Paddle *)paddle;

@end
