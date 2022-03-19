import 'package:bonfire/bonfire.dart';
import 'package:bonfire/joystick/joystick.dart';
import 'package:bonfire/joystick/joystick_directional.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum MyJoystickActions { attack }

class MyJoystick extends Joystick {
  static const btnSpace = 32;
  MyJoystick()
      : super(
            actions: [
              JoystickAction(
                actionId: MyJoystickActions.attack,
                //(required) Action identifier, will be sent to 'void joystickAction(JoystickActionEvent event) {}' when pressed
                sprite: Sprite.load('joystick_atack_range.png'),
                // the action image
                spritePressed: Sprite.load('joystick_atack_range.png'),
                spriteBackgroundDirection:
                    Sprite.load('joystick_background.png'),
                enableDirection: true,
                align: JoystickActionAlign.BOTTOM_RIGHT,
                color: Colors.blue,
                size: 50,
                margin: const EdgeInsets.only(bottom: 50, right: 160),
              )
            ],
            directional: JoystickDirectional(
              spriteBackgroundDirectional:
                  Sprite.load('joystick_background.png'),
              spriteKnobDirectional: Sprite.load('joystick_knob.png'),
              color: Colors.black,
              size: 100,
              isFixed: false,
            ),
            keyboardConfig: KeyboardConfig(
              enable: true,
              acceptedKeys: [
                // You can pass specific Keys accepted. If null accept all keys
                LogicalKeyboardKey.space,
              ],
              keyboardDirectionalType: KeyboardDirectionalType.wasd,
            ));
}
