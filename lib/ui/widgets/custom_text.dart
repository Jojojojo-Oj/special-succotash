import 'package:flutter/material.dart';

class CustomText extends StatelessWidget{
  const CustomText(this.txtSize,this.txtColor,this.txt,{super.key});
  final String txt;
  final Color txtColor;
  final double txtSize;
  @override
  Widget build(BuildContext context) {
    return Text(txt,
    style: TextStyle(
      fontSize: txtSize,
      color: txtColor
    ));
  }
}