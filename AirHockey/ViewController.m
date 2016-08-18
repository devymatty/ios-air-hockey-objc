//
//  ViewController.m
//  Paddies
//
//  Created by Mikhail on 27.07.16.
//  Copyright © 2016 iDevelopment Mikey's. All rights reserved.
//

#import "ViewController.h"

#define MAX_SCORE 3

@interface ViewController () {
    UITouch *touch1;
    UITouch *touch2;
    
    float dx;
    float dy;
    float speed;
    
    NSTimer *timer;
    
    UIAlertController *alertCntrllr;
    
    SystemSoundID sounds[3];
}

@property (weak, nonatomic) IBOutlet UIImageView *imgViewPuck;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewPaddle1;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewPaddle2;

//@property (weak, nonatomic) IBOutlet UIView *viewPaddle1;
//@property (weak, nonatomic) IBOutlet UIView *viewPaddle2;
//@property (weak, nonatomic) IBOutlet UIView *viewPuck;
@property (weak, nonatomic) IBOutlet UILabel *viewScore1;
@property (weak, nonatomic) IBOutlet UILabel *viewScore2;

- (void)resume;
- (void)pause;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSounds];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self newGame];
}


#define SOUND_WALL 0
#define SOUND_PADDLE 1
#define SOUND_SCORE 2
// загружаем звуковой эффект в индекс звукового массива
- (void)loadSound:(NSString *)name slot:(int)slot {
    if (sounds[slot] != 0) {
        return;
    }
    
    // создаем имя пути к звуковому файлу
    NSString *sndPath = [[NSBundle mainBundle]pathForResource:name ofType:@"wav" inDirectory:@"/"];
    
    // создаем системный ID звука в нашей звуковой ячейке (слоте)
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) [NSURL fileURLWithPath:sndPath], &sounds[slot]);
}

- (void)initSounds {
    [self loadSound:@"wall" slot:SOUND_WALL];
    [self loadSound:@"paddle" slot:SOUND_PADDLE];
    [self loadSound:@"score" slot:SOUND_SCORE];
}

