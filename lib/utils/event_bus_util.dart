import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();


class TabChangeEvent {
}

class PdaScanEvent {
  String scanCode;
  PdaScanEvent(this.scanCode);
}