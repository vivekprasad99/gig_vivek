import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class TopNavBar extends StatelessWidget {
  final String loginType;

  TopNavBar(this.loginType);

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: TopNavBarMobile(),
      tablet: TopNavBarTabletDesktop(loginType),
    );
  }
}

class TopNavBarMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

class TopNavBarTabletDesktop extends StatelessWidget {
  var userName, userImage;
  final String loginType;

  // var _loginDataCubit = sl<LoginUserDataCubit>();

  TopNavBarTabletDesktop(this.loginType);

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }

  Widget myPopMenu() {
    return PopupMenuButton(
      onSelected: (value) {},
      itemBuilder: (context) => [
        PopupMenuItem(
            value: 1,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                  child: Icon(Icons.print),
                ),
                Text('Print')
              ],
            )),
        PopupMenuItem(
            value: 2,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                  child: Icon(Icons.share),
                ),
                Text('Share')
              ],
            )),
        PopupMenuItem(
          value: 3,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(Icons.add_circle),
              ),
              Text('Add')
            ],
          ),
        ),
      ],
    );
  }
}