- (void)playSound:(int)slot {
    AudioServicesPlaySystemSound(sounds[slot]);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // перебираем все элементы касания
    for (UITouch *touch in touches) {
        // получаем точку касания в пределах вида
        CGPoint touchPoint = [touch locationInView:self.view];
        
        // проверяем, в какой половине экрана произошло касание,
        // и присваиваем его той или иной ракетке, если оно еще не присвоено
        
        // перемещаем одну из ракеток, в зависимости от того, в какой части экрана произошло касание
        if (touch1 == nil && touchPoint.y < self.view.bounds.size.height/2) {
            touch1 = touch;
            _imgViewPaddle1.center = CGPointMake(touchPoint.x, _imgViewPaddle1.center.y);
            
        } else if (touch2 == nil && touchPoint.y >= self.view.bounds.size.height/2) {
            touch2 = touch;
            _imgViewPaddle2.center = CGPointMake(touchPoint.x, _imgViewPaddle2.center.y);
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // итерируем через все объекты касания
    for (UITouch *touch in touches) {
        //  получаем точку касания внутри вида
        CGPoint touchPoint = [touch locationInView:self.view];
        
        // если ракетке присвоено касание, то перемещаем ракетку
        if (touch == touch1) {
            _imgViewPaddle1.center = CGPointMake(touchPoint.x, _imgViewPaddle1.center.y);
        } else if (touch == touch2) {
            _imgViewPaddle2.center = CGPointMake(touchPoint.x, _imgViewPaddle2.center.y);
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // итерируем через все объекты касания
    for (UITouch *touch in touches) {
        if (touch == touch1) {
            touch1 = nil;
        } else if (touch == touch2) {
            touch2 = nil;
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

- (void)reset {
    // задаем направление мячика, чтобы он летеле либо влево, либо вправо
    if ((arc4random() % 2) == 0) {
        dx = -1;
    } else {
        dx = 1;
    }
    
    // задаем для dy обратное значение, если ее предыдущее значениее было ненулевым. В таком случае мячик полетит к игроку, только что набравшему очко. В противном случае пускаем мячик в случайном направлении.
    if (dy != 0) {
        dy = -dy;
    } else {
        if ((arc4random() % 2) == 0) {
            dy = -1;
        } else {
            dy = 1;
        }
    }
    
    // перемещаем точку в случайное положение в области центра
    _imgViewPuck.center = CGPointMake(15 + arc4random() % ((int)self.view.bounds.size.width - 30), self.view.bounds.size.height/2);
    
    // сбрасываем скорость
    speed = 2;
}

- (void)animate {
    // перемещаем мячик в новую позицию в зависимости от направления
    // и скорости движения
    _imgViewPuck.center = CGPointMake(_imgViewPuck.center.x + dx*speed, _imgViewPuck.center.y + dy*speed);
    
    // проверяем, не ударился ли мяч о левую или правую стенку
    if ([self checkPuckCollision:CGRectMake(-10.0, 0, 20.0, self.view.bounds.size.height) dirX:fabs(dx) dirY:0]) {
        // воспроизводим звук удара о стену
        [self playSound:SOUND_WALL];
    }
    if ([self checkPuckCollision:CGRectMake(self.view.bounds.size.width-10.0, 0, 20.0, self.view.bounds.size.height) dirX:-fabs(dx) dirY:0]) {
        // воспроизводим звук удара о стену
        [self playSound:SOUND_WALL];
    }

    // проверяем, не ударился ли мяч о ракетку одного из игроков
    if ([self checkPuckCollision:_imgViewPaddle1.frame dirX:(_imgViewPuck.center.x-_imgViewPaddle1.center.x)/32.0 dirY:1]) {
        // воспроизводим звук соударения с ракеткой
        // и увеличиваем скорость мячика
        [self increaseSpeed];
        [self playSound:SOUND_PADDLE];
    }
    if ([self checkPuckCollision:_imgViewPaddle2.frame dirX:(_imgViewPuck.center.x-_imgViewPaddle2.center.x)/32.0 dirY:-1]) {
        // воспроизводим звук соударения с ракеткой
        // и увеличиваем скорость мячика
        [self increaseSpeed];
        [self playSound:SOUND_PADDLE];
    }
    
    // проверяем не забит ли мяч
    if ([self checkGoal]) {
        // воспроизводим звук начисления очка
        [self playSound:SOUND_SCORE];
    }
}

- (void)start {
    if (timer == nil) {
        // создаем анимационный таймер
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0
                                                 target:self
                                               selector:@selector(animate)
                                               userInfo:nil
                                                repeats:YES];
    }
    // оображаем мячик
    _imgViewPuck.hidden = NO;
}

- (void)stop {
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
    }
    
    // скрываем мячик
    _imgViewPuck.hidden = YES;
}



- (BOOL)checkPuckCollision:(CGRect)rect dirX:(float)x dirY:(float)y {
    // проверяем, пересекается ли мячик с переданным прямоугольником
    if  (CGRectIntersectsRect(_imgViewPuck.frame, rect)) {
        // изменяем направление мячика
        if (x != 0) {
            dx = x;
        }
        if (y != 0) {
            dy = y;
        }
        return YES;
    }
    return NO;
}

- (BOOL)checkGoal {
    // Проверяем, не вышел ли мяч за пределы поля, и если так - сбрасываем игру
    if (_imgViewPuck.center.y < 0 || _imgViewPuck.center.y >= self.view.bounds.size.height) {
        // получаем целочисленное значение из содержимого подписи со счетом
        int s1 = _viewScore1.text.intValue;
        int s2 = _viewScore2.text.intValue;
        
        // даем очко тому игроку,который его заработал
        if (_imgViewPuck.center.y < 0) {
            ++s2;
        } else {
            ++s1;
        }
        
        // обновляем подписи со счетом
        _viewScore1.text = [NSString stringWithFormat:@"%u", s1];
        _viewScore2.text = [NSString stringWithFormat:@"%u", s2];
        
        // проверяем, не определился ли победитель
        if ([self gameOver] == 1) {
            // называем победителя
            [self displayMessage:@"Player 1 has won!"];
        } else if ([self gameOver] == 2) {
            // называем победителя
            [self displayMessage:@"Player 2 has won!"];
        } else {
            // сбрасываем прежний раунд и начинам новый
            [self reset];
        }
        
        // возвращаем TRUE, если мяч был забит
        return YES;
    }
    
    // мяч не забит
    return NO;
}

- (void)displayMessage:(NSString *)msg {
    
    // не отображаем более одного сообщения
    if (alertCntrllr) {
        return;
    }

    // останавливаем анимационный таймер
    [self stop];
    
    // создаем и выводим на экран сообщение с предупреждением
    alertCntrllr = [UIAlertController alertControllerWithTitle:@"Game" message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ОК" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // сообщение убрано с экрана поэтому игра сбрасывается и запускается анимация
        alertCntrllr = nil;
        
        if ([self gameOver]) {
            [self newGame];
            return;
        }
        
        [self reset];
        [self start];
    }];
    
    [alertCntrllr addAction:okAction];

    [self presentViewController:alertCntrllr animated:YES completion:nil];
}

- (void)newGame {
    [self reset];
    
    // сбрасываем счет
    _viewScore1.text = @"0";
    _viewScore2.text = @"0";
    
    // отображаем сообщение о том, что игра начинается
    [self displayMessage:@"Ready to play?"];
}

- (int)gameOver {
    if (_viewScore1.text.intValue >= MAX_SCORE) {
        return 1;
    }
    if (_viewScore2.text.intValue >= MAX_SCORE) {
        return 2;
    }
    return 0;
}

- (void)increaseSpeed {
    speed += 0.5;
    if (speed > 10) {
        speed = 10;
    }
}

- (void)pause {
    [self stop];
}

- (void)resume {
    // чтобы продолжить игру, отображаем соответствующее сообщение
    [self displayMessage:@"Game Paused"];
}

@end














