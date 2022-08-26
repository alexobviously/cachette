import 'package:cachette/cachette.dart';

void main(List<String> args) async {
  final cachette = Cachette<int, String>(3);
  cachette.evictionStream.listen(print);
  cachette.add(0, 'zero');
  cachette.add(1, 'one');
  cachette.add(2, 'two');
  print(cachette[0]);
  cachette.add(3, 'three');
  cachette[4] = 'four';
  await Future.delayed(Duration(milliseconds: 100));
  print(cachette.values);
}
