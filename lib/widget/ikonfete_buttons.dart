import 'package:flutter/material.dart';

class PrimaryButton extends StatefulWidget {
  final double width;
  final double height;
  final Function onTap;
  final String text;
  final Color defaultColor;
  final Color activeColor;
  final Color borderColor;
  final Color disabledColor;
  final TextStyle textStyle;
  final double elevation;
  final Widget child;
  final BorderRadius borderRadius;
  final bool disabled;

  PrimaryButton({
    @required this.width,
    @required this.height,
    this.text,
    this.child,
    @required this.defaultColor,
    this.activeColor,
    this.disabledColor,
    this.borderColor: Colors.transparent,
    this.elevation: 1.0,
    this.textStyle: const TextStyle(color: Colors.white),
    this.onTap,
    this.borderRadius,
    this.disabled: false,
  })  : assert(!(text == null && child == null)),
        assert(!(text != null && child != null));

  @override
  _PrimaryButtonState createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  Color _buttonColor;

  @override
  void initState() {
    super.initState();
    _buttonColor = widget.defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: widget.disabled
          ? null
          : (details) {
              if (widget.activeColor != null) {
                setState(() {
                  _buttonColor = widget.activeColor;
                });
              }
            },
      onTapUp: widget.disabled
          ? null
          : (details) {
              setState(() {
                _buttonColor = widget.defaultColor;
              });
            },
      child: Container(
        width: this.widget.width,
        height: 50.0,
        child: Material(
          type: MaterialType.button,
          color: !widget.disabled
              ? _buttonColor
              : widget.disabledColor ?? widget.defaultColor.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: widget.borderColor, width: 1.0),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(5.0),
          ),
          elevation: widget.elevation,
          child: Center(
            child: widget.text != null
                ? Text(
                    this.widget.text,
                    style: widget.textStyle,
                  )
                : widget.child,
          ),
        ),
      ),
    );
  }
}
