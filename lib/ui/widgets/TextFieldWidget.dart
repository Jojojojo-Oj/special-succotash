import 'package:flutter/material.dart';

class CustomTextinput extends StatelessWidget{
  const CustomTextinput(this.txtfController,this.hinttxt, this.psfl,{super.key});

  final TextEditingController txtfController;
  final String hinttxt;
  final bool psfl;



  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(
        fontSize: 14,
        color: Colors.black,
      ),
      controller: txtfController,
      obscureText: psfl,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey,width: 1.0)
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color.fromRGBO(19, 37,64, 1), width: 1.5),
        ),
        hintText: hinttxt,
      ),
    );
  }
}